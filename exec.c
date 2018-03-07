#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
  char *s, *last;
  int i, off;
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
  if((ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);
  pgdir = 0;

  // assignment3
  #ifndef NONE 
  //create structures to save all relevant data
  struct discPages disc[MAX_PSYC_PAGES];
  struct physicalPages physical[MAX_PSYC_PAGES];
  //save current data and reset current process
  struct physicalPages *head = proc->head;
  proc->head = 0; 
  struct physicalPages *tail = proc->tail;
  proc->tail = 0;
  int pagesInPhMem = proc->pagesInPhMem;
  proc->pagesInPhMem = 0;
  int pagesInDisc = proc->pagesInDisc;
  proc->pagesInDisc = 0;
  int totalPageFaultCount = proc->totalPageFaultCount;
  proc->totalPageFaultCount = 0;
  int totalSwappedCount = proc->totalSwappedCount;
  proc->totalSwappedCount = 0;

  // iterate arrays , copy the data and reset process
  for(int i = 0 ; i < MAX_PSYC_PAGES ; i++){
    physical[i].virtualAdress = proc->physical[i].virtualAdress;
    proc->physical[i].virtualAdress = (char*)0xffffffff;
    physical[i].next = proc->physical[i].next;
    proc->physical[i].next = 0;
    physical[i].prev = proc->physical[i].prev;
    proc->physical[i].prev = 0;
    physical[i].accessCount = proc->physical[i].accessCount;
    proc->physical[i].accessCount = 0;
    disc[i].virtualAdress = proc->disc[i].virtualAdress;
    proc->disc[i].virtualAdress = (char*)0xffffffff;
  }
  #endif
  // finish

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
    goto bad;

  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  proc->pgdir = pgdir;
  proc->sz = sz;
  proc->tf->eip = elf.entry;  // main
  proc->tf->esp = sp;

  // assignment3 
    removeSwapFile(proc); //delete old disc
    createSwapFile(proc); //create new disc
  //finish

  switchuvm(proc);
  freevm(oldpgdir);
  cprintf("exec : number of page allocate : %d, with pid: %d and name : %s\n", proc->pagesInPhMem, proc->pid, proc->name);
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
    end_op();
  }

  // assignment3
  #ifndef NONE
  // set all the fields
  proc->head = head;
  proc->tail = tail;
  proc->pagesInPhMem = pagesInPhMem;
  proc->pagesInDisc = pagesInDisc;
  proc->totalPageFaultCount = totalPageFaultCount;
  proc->totalSwappedCount = totalSwappedCount;

   // iterate arrays , set the new data 
  for(int i = 0 ; i < MAX_PSYC_PAGES ; i++)
  {
    proc->physical[i].virtualAdress = physical[i].virtualAdress;
    proc->physical[i].next = physical[i].next;
    proc->physical[i].prev = physical[i].prev;
    proc->physical[i].accessCount = physical[i].accessCount;
    proc->disc[i].virtualAdress = disc[i].virtualAdress;
  }
  #endif
  // finish

  return -1;
}
