#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "elf.h"

#define BUF_SIZE PGSIZE/2
extern char data[];  // defined by kernel.ld
pde_t *kpgdir;  // for use in scheduler()
struct segdesc gdt[NSEGS];

struct physicalPages *writeToSwapFileFunction(char *va);
void insertNewPage(char *va);
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
  struct cpu *c;

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);

  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);

  // Initialize cpu-local storage.
  cpu = c;
  proc = 0;
}

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// There is one page table per process, plus one that's used when
// a CPU is not running any process (kpgdir). The kernel uses the
// current process's page table during system calls and interrupts;
// page protection bits prevent user code from using the kernel's
// mappings.
//
// setupkvm() and exec() set up every page table like this:
//
//   0..KERNBASE: user memory (text+data+stack+heap), mapped to
//                phys memory allocated by the kernel
//   KERNBASE..KERNBASE+EXTMEM: mapped to 0..EXTMEM (for I/O space)
//   KERNBASE+EXTMEM..data: mapped to EXTMEM..V2P(data)
//                for the kernel's instructions and r/o data
//   data..KERNBASE+PHYSTOP: mapped to V2P(data)..PHYSTOP,
//                                  rw data + free physical memory
//   0xfe000000..0: mapped direct (devices such as ioapic)
//
// The kernel allocates physical memory for its heap and for user memory
// between V2P(end) and the end of physical memory (PHYSTOP)
// (directly addressable from end..P2V(PHYSTOP)).

// This table defines the kernel's mappings, which are present in
// every process's page table.
static struct kmap {
  void *virt;
  uint phys_start;
  uint phys_end;
  int perm;
} kmap[] = {
 { (void*)KERNBASE, 0,             EXTMEM,    PTE_W}, // I/O space
 { (void*)KERNLINK, V2P(KERNLINK), V2P(data), 0},     // kern text+rodata
 { (void*)data,     V2P(data),     PHYSTOP,   PTE_W}, // kern data+memory
 { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // more devices
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
}

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
  kpgdir = setupkvm();
  switchkvm();
}

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(v2p(kpgdir));   // switch to the kernel page table
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  pushcli();
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
  cpu->gdt[SEG_TSS].s = 0;
  cpu->ts.ss0 = SEG_KDATA << 3;
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  lcr3(v2p(p->pgdir));  // switch to new address space
  popcli();
}

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
}

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
}

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  //assignment3
  // if its non-normal selection
  #ifndef NONE
  uint newpage = 0; // 0 - write to physical memory ; 1- write to disc
  #endif
  // finish

  char *mem;
  uint a;

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
    //assignment3 
    //if exceed physicalPages size copy a page to disc and reset page for this new page
    #ifndef NONE
    if (proc->pagesInPhMem >= MAX_PSYC_PAGES){
      writeToSwapFileFunction((char*)a);
        newpage = 1;
    }
    #endif

    mem = kalloc();
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    //if there is place in physicalPages ,add it
    #ifndef NONE
    if (newpage == 0)
      insertNewPage((char*)a);
    #endif
	//finish
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;
  int i;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a += (NPTENTRIES - 1) * PGSIZE;
    else if((*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
        //assignment3
        if (proc->pgdir == pgdir) {
		#ifndef NONE
		//search for index that points to virtual address a
          for (i = 0; i < MAX_PSYC_PAGES; i++) {
            if (proc->physical[i].virtualAdress == (char*)a)
              goto foundEntry;
          }
          panic("deallocuvm: no entry found in physical memory");
  foundEntry:
  //reset virtualAdress
          proc->physical[i].virtualAdress = (char*) 0xffffffff;
            // remove the physical[i] from the linked list
			//first check if head points to physical[i]
          if (proc->head == &proc->physical[i]){
            proc->head = proc->physical[i].next;
            if(proc->head != 0)
              proc->head->prev = 0;
            goto done;
          }
		  // check if tail points to physical[i]
          if (proc->tail == &proc->physical[i]){
            proc->tail = proc->physical[i].prev;
            goto done;
          }
		  //if its neither of them than remove from linked list in normal way
          struct physicalPages *temp = proc->head;
		  //find link before physical[i] or before null if not found
          while (temp->next != 0 && temp->next != &proc->physical[i]){
            temp = temp->next;
          }
		  //change the next of link before physical[i] to physical[i].next 
          temp->next = proc->physical[i].next;
          if (proc->physical[i].next != 0){
            proc->physical[i].next->prev = temp; 
          }
  done:
  //reset pointers
          proc->physical[i].next = 0;
          proc->physical[i].prev = 0;

  #endif
	//decrement total pages in physical memory
  	//cprintf("deallocuvm - pages in mem before dealloc  %d\n" ,proc->pagesInPhMem);
          proc->pagesInPhMem--;
        }
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
    //entry not found in physical memory , search in disc
  else if (*pte & PTE_PG && proc->pgdir == pgdir) {
      for (i = 0; i < MAX_PSYC_PAGES; i++) {
        if (proc->disc[i].virtualAdress == (char*)a)
          goto foundEntryDisc;
      }
    panic("deallocuvm: no entry found in disc");
	foundEntryDisc:
      proc->disc[i].virtualAdress = (char*) 0xffffffff;
	  //cprintf("total pages in disc: %d    one page is removed from disc %d \n",proc->pagesInDisc,proc->pagesInDisc-1);
	  //decrement pages in disc
      proc->pagesInDisc--;
	  //finish
  }
}

  return newsz;
}

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
}

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
  *pte &= ~PTE_U;
}

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    // check if the page exist and that PTE_PG is on
    // assignment3
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
      panic("copyuvm: page not present or is not page out");

    if(*pte & PTE_PG) // there was a page out
    {
      pte = walkpgdir(d, (void*)i, 1);
	  // update the flags of the swapped out PGE to : not present, pagedOut, user, writeable
      *pte = PTE_U | PTE_W | PTE_PG;
      continue;
    }
    // finish
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;

bad:
  freevm(d);
  return 0;
}

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)p2v(PTE_ADDR(*pte));
}

// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}

//assignment3
// helper function for the access bit
int checkAccBit(char *va){
  uint accBit;
  //get address of PTE
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
  //check if empty
  if (!*pte)
    panic("checkAccBit: pte1 is empty");
    //get accessBit
  accBit = (*pte) & PTE_A;
  (*pte) &= ~PTE_A; // reset to PTE_A only bit
  return accBit;
}


void changeToScFifo() {
  struct physicalPages *temp = proc->tail;
  do{
    //move temp from tail to head
    proc->tail = proc->tail->prev;
    proc->tail->next = 0;
    temp->prev = 0;
    temp->next = proc->head;
    proc->head->prev = temp;
    proc->head = temp;
    temp = proc->tail;
  }while(checkAccBit(proc->head->virtualAdress));

}

// searching for the minimum accessed bit
int findMinAccessed () {
    int min= 1000000;
    int index = -1;
  // find the minimum accessed page
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    //if virtualAdress points to null cont
    if (proc->physical[i].virtualAdress == (char*)0xffffffff)
      continue;
      //update is found smaller
      if(proc->physical[i].accessCount <  min){
       min = proc->physical[i].accessCount;
       index = i;
    }
  }
  return index;
}

// doing the actual swap
struct physicalPages *writeToSwapFileFunction(char *va){

  if (proc->head == 0 || (proc->head->next == 0))
    panic("writeToSwapFileFunction: proc->head is NULL or single page in physical memory");

  int i;
  struct physicalPages *pageToWrite = 0;

  #if LAP
  //cprintf("LAP LAP LAP LAP LAP\n");
  //if LAP is selected we need to remove the least accessed page 
  int index = findMinAccessed();
  pageToWrite = &proc->physical[index];
  
  #elif SCFIFO
  //if SCFIFO is selected we remove according to create time and PTE_A flag (accBit)
  changeToScFifo();
  pageToWrite = proc->head;
  
  #elif LIFO
  //if FIFO is selected we remove the last one 
  pageToWrite = proc->head;
  #endif

  // searching for a free page slot in the disc
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->disc[i].virtualAdress == (char*)0xffffffff)
      goto foundDiscSlot;
  }
  panic("writeToSwapFileFunction: can't find slot in disc");
foundDiscSlot:
  // save the pageToWrite object into the disc
  proc->disc[i].virtualAdress = pageToWrite->virtualAdress;
  if ( writeToSwapFile(proc, (char*)PTE_ADDR(pageToWrite->virtualAdress), i * PGSIZE, PGSIZE) == 0) //if 0 returned writeToSwapFile failed
    return 0;
  // search for the PTE of the previous page
  pte_t *pte_temp = walkpgdir(proc->pgdir, (void*)pageToWrite->virtualAdress, 0);
  if (!*pte_temp)
    panic("writeToSwapFileFunction: pte1 is empty");
 // cprintf("swapping out address: %x\n", pageToWrite->virtualAdress);
  kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, pageToWrite->virtualAdress, 0))));
  // set the default flags 
  *pte_temp = PTE_W | PTE_U | PTE_PG;
  
  proc->totalSwappedCount++; //update totalPagesCount
  proc->pagesInDisc++;  //update pages in disc
  lcr3(v2p(proc->pgdir)); // change the register

  pageToWrite->virtualAdress = va; // change the swapped page to be the new one
  pageToWrite->accessCount = 0; //reset accessCount
  return pageToWrite;
}


// this function record a new page
void insertNewPage(char *va) {
  int i;
  //looking for unused physical index 
  for (i = 0; i < MAX_PSYC_PAGES; i++)
    if (proc->physical[i].virtualAdress == (char*)0xffffffff)
      goto foundSpace;
   panic("insertNewPage: no free pages");
  // enter the new physicalPages in the head of the list
foundSpace:
	//cprintf("insert new page : found empty space in position %d\n",i);
	// first set the page fields
  proc->physical[i].virtualAdress = va; // set the virtualAdress
  proc->physical[i].accessCount = 0; // reset the accessCount to 0 for a new page.
  proc->physical[i].next = proc->head; // set the new page to point at head
  proc->physical[i].prev = 0; // the prev will be null
  // update list
  if(proc->head != 0) // if head is not null , set head prev to point at our page
    proc->head->prev = &proc->physical[i];
  else //head is null so first link inserted is also the tail
    proc->tail = &proc->physical[i];
  proc->head = &proc->physical[i]; //know set head to the new page
  proc->pagesInPhMem++;
  //cprintf("pages in memory after insert new page %d\n" ,proc->pagesInPhMem);
}

void swapHelperFunction(void* vaOut, uint vaIn) {
  int i, j;
  char buf[BUF_SIZE];
  pte_t *pte_out, *pte_in;
  pte_out = walkpgdir(proc->pgdir, vaOut, 0); // take the page table adress to swap into the swapFile
  if (!*pte_out)
    panic("swapHelperFunction: pte_out is empty");
  //searching for unused disc index 
  for (i = 0; i < MAX_PSYC_PAGES; i++)
    if (proc->disc[i].virtualAdress == (char*)PTE_ADDR(vaIn))
      goto foundInDisc;
  panic("swapHelperFunction: no slot in disc");
foundInDisc:
 //cprintf("swap helper function : found virtual address in position %d\n",i);
  proc->disc[i].virtualAdress  = vaOut; //update relevant fields for the swaped page
  //assign the physical page to addr in the relevant page table
  pte_in = walkpgdir(proc->pgdir, (void*)vaIn, 0);
  if (!*pte_in)
    panic("swapHelperFunction: pte_in is empty");
  //set new page table entry
  *pte_in = PTE_ADDR(*pte_out) | PTE_U | PTE_W | PTE_P;
  // doing the actual swap 
  for (j = 0; j < 2; j++) {
    int loc = (i * PGSIZE) + ((PGSIZE / 2) * j);
    int addroffset = ((PGSIZE / 2) * j);
    // set the buffer to zero
    memset(buf, 0, BUF_SIZE);
   // read from the swap file to the buffer (reading the page we bringing)
    readFromSwapFile(proc, buf, loc, BUF_SIZE);
    // write the page we swapping out to the swapFile
    writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_out)) + addroffset), loc, BUF_SIZE);
    //copy the new page from buff to the main memory
    memmove((void*)(PTE_ADDR(vaIn) + addroffset), (void*)buf, BUF_SIZE);
  }
   // update the flags of the swapped out PGE to : not present, pagedOut, user, writeable
  *pte_out = PTE_U | PTE_W | PTE_PG;
}


void swapPagesInTrap(uint addr){
  //ignore init and shell 
 if (proc->pid <= 2) {
    proc->pagesInPhMem++;
    return;
  }
//check for errors
  if (proc->head == 0 || (proc->head->next == 0))
    panic("writeToSwapFileFunction: proc->head is NULL or single page in physical memory");

#if LIFO
  swapHelperFunction(proc->head->virtualAdress,addr);
  proc->head->virtualAdress = (char*)PTE_ADDR(addr); //update head 
#elif SCFIFO
  changeToScFifo(); 
   swapHelperFunction(proc->head->virtualAdress,addr);
  proc->head->virtualAdress = (char*)PTE_ADDR(addr);//update head 
#elif LAP
  int index = findMinAccessed(); //find minimum accessed index to be swapped
   swapHelperFunction( proc->physical[index].virtualAdress,addr); //swap
  proc->physical[index].virtualAdress = (char*)PTE_ADDR(addr); //update head
#endif

  lcr3(v2p(proc->pgdir)); // update the page directory
   proc->totalSwappedCount++;
}

//PAGEBREAK!
// Blank page.
//PAGEBREAK!
// Blank page.
//PAGEBREAK!
// Blank page.