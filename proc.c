#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "elf.h"
#include "spinlock.h"
#include "kalloc.h"

// assignment3 
//external functions we need to import
extern pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);
extern struct physicalPageStat physicalPageStatistic;
void printProcMemPageInfo(struct proc *proc); 
// finish
struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);



void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

//assignment3
//initialize pages for new process  in disc and in physical memory
  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
   p->physical[i].virtualAdress = (char*)0xffffffff;
   p->physical[i].next = 0;
   p->physical[i].prev = 0;
   p->disc[i].virtualAdress = (char*)0xffffffff;
 }
 // initialize global variable in process for the page
 p->pagesInPhMem = 0;
 p->pagesInDisc = 0;
 p->head = 0;
 p->tail = 0;
 p->totalPageFaultCount=0;
 p->totalSwappedCount=0;
// finish
  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;

  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  // assignment3 
  //copy # of pages in physical memory and in disc
  np->pagesInPhMem = proc->pagesInPhMem;
  np->pagesInDisc = proc->pagesInDisc;
 // finish
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));

  pid = np->pid;

  // assignment3 
  createSwapFile(np);
  char buf[PGSIZE/2] = "";
  int offset = 0;
  int nread = 0;
  //read parent's disc in chunks of pgsize/2
  //don't copy init proc or shell
   if (proc->pid >   2) {
     //read until failed reading
     while ((nread = readFromSwapFile(proc, buf, offset, PGSIZE/2)) != 0) {
       if (writeToSwapFile(np, buf, offset, nread) == -1){
        panic("fork:error copy disc from parent to child");
      }
      //update offset accoring to read data
      offset += nread;
    }
  }

//go over all pages and copy fields virtualAdress, accessCount and swapLocation
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
    np->physical[i].virtualAdress = proc->physical[i].virtualAdress;
    np->physical[i].accessCount = proc->physical[i].accessCount;
    np->disc[i].virtualAdress = proc->disc[i].virtualAdress;
  }
//after we copied all pages now we need to change next and prev for each one
//do it in a wasteful way to prevent errors! 
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    for (int j = 0; j < MAX_PSYC_PAGES; ++j){
      //if found next update it and break from inner loop
      if(np->physical[j].virtualAdress == proc->physical[i].next->virtualAdress){
        np->physical[i].next = &np->physical[j];
        break;
      }
//if found prev update it and break from inner loop
      if(np->physical[j].virtualAdress == proc->physical[i].prev->virtualAdress){
        np->physical[i].prev = &np->physical[j];
        break;
        }
      }
    }

    #ifndef NONE
	//if SELECTION != NONE update process head and tail
      for (i = 0; i < MAX_PSYC_PAGES; i++) {
        if (proc->head->virtualAdress == np->physical[i].virtualAdress)
          np->head = &np->physical[i];
        if (proc->tail->virtualAdress == np->physical[i].virtualAdress)
          np->tail = &np->physical[i];
      }
    #endif
	//finish

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  np->state = RUNNABLE;
  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }
  //assignment3
  //delete disc before exiting 
  removeSwapFile(proc);
  #if TRUE
  //print memory info if flag is TRUE 
  printProcMemPageInfo(proc);
  #endif

  //finish

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  proc->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  int percent;
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    printProcMemPageInfo(p);
  }
  // print general (not per-process) physical memory pages info
  uint a = physicalPageStatistic.numOfPhysicalPages;
  uint b =  physicalPageStatistic.numOfInitPages;
  percent = a*100/b;
  cprintf("\nratio:  %d/%d = 0.%d%\n",  physicalPageStatistic.numOfPhysicalPages,physicalPageStatistic.numOfInitPages , percent);
  }

void
printProcMemPageInfo(struct proc *proc){
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleeping",
  [RUNNABLE]  "runnable",
  [RUNNING]   "running",
  [ZOMBIE]    "zombie"
  };
  int i;
  char *state;
 uint pc[10];

  if(proc->state >= 0 && proc->state < NELEM(states) && states[proc->state])
    state = states[proc->state];
  else
    state = "???";

  // regular xv6 procdump printing
  cprintf("\n%d %s %s\n", proc->pid, state, proc->name);

  //print out memory pages info:
  cprintf("allocated memory pages: %d\n", proc->pagesInPhMem);
  cprintf("currently paged out: %d\n", proc->pagesInDisc);
  cprintf("page faults: %d\n", proc->totalPageFaultCount);
  cprintf("Total number of paged out operation: %d\n\n", proc->totalSwappedCount);

  // regular xv6 procdump printing
  if(proc->state == SLEEPING){
    getcallerpcs((uint*)proc->context->ebp+2, pc);
    for(i=0; i<10 && pc[i] != 0; i++)
      cprintf("%p ", pc[i]);
  }
  }

void
updateLAP()
{
    struct proc *p;
    int i;
    pte_t *pageTableEntry;
    acquire(&ptable.lock);
    for(p = ptable.proc ; p < &ptable.proc[NPROC]; p++)
    {
        // check the process state and that it is not shell to init
        if((p->state == RUNNING || p->state == RUNNABLE || p->state == SLEEPING) && (p->pid > 2))
        {
            // iterate over all the pages in memory
            for(i = 0 ; i < MAX_PSYC_PAGES ; i++)
            {
                if(p->physical[i].virtualAdress == (char*)0xffffffff)
                {
                    continue; // there is no page here so nothing to do
                }
                pageTableEntry = walkpgdir(p->pgdir, p->physical[i].virtualAdress, 0);
                if(*pageTableEntry & PTE_A) // check if access bit is on
                {
                  p->physical[i].accessCount++;
                }
                *pageTableEntry &= ~PTE_A; //reset all bits but PTE_A
            }
        }
    }
    release(&ptable.lock);
}



