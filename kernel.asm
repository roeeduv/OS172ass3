
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 e6 10 80       	mov    $0x8010e650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 85 40 10 80       	mov    $0x80104085,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 30 9d 10 80       	push   $0x80109d30
80100042:	68 60 e6 10 80       	push   $0x8010e660
80100047:	e8 f9 5c 00 00       	call   80105d45 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 25 11 80 64 	movl   $0x80112564,0x80112570
80100056:	25 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 25 11 80 64 	movl   $0x80112564,0x80112574
80100060:	25 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 e6 10 80 	movl   $0x8010e694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 25 11 80    	mov    0x80112574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 25 11 80 	movl   $0x80112564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 25 11 80       	mov    0x80112574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 25 11 80       	mov    %eax,0x80112574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 25 11 80       	mov    $0x80112564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 e6 10 80       	push   $0x8010e660
801000c1:	e8 a1 5c 00 00       	call   80105d67 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 25 11 80       	mov    0x80112574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 e6 10 80       	push   $0x8010e660
8010010c:	e8 bd 5c 00 00       	call   80105dce <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 e6 10 80       	push   $0x8010e660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 76 57 00 00       	call   801058a2 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 25 11 80 	cmpl   $0x80112564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 25 11 80       	mov    0x80112570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 e6 10 80       	push   $0x8010e660
80100188:	e8 41 5c 00 00       	call   80105dce <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 25 11 80 	cmpl   $0x80112564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 37 9d 10 80       	push   $0x80109d37
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 b2 2e 00 00       	call   80103099 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 48 9d 10 80       	push   $0x80109d48
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 71 2e 00 00       	call   80103099 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 4f 9d 10 80       	push   $0x80109d4f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 e6 10 80       	push   $0x8010e660
80100255:	e8 0d 5b 00 00       	call   80105d67 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 25 11 80    	mov    0x80112574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 25 11 80 	movl   $0x80112564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 25 11 80       	mov    0x80112574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 25 11 80       	mov    %eax,0x80112574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 d2 56 00 00       	call   80105990 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 e6 10 80       	push   $0x8010e660
801002c9:	e8 00 5b 00 00       	call   80105dce <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 b0 10 80 	movzbl -0x7fef4ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 d5 10 80       	mov    0x8010d5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 d5 10 80       	push   $0x8010d5c0
801003e2:	e8 80 59 00 00       	call   80105d67 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 56 9d 10 80       	push   $0x80109d56
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 5f 9d 10 80 	movl   $0x80109d5f,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 d5 10 80       	push   $0x8010d5c0
8010055b:	e8 6e 58 00 00       	call   80105dce <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 d5 10 80 00 	movl   $0x0,0x8010d5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 66 9d 10 80       	push   $0x80109d66
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 75 9d 10 80       	push   $0x80109d75
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 59 58 00 00       	call   80105e20 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 77 9d 10 80       	push   $0x80109d77
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 d5 10 80 01 	movl   $0x1,0x8010d5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 b0 10 80    	mov    0x8010b000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 7b 9d 10 80       	push   $0x80109d7b
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 8d 59 00 00       	call   80106089 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 a4 58 00 00       	call   80105fca <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 a0 d5 10 80       	mov    0x8010d5a0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 fa 71 00 00       	call   801079b5 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 ed 71 00 00       	call   801079b5 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 e0 71 00 00       	call   801079b5 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 d0 71 00 00       	call   801079b5 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 c0 d5 10 80       	push   $0x8010d5c0
8010080e:	e8 54 55 00 00       	call   80105d67 <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010084d:	a1 08 28 11 80       	mov    0x80112808,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 08 28 11 80       	mov    %eax,0x80112808
        consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	8b 15 08 28 11 80    	mov    0x80112808,%edx
80100870:	a1 04 28 11 80       	mov    0x80112804,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 08 28 11 80       	mov    0x80112808,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 80 27 11 80 	movzbl -0x7feed880(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100898:	8b 15 08 28 11 80    	mov    0x80112808,%edx
8010089e:	a1 04 28 11 80       	mov    0x80112804,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 08 28 11 80       	mov    0x80112808,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 08 28 11 80       	mov    %eax,0x80112808
        consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 08 28 11 80    	mov    0x80112808,%edx
801008dd:	a1 00 28 11 80       	mov    0x80112800,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 08 28 11 80       	mov    0x80112808,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 08 28 11 80    	mov    %edx,0x80112808
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 80 27 11 80    	mov    %dl,-0x7feed880(%eax)
        consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
80100932:	a1 08 28 11 80       	mov    0x80112808,%eax
80100937:	8b 15 00 28 11 80    	mov    0x80112800,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 08 28 11 80       	mov    0x80112808,%eax
80100949:	a3 04 28 11 80       	mov    %eax,0x80112804
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 00 28 11 80       	push   $0x80112800
80100956:	e8 35 50 00 00       	call   80105990 <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 c0 d5 10 80       	push   $0x8010d5c0
80100979:	e8 50 54 00 00       	call   80105dce <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 c2 50 00 00       	call   80105a4e <procdump>
  }
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 ba 14 00 00       	call   80101e5a <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 d5 10 80       	push   $0x8010d5c0
801009b1:	e8 b1 53 00 00       	call   80105d67 <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 c0 d5 10 80       	push   $0x8010d5c0
801009d3:	e8 f6 53 00 00       	call   80105dce <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 16 13 00 00       	call   80101cfc <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 d5 10 80       	push   $0x8010d5c0
801009fb:	68 00 28 11 80       	push   $0x80112800
80100a00:	e8 9d 4e 00 00       	call   801058a2 <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 00 28 11 80    	mov    0x80112800,%edx
80100a0e:	a1 04 28 11 80       	mov    0x80112804,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 00 28 11 80       	mov    0x80112800,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 00 28 11 80    	mov    %edx,0x80112800
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 80 27 11 80 	movzbl -0x7feed880(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 00 28 11 80       	mov    0x80112800,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 00 28 11 80       	mov    %eax,0x80112800
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a7e:	e8 4b 53 00 00       	call   80105dce <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 6b 12 00 00       	call   80101cfc <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 a9 13 00 00       	call   80101e5a <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 d5 10 80       	push   $0x8010d5c0
80100abc:	e8 a6 52 00 00       	call   80105d67 <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 c0 d5 10 80       	push   $0x8010d5c0
80100afe:	e8 cb 52 00 00       	call   80105dce <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 eb 11 00 00       	call   80101cfc <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

  return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void
consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 8e 9d 10 80       	push   $0x80109d8e
80100b27:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b2c:	e8 14 52 00 00       	call   80105d45 <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 cc 31 11 80 a0 	movl   $0x80100aa0,0x801131cc
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 c8 31 11 80 8f 	movl   $0x8010098f,0x801131c8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 d5 10 80 01 	movl   $0x1,0x8010d5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 c5 3b 00 00       	call   80104721 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 fb 26 00 00       	call   80103266 <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec 68 02 00 00    	sub    $0x268,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 c4 31 00 00       	call   80103d43 <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 30 1d 00 00       	call   801028ba <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 34 32 00 00       	call   80103dcf <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 60 07 00 00       	jmp    80101305 <exec+0x794>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 4c 11 00 00       	call   80101cfc <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  #ifndef NONE 
  //create structures to save all relevant data
  struct discPages disc[MAX_PSYC_PAGES];
  struct physicalPages physical[MAX_PSYC_PAGES];
  //save current data and reset current process
  struct physicalPages *head = proc->head;
80100bba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100bc0:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80100bc6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  proc->head = 0; 
80100bc9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100bcf:	c7 80 ac 01 00 00 00 	movl   $0x0,0x1ac(%eax)
80100bd6:	00 00 00 
  struct physicalPages *tail = proc->tail;
80100bd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100bdf:	8b 80 b0 01 00 00    	mov    0x1b0(%eax),%eax
80100be5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  proc->tail = 0;
80100be8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100bee:	c7 80 b0 01 00 00 00 	movl   $0x0,0x1b0(%eax)
80100bf5:	00 00 00 
  int pagesInPhMem = proc->pagesInPhMem;
80100bf8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100bfe:	8b 80 b4 01 00 00    	mov    0x1b4(%eax),%eax
80100c04:	89 45 c0             	mov    %eax,-0x40(%ebp)
  proc->pagesInPhMem = 0;
80100c07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c0d:	c7 80 b4 01 00 00 00 	movl   $0x0,0x1b4(%eax)
80100c14:	00 00 00 
  int pagesInDisc = proc->pagesInDisc;
80100c17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c1d:	8b 80 b8 01 00 00    	mov    0x1b8(%eax),%eax
80100c23:	89 45 bc             	mov    %eax,-0x44(%ebp)
  proc->pagesInDisc = 0;
80100c26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c2c:	c7 80 b8 01 00 00 00 	movl   $0x0,0x1b8(%eax)
80100c33:	00 00 00 
  int totalPageFaultCount = proc->totalPageFaultCount;
80100c36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c3c:	8b 80 bc 01 00 00    	mov    0x1bc(%eax),%eax
80100c42:	89 45 b8             	mov    %eax,-0x48(%ebp)
  proc->totalPageFaultCount = 0;
80100c45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c4b:	c7 80 bc 01 00 00 00 	movl   $0x0,0x1bc(%eax)
80100c52:	00 00 00 
  int totalSwappedCount = proc->totalSwappedCount;
80100c55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c5b:	8b 80 c0 01 00 00    	mov    0x1c0(%eax),%eax
80100c61:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  proc->totalSwappedCount = 0;
80100c64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c6a:	c7 80 c0 01 00 00 00 	movl   $0x0,0x1c0(%eax)
80100c71:	00 00 00 

  // iterate arrays , copy the data and reset process
  for(int i = 0 ; i < MAX_PSYC_PAGES ; i++){
80100c74:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
80100c7b:	e9 3c 01 00 00       	jmp    80100dbc <exec+0x24b>
    physical[i].virtualAdress = proc->physical[i].virtualAdress;
80100c80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c86:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100c89:	83 c2 0b             	add    $0xb,%edx
80100c8c:	c1 e2 04             	shl    $0x4,%edx
80100c8f:	01 d0                	add    %edx,%eax
80100c91:	83 c0 0c             	add    $0xc,%eax
80100c94:	8b 00                	mov    (%eax),%eax
80100c96:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100c99:	c1 e2 04             	shl    $0x4,%edx
80100c9c:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100c9f:	01 ca                	add    %ecx,%edx
80100ca1:	81 ea 58 02 00 00    	sub    $0x258,%edx
80100ca7:	89 02                	mov    %eax,(%edx)
    proc->physical[i].virtualAdress = (char*)0xffffffff;
80100ca9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100caf:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100cb2:	83 c2 0b             	add    $0xb,%edx
80100cb5:	c1 e2 04             	shl    $0x4,%edx
80100cb8:	01 d0                	add    %edx,%eax
80100cba:	83 c0 0c             	add    $0xc,%eax
80100cbd:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    physical[i].next = proc->physical[i].next;
80100cc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cc9:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100ccc:	83 c2 0b             	add    $0xb,%edx
80100ccf:	c1 e2 04             	shl    $0x4,%edx
80100cd2:	01 d0                	add    %edx,%eax
80100cd4:	83 c0 14             	add    $0x14,%eax
80100cd7:	8b 00                	mov    (%eax),%eax
80100cd9:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100cdc:	c1 e2 04             	shl    $0x4,%edx
80100cdf:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100ce2:	01 ca                	add    %ecx,%edx
80100ce4:	81 ea 50 02 00 00    	sub    $0x250,%edx
80100cea:	89 02                	mov    %eax,(%edx)
    proc->physical[i].next = 0;
80100cec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cf2:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100cf5:	83 c2 0b             	add    $0xb,%edx
80100cf8:	c1 e2 04             	shl    $0x4,%edx
80100cfb:	01 d0                	add    %edx,%eax
80100cfd:	83 c0 14             	add    $0x14,%eax
80100d00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    physical[i].prev = proc->physical[i].prev;
80100d06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d0c:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100d0f:	83 c2 0b             	add    $0xb,%edx
80100d12:	c1 e2 04             	shl    $0x4,%edx
80100d15:	01 d0                	add    %edx,%eax
80100d17:	83 c0 18             	add    $0x18,%eax
80100d1a:	8b 00                	mov    (%eax),%eax
80100d1c:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100d1f:	c1 e2 04             	shl    $0x4,%edx
80100d22:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100d25:	01 ca                	add    %ecx,%edx
80100d27:	81 ea 4c 02 00 00    	sub    $0x24c,%edx
80100d2d:	89 02                	mov    %eax,(%edx)
    proc->physical[i].prev = 0;
80100d2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d35:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100d38:	83 c2 0b             	add    $0xb,%edx
80100d3b:	c1 e2 04             	shl    $0x4,%edx
80100d3e:	01 d0                	add    %edx,%eax
80100d40:	83 c0 18             	add    $0x18,%eax
80100d43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    physical[i].accessCount = proc->physical[i].accessCount;
80100d49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d4f:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100d52:	83 c2 0b             	add    $0xb,%edx
80100d55:	c1 e2 04             	shl    $0x4,%edx
80100d58:	01 d0                	add    %edx,%eax
80100d5a:	83 c0 10             	add    $0x10,%eax
80100d5d:	8b 00                	mov    (%eax),%eax
80100d5f:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100d62:	c1 e2 04             	shl    $0x4,%edx
80100d65:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100d68:	01 ca                	add    %ecx,%edx
80100d6a:	81 ea 54 02 00 00    	sub    $0x254,%edx
80100d70:	89 02                	mov    %eax,(%edx)
    proc->physical[i].accessCount = 0;
80100d72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d78:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100d7b:	83 c2 0b             	add    $0xb,%edx
80100d7e:	c1 e2 04             	shl    $0x4,%edx
80100d81:	01 d0                	add    %edx,%eax
80100d83:	83 c0 10             	add    $0x10,%eax
80100d86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    disc[i].virtualAdress = proc->disc[i].virtualAdress;
80100d8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d92:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100d95:	83 c2 20             	add    $0x20,%edx
80100d98:	8b 14 90             	mov    (%eax,%edx,4),%edx
80100d9b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d9e:	89 94 85 90 fe ff ff 	mov    %edx,-0x170(%ebp,%eax,4)
    proc->disc[i].virtualAdress = (char*)0xffffffff;
80100da5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100dab:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100dae:	83 c2 20             	add    $0x20,%edx
80100db1:	c7 04 90 ff ff ff ff 	movl   $0xffffffff,(%eax,%edx,4)
  proc->totalPageFaultCount = 0;
  int totalSwappedCount = proc->totalSwappedCount;
  proc->totalSwappedCount = 0;

  // iterate arrays , copy the data and reset process
  for(int i = 0 ; i < MAX_PSYC_PAGES ; i++){
80100db8:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
80100dbc:	83 7d d0 0e          	cmpl   $0xe,-0x30(%ebp)
80100dc0:	0f 8e ba fe ff ff    	jle    80100c80 <exec+0x10f>
  }
  #endif
  // finish

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100dc6:	6a 34                	push   $0x34
80100dc8:	6a 00                	push   $0x0
80100dca:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100dd0:	50                   	push   %eax
80100dd1:	ff 75 d8             	pushl  -0x28(%ebp)
80100dd4:	e8 91 14 00 00       	call   8010226a <readi>
80100dd9:	83 c4 10             	add    $0x10,%esp
80100ddc:	83 f8 33             	cmp    $0x33,%eax
80100ddf:	0f 86 9e 03 00 00    	jbe    80101183 <exec+0x612>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100de5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100deb:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100df0:	0f 85 90 03 00 00    	jne    80101186 <exec+0x615>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100df6:	e8 0f 7d 00 00       	call   80108b0a <setupkvm>
80100dfb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100dfe:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100e02:	0f 84 81 03 00 00    	je     80101189 <exec+0x618>
    goto bad;

  // Load program into memory.
  sz = 0;
80100e08:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e0f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100e16:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100e1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e1f:	e9 ab 00 00 00       	jmp    80100ecf <exec+0x35e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100e24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e27:	6a 20                	push   $0x20
80100e29:	50                   	push   %eax
80100e2a:	8d 85 cc fe ff ff    	lea    -0x134(%ebp),%eax
80100e30:	50                   	push   %eax
80100e31:	ff 75 d8             	pushl  -0x28(%ebp)
80100e34:	e8 31 14 00 00       	call   8010226a <readi>
80100e39:	83 c4 10             	add    $0x10,%esp
80100e3c:	83 f8 20             	cmp    $0x20,%eax
80100e3f:	0f 85 47 03 00 00    	jne    8010118c <exec+0x61b>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100e45:	8b 85 cc fe ff ff    	mov    -0x134(%ebp),%eax
80100e4b:	83 f8 01             	cmp    $0x1,%eax
80100e4e:	75 71                	jne    80100ec1 <exec+0x350>
      continue;
    if(ph.memsz < ph.filesz)
80100e50:	8b 95 e0 fe ff ff    	mov    -0x120(%ebp),%edx
80100e56:	8b 85 dc fe ff ff    	mov    -0x124(%ebp),%eax
80100e5c:	39 c2                	cmp    %eax,%edx
80100e5e:	0f 82 2b 03 00 00    	jb     8010118f <exec+0x61e>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100e64:	8b 95 d4 fe ff ff    	mov    -0x12c(%ebp),%edx
80100e6a:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100e70:	01 d0                	add    %edx,%eax
80100e72:	83 ec 04             	sub    $0x4,%esp
80100e75:	50                   	push   %eax
80100e76:	ff 75 e0             	pushl  -0x20(%ebp)
80100e79:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e7c:	e8 30 80 00 00       	call   80108eb1 <allocuvm>
80100e81:	83 c4 10             	add    $0x10,%esp
80100e84:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e87:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e8b:	0f 84 01 03 00 00    	je     80101192 <exec+0x621>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100e91:	8b 95 dc fe ff ff    	mov    -0x124(%ebp),%edx
80100e97:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
80100e9d:	8b 8d d4 fe ff ff    	mov    -0x12c(%ebp),%ecx
80100ea3:	83 ec 0c             	sub    $0xc,%esp
80100ea6:	52                   	push   %edx
80100ea7:	50                   	push   %eax
80100ea8:	ff 75 d8             	pushl  -0x28(%ebp)
80100eab:	51                   	push   %ecx
80100eac:	ff 75 d4             	pushl  -0x2c(%ebp)
80100eaf:	e8 26 7f 00 00       	call   80108dda <loaduvm>
80100eb4:	83 c4 20             	add    $0x20,%esp
80100eb7:	85 c0                	test   %eax,%eax
80100eb9:	0f 88 d6 02 00 00    	js     80101195 <exec+0x624>
80100ebf:	eb 01                	jmp    80100ec2 <exec+0x351>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100ec1:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ec2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100ec6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ec9:	83 c0 20             	add    $0x20,%eax
80100ecc:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ecf:	0f b7 85 18 ff ff ff 	movzwl -0xe8(%ebp),%eax
80100ed6:	0f b7 c0             	movzwl %ax,%eax
80100ed9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100edc:	0f 8f 42 ff ff ff    	jg     80100e24 <exec+0x2b3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100ee2:	83 ec 0c             	sub    $0xc,%esp
80100ee5:	ff 75 d8             	pushl  -0x28(%ebp)
80100ee8:	e8 cf 10 00 00       	call   80101fbc <iunlockput>
80100eed:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ef0:	e8 da 2e 00 00       	call   80103dcf <end_op>
  ip = 0;
80100ef5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100efc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100eff:	05 ff 0f 00 00       	add    $0xfff,%eax
80100f04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100f09:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f0f:	05 00 20 00 00       	add    $0x2000,%eax
80100f14:	83 ec 04             	sub    $0x4,%esp
80100f17:	50                   	push   %eax
80100f18:	ff 75 e0             	pushl  -0x20(%ebp)
80100f1b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f1e:	e8 8e 7f 00 00       	call   80108eb1 <allocuvm>
80100f23:	83 c4 10             	add    $0x10,%esp
80100f26:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f2d:	0f 84 65 02 00 00    	je     80101198 <exec+0x627>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100f33:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f36:	2d 00 20 00 00       	sub    $0x2000,%eax
80100f3b:	83 ec 08             	sub    $0x8,%esp
80100f3e:	50                   	push   %eax
80100f3f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f42:	e8 66 84 00 00       	call   801093ad <clearpteu>
80100f47:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100f4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f4d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f50:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100f57:	e9 96 00 00 00       	jmp    80100ff2 <exec+0x481>
    if(argc >= MAXARG)
80100f5c:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100f60:	0f 87 35 02 00 00    	ja     8010119b <exec+0x62a>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100f66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f70:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f73:	01 d0                	add    %edx,%eax
80100f75:	8b 00                	mov    (%eax),%eax
80100f77:	83 ec 0c             	sub    $0xc,%esp
80100f7a:	50                   	push   %eax
80100f7b:	e8 97 52 00 00       	call   80106217 <strlen>
80100f80:	83 c4 10             	add    $0x10,%esp
80100f83:	89 c2                	mov    %eax,%edx
80100f85:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f88:	29 d0                	sub    %edx,%eax
80100f8a:	83 e8 01             	sub    $0x1,%eax
80100f8d:	83 e0 fc             	and    $0xfffffffc,%eax
80100f90:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100fa0:	01 d0                	add    %edx,%eax
80100fa2:	8b 00                	mov    (%eax),%eax
80100fa4:	83 ec 0c             	sub    $0xc,%esp
80100fa7:	50                   	push   %eax
80100fa8:	e8 6a 52 00 00       	call   80106217 <strlen>
80100fad:	83 c4 10             	add    $0x10,%esp
80100fb0:	83 c0 01             	add    $0x1,%eax
80100fb3:	89 c1                	mov    %eax,%ecx
80100fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100fc2:	01 d0                	add    %edx,%eax
80100fc4:	8b 00                	mov    (%eax),%eax
80100fc6:	51                   	push   %ecx
80100fc7:	50                   	push   %eax
80100fc8:	ff 75 dc             	pushl  -0x24(%ebp)
80100fcb:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fce:	e8 cf 85 00 00       	call   801095a2 <copyout>
80100fd3:	83 c4 10             	add    $0x10,%esp
80100fd6:	85 c0                	test   %eax,%eax
80100fd8:	0f 88 c0 01 00 00    	js     8010119e <exec+0x62d>
      goto bad;
    ustack[3+argc] = sp;
80100fde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fe1:	8d 50 03             	lea    0x3(%eax),%edx
80100fe4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100fe7:	89 84 95 20 ff ff ff 	mov    %eax,-0xe0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100fee:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ff2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ff5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100fff:	01 d0                	add    %edx,%eax
80101001:	8b 00                	mov    (%eax),%eax
80101003:	85 c0                	test   %eax,%eax
80101005:	0f 85 51 ff ff ff    	jne    80100f5c <exec+0x3eb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
8010100b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010100e:	83 c0 03             	add    $0x3,%eax
80101011:	c7 84 85 20 ff ff ff 	movl   $0x0,-0xe0(%ebp,%eax,4)
80101018:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
8010101c:	c7 85 20 ff ff ff ff 	movl   $0xffffffff,-0xe0(%ebp)
80101023:	ff ff ff 
  ustack[1] = argc;
80101026:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101029:	89 85 24 ff ff ff    	mov    %eax,-0xdc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
8010102f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101032:	83 c0 01             	add    $0x1,%eax
80101035:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010103c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010103f:	29 d0                	sub    %edx,%eax
80101041:	89 85 28 ff ff ff    	mov    %eax,-0xd8(%ebp)

  sp -= (3+argc+1) * 4;
80101047:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010104a:	83 c0 04             	add    $0x4,%eax
8010104d:	c1 e0 02             	shl    $0x2,%eax
80101050:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101056:	83 c0 04             	add    $0x4,%eax
80101059:	c1 e0 02             	shl    $0x2,%eax
8010105c:	50                   	push   %eax
8010105d:	8d 85 20 ff ff ff    	lea    -0xe0(%ebp),%eax
80101063:	50                   	push   %eax
80101064:	ff 75 dc             	pushl  -0x24(%ebp)
80101067:	ff 75 d4             	pushl  -0x2c(%ebp)
8010106a:	e8 33 85 00 00       	call   801095a2 <copyout>
8010106f:	83 c4 10             	add    $0x10,%esp
80101072:	85 c0                	test   %eax,%eax
80101074:	0f 88 27 01 00 00    	js     801011a1 <exec+0x630>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010107a:	8b 45 08             	mov    0x8(%ebp),%eax
8010107d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101083:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101086:	eb 17                	jmp    8010109f <exec+0x52e>
    if(*s == '/')
80101088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010108b:	0f b6 00             	movzbl (%eax),%eax
8010108e:	3c 2f                	cmp    $0x2f,%al
80101090:	75 09                	jne    8010109b <exec+0x52a>
      last = s+1;
80101092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101095:	83 c0 01             	add    $0x1,%eax
80101098:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010109b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010109f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a2:	0f b6 00             	movzbl (%eax),%eax
801010a5:	84 c0                	test   %al,%al
801010a7:	75 df                	jne    80101088 <exec+0x517>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
801010a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010af:	83 c0 6c             	add    $0x6c,%eax
801010b2:	83 ec 04             	sub    $0x4,%esp
801010b5:	6a 10                	push   $0x10
801010b7:	ff 75 f0             	pushl  -0x10(%ebp)
801010ba:	50                   	push   %eax
801010bb:	e8 0d 51 00 00       	call   801061cd <safestrcpy>
801010c0:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801010c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010c9:	8b 40 04             	mov    0x4(%eax),%eax
801010cc:	89 45 b0             	mov    %eax,-0x50(%ebp)
  proc->pgdir = pgdir;
801010cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801010d8:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801010db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801010e4:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801010e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010ec:	8b 40 18             	mov    0x18(%eax),%eax
801010ef:	8b 95 04 ff ff ff    	mov    -0xfc(%ebp),%edx
801010f5:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801010f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010fe:	8b 40 18             	mov    0x18(%eax),%eax
80101101:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101104:	89 50 44             	mov    %edx,0x44(%eax)

  // assignment3 
    removeSwapFile(proc); //delete old disc
80101107:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	50                   	push   %eax
80101111:	e8 9c 18 00 00       	call   801029b2 <removeSwapFile>
80101116:	83 c4 10             	add    $0x10,%esp
    createSwapFile(proc); //create new disc
80101119:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010111f:	83 ec 0c             	sub    $0xc,%esp
80101122:	50                   	push   %eax
80101123:	e8 a3 1a 00 00       	call   80102bcb <createSwapFile>
80101128:	83 c4 10             	add    $0x10,%esp
  //finish

  switchuvm(proc);
8010112b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101131:	83 ec 0c             	sub    $0xc,%esp
80101134:	50                   	push   %eax
80101135:	e8 b7 7a 00 00       	call   80108bf1 <switchuvm>
8010113a:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
8010113d:	83 ec 0c             	sub    $0xc,%esp
80101140:	ff 75 b0             	pushl  -0x50(%ebp)
80101143:	e8 c5 81 00 00       	call   8010930d <freevm>
80101148:	83 c4 10             	add    $0x10,%esp
  cprintf("exec : number of page allocate : %d, with pid: %d and name : %s\n", proc->pagesInPhMem, proc->pid, proc->name);
8010114b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101151:	8d 48 6c             	lea    0x6c(%eax),%ecx
80101154:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010115a:	8b 50 10             	mov    0x10(%eax),%edx
8010115d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101163:	8b 80 b4 01 00 00    	mov    0x1b4(%eax),%eax
80101169:	51                   	push   %ecx
8010116a:	52                   	push   %edx
8010116b:	50                   	push   %eax
8010116c:	68 98 9d 10 80       	push   $0x80109d98
80101171:	e8 50 f2 ff ff       	call   801003c6 <cprintf>
80101176:	83 c4 10             	add    $0x10,%esp
  return 0;
80101179:	b8 00 00 00 00       	mov    $0x0,%eax
8010117e:	e9 82 01 00 00       	jmp    80101305 <exec+0x794>
  #endif
  // finish

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80101183:	90                   	nop
80101184:	eb 1c                	jmp    801011a2 <exec+0x631>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80101186:	90                   	nop
80101187:	eb 19                	jmp    801011a2 <exec+0x631>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80101189:	90                   	nop
8010118a:	eb 16                	jmp    801011a2 <exec+0x631>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
8010118c:	90                   	nop
8010118d:	eb 13                	jmp    801011a2 <exec+0x631>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
8010118f:	90                   	nop
80101190:	eb 10                	jmp    801011a2 <exec+0x631>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101192:	90                   	nop
80101193:	eb 0d                	jmp    801011a2 <exec+0x631>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101195:	90                   	nop
80101196:	eb 0a                	jmp    801011a2 <exec+0x631>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101198:	90                   	nop
80101199:	eb 07                	jmp    801011a2 <exec+0x631>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
8010119b:	90                   	nop
8010119c:	eb 04                	jmp    801011a2 <exec+0x631>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
8010119e:	90                   	nop
8010119f:	eb 01                	jmp    801011a2 <exec+0x631>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
801011a1:	90                   	nop
  freevm(oldpgdir);
  cprintf("exec : number of page allocate : %d, with pid: %d and name : %s\n", proc->pagesInPhMem, proc->pid, proc->name);
  return 0;

 bad:
  if(pgdir)
801011a2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801011a6:	74 0e                	je     801011b6 <exec+0x645>
    freevm(pgdir);
801011a8:	83 ec 0c             	sub    $0xc,%esp
801011ab:	ff 75 d4             	pushl  -0x2c(%ebp)
801011ae:	e8 5a 81 00 00       	call   8010930d <freevm>
801011b3:	83 c4 10             	add    $0x10,%esp
  if(ip){
801011b6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801011ba:	74 13                	je     801011cf <exec+0x65e>
    iunlockput(ip);
801011bc:	83 ec 0c             	sub    $0xc,%esp
801011bf:	ff 75 d8             	pushl  -0x28(%ebp)
801011c2:	e8 f5 0d 00 00       	call   80101fbc <iunlockput>
801011c7:	83 c4 10             	add    $0x10,%esp
    end_op();
801011ca:	e8 00 2c 00 00       	call   80103dcf <end_op>
  }

  // assignment3
  #ifndef NONE
  // set all the fields
  proc->head = head;
801011cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011d5:	8b 55 c8             	mov    -0x38(%ebp),%edx
801011d8:	89 90 ac 01 00 00    	mov    %edx,0x1ac(%eax)
  proc->tail = tail;
801011de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
801011e7:	89 90 b0 01 00 00    	mov    %edx,0x1b0(%eax)
  proc->pagesInPhMem = pagesInPhMem;
801011ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011f3:	8b 55 c0             	mov    -0x40(%ebp),%edx
801011f6:	89 90 b4 01 00 00    	mov    %edx,0x1b4(%eax)
  proc->pagesInDisc = pagesInDisc;
801011fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101202:	8b 55 bc             	mov    -0x44(%ebp),%edx
80101205:	89 90 b8 01 00 00    	mov    %edx,0x1b8(%eax)
  proc->totalPageFaultCount = totalPageFaultCount;
8010120b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101211:	8b 55 b8             	mov    -0x48(%ebp),%edx
80101214:	89 90 bc 01 00 00    	mov    %edx,0x1bc(%eax)
  proc->totalSwappedCount = totalSwappedCount;
8010121a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101220:	8b 55 b4             	mov    -0x4c(%ebp),%edx
80101223:	89 90 c0 01 00 00    	mov    %edx,0x1c0(%eax)

   // iterate arrays , set the new data 
  for(int i = 0 ; i < MAX_PSYC_PAGES ; i++)
80101229:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
80101230:	e9 c1 00 00 00       	jmp    801012f6 <exec+0x785>
  {
    proc->physical[i].virtualAdress = physical[i].virtualAdress;
80101235:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010123c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010123f:	c1 e0 04             	shl    $0x4,%eax
80101242:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80101245:	01 c8                	add    %ecx,%eax
80101247:	2d 58 02 00 00       	sub    $0x258,%eax
8010124c:	8b 00                	mov    (%eax),%eax
8010124e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
80101251:	83 c1 0b             	add    $0xb,%ecx
80101254:	c1 e1 04             	shl    $0x4,%ecx
80101257:	01 ca                	add    %ecx,%edx
80101259:	83 c2 0c             	add    $0xc,%edx
8010125c:	89 02                	mov    %eax,(%edx)
    proc->physical[i].next = physical[i].next;
8010125e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80101265:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101268:	c1 e0 04             	shl    $0x4,%eax
8010126b:	8d 4d f8             	lea    -0x8(%ebp),%ecx
8010126e:	01 c8                	add    %ecx,%eax
80101270:	2d 50 02 00 00       	sub    $0x250,%eax
80101275:	8b 00                	mov    (%eax),%eax
80101277:	8b 4d cc             	mov    -0x34(%ebp),%ecx
8010127a:	83 c1 0b             	add    $0xb,%ecx
8010127d:	c1 e1 04             	shl    $0x4,%ecx
80101280:	01 ca                	add    %ecx,%edx
80101282:	83 c2 14             	add    $0x14,%edx
80101285:	89 02                	mov    %eax,(%edx)
    proc->physical[i].prev = physical[i].prev;
80101287:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010128e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101291:	c1 e0 04             	shl    $0x4,%eax
80101294:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80101297:	01 c8                	add    %ecx,%eax
80101299:	2d 4c 02 00 00       	sub    $0x24c,%eax
8010129e:	8b 00                	mov    (%eax),%eax
801012a0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
801012a3:	83 c1 0b             	add    $0xb,%ecx
801012a6:	c1 e1 04             	shl    $0x4,%ecx
801012a9:	01 ca                	add    %ecx,%edx
801012ab:	83 c2 18             	add    $0x18,%edx
801012ae:	89 02                	mov    %eax,(%edx)
    proc->physical[i].accessCount = physical[i].accessCount;
801012b0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801012b7:	8b 45 cc             	mov    -0x34(%ebp),%eax
801012ba:	c1 e0 04             	shl    $0x4,%eax
801012bd:	8d 4d f8             	lea    -0x8(%ebp),%ecx
801012c0:	01 c8                	add    %ecx,%eax
801012c2:	2d 54 02 00 00       	sub    $0x254,%eax
801012c7:	8b 00                	mov    (%eax),%eax
801012c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
801012cc:	83 c1 0b             	add    $0xb,%ecx
801012cf:	c1 e1 04             	shl    $0x4,%ecx
801012d2:	01 ca                	add    %ecx,%edx
801012d4:	83 c2 10             	add    $0x10,%edx
801012d7:	89 02                	mov    %eax,(%edx)
    proc->disc[i].virtualAdress = disc[i].virtualAdress;
801012d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801012df:	8b 55 cc             	mov    -0x34(%ebp),%edx
801012e2:	8b 94 95 90 fe ff ff 	mov    -0x170(%ebp,%edx,4),%edx
801012e9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
801012ec:	83 c1 20             	add    $0x20,%ecx
801012ef:	89 14 88             	mov    %edx,(%eax,%ecx,4)
  proc->pagesInDisc = pagesInDisc;
  proc->totalPageFaultCount = totalPageFaultCount;
  proc->totalSwappedCount = totalSwappedCount;

   // iterate arrays , set the new data 
  for(int i = 0 ; i < MAX_PSYC_PAGES ; i++)
801012f2:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
801012f6:	83 7d cc 0e          	cmpl   $0xe,-0x34(%ebp)
801012fa:	0f 8e 35 ff ff ff    	jle    80101235 <exec+0x6c4>
    proc->disc[i].virtualAdress = disc[i].virtualAdress;
  }
  #endif
  // finish

  return -1;
80101300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101305:	c9                   	leave  
80101306:	c3                   	ret    

80101307 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101307:	55                   	push   %ebp
80101308:	89 e5                	mov    %esp,%ebp
8010130a:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010130d:	83 ec 08             	sub    $0x8,%esp
80101310:	68 d9 9d 10 80       	push   $0x80109dd9
80101315:	68 20 28 11 80       	push   $0x80112820
8010131a:	e8 26 4a 00 00       	call   80105d45 <initlock>
8010131f:	83 c4 10             	add    $0x10,%esp
}
80101322:	90                   	nop
80101323:	c9                   	leave  
80101324:	c3                   	ret    

80101325 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101325:	55                   	push   %ebp
80101326:	89 e5                	mov    %esp,%ebp
80101328:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010132b:	83 ec 0c             	sub    $0xc,%esp
8010132e:	68 20 28 11 80       	push   $0x80112820
80101333:	e8 2f 4a 00 00       	call   80105d67 <acquire>
80101338:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010133b:	c7 45 f4 54 28 11 80 	movl   $0x80112854,-0xc(%ebp)
80101342:	eb 2d                	jmp    80101371 <filealloc+0x4c>
    if(f->ref == 0){
80101344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101347:	8b 40 04             	mov    0x4(%eax),%eax
8010134a:	85 c0                	test   %eax,%eax
8010134c:	75 1f                	jne    8010136d <filealloc+0x48>
      f->ref = 1;
8010134e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101351:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101358:	83 ec 0c             	sub    $0xc,%esp
8010135b:	68 20 28 11 80       	push   $0x80112820
80101360:	e8 69 4a 00 00       	call   80105dce <release>
80101365:	83 c4 10             	add    $0x10,%esp
      return f;
80101368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136b:	eb 23                	jmp    80101390 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010136d:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101371:	b8 b4 31 11 80       	mov    $0x801131b4,%eax
80101376:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101379:	72 c9                	jb     80101344 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010137b:	83 ec 0c             	sub    $0xc,%esp
8010137e:	68 20 28 11 80       	push   $0x80112820
80101383:	e8 46 4a 00 00       	call   80105dce <release>
80101388:	83 c4 10             	add    $0x10,%esp
  return 0;
8010138b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101390:	c9                   	leave  
80101391:	c3                   	ret    

80101392 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101392:	55                   	push   %ebp
80101393:	89 e5                	mov    %esp,%ebp
80101395:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101398:	83 ec 0c             	sub    $0xc,%esp
8010139b:	68 20 28 11 80       	push   $0x80112820
801013a0:	e8 c2 49 00 00       	call   80105d67 <acquire>
801013a5:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801013a8:	8b 45 08             	mov    0x8(%ebp),%eax
801013ab:	8b 40 04             	mov    0x4(%eax),%eax
801013ae:	85 c0                	test   %eax,%eax
801013b0:	7f 0d                	jg     801013bf <filedup+0x2d>
    panic("filedup");
801013b2:	83 ec 0c             	sub    $0xc,%esp
801013b5:	68 e0 9d 10 80       	push   $0x80109de0
801013ba:	e8 a7 f1 ff ff       	call   80100566 <panic>
  f->ref++;
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	8b 40 04             	mov    0x4(%eax),%eax
801013c5:	8d 50 01             	lea    0x1(%eax),%edx
801013c8:	8b 45 08             	mov    0x8(%ebp),%eax
801013cb:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801013ce:	83 ec 0c             	sub    $0xc,%esp
801013d1:	68 20 28 11 80       	push   $0x80112820
801013d6:	e8 f3 49 00 00       	call   80105dce <release>
801013db:	83 c4 10             	add    $0x10,%esp
  return f;
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
}
801013e1:	c9                   	leave  
801013e2:	c3                   	ret    

801013e3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801013e3:	55                   	push   %ebp
801013e4:	89 e5                	mov    %esp,%ebp
801013e6:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801013e9:	83 ec 0c             	sub    $0xc,%esp
801013ec:	68 20 28 11 80       	push   $0x80112820
801013f1:	e8 71 49 00 00       	call   80105d67 <acquire>
801013f6:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801013f9:	8b 45 08             	mov    0x8(%ebp),%eax
801013fc:	8b 40 04             	mov    0x4(%eax),%eax
801013ff:	85 c0                	test   %eax,%eax
80101401:	7f 0d                	jg     80101410 <fileclose+0x2d>
    panic("fileclose");
80101403:	83 ec 0c             	sub    $0xc,%esp
80101406:	68 e8 9d 10 80       	push   $0x80109de8
8010140b:	e8 56 f1 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101410:	8b 45 08             	mov    0x8(%ebp),%eax
80101413:	8b 40 04             	mov    0x4(%eax),%eax
80101416:	8d 50 ff             	lea    -0x1(%eax),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	89 50 04             	mov    %edx,0x4(%eax)
8010141f:	8b 45 08             	mov    0x8(%ebp),%eax
80101422:	8b 40 04             	mov    0x4(%eax),%eax
80101425:	85 c0                	test   %eax,%eax
80101427:	7e 15                	jle    8010143e <fileclose+0x5b>
    release(&ftable.lock);
80101429:	83 ec 0c             	sub    $0xc,%esp
8010142c:	68 20 28 11 80       	push   $0x80112820
80101431:	e8 98 49 00 00       	call   80105dce <release>
80101436:	83 c4 10             	add    $0x10,%esp
80101439:	e9 8b 00 00 00       	jmp    801014c9 <fileclose+0xe6>
    return;
  }
  ff = *f;
8010143e:	8b 45 08             	mov    0x8(%ebp),%eax
80101441:	8b 10                	mov    (%eax),%edx
80101443:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101446:	8b 50 04             	mov    0x4(%eax),%edx
80101449:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010144c:	8b 50 08             	mov    0x8(%eax),%edx
8010144f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101452:	8b 50 0c             	mov    0xc(%eax),%edx
80101455:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101458:	8b 50 10             	mov    0x10(%eax),%edx
8010145b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010145e:	8b 40 14             	mov    0x14(%eax),%eax
80101461:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101464:	8b 45 08             	mov    0x8(%ebp),%eax
80101467:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010146e:	8b 45 08             	mov    0x8(%ebp),%eax
80101471:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101477:	83 ec 0c             	sub    $0xc,%esp
8010147a:	68 20 28 11 80       	push   $0x80112820
8010147f:	e8 4a 49 00 00       	call   80105dce <release>
80101484:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101487:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010148a:	83 f8 01             	cmp    $0x1,%eax
8010148d:	75 19                	jne    801014a8 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010148f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101493:	0f be d0             	movsbl %al,%edx
80101496:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101499:	83 ec 08             	sub    $0x8,%esp
8010149c:	52                   	push   %edx
8010149d:	50                   	push   %eax
8010149e:	e8 e7 34 00 00       	call   8010498a <pipeclose>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	eb 21                	jmp    801014c9 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801014a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801014ab:	83 f8 02             	cmp    $0x2,%eax
801014ae:	75 19                	jne    801014c9 <fileclose+0xe6>
    begin_op();
801014b0:	e8 8e 28 00 00       	call   80103d43 <begin_op>
    iput(ff.ip);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 ec 0c             	sub    $0xc,%esp
801014bb:	50                   	push   %eax
801014bc:	e8 0b 0a 00 00       	call   80101ecc <iput>
801014c1:	83 c4 10             	add    $0x10,%esp
    end_op();
801014c4:	e8 06 29 00 00       	call   80103dcf <end_op>
  }
}
801014c9:	c9                   	leave  
801014ca:	c3                   	ret    

801014cb <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801014cb:	55                   	push   %ebp
801014cc:	89 e5                	mov    %esp,%ebp
801014ce:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801014d1:	8b 45 08             	mov    0x8(%ebp),%eax
801014d4:	8b 00                	mov    (%eax),%eax
801014d6:	83 f8 02             	cmp    $0x2,%eax
801014d9:	75 40                	jne    8010151b <filestat+0x50>
    ilock(f->ip);
801014db:	8b 45 08             	mov    0x8(%ebp),%eax
801014de:	8b 40 10             	mov    0x10(%eax),%eax
801014e1:	83 ec 0c             	sub    $0xc,%esp
801014e4:	50                   	push   %eax
801014e5:	e8 12 08 00 00       	call   80101cfc <ilock>
801014ea:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801014ed:	8b 45 08             	mov    0x8(%ebp),%eax
801014f0:	8b 40 10             	mov    0x10(%eax),%eax
801014f3:	83 ec 08             	sub    $0x8,%esp
801014f6:	ff 75 0c             	pushl  0xc(%ebp)
801014f9:	50                   	push   %eax
801014fa:	e8 25 0d 00 00       	call   80102224 <stati>
801014ff:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101502:	8b 45 08             	mov    0x8(%ebp),%eax
80101505:	8b 40 10             	mov    0x10(%eax),%eax
80101508:	83 ec 0c             	sub    $0xc,%esp
8010150b:	50                   	push   %eax
8010150c:	e8 49 09 00 00       	call   80101e5a <iunlock>
80101511:	83 c4 10             	add    $0x10,%esp
    return 0;
80101514:	b8 00 00 00 00       	mov    $0x0,%eax
80101519:	eb 05                	jmp    80101520 <filestat+0x55>
  }
  return -1;
8010151b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101520:	c9                   	leave  
80101521:	c3                   	ret    

80101522 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101522:	55                   	push   %ebp
80101523:	89 e5                	mov    %esp,%ebp
80101525:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101528:	8b 45 08             	mov    0x8(%ebp),%eax
8010152b:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010152f:	84 c0                	test   %al,%al
80101531:	75 0a                	jne    8010153d <fileread+0x1b>
    return -1;
80101533:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101538:	e9 9b 00 00 00       	jmp    801015d8 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010153d:	8b 45 08             	mov    0x8(%ebp),%eax
80101540:	8b 00                	mov    (%eax),%eax
80101542:	83 f8 01             	cmp    $0x1,%eax
80101545:	75 1a                	jne    80101561 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101547:	8b 45 08             	mov    0x8(%ebp),%eax
8010154a:	8b 40 0c             	mov    0xc(%eax),%eax
8010154d:	83 ec 04             	sub    $0x4,%esp
80101550:	ff 75 10             	pushl  0x10(%ebp)
80101553:	ff 75 0c             	pushl  0xc(%ebp)
80101556:	50                   	push   %eax
80101557:	e8 d6 35 00 00       	call   80104b32 <piperead>
8010155c:	83 c4 10             	add    $0x10,%esp
8010155f:	eb 77                	jmp    801015d8 <fileread+0xb6>
  if(f->type == FD_INODE){
80101561:	8b 45 08             	mov    0x8(%ebp),%eax
80101564:	8b 00                	mov    (%eax),%eax
80101566:	83 f8 02             	cmp    $0x2,%eax
80101569:	75 60                	jne    801015cb <fileread+0xa9>
    ilock(f->ip);
8010156b:	8b 45 08             	mov    0x8(%ebp),%eax
8010156e:	8b 40 10             	mov    0x10(%eax),%eax
80101571:	83 ec 0c             	sub    $0xc,%esp
80101574:	50                   	push   %eax
80101575:	e8 82 07 00 00       	call   80101cfc <ilock>
8010157a:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010157d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101580:	8b 45 08             	mov    0x8(%ebp),%eax
80101583:	8b 50 14             	mov    0x14(%eax),%edx
80101586:	8b 45 08             	mov    0x8(%ebp),%eax
80101589:	8b 40 10             	mov    0x10(%eax),%eax
8010158c:	51                   	push   %ecx
8010158d:	52                   	push   %edx
8010158e:	ff 75 0c             	pushl  0xc(%ebp)
80101591:	50                   	push   %eax
80101592:	e8 d3 0c 00 00       	call   8010226a <readi>
80101597:	83 c4 10             	add    $0x10,%esp
8010159a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010159d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801015a1:	7e 11                	jle    801015b4 <fileread+0x92>
      f->off += r;
801015a3:	8b 45 08             	mov    0x8(%ebp),%eax
801015a6:	8b 50 14             	mov    0x14(%eax),%edx
801015a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ac:	01 c2                	add    %eax,%edx
801015ae:	8b 45 08             	mov    0x8(%ebp),%eax
801015b1:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801015b4:	8b 45 08             	mov    0x8(%ebp),%eax
801015b7:	8b 40 10             	mov    0x10(%eax),%eax
801015ba:	83 ec 0c             	sub    $0xc,%esp
801015bd:	50                   	push   %eax
801015be:	e8 97 08 00 00       	call   80101e5a <iunlock>
801015c3:	83 c4 10             	add    $0x10,%esp
    return r;
801015c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c9:	eb 0d                	jmp    801015d8 <fileread+0xb6>
  }
  panic("fileread");
801015cb:	83 ec 0c             	sub    $0xc,%esp
801015ce:	68 f2 9d 10 80       	push   $0x80109df2
801015d3:	e8 8e ef ff ff       	call   80100566 <panic>
}
801015d8:	c9                   	leave  
801015d9:	c3                   	ret    

801015da <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801015da:	55                   	push   %ebp
801015db:	89 e5                	mov    %esp,%ebp
801015dd:	53                   	push   %ebx
801015de:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801015e1:	8b 45 08             	mov    0x8(%ebp),%eax
801015e4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801015e8:	84 c0                	test   %al,%al
801015ea:	75 0a                	jne    801015f6 <filewrite+0x1c>
    return -1;
801015ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801015f1:	e9 1b 01 00 00       	jmp    80101711 <filewrite+0x137>
  if(f->type == FD_PIPE)
801015f6:	8b 45 08             	mov    0x8(%ebp),%eax
801015f9:	8b 00                	mov    (%eax),%eax
801015fb:	83 f8 01             	cmp    $0x1,%eax
801015fe:	75 1d                	jne    8010161d <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101600:	8b 45 08             	mov    0x8(%ebp),%eax
80101603:	8b 40 0c             	mov    0xc(%eax),%eax
80101606:	83 ec 04             	sub    $0x4,%esp
80101609:	ff 75 10             	pushl  0x10(%ebp)
8010160c:	ff 75 0c             	pushl  0xc(%ebp)
8010160f:	50                   	push   %eax
80101610:	e8 1f 34 00 00       	call   80104a34 <pipewrite>
80101615:	83 c4 10             	add    $0x10,%esp
80101618:	e9 f4 00 00 00       	jmp    80101711 <filewrite+0x137>
  if(f->type == FD_INODE){
8010161d:	8b 45 08             	mov    0x8(%ebp),%eax
80101620:	8b 00                	mov    (%eax),%eax
80101622:	83 f8 02             	cmp    $0x2,%eax
80101625:	0f 85 d9 00 00 00    	jne    80101704 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010162b:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101632:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101639:	e9 a3 00 00 00       	jmp    801016e1 <filewrite+0x107>
      int n1 = n - i;
8010163e:	8b 45 10             	mov    0x10(%ebp),%eax
80101641:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101644:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101647:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010164d:	7e 06                	jle    80101655 <filewrite+0x7b>
        n1 = max;
8010164f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101652:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101655:	e8 e9 26 00 00       	call   80103d43 <begin_op>
      ilock(f->ip);
8010165a:	8b 45 08             	mov    0x8(%ebp),%eax
8010165d:	8b 40 10             	mov    0x10(%eax),%eax
80101660:	83 ec 0c             	sub    $0xc,%esp
80101663:	50                   	push   %eax
80101664:	e8 93 06 00 00       	call   80101cfc <ilock>
80101669:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010166c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010166f:	8b 45 08             	mov    0x8(%ebp),%eax
80101672:	8b 50 14             	mov    0x14(%eax),%edx
80101675:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101678:	8b 45 0c             	mov    0xc(%ebp),%eax
8010167b:	01 c3                	add    %eax,%ebx
8010167d:	8b 45 08             	mov    0x8(%ebp),%eax
80101680:	8b 40 10             	mov    0x10(%eax),%eax
80101683:	51                   	push   %ecx
80101684:	52                   	push   %edx
80101685:	53                   	push   %ebx
80101686:	50                   	push   %eax
80101687:	e8 35 0d 00 00       	call   801023c1 <writei>
8010168c:	83 c4 10             	add    $0x10,%esp
8010168f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101692:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101696:	7e 11                	jle    801016a9 <filewrite+0xcf>
        f->off += r;
80101698:	8b 45 08             	mov    0x8(%ebp),%eax
8010169b:	8b 50 14             	mov    0x14(%eax),%edx
8010169e:	8b 45 e8             	mov    -0x18(%ebp),%eax
801016a1:	01 c2                	add    %eax,%edx
801016a3:	8b 45 08             	mov    0x8(%ebp),%eax
801016a6:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801016a9:	8b 45 08             	mov    0x8(%ebp),%eax
801016ac:	8b 40 10             	mov    0x10(%eax),%eax
801016af:	83 ec 0c             	sub    $0xc,%esp
801016b2:	50                   	push   %eax
801016b3:	e8 a2 07 00 00       	call   80101e5a <iunlock>
801016b8:	83 c4 10             	add    $0x10,%esp
      end_op();
801016bb:	e8 0f 27 00 00       	call   80103dcf <end_op>

      if(r < 0)
801016c0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801016c4:	78 29                	js     801016ef <filewrite+0x115>
        break;
      if(r != n1)
801016c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801016c9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801016cc:	74 0d                	je     801016db <filewrite+0x101>
        panic("short filewrite");
801016ce:	83 ec 0c             	sub    $0xc,%esp
801016d1:	68 fb 9d 10 80       	push   $0x80109dfb
801016d6:	e8 8b ee ff ff       	call   80100566 <panic>
      i += r;
801016db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801016de:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801016e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e4:	3b 45 10             	cmp    0x10(%ebp),%eax
801016e7:	0f 8c 51 ff ff ff    	jl     8010163e <filewrite+0x64>
801016ed:	eb 01                	jmp    801016f0 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801016ef:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801016f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f3:	3b 45 10             	cmp    0x10(%ebp),%eax
801016f6:	75 05                	jne    801016fd <filewrite+0x123>
801016f8:	8b 45 10             	mov    0x10(%ebp),%eax
801016fb:	eb 14                	jmp    80101711 <filewrite+0x137>
801016fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101702:	eb 0d                	jmp    80101711 <filewrite+0x137>
  }
  panic("filewrite");
80101704:	83 ec 0c             	sub    $0xc,%esp
80101707:	68 0b 9e 10 80       	push   $0x80109e0b
8010170c:	e8 55 ee ff ff       	call   80100566 <panic>
}
80101711:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101714:	c9                   	leave  
80101715:	c3                   	ret    

80101716 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101716:	55                   	push   %ebp
80101717:	89 e5                	mov    %esp,%ebp
80101719:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010171c:	8b 45 08             	mov    0x8(%ebp),%eax
8010171f:	83 ec 08             	sub    $0x8,%esp
80101722:	6a 01                	push   $0x1
80101724:	50                   	push   %eax
80101725:	e8 8c ea ff ff       	call   801001b6 <bread>
8010172a:	83 c4 10             	add    $0x10,%esp
8010172d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101733:	83 c0 18             	add    $0x18,%eax
80101736:	83 ec 04             	sub    $0x4,%esp
80101739:	6a 1c                	push   $0x1c
8010173b:	50                   	push   %eax
8010173c:	ff 75 0c             	pushl  0xc(%ebp)
8010173f:	e8 45 49 00 00       	call   80106089 <memmove>
80101744:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101747:	83 ec 0c             	sub    $0xc,%esp
8010174a:	ff 75 f4             	pushl  -0xc(%ebp)
8010174d:	e8 dc ea ff ff       	call   8010022e <brelse>
80101752:	83 c4 10             	add    $0x10,%esp
}
80101755:	90                   	nop
80101756:	c9                   	leave  
80101757:	c3                   	ret    

80101758 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101758:	55                   	push   %ebp
80101759:	89 e5                	mov    %esp,%ebp
8010175b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010175e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101761:	8b 45 08             	mov    0x8(%ebp),%eax
80101764:	83 ec 08             	sub    $0x8,%esp
80101767:	52                   	push   %edx
80101768:	50                   	push   %eax
80101769:	e8 48 ea ff ff       	call   801001b6 <bread>
8010176e:	83 c4 10             	add    $0x10,%esp
80101771:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101777:	83 c0 18             	add    $0x18,%eax
8010177a:	83 ec 04             	sub    $0x4,%esp
8010177d:	68 00 02 00 00       	push   $0x200
80101782:	6a 00                	push   $0x0
80101784:	50                   	push   %eax
80101785:	e8 40 48 00 00       	call   80105fca <memset>
8010178a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010178d:	83 ec 0c             	sub    $0xc,%esp
80101790:	ff 75 f4             	pushl  -0xc(%ebp)
80101793:	e8 e3 27 00 00       	call   80103f7b <log_write>
80101798:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010179b:	83 ec 0c             	sub    $0xc,%esp
8010179e:	ff 75 f4             	pushl  -0xc(%ebp)
801017a1:	e8 88 ea ff ff       	call   8010022e <brelse>
801017a6:	83 c4 10             	add    $0x10,%esp
}
801017a9:	90                   	nop
801017aa:	c9                   	leave  
801017ab:	c3                   	ret    

801017ac <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801017ac:	55                   	push   %ebp
801017ad:	89 e5                	mov    %esp,%ebp
801017af:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801017b2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801017b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801017c0:	e9 13 01 00 00       	jmp    801018d8 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
801017c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c8:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801017ce:	85 c0                	test   %eax,%eax
801017d0:	0f 48 c2             	cmovs  %edx,%eax
801017d3:	c1 f8 0c             	sar    $0xc,%eax
801017d6:	89 c2                	mov    %eax,%edx
801017d8:	a1 38 32 11 80       	mov    0x80113238,%eax
801017dd:	01 d0                	add    %edx,%eax
801017df:	83 ec 08             	sub    $0x8,%esp
801017e2:	50                   	push   %eax
801017e3:	ff 75 08             	pushl  0x8(%ebp)
801017e6:	e8 cb e9 ff ff       	call   801001b6 <bread>
801017eb:	83 c4 10             	add    $0x10,%esp
801017ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801017f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801017f8:	e9 a6 00 00 00       	jmp    801018a3 <balloc+0xf7>
      m = 1 << (bi % 8);
801017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101800:	99                   	cltd   
80101801:	c1 ea 1d             	shr    $0x1d,%edx
80101804:	01 d0                	add    %edx,%eax
80101806:	83 e0 07             	and    $0x7,%eax
80101809:	29 d0                	sub    %edx,%eax
8010180b:	ba 01 00 00 00       	mov    $0x1,%edx
80101810:	89 c1                	mov    %eax,%ecx
80101812:	d3 e2                	shl    %cl,%edx
80101814:	89 d0                	mov    %edx,%eax
80101816:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101819:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010181c:	8d 50 07             	lea    0x7(%eax),%edx
8010181f:	85 c0                	test   %eax,%eax
80101821:	0f 48 c2             	cmovs  %edx,%eax
80101824:	c1 f8 03             	sar    $0x3,%eax
80101827:	89 c2                	mov    %eax,%edx
80101829:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010182c:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101831:	0f b6 c0             	movzbl %al,%eax
80101834:	23 45 e8             	and    -0x18(%ebp),%eax
80101837:	85 c0                	test   %eax,%eax
80101839:	75 64                	jne    8010189f <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
8010183b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010183e:	8d 50 07             	lea    0x7(%eax),%edx
80101841:	85 c0                	test   %eax,%eax
80101843:	0f 48 c2             	cmovs  %edx,%eax
80101846:	c1 f8 03             	sar    $0x3,%eax
80101849:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010184c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101851:	89 d1                	mov    %edx,%ecx
80101853:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101856:	09 ca                	or     %ecx,%edx
80101858:	89 d1                	mov    %edx,%ecx
8010185a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010185d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101861:	83 ec 0c             	sub    $0xc,%esp
80101864:	ff 75 ec             	pushl  -0x14(%ebp)
80101867:	e8 0f 27 00 00       	call   80103f7b <log_write>
8010186c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010186f:	83 ec 0c             	sub    $0xc,%esp
80101872:	ff 75 ec             	pushl  -0x14(%ebp)
80101875:	e8 b4 e9 ff ff       	call   8010022e <brelse>
8010187a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010187d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101880:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101883:	01 c2                	add    %eax,%edx
80101885:	8b 45 08             	mov    0x8(%ebp),%eax
80101888:	83 ec 08             	sub    $0x8,%esp
8010188b:	52                   	push   %edx
8010188c:	50                   	push   %eax
8010188d:	e8 c6 fe ff ff       	call   80101758 <bzero>
80101892:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101895:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189b:	01 d0                	add    %edx,%eax
8010189d:	eb 57                	jmp    801018f6 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010189f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801018a3:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801018aa:	7f 17                	jg     801018c3 <balloc+0x117>
801018ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b2:	01 d0                	add    %edx,%eax
801018b4:	89 c2                	mov    %eax,%edx
801018b6:	a1 20 32 11 80       	mov    0x80113220,%eax
801018bb:	39 c2                	cmp    %eax,%edx
801018bd:	0f 82 3a ff ff ff    	jb     801017fd <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801018c3:	83 ec 0c             	sub    $0xc,%esp
801018c6:	ff 75 ec             	pushl  -0x14(%ebp)
801018c9:	e8 60 e9 ff ff       	call   8010022e <brelse>
801018ce:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801018d1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801018d8:	8b 15 20 32 11 80    	mov    0x80113220,%edx
801018de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e1:	39 c2                	cmp    %eax,%edx
801018e3:	0f 87 dc fe ff ff    	ja     801017c5 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801018e9:	83 ec 0c             	sub    $0xc,%esp
801018ec:	68 18 9e 10 80       	push   $0x80109e18
801018f1:	e8 70 ec ff ff       	call   80100566 <panic>
}
801018f6:	c9                   	leave  
801018f7:	c3                   	ret    

801018f8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801018f8:	55                   	push   %ebp
801018f9:	89 e5                	mov    %esp,%ebp
801018fb:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801018fe:	83 ec 08             	sub    $0x8,%esp
80101901:	68 20 32 11 80       	push   $0x80113220
80101906:	ff 75 08             	pushl  0x8(%ebp)
80101909:	e8 08 fe ff ff       	call   80101716 <readsb>
8010190e:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101911:	8b 45 0c             	mov    0xc(%ebp),%eax
80101914:	c1 e8 0c             	shr    $0xc,%eax
80101917:	89 c2                	mov    %eax,%edx
80101919:	a1 38 32 11 80       	mov    0x80113238,%eax
8010191e:	01 c2                	add    %eax,%edx
80101920:	8b 45 08             	mov    0x8(%ebp),%eax
80101923:	83 ec 08             	sub    $0x8,%esp
80101926:	52                   	push   %edx
80101927:	50                   	push   %eax
80101928:	e8 89 e8 ff ff       	call   801001b6 <bread>
8010192d:	83 c4 10             	add    $0x10,%esp
80101930:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101933:	8b 45 0c             	mov    0xc(%ebp),%eax
80101936:	25 ff 0f 00 00       	and    $0xfff,%eax
8010193b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101941:	99                   	cltd   
80101942:	c1 ea 1d             	shr    $0x1d,%edx
80101945:	01 d0                	add    %edx,%eax
80101947:	83 e0 07             	and    $0x7,%eax
8010194a:	29 d0                	sub    %edx,%eax
8010194c:	ba 01 00 00 00       	mov    $0x1,%edx
80101951:	89 c1                	mov    %eax,%ecx
80101953:	d3 e2                	shl    %cl,%edx
80101955:	89 d0                	mov    %edx,%eax
80101957:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010195a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195d:	8d 50 07             	lea    0x7(%eax),%edx
80101960:	85 c0                	test   %eax,%eax
80101962:	0f 48 c2             	cmovs  %edx,%eax
80101965:	c1 f8 03             	sar    $0x3,%eax
80101968:	89 c2                	mov    %eax,%edx
8010196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196d:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101972:	0f b6 c0             	movzbl %al,%eax
80101975:	23 45 ec             	and    -0x14(%ebp),%eax
80101978:	85 c0                	test   %eax,%eax
8010197a:	75 0d                	jne    80101989 <bfree+0x91>
    panic("freeing free block");
8010197c:	83 ec 0c             	sub    $0xc,%esp
8010197f:	68 2e 9e 10 80       	push   $0x80109e2e
80101984:	e8 dd eb ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
80101989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198c:	8d 50 07             	lea    0x7(%eax),%edx
8010198f:	85 c0                	test   %eax,%eax
80101991:	0f 48 c2             	cmovs  %edx,%eax
80101994:	c1 f8 03             	sar    $0x3,%eax
80101997:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010199a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010199f:	89 d1                	mov    %edx,%ecx
801019a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801019a4:	f7 d2                	not    %edx
801019a6:	21 ca                	and    %ecx,%edx
801019a8:	89 d1                	mov    %edx,%ecx
801019aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019ad:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801019b1:	83 ec 0c             	sub    $0xc,%esp
801019b4:	ff 75 f4             	pushl  -0xc(%ebp)
801019b7:	e8 bf 25 00 00       	call   80103f7b <log_write>
801019bc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019bf:	83 ec 0c             	sub    $0xc,%esp
801019c2:	ff 75 f4             	pushl  -0xc(%ebp)
801019c5:	e8 64 e8 ff ff       	call   8010022e <brelse>
801019ca:	83 c4 10             	add    $0x10,%esp
}
801019cd:	90                   	nop
801019ce:	c9                   	leave  
801019cf:	c3                   	ret    

801019d0 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801019d0:	55                   	push   %ebp
801019d1:	89 e5                	mov    %esp,%ebp
801019d3:	57                   	push   %edi
801019d4:	56                   	push   %esi
801019d5:	53                   	push   %ebx
801019d6:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
801019d9:	83 ec 08             	sub    $0x8,%esp
801019dc:	68 41 9e 10 80       	push   $0x80109e41
801019e1:	68 40 32 11 80       	push   $0x80113240
801019e6:	e8 5a 43 00 00       	call   80105d45 <initlock>
801019eb:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801019ee:	83 ec 08             	sub    $0x8,%esp
801019f1:	68 20 32 11 80       	push   $0x80113220
801019f6:	ff 75 08             	pushl  0x8(%ebp)
801019f9:	e8 18 fd ff ff       	call   80101716 <readsb>
801019fe:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101a01:	a1 38 32 11 80       	mov    0x80113238,%eax
80101a06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101a09:	8b 3d 34 32 11 80    	mov    0x80113234,%edi
80101a0f:	8b 35 30 32 11 80    	mov    0x80113230,%esi
80101a15:	8b 1d 2c 32 11 80    	mov    0x8011322c,%ebx
80101a1b:	8b 0d 28 32 11 80    	mov    0x80113228,%ecx
80101a21:	8b 15 24 32 11 80    	mov    0x80113224,%edx
80101a27:	a1 20 32 11 80       	mov    0x80113220,%eax
80101a2c:	ff 75 e4             	pushl  -0x1c(%ebp)
80101a2f:	57                   	push   %edi
80101a30:	56                   	push   %esi
80101a31:	53                   	push   %ebx
80101a32:	51                   	push   %ecx
80101a33:	52                   	push   %edx
80101a34:	50                   	push   %eax
80101a35:	68 48 9e 10 80       	push   $0x80109e48
80101a3a:	e8 87 e9 ff ff       	call   801003c6 <cprintf>
80101a3f:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101a42:	90                   	nop
80101a43:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a46:	5b                   	pop    %ebx
80101a47:	5e                   	pop    %esi
80101a48:	5f                   	pop    %edi
80101a49:	5d                   	pop    %ebp
80101a4a:	c3                   	ret    

80101a4b <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101a4b:	55                   	push   %ebp
80101a4c:	89 e5                	mov    %esp,%ebp
80101a4e:	83 ec 28             	sub    $0x28,%esp
80101a51:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a54:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101a58:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101a5f:	e9 9e 00 00 00       	jmp    80101b02 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a67:	c1 e8 03             	shr    $0x3,%eax
80101a6a:	89 c2                	mov    %eax,%edx
80101a6c:	a1 34 32 11 80       	mov    0x80113234,%eax
80101a71:	01 d0                	add    %edx,%eax
80101a73:	83 ec 08             	sub    $0x8,%esp
80101a76:	50                   	push   %eax
80101a77:	ff 75 08             	pushl  0x8(%ebp)
80101a7a:	e8 37 e7 ff ff       	call   801001b6 <bread>
80101a7f:	83 c4 10             	add    $0x10,%esp
80101a82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a88:	8d 50 18             	lea    0x18(%eax),%edx
80101a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8e:	83 e0 07             	and    $0x7,%eax
80101a91:	c1 e0 06             	shl    $0x6,%eax
80101a94:	01 d0                	add    %edx,%eax
80101a96:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101a99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a9c:	0f b7 00             	movzwl (%eax),%eax
80101a9f:	66 85 c0             	test   %ax,%ax
80101aa2:	75 4c                	jne    80101af0 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101aa4:	83 ec 04             	sub    $0x4,%esp
80101aa7:	6a 40                	push   $0x40
80101aa9:	6a 00                	push   $0x0
80101aab:	ff 75 ec             	pushl  -0x14(%ebp)
80101aae:	e8 17 45 00 00       	call   80105fca <memset>
80101ab3:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101ab6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ab9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101abd:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101ac0:	83 ec 0c             	sub    $0xc,%esp
80101ac3:	ff 75 f0             	pushl  -0x10(%ebp)
80101ac6:	e8 b0 24 00 00       	call   80103f7b <log_write>
80101acb:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101ace:	83 ec 0c             	sub    $0xc,%esp
80101ad1:	ff 75 f0             	pushl  -0x10(%ebp)
80101ad4:	e8 55 e7 ff ff       	call   8010022e <brelse>
80101ad9:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101adf:	83 ec 08             	sub    $0x8,%esp
80101ae2:	50                   	push   %eax
80101ae3:	ff 75 08             	pushl  0x8(%ebp)
80101ae6:	e8 f8 00 00 00       	call   80101be3 <iget>
80101aeb:	83 c4 10             	add    $0x10,%esp
80101aee:	eb 30                	jmp    80101b20 <ialloc+0xd5>
    }
    brelse(bp);
80101af0:	83 ec 0c             	sub    $0xc,%esp
80101af3:	ff 75 f0             	pushl  -0x10(%ebp)
80101af6:	e8 33 e7 ff ff       	call   8010022e <brelse>
80101afb:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101afe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101b02:	8b 15 28 32 11 80    	mov    0x80113228,%edx
80101b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b0b:	39 c2                	cmp    %eax,%edx
80101b0d:	0f 87 51 ff ff ff    	ja     80101a64 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101b13:	83 ec 0c             	sub    $0xc,%esp
80101b16:	68 9b 9e 10 80       	push   $0x80109e9b
80101b1b:	e8 46 ea ff ff       	call   80100566 <panic>
}
80101b20:	c9                   	leave  
80101b21:	c3                   	ret    

80101b22 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101b22:	55                   	push   %ebp
80101b23:	89 e5                	mov    %esp,%ebp
80101b25:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b28:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2b:	8b 40 04             	mov    0x4(%eax),%eax
80101b2e:	c1 e8 03             	shr    $0x3,%eax
80101b31:	89 c2                	mov    %eax,%edx
80101b33:	a1 34 32 11 80       	mov    0x80113234,%eax
80101b38:	01 c2                	add    %eax,%edx
80101b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3d:	8b 00                	mov    (%eax),%eax
80101b3f:	83 ec 08             	sub    $0x8,%esp
80101b42:	52                   	push   %edx
80101b43:	50                   	push   %eax
80101b44:	e8 6d e6 ff ff       	call   801001b6 <bread>
80101b49:	83 c4 10             	add    $0x10,%esp
80101b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b52:	8d 50 18             	lea    0x18(%eax),%edx
80101b55:	8b 45 08             	mov    0x8(%ebp),%eax
80101b58:	8b 40 04             	mov    0x4(%eax),%eax
80101b5b:	83 e0 07             	and    $0x7,%eax
80101b5e:	c1 e0 06             	shl    $0x6,%eax
80101b61:	01 d0                	add    %edx,%eax
80101b63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101b66:	8b 45 08             	mov    0x8(%ebp),%eax
80101b69:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b70:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101b73:	8b 45 08             	mov    0x8(%ebp),%eax
80101b76:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b7d:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b8b:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101b96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b99:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba0:	8b 50 18             	mov    0x18(%eax),%edx
80101ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba6:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	8d 50 1c             	lea    0x1c(%eax),%edx
80101baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb2:	83 c0 0c             	add    $0xc,%eax
80101bb5:	83 ec 04             	sub    $0x4,%esp
80101bb8:	6a 34                	push   $0x34
80101bba:	52                   	push   %edx
80101bbb:	50                   	push   %eax
80101bbc:	e8 c8 44 00 00       	call   80106089 <memmove>
80101bc1:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101bc4:	83 ec 0c             	sub    $0xc,%esp
80101bc7:	ff 75 f4             	pushl  -0xc(%ebp)
80101bca:	e8 ac 23 00 00       	call   80103f7b <log_write>
80101bcf:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101bd2:	83 ec 0c             	sub    $0xc,%esp
80101bd5:	ff 75 f4             	pushl  -0xc(%ebp)
80101bd8:	e8 51 e6 ff ff       	call   8010022e <brelse>
80101bdd:	83 c4 10             	add    $0x10,%esp
}
80101be0:	90                   	nop
80101be1:	c9                   	leave  
80101be2:	c3                   	ret    

80101be3 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101be3:	55                   	push   %ebp
80101be4:	89 e5                	mov    %esp,%ebp
80101be6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 40 32 11 80       	push   $0x80113240
80101bf1:	e8 71 41 00 00       	call   80105d67 <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101bf9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101c00:	c7 45 f4 74 32 11 80 	movl   $0x80113274,-0xc(%ebp)
80101c07:	eb 5d                	jmp    80101c66 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c0c:	8b 40 08             	mov    0x8(%eax),%eax
80101c0f:	85 c0                	test   %eax,%eax
80101c11:	7e 39                	jle    80101c4c <iget+0x69>
80101c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c16:	8b 00                	mov    (%eax),%eax
80101c18:	3b 45 08             	cmp    0x8(%ebp),%eax
80101c1b:	75 2f                	jne    80101c4c <iget+0x69>
80101c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c20:	8b 40 04             	mov    0x4(%eax),%eax
80101c23:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101c26:	75 24                	jne    80101c4c <iget+0x69>
      ip->ref++;
80101c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c2b:	8b 40 08             	mov    0x8(%eax),%eax
80101c2e:	8d 50 01             	lea    0x1(%eax),%edx
80101c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c34:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101c37:	83 ec 0c             	sub    $0xc,%esp
80101c3a:	68 40 32 11 80       	push   $0x80113240
80101c3f:	e8 8a 41 00 00       	call   80105dce <release>
80101c44:	83 c4 10             	add    $0x10,%esp
      return ip;
80101c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c4a:	eb 74                	jmp    80101cc0 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101c4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101c50:	75 10                	jne    80101c62 <iget+0x7f>
80101c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c55:	8b 40 08             	mov    0x8(%eax),%eax
80101c58:	85 c0                	test   %eax,%eax
80101c5a:	75 06                	jne    80101c62 <iget+0x7f>
      empty = ip;
80101c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101c62:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101c66:	81 7d f4 14 42 11 80 	cmpl   $0x80114214,-0xc(%ebp)
80101c6d:	72 9a                	jb     80101c09 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101c6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101c73:	75 0d                	jne    80101c82 <iget+0x9f>
    panic("iget: no inodes");
80101c75:	83 ec 0c             	sub    $0xc,%esp
80101c78:	68 ad 9e 10 80       	push   $0x80109ead
80101c7d:	e8 e4 e8 ff ff       	call   80100566 <panic>

  ip = empty;
80101c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c8b:	8b 55 08             	mov    0x8(%ebp),%edx
80101c8e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c93:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c96:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c9c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ca6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101cad:	83 ec 0c             	sub    $0xc,%esp
80101cb0:	68 40 32 11 80       	push   $0x80113240
80101cb5:	e8 14 41 00 00       	call   80105dce <release>
80101cba:	83 c4 10             	add    $0x10,%esp

  return ip;
80101cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101cc0:	c9                   	leave  
80101cc1:	c3                   	ret    

80101cc2 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101cc2:	55                   	push   %ebp
80101cc3:	89 e5                	mov    %esp,%ebp
80101cc5:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101cc8:	83 ec 0c             	sub    $0xc,%esp
80101ccb:	68 40 32 11 80       	push   $0x80113240
80101cd0:	e8 92 40 00 00       	call   80105d67 <acquire>
80101cd5:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	8b 40 08             	mov    0x8(%eax),%eax
80101cde:	8d 50 01             	lea    0x1(%eax),%edx
80101ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce4:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ce7:	83 ec 0c             	sub    $0xc,%esp
80101cea:	68 40 32 11 80       	push   $0x80113240
80101cef:	e8 da 40 00 00       	call   80105dce <release>
80101cf4:	83 c4 10             	add    $0x10,%esp
  return ip;
80101cf7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101cfa:	c9                   	leave  
80101cfb:	c3                   	ret    

80101cfc <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101cfc:	55                   	push   %ebp
80101cfd:	89 e5                	mov    %esp,%ebp
80101cff:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101d02:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101d06:	74 0a                	je     80101d12 <ilock+0x16>
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 40 08             	mov    0x8(%eax),%eax
80101d0e:	85 c0                	test   %eax,%eax
80101d10:	7f 0d                	jg     80101d1f <ilock+0x23>
    panic("ilock");
80101d12:	83 ec 0c             	sub    $0xc,%esp
80101d15:	68 bd 9e 10 80       	push   $0x80109ebd
80101d1a:	e8 47 e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101d1f:	83 ec 0c             	sub    $0xc,%esp
80101d22:	68 40 32 11 80       	push   $0x80113240
80101d27:	e8 3b 40 00 00       	call   80105d67 <acquire>
80101d2c:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101d2f:	eb 13                	jmp    80101d44 <ilock+0x48>
    sleep(ip, &icache.lock);
80101d31:	83 ec 08             	sub    $0x8,%esp
80101d34:	68 40 32 11 80       	push   $0x80113240
80101d39:	ff 75 08             	pushl  0x8(%ebp)
80101d3c:	e8 61 3b 00 00       	call   801058a2 <sleep>
80101d41:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101d44:	8b 45 08             	mov    0x8(%ebp),%eax
80101d47:	8b 40 0c             	mov    0xc(%eax),%eax
80101d4a:	83 e0 01             	and    $0x1,%eax
80101d4d:	85 c0                	test   %eax,%eax
80101d4f:	75 e0                	jne    80101d31 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101d51:	8b 45 08             	mov    0x8(%ebp),%eax
80101d54:	8b 40 0c             	mov    0xc(%eax),%eax
80101d57:	83 c8 01             	or     $0x1,%eax
80101d5a:	89 c2                	mov    %eax,%edx
80101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5f:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101d62:	83 ec 0c             	sub    $0xc,%esp
80101d65:	68 40 32 11 80       	push   $0x80113240
80101d6a:	e8 5f 40 00 00       	call   80105dce <release>
80101d6f:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	8b 40 0c             	mov    0xc(%eax),%eax
80101d78:	83 e0 02             	and    $0x2,%eax
80101d7b:	85 c0                	test   %eax,%eax
80101d7d:	0f 85 d4 00 00 00    	jne    80101e57 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101d83:	8b 45 08             	mov    0x8(%ebp),%eax
80101d86:	8b 40 04             	mov    0x4(%eax),%eax
80101d89:	c1 e8 03             	shr    $0x3,%eax
80101d8c:	89 c2                	mov    %eax,%edx
80101d8e:	a1 34 32 11 80       	mov    0x80113234,%eax
80101d93:	01 c2                	add    %eax,%edx
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	8b 00                	mov    (%eax),%eax
80101d9a:	83 ec 08             	sub    $0x8,%esp
80101d9d:	52                   	push   %edx
80101d9e:	50                   	push   %eax
80101d9f:	e8 12 e4 ff ff       	call   801001b6 <bread>
80101da4:	83 c4 10             	add    $0x10,%esp
80101da7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dad:	8d 50 18             	lea    0x18(%eax),%edx
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	8b 40 04             	mov    0x4(%eax),%eax
80101db6:	83 e0 07             	and    $0x7,%eax
80101db9:	c1 e0 06             	shl    $0x6,%eax
80101dbc:	01 d0                	add    %edx,%eax
80101dbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc4:	0f b7 10             	movzwl (%eax),%edx
80101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dca:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dd1:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101ddc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ddf:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101de3:	8b 45 08             	mov    0x8(%ebp),%eax
80101de6:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ded:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101df1:	8b 45 08             	mov    0x8(%ebp),%eax
80101df4:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfb:	8b 50 08             	mov    0x8(%eax),%edx
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e07:	8d 50 0c             	lea    0xc(%eax),%edx
80101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0d:	83 c0 1c             	add    $0x1c,%eax
80101e10:	83 ec 04             	sub    $0x4,%esp
80101e13:	6a 34                	push   $0x34
80101e15:	52                   	push   %edx
80101e16:	50                   	push   %eax
80101e17:	e8 6d 42 00 00       	call   80106089 <memmove>
80101e1c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101e1f:	83 ec 0c             	sub    $0xc,%esp
80101e22:	ff 75 f4             	pushl  -0xc(%ebp)
80101e25:	e8 04 e4 ff ff       	call   8010022e <brelse>
80101e2a:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e30:	8b 40 0c             	mov    0xc(%eax),%eax
80101e33:	83 c8 02             	or     $0x2,%eax
80101e36:	89 c2                	mov    %eax,%edx
80101e38:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3b:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e41:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e45:	66 85 c0             	test   %ax,%ax
80101e48:	75 0d                	jne    80101e57 <ilock+0x15b>
      panic("ilock: no type");
80101e4a:	83 ec 0c             	sub    $0xc,%esp
80101e4d:	68 c3 9e 10 80       	push   $0x80109ec3
80101e52:	e8 0f e7 ff ff       	call   80100566 <panic>
  }
}
80101e57:	90                   	nop
80101e58:	c9                   	leave  
80101e59:	c3                   	ret    

80101e5a <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101e5a:	55                   	push   %ebp
80101e5b:	89 e5                	mov    %esp,%ebp
80101e5d:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101e60:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101e64:	74 17                	je     80101e7d <iunlock+0x23>
80101e66:	8b 45 08             	mov    0x8(%ebp),%eax
80101e69:	8b 40 0c             	mov    0xc(%eax),%eax
80101e6c:	83 e0 01             	and    $0x1,%eax
80101e6f:	85 c0                	test   %eax,%eax
80101e71:	74 0a                	je     80101e7d <iunlock+0x23>
80101e73:	8b 45 08             	mov    0x8(%ebp),%eax
80101e76:	8b 40 08             	mov    0x8(%eax),%eax
80101e79:	85 c0                	test   %eax,%eax
80101e7b:	7f 0d                	jg     80101e8a <iunlock+0x30>
    panic("iunlock");
80101e7d:	83 ec 0c             	sub    $0xc,%esp
80101e80:	68 d2 9e 10 80       	push   $0x80109ed2
80101e85:	e8 dc e6 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101e8a:	83 ec 0c             	sub    $0xc,%esp
80101e8d:	68 40 32 11 80       	push   $0x80113240
80101e92:	e8 d0 3e 00 00       	call   80105d67 <acquire>
80101e97:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9d:	8b 40 0c             	mov    0xc(%eax),%eax
80101ea0:	83 e0 fe             	and    $0xfffffffe,%eax
80101ea3:	89 c2                	mov    %eax,%edx
80101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea8:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101eab:	83 ec 0c             	sub    $0xc,%esp
80101eae:	ff 75 08             	pushl  0x8(%ebp)
80101eb1:	e8 da 3a 00 00       	call   80105990 <wakeup>
80101eb6:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101eb9:	83 ec 0c             	sub    $0xc,%esp
80101ebc:	68 40 32 11 80       	push   $0x80113240
80101ec1:	e8 08 3f 00 00       	call   80105dce <release>
80101ec6:	83 c4 10             	add    $0x10,%esp
}
80101ec9:	90                   	nop
80101eca:	c9                   	leave  
80101ecb:	c3                   	ret    

80101ecc <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101ecc:	55                   	push   %ebp
80101ecd:	89 e5                	mov    %esp,%ebp
80101ecf:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ed2:	83 ec 0c             	sub    $0xc,%esp
80101ed5:	68 40 32 11 80       	push   $0x80113240
80101eda:	e8 88 3e 00 00       	call   80105d67 <acquire>
80101edf:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	8b 40 08             	mov    0x8(%eax),%eax
80101ee8:	83 f8 01             	cmp    $0x1,%eax
80101eeb:	0f 85 a9 00 00 00    	jne    80101f9a <iput+0xce>
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	8b 40 0c             	mov    0xc(%eax),%eax
80101ef7:	83 e0 02             	and    $0x2,%eax
80101efa:	85 c0                	test   %eax,%eax
80101efc:	0f 84 98 00 00 00    	je     80101f9a <iput+0xce>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101f09:	66 85 c0             	test   %ax,%ax
80101f0c:	0f 85 88 00 00 00    	jne    80101f9a <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101f12:	8b 45 08             	mov    0x8(%ebp),%eax
80101f15:	8b 40 0c             	mov    0xc(%eax),%eax
80101f18:	83 e0 01             	and    $0x1,%eax
80101f1b:	85 c0                	test   %eax,%eax
80101f1d:	74 0d                	je     80101f2c <iput+0x60>
      panic("iput busy");
80101f1f:	83 ec 0c             	sub    $0xc,%esp
80101f22:	68 da 9e 10 80       	push   $0x80109eda
80101f27:	e8 3a e6 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2f:	8b 40 0c             	mov    0xc(%eax),%eax
80101f32:	83 c8 01             	or     $0x1,%eax
80101f35:	89 c2                	mov    %eax,%edx
80101f37:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3a:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101f3d:	83 ec 0c             	sub    $0xc,%esp
80101f40:	68 40 32 11 80       	push   $0x80113240
80101f45:	e8 84 3e 00 00       	call   80105dce <release>
80101f4a:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101f4d:	83 ec 0c             	sub    $0xc,%esp
80101f50:	ff 75 08             	pushl  0x8(%ebp)
80101f53:	e8 a8 01 00 00       	call   80102100 <itrunc>
80101f58:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5e:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101f64:	83 ec 0c             	sub    $0xc,%esp
80101f67:	ff 75 08             	pushl  0x8(%ebp)
80101f6a:	e8 b3 fb ff ff       	call   80101b22 <iupdate>
80101f6f:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101f72:	83 ec 0c             	sub    $0xc,%esp
80101f75:	68 40 32 11 80       	push   $0x80113240
80101f7a:	e8 e8 3d 00 00       	call   80105d67 <acquire>
80101f7f:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101f82:	8b 45 08             	mov    0x8(%ebp),%eax
80101f85:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101f8c:	83 ec 0c             	sub    $0xc,%esp
80101f8f:	ff 75 08             	pushl  0x8(%ebp)
80101f92:	e8 f9 39 00 00       	call   80105990 <wakeup>
80101f97:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9d:	8b 40 08             	mov    0x8(%eax),%eax
80101fa0:	8d 50 ff             	lea    -0x1(%eax),%edx
80101fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa6:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101fa9:	83 ec 0c             	sub    $0xc,%esp
80101fac:	68 40 32 11 80       	push   $0x80113240
80101fb1:	e8 18 3e 00 00       	call   80105dce <release>
80101fb6:	83 c4 10             	add    $0x10,%esp
}
80101fb9:	90                   	nop
80101fba:	c9                   	leave  
80101fbb:	c3                   	ret    

80101fbc <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101fbc:	55                   	push   %ebp
80101fbd:	89 e5                	mov    %esp,%ebp
80101fbf:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101fc2:	83 ec 0c             	sub    $0xc,%esp
80101fc5:	ff 75 08             	pushl  0x8(%ebp)
80101fc8:	e8 8d fe ff ff       	call   80101e5a <iunlock>
80101fcd:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101fd0:	83 ec 0c             	sub    $0xc,%esp
80101fd3:	ff 75 08             	pushl  0x8(%ebp)
80101fd6:	e8 f1 fe ff ff       	call   80101ecc <iput>
80101fdb:	83 c4 10             	add    $0x10,%esp
}
80101fde:	90                   	nop
80101fdf:	c9                   	leave  
80101fe0:	c3                   	ret    

80101fe1 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101fe1:	55                   	push   %ebp
80101fe2:	89 e5                	mov    %esp,%ebp
80101fe4:	53                   	push   %ebx
80101fe5:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101fe8:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101fec:	77 42                	ja     80102030 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101fee:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff1:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ff4:	83 c2 04             	add    $0x4,%edx
80101ff7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ffb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ffe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102002:	75 24                	jne    80102028 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80102004:	8b 45 08             	mov    0x8(%ebp),%eax
80102007:	8b 00                	mov    (%eax),%eax
80102009:	83 ec 0c             	sub    $0xc,%esp
8010200c:	50                   	push   %eax
8010200d:	e8 9a f7 ff ff       	call   801017ac <balloc>
80102012:	83 c4 10             	add    $0x10,%esp
80102015:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102018:	8b 45 08             	mov    0x8(%ebp),%eax
8010201b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010201e:	8d 4a 04             	lea    0x4(%edx),%ecx
80102021:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102024:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80102028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010202b:	e9 cb 00 00 00       	jmp    801020fb <bmap+0x11a>
  }
  bn -= NDIRECT;
80102030:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80102034:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80102038:	0f 87 b0 00 00 00    	ja     801020ee <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	8b 40 4c             	mov    0x4c(%eax),%eax
80102044:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102047:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010204b:	75 1d                	jne    8010206a <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010204d:	8b 45 08             	mov    0x8(%ebp),%eax
80102050:	8b 00                	mov    (%eax),%eax
80102052:	83 ec 0c             	sub    $0xc,%esp
80102055:	50                   	push   %eax
80102056:	e8 51 f7 ff ff       	call   801017ac <balloc>
8010205b:	83 c4 10             	add    $0x10,%esp
8010205e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102067:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	8b 00                	mov    (%eax),%eax
8010206f:	83 ec 08             	sub    $0x8,%esp
80102072:	ff 75 f4             	pushl  -0xc(%ebp)
80102075:	50                   	push   %eax
80102076:	e8 3b e1 ff ff       	call   801001b6 <bread>
8010207b:	83 c4 10             	add    $0x10,%esp
8010207e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80102081:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102084:	83 c0 18             	add    $0x18,%eax
80102087:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
8010208a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010208d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102094:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102097:	01 d0                	add    %edx,%eax
80102099:	8b 00                	mov    (%eax),%eax
8010209b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010209e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801020a2:	75 37                	jne    801020db <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
801020a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801020ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801020b4:	8b 45 08             	mov    0x8(%ebp),%eax
801020b7:	8b 00                	mov    (%eax),%eax
801020b9:	83 ec 0c             	sub    $0xc,%esp
801020bc:	50                   	push   %eax
801020bd:	e8 ea f6 ff ff       	call   801017ac <balloc>
801020c2:	83 c4 10             	add    $0x10,%esp
801020c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801020c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020cb:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
801020cd:	83 ec 0c             	sub    $0xc,%esp
801020d0:	ff 75 f0             	pushl  -0x10(%ebp)
801020d3:	e8 a3 1e 00 00       	call   80103f7b <log_write>
801020d8:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
801020db:	83 ec 0c             	sub    $0xc,%esp
801020de:	ff 75 f0             	pushl  -0x10(%ebp)
801020e1:	e8 48 e1 ff ff       	call   8010022e <brelse>
801020e6:	83 c4 10             	add    $0x10,%esp
    return addr;
801020e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ec:	eb 0d                	jmp    801020fb <bmap+0x11a>
  }

  panic("bmap: out of range");
801020ee:	83 ec 0c             	sub    $0xc,%esp
801020f1:	68 e4 9e 10 80       	push   $0x80109ee4
801020f6:	e8 6b e4 ff ff       	call   80100566 <panic>
}
801020fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020fe:	c9                   	leave  
801020ff:	c3                   	ret    

80102100 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80102100:	55                   	push   %ebp
80102101:	89 e5                	mov    %esp,%ebp
80102103:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80102106:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010210d:	eb 45                	jmp    80102154 <itrunc+0x54>
    if(ip->addrs[i]){
8010210f:	8b 45 08             	mov    0x8(%ebp),%eax
80102112:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102115:	83 c2 04             	add    $0x4,%edx
80102118:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	74 30                	je     80102150 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80102120:	8b 45 08             	mov    0x8(%ebp),%eax
80102123:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102126:	83 c2 04             	add    $0x4,%edx
80102129:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010212d:	8b 55 08             	mov    0x8(%ebp),%edx
80102130:	8b 12                	mov    (%edx),%edx
80102132:	83 ec 08             	sub    $0x8,%esp
80102135:	50                   	push   %eax
80102136:	52                   	push   %edx
80102137:	e8 bc f7 ff ff       	call   801018f8 <bfree>
8010213c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
8010213f:	8b 45 08             	mov    0x8(%ebp),%eax
80102142:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102145:	83 c2 04             	add    $0x4,%edx
80102148:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010214f:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80102150:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102154:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102158:	7e b5                	jle    8010210f <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
8010215a:	8b 45 08             	mov    0x8(%ebp),%eax
8010215d:	8b 40 4c             	mov    0x4c(%eax),%eax
80102160:	85 c0                	test   %eax,%eax
80102162:	0f 84 a1 00 00 00    	je     80102209 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80102168:	8b 45 08             	mov    0x8(%ebp),%eax
8010216b:	8b 50 4c             	mov    0x4c(%eax),%edx
8010216e:	8b 45 08             	mov    0x8(%ebp),%eax
80102171:	8b 00                	mov    (%eax),%eax
80102173:	83 ec 08             	sub    $0x8,%esp
80102176:	52                   	push   %edx
80102177:	50                   	push   %eax
80102178:	e8 39 e0 ff ff       	call   801001b6 <bread>
8010217d:	83 c4 10             	add    $0x10,%esp
80102180:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80102183:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102186:	83 c0 18             	add    $0x18,%eax
80102189:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
8010218c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102193:	eb 3c                	jmp    801021d1 <itrunc+0xd1>
      if(a[j])
80102195:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102198:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010219f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801021a2:	01 d0                	add    %edx,%eax
801021a4:	8b 00                	mov    (%eax),%eax
801021a6:	85 c0                	test   %eax,%eax
801021a8:	74 23                	je     801021cd <itrunc+0xcd>
        bfree(ip->dev, a[j]);
801021aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801021b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801021b7:	01 d0                	add    %edx,%eax
801021b9:	8b 00                	mov    (%eax),%eax
801021bb:	8b 55 08             	mov    0x8(%ebp),%edx
801021be:	8b 12                	mov    (%edx),%edx
801021c0:	83 ec 08             	sub    $0x8,%esp
801021c3:	50                   	push   %eax
801021c4:	52                   	push   %edx
801021c5:	e8 2e f7 ff ff       	call   801018f8 <bfree>
801021ca:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
801021cd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801021d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021d4:	83 f8 7f             	cmp    $0x7f,%eax
801021d7:	76 bc                	jbe    80102195 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
801021d9:	83 ec 0c             	sub    $0xc,%esp
801021dc:	ff 75 ec             	pushl  -0x14(%ebp)
801021df:	e8 4a e0 ff ff       	call   8010022e <brelse>
801021e4:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
801021e7:	8b 45 08             	mov    0x8(%ebp),%eax
801021ea:	8b 40 4c             	mov    0x4c(%eax),%eax
801021ed:	8b 55 08             	mov    0x8(%ebp),%edx
801021f0:	8b 12                	mov    (%edx),%edx
801021f2:	83 ec 08             	sub    $0x8,%esp
801021f5:	50                   	push   %eax
801021f6:	52                   	push   %edx
801021f7:	e8 fc f6 ff ff       	call   801018f8 <bfree>
801021fc:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
801021ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102202:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102209:	8b 45 08             	mov    0x8(%ebp),%eax
8010220c:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102213:	83 ec 0c             	sub    $0xc,%esp
80102216:	ff 75 08             	pushl  0x8(%ebp)
80102219:	e8 04 f9 ff ff       	call   80101b22 <iupdate>
8010221e:	83 c4 10             	add    $0x10,%esp
}
80102221:	90                   	nop
80102222:	c9                   	leave  
80102223:	c3                   	ret    

80102224 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102224:	55                   	push   %ebp
80102225:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102227:	8b 45 08             	mov    0x8(%ebp),%eax
8010222a:	8b 00                	mov    (%eax),%eax
8010222c:	89 c2                	mov    %eax,%edx
8010222e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102231:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102234:	8b 45 08             	mov    0x8(%ebp),%eax
80102237:	8b 50 04             	mov    0x4(%eax),%edx
8010223a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010223d:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102247:	8b 45 0c             	mov    0xc(%ebp),%eax
8010224a:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010224d:	8b 45 08             	mov    0x8(%ebp),%eax
80102250:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102254:	8b 45 0c             	mov    0xc(%ebp),%eax
80102257:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010225b:	8b 45 08             	mov    0x8(%ebp),%eax
8010225e:	8b 50 18             	mov    0x18(%eax),%edx
80102261:	8b 45 0c             	mov    0xc(%ebp),%eax
80102264:	89 50 10             	mov    %edx,0x10(%eax)
}
80102267:	90                   	nop
80102268:	5d                   	pop    %ebp
80102269:	c3                   	ret    

8010226a <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010226a:	55                   	push   %ebp
8010226b:	89 e5                	mov    %esp,%ebp
8010226d:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102277:	66 83 f8 03          	cmp    $0x3,%ax
8010227b:	75 5c                	jne    801022d9 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010227d:	8b 45 08             	mov    0x8(%ebp),%eax
80102280:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102284:	66 85 c0             	test   %ax,%ax
80102287:	78 20                	js     801022a9 <readi+0x3f>
80102289:	8b 45 08             	mov    0x8(%ebp),%eax
8010228c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102290:	66 83 f8 09          	cmp    $0x9,%ax
80102294:	7f 13                	jg     801022a9 <readi+0x3f>
80102296:	8b 45 08             	mov    0x8(%ebp),%eax
80102299:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010229d:	98                   	cwtl   
8010229e:	8b 04 c5 c0 31 11 80 	mov    -0x7feece40(,%eax,8),%eax
801022a5:	85 c0                	test   %eax,%eax
801022a7:	75 0a                	jne    801022b3 <readi+0x49>
      return -1;
801022a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022ae:	e9 0c 01 00 00       	jmp    801023bf <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
801022b3:	8b 45 08             	mov    0x8(%ebp),%eax
801022b6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801022ba:	98                   	cwtl   
801022bb:	8b 04 c5 c0 31 11 80 	mov    -0x7feece40(,%eax,8),%eax
801022c2:	8b 55 14             	mov    0x14(%ebp),%edx
801022c5:	83 ec 04             	sub    $0x4,%esp
801022c8:	52                   	push   %edx
801022c9:	ff 75 0c             	pushl  0xc(%ebp)
801022cc:	ff 75 08             	pushl  0x8(%ebp)
801022cf:	ff d0                	call   *%eax
801022d1:	83 c4 10             	add    $0x10,%esp
801022d4:	e9 e6 00 00 00       	jmp    801023bf <readi+0x155>
  }

  if(off > ip->size || off + n < off)
801022d9:	8b 45 08             	mov    0x8(%ebp),%eax
801022dc:	8b 40 18             	mov    0x18(%eax),%eax
801022df:	3b 45 10             	cmp    0x10(%ebp),%eax
801022e2:	72 0d                	jb     801022f1 <readi+0x87>
801022e4:	8b 55 10             	mov    0x10(%ebp),%edx
801022e7:	8b 45 14             	mov    0x14(%ebp),%eax
801022ea:	01 d0                	add    %edx,%eax
801022ec:	3b 45 10             	cmp    0x10(%ebp),%eax
801022ef:	73 0a                	jae    801022fb <readi+0x91>
    return -1;
801022f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022f6:	e9 c4 00 00 00       	jmp    801023bf <readi+0x155>
  if(off + n > ip->size)
801022fb:	8b 55 10             	mov    0x10(%ebp),%edx
801022fe:	8b 45 14             	mov    0x14(%ebp),%eax
80102301:	01 c2                	add    %eax,%edx
80102303:	8b 45 08             	mov    0x8(%ebp),%eax
80102306:	8b 40 18             	mov    0x18(%eax),%eax
80102309:	39 c2                	cmp    %eax,%edx
8010230b:	76 0c                	jbe    80102319 <readi+0xaf>
    n = ip->size - off;
8010230d:	8b 45 08             	mov    0x8(%ebp),%eax
80102310:	8b 40 18             	mov    0x18(%eax),%eax
80102313:	2b 45 10             	sub    0x10(%ebp),%eax
80102316:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102319:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102320:	e9 8b 00 00 00       	jmp    801023b0 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102325:	8b 45 10             	mov    0x10(%ebp),%eax
80102328:	c1 e8 09             	shr    $0x9,%eax
8010232b:	83 ec 08             	sub    $0x8,%esp
8010232e:	50                   	push   %eax
8010232f:	ff 75 08             	pushl  0x8(%ebp)
80102332:	e8 aa fc ff ff       	call   80101fe1 <bmap>
80102337:	83 c4 10             	add    $0x10,%esp
8010233a:	89 c2                	mov    %eax,%edx
8010233c:	8b 45 08             	mov    0x8(%ebp),%eax
8010233f:	8b 00                	mov    (%eax),%eax
80102341:	83 ec 08             	sub    $0x8,%esp
80102344:	52                   	push   %edx
80102345:	50                   	push   %eax
80102346:	e8 6b de ff ff       	call   801001b6 <bread>
8010234b:	83 c4 10             	add    $0x10,%esp
8010234e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102351:	8b 45 10             	mov    0x10(%ebp),%eax
80102354:	25 ff 01 00 00       	and    $0x1ff,%eax
80102359:	ba 00 02 00 00       	mov    $0x200,%edx
8010235e:	29 c2                	sub    %eax,%edx
80102360:	8b 45 14             	mov    0x14(%ebp),%eax
80102363:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102366:	39 c2                	cmp    %eax,%edx
80102368:	0f 46 c2             	cmovbe %edx,%eax
8010236b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010236e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102371:	8d 50 18             	lea    0x18(%eax),%edx
80102374:	8b 45 10             	mov    0x10(%ebp),%eax
80102377:	25 ff 01 00 00       	and    $0x1ff,%eax
8010237c:	01 d0                	add    %edx,%eax
8010237e:	83 ec 04             	sub    $0x4,%esp
80102381:	ff 75 ec             	pushl  -0x14(%ebp)
80102384:	50                   	push   %eax
80102385:	ff 75 0c             	pushl  0xc(%ebp)
80102388:	e8 fc 3c 00 00       	call   80106089 <memmove>
8010238d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102390:	83 ec 0c             	sub    $0xc,%esp
80102393:	ff 75 f0             	pushl  -0x10(%ebp)
80102396:	e8 93 de ff ff       	call   8010022e <brelse>
8010239b:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010239e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023a1:	01 45 f4             	add    %eax,-0xc(%ebp)
801023a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023a7:	01 45 10             	add    %eax,0x10(%ebp)
801023aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023ad:	01 45 0c             	add    %eax,0xc(%ebp)
801023b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b3:	3b 45 14             	cmp    0x14(%ebp),%eax
801023b6:	0f 82 69 ff ff ff    	jb     80102325 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801023bc:	8b 45 14             	mov    0x14(%ebp),%eax
}
801023bf:	c9                   	leave  
801023c0:	c3                   	ret    

801023c1 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801023c1:	55                   	push   %ebp
801023c2:	89 e5                	mov    %esp,%ebp
801023c4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801023c7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ca:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023ce:	66 83 f8 03          	cmp    $0x3,%ax
801023d2:	75 5c                	jne    80102430 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801023d4:	8b 45 08             	mov    0x8(%ebp),%eax
801023d7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801023db:	66 85 c0             	test   %ax,%ax
801023de:	78 20                	js     80102400 <writei+0x3f>
801023e0:	8b 45 08             	mov    0x8(%ebp),%eax
801023e3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801023e7:	66 83 f8 09          	cmp    $0x9,%ax
801023eb:	7f 13                	jg     80102400 <writei+0x3f>
801023ed:	8b 45 08             	mov    0x8(%ebp),%eax
801023f0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801023f4:	98                   	cwtl   
801023f5:	8b 04 c5 c4 31 11 80 	mov    -0x7feece3c(,%eax,8),%eax
801023fc:	85 c0                	test   %eax,%eax
801023fe:	75 0a                	jne    8010240a <writei+0x49>
      return -1;
80102400:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102405:	e9 3d 01 00 00       	jmp    80102547 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010240a:	8b 45 08             	mov    0x8(%ebp),%eax
8010240d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102411:	98                   	cwtl   
80102412:	8b 04 c5 c4 31 11 80 	mov    -0x7feece3c(,%eax,8),%eax
80102419:	8b 55 14             	mov    0x14(%ebp),%edx
8010241c:	83 ec 04             	sub    $0x4,%esp
8010241f:	52                   	push   %edx
80102420:	ff 75 0c             	pushl  0xc(%ebp)
80102423:	ff 75 08             	pushl  0x8(%ebp)
80102426:	ff d0                	call   *%eax
80102428:	83 c4 10             	add    $0x10,%esp
8010242b:	e9 17 01 00 00       	jmp    80102547 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102430:	8b 45 08             	mov    0x8(%ebp),%eax
80102433:	8b 40 18             	mov    0x18(%eax),%eax
80102436:	3b 45 10             	cmp    0x10(%ebp),%eax
80102439:	72 0d                	jb     80102448 <writei+0x87>
8010243b:	8b 55 10             	mov    0x10(%ebp),%edx
8010243e:	8b 45 14             	mov    0x14(%ebp),%eax
80102441:	01 d0                	add    %edx,%eax
80102443:	3b 45 10             	cmp    0x10(%ebp),%eax
80102446:	73 0a                	jae    80102452 <writei+0x91>
    return -1;
80102448:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010244d:	e9 f5 00 00 00       	jmp    80102547 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102452:	8b 55 10             	mov    0x10(%ebp),%edx
80102455:	8b 45 14             	mov    0x14(%ebp),%eax
80102458:	01 d0                	add    %edx,%eax
8010245a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010245f:	76 0a                	jbe    8010246b <writei+0xaa>
    return -1;
80102461:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102466:	e9 dc 00 00 00       	jmp    80102547 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010246b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102472:	e9 99 00 00 00       	jmp    80102510 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102477:	8b 45 10             	mov    0x10(%ebp),%eax
8010247a:	c1 e8 09             	shr    $0x9,%eax
8010247d:	83 ec 08             	sub    $0x8,%esp
80102480:	50                   	push   %eax
80102481:	ff 75 08             	pushl  0x8(%ebp)
80102484:	e8 58 fb ff ff       	call   80101fe1 <bmap>
80102489:	83 c4 10             	add    $0x10,%esp
8010248c:	89 c2                	mov    %eax,%edx
8010248e:	8b 45 08             	mov    0x8(%ebp),%eax
80102491:	8b 00                	mov    (%eax),%eax
80102493:	83 ec 08             	sub    $0x8,%esp
80102496:	52                   	push   %edx
80102497:	50                   	push   %eax
80102498:	e8 19 dd ff ff       	call   801001b6 <bread>
8010249d:	83 c4 10             	add    $0x10,%esp
801024a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801024a3:	8b 45 10             	mov    0x10(%ebp),%eax
801024a6:	25 ff 01 00 00       	and    $0x1ff,%eax
801024ab:	ba 00 02 00 00       	mov    $0x200,%edx
801024b0:	29 c2                	sub    %eax,%edx
801024b2:	8b 45 14             	mov    0x14(%ebp),%eax
801024b5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801024b8:	39 c2                	cmp    %eax,%edx
801024ba:	0f 46 c2             	cmovbe %edx,%eax
801024bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801024c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024c3:	8d 50 18             	lea    0x18(%eax),%edx
801024c6:	8b 45 10             	mov    0x10(%ebp),%eax
801024c9:	25 ff 01 00 00       	and    $0x1ff,%eax
801024ce:	01 d0                	add    %edx,%eax
801024d0:	83 ec 04             	sub    $0x4,%esp
801024d3:	ff 75 ec             	pushl  -0x14(%ebp)
801024d6:	ff 75 0c             	pushl  0xc(%ebp)
801024d9:	50                   	push   %eax
801024da:	e8 aa 3b 00 00       	call   80106089 <memmove>
801024df:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801024e2:	83 ec 0c             	sub    $0xc,%esp
801024e5:	ff 75 f0             	pushl  -0x10(%ebp)
801024e8:	e8 8e 1a 00 00       	call   80103f7b <log_write>
801024ed:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801024f0:	83 ec 0c             	sub    $0xc,%esp
801024f3:	ff 75 f0             	pushl  -0x10(%ebp)
801024f6:	e8 33 dd ff ff       	call   8010022e <brelse>
801024fb:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801024fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102501:	01 45 f4             	add    %eax,-0xc(%ebp)
80102504:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102507:	01 45 10             	add    %eax,0x10(%ebp)
8010250a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010250d:	01 45 0c             	add    %eax,0xc(%ebp)
80102510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102513:	3b 45 14             	cmp    0x14(%ebp),%eax
80102516:	0f 82 5b ff ff ff    	jb     80102477 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010251c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102520:	74 22                	je     80102544 <writei+0x183>
80102522:	8b 45 08             	mov    0x8(%ebp),%eax
80102525:	8b 40 18             	mov    0x18(%eax),%eax
80102528:	3b 45 10             	cmp    0x10(%ebp),%eax
8010252b:	73 17                	jae    80102544 <writei+0x183>
    ip->size = off;
8010252d:	8b 45 08             	mov    0x8(%ebp),%eax
80102530:	8b 55 10             	mov    0x10(%ebp),%edx
80102533:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102536:	83 ec 0c             	sub    $0xc,%esp
80102539:	ff 75 08             	pushl  0x8(%ebp)
8010253c:	e8 e1 f5 ff ff       	call   80101b22 <iupdate>
80102541:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102544:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102547:	c9                   	leave  
80102548:	c3                   	ret    

80102549 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102549:	55                   	push   %ebp
8010254a:	89 e5                	mov    %esp,%ebp
8010254c:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010254f:	83 ec 04             	sub    $0x4,%esp
80102552:	6a 0e                	push   $0xe
80102554:	ff 75 0c             	pushl  0xc(%ebp)
80102557:	ff 75 08             	pushl  0x8(%ebp)
8010255a:	e8 c0 3b 00 00       	call   8010611f <strncmp>
8010255f:	83 c4 10             	add    $0x10,%esp
}
80102562:	c9                   	leave  
80102563:	c3                   	ret    

80102564 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102564:	55                   	push   %ebp
80102565:	89 e5                	mov    %esp,%ebp
80102567:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010256a:	8b 45 08             	mov    0x8(%ebp),%eax
8010256d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102571:	66 83 f8 01          	cmp    $0x1,%ax
80102575:	74 0d                	je     80102584 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102577:	83 ec 0c             	sub    $0xc,%esp
8010257a:	68 f7 9e 10 80       	push   $0x80109ef7
8010257f:	e8 e2 df ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102584:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010258b:	eb 7b                	jmp    80102608 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010258d:	6a 10                	push   $0x10
8010258f:	ff 75 f4             	pushl  -0xc(%ebp)
80102592:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102595:	50                   	push   %eax
80102596:	ff 75 08             	pushl  0x8(%ebp)
80102599:	e8 cc fc ff ff       	call   8010226a <readi>
8010259e:	83 c4 10             	add    $0x10,%esp
801025a1:	83 f8 10             	cmp    $0x10,%eax
801025a4:	74 0d                	je     801025b3 <dirlookup+0x4f>
      panic("dirlink read");
801025a6:	83 ec 0c             	sub    $0xc,%esp
801025a9:	68 09 9f 10 80       	push   $0x80109f09
801025ae:	e8 b3 df ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801025b3:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801025b7:	66 85 c0             	test   %ax,%ax
801025ba:	74 47                	je     80102603 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801025bc:	83 ec 08             	sub    $0x8,%esp
801025bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801025c2:	83 c0 02             	add    $0x2,%eax
801025c5:	50                   	push   %eax
801025c6:	ff 75 0c             	pushl  0xc(%ebp)
801025c9:	e8 7b ff ff ff       	call   80102549 <namecmp>
801025ce:	83 c4 10             	add    $0x10,%esp
801025d1:	85 c0                	test   %eax,%eax
801025d3:	75 2f                	jne    80102604 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801025d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801025d9:	74 08                	je     801025e3 <dirlookup+0x7f>
        *poff = off;
801025db:	8b 45 10             	mov    0x10(%ebp),%eax
801025de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801025e1:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801025e3:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801025e7:	0f b7 c0             	movzwl %ax,%eax
801025ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801025ed:	8b 45 08             	mov    0x8(%ebp),%eax
801025f0:	8b 00                	mov    (%eax),%eax
801025f2:	83 ec 08             	sub    $0x8,%esp
801025f5:	ff 75 f0             	pushl  -0x10(%ebp)
801025f8:	50                   	push   %eax
801025f9:	e8 e5 f5 ff ff       	call   80101be3 <iget>
801025fe:	83 c4 10             	add    $0x10,%esp
80102601:	eb 19                	jmp    8010261c <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102603:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102604:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102608:	8b 45 08             	mov    0x8(%ebp),%eax
8010260b:	8b 40 18             	mov    0x18(%eax),%eax
8010260e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102611:	0f 87 76 ff ff ff    	ja     8010258d <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102617:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010261c:	c9                   	leave  
8010261d:	c3                   	ret    

8010261e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010261e:	55                   	push   %ebp
8010261f:	89 e5                	mov    %esp,%ebp
80102621:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102624:	83 ec 04             	sub    $0x4,%esp
80102627:	6a 00                	push   $0x0
80102629:	ff 75 0c             	pushl  0xc(%ebp)
8010262c:	ff 75 08             	pushl  0x8(%ebp)
8010262f:	e8 30 ff ff ff       	call   80102564 <dirlookup>
80102634:	83 c4 10             	add    $0x10,%esp
80102637:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010263a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010263e:	74 18                	je     80102658 <dirlink+0x3a>
    iput(ip);
80102640:	83 ec 0c             	sub    $0xc,%esp
80102643:	ff 75 f0             	pushl  -0x10(%ebp)
80102646:	e8 81 f8 ff ff       	call   80101ecc <iput>
8010264b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010264e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102653:	e9 9c 00 00 00       	jmp    801026f4 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102658:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010265f:	eb 39                	jmp    8010269a <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102664:	6a 10                	push   $0x10
80102666:	50                   	push   %eax
80102667:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010266a:	50                   	push   %eax
8010266b:	ff 75 08             	pushl  0x8(%ebp)
8010266e:	e8 f7 fb ff ff       	call   8010226a <readi>
80102673:	83 c4 10             	add    $0x10,%esp
80102676:	83 f8 10             	cmp    $0x10,%eax
80102679:	74 0d                	je     80102688 <dirlink+0x6a>
      panic("dirlink read");
8010267b:	83 ec 0c             	sub    $0xc,%esp
8010267e:	68 09 9f 10 80       	push   $0x80109f09
80102683:	e8 de de ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102688:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010268c:	66 85 c0             	test   %ax,%ax
8010268f:	74 18                	je     801026a9 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102694:	83 c0 10             	add    $0x10,%eax
80102697:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010269a:	8b 45 08             	mov    0x8(%ebp),%eax
8010269d:	8b 50 18             	mov    0x18(%eax),%edx
801026a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a3:	39 c2                	cmp    %eax,%edx
801026a5:	77 ba                	ja     80102661 <dirlink+0x43>
801026a7:	eb 01                	jmp    801026aa <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801026a9:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801026aa:	83 ec 04             	sub    $0x4,%esp
801026ad:	6a 0e                	push   $0xe
801026af:	ff 75 0c             	pushl  0xc(%ebp)
801026b2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801026b5:	83 c0 02             	add    $0x2,%eax
801026b8:	50                   	push   %eax
801026b9:	e8 b7 3a 00 00       	call   80106175 <strncpy>
801026be:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801026c1:	8b 45 10             	mov    0x10(%ebp),%eax
801026c4:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801026c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026cb:	6a 10                	push   $0x10
801026cd:	50                   	push   %eax
801026ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
801026d1:	50                   	push   %eax
801026d2:	ff 75 08             	pushl  0x8(%ebp)
801026d5:	e8 e7 fc ff ff       	call   801023c1 <writei>
801026da:	83 c4 10             	add    $0x10,%esp
801026dd:	83 f8 10             	cmp    $0x10,%eax
801026e0:	74 0d                	je     801026ef <dirlink+0xd1>
    panic("dirlink");
801026e2:	83 ec 0c             	sub    $0xc,%esp
801026e5:	68 16 9f 10 80       	push   $0x80109f16
801026ea:	e8 77 de ff ff       	call   80100566 <panic>

  return 0;
801026ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026f4:	c9                   	leave  
801026f5:	c3                   	ret    

801026f6 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801026f6:	55                   	push   %ebp
801026f7:	89 e5                	mov    %esp,%ebp
801026f9:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801026fc:	eb 04                	jmp    80102702 <skipelem+0xc>
    path++;
801026fe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102702:	8b 45 08             	mov    0x8(%ebp),%eax
80102705:	0f b6 00             	movzbl (%eax),%eax
80102708:	3c 2f                	cmp    $0x2f,%al
8010270a:	74 f2                	je     801026fe <skipelem+0x8>
    path++;
  if(*path == 0)
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	0f b6 00             	movzbl (%eax),%eax
80102712:	84 c0                	test   %al,%al
80102714:	75 07                	jne    8010271d <skipelem+0x27>
    return 0;
80102716:	b8 00 00 00 00       	mov    $0x0,%eax
8010271b:	eb 7b                	jmp    80102798 <skipelem+0xa2>
  s = path;
8010271d:	8b 45 08             	mov    0x8(%ebp),%eax
80102720:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102723:	eb 04                	jmp    80102729 <skipelem+0x33>
    path++;
80102725:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	0f b6 00             	movzbl (%eax),%eax
8010272f:	3c 2f                	cmp    $0x2f,%al
80102731:	74 0a                	je     8010273d <skipelem+0x47>
80102733:	8b 45 08             	mov    0x8(%ebp),%eax
80102736:	0f b6 00             	movzbl (%eax),%eax
80102739:	84 c0                	test   %al,%al
8010273b:	75 e8                	jne    80102725 <skipelem+0x2f>
    path++;
  len = path - s;
8010273d:	8b 55 08             	mov    0x8(%ebp),%edx
80102740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102743:	29 c2                	sub    %eax,%edx
80102745:	89 d0                	mov    %edx,%eax
80102747:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010274a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010274e:	7e 15                	jle    80102765 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102750:	83 ec 04             	sub    $0x4,%esp
80102753:	6a 0e                	push   $0xe
80102755:	ff 75 f4             	pushl  -0xc(%ebp)
80102758:	ff 75 0c             	pushl  0xc(%ebp)
8010275b:	e8 29 39 00 00       	call   80106089 <memmove>
80102760:	83 c4 10             	add    $0x10,%esp
80102763:	eb 26                	jmp    8010278b <skipelem+0x95>
  else {
    memmove(name, s, len);
80102765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102768:	83 ec 04             	sub    $0x4,%esp
8010276b:	50                   	push   %eax
8010276c:	ff 75 f4             	pushl  -0xc(%ebp)
8010276f:	ff 75 0c             	pushl  0xc(%ebp)
80102772:	e8 12 39 00 00       	call   80106089 <memmove>
80102777:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010277a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010277d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102780:	01 d0                	add    %edx,%eax
80102782:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102785:	eb 04                	jmp    8010278b <skipelem+0x95>
    path++;
80102787:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010278b:	8b 45 08             	mov    0x8(%ebp),%eax
8010278e:	0f b6 00             	movzbl (%eax),%eax
80102791:	3c 2f                	cmp    $0x2f,%al
80102793:	74 f2                	je     80102787 <skipelem+0x91>
    path++;
  return path;
80102795:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102798:	c9                   	leave  
80102799:	c3                   	ret    

8010279a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010279a:	55                   	push   %ebp
8010279b:	89 e5                	mov    %esp,%ebp
8010279d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801027a0:	8b 45 08             	mov    0x8(%ebp),%eax
801027a3:	0f b6 00             	movzbl (%eax),%eax
801027a6:	3c 2f                	cmp    $0x2f,%al
801027a8:	75 17                	jne    801027c1 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801027aa:	83 ec 08             	sub    $0x8,%esp
801027ad:	6a 01                	push   $0x1
801027af:	6a 01                	push   $0x1
801027b1:	e8 2d f4 ff ff       	call   80101be3 <iget>
801027b6:	83 c4 10             	add    $0x10,%esp
801027b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027bc:	e9 bb 00 00 00       	jmp    8010287c <namex+0xe2>
  else
    ip = idup(proc->cwd);
801027c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801027c7:	8b 40 68             	mov    0x68(%eax),%eax
801027ca:	83 ec 0c             	sub    $0xc,%esp
801027cd:	50                   	push   %eax
801027ce:	e8 ef f4 ff ff       	call   80101cc2 <idup>
801027d3:	83 c4 10             	add    $0x10,%esp
801027d6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801027d9:	e9 9e 00 00 00       	jmp    8010287c <namex+0xe2>
    ilock(ip);
801027de:	83 ec 0c             	sub    $0xc,%esp
801027e1:	ff 75 f4             	pushl  -0xc(%ebp)
801027e4:	e8 13 f5 ff ff       	call   80101cfc <ilock>
801027e9:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801027ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ef:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801027f3:	66 83 f8 01          	cmp    $0x1,%ax
801027f7:	74 18                	je     80102811 <namex+0x77>
      iunlockput(ip);
801027f9:	83 ec 0c             	sub    $0xc,%esp
801027fc:	ff 75 f4             	pushl  -0xc(%ebp)
801027ff:	e8 b8 f7 ff ff       	call   80101fbc <iunlockput>
80102804:	83 c4 10             	add    $0x10,%esp
      return 0;
80102807:	b8 00 00 00 00       	mov    $0x0,%eax
8010280c:	e9 a7 00 00 00       	jmp    801028b8 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102811:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102815:	74 20                	je     80102837 <namex+0x9d>
80102817:	8b 45 08             	mov    0x8(%ebp),%eax
8010281a:	0f b6 00             	movzbl (%eax),%eax
8010281d:	84 c0                	test   %al,%al
8010281f:	75 16                	jne    80102837 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102821:	83 ec 0c             	sub    $0xc,%esp
80102824:	ff 75 f4             	pushl  -0xc(%ebp)
80102827:	e8 2e f6 ff ff       	call   80101e5a <iunlock>
8010282c:	83 c4 10             	add    $0x10,%esp
      return ip;
8010282f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102832:	e9 81 00 00 00       	jmp    801028b8 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102837:	83 ec 04             	sub    $0x4,%esp
8010283a:	6a 00                	push   $0x0
8010283c:	ff 75 10             	pushl  0x10(%ebp)
8010283f:	ff 75 f4             	pushl  -0xc(%ebp)
80102842:	e8 1d fd ff ff       	call   80102564 <dirlookup>
80102847:	83 c4 10             	add    $0x10,%esp
8010284a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010284d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102851:	75 15                	jne    80102868 <namex+0xce>
      iunlockput(ip);
80102853:	83 ec 0c             	sub    $0xc,%esp
80102856:	ff 75 f4             	pushl  -0xc(%ebp)
80102859:	e8 5e f7 ff ff       	call   80101fbc <iunlockput>
8010285e:	83 c4 10             	add    $0x10,%esp
      return 0;
80102861:	b8 00 00 00 00       	mov    $0x0,%eax
80102866:	eb 50                	jmp    801028b8 <namex+0x11e>
    }
    iunlockput(ip);
80102868:	83 ec 0c             	sub    $0xc,%esp
8010286b:	ff 75 f4             	pushl  -0xc(%ebp)
8010286e:	e8 49 f7 ff ff       	call   80101fbc <iunlockput>
80102873:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102876:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102879:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010287c:	83 ec 08             	sub    $0x8,%esp
8010287f:	ff 75 10             	pushl  0x10(%ebp)
80102882:	ff 75 08             	pushl  0x8(%ebp)
80102885:	e8 6c fe ff ff       	call   801026f6 <skipelem>
8010288a:	83 c4 10             	add    $0x10,%esp
8010288d:	89 45 08             	mov    %eax,0x8(%ebp)
80102890:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102894:	0f 85 44 ff ff ff    	jne    801027de <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010289a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010289e:	74 15                	je     801028b5 <namex+0x11b>
    iput(ip);
801028a0:	83 ec 0c             	sub    $0xc,%esp
801028a3:	ff 75 f4             	pushl  -0xc(%ebp)
801028a6:	e8 21 f6 ff ff       	call   80101ecc <iput>
801028ab:	83 c4 10             	add    $0x10,%esp
    return 0;
801028ae:	b8 00 00 00 00       	mov    $0x0,%eax
801028b3:	eb 03                	jmp    801028b8 <namex+0x11e>
  }
  return ip;
801028b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801028b8:	c9                   	leave  
801028b9:	c3                   	ret    

801028ba <namei>:

struct inode*
namei(char *path)
{
801028ba:	55                   	push   %ebp
801028bb:	89 e5                	mov    %esp,%ebp
801028bd:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801028c0:	83 ec 04             	sub    $0x4,%esp
801028c3:	8d 45 ea             	lea    -0x16(%ebp),%eax
801028c6:	50                   	push   %eax
801028c7:	6a 00                	push   $0x0
801028c9:	ff 75 08             	pushl  0x8(%ebp)
801028cc:	e8 c9 fe ff ff       	call   8010279a <namex>
801028d1:	83 c4 10             	add    $0x10,%esp
}
801028d4:	c9                   	leave  
801028d5:	c3                   	ret    

801028d6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801028d6:	55                   	push   %ebp
801028d7:	89 e5                	mov    %esp,%ebp
801028d9:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801028dc:	83 ec 04             	sub    $0x4,%esp
801028df:	ff 75 0c             	pushl  0xc(%ebp)
801028e2:	6a 01                	push   $0x1
801028e4:	ff 75 08             	pushl  0x8(%ebp)
801028e7:	e8 ae fe ff ff       	call   8010279a <namex>
801028ec:	83 c4 10             	add    $0x10,%esp
}
801028ef:	c9                   	leave  
801028f0:	c3                   	ret    

801028f1 <itoa>:

#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
801028f1:	55                   	push   %ebp
801028f2:	89 e5                	mov    %esp,%ebp
801028f4:	83 ec 20             	sub    $0x20,%esp
    char const digit[] = "0123456789";
801028f7:	c7 45 ed 30 31 32 33 	movl   $0x33323130,-0x13(%ebp)
801028fe:	c7 45 f1 34 35 36 37 	movl   $0x37363534,-0xf(%ebp)
80102905:	66 c7 45 f5 38 39    	movw   $0x3938,-0xb(%ebp)
8010290b:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
    char* p = b;
8010290f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102912:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if(i<0){
80102915:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102919:	79 0f                	jns    8010292a <itoa+0x39>
        *p++ = '-';
8010291b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010291e:	8d 50 01             	lea    0x1(%eax),%edx
80102921:	89 55 fc             	mov    %edx,-0x4(%ebp)
80102924:	c6 00 2d             	movb   $0x2d,(%eax)
        i *= -1;
80102927:	f7 5d 08             	negl   0x8(%ebp)
    }
    int shifter = i;
8010292a:	8b 45 08             	mov    0x8(%ebp),%eax
8010292d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    do{ //Move to where representation ends
        ++p;
80102930:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
        shifter = shifter/10;
80102934:	8b 4d f8             	mov    -0x8(%ebp),%ecx
80102937:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010293c:	89 c8                	mov    %ecx,%eax
8010293e:	f7 ea                	imul   %edx
80102940:	c1 fa 02             	sar    $0x2,%edx
80102943:	89 c8                	mov    %ecx,%eax
80102945:	c1 f8 1f             	sar    $0x1f,%eax
80102948:	29 c2                	sub    %eax,%edx
8010294a:	89 d0                	mov    %edx,%eax
8010294c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    }while(shifter);
8010294f:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
80102953:	75 db                	jne    80102930 <itoa+0x3f>
    *p = '\0';
80102955:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102958:	c6 00 00             	movb   $0x0,(%eax)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
8010295b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010295f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102962:	ba 67 66 66 66       	mov    $0x66666667,%edx
80102967:	89 c8                	mov    %ecx,%eax
80102969:	f7 ea                	imul   %edx
8010296b:	c1 fa 02             	sar    $0x2,%edx
8010296e:	89 c8                	mov    %ecx,%eax
80102970:	c1 f8 1f             	sar    $0x1f,%eax
80102973:	29 c2                	sub    %eax,%edx
80102975:	89 d0                	mov    %edx,%eax
80102977:	c1 e0 02             	shl    $0x2,%eax
8010297a:	01 d0                	add    %edx,%eax
8010297c:	01 c0                	add    %eax,%eax
8010297e:	29 c1                	sub    %eax,%ecx
80102980:	89 ca                	mov    %ecx,%edx
80102982:	0f b6 54 15 ed       	movzbl -0x13(%ebp,%edx,1),%edx
80102987:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010298a:	88 10                	mov    %dl,(%eax)
        i = i/10;
8010298c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010298f:	ba 67 66 66 66       	mov    $0x66666667,%edx
80102994:	89 c8                	mov    %ecx,%eax
80102996:	f7 ea                	imul   %edx
80102998:	c1 fa 02             	sar    $0x2,%edx
8010299b:	89 c8                	mov    %ecx,%eax
8010299d:	c1 f8 1f             	sar    $0x1f,%eax
801029a0:	29 c2                	sub    %eax,%edx
801029a2:	89 d0                	mov    %edx,%eax
801029a4:	89 45 08             	mov    %eax,0x8(%ebp)
    }while(i);
801029a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801029ab:	75 ae                	jne    8010295b <itoa+0x6a>
    return b;
801029ad:	8b 45 0c             	mov    0xc(%ebp),%eax
}
801029b0:	c9                   	leave  
801029b1:	c3                   	ret    

801029b2 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
801029b2:	55                   	push   %ebp
801029b3:	89 e5                	mov    %esp,%ebp
801029b5:	83 ec 48             	sub    $0x48,%esp
	//path of proccess
	char path[DIGITS];
	memmove(path,"/.swap", 6);
801029b8:	83 ec 04             	sub    $0x4,%esp
801029bb:	6a 06                	push   $0x6
801029bd:	68 1e 9f 10 80       	push   $0x80109f1e
801029c2:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801029c5:	50                   	push   %eax
801029c6:	e8 be 36 00 00       	call   80106089 <memmove>
801029cb:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
801029ce:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801029d1:	83 c0 06             	add    $0x6,%eax
801029d4:	8b 55 08             	mov    0x8(%ebp),%edx
801029d7:	8b 52 10             	mov    0x10(%edx),%edx
801029da:	83 ec 08             	sub    $0x8,%esp
801029dd:	50                   	push   %eax
801029de:	52                   	push   %edx
801029df:	e8 0d ff ff ff       	call   801028f1 <itoa>
801029e4:	83 c4 10             	add    $0x10,%esp
	struct inode *ip, *dp;
	struct dirent de;
	char name[DIRSIZ];
	uint off;

	if(0 == p->swapFile)
801029e7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ea:	8b 40 7c             	mov    0x7c(%eax),%eax
801029ed:	85 c0                	test   %eax,%eax
801029ef:	75 0a                	jne    801029fb <removeSwapFile+0x49>
	{
		return -1;
801029f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801029f6:	e9 ce 01 00 00       	jmp    80102bc9 <removeSwapFile+0x217>
	}
	fileclose(p->swapFile);
801029fb:	8b 45 08             	mov    0x8(%ebp),%eax
801029fe:	8b 40 7c             	mov    0x7c(%eax),%eax
80102a01:	83 ec 0c             	sub    $0xc,%esp
80102a04:	50                   	push   %eax
80102a05:	e8 d9 e9 ff ff       	call   801013e3 <fileclose>
80102a0a:	83 c4 10             	add    $0x10,%esp

	begin_op();
80102a0d:	e8 31 13 00 00       	call   80103d43 <begin_op>
	if((dp = nameiparent(path, name)) == 0)
80102a12:	83 ec 08             	sub    $0x8,%esp
80102a15:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102a18:	50                   	push   %eax
80102a19:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102a1c:	50                   	push   %eax
80102a1d:	e8 b4 fe ff ff       	call   801028d6 <nameiparent>
80102a22:	83 c4 10             	add    $0x10,%esp
80102a25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a2c:	75 0f                	jne    80102a3d <removeSwapFile+0x8b>
	{
		end_op();
80102a2e:	e8 9c 13 00 00       	call   80103dcf <end_op>
		return -1;
80102a33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a38:	e9 8c 01 00 00       	jmp    80102bc9 <removeSwapFile+0x217>
	}

	ilock(dp);
80102a3d:	83 ec 0c             	sub    $0xc,%esp
80102a40:	ff 75 f4             	pushl  -0xc(%ebp)
80102a43:	e8 b4 f2 ff ff       	call   80101cfc <ilock>
80102a48:	83 c4 10             	add    $0x10,%esp

	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80102a4b:	83 ec 08             	sub    $0x8,%esp
80102a4e:	68 25 9f 10 80       	push   $0x80109f25
80102a53:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102a56:	50                   	push   %eax
80102a57:	e8 ed fa ff ff       	call   80102549 <namecmp>
80102a5c:	83 c4 10             	add    $0x10,%esp
80102a5f:	85 c0                	test   %eax,%eax
80102a61:	0f 84 4a 01 00 00    	je     80102bb1 <removeSwapFile+0x1ff>
80102a67:	83 ec 08             	sub    $0x8,%esp
80102a6a:	68 27 9f 10 80       	push   $0x80109f27
80102a6f:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102a72:	50                   	push   %eax
80102a73:	e8 d1 fa ff ff       	call   80102549 <namecmp>
80102a78:	83 c4 10             	add    $0x10,%esp
80102a7b:	85 c0                	test   %eax,%eax
80102a7d:	0f 84 2e 01 00 00    	je     80102bb1 <removeSwapFile+0x1ff>
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
80102a83:	83 ec 04             	sub    $0x4,%esp
80102a86:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102a89:	50                   	push   %eax
80102a8a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102a8d:	50                   	push   %eax
80102a8e:	ff 75 f4             	pushl  -0xc(%ebp)
80102a91:	e8 ce fa ff ff       	call   80102564 <dirlookup>
80102a96:	83 c4 10             	add    $0x10,%esp
80102a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102a9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102aa0:	0f 84 0a 01 00 00    	je     80102bb0 <removeSwapFile+0x1fe>
		goto bad;
	ilock(ip);
80102aa6:	83 ec 0c             	sub    $0xc,%esp
80102aa9:	ff 75 f0             	pushl  -0x10(%ebp)
80102aac:	e8 4b f2 ff ff       	call   80101cfc <ilock>
80102ab1:	83 c4 10             	add    $0x10,%esp

	if(ip->nlink < 1)
80102ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ab7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102abb:	66 85 c0             	test   %ax,%ax
80102abe:	7f 0d                	jg     80102acd <removeSwapFile+0x11b>
		panic("unlink: nlink < 1");
80102ac0:	83 ec 0c             	sub    $0xc,%esp
80102ac3:	68 2a 9f 10 80       	push   $0x80109f2a
80102ac8:	e8 99 da ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR && !isdirempty(ip)){
80102acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ad0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102ad4:	66 83 f8 01          	cmp    $0x1,%ax
80102ad8:	75 25                	jne    80102aff <removeSwapFile+0x14d>
80102ada:	83 ec 0c             	sub    $0xc,%esp
80102add:	ff 75 f0             	pushl  -0x10(%ebp)
80102ae0:	e8 78 3d 00 00       	call   8010685d <isdirempty>
80102ae5:	83 c4 10             	add    $0x10,%esp
80102ae8:	85 c0                	test   %eax,%eax
80102aea:	75 13                	jne    80102aff <removeSwapFile+0x14d>
		iunlockput(ip);
80102aec:	83 ec 0c             	sub    $0xc,%esp
80102aef:	ff 75 f0             	pushl  -0x10(%ebp)
80102af2:	e8 c5 f4 ff ff       	call   80101fbc <iunlockput>
80102af7:	83 c4 10             	add    $0x10,%esp
		goto bad;
80102afa:	e9 b2 00 00 00       	jmp    80102bb1 <removeSwapFile+0x1ff>
	}

	memset(&de, 0, sizeof(de));
80102aff:	83 ec 04             	sub    $0x4,%esp
80102b02:	6a 10                	push   $0x10
80102b04:	6a 00                	push   $0x0
80102b06:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102b09:	50                   	push   %eax
80102b0a:	e8 bb 34 00 00       	call   80105fca <memset>
80102b0f:	83 c4 10             	add    $0x10,%esp
	if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102b12:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102b15:	6a 10                	push   $0x10
80102b17:	50                   	push   %eax
80102b18:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102b1b:	50                   	push   %eax
80102b1c:	ff 75 f4             	pushl  -0xc(%ebp)
80102b1f:	e8 9d f8 ff ff       	call   801023c1 <writei>
80102b24:	83 c4 10             	add    $0x10,%esp
80102b27:	83 f8 10             	cmp    $0x10,%eax
80102b2a:	74 0d                	je     80102b39 <removeSwapFile+0x187>
		panic("unlink: writei");
80102b2c:	83 ec 0c             	sub    $0xc,%esp
80102b2f:	68 3c 9f 10 80       	push   $0x80109f3c
80102b34:	e8 2d da ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR){
80102b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b3c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102b40:	66 83 f8 01          	cmp    $0x1,%ax
80102b44:	75 21                	jne    80102b67 <removeSwapFile+0x1b5>
		dp->nlink--;
80102b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b49:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102b4d:	83 e8 01             	sub    $0x1,%eax
80102b50:	89 c2                	mov    %eax,%edx
80102b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b55:	66 89 50 16          	mov    %dx,0x16(%eax)
		iupdate(dp);
80102b59:	83 ec 0c             	sub    $0xc,%esp
80102b5c:	ff 75 f4             	pushl  -0xc(%ebp)
80102b5f:	e8 be ef ff ff       	call   80101b22 <iupdate>
80102b64:	83 c4 10             	add    $0x10,%esp
	}
	iunlockput(dp);
80102b67:	83 ec 0c             	sub    $0xc,%esp
80102b6a:	ff 75 f4             	pushl  -0xc(%ebp)
80102b6d:	e8 4a f4 ff ff       	call   80101fbc <iunlockput>
80102b72:	83 c4 10             	add    $0x10,%esp

	ip->nlink--;
80102b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b78:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102b7c:	83 e8 01             	sub    $0x1,%eax
80102b7f:	89 c2                	mov    %eax,%edx
80102b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b84:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
80102b88:	83 ec 0c             	sub    $0xc,%esp
80102b8b:	ff 75 f0             	pushl  -0x10(%ebp)
80102b8e:	e8 8f ef ff ff       	call   80101b22 <iupdate>
80102b93:	83 c4 10             	add    $0x10,%esp
	iunlockput(ip);
80102b96:	83 ec 0c             	sub    $0xc,%esp
80102b99:	ff 75 f0             	pushl  -0x10(%ebp)
80102b9c:	e8 1b f4 ff ff       	call   80101fbc <iunlockput>
80102ba1:	83 c4 10             	add    $0x10,%esp

	end_op();
80102ba4:	e8 26 12 00 00       	call   80103dcf <end_op>

	return 0;
80102ba9:	b8 00 00 00 00       	mov    $0x0,%eax
80102bae:	eb 19                	jmp    80102bc9 <removeSwapFile+0x217>
	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
		goto bad;
80102bb0:	90                   	nop
	end_op();

	return 0;

	bad:
		iunlockput(dp);
80102bb1:	83 ec 0c             	sub    $0xc,%esp
80102bb4:	ff 75 f4             	pushl  -0xc(%ebp)
80102bb7:	e8 00 f4 ff ff       	call   80101fbc <iunlockput>
80102bbc:	83 c4 10             	add    $0x10,%esp
		end_op();
80102bbf:	e8 0b 12 00 00       	call   80103dcf <end_op>
		return -1;
80102bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
80102bc9:	c9                   	leave  
80102bca:	c3                   	ret    

80102bcb <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
80102bcb:	55                   	push   %ebp
80102bcc:	89 e5                	mov    %esp,%ebp
80102bce:	83 ec 28             	sub    $0x28,%esp

	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102bd1:	83 ec 04             	sub    $0x4,%esp
80102bd4:	6a 06                	push   $0x6
80102bd6:	68 1e 9f 10 80       	push   $0x80109f1e
80102bdb:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102bde:	50                   	push   %eax
80102bdf:	e8 a5 34 00 00       	call   80106089 <memmove>
80102be4:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102be7:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102bea:	83 c0 06             	add    $0x6,%eax
80102bed:	8b 55 08             	mov    0x8(%ebp),%edx
80102bf0:	8b 52 10             	mov    0x10(%edx),%edx
80102bf3:	83 ec 08             	sub    $0x8,%esp
80102bf6:	50                   	push   %eax
80102bf7:	52                   	push   %edx
80102bf8:	e8 f4 fc ff ff       	call   801028f1 <itoa>
80102bfd:	83 c4 10             	add    $0x10,%esp

    begin_op();
80102c00:	e8 3e 11 00 00       	call   80103d43 <begin_op>
    struct inode * in = create(path, T_FILE, 0, 0);
80102c05:	6a 00                	push   $0x0
80102c07:	6a 00                	push   $0x0
80102c09:	6a 02                	push   $0x2
80102c0b:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102c0e:	50                   	push   %eax
80102c0f:	e8 8f 3e 00 00       	call   80106aa3 <create>
80102c14:	83 c4 10             	add    $0x10,%esp
80102c17:	89 45 f4             	mov    %eax,-0xc(%ebp)
	iunlock(in);
80102c1a:	83 ec 0c             	sub    $0xc,%esp
80102c1d:	ff 75 f4             	pushl  -0xc(%ebp)
80102c20:	e8 35 f2 ff ff       	call   80101e5a <iunlock>
80102c25:	83 c4 10             	add    $0x10,%esp

	p->swapFile = filealloc();
80102c28:	e8 f8 e6 ff ff       	call   80101325 <filealloc>
80102c2d:	89 c2                	mov    %eax,%edx
80102c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c32:	89 50 7c             	mov    %edx,0x7c(%eax)
	if (p->swapFile == 0)
80102c35:	8b 45 08             	mov    0x8(%ebp),%eax
80102c38:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c3b:	85 c0                	test   %eax,%eax
80102c3d:	75 0d                	jne    80102c4c <createSwapFile+0x81>
		panic("no slot for files on /store");
80102c3f:	83 ec 0c             	sub    $0xc,%esp
80102c42:	68 4b 9f 10 80       	push   $0x80109f4b
80102c47:	e8 1a d9 ff ff       	call   80100566 <panic>

	p->swapFile->ip = in;
80102c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c4f:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c55:	89 50 10             	mov    %edx,0x10(%eax)
	p->swapFile->type = FD_INODE;
80102c58:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5b:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c5e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
	p->swapFile->off = 0;
80102c64:	8b 45 08             	mov    0x8(%ebp),%eax
80102c67:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c6a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	p->swapFile->readable = O_WRONLY;
80102c71:	8b 45 08             	mov    0x8(%ebp),%eax
80102c74:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c77:	c6 40 08 01          	movb   $0x1,0x8(%eax)
	p->swapFile->writable = O_RDWR;
80102c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7e:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c81:	c6 40 09 02          	movb   $0x2,0x9(%eax)
    end_op();
80102c85:	e8 45 11 00 00       	call   80103dcf <end_op>

    return 0;
80102c8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102c8f:	c9                   	leave  
80102c90:	c3                   	ret    

80102c91 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102c91:	55                   	push   %ebp
80102c92:	89 e5                	mov    %esp,%ebp
80102c94:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102c97:	8b 45 08             	mov    0x8(%ebp),%eax
80102c9a:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c9d:	8b 55 10             	mov    0x10(%ebp),%edx
80102ca0:	89 50 14             	mov    %edx,0x14(%eax)

	return filewrite(p->swapFile, buffer, size);
80102ca3:	8b 55 14             	mov    0x14(%ebp),%edx
80102ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca9:	8b 40 7c             	mov    0x7c(%eax),%eax
80102cac:	83 ec 04             	sub    $0x4,%esp
80102caf:	52                   	push   %edx
80102cb0:	ff 75 0c             	pushl  0xc(%ebp)
80102cb3:	50                   	push   %eax
80102cb4:	e8 21 e9 ff ff       	call   801015da <filewrite>
80102cb9:	83 c4 10             	add    $0x10,%esp

}
80102cbc:	c9                   	leave  
80102cbd:	c3                   	ret    

80102cbe <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102cbe:	55                   	push   %ebp
80102cbf:	89 e5                	mov    %esp,%ebp
80102cc1:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc7:	8b 40 7c             	mov    0x7c(%eax),%eax
80102cca:	8b 55 10             	mov    0x10(%ebp),%edx
80102ccd:	89 50 14             	mov    %edx,0x14(%eax)

	return fileread(p->swapFile, buffer,  size);
80102cd0:	8b 55 14             	mov    0x14(%ebp),%edx
80102cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd6:	8b 40 7c             	mov    0x7c(%eax),%eax
80102cd9:	83 ec 04             	sub    $0x4,%esp
80102cdc:	52                   	push   %edx
80102cdd:	ff 75 0c             	pushl  0xc(%ebp)
80102ce0:	50                   	push   %eax
80102ce1:	e8 3c e8 ff ff       	call   80101522 <fileread>
80102ce6:	83 c4 10             	add    $0x10,%esp
}
80102ce9:	c9                   	leave  
80102cea:	c3                   	ret    

80102ceb <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ceb:	55                   	push   %ebp
80102cec:	89 e5                	mov    %esp,%ebp
80102cee:	83 ec 14             	sub    $0x14,%esp
80102cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cfc:	89 c2                	mov    %eax,%edx
80102cfe:	ec                   	in     (%dx),%al
80102cff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d02:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d06:	c9                   	leave  
80102d07:	c3                   	ret    

80102d08 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102d08:	55                   	push   %ebp
80102d09:	89 e5                	mov    %esp,%ebp
80102d0b:	57                   	push   %edi
80102d0c:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102d0d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d13:	8b 45 10             	mov    0x10(%ebp),%eax
80102d16:	89 cb                	mov    %ecx,%ebx
80102d18:	89 df                	mov    %ebx,%edi
80102d1a:	89 c1                	mov    %eax,%ecx
80102d1c:	fc                   	cld    
80102d1d:	f3 6d                	rep insl (%dx),%es:(%edi)
80102d1f:	89 c8                	mov    %ecx,%eax
80102d21:	89 fb                	mov    %edi,%ebx
80102d23:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d26:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102d29:	90                   	nop
80102d2a:	5b                   	pop    %ebx
80102d2b:	5f                   	pop    %edi
80102d2c:	5d                   	pop    %ebp
80102d2d:	c3                   	ret    

80102d2e <outb>:

static inline void
outb(ushort port, uchar data)
{
80102d2e:	55                   	push   %ebp
80102d2f:	89 e5                	mov    %esp,%ebp
80102d31:	83 ec 08             	sub    $0x8,%esp
80102d34:	8b 55 08             	mov    0x8(%ebp),%edx
80102d37:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d3a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d3e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d41:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d45:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d49:	ee                   	out    %al,(%dx)
}
80102d4a:	90                   	nop
80102d4b:	c9                   	leave  
80102d4c:	c3                   	ret    

80102d4d <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102d4d:	55                   	push   %ebp
80102d4e:	89 e5                	mov    %esp,%ebp
80102d50:	56                   	push   %esi
80102d51:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102d52:	8b 55 08             	mov    0x8(%ebp),%edx
80102d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d58:	8b 45 10             	mov    0x10(%ebp),%eax
80102d5b:	89 cb                	mov    %ecx,%ebx
80102d5d:	89 de                	mov    %ebx,%esi
80102d5f:	89 c1                	mov    %eax,%ecx
80102d61:	fc                   	cld    
80102d62:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102d64:	89 c8                	mov    %ecx,%eax
80102d66:	89 f3                	mov    %esi,%ebx
80102d68:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d6b:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102d6e:	90                   	nop
80102d6f:	5b                   	pop    %ebx
80102d70:	5e                   	pop    %esi
80102d71:	5d                   	pop    %ebp
80102d72:	c3                   	ret    

80102d73 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102d73:	55                   	push   %ebp
80102d74:	89 e5                	mov    %esp,%ebp
80102d76:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102d79:	90                   	nop
80102d7a:	68 f7 01 00 00       	push   $0x1f7
80102d7f:	e8 67 ff ff ff       	call   80102ceb <inb>
80102d84:	83 c4 04             	add    $0x4,%esp
80102d87:	0f b6 c0             	movzbl %al,%eax
80102d8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102d8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d90:	25 c0 00 00 00       	and    $0xc0,%eax
80102d95:	83 f8 40             	cmp    $0x40,%eax
80102d98:	75 e0                	jne    80102d7a <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102d9a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102d9e:	74 11                	je     80102db1 <idewait+0x3e>
80102da0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da3:	83 e0 21             	and    $0x21,%eax
80102da6:	85 c0                	test   %eax,%eax
80102da8:	74 07                	je     80102db1 <idewait+0x3e>
    return -1;
80102daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102daf:	eb 05                	jmp    80102db6 <idewait+0x43>
  return 0;
80102db1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102db6:	c9                   	leave  
80102db7:	c3                   	ret    

80102db8 <ideinit>:

void
ideinit(void)
{
80102db8:	55                   	push   %ebp
80102db9:	89 e5                	mov    %esp,%ebp
80102dbb:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102dbe:	83 ec 08             	sub    $0x8,%esp
80102dc1:	68 67 9f 10 80       	push   $0x80109f67
80102dc6:	68 00 d6 10 80       	push   $0x8010d600
80102dcb:	e8 75 2f 00 00       	call   80105d45 <initlock>
80102dd0:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102dd3:	83 ec 0c             	sub    $0xc,%esp
80102dd6:	6a 0e                	push   $0xe
80102dd8:	e8 44 19 00 00       	call   80104721 <picenable>
80102ddd:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102de0:	a1 60 49 11 80       	mov    0x80114960,%eax
80102de5:	83 e8 01             	sub    $0x1,%eax
80102de8:	83 ec 08             	sub    $0x8,%esp
80102deb:	50                   	push   %eax
80102dec:	6a 0e                	push   $0xe
80102dee:	e8 73 04 00 00       	call   80103266 <ioapicenable>
80102df3:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102df6:	83 ec 0c             	sub    $0xc,%esp
80102df9:	6a 00                	push   $0x0
80102dfb:	e8 73 ff ff ff       	call   80102d73 <idewait>
80102e00:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102e03:	83 ec 08             	sub    $0x8,%esp
80102e06:	68 f0 00 00 00       	push   $0xf0
80102e0b:	68 f6 01 00 00       	push   $0x1f6
80102e10:	e8 19 ff ff ff       	call   80102d2e <outb>
80102e15:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102e18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e1f:	eb 24                	jmp    80102e45 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102e21:	83 ec 0c             	sub    $0xc,%esp
80102e24:	68 f7 01 00 00       	push   $0x1f7
80102e29:	e8 bd fe ff ff       	call   80102ceb <inb>
80102e2e:	83 c4 10             	add    $0x10,%esp
80102e31:	84 c0                	test   %al,%al
80102e33:	74 0c                	je     80102e41 <ideinit+0x89>
      havedisk1 = 1;
80102e35:	c7 05 38 d6 10 80 01 	movl   $0x1,0x8010d638
80102e3c:	00 00 00 
      break;
80102e3f:	eb 0d                	jmp    80102e4e <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102e41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102e45:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102e4c:	7e d3                	jle    80102e21 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102e4e:	83 ec 08             	sub    $0x8,%esp
80102e51:	68 e0 00 00 00       	push   $0xe0
80102e56:	68 f6 01 00 00       	push   $0x1f6
80102e5b:	e8 ce fe ff ff       	call   80102d2e <outb>
80102e60:	83 c4 10             	add    $0x10,%esp
}
80102e63:	90                   	nop
80102e64:	c9                   	leave  
80102e65:	c3                   	ret    

80102e66 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102e66:	55                   	push   %ebp
80102e67:	89 e5                	mov    %esp,%ebp
80102e69:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102e6c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102e70:	75 0d                	jne    80102e7f <idestart+0x19>
    panic("idestart");
80102e72:	83 ec 0c             	sub    $0xc,%esp
80102e75:	68 6b 9f 10 80       	push   $0x80109f6b
80102e7a:	e8 e7 d6 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e82:	8b 40 08             	mov    0x8(%eax),%eax
80102e85:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102e8a:	76 0d                	jbe    80102e99 <idestart+0x33>
    panic("incorrect blockno");
80102e8c:	83 ec 0c             	sub    $0xc,%esp
80102e8f:	68 74 9f 10 80       	push   $0x80109f74
80102e94:	e8 cd d6 ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102e99:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ea3:	8b 50 08             	mov    0x8(%eax),%edx
80102ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea9:	0f af c2             	imul   %edx,%eax
80102eac:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102eaf:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102eb3:	7e 0d                	jle    80102ec2 <idestart+0x5c>
80102eb5:	83 ec 0c             	sub    $0xc,%esp
80102eb8:	68 6b 9f 10 80       	push   $0x80109f6b
80102ebd:	e8 a4 d6 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102ec2:	83 ec 0c             	sub    $0xc,%esp
80102ec5:	6a 00                	push   $0x0
80102ec7:	e8 a7 fe ff ff       	call   80102d73 <idewait>
80102ecc:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102ecf:	83 ec 08             	sub    $0x8,%esp
80102ed2:	6a 00                	push   $0x0
80102ed4:	68 f6 03 00 00       	push   $0x3f6
80102ed9:	e8 50 fe ff ff       	call   80102d2e <outb>
80102ede:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ee4:	0f b6 c0             	movzbl %al,%eax
80102ee7:	83 ec 08             	sub    $0x8,%esp
80102eea:	50                   	push   %eax
80102eeb:	68 f2 01 00 00       	push   $0x1f2
80102ef0:	e8 39 fe ff ff       	call   80102d2e <outb>
80102ef5:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102efb:	0f b6 c0             	movzbl %al,%eax
80102efe:	83 ec 08             	sub    $0x8,%esp
80102f01:	50                   	push   %eax
80102f02:	68 f3 01 00 00       	push   $0x1f3
80102f07:	e8 22 fe ff ff       	call   80102d2e <outb>
80102f0c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f12:	c1 f8 08             	sar    $0x8,%eax
80102f15:	0f b6 c0             	movzbl %al,%eax
80102f18:	83 ec 08             	sub    $0x8,%esp
80102f1b:	50                   	push   %eax
80102f1c:	68 f4 01 00 00       	push   $0x1f4
80102f21:	e8 08 fe ff ff       	call   80102d2e <outb>
80102f26:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f2c:	c1 f8 10             	sar    $0x10,%eax
80102f2f:	0f b6 c0             	movzbl %al,%eax
80102f32:	83 ec 08             	sub    $0x8,%esp
80102f35:	50                   	push   %eax
80102f36:	68 f5 01 00 00       	push   $0x1f5
80102f3b:	e8 ee fd ff ff       	call   80102d2e <outb>
80102f40:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102f43:	8b 45 08             	mov    0x8(%ebp),%eax
80102f46:	8b 40 04             	mov    0x4(%eax),%eax
80102f49:	83 e0 01             	and    $0x1,%eax
80102f4c:	c1 e0 04             	shl    $0x4,%eax
80102f4f:	89 c2                	mov    %eax,%edx
80102f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f54:	c1 f8 18             	sar    $0x18,%eax
80102f57:	83 e0 0f             	and    $0xf,%eax
80102f5a:	09 d0                	or     %edx,%eax
80102f5c:	83 c8 e0             	or     $0xffffffe0,%eax
80102f5f:	0f b6 c0             	movzbl %al,%eax
80102f62:	83 ec 08             	sub    $0x8,%esp
80102f65:	50                   	push   %eax
80102f66:	68 f6 01 00 00       	push   $0x1f6
80102f6b:	e8 be fd ff ff       	call   80102d2e <outb>
80102f70:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102f73:	8b 45 08             	mov    0x8(%ebp),%eax
80102f76:	8b 00                	mov    (%eax),%eax
80102f78:	83 e0 04             	and    $0x4,%eax
80102f7b:	85 c0                	test   %eax,%eax
80102f7d:	74 30                	je     80102faf <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102f7f:	83 ec 08             	sub    $0x8,%esp
80102f82:	6a 30                	push   $0x30
80102f84:	68 f7 01 00 00       	push   $0x1f7
80102f89:	e8 a0 fd ff ff       	call   80102d2e <outb>
80102f8e:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102f91:	8b 45 08             	mov    0x8(%ebp),%eax
80102f94:	83 c0 18             	add    $0x18,%eax
80102f97:	83 ec 04             	sub    $0x4,%esp
80102f9a:	68 80 00 00 00       	push   $0x80
80102f9f:	50                   	push   %eax
80102fa0:	68 f0 01 00 00       	push   $0x1f0
80102fa5:	e8 a3 fd ff ff       	call   80102d4d <outsl>
80102faa:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102fad:	eb 12                	jmp    80102fc1 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102faf:	83 ec 08             	sub    $0x8,%esp
80102fb2:	6a 20                	push   $0x20
80102fb4:	68 f7 01 00 00       	push   $0x1f7
80102fb9:	e8 70 fd ff ff       	call   80102d2e <outb>
80102fbe:	83 c4 10             	add    $0x10,%esp
  }
}
80102fc1:	90                   	nop
80102fc2:	c9                   	leave  
80102fc3:	c3                   	ret    

80102fc4 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102fc4:	55                   	push   %ebp
80102fc5:	89 e5                	mov    %esp,%ebp
80102fc7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102fca:	83 ec 0c             	sub    $0xc,%esp
80102fcd:	68 00 d6 10 80       	push   $0x8010d600
80102fd2:	e8 90 2d 00 00       	call   80105d67 <acquire>
80102fd7:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102fda:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102fdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102fe2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102fe6:	75 15                	jne    80102ffd <ideintr+0x39>
    release(&idelock);
80102fe8:	83 ec 0c             	sub    $0xc,%esp
80102feb:	68 00 d6 10 80       	push   $0x8010d600
80102ff0:	e8 d9 2d 00 00       	call   80105dce <release>
80102ff5:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102ff8:	e9 9a 00 00 00       	jmp    80103097 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103000:	8b 40 14             	mov    0x14(%eax),%eax
80103003:	a3 34 d6 10 80       	mov    %eax,0x8010d634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80103008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010300b:	8b 00                	mov    (%eax),%eax
8010300d:	83 e0 04             	and    $0x4,%eax
80103010:	85 c0                	test   %eax,%eax
80103012:	75 2d                	jne    80103041 <ideintr+0x7d>
80103014:	83 ec 0c             	sub    $0xc,%esp
80103017:	6a 01                	push   $0x1
80103019:	e8 55 fd ff ff       	call   80102d73 <idewait>
8010301e:	83 c4 10             	add    $0x10,%esp
80103021:	85 c0                	test   %eax,%eax
80103023:	78 1c                	js     80103041 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80103025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103028:	83 c0 18             	add    $0x18,%eax
8010302b:	83 ec 04             	sub    $0x4,%esp
8010302e:	68 80 00 00 00       	push   $0x80
80103033:	50                   	push   %eax
80103034:	68 f0 01 00 00       	push   $0x1f0
80103039:	e8 ca fc ff ff       	call   80102d08 <insl>
8010303e:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80103041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103044:	8b 00                	mov    (%eax),%eax
80103046:	83 c8 02             	or     $0x2,%eax
80103049:	89 c2                	mov    %eax,%edx
8010304b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010304e:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80103050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103053:	8b 00                	mov    (%eax),%eax
80103055:	83 e0 fb             	and    $0xfffffffb,%eax
80103058:	89 c2                	mov    %eax,%edx
8010305a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010305d:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010305f:	83 ec 0c             	sub    $0xc,%esp
80103062:	ff 75 f4             	pushl  -0xc(%ebp)
80103065:	e8 26 29 00 00       	call   80105990 <wakeup>
8010306a:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010306d:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80103072:	85 c0                	test   %eax,%eax
80103074:	74 11                	je     80103087 <ideintr+0xc3>
    idestart(idequeue);
80103076:	a1 34 d6 10 80       	mov    0x8010d634,%eax
8010307b:	83 ec 0c             	sub    $0xc,%esp
8010307e:	50                   	push   %eax
8010307f:	e8 e2 fd ff ff       	call   80102e66 <idestart>
80103084:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80103087:	83 ec 0c             	sub    $0xc,%esp
8010308a:	68 00 d6 10 80       	push   $0x8010d600
8010308f:	e8 3a 2d 00 00       	call   80105dce <release>
80103094:	83 c4 10             	add    $0x10,%esp
}
80103097:	c9                   	leave  
80103098:	c3                   	ret    

80103099 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103099:	55                   	push   %ebp
8010309a:	89 e5                	mov    %esp,%ebp
8010309c:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010309f:	8b 45 08             	mov    0x8(%ebp),%eax
801030a2:	8b 00                	mov    (%eax),%eax
801030a4:	83 e0 01             	and    $0x1,%eax
801030a7:	85 c0                	test   %eax,%eax
801030a9:	75 0d                	jne    801030b8 <iderw+0x1f>
    panic("iderw: buf not busy");
801030ab:	83 ec 0c             	sub    $0xc,%esp
801030ae:	68 86 9f 10 80       	push   $0x80109f86
801030b3:	e8 ae d4 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801030b8:	8b 45 08             	mov    0x8(%ebp),%eax
801030bb:	8b 00                	mov    (%eax),%eax
801030bd:	83 e0 06             	and    $0x6,%eax
801030c0:	83 f8 02             	cmp    $0x2,%eax
801030c3:	75 0d                	jne    801030d2 <iderw+0x39>
    panic("iderw: nothing to do");
801030c5:	83 ec 0c             	sub    $0xc,%esp
801030c8:	68 9a 9f 10 80       	push   $0x80109f9a
801030cd:	e8 94 d4 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801030d2:	8b 45 08             	mov    0x8(%ebp),%eax
801030d5:	8b 40 04             	mov    0x4(%eax),%eax
801030d8:	85 c0                	test   %eax,%eax
801030da:	74 16                	je     801030f2 <iderw+0x59>
801030dc:	a1 38 d6 10 80       	mov    0x8010d638,%eax
801030e1:	85 c0                	test   %eax,%eax
801030e3:	75 0d                	jne    801030f2 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801030e5:	83 ec 0c             	sub    $0xc,%esp
801030e8:	68 af 9f 10 80       	push   $0x80109faf
801030ed:	e8 74 d4 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801030f2:	83 ec 0c             	sub    $0xc,%esp
801030f5:	68 00 d6 10 80       	push   $0x8010d600
801030fa:	e8 68 2c 00 00       	call   80105d67 <acquire>
801030ff:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80103102:	8b 45 08             	mov    0x8(%ebp),%eax
80103105:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010310c:	c7 45 f4 34 d6 10 80 	movl   $0x8010d634,-0xc(%ebp)
80103113:	eb 0b                	jmp    80103120 <iderw+0x87>
80103115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103118:	8b 00                	mov    (%eax),%eax
8010311a:	83 c0 14             	add    $0x14,%eax
8010311d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103123:	8b 00                	mov    (%eax),%eax
80103125:	85 c0                	test   %eax,%eax
80103127:	75 ec                	jne    80103115 <iderw+0x7c>
    ;
  *pp = b;
80103129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010312c:	8b 55 08             	mov    0x8(%ebp),%edx
8010312f:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80103131:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80103136:	3b 45 08             	cmp    0x8(%ebp),%eax
80103139:	75 23                	jne    8010315e <iderw+0xc5>
    idestart(b);
8010313b:	83 ec 0c             	sub    $0xc,%esp
8010313e:	ff 75 08             	pushl  0x8(%ebp)
80103141:	e8 20 fd ff ff       	call   80102e66 <idestart>
80103146:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80103149:	eb 13                	jmp    8010315e <iderw+0xc5>
    sleep(b, &idelock);
8010314b:	83 ec 08             	sub    $0x8,%esp
8010314e:	68 00 d6 10 80       	push   $0x8010d600
80103153:	ff 75 08             	pushl  0x8(%ebp)
80103156:	e8 47 27 00 00       	call   801058a2 <sleep>
8010315b:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010315e:	8b 45 08             	mov    0x8(%ebp),%eax
80103161:	8b 00                	mov    (%eax),%eax
80103163:	83 e0 06             	and    $0x6,%eax
80103166:	83 f8 02             	cmp    $0x2,%eax
80103169:	75 e0                	jne    8010314b <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 00 d6 10 80       	push   $0x8010d600
80103173:	e8 56 2c 00 00       	call   80105dce <release>
80103178:	83 c4 10             	add    $0x10,%esp
}
8010317b:	90                   	nop
8010317c:	c9                   	leave  
8010317d:	c3                   	ret    

8010317e <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010317e:	55                   	push   %ebp
8010317f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103181:	a1 14 42 11 80       	mov    0x80114214,%eax
80103186:	8b 55 08             	mov    0x8(%ebp),%edx
80103189:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010318b:	a1 14 42 11 80       	mov    0x80114214,%eax
80103190:	8b 40 10             	mov    0x10(%eax),%eax
}
80103193:	5d                   	pop    %ebp
80103194:	c3                   	ret    

80103195 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80103195:	55                   	push   %ebp
80103196:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103198:	a1 14 42 11 80       	mov    0x80114214,%eax
8010319d:	8b 55 08             	mov    0x8(%ebp),%edx
801031a0:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801031a2:	a1 14 42 11 80       	mov    0x80114214,%eax
801031a7:	8b 55 0c             	mov    0xc(%ebp),%edx
801031aa:	89 50 10             	mov    %edx,0x10(%eax)
}
801031ad:	90                   	nop
801031ae:	5d                   	pop    %ebp
801031af:	c3                   	ret    

801031b0 <ioapicinit>:

void
ioapicinit(void)
{
801031b0:	55                   	push   %ebp
801031b1:	89 e5                	mov    %esp,%ebp
801031b3:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
801031b6:	a1 64 43 11 80       	mov    0x80114364,%eax
801031bb:	85 c0                	test   %eax,%eax
801031bd:	0f 84 a0 00 00 00    	je     80103263 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801031c3:	c7 05 14 42 11 80 00 	movl   $0xfec00000,0x80114214
801031ca:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801031cd:	6a 01                	push   $0x1
801031cf:	e8 aa ff ff ff       	call   8010317e <ioapicread>
801031d4:	83 c4 04             	add    $0x4,%esp
801031d7:	c1 e8 10             	shr    $0x10,%eax
801031da:	25 ff 00 00 00       	and    $0xff,%eax
801031df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801031e2:	6a 00                	push   $0x0
801031e4:	e8 95 ff ff ff       	call   8010317e <ioapicread>
801031e9:	83 c4 04             	add    $0x4,%esp
801031ec:	c1 e8 18             	shr    $0x18,%eax
801031ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801031f2:	0f b6 05 60 43 11 80 	movzbl 0x80114360,%eax
801031f9:	0f b6 c0             	movzbl %al,%eax
801031fc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801031ff:	74 10                	je     80103211 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80103201:	83 ec 0c             	sub    $0xc,%esp
80103204:	68 d0 9f 10 80       	push   $0x80109fd0
80103209:	e8 b8 d1 ff ff       	call   801003c6 <cprintf>
8010320e:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103211:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103218:	eb 3f                	jmp    80103259 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010321a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010321d:	83 c0 20             	add    $0x20,%eax
80103220:	0d 00 00 01 00       	or     $0x10000,%eax
80103225:	89 c2                	mov    %eax,%edx
80103227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010322a:	83 c0 08             	add    $0x8,%eax
8010322d:	01 c0                	add    %eax,%eax
8010322f:	83 ec 08             	sub    $0x8,%esp
80103232:	52                   	push   %edx
80103233:	50                   	push   %eax
80103234:	e8 5c ff ff ff       	call   80103195 <ioapicwrite>
80103239:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010323c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010323f:	83 c0 08             	add    $0x8,%eax
80103242:	01 c0                	add    %eax,%eax
80103244:	83 c0 01             	add    $0x1,%eax
80103247:	83 ec 08             	sub    $0x8,%esp
8010324a:	6a 00                	push   $0x0
8010324c:	50                   	push   %eax
8010324d:	e8 43 ff ff ff       	call   80103195 <ioapicwrite>
80103252:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103255:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010325c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010325f:	7e b9                	jle    8010321a <ioapicinit+0x6a>
80103261:	eb 01                	jmp    80103264 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80103263:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80103264:	c9                   	leave  
80103265:	c3                   	ret    

80103266 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80103266:	55                   	push   %ebp
80103267:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80103269:	a1 64 43 11 80       	mov    0x80114364,%eax
8010326e:	85 c0                	test   %eax,%eax
80103270:	74 39                	je     801032ab <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80103272:	8b 45 08             	mov    0x8(%ebp),%eax
80103275:	83 c0 20             	add    $0x20,%eax
80103278:	89 c2                	mov    %eax,%edx
8010327a:	8b 45 08             	mov    0x8(%ebp),%eax
8010327d:	83 c0 08             	add    $0x8,%eax
80103280:	01 c0                	add    %eax,%eax
80103282:	52                   	push   %edx
80103283:	50                   	push   %eax
80103284:	e8 0c ff ff ff       	call   80103195 <ioapicwrite>
80103289:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010328c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010328f:	c1 e0 18             	shl    $0x18,%eax
80103292:	89 c2                	mov    %eax,%edx
80103294:	8b 45 08             	mov    0x8(%ebp),%eax
80103297:	83 c0 08             	add    $0x8,%eax
8010329a:	01 c0                	add    %eax,%eax
8010329c:	83 c0 01             	add    $0x1,%eax
8010329f:	52                   	push   %edx
801032a0:	50                   	push   %eax
801032a1:	e8 ef fe ff ff       	call   80103195 <ioapicwrite>
801032a6:	83 c4 08             	add    $0x8,%esp
801032a9:	eb 01                	jmp    801032ac <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801032ab:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801032ac:	c9                   	leave  
801032ad:	c3                   	ret    

801032ae <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801032ae:	55                   	push   %ebp
801032af:	89 e5                	mov    %esp,%ebp
801032b1:	8b 45 08             	mov    0x8(%ebp),%eax
801032b4:	05 00 00 00 80       	add    $0x80000000,%eax
801032b9:	5d                   	pop    %ebp
801032ba:	c3                   	ret    

801032bb <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801032bb:	55                   	push   %ebp
801032bc:	89 e5                	mov    %esp,%ebp
801032be:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
801032c1:	83 ec 08             	sub    $0x8,%esp
801032c4:	68 02 a0 10 80       	push   $0x8010a002
801032c9:	68 20 42 11 80       	push   $0x80114220
801032ce:	e8 72 2a 00 00       	call   80105d45 <initlock>
801032d3:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801032d6:	c7 05 54 42 11 80 00 	movl   $0x0,0x80114254
801032dd:	00 00 00 
  freerange(vstart, vend);
801032e0:	83 ec 08             	sub    $0x8,%esp
801032e3:	ff 75 0c             	pushl  0xc(%ebp)
801032e6:	ff 75 08             	pushl  0x8(%ebp)
801032e9:	e8 7a 00 00 00       	call   80103368 <freerange>
801032ee:	83 c4 10             	add    $0x10,%esp

  //assignment3 
  //update the # of pages inserted to free list in kinit1
  physicalPageStatistic.numOfInitPages = (PGROUNDDOWN((uint)vend) - PGROUNDUP((uint)vstart))/PGSIZE;
801032f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801032f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801032f9:	89 c2                	mov    %eax,%edx
801032fb:	8b 45 08             	mov    0x8(%ebp),%eax
801032fe:	05 ff 0f 00 00       	add    $0xfff,%eax
80103303:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103308:	29 c2                	sub    %eax,%edx
8010330a:	89 d0                	mov    %edx,%eax
8010330c:	c1 e8 0c             	shr    $0xc,%eax
8010330f:	a3 5c 42 11 80       	mov    %eax,0x8011425c

// finish
}
80103314:	90                   	nop
80103315:	c9                   	leave  
80103316:	c3                   	ret    

80103317 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80103317:	55                   	push   %ebp
80103318:	89 e5                	mov    %esp,%ebp
8010331a:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
8010331d:	83 ec 08             	sub    $0x8,%esp
80103320:	ff 75 0c             	pushl  0xc(%ebp)
80103323:	ff 75 08             	pushl  0x8(%ebp)
80103326:	e8 3d 00 00 00       	call   80103368 <freerange>
8010332b:	83 c4 10             	add    $0x10,%esp
    // assignment3
    //update the # of pages inserted to free list in kinit2
    physicalPageStatistic.numOfInitPages += (PGROUNDDOWN((uint)vend) - PGROUNDUP((uint)vstart))/PGSIZE;
8010332e:	a1 5c 42 11 80       	mov    0x8011425c,%eax
80103333:	8b 55 0c             	mov    0xc(%ebp),%edx
80103336:	89 d1                	mov    %edx,%ecx
80103338:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
8010333e:	8b 55 08             	mov    0x8(%ebp),%edx
80103341:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
80103347:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010334d:	29 d1                	sub    %edx,%ecx
8010334f:	89 ca                	mov    %ecx,%edx
80103351:	c1 ea 0c             	shr    $0xc,%edx
80103354:	01 d0                	add    %edx,%eax
80103356:	a3 5c 42 11 80       	mov    %eax,0x8011425c
    // finish
  kmem.use_lock = 1;
8010335b:	c7 05 54 42 11 80 01 	movl   $0x1,0x80114254
80103362:	00 00 00 
}
80103365:	90                   	nop
80103366:	c9                   	leave  
80103367:	c3                   	ret    

80103368 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103368:	55                   	push   %ebp
80103369:	89 e5                	mov    %esp,%ebp
8010336b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
8010336e:	8b 45 08             	mov    0x8(%ebp),%eax
80103371:	05 ff 0f 00 00       	add    $0xfff,%eax
80103376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010337b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010337e:	eb 15                	jmp    80103395 <freerange+0x2d>
    kfree(p);
80103380:	83 ec 0c             	sub    $0xc,%esp
80103383:	ff 75 f4             	pushl  -0xc(%ebp)
80103386:	e8 1a 00 00 00       	call   801033a5 <kfree>
8010338b:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010338e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80103395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103398:	05 00 10 00 00       	add    $0x1000,%eax
8010339d:	3b 45 0c             	cmp    0xc(%ebp),%eax
801033a0:	76 de                	jbe    80103380 <freerange+0x18>
    kfree(p);
}
801033a2:	90                   	nop
801033a3:	c9                   	leave  
801033a4:	c3                   	ret    

801033a5 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801033a5:	55                   	push   %ebp
801033a6:	89 e5                	mov    %esp,%ebp
801033a8:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801033ab:	8b 45 08             	mov    0x8(%ebp),%eax
801033ae:	25 ff 0f 00 00       	and    $0xfff,%eax
801033b3:	85 c0                	test   %eax,%eax
801033b5:	75 1b                	jne    801033d2 <kfree+0x2d>
801033b7:	81 7d 08 5c c3 11 80 	cmpl   $0x8011c35c,0x8(%ebp)
801033be:	72 12                	jb     801033d2 <kfree+0x2d>
801033c0:	ff 75 08             	pushl  0x8(%ebp)
801033c3:	e8 e6 fe ff ff       	call   801032ae <v2p>
801033c8:	83 c4 04             	add    $0x4,%esp
801033cb:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801033d0:	76 0d                	jbe    801033df <kfree+0x3a>
    panic("kfree");
801033d2:	83 ec 0c             	sub    $0xc,%esp
801033d5:	68 07 a0 10 80       	push   $0x8010a007
801033da:	e8 87 d1 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801033df:	83 ec 04             	sub    $0x4,%esp
801033e2:	68 00 10 00 00       	push   $0x1000
801033e7:	6a 01                	push   $0x1
801033e9:	ff 75 08             	pushl  0x8(%ebp)
801033ec:	e8 d9 2b 00 00       	call   80105fca <memset>
801033f1:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
801033f4:	a1 54 42 11 80       	mov    0x80114254,%eax
801033f9:	85 c0                	test   %eax,%eax
801033fb:	74 10                	je     8010340d <kfree+0x68>
    acquire(&kmem.lock);
801033fd:	83 ec 0c             	sub    $0xc,%esp
80103400:	68 20 42 11 80       	push   $0x80114220
80103405:	e8 5d 29 00 00       	call   80105d67 <acquire>
8010340a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010340d:	8b 45 08             	mov    0x8(%ebp),%eax
80103410:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80103413:	8b 15 58 42 11 80    	mov    0x80114258,%edx
80103419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010341e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103421:	a3 58 42 11 80       	mov    %eax,0x80114258
  //assignment3 - change code here
  physicalPageStatistic.numOfPhysicalPages++;
80103426:	a1 60 42 11 80       	mov    0x80114260,%eax
8010342b:	83 c0 01             	add    $0x1,%eax
8010342e:	a3 60 42 11 80       	mov    %eax,0x80114260
  //finish
  if(kmem.use_lock)
80103433:	a1 54 42 11 80       	mov    0x80114254,%eax
80103438:	85 c0                	test   %eax,%eax
8010343a:	74 10                	je     8010344c <kfree+0xa7>
    release(&kmem.lock);
8010343c:	83 ec 0c             	sub    $0xc,%esp
8010343f:	68 20 42 11 80       	push   $0x80114220
80103444:	e8 85 29 00 00       	call   80105dce <release>
80103449:	83 c4 10             	add    $0x10,%esp
}
8010344c:	90                   	nop
8010344d:	c9                   	leave  
8010344e:	c3                   	ret    

8010344f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010344f:	55                   	push   %ebp
80103450:	89 e5                	mov    %esp,%ebp
80103452:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103455:	a1 54 42 11 80       	mov    0x80114254,%eax
8010345a:	85 c0                	test   %eax,%eax
8010345c:	74 10                	je     8010346e <kalloc+0x1f>
    acquire(&kmem.lock);
8010345e:	83 ec 0c             	sub    $0xc,%esp
80103461:	68 20 42 11 80       	push   $0x80114220
80103466:	e8 fc 28 00 00       	call   80105d67 <acquire>
8010346b:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
8010346e:	a1 58 42 11 80       	mov    0x80114258,%eax
80103473:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103476:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010347a:	74 0a                	je     80103486 <kalloc+0x37>
    kmem.freelist = r->next;
8010347c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010347f:	8b 00                	mov    (%eax),%eax
80103481:	a3 58 42 11 80       	mov    %eax,0x80114258
    //assignment3 - change code here
    physicalPageStatistic.numOfPhysicalPages--;
80103486:	a1 60 42 11 80       	mov    0x80114260,%eax
8010348b:	83 e8 01             	sub    $0x1,%eax
8010348e:	a3 60 42 11 80       	mov    %eax,0x80114260
    // finish
  if(kmem.use_lock)
80103493:	a1 54 42 11 80       	mov    0x80114254,%eax
80103498:	85 c0                	test   %eax,%eax
8010349a:	74 10                	je     801034ac <kalloc+0x5d>
    release(&kmem.lock);
8010349c:	83 ec 0c             	sub    $0xc,%esp
8010349f:	68 20 42 11 80       	push   $0x80114220
801034a4:	e8 25 29 00 00       	call   80105dce <release>
801034a9:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801034ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801034af:	c9                   	leave  
801034b0:	c3                   	ret    

801034b1 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801034b1:	55                   	push   %ebp
801034b2:	89 e5                	mov    %esp,%ebp
801034b4:	83 ec 14             	sub    $0x14,%esp
801034b7:	8b 45 08             	mov    0x8(%ebp),%eax
801034ba:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034be:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801034c2:	89 c2                	mov    %eax,%edx
801034c4:	ec                   	in     (%dx),%al
801034c5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801034c8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801034cc:	c9                   	leave  
801034cd:	c3                   	ret    

801034ce <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801034ce:	55                   	push   %ebp
801034cf:	89 e5                	mov    %esp,%ebp
801034d1:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801034d4:	6a 64                	push   $0x64
801034d6:	e8 d6 ff ff ff       	call   801034b1 <inb>
801034db:	83 c4 04             	add    $0x4,%esp
801034de:	0f b6 c0             	movzbl %al,%eax
801034e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801034e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034e7:	83 e0 01             	and    $0x1,%eax
801034ea:	85 c0                	test   %eax,%eax
801034ec:	75 0a                	jne    801034f8 <kbdgetc+0x2a>
    return -1;
801034ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034f3:	e9 23 01 00 00       	jmp    8010361b <kbdgetc+0x14d>
  data = inb(KBDATAP);
801034f8:	6a 60                	push   $0x60
801034fa:	e8 b2 ff ff ff       	call   801034b1 <inb>
801034ff:	83 c4 04             	add    $0x4,%esp
80103502:	0f b6 c0             	movzbl %al,%eax
80103505:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103508:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010350f:	75 17                	jne    80103528 <kbdgetc+0x5a>
    shift |= E0ESC;
80103511:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103516:	83 c8 40             	or     $0x40,%eax
80103519:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
8010351e:	b8 00 00 00 00       	mov    $0x0,%eax
80103523:	e9 f3 00 00 00       	jmp    8010361b <kbdgetc+0x14d>
  } else if(data & 0x80){
80103528:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010352b:	25 80 00 00 00       	and    $0x80,%eax
80103530:	85 c0                	test   %eax,%eax
80103532:	74 45                	je     80103579 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103534:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103539:	83 e0 40             	and    $0x40,%eax
8010353c:	85 c0                	test   %eax,%eax
8010353e:	75 08                	jne    80103548 <kbdgetc+0x7a>
80103540:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103543:	83 e0 7f             	and    $0x7f,%eax
80103546:	eb 03                	jmp    8010354b <kbdgetc+0x7d>
80103548:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010354b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010354e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103551:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103556:	0f b6 00             	movzbl (%eax),%eax
80103559:	83 c8 40             	or     $0x40,%eax
8010355c:	0f b6 c0             	movzbl %al,%eax
8010355f:	f7 d0                	not    %eax
80103561:	89 c2                	mov    %eax,%edx
80103563:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103568:	21 d0                	and    %edx,%eax
8010356a:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
8010356f:	b8 00 00 00 00       	mov    $0x0,%eax
80103574:	e9 a2 00 00 00       	jmp    8010361b <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103579:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
8010357e:	83 e0 40             	and    $0x40,%eax
80103581:	85 c0                	test   %eax,%eax
80103583:	74 14                	je     80103599 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103585:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010358c:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103591:	83 e0 bf             	and    $0xffffffbf,%eax
80103594:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  }

  shift |= shiftcode[data];
80103599:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010359c:	05 20 b0 10 80       	add    $0x8010b020,%eax
801035a1:	0f b6 00             	movzbl (%eax),%eax
801035a4:	0f b6 d0             	movzbl %al,%edx
801035a7:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801035ac:	09 d0                	or     %edx,%eax
801035ae:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  shift ^= togglecode[data];
801035b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035b6:	05 20 b1 10 80       	add    $0x8010b120,%eax
801035bb:	0f b6 00             	movzbl (%eax),%eax
801035be:	0f b6 d0             	movzbl %al,%edx
801035c1:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801035c6:	31 d0                	xor    %edx,%eax
801035c8:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  c = charcode[shift & (CTL | SHIFT)][data];
801035cd:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801035d2:	83 e0 03             	and    $0x3,%eax
801035d5:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
801035dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035df:	01 d0                	add    %edx,%eax
801035e1:	0f b6 00             	movzbl (%eax),%eax
801035e4:	0f b6 c0             	movzbl %al,%eax
801035e7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801035ea:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801035ef:	83 e0 08             	and    $0x8,%eax
801035f2:	85 c0                	test   %eax,%eax
801035f4:	74 22                	je     80103618 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801035f6:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801035fa:	76 0c                	jbe    80103608 <kbdgetc+0x13a>
801035fc:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103600:	77 06                	ja     80103608 <kbdgetc+0x13a>
      c += 'A' - 'a';
80103602:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103606:	eb 10                	jmp    80103618 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103608:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010360c:	76 0a                	jbe    80103618 <kbdgetc+0x14a>
8010360e:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103612:	77 04                	ja     80103618 <kbdgetc+0x14a>
      c += 'a' - 'A';
80103614:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103618:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010361b:	c9                   	leave  
8010361c:	c3                   	ret    

8010361d <kbdintr>:

void
kbdintr(void)
{
8010361d:	55                   	push   %ebp
8010361e:	89 e5                	mov    %esp,%ebp
80103620:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103623:	83 ec 0c             	sub    $0xc,%esp
80103626:	68 ce 34 10 80       	push   $0x801034ce
8010362b:	e8 c9 d1 ff ff       	call   801007f9 <consoleintr>
80103630:	83 c4 10             	add    $0x10,%esp
}
80103633:	90                   	nop
80103634:	c9                   	leave  
80103635:	c3                   	ret    

80103636 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103636:	55                   	push   %ebp
80103637:	89 e5                	mov    %esp,%ebp
80103639:	83 ec 14             	sub    $0x14,%esp
8010363c:	8b 45 08             	mov    0x8(%ebp),%eax
8010363f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103643:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103647:	89 c2                	mov    %eax,%edx
80103649:	ec                   	in     (%dx),%al
8010364a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010364d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103651:	c9                   	leave  
80103652:	c3                   	ret    

80103653 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103653:	55                   	push   %ebp
80103654:	89 e5                	mov    %esp,%ebp
80103656:	83 ec 08             	sub    $0x8,%esp
80103659:	8b 55 08             	mov    0x8(%ebp),%edx
8010365c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103663:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103666:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010366a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010366e:	ee                   	out    %al,(%dx)
}
8010366f:	90                   	nop
80103670:	c9                   	leave  
80103671:	c3                   	ret    

80103672 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103672:	55                   	push   %ebp
80103673:	89 e5                	mov    %esp,%ebp
80103675:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103678:	9c                   	pushf  
80103679:	58                   	pop    %eax
8010367a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010367d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103680:	c9                   	leave  
80103681:	c3                   	ret    

80103682 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103682:	55                   	push   %ebp
80103683:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103685:	a1 64 42 11 80       	mov    0x80114264,%eax
8010368a:	8b 55 08             	mov    0x8(%ebp),%edx
8010368d:	c1 e2 02             	shl    $0x2,%edx
80103690:	01 c2                	add    %eax,%edx
80103692:	8b 45 0c             	mov    0xc(%ebp),%eax
80103695:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103697:	a1 64 42 11 80       	mov    0x80114264,%eax
8010369c:	83 c0 20             	add    $0x20,%eax
8010369f:	8b 00                	mov    (%eax),%eax
}
801036a1:	90                   	nop
801036a2:	5d                   	pop    %ebp
801036a3:	c3                   	ret    

801036a4 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801036a4:	55                   	push   %ebp
801036a5:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801036a7:	a1 64 42 11 80       	mov    0x80114264,%eax
801036ac:	85 c0                	test   %eax,%eax
801036ae:	0f 84 0b 01 00 00    	je     801037bf <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801036b4:	68 3f 01 00 00       	push   $0x13f
801036b9:	6a 3c                	push   $0x3c
801036bb:	e8 c2 ff ff ff       	call   80103682 <lapicw>
801036c0:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801036c3:	6a 0b                	push   $0xb
801036c5:	68 f8 00 00 00       	push   $0xf8
801036ca:	e8 b3 ff ff ff       	call   80103682 <lapicw>
801036cf:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801036d2:	68 20 00 02 00       	push   $0x20020
801036d7:	68 c8 00 00 00       	push   $0xc8
801036dc:	e8 a1 ff ff ff       	call   80103682 <lapicw>
801036e1:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
801036e4:	68 80 96 98 00       	push   $0x989680
801036e9:	68 e0 00 00 00       	push   $0xe0
801036ee:	e8 8f ff ff ff       	call   80103682 <lapicw>
801036f3:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801036f6:	68 00 00 01 00       	push   $0x10000
801036fb:	68 d4 00 00 00       	push   $0xd4
80103700:	e8 7d ff ff ff       	call   80103682 <lapicw>
80103705:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103708:	68 00 00 01 00       	push   $0x10000
8010370d:	68 d8 00 00 00       	push   $0xd8
80103712:	e8 6b ff ff ff       	call   80103682 <lapicw>
80103717:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010371a:	a1 64 42 11 80       	mov    0x80114264,%eax
8010371f:	83 c0 30             	add    $0x30,%eax
80103722:	8b 00                	mov    (%eax),%eax
80103724:	c1 e8 10             	shr    $0x10,%eax
80103727:	0f b6 c0             	movzbl %al,%eax
8010372a:	83 f8 03             	cmp    $0x3,%eax
8010372d:	76 12                	jbe    80103741 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
8010372f:	68 00 00 01 00       	push   $0x10000
80103734:	68 d0 00 00 00       	push   $0xd0
80103739:	e8 44 ff ff ff       	call   80103682 <lapicw>
8010373e:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103741:	6a 33                	push   $0x33
80103743:	68 dc 00 00 00       	push   $0xdc
80103748:	e8 35 ff ff ff       	call   80103682 <lapicw>
8010374d:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103750:	6a 00                	push   $0x0
80103752:	68 a0 00 00 00       	push   $0xa0
80103757:	e8 26 ff ff ff       	call   80103682 <lapicw>
8010375c:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010375f:	6a 00                	push   $0x0
80103761:	68 a0 00 00 00       	push   $0xa0
80103766:	e8 17 ff ff ff       	call   80103682 <lapicw>
8010376b:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010376e:	6a 00                	push   $0x0
80103770:	6a 2c                	push   $0x2c
80103772:	e8 0b ff ff ff       	call   80103682 <lapicw>
80103777:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010377a:	6a 00                	push   $0x0
8010377c:	68 c4 00 00 00       	push   $0xc4
80103781:	e8 fc fe ff ff       	call   80103682 <lapicw>
80103786:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103789:	68 00 85 08 00       	push   $0x88500
8010378e:	68 c0 00 00 00       	push   $0xc0
80103793:	e8 ea fe ff ff       	call   80103682 <lapicw>
80103798:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010379b:	90                   	nop
8010379c:	a1 64 42 11 80       	mov    0x80114264,%eax
801037a1:	05 00 03 00 00       	add    $0x300,%eax
801037a6:	8b 00                	mov    (%eax),%eax
801037a8:	25 00 10 00 00       	and    $0x1000,%eax
801037ad:	85 c0                	test   %eax,%eax
801037af:	75 eb                	jne    8010379c <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801037b1:	6a 00                	push   $0x0
801037b3:	6a 20                	push   $0x20
801037b5:	e8 c8 fe ff ff       	call   80103682 <lapicw>
801037ba:	83 c4 08             	add    $0x8,%esp
801037bd:	eb 01                	jmp    801037c0 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801037bf:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801037c0:	c9                   	leave  
801037c1:	c3                   	ret    

801037c2 <cpunum>:

int
cpunum(void)
{
801037c2:	55                   	push   %ebp
801037c3:	89 e5                	mov    %esp,%ebp
801037c5:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801037c8:	e8 a5 fe ff ff       	call   80103672 <readeflags>
801037cd:	25 00 02 00 00       	and    $0x200,%eax
801037d2:	85 c0                	test   %eax,%eax
801037d4:	74 26                	je     801037fc <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801037d6:	a1 40 d6 10 80       	mov    0x8010d640,%eax
801037db:	8d 50 01             	lea    0x1(%eax),%edx
801037de:	89 15 40 d6 10 80    	mov    %edx,0x8010d640
801037e4:	85 c0                	test   %eax,%eax
801037e6:	75 14                	jne    801037fc <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
801037e8:	8b 45 04             	mov    0x4(%ebp),%eax
801037eb:	83 ec 08             	sub    $0x8,%esp
801037ee:	50                   	push   %eax
801037ef:	68 10 a0 10 80       	push   $0x8010a010
801037f4:	e8 cd cb ff ff       	call   801003c6 <cprintf>
801037f9:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801037fc:	a1 64 42 11 80       	mov    0x80114264,%eax
80103801:	85 c0                	test   %eax,%eax
80103803:	74 0f                	je     80103814 <cpunum+0x52>
    return lapic[ID]>>24;
80103805:	a1 64 42 11 80       	mov    0x80114264,%eax
8010380a:	83 c0 20             	add    $0x20,%eax
8010380d:	8b 00                	mov    (%eax),%eax
8010380f:	c1 e8 18             	shr    $0x18,%eax
80103812:	eb 05                	jmp    80103819 <cpunum+0x57>
  return 0;
80103814:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103819:	c9                   	leave  
8010381a:	c3                   	ret    

8010381b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010381b:	55                   	push   %ebp
8010381c:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010381e:	a1 64 42 11 80       	mov    0x80114264,%eax
80103823:	85 c0                	test   %eax,%eax
80103825:	74 0c                	je     80103833 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103827:	6a 00                	push   $0x0
80103829:	6a 2c                	push   $0x2c
8010382b:	e8 52 fe ff ff       	call   80103682 <lapicw>
80103830:	83 c4 08             	add    $0x8,%esp
}
80103833:	90                   	nop
80103834:	c9                   	leave  
80103835:	c3                   	ret    

80103836 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103836:	55                   	push   %ebp
80103837:	89 e5                	mov    %esp,%ebp
}
80103839:	90                   	nop
8010383a:	5d                   	pop    %ebp
8010383b:	c3                   	ret    

8010383c <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010383c:	55                   	push   %ebp
8010383d:	89 e5                	mov    %esp,%ebp
8010383f:	83 ec 14             	sub    $0x14,%esp
80103842:	8b 45 08             	mov    0x8(%ebp),%eax
80103845:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103848:	6a 0f                	push   $0xf
8010384a:	6a 70                	push   $0x70
8010384c:	e8 02 fe ff ff       	call   80103653 <outb>
80103851:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103854:	6a 0a                	push   $0xa
80103856:	6a 71                	push   $0x71
80103858:	e8 f6 fd ff ff       	call   80103653 <outb>
8010385d:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103860:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103867:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010386a:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010386f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103872:	83 c0 02             	add    $0x2,%eax
80103875:	8b 55 0c             	mov    0xc(%ebp),%edx
80103878:	c1 ea 04             	shr    $0x4,%edx
8010387b:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010387e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103882:	c1 e0 18             	shl    $0x18,%eax
80103885:	50                   	push   %eax
80103886:	68 c4 00 00 00       	push   $0xc4
8010388b:	e8 f2 fd ff ff       	call   80103682 <lapicw>
80103890:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103893:	68 00 c5 00 00       	push   $0xc500
80103898:	68 c0 00 00 00       	push   $0xc0
8010389d:	e8 e0 fd ff ff       	call   80103682 <lapicw>
801038a2:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801038a5:	68 c8 00 00 00       	push   $0xc8
801038aa:	e8 87 ff ff ff       	call   80103836 <microdelay>
801038af:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801038b2:	68 00 85 00 00       	push   $0x8500
801038b7:	68 c0 00 00 00       	push   $0xc0
801038bc:	e8 c1 fd ff ff       	call   80103682 <lapicw>
801038c1:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801038c4:	6a 64                	push   $0x64
801038c6:	e8 6b ff ff ff       	call   80103836 <microdelay>
801038cb:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038ce:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801038d5:	eb 3d                	jmp    80103914 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801038d7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801038db:	c1 e0 18             	shl    $0x18,%eax
801038de:	50                   	push   %eax
801038df:	68 c4 00 00 00       	push   $0xc4
801038e4:	e8 99 fd ff ff       	call   80103682 <lapicw>
801038e9:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801038ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801038ef:	c1 e8 0c             	shr    $0xc,%eax
801038f2:	80 cc 06             	or     $0x6,%ah
801038f5:	50                   	push   %eax
801038f6:	68 c0 00 00 00       	push   $0xc0
801038fb:	e8 82 fd ff ff       	call   80103682 <lapicw>
80103900:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103903:	68 c8 00 00 00       	push   $0xc8
80103908:	e8 29 ff ff ff       	call   80103836 <microdelay>
8010390d:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103910:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103914:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103918:	7e bd                	jle    801038d7 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010391a:	90                   	nop
8010391b:	c9                   	leave  
8010391c:	c3                   	ret    

8010391d <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010391d:	55                   	push   %ebp
8010391e:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103920:	8b 45 08             	mov    0x8(%ebp),%eax
80103923:	0f b6 c0             	movzbl %al,%eax
80103926:	50                   	push   %eax
80103927:	6a 70                	push   $0x70
80103929:	e8 25 fd ff ff       	call   80103653 <outb>
8010392e:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103931:	68 c8 00 00 00       	push   $0xc8
80103936:	e8 fb fe ff ff       	call   80103836 <microdelay>
8010393b:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010393e:	6a 71                	push   $0x71
80103940:	e8 f1 fc ff ff       	call   80103636 <inb>
80103945:	83 c4 04             	add    $0x4,%esp
80103948:	0f b6 c0             	movzbl %al,%eax
}
8010394b:	c9                   	leave  
8010394c:	c3                   	ret    

8010394d <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010394d:	55                   	push   %ebp
8010394e:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103950:	6a 00                	push   $0x0
80103952:	e8 c6 ff ff ff       	call   8010391d <cmos_read>
80103957:	83 c4 04             	add    $0x4,%esp
8010395a:	89 c2                	mov    %eax,%edx
8010395c:	8b 45 08             	mov    0x8(%ebp),%eax
8010395f:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103961:	6a 02                	push   $0x2
80103963:	e8 b5 ff ff ff       	call   8010391d <cmos_read>
80103968:	83 c4 04             	add    $0x4,%esp
8010396b:	89 c2                	mov    %eax,%edx
8010396d:	8b 45 08             	mov    0x8(%ebp),%eax
80103970:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103973:	6a 04                	push   $0x4
80103975:	e8 a3 ff ff ff       	call   8010391d <cmos_read>
8010397a:	83 c4 04             	add    $0x4,%esp
8010397d:	89 c2                	mov    %eax,%edx
8010397f:	8b 45 08             	mov    0x8(%ebp),%eax
80103982:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103985:	6a 07                	push   $0x7
80103987:	e8 91 ff ff ff       	call   8010391d <cmos_read>
8010398c:	83 c4 04             	add    $0x4,%esp
8010398f:	89 c2                	mov    %eax,%edx
80103991:	8b 45 08             	mov    0x8(%ebp),%eax
80103994:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103997:	6a 08                	push   $0x8
80103999:	e8 7f ff ff ff       	call   8010391d <cmos_read>
8010399e:	83 c4 04             	add    $0x4,%esp
801039a1:	89 c2                	mov    %eax,%edx
801039a3:	8b 45 08             	mov    0x8(%ebp),%eax
801039a6:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801039a9:	6a 09                	push   $0x9
801039ab:	e8 6d ff ff ff       	call   8010391d <cmos_read>
801039b0:	83 c4 04             	add    $0x4,%esp
801039b3:	89 c2                	mov    %eax,%edx
801039b5:	8b 45 08             	mov    0x8(%ebp),%eax
801039b8:	89 50 14             	mov    %edx,0x14(%eax)
}
801039bb:	90                   	nop
801039bc:	c9                   	leave  
801039bd:	c3                   	ret    

801039be <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801039be:	55                   	push   %ebp
801039bf:	89 e5                	mov    %esp,%ebp
801039c1:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801039c4:	6a 0b                	push   $0xb
801039c6:	e8 52 ff ff ff       	call   8010391d <cmos_read>
801039cb:	83 c4 04             	add    $0x4,%esp
801039ce:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801039d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d4:	83 e0 04             	and    $0x4,%eax
801039d7:	85 c0                	test   %eax,%eax
801039d9:	0f 94 c0             	sete   %al
801039dc:	0f b6 c0             	movzbl %al,%eax
801039df:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801039e2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801039e5:	50                   	push   %eax
801039e6:	e8 62 ff ff ff       	call   8010394d <fill_rtcdate>
801039eb:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801039ee:	6a 0a                	push   $0xa
801039f0:	e8 28 ff ff ff       	call   8010391d <cmos_read>
801039f5:	83 c4 04             	add    $0x4,%esp
801039f8:	25 80 00 00 00       	and    $0x80,%eax
801039fd:	85 c0                	test   %eax,%eax
801039ff:	75 27                	jne    80103a28 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103a01:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a04:	50                   	push   %eax
80103a05:	e8 43 ff ff ff       	call   8010394d <fill_rtcdate>
80103a0a:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103a0d:	83 ec 04             	sub    $0x4,%esp
80103a10:	6a 18                	push   $0x18
80103a12:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a15:	50                   	push   %eax
80103a16:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a19:	50                   	push   %eax
80103a1a:	e8 12 26 00 00       	call   80106031 <memcmp>
80103a1f:	83 c4 10             	add    $0x10,%esp
80103a22:	85 c0                	test   %eax,%eax
80103a24:	74 05                	je     80103a2b <cmostime+0x6d>
80103a26:	eb ba                	jmp    801039e2 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103a28:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103a29:	eb b7                	jmp    801039e2 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103a2b:	90                   	nop
  }

  // convert
  if (bcd) {
80103a2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a30:	0f 84 b4 00 00 00    	je     80103aea <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103a36:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a39:	c1 e8 04             	shr    $0x4,%eax
80103a3c:	89 c2                	mov    %eax,%edx
80103a3e:	89 d0                	mov    %edx,%eax
80103a40:	c1 e0 02             	shl    $0x2,%eax
80103a43:	01 d0                	add    %edx,%eax
80103a45:	01 c0                	add    %eax,%eax
80103a47:	89 c2                	mov    %eax,%edx
80103a49:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a4c:	83 e0 0f             	and    $0xf,%eax
80103a4f:	01 d0                	add    %edx,%eax
80103a51:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103a54:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a57:	c1 e8 04             	shr    $0x4,%eax
80103a5a:	89 c2                	mov    %eax,%edx
80103a5c:	89 d0                	mov    %edx,%eax
80103a5e:	c1 e0 02             	shl    $0x2,%eax
80103a61:	01 d0                	add    %edx,%eax
80103a63:	01 c0                	add    %eax,%eax
80103a65:	89 c2                	mov    %eax,%edx
80103a67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a6a:	83 e0 0f             	and    $0xf,%eax
80103a6d:	01 d0                	add    %edx,%eax
80103a6f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103a72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a75:	c1 e8 04             	shr    $0x4,%eax
80103a78:	89 c2                	mov    %eax,%edx
80103a7a:	89 d0                	mov    %edx,%eax
80103a7c:	c1 e0 02             	shl    $0x2,%eax
80103a7f:	01 d0                	add    %edx,%eax
80103a81:	01 c0                	add    %eax,%eax
80103a83:	89 c2                	mov    %eax,%edx
80103a85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a88:	83 e0 0f             	and    $0xf,%eax
80103a8b:	01 d0                	add    %edx,%eax
80103a8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103a90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103a93:	c1 e8 04             	shr    $0x4,%eax
80103a96:	89 c2                	mov    %eax,%edx
80103a98:	89 d0                	mov    %edx,%eax
80103a9a:	c1 e0 02             	shl    $0x2,%eax
80103a9d:	01 d0                	add    %edx,%eax
80103a9f:	01 c0                	add    %eax,%eax
80103aa1:	89 c2                	mov    %eax,%edx
80103aa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103aa6:	83 e0 0f             	and    $0xf,%eax
80103aa9:	01 d0                	add    %edx,%eax
80103aab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103aae:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ab1:	c1 e8 04             	shr    $0x4,%eax
80103ab4:	89 c2                	mov    %eax,%edx
80103ab6:	89 d0                	mov    %edx,%eax
80103ab8:	c1 e0 02             	shl    $0x2,%eax
80103abb:	01 d0                	add    %edx,%eax
80103abd:	01 c0                	add    %eax,%eax
80103abf:	89 c2                	mov    %eax,%edx
80103ac1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ac4:	83 e0 0f             	and    $0xf,%eax
80103ac7:	01 d0                	add    %edx,%eax
80103ac9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103acc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103acf:	c1 e8 04             	shr    $0x4,%eax
80103ad2:	89 c2                	mov    %eax,%edx
80103ad4:	89 d0                	mov    %edx,%eax
80103ad6:	c1 e0 02             	shl    $0x2,%eax
80103ad9:	01 d0                	add    %edx,%eax
80103adb:	01 c0                	add    %eax,%eax
80103add:	89 c2                	mov    %eax,%edx
80103adf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ae2:	83 e0 0f             	and    $0xf,%eax
80103ae5:	01 d0                	add    %edx,%eax
80103ae7:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103aea:	8b 45 08             	mov    0x8(%ebp),%eax
80103aed:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103af0:	89 10                	mov    %edx,(%eax)
80103af2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103af5:	89 50 04             	mov    %edx,0x4(%eax)
80103af8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103afb:	89 50 08             	mov    %edx,0x8(%eax)
80103afe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103b01:	89 50 0c             	mov    %edx,0xc(%eax)
80103b04:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103b07:	89 50 10             	mov    %edx,0x10(%eax)
80103b0a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b0d:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103b10:	8b 45 08             	mov    0x8(%ebp),%eax
80103b13:	8b 40 14             	mov    0x14(%eax),%eax
80103b16:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b1f:	89 50 14             	mov    %edx,0x14(%eax)
}
80103b22:	90                   	nop
80103b23:	c9                   	leave  
80103b24:	c3                   	ret    

80103b25 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103b25:	55                   	push   %ebp
80103b26:	89 e5                	mov    %esp,%ebp
80103b28:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103b2b:	83 ec 08             	sub    $0x8,%esp
80103b2e:	68 3c a0 10 80       	push   $0x8010a03c
80103b33:	68 80 42 11 80       	push   $0x80114280
80103b38:	e8 08 22 00 00       	call   80105d45 <initlock>
80103b3d:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103b40:	83 ec 08             	sub    $0x8,%esp
80103b43:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103b46:	50                   	push   %eax
80103b47:	ff 75 08             	pushl  0x8(%ebp)
80103b4a:	e8 c7 db ff ff       	call   80101716 <readsb>
80103b4f:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103b52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b55:	a3 b4 42 11 80       	mov    %eax,0x801142b4
  log.size = sb.nlog;
80103b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103b5d:	a3 b8 42 11 80       	mov    %eax,0x801142b8
  log.dev = dev;
80103b62:	8b 45 08             	mov    0x8(%ebp),%eax
80103b65:	a3 c4 42 11 80       	mov    %eax,0x801142c4
  recover_from_log();
80103b6a:	e8 b2 01 00 00       	call   80103d21 <recover_from_log>
}
80103b6f:	90                   	nop
80103b70:	c9                   	leave  
80103b71:	c3                   	ret    

80103b72 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103b72:	55                   	push   %ebp
80103b73:	89 e5                	mov    %esp,%ebp
80103b75:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103b78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b7f:	e9 95 00 00 00       	jmp    80103c19 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103b84:	8b 15 b4 42 11 80    	mov    0x801142b4,%edx
80103b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8d:	01 d0                	add    %edx,%eax
80103b8f:	83 c0 01             	add    $0x1,%eax
80103b92:	89 c2                	mov    %eax,%edx
80103b94:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103b99:	83 ec 08             	sub    $0x8,%esp
80103b9c:	52                   	push   %edx
80103b9d:	50                   	push   %eax
80103b9e:	e8 13 c6 ff ff       	call   801001b6 <bread>
80103ba3:	83 c4 10             	add    $0x10,%esp
80103ba6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bac:	83 c0 10             	add    $0x10,%eax
80103baf:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
80103bb6:	89 c2                	mov    %eax,%edx
80103bb8:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103bbd:	83 ec 08             	sub    $0x8,%esp
80103bc0:	52                   	push   %edx
80103bc1:	50                   	push   %eax
80103bc2:	e8 ef c5 ff ff       	call   801001b6 <bread>
80103bc7:	83 c4 10             	add    $0x10,%esp
80103bca:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd0:	8d 50 18             	lea    0x18(%eax),%edx
80103bd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bd6:	83 c0 18             	add    $0x18,%eax
80103bd9:	83 ec 04             	sub    $0x4,%esp
80103bdc:	68 00 02 00 00       	push   $0x200
80103be1:	52                   	push   %edx
80103be2:	50                   	push   %eax
80103be3:	e8 a1 24 00 00       	call   80106089 <memmove>
80103be8:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103beb:	83 ec 0c             	sub    $0xc,%esp
80103bee:	ff 75 ec             	pushl  -0x14(%ebp)
80103bf1:	e8 f9 c5 ff ff       	call   801001ef <bwrite>
80103bf6:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103bf9:	83 ec 0c             	sub    $0xc,%esp
80103bfc:	ff 75 f0             	pushl  -0x10(%ebp)
80103bff:	e8 2a c6 ff ff       	call   8010022e <brelse>
80103c04:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103c07:	83 ec 0c             	sub    $0xc,%esp
80103c0a:	ff 75 ec             	pushl  -0x14(%ebp)
80103c0d:	e8 1c c6 ff ff       	call   8010022e <brelse>
80103c12:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103c15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c19:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103c1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c21:	0f 8f 5d ff ff ff    	jg     80103b84 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103c27:	90                   	nop
80103c28:	c9                   	leave  
80103c29:	c3                   	ret    

80103c2a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103c2a:	55                   	push   %ebp
80103c2b:	89 e5                	mov    %esp,%ebp
80103c2d:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103c30:	a1 b4 42 11 80       	mov    0x801142b4,%eax
80103c35:	89 c2                	mov    %eax,%edx
80103c37:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103c3c:	83 ec 08             	sub    $0x8,%esp
80103c3f:	52                   	push   %edx
80103c40:	50                   	push   %eax
80103c41:	e8 70 c5 ff ff       	call   801001b6 <bread>
80103c46:	83 c4 10             	add    $0x10,%esp
80103c49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c4f:	83 c0 18             	add    $0x18,%eax
80103c52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103c55:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c58:	8b 00                	mov    (%eax),%eax
80103c5a:	a3 c8 42 11 80       	mov    %eax,0x801142c8
  for (i = 0; i < log.lh.n; i++) {
80103c5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c66:	eb 1b                	jmp    80103c83 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103c68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c6e:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c75:	83 c2 10             	add    $0x10,%edx
80103c78:	89 04 95 8c 42 11 80 	mov    %eax,-0x7feebd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103c7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c83:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103c88:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c8b:	7f db                	jg     80103c68 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103c8d:	83 ec 0c             	sub    $0xc,%esp
80103c90:	ff 75 f0             	pushl  -0x10(%ebp)
80103c93:	e8 96 c5 ff ff       	call   8010022e <brelse>
80103c98:	83 c4 10             	add    $0x10,%esp
}
80103c9b:	90                   	nop
80103c9c:	c9                   	leave  
80103c9d:	c3                   	ret    

80103c9e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103c9e:	55                   	push   %ebp
80103c9f:	89 e5                	mov    %esp,%ebp
80103ca1:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103ca4:	a1 b4 42 11 80       	mov    0x801142b4,%eax
80103ca9:	89 c2                	mov    %eax,%edx
80103cab:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103cb0:	83 ec 08             	sub    $0x8,%esp
80103cb3:	52                   	push   %edx
80103cb4:	50                   	push   %eax
80103cb5:	e8 fc c4 ff ff       	call   801001b6 <bread>
80103cba:	83 c4 10             	add    $0x10,%esp
80103cbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc3:	83 c0 18             	add    $0x18,%eax
80103cc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103cc9:	8b 15 c8 42 11 80    	mov    0x801142c8,%edx
80103ccf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cd2:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103cd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103cdb:	eb 1b                	jmp    80103cf8 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce0:	83 c0 10             	add    $0x10,%eax
80103ce3:	8b 0c 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%ecx
80103cea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ced:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cf0:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103cf4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103cf8:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103cfd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d00:	7f db                	jg     80103cdd <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103d02:	83 ec 0c             	sub    $0xc,%esp
80103d05:	ff 75 f0             	pushl  -0x10(%ebp)
80103d08:	e8 e2 c4 ff ff       	call   801001ef <bwrite>
80103d0d:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103d10:	83 ec 0c             	sub    $0xc,%esp
80103d13:	ff 75 f0             	pushl  -0x10(%ebp)
80103d16:	e8 13 c5 ff ff       	call   8010022e <brelse>
80103d1b:	83 c4 10             	add    $0x10,%esp
}
80103d1e:	90                   	nop
80103d1f:	c9                   	leave  
80103d20:	c3                   	ret    

80103d21 <recover_from_log>:

static void
recover_from_log(void)
{
80103d21:	55                   	push   %ebp
80103d22:	89 e5                	mov    %esp,%ebp
80103d24:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103d27:	e8 fe fe ff ff       	call   80103c2a <read_head>
  install_trans(); // if committed, copy from log to disk
80103d2c:	e8 41 fe ff ff       	call   80103b72 <install_trans>
  log.lh.n = 0;
80103d31:	c7 05 c8 42 11 80 00 	movl   $0x0,0x801142c8
80103d38:	00 00 00 
  write_head(); // clear the log
80103d3b:	e8 5e ff ff ff       	call   80103c9e <write_head>
}
80103d40:	90                   	nop
80103d41:	c9                   	leave  
80103d42:	c3                   	ret    

80103d43 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103d43:	55                   	push   %ebp
80103d44:	89 e5                	mov    %esp,%ebp
80103d46:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103d49:	83 ec 0c             	sub    $0xc,%esp
80103d4c:	68 80 42 11 80       	push   $0x80114280
80103d51:	e8 11 20 00 00       	call   80105d67 <acquire>
80103d56:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103d59:	a1 c0 42 11 80       	mov    0x801142c0,%eax
80103d5e:	85 c0                	test   %eax,%eax
80103d60:	74 17                	je     80103d79 <begin_op+0x36>
      sleep(&log, &log.lock);
80103d62:	83 ec 08             	sub    $0x8,%esp
80103d65:	68 80 42 11 80       	push   $0x80114280
80103d6a:	68 80 42 11 80       	push   $0x80114280
80103d6f:	e8 2e 1b 00 00       	call   801058a2 <sleep>
80103d74:	83 c4 10             	add    $0x10,%esp
80103d77:	eb e0                	jmp    80103d59 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103d79:	8b 0d c8 42 11 80    	mov    0x801142c8,%ecx
80103d7f:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103d84:	8d 50 01             	lea    0x1(%eax),%edx
80103d87:	89 d0                	mov    %edx,%eax
80103d89:	c1 e0 02             	shl    $0x2,%eax
80103d8c:	01 d0                	add    %edx,%eax
80103d8e:	01 c0                	add    %eax,%eax
80103d90:	01 c8                	add    %ecx,%eax
80103d92:	83 f8 1e             	cmp    $0x1e,%eax
80103d95:	7e 17                	jle    80103dae <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103d97:	83 ec 08             	sub    $0x8,%esp
80103d9a:	68 80 42 11 80       	push   $0x80114280
80103d9f:	68 80 42 11 80       	push   $0x80114280
80103da4:	e8 f9 1a 00 00       	call   801058a2 <sleep>
80103da9:	83 c4 10             	add    $0x10,%esp
80103dac:	eb ab                	jmp    80103d59 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103dae:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103db3:	83 c0 01             	add    $0x1,%eax
80103db6:	a3 bc 42 11 80       	mov    %eax,0x801142bc
      release(&log.lock);
80103dbb:	83 ec 0c             	sub    $0xc,%esp
80103dbe:	68 80 42 11 80       	push   $0x80114280
80103dc3:	e8 06 20 00 00       	call   80105dce <release>
80103dc8:	83 c4 10             	add    $0x10,%esp
      break;
80103dcb:	90                   	nop
    }
  }
}
80103dcc:	90                   	nop
80103dcd:	c9                   	leave  
80103dce:	c3                   	ret    

80103dcf <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103dcf:	55                   	push   %ebp
80103dd0:	89 e5                	mov    %esp,%ebp
80103dd2:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103dd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103ddc:	83 ec 0c             	sub    $0xc,%esp
80103ddf:	68 80 42 11 80       	push   $0x80114280
80103de4:	e8 7e 1f 00 00       	call   80105d67 <acquire>
80103de9:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103dec:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103df1:	83 e8 01             	sub    $0x1,%eax
80103df4:	a3 bc 42 11 80       	mov    %eax,0x801142bc
  if(log.committing)
80103df9:	a1 c0 42 11 80       	mov    0x801142c0,%eax
80103dfe:	85 c0                	test   %eax,%eax
80103e00:	74 0d                	je     80103e0f <end_op+0x40>
    panic("log.committing");
80103e02:	83 ec 0c             	sub    $0xc,%esp
80103e05:	68 40 a0 10 80       	push   $0x8010a040
80103e0a:	e8 57 c7 ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103e0f:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103e14:	85 c0                	test   %eax,%eax
80103e16:	75 13                	jne    80103e2b <end_op+0x5c>
    do_commit = 1;
80103e18:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103e1f:	c7 05 c0 42 11 80 01 	movl   $0x1,0x801142c0
80103e26:	00 00 00 
80103e29:	eb 10                	jmp    80103e3b <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103e2b:	83 ec 0c             	sub    $0xc,%esp
80103e2e:	68 80 42 11 80       	push   $0x80114280
80103e33:	e8 58 1b 00 00       	call   80105990 <wakeup>
80103e38:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	68 80 42 11 80       	push   $0x80114280
80103e43:	e8 86 1f 00 00       	call   80105dce <release>
80103e48:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103e4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e4f:	74 3f                	je     80103e90 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103e51:	e8 f5 00 00 00       	call   80103f4b <commit>
    acquire(&log.lock);
80103e56:	83 ec 0c             	sub    $0xc,%esp
80103e59:	68 80 42 11 80       	push   $0x80114280
80103e5e:	e8 04 1f 00 00       	call   80105d67 <acquire>
80103e63:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103e66:	c7 05 c0 42 11 80 00 	movl   $0x0,0x801142c0
80103e6d:	00 00 00 
    wakeup(&log);
80103e70:	83 ec 0c             	sub    $0xc,%esp
80103e73:	68 80 42 11 80       	push   $0x80114280
80103e78:	e8 13 1b 00 00       	call   80105990 <wakeup>
80103e7d:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103e80:	83 ec 0c             	sub    $0xc,%esp
80103e83:	68 80 42 11 80       	push   $0x80114280
80103e88:	e8 41 1f 00 00       	call   80105dce <release>
80103e8d:	83 c4 10             	add    $0x10,%esp
  }
}
80103e90:	90                   	nop
80103e91:	c9                   	leave  
80103e92:	c3                   	ret    

80103e93 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103e93:	55                   	push   %ebp
80103e94:	89 e5                	mov    %esp,%ebp
80103e96:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103e99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ea0:	e9 95 00 00 00       	jmp    80103f3a <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103ea5:	8b 15 b4 42 11 80    	mov    0x801142b4,%edx
80103eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eae:	01 d0                	add    %edx,%eax
80103eb0:	83 c0 01             	add    $0x1,%eax
80103eb3:	89 c2                	mov    %eax,%edx
80103eb5:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103eba:	83 ec 08             	sub    $0x8,%esp
80103ebd:	52                   	push   %edx
80103ebe:	50                   	push   %eax
80103ebf:	e8 f2 c2 ff ff       	call   801001b6 <bread>
80103ec4:	83 c4 10             	add    $0x10,%esp
80103ec7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ecd:	83 c0 10             	add    $0x10,%eax
80103ed0:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
80103ed7:	89 c2                	mov    %eax,%edx
80103ed9:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103ede:	83 ec 08             	sub    $0x8,%esp
80103ee1:	52                   	push   %edx
80103ee2:	50                   	push   %eax
80103ee3:	e8 ce c2 ff ff       	call   801001b6 <bread>
80103ee8:	83 c4 10             	add    $0x10,%esp
80103eeb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103eee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef1:	8d 50 18             	lea    0x18(%eax),%edx
80103ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ef7:	83 c0 18             	add    $0x18,%eax
80103efa:	83 ec 04             	sub    $0x4,%esp
80103efd:	68 00 02 00 00       	push   $0x200
80103f02:	52                   	push   %edx
80103f03:	50                   	push   %eax
80103f04:	e8 80 21 00 00       	call   80106089 <memmove>
80103f09:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103f0c:	83 ec 0c             	sub    $0xc,%esp
80103f0f:	ff 75 f0             	pushl  -0x10(%ebp)
80103f12:	e8 d8 c2 ff ff       	call   801001ef <bwrite>
80103f17:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103f1a:	83 ec 0c             	sub    $0xc,%esp
80103f1d:	ff 75 ec             	pushl  -0x14(%ebp)
80103f20:	e8 09 c3 ff ff       	call   8010022e <brelse>
80103f25:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103f28:	83 ec 0c             	sub    $0xc,%esp
80103f2b:	ff 75 f0             	pushl  -0x10(%ebp)
80103f2e:	e8 fb c2 ff ff       	call   8010022e <brelse>
80103f33:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103f36:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f3a:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103f3f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103f42:	0f 8f 5d ff ff ff    	jg     80103ea5 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103f48:	90                   	nop
80103f49:	c9                   	leave  
80103f4a:	c3                   	ret    

80103f4b <commit>:

static void
commit()
{
80103f4b:	55                   	push   %ebp
80103f4c:	89 e5                	mov    %esp,%ebp
80103f4e:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103f51:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103f56:	85 c0                	test   %eax,%eax
80103f58:	7e 1e                	jle    80103f78 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103f5a:	e8 34 ff ff ff       	call   80103e93 <write_log>
    write_head();    // Write header to disk -- the real commit
80103f5f:	e8 3a fd ff ff       	call   80103c9e <write_head>
    install_trans(); // Now install writes to home locations
80103f64:	e8 09 fc ff ff       	call   80103b72 <install_trans>
    log.lh.n = 0; 
80103f69:	c7 05 c8 42 11 80 00 	movl   $0x0,0x801142c8
80103f70:	00 00 00 
    write_head();    // Erase the transaction from the log
80103f73:	e8 26 fd ff ff       	call   80103c9e <write_head>
  }
}
80103f78:	90                   	nop
80103f79:	c9                   	leave  
80103f7a:	c3                   	ret    

80103f7b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103f7b:	55                   	push   %ebp
80103f7c:	89 e5                	mov    %esp,%ebp
80103f7e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103f81:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103f86:	83 f8 1d             	cmp    $0x1d,%eax
80103f89:	7f 12                	jg     80103f9d <log_write+0x22>
80103f8b:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103f90:	8b 15 b8 42 11 80    	mov    0x801142b8,%edx
80103f96:	83 ea 01             	sub    $0x1,%edx
80103f99:	39 d0                	cmp    %edx,%eax
80103f9b:	7c 0d                	jl     80103faa <log_write+0x2f>
    panic("too big a transaction");
80103f9d:	83 ec 0c             	sub    $0xc,%esp
80103fa0:	68 4f a0 10 80       	push   $0x8010a04f
80103fa5:	e8 bc c5 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103faa:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103faf:	85 c0                	test   %eax,%eax
80103fb1:	7f 0d                	jg     80103fc0 <log_write+0x45>
    panic("log_write outside of trans");
80103fb3:	83 ec 0c             	sub    $0xc,%esp
80103fb6:	68 65 a0 10 80       	push   $0x8010a065
80103fbb:	e8 a6 c5 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103fc0:	83 ec 0c             	sub    $0xc,%esp
80103fc3:	68 80 42 11 80       	push   $0x80114280
80103fc8:	e8 9a 1d 00 00       	call   80105d67 <acquire>
80103fcd:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103fd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103fd7:	eb 1d                	jmp    80103ff6 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdc:	83 c0 10             	add    $0x10,%eax
80103fdf:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
80103fe6:	89 c2                	mov    %eax,%edx
80103fe8:	8b 45 08             	mov    0x8(%ebp),%eax
80103feb:	8b 40 08             	mov    0x8(%eax),%eax
80103fee:	39 c2                	cmp    %eax,%edx
80103ff0:	74 10                	je     80104002 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103ff2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ff6:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103ffb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ffe:	7f d9                	jg     80103fd9 <log_write+0x5e>
80104000:	eb 01                	jmp    80104003 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80104002:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80104003:	8b 45 08             	mov    0x8(%ebp),%eax
80104006:	8b 40 08             	mov    0x8(%eax),%eax
80104009:	89 c2                	mov    %eax,%edx
8010400b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400e:	83 c0 10             	add    $0x10,%eax
80104011:	89 14 85 8c 42 11 80 	mov    %edx,-0x7feebd74(,%eax,4)
  if (i == log.lh.n)
80104018:	a1 c8 42 11 80       	mov    0x801142c8,%eax
8010401d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104020:	75 0d                	jne    8010402f <log_write+0xb4>
    log.lh.n++;
80104022:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80104027:	83 c0 01             	add    $0x1,%eax
8010402a:	a3 c8 42 11 80       	mov    %eax,0x801142c8
  b->flags |= B_DIRTY; // prevent eviction
8010402f:	8b 45 08             	mov    0x8(%ebp),%eax
80104032:	8b 00                	mov    (%eax),%eax
80104034:	83 c8 04             	or     $0x4,%eax
80104037:	89 c2                	mov    %eax,%edx
80104039:	8b 45 08             	mov    0x8(%ebp),%eax
8010403c:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010403e:	83 ec 0c             	sub    $0xc,%esp
80104041:	68 80 42 11 80       	push   $0x80114280
80104046:	e8 83 1d 00 00       	call   80105dce <release>
8010404b:	83 c4 10             	add    $0x10,%esp
}
8010404e:	90                   	nop
8010404f:	c9                   	leave  
80104050:	c3                   	ret    

80104051 <v2p>:
80104051:	55                   	push   %ebp
80104052:	89 e5                	mov    %esp,%ebp
80104054:	8b 45 08             	mov    0x8(%ebp),%eax
80104057:	05 00 00 00 80       	add    $0x80000000,%eax
8010405c:	5d                   	pop    %ebp
8010405d:	c3                   	ret    

8010405e <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010405e:	55                   	push   %ebp
8010405f:	89 e5                	mov    %esp,%ebp
80104061:	8b 45 08             	mov    0x8(%ebp),%eax
80104064:	05 00 00 00 80       	add    $0x80000000,%eax
80104069:	5d                   	pop    %ebp
8010406a:	c3                   	ret    

8010406b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010406b:	55                   	push   %ebp
8010406c:	89 e5                	mov    %esp,%ebp
8010406e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104071:	8b 55 08             	mov    0x8(%ebp),%edx
80104074:	8b 45 0c             	mov    0xc(%ebp),%eax
80104077:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010407a:	f0 87 02             	lock xchg %eax,(%edx)
8010407d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104080:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104083:	c9                   	leave  
80104084:	c3                   	ret    

80104085 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80104085:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80104089:	83 e4 f0             	and    $0xfffffff0,%esp
8010408c:	ff 71 fc             	pushl  -0x4(%ecx)
8010408f:	55                   	push   %ebp
80104090:	89 e5                	mov    %esp,%ebp
80104092:	51                   	push   %ecx
80104093:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80104096:	83 ec 08             	sub    $0x8,%esp
80104099:	68 00 00 40 80       	push   $0x80400000
8010409e:	68 5c c3 11 80       	push   $0x8011c35c
801040a3:	e8 13 f2 ff ff       	call   801032bb <kinit1>
801040a8:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801040ab:	e8 0c 4b 00 00       	call   80108bbc <kvmalloc>
  mpinit();        // collect info about this machine
801040b0:	e8 43 04 00 00       	call   801044f8 <mpinit>
  lapicinit();
801040b5:	e8 ea f5 ff ff       	call   801036a4 <lapicinit>
  seginit();       // set up segments
801040ba:	e8 a6 44 00 00       	call   80108565 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801040bf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801040c5:	0f b6 00             	movzbl (%eax),%eax
801040c8:	0f b6 c0             	movzbl %al,%eax
801040cb:	83 ec 08             	sub    $0x8,%esp
801040ce:	50                   	push   %eax
801040cf:	68 80 a0 10 80       	push   $0x8010a080
801040d4:	e8 ed c2 ff ff       	call   801003c6 <cprintf>
801040d9:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801040dc:	e8 6d 06 00 00       	call   8010474e <picinit>
  ioapicinit();    // another interrupt controller
801040e1:	e8 ca f0 ff ff       	call   801031b0 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801040e6:	e8 2e ca ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
801040eb:	e8 d1 37 00 00       	call   801078c1 <uartinit>
  pinit();         // process table
801040f0:	e8 56 0b 00 00       	call   80104c4b <pinit>
  tvinit();        // trap vectors
801040f5:	e8 fd 32 00 00       	call   801073f7 <tvinit>
  binit();         // buffer cache
801040fa:	e8 35 bf ff ff       	call   80100034 <binit>
  fileinit();      // file table
801040ff:	e8 03 d2 ff ff       	call   80101307 <fileinit>
  ideinit();       // disk
80104104:	e8 af ec ff ff       	call   80102db8 <ideinit>
  if(!ismp)
80104109:	a1 64 43 11 80       	mov    0x80114364,%eax
8010410e:	85 c0                	test   %eax,%eax
80104110:	75 05                	jne    80104117 <main+0x92>
    timerinit();   // uniprocessor timer
80104112:	e8 30 32 00 00       	call   80107347 <timerinit>
  startothers();   // start other processors
80104117:	e8 7f 00 00 00       	call   8010419b <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010411c:	83 ec 08             	sub    $0x8,%esp
8010411f:	68 00 00 00 8e       	push   $0x8e000000
80104124:	68 00 00 40 80       	push   $0x80400000
80104129:	e8 e9 f1 ff ff       	call   80103317 <kinit2>
8010412e:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80104131:	e8 f5 0c 00 00       	call   80104e2b <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80104136:	e8 1a 00 00 00       	call   80104155 <mpmain>

8010413b <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010413b:	55                   	push   %ebp
8010413c:	89 e5                	mov    %esp,%ebp
8010413e:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80104141:	e8 8e 4a 00 00       	call   80108bd4 <switchkvm>
  seginit();
80104146:	e8 1a 44 00 00       	call   80108565 <seginit>
  lapicinit();
8010414b:	e8 54 f5 ff ff       	call   801036a4 <lapicinit>
  mpmain();
80104150:	e8 00 00 00 00       	call   80104155 <mpmain>

80104155 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80104155:	55                   	push   %ebp
80104156:	89 e5                	mov    %esp,%ebp
80104158:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010415b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104161:	0f b6 00             	movzbl (%eax),%eax
80104164:	0f b6 c0             	movzbl %al,%eax
80104167:	83 ec 08             	sub    $0x8,%esp
8010416a:	50                   	push   %eax
8010416b:	68 97 a0 10 80       	push   $0x8010a097
80104170:	e8 51 c2 ff ff       	call   801003c6 <cprintf>
80104175:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80104178:	e8 f0 33 00 00       	call   8010756d <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010417d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104183:	05 a8 00 00 00       	add    $0xa8,%eax
80104188:	83 ec 08             	sub    $0x8,%esp
8010418b:	6a 01                	push   $0x1
8010418d:	50                   	push   %eax
8010418e:	e8 d8 fe ff ff       	call   8010406b <xchg>
80104193:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80104196:	e8 22 15 00 00       	call   801056bd <scheduler>

8010419b <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010419b:	55                   	push   %ebp
8010419c:	89 e5                	mov    %esp,%ebp
8010419e:	53                   	push   %ebx
8010419f:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801041a2:	68 00 70 00 00       	push   $0x7000
801041a7:	e8 b2 fe ff ff       	call   8010405e <p2v>
801041ac:	83 c4 04             	add    $0x4,%esp
801041af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801041b2:	b8 8a 00 00 00       	mov    $0x8a,%eax
801041b7:	83 ec 04             	sub    $0x4,%esp
801041ba:	50                   	push   %eax
801041bb:	68 0c d5 10 80       	push   $0x8010d50c
801041c0:	ff 75 f0             	pushl  -0x10(%ebp)
801041c3:	e8 c1 1e 00 00       	call   80106089 <memmove>
801041c8:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801041cb:	c7 45 f4 80 43 11 80 	movl   $0x80114380,-0xc(%ebp)
801041d2:	e9 90 00 00 00       	jmp    80104267 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801041d7:	e8 e6 f5 ff ff       	call   801037c2 <cpunum>
801041dc:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801041e2:	05 80 43 11 80       	add    $0x80114380,%eax
801041e7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041ea:	74 73                	je     8010425f <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801041ec:	e8 5e f2 ff ff       	call   8010344f <kalloc>
801041f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801041f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041f7:	83 e8 04             	sub    $0x4,%eax
801041fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801041fd:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104203:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104205:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104208:	83 e8 08             	sub    $0x8,%eax
8010420b:	c7 00 3b 41 10 80    	movl   $0x8010413b,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80104211:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104214:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104217:	83 ec 0c             	sub    $0xc,%esp
8010421a:	68 00 c0 10 80       	push   $0x8010c000
8010421f:	e8 2d fe ff ff       	call   80104051 <v2p>
80104224:	83 c4 10             	add    $0x10,%esp
80104227:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80104229:	83 ec 0c             	sub    $0xc,%esp
8010422c:	ff 75 f0             	pushl  -0x10(%ebp)
8010422f:	e8 1d fe ff ff       	call   80104051 <v2p>
80104234:	83 c4 10             	add    $0x10,%esp
80104237:	89 c2                	mov    %eax,%edx
80104239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423c:	0f b6 00             	movzbl (%eax),%eax
8010423f:	0f b6 c0             	movzbl %al,%eax
80104242:	83 ec 08             	sub    $0x8,%esp
80104245:	52                   	push   %edx
80104246:	50                   	push   %eax
80104247:	e8 f0 f5 ff ff       	call   8010383c <lapicstartap>
8010424c:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010424f:	90                   	nop
80104250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104253:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104259:	85 c0                	test   %eax,%eax
8010425b:	74 f3                	je     80104250 <startothers+0xb5>
8010425d:	eb 01                	jmp    80104260 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010425f:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80104260:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80104267:	a1 60 49 11 80       	mov    0x80114960,%eax
8010426c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104272:	05 80 43 11 80       	add    $0x80114380,%eax
80104277:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010427a:	0f 87 57 ff ff ff    	ja     801041d7 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80104280:	90                   	nop
80104281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104284:	c9                   	leave  
80104285:	c3                   	ret    

80104286 <p2v>:
80104286:	55                   	push   %ebp
80104287:	89 e5                	mov    %esp,%ebp
80104289:	8b 45 08             	mov    0x8(%ebp),%eax
8010428c:	05 00 00 00 80       	add    $0x80000000,%eax
80104291:	5d                   	pop    %ebp
80104292:	c3                   	ret    

80104293 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80104293:	55                   	push   %ebp
80104294:	89 e5                	mov    %esp,%ebp
80104296:	83 ec 14             	sub    $0x14,%esp
80104299:	8b 45 08             	mov    0x8(%ebp),%eax
8010429c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801042a0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801042a4:	89 c2                	mov    %eax,%edx
801042a6:	ec                   	in     (%dx),%al
801042a7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801042aa:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801042ae:	c9                   	leave  
801042af:	c3                   	ret    

801042b0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801042b0:	55                   	push   %ebp
801042b1:	89 e5                	mov    %esp,%ebp
801042b3:	83 ec 08             	sub    $0x8,%esp
801042b6:	8b 55 08             	mov    0x8(%ebp),%edx
801042b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801042bc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801042c0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801042c3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801042c7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801042cb:	ee                   	out    %al,(%dx)
}
801042cc:	90                   	nop
801042cd:	c9                   	leave  
801042ce:	c3                   	ret    

801042cf <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801042cf:	55                   	push   %ebp
801042d0:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801042d2:	a1 44 d6 10 80       	mov    0x8010d644,%eax
801042d7:	89 c2                	mov    %eax,%edx
801042d9:	b8 80 43 11 80       	mov    $0x80114380,%eax
801042de:	29 c2                	sub    %eax,%edx
801042e0:	89 d0                	mov    %edx,%eax
801042e2:	c1 f8 02             	sar    $0x2,%eax
801042e5:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801042eb:	5d                   	pop    %ebp
801042ec:	c3                   	ret    

801042ed <sum>:

static uchar
sum(uchar *addr, int len)
{
801042ed:	55                   	push   %ebp
801042ee:	89 e5                	mov    %esp,%ebp
801042f0:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801042f3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801042fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104301:	eb 15                	jmp    80104318 <sum+0x2b>
    sum += addr[i];
80104303:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104306:	8b 45 08             	mov    0x8(%ebp),%eax
80104309:	01 d0                	add    %edx,%eax
8010430b:	0f b6 00             	movzbl (%eax),%eax
8010430e:	0f b6 c0             	movzbl %al,%eax
80104311:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104314:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104318:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010431b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010431e:	7c e3                	jl     80104303 <sum+0x16>
    sum += addr[i];
  return sum;
80104320:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104323:	c9                   	leave  
80104324:	c3                   	ret    

80104325 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104325:	55                   	push   %ebp
80104326:	89 e5                	mov    %esp,%ebp
80104328:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
8010432b:	ff 75 08             	pushl  0x8(%ebp)
8010432e:	e8 53 ff ff ff       	call   80104286 <p2v>
80104333:	83 c4 04             	add    $0x4,%esp
80104336:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80104339:	8b 55 0c             	mov    0xc(%ebp),%edx
8010433c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010433f:	01 d0                	add    %edx,%eax
80104341:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104344:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104347:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010434a:	eb 36                	jmp    80104382 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010434c:	83 ec 04             	sub    $0x4,%esp
8010434f:	6a 04                	push   $0x4
80104351:	68 a8 a0 10 80       	push   $0x8010a0a8
80104356:	ff 75 f4             	pushl  -0xc(%ebp)
80104359:	e8 d3 1c 00 00       	call   80106031 <memcmp>
8010435e:	83 c4 10             	add    $0x10,%esp
80104361:	85 c0                	test   %eax,%eax
80104363:	75 19                	jne    8010437e <mpsearch1+0x59>
80104365:	83 ec 08             	sub    $0x8,%esp
80104368:	6a 10                	push   $0x10
8010436a:	ff 75 f4             	pushl  -0xc(%ebp)
8010436d:	e8 7b ff ff ff       	call   801042ed <sum>
80104372:	83 c4 10             	add    $0x10,%esp
80104375:	84 c0                	test   %al,%al
80104377:	75 05                	jne    8010437e <mpsearch1+0x59>
      return (struct mp*)p;
80104379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437c:	eb 11                	jmp    8010438f <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
8010437e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80104382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104385:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104388:	72 c2                	jb     8010434c <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
8010438a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010438f:	c9                   	leave  
80104390:	c3                   	ret    

80104391 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80104391:	55                   	push   %ebp
80104392:	89 e5                	mov    %esp,%ebp
80104394:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80104397:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
8010439e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a1:	83 c0 0f             	add    $0xf,%eax
801043a4:	0f b6 00             	movzbl (%eax),%eax
801043a7:	0f b6 c0             	movzbl %al,%eax
801043aa:	c1 e0 08             	shl    $0x8,%eax
801043ad:	89 c2                	mov    %eax,%edx
801043af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b2:	83 c0 0e             	add    $0xe,%eax
801043b5:	0f b6 00             	movzbl (%eax),%eax
801043b8:	0f b6 c0             	movzbl %al,%eax
801043bb:	09 d0                	or     %edx,%eax
801043bd:	c1 e0 04             	shl    $0x4,%eax
801043c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801043c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801043c7:	74 21                	je     801043ea <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801043c9:	83 ec 08             	sub    $0x8,%esp
801043cc:	68 00 04 00 00       	push   $0x400
801043d1:	ff 75 f0             	pushl  -0x10(%ebp)
801043d4:	e8 4c ff ff ff       	call   80104325 <mpsearch1>
801043d9:	83 c4 10             	add    $0x10,%esp
801043dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801043df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801043e3:	74 51                	je     80104436 <mpsearch+0xa5>
      return mp;
801043e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043e8:	eb 61                	jmp    8010444b <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801043ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ed:	83 c0 14             	add    $0x14,%eax
801043f0:	0f b6 00             	movzbl (%eax),%eax
801043f3:	0f b6 c0             	movzbl %al,%eax
801043f6:	c1 e0 08             	shl    $0x8,%eax
801043f9:	89 c2                	mov    %eax,%edx
801043fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fe:	83 c0 13             	add    $0x13,%eax
80104401:	0f b6 00             	movzbl (%eax),%eax
80104404:	0f b6 c0             	movzbl %al,%eax
80104407:	09 d0                	or     %edx,%eax
80104409:	c1 e0 0a             	shl    $0xa,%eax
8010440c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
8010440f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104412:	2d 00 04 00 00       	sub    $0x400,%eax
80104417:	83 ec 08             	sub    $0x8,%esp
8010441a:	68 00 04 00 00       	push   $0x400
8010441f:	50                   	push   %eax
80104420:	e8 00 ff ff ff       	call   80104325 <mpsearch1>
80104425:	83 c4 10             	add    $0x10,%esp
80104428:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010442b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010442f:	74 05                	je     80104436 <mpsearch+0xa5>
      return mp;
80104431:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104434:	eb 15                	jmp    8010444b <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80104436:	83 ec 08             	sub    $0x8,%esp
80104439:	68 00 00 01 00       	push   $0x10000
8010443e:	68 00 00 0f 00       	push   $0xf0000
80104443:	e8 dd fe ff ff       	call   80104325 <mpsearch1>
80104448:	83 c4 10             	add    $0x10,%esp
}
8010444b:	c9                   	leave  
8010444c:	c3                   	ret    

8010444d <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
8010444d:	55                   	push   %ebp
8010444e:	89 e5                	mov    %esp,%ebp
80104450:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104453:	e8 39 ff ff ff       	call   80104391 <mpsearch>
80104458:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010445b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010445f:	74 0a                	je     8010446b <mpconfig+0x1e>
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	8b 40 04             	mov    0x4(%eax),%eax
80104467:	85 c0                	test   %eax,%eax
80104469:	75 0a                	jne    80104475 <mpconfig+0x28>
    return 0;
8010446b:	b8 00 00 00 00       	mov    $0x0,%eax
80104470:	e9 81 00 00 00       	jmp    801044f6 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80104475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104478:	8b 40 04             	mov    0x4(%eax),%eax
8010447b:	83 ec 0c             	sub    $0xc,%esp
8010447e:	50                   	push   %eax
8010447f:	e8 02 fe ff ff       	call   80104286 <p2v>
80104484:	83 c4 10             	add    $0x10,%esp
80104487:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010448a:	83 ec 04             	sub    $0x4,%esp
8010448d:	6a 04                	push   $0x4
8010448f:	68 ad a0 10 80       	push   $0x8010a0ad
80104494:	ff 75 f0             	pushl  -0x10(%ebp)
80104497:	e8 95 1b 00 00       	call   80106031 <memcmp>
8010449c:	83 c4 10             	add    $0x10,%esp
8010449f:	85 c0                	test   %eax,%eax
801044a1:	74 07                	je     801044aa <mpconfig+0x5d>
    return 0;
801044a3:	b8 00 00 00 00       	mov    $0x0,%eax
801044a8:	eb 4c                	jmp    801044f6 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801044aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ad:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801044b1:	3c 01                	cmp    $0x1,%al
801044b3:	74 12                	je     801044c7 <mpconfig+0x7a>
801044b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b8:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801044bc:	3c 04                	cmp    $0x4,%al
801044be:	74 07                	je     801044c7 <mpconfig+0x7a>
    return 0;
801044c0:	b8 00 00 00 00       	mov    $0x0,%eax
801044c5:	eb 2f                	jmp    801044f6 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801044c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ca:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801044ce:	0f b7 c0             	movzwl %ax,%eax
801044d1:	83 ec 08             	sub    $0x8,%esp
801044d4:	50                   	push   %eax
801044d5:	ff 75 f0             	pushl  -0x10(%ebp)
801044d8:	e8 10 fe ff ff       	call   801042ed <sum>
801044dd:	83 c4 10             	add    $0x10,%esp
801044e0:	84 c0                	test   %al,%al
801044e2:	74 07                	je     801044eb <mpconfig+0x9e>
    return 0;
801044e4:	b8 00 00 00 00       	mov    $0x0,%eax
801044e9:	eb 0b                	jmp    801044f6 <mpconfig+0xa9>
  *pmp = mp;
801044eb:	8b 45 08             	mov    0x8(%ebp),%eax
801044ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f1:	89 10                	mov    %edx,(%eax)
  return conf;
801044f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801044f6:	c9                   	leave  
801044f7:	c3                   	ret    

801044f8 <mpinit>:

void
mpinit(void)
{
801044f8:	55                   	push   %ebp
801044f9:	89 e5                	mov    %esp,%ebp
801044fb:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
801044fe:	c7 05 44 d6 10 80 80 	movl   $0x80114380,0x8010d644
80104505:	43 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104508:	83 ec 0c             	sub    $0xc,%esp
8010450b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010450e:	50                   	push   %eax
8010450f:	e8 39 ff ff ff       	call   8010444d <mpconfig>
80104514:	83 c4 10             	add    $0x10,%esp
80104517:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010451a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010451e:	0f 84 96 01 00 00    	je     801046ba <mpinit+0x1c2>
    return;
  ismp = 1;
80104524:	c7 05 64 43 11 80 01 	movl   $0x1,0x80114364
8010452b:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
8010452e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104531:	8b 40 24             	mov    0x24(%eax),%eax
80104534:	a3 64 42 11 80       	mov    %eax,0x80114264
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104539:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010453c:	83 c0 2c             	add    $0x2c,%eax
8010453f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104542:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104545:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104549:	0f b7 d0             	movzwl %ax,%edx
8010454c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010454f:	01 d0                	add    %edx,%eax
80104551:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104554:	e9 f2 00 00 00       	jmp    8010464b <mpinit+0x153>
    switch(*p){
80104559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455c:	0f b6 00             	movzbl (%eax),%eax
8010455f:	0f b6 c0             	movzbl %al,%eax
80104562:	83 f8 04             	cmp    $0x4,%eax
80104565:	0f 87 bc 00 00 00    	ja     80104627 <mpinit+0x12f>
8010456b:	8b 04 85 f0 a0 10 80 	mov    -0x7fef5f10(,%eax,4),%eax
80104572:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80104574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104577:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
8010457a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010457d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104581:	0f b6 d0             	movzbl %al,%edx
80104584:	a1 60 49 11 80       	mov    0x80114960,%eax
80104589:	39 c2                	cmp    %eax,%edx
8010458b:	74 2b                	je     801045b8 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
8010458d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104590:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104594:	0f b6 d0             	movzbl %al,%edx
80104597:	a1 60 49 11 80       	mov    0x80114960,%eax
8010459c:	83 ec 04             	sub    $0x4,%esp
8010459f:	52                   	push   %edx
801045a0:	50                   	push   %eax
801045a1:	68 b2 a0 10 80       	push   $0x8010a0b2
801045a6:	e8 1b be ff ff       	call   801003c6 <cprintf>
801045ab:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801045ae:	c7 05 64 43 11 80 00 	movl   $0x0,0x80114364
801045b5:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801045b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801045bb:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801045bf:	0f b6 c0             	movzbl %al,%eax
801045c2:	83 e0 02             	and    $0x2,%eax
801045c5:	85 c0                	test   %eax,%eax
801045c7:	74 15                	je     801045de <mpinit+0xe6>
        bcpu = &cpus[ncpu];
801045c9:	a1 60 49 11 80       	mov    0x80114960,%eax
801045ce:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801045d4:	05 80 43 11 80       	add    $0x80114380,%eax
801045d9:	a3 44 d6 10 80       	mov    %eax,0x8010d644
      cpus[ncpu].id = ncpu;
801045de:	a1 60 49 11 80       	mov    0x80114960,%eax
801045e3:	8b 15 60 49 11 80    	mov    0x80114960,%edx
801045e9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801045ef:	05 80 43 11 80       	add    $0x80114380,%eax
801045f4:	88 10                	mov    %dl,(%eax)
      ncpu++;
801045f6:	a1 60 49 11 80       	mov    0x80114960,%eax
801045fb:	83 c0 01             	add    $0x1,%eax
801045fe:	a3 60 49 11 80       	mov    %eax,0x80114960
      p += sizeof(struct mpproc);
80104603:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104607:	eb 42                	jmp    8010464b <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
8010460f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104612:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104616:	a2 60 43 11 80       	mov    %al,0x80114360
      p += sizeof(struct mpioapic);
8010461b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010461f:	eb 2a                	jmp    8010464b <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104621:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104625:	eb 24                	jmp    8010464b <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462a:	0f b6 00             	movzbl (%eax),%eax
8010462d:	0f b6 c0             	movzbl %al,%eax
80104630:	83 ec 08             	sub    $0x8,%esp
80104633:	50                   	push   %eax
80104634:	68 d0 a0 10 80       	push   $0x8010a0d0
80104639:	e8 88 bd ff ff       	call   801003c6 <cprintf>
8010463e:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104641:	c7 05 64 43 11 80 00 	movl   $0x0,0x80114364
80104648:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010464b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104651:	0f 82 02 ff ff ff    	jb     80104559 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104657:	a1 64 43 11 80       	mov    0x80114364,%eax
8010465c:	85 c0                	test   %eax,%eax
8010465e:	75 1d                	jne    8010467d <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104660:	c7 05 60 49 11 80 01 	movl   $0x1,0x80114960
80104667:	00 00 00 
    lapic = 0;
8010466a:	c7 05 64 42 11 80 00 	movl   $0x0,0x80114264
80104671:	00 00 00 
    ioapicid = 0;
80104674:	c6 05 60 43 11 80 00 	movb   $0x0,0x80114360
    return;
8010467b:	eb 3e                	jmp    801046bb <mpinit+0x1c3>
  }

  if(mp->imcrp){
8010467d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104680:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80104684:	84 c0                	test   %al,%al
80104686:	74 33                	je     801046bb <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104688:	83 ec 08             	sub    $0x8,%esp
8010468b:	6a 70                	push   $0x70
8010468d:	6a 22                	push   $0x22
8010468f:	e8 1c fc ff ff       	call   801042b0 <outb>
80104694:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104697:	83 ec 0c             	sub    $0xc,%esp
8010469a:	6a 23                	push   $0x23
8010469c:	e8 f2 fb ff ff       	call   80104293 <inb>
801046a1:	83 c4 10             	add    $0x10,%esp
801046a4:	83 c8 01             	or     $0x1,%eax
801046a7:	0f b6 c0             	movzbl %al,%eax
801046aa:	83 ec 08             	sub    $0x8,%esp
801046ad:	50                   	push   %eax
801046ae:	6a 23                	push   $0x23
801046b0:	e8 fb fb ff ff       	call   801042b0 <outb>
801046b5:	83 c4 10             	add    $0x10,%esp
801046b8:	eb 01                	jmp    801046bb <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801046ba:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801046bb:	c9                   	leave  
801046bc:	c3                   	ret    

801046bd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801046bd:	55                   	push   %ebp
801046be:	89 e5                	mov    %esp,%ebp
801046c0:	83 ec 08             	sub    $0x8,%esp
801046c3:	8b 55 08             	mov    0x8(%ebp),%edx
801046c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801046c9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801046cd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801046d0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801046d4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801046d8:	ee                   	out    %al,(%dx)
}
801046d9:	90                   	nop
801046da:	c9                   	leave  
801046db:	c3                   	ret    

801046dc <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
801046dc:	55                   	push   %ebp
801046dd:	89 e5                	mov    %esp,%ebp
801046df:	83 ec 04             	sub    $0x4,%esp
801046e2:	8b 45 08             	mov    0x8(%ebp),%eax
801046e5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
801046e9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801046ed:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
  outb(IO_PIC1+1, mask);
801046f3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801046f7:	0f b6 c0             	movzbl %al,%eax
801046fa:	50                   	push   %eax
801046fb:	6a 21                	push   $0x21
801046fd:	e8 bb ff ff ff       	call   801046bd <outb>
80104702:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104705:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104709:	66 c1 e8 08          	shr    $0x8,%ax
8010470d:	0f b6 c0             	movzbl %al,%eax
80104710:	50                   	push   %eax
80104711:	68 a1 00 00 00       	push   $0xa1
80104716:	e8 a2 ff ff ff       	call   801046bd <outb>
8010471b:	83 c4 08             	add    $0x8,%esp
}
8010471e:	90                   	nop
8010471f:	c9                   	leave  
80104720:	c3                   	ret    

80104721 <picenable>:

void
picenable(int irq)
{
80104721:	55                   	push   %ebp
80104722:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104724:	8b 45 08             	mov    0x8(%ebp),%eax
80104727:	ba 01 00 00 00       	mov    $0x1,%edx
8010472c:	89 c1                	mov    %eax,%ecx
8010472e:	d3 e2                	shl    %cl,%edx
80104730:	89 d0                	mov    %edx,%eax
80104732:	f7 d0                	not    %eax
80104734:	89 c2                	mov    %eax,%edx
80104736:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
8010473d:	21 d0                	and    %edx,%eax
8010473f:	0f b7 c0             	movzwl %ax,%eax
80104742:	50                   	push   %eax
80104743:	e8 94 ff ff ff       	call   801046dc <picsetmask>
80104748:	83 c4 04             	add    $0x4,%esp
}
8010474b:	90                   	nop
8010474c:	c9                   	leave  
8010474d:	c3                   	ret    

8010474e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
8010474e:	55                   	push   %ebp
8010474f:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104751:	68 ff 00 00 00       	push   $0xff
80104756:	6a 21                	push   $0x21
80104758:	e8 60 ff ff ff       	call   801046bd <outb>
8010475d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104760:	68 ff 00 00 00       	push   $0xff
80104765:	68 a1 00 00 00       	push   $0xa1
8010476a:	e8 4e ff ff ff       	call   801046bd <outb>
8010476f:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104772:	6a 11                	push   $0x11
80104774:	6a 20                	push   $0x20
80104776:	e8 42 ff ff ff       	call   801046bd <outb>
8010477b:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010477e:	6a 20                	push   $0x20
80104780:	6a 21                	push   $0x21
80104782:	e8 36 ff ff ff       	call   801046bd <outb>
80104787:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
8010478a:	6a 04                	push   $0x4
8010478c:	6a 21                	push   $0x21
8010478e:	e8 2a ff ff ff       	call   801046bd <outb>
80104793:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104796:	6a 03                	push   $0x3
80104798:	6a 21                	push   $0x21
8010479a:	e8 1e ff ff ff       	call   801046bd <outb>
8010479f:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801047a2:	6a 11                	push   $0x11
801047a4:	68 a0 00 00 00       	push   $0xa0
801047a9:	e8 0f ff ff ff       	call   801046bd <outb>
801047ae:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801047b1:	6a 28                	push   $0x28
801047b3:	68 a1 00 00 00       	push   $0xa1
801047b8:	e8 00 ff ff ff       	call   801046bd <outb>
801047bd:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801047c0:	6a 02                	push   $0x2
801047c2:	68 a1 00 00 00       	push   $0xa1
801047c7:	e8 f1 fe ff ff       	call   801046bd <outb>
801047cc:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801047cf:	6a 03                	push   $0x3
801047d1:	68 a1 00 00 00       	push   $0xa1
801047d6:	e8 e2 fe ff ff       	call   801046bd <outb>
801047db:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801047de:	6a 68                	push   $0x68
801047e0:	6a 20                	push   $0x20
801047e2:	e8 d6 fe ff ff       	call   801046bd <outb>
801047e7:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
801047ea:	6a 0a                	push   $0xa
801047ec:	6a 20                	push   $0x20
801047ee:	e8 ca fe ff ff       	call   801046bd <outb>
801047f3:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
801047f6:	6a 68                	push   $0x68
801047f8:	68 a0 00 00 00       	push   $0xa0
801047fd:	e8 bb fe ff ff       	call   801046bd <outb>
80104802:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104805:	6a 0a                	push   $0xa
80104807:	68 a0 00 00 00       	push   $0xa0
8010480c:	e8 ac fe ff ff       	call   801046bd <outb>
80104811:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104814:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
8010481b:	66 83 f8 ff          	cmp    $0xffff,%ax
8010481f:	74 13                	je     80104834 <picinit+0xe6>
    picsetmask(irqmask);
80104821:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104828:	0f b7 c0             	movzwl %ax,%eax
8010482b:	50                   	push   %eax
8010482c:	e8 ab fe ff ff       	call   801046dc <picsetmask>
80104831:	83 c4 04             	add    $0x4,%esp
}
80104834:	90                   	nop
80104835:	c9                   	leave  
80104836:	c3                   	ret    

80104837 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104837:	55                   	push   %ebp
80104838:	89 e5                	mov    %esp,%ebp
8010483a:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010483d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104844:	8b 45 0c             	mov    0xc(%ebp),%eax
80104847:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010484d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104850:	8b 10                	mov    (%eax),%edx
80104852:	8b 45 08             	mov    0x8(%ebp),%eax
80104855:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104857:	e8 c9 ca ff ff       	call   80101325 <filealloc>
8010485c:	89 c2                	mov    %eax,%edx
8010485e:	8b 45 08             	mov    0x8(%ebp),%eax
80104861:	89 10                	mov    %edx,(%eax)
80104863:	8b 45 08             	mov    0x8(%ebp),%eax
80104866:	8b 00                	mov    (%eax),%eax
80104868:	85 c0                	test   %eax,%eax
8010486a:	0f 84 cb 00 00 00    	je     8010493b <pipealloc+0x104>
80104870:	e8 b0 ca ff ff       	call   80101325 <filealloc>
80104875:	89 c2                	mov    %eax,%edx
80104877:	8b 45 0c             	mov    0xc(%ebp),%eax
8010487a:	89 10                	mov    %edx,(%eax)
8010487c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010487f:	8b 00                	mov    (%eax),%eax
80104881:	85 c0                	test   %eax,%eax
80104883:	0f 84 b2 00 00 00    	je     8010493b <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104889:	e8 c1 eb ff ff       	call   8010344f <kalloc>
8010488e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104891:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104895:	0f 84 9f 00 00 00    	je     8010493a <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
8010489b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489e:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801048a5:	00 00 00 
  p->writeopen = 1;
801048a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ab:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801048b2:	00 00 00 
  p->nwrite = 0;
801048b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b8:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801048bf:	00 00 00 
  p->nread = 0;
801048c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c5:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801048cc:	00 00 00 
  initlock(&p->lock, "pipe");
801048cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d2:	83 ec 08             	sub    $0x8,%esp
801048d5:	68 04 a1 10 80       	push   $0x8010a104
801048da:	50                   	push   %eax
801048db:	e8 65 14 00 00       	call   80105d45 <initlock>
801048e0:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801048e3:	8b 45 08             	mov    0x8(%ebp),%eax
801048e6:	8b 00                	mov    (%eax),%eax
801048e8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801048ee:	8b 45 08             	mov    0x8(%ebp),%eax
801048f1:	8b 00                	mov    (%eax),%eax
801048f3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801048f7:	8b 45 08             	mov    0x8(%ebp),%eax
801048fa:	8b 00                	mov    (%eax),%eax
801048fc:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104900:	8b 45 08             	mov    0x8(%ebp),%eax
80104903:	8b 00                	mov    (%eax),%eax
80104905:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104908:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010490b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010490e:	8b 00                	mov    (%eax),%eax
80104910:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104916:	8b 45 0c             	mov    0xc(%ebp),%eax
80104919:	8b 00                	mov    (%eax),%eax
8010491b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010491f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104922:	8b 00                	mov    (%eax),%eax
80104924:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104928:	8b 45 0c             	mov    0xc(%ebp),%eax
8010492b:	8b 00                	mov    (%eax),%eax
8010492d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104930:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104933:	b8 00 00 00 00       	mov    $0x0,%eax
80104938:	eb 4e                	jmp    80104988 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010493a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010493b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010493f:	74 0e                	je     8010494f <pipealloc+0x118>
    kfree((char*)p);
80104941:	83 ec 0c             	sub    $0xc,%esp
80104944:	ff 75 f4             	pushl  -0xc(%ebp)
80104947:	e8 59 ea ff ff       	call   801033a5 <kfree>
8010494c:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010494f:	8b 45 08             	mov    0x8(%ebp),%eax
80104952:	8b 00                	mov    (%eax),%eax
80104954:	85 c0                	test   %eax,%eax
80104956:	74 11                	je     80104969 <pipealloc+0x132>
    fileclose(*f0);
80104958:	8b 45 08             	mov    0x8(%ebp),%eax
8010495b:	8b 00                	mov    (%eax),%eax
8010495d:	83 ec 0c             	sub    $0xc,%esp
80104960:	50                   	push   %eax
80104961:	e8 7d ca ff ff       	call   801013e3 <fileclose>
80104966:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104969:	8b 45 0c             	mov    0xc(%ebp),%eax
8010496c:	8b 00                	mov    (%eax),%eax
8010496e:	85 c0                	test   %eax,%eax
80104970:	74 11                	je     80104983 <pipealloc+0x14c>
    fileclose(*f1);
80104972:	8b 45 0c             	mov    0xc(%ebp),%eax
80104975:	8b 00                	mov    (%eax),%eax
80104977:	83 ec 0c             	sub    $0xc,%esp
8010497a:	50                   	push   %eax
8010497b:	e8 63 ca ff ff       	call   801013e3 <fileclose>
80104980:	83 c4 10             	add    $0x10,%esp
  return -1;
80104983:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104988:	c9                   	leave  
80104989:	c3                   	ret    

8010498a <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010498a:	55                   	push   %ebp
8010498b:	89 e5                	mov    %esp,%ebp
8010498d:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104990:	8b 45 08             	mov    0x8(%ebp),%eax
80104993:	83 ec 0c             	sub    $0xc,%esp
80104996:	50                   	push   %eax
80104997:	e8 cb 13 00 00       	call   80105d67 <acquire>
8010499c:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010499f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801049a3:	74 23                	je     801049c8 <pipeclose+0x3e>
    p->writeopen = 0;
801049a5:	8b 45 08             	mov    0x8(%ebp),%eax
801049a8:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801049af:	00 00 00 
    wakeup(&p->nread);
801049b2:	8b 45 08             	mov    0x8(%ebp),%eax
801049b5:	05 34 02 00 00       	add    $0x234,%eax
801049ba:	83 ec 0c             	sub    $0xc,%esp
801049bd:	50                   	push   %eax
801049be:	e8 cd 0f 00 00       	call   80105990 <wakeup>
801049c3:	83 c4 10             	add    $0x10,%esp
801049c6:	eb 21                	jmp    801049e9 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801049c8:	8b 45 08             	mov    0x8(%ebp),%eax
801049cb:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801049d2:	00 00 00 
    wakeup(&p->nwrite);
801049d5:	8b 45 08             	mov    0x8(%ebp),%eax
801049d8:	05 38 02 00 00       	add    $0x238,%eax
801049dd:	83 ec 0c             	sub    $0xc,%esp
801049e0:	50                   	push   %eax
801049e1:	e8 aa 0f 00 00       	call   80105990 <wakeup>
801049e6:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801049e9:	8b 45 08             	mov    0x8(%ebp),%eax
801049ec:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801049f2:	85 c0                	test   %eax,%eax
801049f4:	75 2c                	jne    80104a22 <pipeclose+0x98>
801049f6:	8b 45 08             	mov    0x8(%ebp),%eax
801049f9:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801049ff:	85 c0                	test   %eax,%eax
80104a01:	75 1f                	jne    80104a22 <pipeclose+0x98>
    release(&p->lock);
80104a03:	8b 45 08             	mov    0x8(%ebp),%eax
80104a06:	83 ec 0c             	sub    $0xc,%esp
80104a09:	50                   	push   %eax
80104a0a:	e8 bf 13 00 00       	call   80105dce <release>
80104a0f:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104a12:	83 ec 0c             	sub    $0xc,%esp
80104a15:	ff 75 08             	pushl  0x8(%ebp)
80104a18:	e8 88 e9 ff ff       	call   801033a5 <kfree>
80104a1d:	83 c4 10             	add    $0x10,%esp
80104a20:	eb 0f                	jmp    80104a31 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104a22:	8b 45 08             	mov    0x8(%ebp),%eax
80104a25:	83 ec 0c             	sub    $0xc,%esp
80104a28:	50                   	push   %eax
80104a29:	e8 a0 13 00 00       	call   80105dce <release>
80104a2e:	83 c4 10             	add    $0x10,%esp
}
80104a31:	90                   	nop
80104a32:	c9                   	leave  
80104a33:	c3                   	ret    

80104a34 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104a34:	55                   	push   %ebp
80104a35:	89 e5                	mov    %esp,%ebp
80104a37:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3d:	83 ec 0c             	sub    $0xc,%esp
80104a40:	50                   	push   %eax
80104a41:	e8 21 13 00 00       	call   80105d67 <acquire>
80104a46:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104a49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a50:	e9 ad 00 00 00       	jmp    80104b02 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104a55:	8b 45 08             	mov    0x8(%ebp),%eax
80104a58:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104a5e:	85 c0                	test   %eax,%eax
80104a60:	74 0d                	je     80104a6f <pipewrite+0x3b>
80104a62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a68:	8b 40 24             	mov    0x24(%eax),%eax
80104a6b:	85 c0                	test   %eax,%eax
80104a6d:	74 19                	je     80104a88 <pipewrite+0x54>
        release(&p->lock);
80104a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a72:	83 ec 0c             	sub    $0xc,%esp
80104a75:	50                   	push   %eax
80104a76:	e8 53 13 00 00       	call   80105dce <release>
80104a7b:	83 c4 10             	add    $0x10,%esp
        return -1;
80104a7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a83:	e9 a8 00 00 00       	jmp    80104b30 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104a88:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8b:	05 34 02 00 00       	add    $0x234,%eax
80104a90:	83 ec 0c             	sub    $0xc,%esp
80104a93:	50                   	push   %eax
80104a94:	e8 f7 0e 00 00       	call   80105990 <wakeup>
80104a99:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a9f:	8b 55 08             	mov    0x8(%ebp),%edx
80104aa2:	81 c2 38 02 00 00    	add    $0x238,%edx
80104aa8:	83 ec 08             	sub    $0x8,%esp
80104aab:	50                   	push   %eax
80104aac:	52                   	push   %edx
80104aad:	e8 f0 0d 00 00       	call   801058a2 <sleep>
80104ab2:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab8:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104abe:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104ac7:	05 00 02 00 00       	add    $0x200,%eax
80104acc:	39 c2                	cmp    %eax,%edx
80104ace:	74 85                	je     80104a55 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ad9:	8d 48 01             	lea    0x1(%eax),%ecx
80104adc:	8b 55 08             	mov    0x8(%ebp),%edx
80104adf:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104ae5:	25 ff 01 00 00       	and    $0x1ff,%eax
80104aea:	89 c1                	mov    %eax,%ecx
80104aec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104aef:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af2:	01 d0                	add    %edx,%eax
80104af4:	0f b6 10             	movzbl (%eax),%edx
80104af7:	8b 45 08             	mov    0x8(%ebp),%eax
80104afa:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104afe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b05:	3b 45 10             	cmp    0x10(%ebp),%eax
80104b08:	7c ab                	jl     80104ab5 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0d:	05 34 02 00 00       	add    $0x234,%eax
80104b12:	83 ec 0c             	sub    $0xc,%esp
80104b15:	50                   	push   %eax
80104b16:	e8 75 0e 00 00       	call   80105990 <wakeup>
80104b1b:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b21:	83 ec 0c             	sub    $0xc,%esp
80104b24:	50                   	push   %eax
80104b25:	e8 a4 12 00 00       	call   80105dce <release>
80104b2a:	83 c4 10             	add    $0x10,%esp
  return n;
80104b2d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104b30:	c9                   	leave  
80104b31:	c3                   	ret    

80104b32 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104b32:	55                   	push   %ebp
80104b33:	89 e5                	mov    %esp,%ebp
80104b35:	53                   	push   %ebx
80104b36:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104b39:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3c:	83 ec 0c             	sub    $0xc,%esp
80104b3f:	50                   	push   %eax
80104b40:	e8 22 12 00 00       	call   80105d67 <acquire>
80104b45:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104b48:	eb 3f                	jmp    80104b89 <piperead+0x57>
    if(proc->killed){
80104b4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b50:	8b 40 24             	mov    0x24(%eax),%eax
80104b53:	85 c0                	test   %eax,%eax
80104b55:	74 19                	je     80104b70 <piperead+0x3e>
      release(&p->lock);
80104b57:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5a:	83 ec 0c             	sub    $0xc,%esp
80104b5d:	50                   	push   %eax
80104b5e:	e8 6b 12 00 00       	call   80105dce <release>
80104b63:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6b:	e9 bf 00 00 00       	jmp    80104c2f <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104b70:	8b 45 08             	mov    0x8(%ebp),%eax
80104b73:	8b 55 08             	mov    0x8(%ebp),%edx
80104b76:	81 c2 34 02 00 00    	add    $0x234,%edx
80104b7c:	83 ec 08             	sub    $0x8,%esp
80104b7f:	50                   	push   %eax
80104b80:	52                   	push   %edx
80104b81:	e8 1c 0d 00 00       	call   801058a2 <sleep>
80104b86:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104b89:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8c:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104b92:	8b 45 08             	mov    0x8(%ebp),%eax
80104b95:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104b9b:	39 c2                	cmp    %eax,%edx
80104b9d:	75 0d                	jne    80104bac <piperead+0x7a>
80104b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba2:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104ba8:	85 c0                	test   %eax,%eax
80104baa:	75 9e                	jne    80104b4a <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104bac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bb3:	eb 49                	jmp    80104bfe <piperead+0xcc>
    if(p->nread == p->nwrite)
80104bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104bc7:	39 c2                	cmp    %eax,%edx
80104bc9:	74 3d                	je     80104c08 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104bcb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bce:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104bdd:	8d 48 01             	lea    0x1(%eax),%ecx
80104be0:	8b 55 08             	mov    0x8(%ebp),%edx
80104be3:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104be9:	25 ff 01 00 00       	and    $0x1ff,%eax
80104bee:	89 c2                	mov    %eax,%edx
80104bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf3:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104bf8:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104bfa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c01:	3b 45 10             	cmp    0x10(%ebp),%eax
80104c04:	7c af                	jl     80104bb5 <piperead+0x83>
80104c06:	eb 01                	jmp    80104c09 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104c08:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104c09:	8b 45 08             	mov    0x8(%ebp),%eax
80104c0c:	05 38 02 00 00       	add    $0x238,%eax
80104c11:	83 ec 0c             	sub    $0xc,%esp
80104c14:	50                   	push   %eax
80104c15:	e8 76 0d 00 00       	call   80105990 <wakeup>
80104c1a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c20:	83 ec 0c             	sub    $0xc,%esp
80104c23:	50                   	push   %eax
80104c24:	e8 a5 11 00 00       	call   80105dce <release>
80104c29:	83 c4 10             	add    $0x10,%esp
  return i;
80104c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104c2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c32:	c9                   	leave  
80104c33:	c3                   	ret    

80104c34 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104c34:	55                   	push   %ebp
80104c35:	89 e5                	mov    %esp,%ebp
80104c37:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104c3a:	9c                   	pushf  
80104c3b:	58                   	pop    %eax
80104c3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104c3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c42:	c9                   	leave  
80104c43:	c3                   	ret    

80104c44 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104c44:	55                   	push   %ebp
80104c45:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104c47:	fb                   	sti    
}
80104c48:	90                   	nop
80104c49:	5d                   	pop    %ebp
80104c4a:	c3                   	ret    

80104c4b <pinit>:



void
pinit(void)
{
80104c4b:	55                   	push   %ebp
80104c4c:	89 e5                	mov    %esp,%ebp
80104c4e:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104c51:	83 ec 08             	sub    $0x8,%esp
80104c54:	68 0c a1 10 80       	push   $0x8010a10c
80104c59:	68 80 49 11 80       	push   $0x80114980
80104c5e:	e8 e2 10 00 00       	call   80105d45 <initlock>
80104c63:	83 c4 10             	add    $0x10,%esp
}
80104c66:	90                   	nop
80104c67:	c9                   	leave  
80104c68:	c3                   	ret    

80104c69 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104c69:	55                   	push   %ebp
80104c6a:	89 e5                	mov    %esp,%ebp
80104c6c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104c6f:	83 ec 0c             	sub    $0xc,%esp
80104c72:	68 80 49 11 80       	push   $0x80114980
80104c77:	e8 eb 10 00 00       	call   80105d67 <acquire>
80104c7c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c7f:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
80104c86:	eb 11                	jmp    80104c99 <allocproc+0x30>
    if(p->state == UNUSED)
80104c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c8e:	85 c0                	test   %eax,%eax
80104c90:	74 2a                	je     80104cbc <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c92:	81 45 f4 c4 01 00 00 	addl   $0x1c4,-0xc(%ebp)
80104c99:	81 7d f4 b4 ba 11 80 	cmpl   $0x8011bab4,-0xc(%ebp)
80104ca0:	72 e6                	jb     80104c88 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104ca2:	83 ec 0c             	sub    $0xc,%esp
80104ca5:	68 80 49 11 80       	push   $0x80114980
80104caa:	e8 1f 11 00 00       	call   80105dce <release>
80104caf:	83 c4 10             	add    $0x10,%esp
  return 0;
80104cb2:	b8 00 00 00 00       	mov    $0x0,%eax
80104cb7:	e9 6d 01 00 00       	jmp    80104e29 <allocproc+0x1c0>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104cbc:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104cc7:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104ccc:	8d 50 01             	lea    0x1(%eax),%edx
80104ccf:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
80104cd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cd8:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104cdb:	83 ec 0c             	sub    $0xc,%esp
80104cde:	68 80 49 11 80       	push   $0x80114980
80104ce3:	e8 e6 10 00 00       	call   80105dce <release>
80104ce8:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104ceb:	e8 5f e7 ff ff       	call   8010344f <kalloc>
80104cf0:	89 c2                	mov    %eax,%edx
80104cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf5:	89 50 08             	mov    %edx,0x8(%eax)
80104cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cfb:	8b 40 08             	mov    0x8(%eax),%eax
80104cfe:	85 c0                	test   %eax,%eax
80104d00:	75 14                	jne    80104d16 <allocproc+0xad>
    p->state = UNUSED;
80104d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d05:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104d0c:	b8 00 00 00 00       	mov    $0x0,%eax
80104d11:	e9 13 01 00 00       	jmp    80104e29 <allocproc+0x1c0>
  }
  sp = p->kstack + KSTACKSIZE;
80104d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d19:	8b 40 08             	mov    0x8(%eax),%eax
80104d1c:	05 00 10 00 00       	add    $0x1000,%eax
80104d21:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104d24:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d2e:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104d31:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80104d35:	ba a4 73 10 80       	mov    $0x801073a4,%edx
80104d3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d3d:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104d3f:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80104d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d46:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d49:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d52:	83 ec 04             	sub    $0x4,%esp
80104d55:	6a 14                	push   $0x14
80104d57:	6a 00                	push   $0x0
80104d59:	50                   	push   %eax
80104d5a:	e8 6b 12 00 00       	call   80105fca <memset>
80104d5f:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d65:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d68:	ba 5c 58 10 80       	mov    $0x8010585c,%edx
80104d6d:	89 50 10             	mov    %edx,0x10(%eax)

//assignment3
//initialize pages for new process  in disc and in physical memory
  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
80104d70:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104d77:	eb 59                	jmp    80104dd2 <allocproc+0x169>
   p->physical[i].virtualAdress = (char*)0xffffffff;
80104d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d7f:	83 c2 0b             	add    $0xb,%edx
80104d82:	c1 e2 04             	shl    $0x4,%edx
80104d85:	01 d0                	add    %edx,%eax
80104d87:	83 c0 0c             	add    $0xc,%eax
80104d8a:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
   p->physical[i].next = 0;
80104d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d93:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d96:	83 c2 0b             	add    $0xb,%edx
80104d99:	c1 e2 04             	shl    $0x4,%edx
80104d9c:	01 d0                	add    %edx,%eax
80104d9e:	83 c0 14             	add    $0x14,%eax
80104da1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
   p->physical[i].prev = 0;
80104da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104daa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104dad:	83 c2 0b             	add    $0xb,%edx
80104db0:	c1 e2 04             	shl    $0x4,%edx
80104db3:	01 d0                	add    %edx,%eax
80104db5:	83 c0 18             	add    $0x18,%eax
80104db8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
   p->disc[i].virtualAdress = (char*)0xffffffff;
80104dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104dc4:	83 c2 20             	add    $0x20,%edx
80104dc7:	c7 04 90 ff ff ff ff 	movl   $0xffffffff,(%eax,%edx,4)
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

//assignment3
//initialize pages for new process  in disc and in physical memory
  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
80104dce:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104dd2:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80104dd6:	7e a1                	jle    80104d79 <allocproc+0x110>
   p->physical[i].next = 0;
   p->physical[i].prev = 0;
   p->disc[i].virtualAdress = (char*)0xffffffff;
 }
 // initialize global variable in process for the page
 p->pagesInPhMem = 0;
80104dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ddb:	c7 80 b4 01 00 00 00 	movl   $0x0,0x1b4(%eax)
80104de2:	00 00 00 
 p->pagesInDisc = 0;
80104de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de8:	c7 80 b8 01 00 00 00 	movl   $0x0,0x1b8(%eax)
80104def:	00 00 00 
 p->head = 0;
80104df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df5:	c7 80 ac 01 00 00 00 	movl   $0x0,0x1ac(%eax)
80104dfc:	00 00 00 
 p->tail = 0;
80104dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e02:	c7 80 b0 01 00 00 00 	movl   $0x0,0x1b0(%eax)
80104e09:	00 00 00 
 p->totalPageFaultCount=0;
80104e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0f:	c7 80 bc 01 00 00 00 	movl   $0x0,0x1bc(%eax)
80104e16:	00 00 00 
 p->totalSwappedCount=0;
80104e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1c:	c7 80 c0 01 00 00 00 	movl   $0x0,0x1c0(%eax)
80104e23:	00 00 00 
// finish
  return p;
80104e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104e29:	c9                   	leave  
80104e2a:	c3                   	ret    

80104e2b <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104e2b:	55                   	push   %ebp
80104e2c:	89 e5                	mov    %esp,%ebp
80104e2e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104e31:	e8 33 fe ff ff       	call   80104c69 <allocproc>
80104e36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3c:	a3 48 d6 10 80       	mov    %eax,0x8010d648
  if((p->pgdir = setupkvm()) == 0)
80104e41:	e8 c4 3c 00 00       	call   80108b0a <setupkvm>
80104e46:	89 c2                	mov    %eax,%edx
80104e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4b:	89 50 04             	mov    %edx,0x4(%eax)
80104e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e51:	8b 40 04             	mov    0x4(%eax),%eax
80104e54:	85 c0                	test   %eax,%eax
80104e56:	75 0d                	jne    80104e65 <userinit+0x3a>
    panic("userinit: out of memory?");
80104e58:	83 ec 0c             	sub    $0xc,%esp
80104e5b:	68 13 a1 10 80       	push   $0x8010a113
80104e60:	e8 01 b7 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104e65:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6d:	8b 40 04             	mov    0x4(%eax),%eax
80104e70:	83 ec 04             	sub    $0x4,%esp
80104e73:	52                   	push   %edx
80104e74:	68 e0 d4 10 80       	push   $0x8010d4e0
80104e79:	50                   	push   %eax
80104e7a:	e8 e5 3e 00 00       	call   80108d64 <inituvm>
80104e7f:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e85:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8e:	8b 40 18             	mov    0x18(%eax),%eax
80104e91:	83 ec 04             	sub    $0x4,%esp
80104e94:	6a 4c                	push   $0x4c
80104e96:	6a 00                	push   $0x0
80104e98:	50                   	push   %eax
80104e99:	e8 2c 11 00 00       	call   80105fca <memset>
80104e9e:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea4:	8b 40 18             	mov    0x18(%eax),%eax
80104ea7:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb0:	8b 40 18             	mov    0x18(%eax),%eax
80104eb3:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebc:	8b 40 18             	mov    0x18(%eax),%eax
80104ebf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ec2:	8b 52 18             	mov    0x18(%edx),%edx
80104ec5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104ec9:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed0:	8b 40 18             	mov    0x18(%eax),%eax
80104ed3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ed6:	8b 52 18             	mov    0x18(%edx),%edx
80104ed9:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104edd:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee4:	8b 40 18             	mov    0x18(%eax),%eax
80104ee7:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef1:	8b 40 18             	mov    0x18(%eax),%eax
80104ef4:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104efe:	8b 40 18             	mov    0x18(%eax),%eax
80104f01:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0b:	83 c0 6c             	add    $0x6c,%eax
80104f0e:	83 ec 04             	sub    $0x4,%esp
80104f11:	6a 10                	push   $0x10
80104f13:	68 2c a1 10 80       	push   $0x8010a12c
80104f18:	50                   	push   %eax
80104f19:	e8 af 12 00 00       	call   801061cd <safestrcpy>
80104f1e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104f21:	83 ec 0c             	sub    $0xc,%esp
80104f24:	68 35 a1 10 80       	push   $0x8010a135
80104f29:	e8 8c d9 ff ff       	call   801028ba <namei>
80104f2e:	83 c4 10             	add    $0x10,%esp
80104f31:	89 c2                	mov    %eax,%edx
80104f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f36:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104f43:	90                   	nop
80104f44:	c9                   	leave  
80104f45:	c3                   	ret    

80104f46 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104f46:	55                   	push   %ebp
80104f47:	89 e5                	mov    %esp,%ebp
80104f49:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
80104f4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f52:	8b 00                	mov    (%eax),%eax
80104f54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104f57:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104f5b:	7e 31                	jle    80104f8e <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104f5d:	8b 55 08             	mov    0x8(%ebp),%edx
80104f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f63:	01 c2                	add    %eax,%edx
80104f65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f6b:	8b 40 04             	mov    0x4(%eax),%eax
80104f6e:	83 ec 04             	sub    $0x4,%esp
80104f71:	52                   	push   %edx
80104f72:	ff 75 f4             	pushl  -0xc(%ebp)
80104f75:	50                   	push   %eax
80104f76:	e8 36 3f 00 00       	call   80108eb1 <allocuvm>
80104f7b:	83 c4 10             	add    $0x10,%esp
80104f7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f85:	75 3e                	jne    80104fc5 <growproc+0x7f>
      return -1;
80104f87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f8c:	eb 59                	jmp    80104fe7 <growproc+0xa1>
  } else if(n < 0){
80104f8e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104f92:	79 31                	jns    80104fc5 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104f94:	8b 55 08             	mov    0x8(%ebp),%edx
80104f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9a:	01 c2                	add    %eax,%edx
80104f9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa2:	8b 40 04             	mov    0x4(%eax),%eax
80104fa5:	83 ec 04             	sub    $0x4,%esp
80104fa8:	52                   	push   %edx
80104fa9:	ff 75 f4             	pushl  -0xc(%ebp)
80104fac:	50                   	push   %eax
80104fad:	e8 0e 40 00 00       	call   80108fc0 <deallocuvm>
80104fb2:	83 c4 10             	add    $0x10,%esp
80104fb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104fb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fbc:	75 07                	jne    80104fc5 <growproc+0x7f>
      return -1;
80104fbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc3:	eb 22                	jmp    80104fe7 <growproc+0xa1>
  }
  proc->sz = sz;
80104fc5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fcb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fce:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104fd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd6:	83 ec 0c             	sub    $0xc,%esp
80104fd9:	50                   	push   %eax
80104fda:	e8 12 3c 00 00       	call   80108bf1 <switchuvm>
80104fdf:	83 c4 10             	add    $0x10,%esp
  return 0;
80104fe2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fe7:	c9                   	leave  
80104fe8:	c3                   	ret    

80104fe9 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104fe9:	55                   	push   %ebp
80104fea:	89 e5                	mov    %esp,%ebp
80104fec:	57                   	push   %edi
80104fed:	56                   	push   %esi
80104fee:	53                   	push   %ebx
80104fef:	81 ec 2c 08 00 00    	sub    $0x82c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104ff5:	e8 6f fc ff ff       	call   80104c69 <allocproc>
80104ffa:	89 45 d8             	mov    %eax,-0x28(%ebp)
80104ffd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80105001:	75 0a                	jne    8010500d <fork+0x24>
    return -1;
80105003:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105008:	e9 34 04 00 00       	jmp    80105441 <fork+0x458>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010500d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105013:	8b 10                	mov    (%eax),%edx
80105015:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010501b:	8b 40 04             	mov    0x4(%eax),%eax
8010501e:	83 ec 08             	sub    $0x8,%esp
80105021:	52                   	push   %edx
80105022:	50                   	push   %eax
80105023:	e8 c6 43 00 00       	call   801093ee <copyuvm>
80105028:	83 c4 10             	add    $0x10,%esp
8010502b:	89 c2                	mov    %eax,%edx
8010502d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105030:	89 50 04             	mov    %edx,0x4(%eax)
80105033:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105036:	8b 40 04             	mov    0x4(%eax),%eax
80105039:	85 c0                	test   %eax,%eax
8010503b:	75 30                	jne    8010506d <fork+0x84>
    kfree(np->kstack);
8010503d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105040:	8b 40 08             	mov    0x8(%eax),%eax
80105043:	83 ec 0c             	sub    $0xc,%esp
80105046:	50                   	push   %eax
80105047:	e8 59 e3 ff ff       	call   801033a5 <kfree>
8010504c:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010504f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105052:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80105059:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010505c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80105063:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105068:	e9 d4 03 00 00       	jmp    80105441 <fork+0x458>
  }
  // assignment3 
  //copy # of pages in physical memory and in disc
  np->pagesInPhMem = proc->pagesInPhMem;
8010506d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105073:	8b 90 b4 01 00 00    	mov    0x1b4(%eax),%edx
80105079:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010507c:	89 90 b4 01 00 00    	mov    %edx,0x1b4(%eax)
  np->pagesInDisc = proc->pagesInDisc;
80105082:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105088:	8b 90 b8 01 00 00    	mov    0x1b8(%eax),%edx
8010508e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105091:	89 90 b8 01 00 00    	mov    %edx,0x1b8(%eax)
 // finish
  np->sz = proc->sz;
80105097:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010509d:	8b 10                	mov    (%eax),%edx
8010509f:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050a2:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801050a4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050ae:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801050b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050b4:	8b 50 18             	mov    0x18(%eax),%edx
801050b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050bd:	8b 40 18             	mov    0x18(%eax),%eax
801050c0:	89 c3                	mov    %eax,%ebx
801050c2:	b8 13 00 00 00       	mov    $0x13,%eax
801050c7:	89 d7                	mov    %edx,%edi
801050c9:	89 de                	mov    %ebx,%esi
801050cb:	89 c1                	mov    %eax,%ecx
801050cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801050cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050d2:	8b 40 18             	mov    0x18(%eax),%eax
801050d5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801050dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801050e3:	eb 43                	jmp    80105128 <fork+0x13f>
    if(proc->ofile[i])
801050e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801050ee:	83 c2 08             	add    $0x8,%edx
801050f1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050f5:	85 c0                	test   %eax,%eax
801050f7:	74 2b                	je     80105124 <fork+0x13b>
      np->ofile[i] = filedup(proc->ofile[i]);
801050f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105102:	83 c2 08             	add    $0x8,%edx
80105105:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105109:	83 ec 0c             	sub    $0xc,%esp
8010510c:	50                   	push   %eax
8010510d:	e8 80 c2 ff ff       	call   80101392 <filedup>
80105112:	83 c4 10             	add    $0x10,%esp
80105115:	89 c1                	mov    %eax,%ecx
80105117:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010511a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010511d:	83 c2 08             	add    $0x8,%edx
80105120:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80105124:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105128:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010512c:	7e b7                	jle    801050e5 <fork+0xfc>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010512e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105134:	8b 40 68             	mov    0x68(%eax),%eax
80105137:	83 ec 0c             	sub    $0xc,%esp
8010513a:	50                   	push   %eax
8010513b:	e8 82 cb ff ff       	call   80101cc2 <idup>
80105140:	83 c4 10             	add    $0x10,%esp
80105143:	89 c2                	mov    %eax,%edx
80105145:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105148:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010514b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105151:	8d 50 6c             	lea    0x6c(%eax),%edx
80105154:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105157:	83 c0 6c             	add    $0x6c,%eax
8010515a:	83 ec 04             	sub    $0x4,%esp
8010515d:	6a 10                	push   $0x10
8010515f:	52                   	push   %edx
80105160:	50                   	push   %eax
80105161:	e8 67 10 00 00       	call   801061cd <safestrcpy>
80105166:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80105169:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010516c:	8b 40 10             	mov    0x10(%eax),%eax
8010516f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

  // assignment3 
  createSwapFile(np);
80105172:	83 ec 0c             	sub    $0xc,%esp
80105175:	ff 75 d8             	pushl  -0x28(%ebp)
80105178:	e8 4e da ff ff       	call   80102bcb <createSwapFile>
8010517d:	83 c4 10             	add    $0x10,%esp
  char buf[PGSIZE/2] = "";
80105180:	c7 85 d0 f7 ff ff 00 	movl   $0x0,-0x830(%ebp)
80105187:	00 00 00 
8010518a:	8d 95 d4 f7 ff ff    	lea    -0x82c(%ebp),%edx
80105190:	b8 00 00 00 00       	mov    $0x0,%eax
80105195:	b9 ff 01 00 00       	mov    $0x1ff,%ecx
8010519a:	89 d7                	mov    %edx,%edi
8010519c:	f3 ab                	rep stos %eax,%es:(%edi)
  int offset = 0;
8010519e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  int nread = 0;
801051a5:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  //read parent's disc in chunks of pgsize/2
  //don't copy init proc or shell
   if (proc->pid >   2) {
801051ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b2:	8b 40 10             	mov    0x10(%eax),%eax
801051b5:	83 f8 02             	cmp    $0x2,%eax
801051b8:	7e 5c                	jle    80105216 <fork+0x22d>
     //read until failed reading
     while ((nread = readFromSwapFile(proc, buf, offset, PGSIZE/2)) != 0) {
801051ba:	eb 32                	jmp    801051ee <fork+0x205>
       if (writeToSwapFile(np, buf, offset, nread) == -1){
801051bc:	8b 55 d0             	mov    -0x30(%ebp),%edx
801051bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801051c2:	52                   	push   %edx
801051c3:	50                   	push   %eax
801051c4:	8d 85 d0 f7 ff ff    	lea    -0x830(%ebp),%eax
801051ca:	50                   	push   %eax
801051cb:	ff 75 d8             	pushl  -0x28(%ebp)
801051ce:	e8 be da ff ff       	call   80102c91 <writeToSwapFile>
801051d3:	83 c4 10             	add    $0x10,%esp
801051d6:	83 f8 ff             	cmp    $0xffffffff,%eax
801051d9:	75 0d                	jne    801051e8 <fork+0x1ff>
        panic("fork:error copy disc from parent to child");
801051db:	83 ec 0c             	sub    $0xc,%esp
801051de:	68 38 a1 10 80       	push   $0x8010a138
801051e3:	e8 7e b3 ff ff       	call   80100566 <panic>
      }
      //update offset accoring to read data
      offset += nread;
801051e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801051eb:	01 45 e0             	add    %eax,-0x20(%ebp)
  int nread = 0;
  //read parent's disc in chunks of pgsize/2
  //don't copy init proc or shell
   if (proc->pid >   2) {
     //read until failed reading
     while ((nread = readFromSwapFile(proc, buf, offset, PGSIZE/2)) != 0) {
801051ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
801051f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051f7:	68 00 08 00 00       	push   $0x800
801051fc:	52                   	push   %edx
801051fd:	8d 95 d0 f7 ff ff    	lea    -0x830(%ebp),%edx
80105203:	52                   	push   %edx
80105204:	50                   	push   %eax
80105205:	e8 b4 da ff ff       	call   80102cbe <readFromSwapFile>
8010520a:	83 c4 10             	add    $0x10,%esp
8010520d:	89 45 d0             	mov    %eax,-0x30(%ebp)
80105210:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80105214:	75 a6                	jne    801051bc <fork+0x1d3>
      offset += nread;
    }
  }

//go over all pages and copy fields virtualAdress, accessCount and swapLocation
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
80105216:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010521d:	eb 71                	jmp    80105290 <fork+0x2a7>
    np->physical[i].virtualAdress = proc->physical[i].virtualAdress;
8010521f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105225:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105228:	83 c2 0b             	add    $0xb,%edx
8010522b:	c1 e2 04             	shl    $0x4,%edx
8010522e:	01 d0                	add    %edx,%eax
80105230:	83 c0 0c             	add    $0xc,%eax
80105233:	8b 00                	mov    (%eax),%eax
80105235:	8b 55 d8             	mov    -0x28(%ebp),%edx
80105238:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010523b:	83 c1 0b             	add    $0xb,%ecx
8010523e:	c1 e1 04             	shl    $0x4,%ecx
80105241:	01 ca                	add    %ecx,%edx
80105243:	83 c2 0c             	add    $0xc,%edx
80105246:	89 02                	mov    %eax,(%edx)
    np->physical[i].accessCount = proc->physical[i].accessCount;
80105248:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010524e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105251:	83 c2 0b             	add    $0xb,%edx
80105254:	c1 e2 04             	shl    $0x4,%edx
80105257:	01 d0                	add    %edx,%eax
80105259:	83 c0 10             	add    $0x10,%eax
8010525c:	8b 00                	mov    (%eax),%eax
8010525e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80105261:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105264:	83 c1 0b             	add    $0xb,%ecx
80105267:	c1 e1 04             	shl    $0x4,%ecx
8010526a:	01 ca                	add    %ecx,%edx
8010526c:	83 c2 10             	add    $0x10,%edx
8010526f:	89 02                	mov    %eax,(%edx)
    np->disc[i].virtualAdress = proc->disc[i].virtualAdress;
80105271:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105277:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010527a:	83 c2 20             	add    $0x20,%edx
8010527d:	8b 14 90             	mov    (%eax,%edx,4),%edx
80105280:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105283:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105286:	83 c1 20             	add    $0x20,%ecx
80105289:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      offset += nread;
    }
  }

//go over all pages and copy fields virtualAdress, accessCount and swapLocation
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
8010528c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105290:	83 7d e4 0e          	cmpl   $0xe,-0x1c(%ebp)
80105294:	7e 89                	jle    8010521f <fork+0x236>
    np->physical[i].accessCount = proc->physical[i].accessCount;
    np->disc[i].virtualAdress = proc->disc[i].virtualAdress;
  }
//after we copied all pages now we need to change next and prev for each one
//do it in a wasteful way to prevent errors! 
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80105296:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010529d:	e9 cc 00 00 00       	jmp    8010536e <fork+0x385>
    for (int j = 0; j < MAX_PSYC_PAGES; ++j){
801052a2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801052a9:	e9 b2 00 00 00       	jmp    80105360 <fork+0x377>
      //if found next update it and break from inner loop
      if(np->physical[j].virtualAdress == proc->physical[i].next->virtualAdress){
801052ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
801052b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801052b4:	83 c2 0b             	add    $0xb,%edx
801052b7:	c1 e2 04             	shl    $0x4,%edx
801052ba:	01 d0                	add    %edx,%eax
801052bc:	83 c0 0c             	add    $0xc,%eax
801052bf:	8b 10                	mov    (%eax),%edx
801052c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801052ca:	83 c1 0b             	add    $0xb,%ecx
801052cd:	c1 e1 04             	shl    $0x4,%ecx
801052d0:	01 c8                	add    %ecx,%eax
801052d2:	83 c0 14             	add    $0x14,%eax
801052d5:	8b 00                	mov    (%eax),%eax
801052d7:	8b 00                	mov    (%eax),%eax
801052d9:	39 c2                	cmp    %eax,%edx
801052db:	75 28                	jne    80105305 <fork+0x31c>
        np->physical[i].next = &np->physical[j];
801052dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801052e0:	83 c0 0b             	add    $0xb,%eax
801052e3:	c1 e0 04             	shl    $0x4,%eax
801052e6:	89 c2                	mov    %eax,%edx
801052e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801052eb:	01 d0                	add    %edx,%eax
801052ed:	8d 50 0c             	lea    0xc(%eax),%edx
801052f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801052f3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801052f6:	83 c1 0b             	add    $0xb,%ecx
801052f9:	c1 e1 04             	shl    $0x4,%ecx
801052fc:	01 c8                	add    %ecx,%eax
801052fe:	83 c0 14             	add    $0x14,%eax
80105301:	89 10                	mov    %edx,(%eax)
        break;
80105303:	eb 65                	jmp    8010536a <fork+0x381>
      }
//if found prev update it and break from inner loop
      if(np->physical[j].virtualAdress == proc->physical[i].prev->virtualAdress){
80105305:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105308:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010530b:	83 c2 0b             	add    $0xb,%edx
8010530e:	c1 e2 04             	shl    $0x4,%edx
80105311:	01 d0                	add    %edx,%eax
80105313:	83 c0 0c             	add    $0xc,%eax
80105316:	8b 10                	mov    (%eax),%edx
80105318:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010531e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105321:	83 c1 0b             	add    $0xb,%ecx
80105324:	c1 e1 04             	shl    $0x4,%ecx
80105327:	01 c8                	add    %ecx,%eax
80105329:	83 c0 18             	add    $0x18,%eax
8010532c:	8b 00                	mov    (%eax),%eax
8010532e:	8b 00                	mov    (%eax),%eax
80105330:	39 c2                	cmp    %eax,%edx
80105332:	75 28                	jne    8010535c <fork+0x373>
        np->physical[i].prev = &np->physical[j];
80105334:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105337:	83 c0 0b             	add    $0xb,%eax
8010533a:	c1 e0 04             	shl    $0x4,%eax
8010533d:	89 c2                	mov    %eax,%edx
8010533f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105342:	01 d0                	add    %edx,%eax
80105344:	8d 50 0c             	lea    0xc(%eax),%edx
80105347:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010534a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010534d:	83 c1 0b             	add    $0xb,%ecx
80105350:	c1 e1 04             	shl    $0x4,%ecx
80105353:	01 c8                	add    %ecx,%eax
80105355:	83 c0 18             	add    $0x18,%eax
80105358:	89 10                	mov    %edx,(%eax)
        break;
8010535a:	eb 0e                	jmp    8010536a <fork+0x381>
    np->disc[i].virtualAdress = proc->disc[i].virtualAdress;
  }
//after we copied all pages now we need to change next and prev for each one
//do it in a wasteful way to prevent errors! 
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    for (int j = 0; j < MAX_PSYC_PAGES; ++j){
8010535c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80105360:	83 7d dc 0e          	cmpl   $0xe,-0x24(%ebp)
80105364:	0f 8e 44 ff ff ff    	jle    801052ae <fork+0x2c5>
    np->physical[i].accessCount = proc->physical[i].accessCount;
    np->disc[i].virtualAdress = proc->disc[i].virtualAdress;
  }
//after we copied all pages now we need to change next and prev for each one
//do it in a wasteful way to prevent errors! 
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010536a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010536e:	83 7d e4 0e          	cmpl   $0xe,-0x1c(%ebp)
80105372:	0f 8e 2a ff ff ff    	jle    801052a2 <fork+0x2b9>
      }
    }

    #ifndef NONE
	//if SELECTION != NONE update process head and tail
      for (i = 0; i < MAX_PSYC_PAGES; i++) {
80105378:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010537f:	e9 86 00 00 00       	jmp    8010540a <fork+0x421>
        if (proc->head->virtualAdress == np->physical[i].virtualAdress)
80105384:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010538a:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80105390:	8b 10                	mov    (%eax),%edx
80105392:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105395:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105398:	83 c1 0b             	add    $0xb,%ecx
8010539b:	c1 e1 04             	shl    $0x4,%ecx
8010539e:	01 c8                	add    %ecx,%eax
801053a0:	83 c0 0c             	add    $0xc,%eax
801053a3:	8b 00                	mov    (%eax),%eax
801053a5:	39 c2                	cmp    %eax,%edx
801053a7:	75 1c                	jne    801053c5 <fork+0x3dc>
          np->head = &np->physical[i];
801053a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801053ac:	83 c0 0b             	add    $0xb,%eax
801053af:	c1 e0 04             	shl    $0x4,%eax
801053b2:	89 c2                	mov    %eax,%edx
801053b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801053b7:	01 d0                	add    %edx,%eax
801053b9:	8d 50 0c             	lea    0xc(%eax),%edx
801053bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801053bf:	89 90 ac 01 00 00    	mov    %edx,0x1ac(%eax)
        if (proc->tail->virtualAdress == np->physical[i].virtualAdress)
801053c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053cb:	8b 80 b0 01 00 00    	mov    0x1b0(%eax),%eax
801053d1:	8b 10                	mov    (%eax),%edx
801053d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801053d6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801053d9:	83 c1 0b             	add    $0xb,%ecx
801053dc:	c1 e1 04             	shl    $0x4,%ecx
801053df:	01 c8                	add    %ecx,%eax
801053e1:	83 c0 0c             	add    $0xc,%eax
801053e4:	8b 00                	mov    (%eax),%eax
801053e6:	39 c2                	cmp    %eax,%edx
801053e8:	75 1c                	jne    80105406 <fork+0x41d>
          np->tail = &np->physical[i];
801053ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801053ed:	83 c0 0b             	add    $0xb,%eax
801053f0:	c1 e0 04             	shl    $0x4,%eax
801053f3:	89 c2                	mov    %eax,%edx
801053f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801053f8:	01 d0                	add    %edx,%eax
801053fa:	8d 50 0c             	lea    0xc(%eax),%edx
801053fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105400:	89 90 b0 01 00 00    	mov    %edx,0x1b0(%eax)
      }
    }

    #ifndef NONE
	//if SELECTION != NONE update process head and tail
      for (i = 0; i < MAX_PSYC_PAGES; i++) {
80105406:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010540a:	83 7d e4 0e          	cmpl   $0xe,-0x1c(%ebp)
8010540e:	0f 8e 70 ff ff ff    	jle    80105384 <fork+0x39b>
      }
    #endif
	//finish

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80105414:	83 ec 0c             	sub    $0xc,%esp
80105417:	68 80 49 11 80       	push   $0x80114980
8010541c:	e8 46 09 00 00       	call   80105d67 <acquire>
80105421:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80105424:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105427:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
8010542e:	83 ec 0c             	sub    $0xc,%esp
80105431:	68 80 49 11 80       	push   $0x80114980
80105436:	e8 93 09 00 00       	call   80105dce <release>
8010543b:	83 c4 10             	add    $0x10,%esp

  return pid;
8010543e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
80105441:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105444:	5b                   	pop    %ebx
80105445:	5e                   	pop    %esi
80105446:	5f                   	pop    %edi
80105447:	5d                   	pop    %ebp
80105448:	c3                   	ret    

80105449 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80105449:	55                   	push   %ebp
8010544a:	89 e5                	mov    %esp,%ebp
8010544c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010544f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105456:	a1 48 d6 10 80       	mov    0x8010d648,%eax
8010545b:	39 c2                	cmp    %eax,%edx
8010545d:	75 0d                	jne    8010546c <exit+0x23>
    panic("init exiting");
8010545f:	83 ec 0c             	sub    $0xc,%esp
80105462:	68 62 a1 10 80       	push   $0x8010a162
80105467:	e8 fa b0 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010546c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105473:	eb 48                	jmp    801054bd <exit+0x74>
    if(proc->ofile[fd]){
80105475:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010547b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010547e:	83 c2 08             	add    $0x8,%edx
80105481:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105485:	85 c0                	test   %eax,%eax
80105487:	74 30                	je     801054b9 <exit+0x70>
      fileclose(proc->ofile[fd]);
80105489:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010548f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105492:	83 c2 08             	add    $0x8,%edx
80105495:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105499:	83 ec 0c             	sub    $0xc,%esp
8010549c:	50                   	push   %eax
8010549d:	e8 41 bf ff ff       	call   801013e3 <fileclose>
801054a2:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
801054a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054ae:	83 c2 08             	add    $0x8,%edx
801054b1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054b8:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801054b9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801054bd:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801054c1:	7e b2                	jle    80105475 <exit+0x2c>
      proc->ofile[fd] = 0;
    }
  }
  //assignment3
  //delete disc before exiting 
  removeSwapFile(proc);
801054c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c9:	83 ec 0c             	sub    $0xc,%esp
801054cc:	50                   	push   %eax
801054cd:	e8 e0 d4 ff ff       	call   801029b2 <removeSwapFile>
801054d2:	83 c4 10             	add    $0x10,%esp
  printProcMemPageInfo(proc);
  #endif

  //finish

  begin_op();
801054d5:	e8 69 e8 ff ff       	call   80103d43 <begin_op>
  iput(proc->cwd);
801054da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054e0:	8b 40 68             	mov    0x68(%eax),%eax
801054e3:	83 ec 0c             	sub    $0xc,%esp
801054e6:	50                   	push   %eax
801054e7:	e8 e0 c9 ff ff       	call   80101ecc <iput>
801054ec:	83 c4 10             	add    $0x10,%esp
  end_op();
801054ef:	e8 db e8 ff ff       	call   80103dcf <end_op>
  proc->cwd = 0;
801054f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054fa:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80105501:	83 ec 0c             	sub    $0xc,%esp
80105504:	68 80 49 11 80       	push   $0x80114980
80105509:	e8 59 08 00 00       	call   80105d67 <acquire>
8010550e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80105511:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105517:	8b 40 14             	mov    0x14(%eax),%eax
8010551a:	83 ec 0c             	sub    $0xc,%esp
8010551d:	50                   	push   %eax
8010551e:	e8 2b 04 00 00       	call   8010594e <wakeup1>
80105523:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105526:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
8010552d:	eb 3f                	jmp    8010556e <exit+0x125>
    if(p->parent == proc){
8010552f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105532:	8b 50 14             	mov    0x14(%eax),%edx
80105535:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010553b:	39 c2                	cmp    %eax,%edx
8010553d:	75 28                	jne    80105567 <exit+0x11e>
      p->parent = initproc;
8010553f:	8b 15 48 d6 10 80    	mov    0x8010d648,%edx
80105545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105548:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010554b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554e:	8b 40 0c             	mov    0xc(%eax),%eax
80105551:	83 f8 05             	cmp    $0x5,%eax
80105554:	75 11                	jne    80105567 <exit+0x11e>
        wakeup1(initproc);
80105556:	a1 48 d6 10 80       	mov    0x8010d648,%eax
8010555b:	83 ec 0c             	sub    $0xc,%esp
8010555e:	50                   	push   %eax
8010555f:	e8 ea 03 00 00       	call   8010594e <wakeup1>
80105564:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105567:	81 45 f4 c4 01 00 00 	addl   $0x1c4,-0xc(%ebp)
8010556e:	81 7d f4 b4 ba 11 80 	cmpl   $0x8011bab4,-0xc(%ebp)
80105575:	72 b8                	jb     8010552f <exit+0xe6>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80105577:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010557d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105584:	e8 dc 01 00 00       	call   80105765 <sched>
  panic("zombie exit");
80105589:	83 ec 0c             	sub    $0xc,%esp
8010558c:	68 6f a1 10 80       	push   $0x8010a16f
80105591:	e8 d0 af ff ff       	call   80100566 <panic>

80105596 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80105596:	55                   	push   %ebp
80105597:	89 e5                	mov    %esp,%ebp
80105599:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010559c:	83 ec 0c             	sub    $0xc,%esp
8010559f:	68 80 49 11 80       	push   $0x80114980
801055a4:	e8 be 07 00 00       	call   80105d67 <acquire>
801055a9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801055ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055b3:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
801055ba:	e9 a9 00 00 00       	jmp    80105668 <wait+0xd2>
      if(p->parent != proc)
801055bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c2:	8b 50 14             	mov    0x14(%eax),%edx
801055c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055cb:	39 c2                	cmp    %eax,%edx
801055cd:	0f 85 8d 00 00 00    	jne    80105660 <wait+0xca>
        continue;
      havekids = 1;
801055d3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801055da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055dd:	8b 40 0c             	mov    0xc(%eax),%eax
801055e0:	83 f8 05             	cmp    $0x5,%eax
801055e3:	75 7c                	jne    80105661 <wait+0xcb>
        // Found one.
        pid = p->pid;
801055e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e8:	8b 40 10             	mov    0x10(%eax),%eax
801055eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801055ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f1:	8b 40 08             	mov    0x8(%eax),%eax
801055f4:	83 ec 0c             	sub    $0xc,%esp
801055f7:	50                   	push   %eax
801055f8:	e8 a8 dd ff ff       	call   801033a5 <kfree>
801055fd:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80105600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105603:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010560a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560d:	8b 40 04             	mov    0x4(%eax),%eax
80105610:	83 ec 0c             	sub    $0xc,%esp
80105613:	50                   	push   %eax
80105614:	e8 f4 3c 00 00       	call   8010930d <freevm>
80105619:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
8010561c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80105626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105629:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80105630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105633:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010563a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105644:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
8010564b:	83 ec 0c             	sub    $0xc,%esp
8010564e:	68 80 49 11 80       	push   $0x80114980
80105653:	e8 76 07 00 00       	call   80105dce <release>
80105658:	83 c4 10             	add    $0x10,%esp
        return pid;
8010565b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010565e:	eb 5b                	jmp    801056bb <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105660:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105661:	81 45 f4 c4 01 00 00 	addl   $0x1c4,-0xc(%ebp)
80105668:	81 7d f4 b4 ba 11 80 	cmpl   $0x8011bab4,-0xc(%ebp)
8010566f:	0f 82 4a ff ff ff    	jb     801055bf <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105675:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105679:	74 0d                	je     80105688 <wait+0xf2>
8010567b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105681:	8b 40 24             	mov    0x24(%eax),%eax
80105684:	85 c0                	test   %eax,%eax
80105686:	74 17                	je     8010569f <wait+0x109>
      release(&ptable.lock);
80105688:	83 ec 0c             	sub    $0xc,%esp
8010568b:	68 80 49 11 80       	push   $0x80114980
80105690:	e8 39 07 00 00       	call   80105dce <release>
80105695:	83 c4 10             	add    $0x10,%esp
      return -1;
80105698:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010569d:	eb 1c                	jmp    801056bb <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010569f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056a5:	83 ec 08             	sub    $0x8,%esp
801056a8:	68 80 49 11 80       	push   $0x80114980
801056ad:	50                   	push   %eax
801056ae:	e8 ef 01 00 00       	call   801058a2 <sleep>
801056b3:	83 c4 10             	add    $0x10,%esp
  }
801056b6:	e9 f1 fe ff ff       	jmp    801055ac <wait+0x16>
}
801056bb:	c9                   	leave  
801056bc:	c3                   	ret    

801056bd <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801056bd:	55                   	push   %ebp
801056be:	89 e5                	mov    %esp,%ebp
801056c0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801056c3:	e8 7c f5 ff ff       	call   80104c44 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801056c8:	83 ec 0c             	sub    $0xc,%esp
801056cb:	68 80 49 11 80       	push   $0x80114980
801056d0:	e8 92 06 00 00       	call   80105d67 <acquire>
801056d5:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056d8:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
801056df:	eb 66                	jmp    80105747 <scheduler+0x8a>
      if(p->state != RUNNABLE)
801056e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e4:	8b 40 0c             	mov    0xc(%eax),%eax
801056e7:	83 f8 03             	cmp    $0x3,%eax
801056ea:	75 53                	jne    8010573f <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801056ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ef:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801056f5:	83 ec 0c             	sub    $0xc,%esp
801056f8:	ff 75 f4             	pushl  -0xc(%ebp)
801056fb:	e8 f1 34 00 00       	call   80108bf1 <switchuvm>
80105700:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80105703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105706:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
8010570d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105713:	8b 40 1c             	mov    0x1c(%eax),%eax
80105716:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010571d:	83 c2 04             	add    $0x4,%edx
80105720:	83 ec 08             	sub    $0x8,%esp
80105723:	50                   	push   %eax
80105724:	52                   	push   %edx
80105725:	e8 14 0b 00 00       	call   8010623e <swtch>
8010572a:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010572d:	e8 a2 34 00 00       	call   80108bd4 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105732:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105739:	00 00 00 00 
8010573d:	eb 01                	jmp    80105740 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
8010573f:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105740:	81 45 f4 c4 01 00 00 	addl   $0x1c4,-0xc(%ebp)
80105747:	81 7d f4 b4 ba 11 80 	cmpl   $0x8011bab4,-0xc(%ebp)
8010574e:	72 91                	jb     801056e1 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105750:	83 ec 0c             	sub    $0xc,%esp
80105753:	68 80 49 11 80       	push   $0x80114980
80105758:	e8 71 06 00 00       	call   80105dce <release>
8010575d:	83 c4 10             	add    $0x10,%esp

  }
80105760:	e9 5e ff ff ff       	jmp    801056c3 <scheduler+0x6>

80105765 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105765:	55                   	push   %ebp
80105766:	89 e5                	mov    %esp,%ebp
80105768:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010576b:	83 ec 0c             	sub    $0xc,%esp
8010576e:	68 80 49 11 80       	push   $0x80114980
80105773:	e8 22 07 00 00       	call   80105e9a <holding>
80105778:	83 c4 10             	add    $0x10,%esp
8010577b:	85 c0                	test   %eax,%eax
8010577d:	75 0d                	jne    8010578c <sched+0x27>
    panic("sched ptable.lock");
8010577f:	83 ec 0c             	sub    $0xc,%esp
80105782:	68 7b a1 10 80       	push   $0x8010a17b
80105787:	e8 da ad ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010578c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105792:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105798:	83 f8 01             	cmp    $0x1,%eax
8010579b:	74 0d                	je     801057aa <sched+0x45>
    panic("sched locks");
8010579d:	83 ec 0c             	sub    $0xc,%esp
801057a0:	68 8d a1 10 80       	push   $0x8010a18d
801057a5:	e8 bc ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801057aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b0:	8b 40 0c             	mov    0xc(%eax),%eax
801057b3:	83 f8 04             	cmp    $0x4,%eax
801057b6:	75 0d                	jne    801057c5 <sched+0x60>
    panic("sched running");
801057b8:	83 ec 0c             	sub    $0xc,%esp
801057bb:	68 99 a1 10 80       	push   $0x8010a199
801057c0:	e8 a1 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801057c5:	e8 6a f4 ff ff       	call   80104c34 <readeflags>
801057ca:	25 00 02 00 00       	and    $0x200,%eax
801057cf:	85 c0                	test   %eax,%eax
801057d1:	74 0d                	je     801057e0 <sched+0x7b>
    panic("sched interruptible");
801057d3:	83 ec 0c             	sub    $0xc,%esp
801057d6:	68 a7 a1 10 80       	push   $0x8010a1a7
801057db:	e8 86 ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801057e0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057e6:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801057ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801057ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057f5:	8b 40 04             	mov    0x4(%eax),%eax
801057f8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057ff:	83 c2 1c             	add    $0x1c,%edx
80105802:	83 ec 08             	sub    $0x8,%esp
80105805:	50                   	push   %eax
80105806:	52                   	push   %edx
80105807:	e8 32 0a 00 00       	call   8010623e <swtch>
8010580c:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010580f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105815:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105818:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010581e:	90                   	nop
8010581f:	c9                   	leave  
80105820:	c3                   	ret    

80105821 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105821:	55                   	push   %ebp
80105822:	89 e5                	mov    %esp,%ebp
80105824:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105827:	83 ec 0c             	sub    $0xc,%esp
8010582a:	68 80 49 11 80       	push   $0x80114980
8010582f:	e8 33 05 00 00       	call   80105d67 <acquire>
80105834:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105837:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010583d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105844:	e8 1c ff ff ff       	call   80105765 <sched>
  release(&ptable.lock);
80105849:	83 ec 0c             	sub    $0xc,%esp
8010584c:	68 80 49 11 80       	push   $0x80114980
80105851:	e8 78 05 00 00       	call   80105dce <release>
80105856:	83 c4 10             	add    $0x10,%esp
}
80105859:	90                   	nop
8010585a:	c9                   	leave  
8010585b:	c3                   	ret    

8010585c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010585c:	55                   	push   %ebp
8010585d:	89 e5                	mov    %esp,%ebp
8010585f:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105862:	83 ec 0c             	sub    $0xc,%esp
80105865:	68 80 49 11 80       	push   $0x80114980
8010586a:	e8 5f 05 00 00       	call   80105dce <release>
8010586f:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105872:	a1 08 d0 10 80       	mov    0x8010d008,%eax
80105877:	85 c0                	test   %eax,%eax
80105879:	74 24                	je     8010589f <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010587b:	c7 05 08 d0 10 80 00 	movl   $0x0,0x8010d008
80105882:	00 00 00 
    iinit(ROOTDEV);
80105885:	83 ec 0c             	sub    $0xc,%esp
80105888:	6a 01                	push   $0x1
8010588a:	e8 41 c1 ff ff       	call   801019d0 <iinit>
8010588f:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105892:	83 ec 0c             	sub    $0xc,%esp
80105895:	6a 01                	push   $0x1
80105897:	e8 89 e2 ff ff       	call   80103b25 <initlog>
8010589c:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010589f:	90                   	nop
801058a0:	c9                   	leave  
801058a1:	c3                   	ret    

801058a2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801058a2:	55                   	push   %ebp
801058a3:	89 e5                	mov    %esp,%ebp
801058a5:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801058a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ae:	85 c0                	test   %eax,%eax
801058b0:	75 0d                	jne    801058bf <sleep+0x1d>
    panic("sleep");
801058b2:	83 ec 0c             	sub    $0xc,%esp
801058b5:	68 bb a1 10 80       	push   $0x8010a1bb
801058ba:	e8 a7 ac ff ff       	call   80100566 <panic>

  if(lk == 0)
801058bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058c3:	75 0d                	jne    801058d2 <sleep+0x30>
    panic("sleep without lk");
801058c5:	83 ec 0c             	sub    $0xc,%esp
801058c8:	68 c1 a1 10 80       	push   $0x8010a1c1
801058cd:	e8 94 ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801058d2:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
801058d9:	74 1e                	je     801058f9 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058db:	83 ec 0c             	sub    $0xc,%esp
801058de:	68 80 49 11 80       	push   $0x80114980
801058e3:	e8 7f 04 00 00       	call   80105d67 <acquire>
801058e8:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058eb:	83 ec 0c             	sub    $0xc,%esp
801058ee:	ff 75 0c             	pushl  0xc(%ebp)
801058f1:	e8 d8 04 00 00       	call   80105dce <release>
801058f6:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801058f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ff:	8b 55 08             	mov    0x8(%ebp),%edx
80105902:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105905:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010590b:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105912:	e8 4e fe ff ff       	call   80105765 <sched>

  // Tidy up.
  proc->chan = 0;
80105917:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010591d:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105924:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
8010592b:	74 1e                	je     8010594b <sleep+0xa9>
    release(&ptable.lock);
8010592d:	83 ec 0c             	sub    $0xc,%esp
80105930:	68 80 49 11 80       	push   $0x80114980
80105935:	e8 94 04 00 00       	call   80105dce <release>
8010593a:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010593d:	83 ec 0c             	sub    $0xc,%esp
80105940:	ff 75 0c             	pushl  0xc(%ebp)
80105943:	e8 1f 04 00 00       	call   80105d67 <acquire>
80105948:	83 c4 10             	add    $0x10,%esp
  }
}
8010594b:	90                   	nop
8010594c:	c9                   	leave  
8010594d:	c3                   	ret    

8010594e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010594e:	55                   	push   %ebp
8010594f:	89 e5                	mov    %esp,%ebp
80105951:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105954:	c7 45 fc b4 49 11 80 	movl   $0x801149b4,-0x4(%ebp)
8010595b:	eb 27                	jmp    80105984 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010595d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105960:	8b 40 0c             	mov    0xc(%eax),%eax
80105963:	83 f8 02             	cmp    $0x2,%eax
80105966:	75 15                	jne    8010597d <wakeup1+0x2f>
80105968:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010596b:	8b 40 20             	mov    0x20(%eax),%eax
8010596e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105971:	75 0a                	jne    8010597d <wakeup1+0x2f>
      p->state = RUNNABLE;
80105973:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105976:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010597d:	81 45 fc c4 01 00 00 	addl   $0x1c4,-0x4(%ebp)
80105984:	81 7d fc b4 ba 11 80 	cmpl   $0x8011bab4,-0x4(%ebp)
8010598b:	72 d0                	jb     8010595d <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010598d:	90                   	nop
8010598e:	c9                   	leave  
8010598f:	c3                   	ret    

80105990 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105996:	83 ec 0c             	sub    $0xc,%esp
80105999:	68 80 49 11 80       	push   $0x80114980
8010599e:	e8 c4 03 00 00       	call   80105d67 <acquire>
801059a3:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801059a6:	83 ec 0c             	sub    $0xc,%esp
801059a9:	ff 75 08             	pushl  0x8(%ebp)
801059ac:	e8 9d ff ff ff       	call   8010594e <wakeup1>
801059b1:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801059b4:	83 ec 0c             	sub    $0xc,%esp
801059b7:	68 80 49 11 80       	push   $0x80114980
801059bc:	e8 0d 04 00 00       	call   80105dce <release>
801059c1:	83 c4 10             	add    $0x10,%esp
}
801059c4:	90                   	nop
801059c5:	c9                   	leave  
801059c6:	c3                   	ret    

801059c7 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801059c7:	55                   	push   %ebp
801059c8:	89 e5                	mov    %esp,%ebp
801059ca:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801059cd:	83 ec 0c             	sub    $0xc,%esp
801059d0:	68 80 49 11 80       	push   $0x80114980
801059d5:	e8 8d 03 00 00       	call   80105d67 <acquire>
801059da:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059dd:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
801059e4:	eb 48                	jmp    80105a2e <kill+0x67>
    if(p->pid == pid){
801059e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e9:	8b 40 10             	mov    0x10(%eax),%eax
801059ec:	3b 45 08             	cmp    0x8(%ebp),%eax
801059ef:	75 36                	jne    80105a27 <kill+0x60>
      p->killed = 1;
801059f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801059fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fe:	8b 40 0c             	mov    0xc(%eax),%eax
80105a01:	83 f8 02             	cmp    $0x2,%eax
80105a04:	75 0a                	jne    80105a10 <kill+0x49>
        p->state = RUNNABLE;
80105a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a09:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105a10:	83 ec 0c             	sub    $0xc,%esp
80105a13:	68 80 49 11 80       	push   $0x80114980
80105a18:	e8 b1 03 00 00       	call   80105dce <release>
80105a1d:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a20:	b8 00 00 00 00       	mov    $0x0,%eax
80105a25:	eb 25                	jmp    80105a4c <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a27:	81 45 f4 c4 01 00 00 	addl   $0x1c4,-0xc(%ebp)
80105a2e:	81 7d f4 b4 ba 11 80 	cmpl   $0x8011bab4,-0xc(%ebp)
80105a35:	72 af                	jb     801059e6 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a37:	83 ec 0c             	sub    $0xc,%esp
80105a3a:	68 80 49 11 80       	push   $0x80114980
80105a3f:	e8 8a 03 00 00       	call   80105dce <release>
80105a44:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a4c:	c9                   	leave  
80105a4d:	c3                   	ret    

80105a4e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a4e:	55                   	push   %ebp
80105a4f:	89 e5                	mov    %esp,%ebp
80105a51:	83 ec 18             	sub    $0x18,%esp
  int percent;
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a54:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
80105a5b:	eb 22                	jmp    80105a7f <procdump+0x31>
    if(p->state == UNUSED)
80105a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a60:	8b 40 0c             	mov    0xc(%eax),%eax
80105a63:	85 c0                	test   %eax,%eax
80105a65:	74 10                	je     80105a77 <procdump+0x29>
      continue;
    printProcMemPageInfo(p);
80105a67:	83 ec 0c             	sub    $0xc,%esp
80105a6a:	ff 75 f4             	pushl  -0xc(%ebp)
80105a6d:	e8 57 00 00 00       	call   80105ac9 <printProcMemPageInfo>
80105a72:	83 c4 10             	add    $0x10,%esp
80105a75:	eb 01                	jmp    80105a78 <procdump+0x2a>
{
  int percent;
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105a77:	90                   	nop
void
procdump(void)
{
  int percent;
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a78:	81 45 f4 c4 01 00 00 	addl   $0x1c4,-0xc(%ebp)
80105a7f:	81 7d f4 b4 ba 11 80 	cmpl   $0x8011bab4,-0xc(%ebp)
80105a86:	72 d5                	jb     80105a5d <procdump+0xf>
    if(p->state == UNUSED)
      continue;
    printProcMemPageInfo(p);
  }
  // print general (not per-process) physical memory pages info
  uint a = physicalPageStatistic.numOfPhysicalPages;
80105a88:	a1 60 42 11 80       	mov    0x80114260,%eax
80105a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint b =  physicalPageStatistic.numOfInitPages;
80105a90:	a1 5c 42 11 80       	mov    0x8011425c,%eax
80105a95:	89 45 ec             	mov    %eax,-0x14(%ebp)
  percent = a*100/b;
80105a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9b:	6b c0 64             	imul   $0x64,%eax,%eax
80105a9e:	ba 00 00 00 00       	mov    $0x0,%edx
80105aa3:	f7 75 ec             	divl   -0x14(%ebp)
80105aa6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  cprintf("\nratio:  %d/%d = 0.%d%\n",  physicalPageStatistic.numOfPhysicalPages,physicalPageStatistic.numOfInitPages , percent);
80105aa9:	8b 15 5c 42 11 80    	mov    0x8011425c,%edx
80105aaf:	a1 60 42 11 80       	mov    0x80114260,%eax
80105ab4:	ff 75 e8             	pushl  -0x18(%ebp)
80105ab7:	52                   	push   %edx
80105ab8:	50                   	push   %eax
80105ab9:	68 d2 a1 10 80       	push   $0x8010a1d2
80105abe:	e8 03 a9 ff ff       	call   801003c6 <cprintf>
80105ac3:	83 c4 10             	add    $0x10,%esp
  }
80105ac6:	90                   	nop
80105ac7:	c9                   	leave  
80105ac8:	c3                   	ret    

80105ac9 <printProcMemPageInfo>:

void
printProcMemPageInfo(struct proc *proc){
80105ac9:	55                   	push   %ebp
80105aca:	89 e5                	mov    %esp,%ebp
80105acc:	83 ec 38             	sub    $0x38,%esp
  };
  int i;
  char *state;
 uint pc[10];

  if(proc->state >= 0 && proc->state < NELEM(states) && states[proc->state])
80105acf:	8b 45 08             	mov    0x8(%ebp),%eax
80105ad2:	8b 40 0c             	mov    0xc(%eax),%eax
80105ad5:	83 f8 05             	cmp    $0x5,%eax
80105ad8:	77 23                	ja     80105afd <printProcMemPageInfo+0x34>
80105ada:	8b 45 08             	mov    0x8(%ebp),%eax
80105add:	8b 40 0c             	mov    0xc(%eax),%eax
80105ae0:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
80105ae7:	85 c0                	test   %eax,%eax
80105ae9:	74 12                	je     80105afd <printProcMemPageInfo+0x34>
    state = states[proc->state];
80105aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80105aee:	8b 40 0c             	mov    0xc(%eax),%eax
80105af1:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
80105af8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105afb:	eb 07                	jmp    80105b04 <printProcMemPageInfo+0x3b>
  else
    state = "???";
80105afd:	c7 45 f0 ea a1 10 80 	movl   $0x8010a1ea,-0x10(%ebp)

  // regular xv6 procdump printing
  cprintf("\n%d %s %s\n", proc->pid, state, proc->name);
80105b04:	8b 45 08             	mov    0x8(%ebp),%eax
80105b07:	8d 50 6c             	lea    0x6c(%eax),%edx
80105b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b0d:	8b 40 10             	mov    0x10(%eax),%eax
80105b10:	52                   	push   %edx
80105b11:	ff 75 f0             	pushl  -0x10(%ebp)
80105b14:	50                   	push   %eax
80105b15:	68 ee a1 10 80       	push   $0x8010a1ee
80105b1a:	e8 a7 a8 ff ff       	call   801003c6 <cprintf>
80105b1f:	83 c4 10             	add    $0x10,%esp

  //print out memory pages info:
  cprintf("allocated memory pages: %d\n", proc->pagesInPhMem);
80105b22:	8b 45 08             	mov    0x8(%ebp),%eax
80105b25:	8b 80 b4 01 00 00    	mov    0x1b4(%eax),%eax
80105b2b:	83 ec 08             	sub    $0x8,%esp
80105b2e:	50                   	push   %eax
80105b2f:	68 f9 a1 10 80       	push   $0x8010a1f9
80105b34:	e8 8d a8 ff ff       	call   801003c6 <cprintf>
80105b39:	83 c4 10             	add    $0x10,%esp
  cprintf("currently paged out: %d\n", proc->pagesInDisc);
80105b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b3f:	8b 80 b8 01 00 00    	mov    0x1b8(%eax),%eax
80105b45:	83 ec 08             	sub    $0x8,%esp
80105b48:	50                   	push   %eax
80105b49:	68 15 a2 10 80       	push   $0x8010a215
80105b4e:	e8 73 a8 ff ff       	call   801003c6 <cprintf>
80105b53:	83 c4 10             	add    $0x10,%esp
  cprintf("page faults: %d\n", proc->totalPageFaultCount);
80105b56:	8b 45 08             	mov    0x8(%ebp),%eax
80105b59:	8b 80 bc 01 00 00    	mov    0x1bc(%eax),%eax
80105b5f:	83 ec 08             	sub    $0x8,%esp
80105b62:	50                   	push   %eax
80105b63:	68 2e a2 10 80       	push   $0x8010a22e
80105b68:	e8 59 a8 ff ff       	call   801003c6 <cprintf>
80105b6d:	83 c4 10             	add    $0x10,%esp
  cprintf("Total number of paged out operation: %d\n\n", proc->totalSwappedCount);
80105b70:	8b 45 08             	mov    0x8(%ebp),%eax
80105b73:	8b 80 c0 01 00 00    	mov    0x1c0(%eax),%eax
80105b79:	83 ec 08             	sub    $0x8,%esp
80105b7c:	50                   	push   %eax
80105b7d:	68 40 a2 10 80       	push   $0x8010a240
80105b82:	e8 3f a8 ff ff       	call   801003c6 <cprintf>
80105b87:	83 c4 10             	add    $0x10,%esp

  // regular xv6 procdump printing
  if(proc->state == SLEEPING){
80105b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b8d:	8b 40 0c             	mov    0xc(%eax),%eax
80105b90:	83 f8 02             	cmp    $0x2,%eax
80105b93:	75 54                	jne    80105be9 <printProcMemPageInfo+0x120>
    getcallerpcs((uint*)proc->context->ebp+2, pc);
80105b95:	8b 45 08             	mov    0x8(%ebp),%eax
80105b98:	8b 40 1c             	mov    0x1c(%eax),%eax
80105b9b:	8b 40 0c             	mov    0xc(%eax),%eax
80105b9e:	83 c0 08             	add    $0x8,%eax
80105ba1:	89 c2                	mov    %eax,%edx
80105ba3:	83 ec 08             	sub    $0x8,%esp
80105ba6:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ba9:	50                   	push   %eax
80105baa:	52                   	push   %edx
80105bab:	e8 70 02 00 00       	call   80105e20 <getcallerpcs>
80105bb0:	83 c4 10             	add    $0x10,%esp
    for(i=0; i<10 && pc[i] != 0; i++)
80105bb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105bba:	eb 1c                	jmp    80105bd8 <printProcMemPageInfo+0x10f>
      cprintf("%p ", pc[i]);
80105bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbf:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
80105bc3:	83 ec 08             	sub    $0x8,%esp
80105bc6:	50                   	push   %eax
80105bc7:	68 6a a2 10 80       	push   $0x8010a26a
80105bcc:	e8 f5 a7 ff ff       	call   801003c6 <cprintf>
80105bd1:	83 c4 10             	add    $0x10,%esp
  cprintf("Total number of paged out operation: %d\n\n", proc->totalSwappedCount);

  // regular xv6 procdump printing
  if(proc->state == SLEEPING){
    getcallerpcs((uint*)proc->context->ebp+2, pc);
    for(i=0; i<10 && pc[i] != 0; i++)
80105bd4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105bd8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105bdc:	7f 0b                	jg     80105be9 <printProcMemPageInfo+0x120>
80105bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be1:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
80105be5:	85 c0                	test   %eax,%eax
80105be7:	75 d3                	jne    80105bbc <printProcMemPageInfo+0xf3>
      cprintf("%p ", pc[i]);
  }
  }
80105be9:	90                   	nop
80105bea:	c9                   	leave  
80105beb:	c3                   	ret    

80105bec <updateLAP>:

void
updateLAP()
{
80105bec:	55                   	push   %ebp
80105bed:	89 e5                	mov    %esp,%ebp
80105bef:	83 ec 18             	sub    $0x18,%esp
    struct proc *p;
    int i;
    pte_t *pageTableEntry;
    acquire(&ptable.lock);
80105bf2:	83 ec 0c             	sub    $0xc,%esp
80105bf5:	68 80 49 11 80       	push   $0x80114980
80105bfa:	e8 68 01 00 00       	call   80105d67 <acquire>
80105bff:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc ; p < &ptable.proc[NPROC]; p++)
80105c02:	c7 45 f4 b4 49 11 80 	movl   $0x801149b4,-0xc(%ebp)
80105c09:	e9 df 00 00 00       	jmp    80105ced <updateLAP+0x101>
    {
        // check the process state and that it is not shell to init
        if((p->state == RUNNING || p->state == RUNNABLE || p->state == SLEEPING) && (p->pid > 2))
80105c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c11:	8b 40 0c             	mov    0xc(%eax),%eax
80105c14:	83 f8 04             	cmp    $0x4,%eax
80105c17:	74 1a                	je     80105c33 <updateLAP+0x47>
80105c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1c:	8b 40 0c             	mov    0xc(%eax),%eax
80105c1f:	83 f8 03             	cmp    $0x3,%eax
80105c22:	74 0f                	je     80105c33 <updateLAP+0x47>
80105c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c27:	8b 40 0c             	mov    0xc(%eax),%eax
80105c2a:	83 f8 02             	cmp    $0x2,%eax
80105c2d:	0f 85 b3 00 00 00    	jne    80105ce6 <updateLAP+0xfa>
80105c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c36:	8b 40 10             	mov    0x10(%eax),%eax
80105c39:	83 f8 02             	cmp    $0x2,%eax
80105c3c:	0f 8e a4 00 00 00    	jle    80105ce6 <updateLAP+0xfa>
        {
            // iterate over all the pages in memory
            for(i = 0 ; i < MAX_PSYC_PAGES ; i++)
80105c42:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105c49:	e9 8e 00 00 00       	jmp    80105cdc <updateLAP+0xf0>
            {
                if(p->physical[i].virtualAdress == (char*)0xffffffff)
80105c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c51:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c54:	83 c2 0b             	add    $0xb,%edx
80105c57:	c1 e2 04             	shl    $0x4,%edx
80105c5a:	01 d0                	add    %edx,%eax
80105c5c:	83 c0 0c             	add    $0xc,%eax
80105c5f:	8b 00                	mov    (%eax),%eax
80105c61:	83 f8 ff             	cmp    $0xffffffff,%eax
80105c64:	74 71                	je     80105cd7 <updateLAP+0xeb>
                {
                    continue; // there is no page here so nothing to do
                }
                pageTableEntry = walkpgdir(p->pgdir, p->physical[i].virtualAdress, 0);
80105c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c69:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c6c:	83 c2 0b             	add    $0xb,%edx
80105c6f:	c1 e2 04             	shl    $0x4,%edx
80105c72:	01 d0                	add    %edx,%eax
80105c74:	83 c0 0c             	add    $0xc,%eax
80105c77:	8b 10                	mov    (%eax),%edx
80105c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7c:	8b 40 04             	mov    0x4(%eax),%eax
80105c7f:	83 ec 04             	sub    $0x4,%esp
80105c82:	6a 00                	push   $0x0
80105c84:	52                   	push   %edx
80105c85:	50                   	push   %eax
80105c86:	e8 4f 2d 00 00       	call   801089da <walkpgdir>
80105c8b:	83 c4 10             	add    $0x10,%esp
80105c8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
                if(*pageTableEntry & PTE_A) // check if access bit is on
80105c91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c94:	8b 00                	mov    (%eax),%eax
80105c96:	83 e0 20             	and    $0x20,%eax
80105c99:	85 c0                	test   %eax,%eax
80105c9b:	74 29                	je     80105cc6 <updateLAP+0xda>
                {
                  p->physical[i].accessCount++;
80105c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ca3:	83 c2 0b             	add    $0xb,%edx
80105ca6:	c1 e2 04             	shl    $0x4,%edx
80105ca9:	01 d0                	add    %edx,%eax
80105cab:	83 c0 10             	add    $0x10,%eax
80105cae:	8b 00                	mov    (%eax),%eax
80105cb0:	8d 50 01             	lea    0x1(%eax),%edx
80105cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105cb9:	83 c1 0b             	add    $0xb,%ecx
80105cbc:	c1 e1 04             	shl    $0x4,%ecx
80105cbf:	01 c8                	add    %ecx,%eax
80105cc1:	83 c0 10             	add    $0x10,%eax
80105cc4:	89 10                	mov    %edx,(%eax)
                }
                *pageTableEntry &= ~PTE_A; //reset all bits but PTE_A
80105cc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cc9:	8b 00                	mov    (%eax),%eax
80105ccb:	83 e0 df             	and    $0xffffffdf,%eax
80105cce:	89 c2                	mov    %eax,%edx
80105cd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cd3:	89 10                	mov    %edx,(%eax)
80105cd5:	eb 01                	jmp    80105cd8 <updateLAP+0xec>
            // iterate over all the pages in memory
            for(i = 0 ; i < MAX_PSYC_PAGES ; i++)
            {
                if(p->physical[i].virtualAdress == (char*)0xffffffff)
                {
                    continue; // there is no page here so nothing to do
80105cd7:	90                   	nop
    {
        // check the process state and that it is not shell to init
        if((p->state == RUNNING || p->state == RUNNABLE || p->state == SLEEPING) && (p->pid > 2))
        {
            // iterate over all the pages in memory
            for(i = 0 ; i < MAX_PSYC_PAGES ; i++)
80105cd8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105cdc:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80105ce0:	0f 8e 68 ff ff ff    	jle    80105c4e <updateLAP+0x62>
{
    struct proc *p;
    int i;
    pte_t *pageTableEntry;
    acquire(&ptable.lock);
    for(p = ptable.proc ; p < &ptable.proc[NPROC]; p++)
80105ce6:	81 45 f4 c4 01 00 00 	addl   $0x1c4,-0xc(%ebp)
80105ced:	81 7d f4 b4 ba 11 80 	cmpl   $0x8011bab4,-0xc(%ebp)
80105cf4:	0f 82 14 ff ff ff    	jb     80105c0e <updateLAP+0x22>
                }
                *pageTableEntry &= ~PTE_A; //reset all bits but PTE_A
            }
        }
    }
    release(&ptable.lock);
80105cfa:	83 ec 0c             	sub    $0xc,%esp
80105cfd:	68 80 49 11 80       	push   $0x80114980
80105d02:	e8 c7 00 00 00       	call   80105dce <release>
80105d07:	83 c4 10             	add    $0x10,%esp
}
80105d0a:	90                   	nop
80105d0b:	c9                   	leave  
80105d0c:	c3                   	ret    

80105d0d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105d0d:	55                   	push   %ebp
80105d0e:	89 e5                	mov    %esp,%ebp
80105d10:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105d13:	9c                   	pushf  
80105d14:	58                   	pop    %eax
80105d15:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105d18:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105d1b:	c9                   	leave  
80105d1c:	c3                   	ret    

80105d1d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105d1d:	55                   	push   %ebp
80105d1e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105d20:	fa                   	cli    
}
80105d21:	90                   	nop
80105d22:	5d                   	pop    %ebp
80105d23:	c3                   	ret    

80105d24 <sti>:

static inline void
sti(void)
{
80105d24:	55                   	push   %ebp
80105d25:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105d27:	fb                   	sti    
}
80105d28:	90                   	nop
80105d29:	5d                   	pop    %ebp
80105d2a:	c3                   	ret    

80105d2b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105d2b:	55                   	push   %ebp
80105d2c:	89 e5                	mov    %esp,%ebp
80105d2e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105d31:	8b 55 08             	mov    0x8(%ebp),%edx
80105d34:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d37:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105d3a:	f0 87 02             	lock xchg %eax,(%edx)
80105d3d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105d40:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105d43:	c9                   	leave  
80105d44:	c3                   	ret    

80105d45 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105d45:	55                   	push   %ebp
80105d46:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105d48:	8b 45 08             	mov    0x8(%ebp),%eax
80105d4b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105d4e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105d51:	8b 45 08             	mov    0x8(%ebp),%eax
80105d54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80105d5d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105d64:	90                   	nop
80105d65:	5d                   	pop    %ebp
80105d66:	c3                   	ret    

80105d67 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105d67:	55                   	push   %ebp
80105d68:	89 e5                	mov    %esp,%ebp
80105d6a:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105d6d:	e8 52 01 00 00       	call   80105ec4 <pushcli>
  if(holding(lk))
80105d72:	8b 45 08             	mov    0x8(%ebp),%eax
80105d75:	83 ec 0c             	sub    $0xc,%esp
80105d78:	50                   	push   %eax
80105d79:	e8 1c 01 00 00       	call   80105e9a <holding>
80105d7e:	83 c4 10             	add    $0x10,%esp
80105d81:	85 c0                	test   %eax,%eax
80105d83:	74 0d                	je     80105d92 <acquire+0x2b>
    panic("acquire");
80105d85:	83 ec 0c             	sub    $0xc,%esp
80105d88:	68 9d a2 10 80       	push   $0x8010a29d
80105d8d:	e8 d4 a7 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105d92:	90                   	nop
80105d93:	8b 45 08             	mov    0x8(%ebp),%eax
80105d96:	83 ec 08             	sub    $0x8,%esp
80105d99:	6a 01                	push   $0x1
80105d9b:	50                   	push   %eax
80105d9c:	e8 8a ff ff ff       	call   80105d2b <xchg>
80105da1:	83 c4 10             	add    $0x10,%esp
80105da4:	85 c0                	test   %eax,%eax
80105da6:	75 eb                	jne    80105d93 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105da8:	8b 45 08             	mov    0x8(%ebp),%eax
80105dab:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105db2:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105db5:	8b 45 08             	mov    0x8(%ebp),%eax
80105db8:	83 c0 0c             	add    $0xc,%eax
80105dbb:	83 ec 08             	sub    $0x8,%esp
80105dbe:	50                   	push   %eax
80105dbf:	8d 45 08             	lea    0x8(%ebp),%eax
80105dc2:	50                   	push   %eax
80105dc3:	e8 58 00 00 00       	call   80105e20 <getcallerpcs>
80105dc8:	83 c4 10             	add    $0x10,%esp
}
80105dcb:	90                   	nop
80105dcc:	c9                   	leave  
80105dcd:	c3                   	ret    

80105dce <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105dce:	55                   	push   %ebp
80105dcf:	89 e5                	mov    %esp,%ebp
80105dd1:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105dd4:	83 ec 0c             	sub    $0xc,%esp
80105dd7:	ff 75 08             	pushl  0x8(%ebp)
80105dda:	e8 bb 00 00 00       	call   80105e9a <holding>
80105ddf:	83 c4 10             	add    $0x10,%esp
80105de2:	85 c0                	test   %eax,%eax
80105de4:	75 0d                	jne    80105df3 <release+0x25>
    panic("release");
80105de6:	83 ec 0c             	sub    $0xc,%esp
80105de9:	68 a5 a2 10 80       	push   $0x8010a2a5
80105dee:	e8 73 a7 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105df3:	8b 45 08             	mov    0x8(%ebp),%eax
80105df6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80105e00:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105e07:	8b 45 08             	mov    0x8(%ebp),%eax
80105e0a:	83 ec 08             	sub    $0x8,%esp
80105e0d:	6a 00                	push   $0x0
80105e0f:	50                   	push   %eax
80105e10:	e8 16 ff ff ff       	call   80105d2b <xchg>
80105e15:	83 c4 10             	add    $0x10,%esp

  popcli();
80105e18:	e8 ec 00 00 00       	call   80105f09 <popcli>
}
80105e1d:	90                   	nop
80105e1e:	c9                   	leave  
80105e1f:	c3                   	ret    

80105e20 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105e20:	55                   	push   %ebp
80105e21:	89 e5                	mov    %esp,%ebp
80105e23:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105e26:	8b 45 08             	mov    0x8(%ebp),%eax
80105e29:	83 e8 08             	sub    $0x8,%eax
80105e2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105e2f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105e36:	eb 38                	jmp    80105e70 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105e38:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105e3c:	74 53                	je     80105e91 <getcallerpcs+0x71>
80105e3e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105e45:	76 4a                	jbe    80105e91 <getcallerpcs+0x71>
80105e47:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105e4b:	74 44                	je     80105e91 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105e4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e5a:	01 c2                	add    %eax,%edx
80105e5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e5f:	8b 40 04             	mov    0x4(%eax),%eax
80105e62:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105e64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e67:	8b 00                	mov    (%eax),%eax
80105e69:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105e6c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105e70:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105e74:	7e c2                	jle    80105e38 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105e76:	eb 19                	jmp    80105e91 <getcallerpcs+0x71>
    pcs[i] = 0;
80105e78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105e82:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e85:	01 d0                	add    %edx,%eax
80105e87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105e8d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105e91:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105e95:	7e e1                	jle    80105e78 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105e97:	90                   	nop
80105e98:	c9                   	leave  
80105e99:	c3                   	ret    

80105e9a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105e9a:	55                   	push   %ebp
80105e9b:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea0:	8b 00                	mov    (%eax),%eax
80105ea2:	85 c0                	test   %eax,%eax
80105ea4:	74 17                	je     80105ebd <holding+0x23>
80105ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea9:	8b 50 08             	mov    0x8(%eax),%edx
80105eac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105eb2:	39 c2                	cmp    %eax,%edx
80105eb4:	75 07                	jne    80105ebd <holding+0x23>
80105eb6:	b8 01 00 00 00       	mov    $0x1,%eax
80105ebb:	eb 05                	jmp    80105ec2 <holding+0x28>
80105ebd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ec2:	5d                   	pop    %ebp
80105ec3:	c3                   	ret    

80105ec4 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105ec4:	55                   	push   %ebp
80105ec5:	89 e5                	mov    %esp,%ebp
80105ec7:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105eca:	e8 3e fe ff ff       	call   80105d0d <readeflags>
80105ecf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105ed2:	e8 46 fe ff ff       	call   80105d1d <cli>
  if(cpu->ncli++ == 0)
80105ed7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105ede:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105ee4:	8d 48 01             	lea    0x1(%eax),%ecx
80105ee7:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105eed:	85 c0                	test   %eax,%eax
80105eef:	75 15                	jne    80105f06 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105ef1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ef7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105efa:	81 e2 00 02 00 00    	and    $0x200,%edx
80105f00:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105f06:	90                   	nop
80105f07:	c9                   	leave  
80105f08:	c3                   	ret    

80105f09 <popcli>:

void
popcli(void)
{
80105f09:	55                   	push   %ebp
80105f0a:	89 e5                	mov    %esp,%ebp
80105f0c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105f0f:	e8 f9 fd ff ff       	call   80105d0d <readeflags>
80105f14:	25 00 02 00 00       	and    $0x200,%eax
80105f19:	85 c0                	test   %eax,%eax
80105f1b:	74 0d                	je     80105f2a <popcli+0x21>
    panic("popcli - interruptible");
80105f1d:	83 ec 0c             	sub    $0xc,%esp
80105f20:	68 ad a2 10 80       	push   $0x8010a2ad
80105f25:	e8 3c a6 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105f2a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105f30:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105f36:	83 ea 01             	sub    $0x1,%edx
80105f39:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105f3f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105f45:	85 c0                	test   %eax,%eax
80105f47:	79 0d                	jns    80105f56 <popcli+0x4d>
    panic("popcli");
80105f49:	83 ec 0c             	sub    $0xc,%esp
80105f4c:	68 c4 a2 10 80       	push   $0x8010a2c4
80105f51:	e8 10 a6 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105f56:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105f5c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105f62:	85 c0                	test   %eax,%eax
80105f64:	75 15                	jne    80105f7b <popcli+0x72>
80105f66:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105f6c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105f72:	85 c0                	test   %eax,%eax
80105f74:	74 05                	je     80105f7b <popcli+0x72>
    sti();
80105f76:	e8 a9 fd ff ff       	call   80105d24 <sti>
}
80105f7b:	90                   	nop
80105f7c:	c9                   	leave  
80105f7d:	c3                   	ret    

80105f7e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105f7e:	55                   	push   %ebp
80105f7f:	89 e5                	mov    %esp,%ebp
80105f81:	57                   	push   %edi
80105f82:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105f83:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105f86:	8b 55 10             	mov    0x10(%ebp),%edx
80105f89:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f8c:	89 cb                	mov    %ecx,%ebx
80105f8e:	89 df                	mov    %ebx,%edi
80105f90:	89 d1                	mov    %edx,%ecx
80105f92:	fc                   	cld    
80105f93:	f3 aa                	rep stos %al,%es:(%edi)
80105f95:	89 ca                	mov    %ecx,%edx
80105f97:	89 fb                	mov    %edi,%ebx
80105f99:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105f9c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105f9f:	90                   	nop
80105fa0:	5b                   	pop    %ebx
80105fa1:	5f                   	pop    %edi
80105fa2:	5d                   	pop    %ebp
80105fa3:	c3                   	ret    

80105fa4 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105fa4:	55                   	push   %ebp
80105fa5:	89 e5                	mov    %esp,%ebp
80105fa7:	57                   	push   %edi
80105fa8:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105fa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105fac:	8b 55 10             	mov    0x10(%ebp),%edx
80105faf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fb2:	89 cb                	mov    %ecx,%ebx
80105fb4:	89 df                	mov    %ebx,%edi
80105fb6:	89 d1                	mov    %edx,%ecx
80105fb8:	fc                   	cld    
80105fb9:	f3 ab                	rep stos %eax,%es:(%edi)
80105fbb:	89 ca                	mov    %ecx,%edx
80105fbd:	89 fb                	mov    %edi,%ebx
80105fbf:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105fc2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105fc5:	90                   	nop
80105fc6:	5b                   	pop    %ebx
80105fc7:	5f                   	pop    %edi
80105fc8:	5d                   	pop    %ebp
80105fc9:	c3                   	ret    

80105fca <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105fca:	55                   	push   %ebp
80105fcb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd0:	83 e0 03             	and    $0x3,%eax
80105fd3:	85 c0                	test   %eax,%eax
80105fd5:	75 43                	jne    8010601a <memset+0x50>
80105fd7:	8b 45 10             	mov    0x10(%ebp),%eax
80105fda:	83 e0 03             	and    $0x3,%eax
80105fdd:	85 c0                	test   %eax,%eax
80105fdf:	75 39                	jne    8010601a <memset+0x50>
    c &= 0xFF;
80105fe1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105fe8:	8b 45 10             	mov    0x10(%ebp),%eax
80105feb:	c1 e8 02             	shr    $0x2,%eax
80105fee:	89 c1                	mov    %eax,%ecx
80105ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ff3:	c1 e0 18             	shl    $0x18,%eax
80105ff6:	89 c2                	mov    %eax,%edx
80105ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ffb:	c1 e0 10             	shl    $0x10,%eax
80105ffe:	09 c2                	or     %eax,%edx
80106000:	8b 45 0c             	mov    0xc(%ebp),%eax
80106003:	c1 e0 08             	shl    $0x8,%eax
80106006:	09 d0                	or     %edx,%eax
80106008:	0b 45 0c             	or     0xc(%ebp),%eax
8010600b:	51                   	push   %ecx
8010600c:	50                   	push   %eax
8010600d:	ff 75 08             	pushl  0x8(%ebp)
80106010:	e8 8f ff ff ff       	call   80105fa4 <stosl>
80106015:	83 c4 0c             	add    $0xc,%esp
80106018:	eb 12                	jmp    8010602c <memset+0x62>
  } else
    stosb(dst, c, n);
8010601a:	8b 45 10             	mov    0x10(%ebp),%eax
8010601d:	50                   	push   %eax
8010601e:	ff 75 0c             	pushl  0xc(%ebp)
80106021:	ff 75 08             	pushl  0x8(%ebp)
80106024:	e8 55 ff ff ff       	call   80105f7e <stosb>
80106029:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010602c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010602f:	c9                   	leave  
80106030:	c3                   	ret    

80106031 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80106031:	55                   	push   %ebp
80106032:	89 e5                	mov    %esp,%ebp
80106034:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106037:	8b 45 08             	mov    0x8(%ebp),%eax
8010603a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010603d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106040:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80106043:	eb 30                	jmp    80106075 <memcmp+0x44>
    if(*s1 != *s2)
80106045:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106048:	0f b6 10             	movzbl (%eax),%edx
8010604b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010604e:	0f b6 00             	movzbl (%eax),%eax
80106051:	38 c2                	cmp    %al,%dl
80106053:	74 18                	je     8010606d <memcmp+0x3c>
      return *s1 - *s2;
80106055:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106058:	0f b6 00             	movzbl (%eax),%eax
8010605b:	0f b6 d0             	movzbl %al,%edx
8010605e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106061:	0f b6 00             	movzbl (%eax),%eax
80106064:	0f b6 c0             	movzbl %al,%eax
80106067:	29 c2                	sub    %eax,%edx
80106069:	89 d0                	mov    %edx,%eax
8010606b:	eb 1a                	jmp    80106087 <memcmp+0x56>
    s1++, s2++;
8010606d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106071:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106075:	8b 45 10             	mov    0x10(%ebp),%eax
80106078:	8d 50 ff             	lea    -0x1(%eax),%edx
8010607b:	89 55 10             	mov    %edx,0x10(%ebp)
8010607e:	85 c0                	test   %eax,%eax
80106080:	75 c3                	jne    80106045 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80106082:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106087:	c9                   	leave  
80106088:	c3                   	ret    

80106089 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106089:	55                   	push   %ebp
8010608a:	89 e5                	mov    %esp,%ebp
8010608c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010608f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106092:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106095:	8b 45 08             	mov    0x8(%ebp),%eax
80106098:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010609b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010609e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801060a1:	73 54                	jae    801060f7 <memmove+0x6e>
801060a3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060a6:	8b 45 10             	mov    0x10(%ebp),%eax
801060a9:	01 d0                	add    %edx,%eax
801060ab:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801060ae:	76 47                	jbe    801060f7 <memmove+0x6e>
    s += n;
801060b0:	8b 45 10             	mov    0x10(%ebp),%eax
801060b3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801060b6:	8b 45 10             	mov    0x10(%ebp),%eax
801060b9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801060bc:	eb 13                	jmp    801060d1 <memmove+0x48>
      *--d = *--s;
801060be:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801060c2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801060c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060c9:	0f b6 10             	movzbl (%eax),%edx
801060cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801060cf:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801060d1:	8b 45 10             	mov    0x10(%ebp),%eax
801060d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801060d7:	89 55 10             	mov    %edx,0x10(%ebp)
801060da:	85 c0                	test   %eax,%eax
801060dc:	75 e0                	jne    801060be <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801060de:	eb 24                	jmp    80106104 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801060e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801060e3:	8d 50 01             	lea    0x1(%eax),%edx
801060e6:	89 55 f8             	mov    %edx,-0x8(%ebp)
801060e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060ec:	8d 4a 01             	lea    0x1(%edx),%ecx
801060ef:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801060f2:	0f b6 12             	movzbl (%edx),%edx
801060f5:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801060f7:	8b 45 10             	mov    0x10(%ebp),%eax
801060fa:	8d 50 ff             	lea    -0x1(%eax),%edx
801060fd:	89 55 10             	mov    %edx,0x10(%ebp)
80106100:	85 c0                	test   %eax,%eax
80106102:	75 dc                	jne    801060e0 <memmove+0x57>
      *d++ = *s++;

  return dst;
80106104:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106107:	c9                   	leave  
80106108:	c3                   	ret    

80106109 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80106109:	55                   	push   %ebp
8010610a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010610c:	ff 75 10             	pushl  0x10(%ebp)
8010610f:	ff 75 0c             	pushl  0xc(%ebp)
80106112:	ff 75 08             	pushl  0x8(%ebp)
80106115:	e8 6f ff ff ff       	call   80106089 <memmove>
8010611a:	83 c4 0c             	add    $0xc,%esp
}
8010611d:	c9                   	leave  
8010611e:	c3                   	ret    

8010611f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010611f:	55                   	push   %ebp
80106120:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80106122:	eb 0c                	jmp    80106130 <strncmp+0x11>
    n--, p++, q++;
80106124:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106128:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010612c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80106130:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106134:	74 1a                	je     80106150 <strncmp+0x31>
80106136:	8b 45 08             	mov    0x8(%ebp),%eax
80106139:	0f b6 00             	movzbl (%eax),%eax
8010613c:	84 c0                	test   %al,%al
8010613e:	74 10                	je     80106150 <strncmp+0x31>
80106140:	8b 45 08             	mov    0x8(%ebp),%eax
80106143:	0f b6 10             	movzbl (%eax),%edx
80106146:	8b 45 0c             	mov    0xc(%ebp),%eax
80106149:	0f b6 00             	movzbl (%eax),%eax
8010614c:	38 c2                	cmp    %al,%dl
8010614e:	74 d4                	je     80106124 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80106150:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106154:	75 07                	jne    8010615d <strncmp+0x3e>
    return 0;
80106156:	b8 00 00 00 00       	mov    $0x0,%eax
8010615b:	eb 16                	jmp    80106173 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010615d:	8b 45 08             	mov    0x8(%ebp),%eax
80106160:	0f b6 00             	movzbl (%eax),%eax
80106163:	0f b6 d0             	movzbl %al,%edx
80106166:	8b 45 0c             	mov    0xc(%ebp),%eax
80106169:	0f b6 00             	movzbl (%eax),%eax
8010616c:	0f b6 c0             	movzbl %al,%eax
8010616f:	29 c2                	sub    %eax,%edx
80106171:	89 d0                	mov    %edx,%eax
}
80106173:	5d                   	pop    %ebp
80106174:	c3                   	ret    

80106175 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106175:	55                   	push   %ebp
80106176:	89 e5                	mov    %esp,%ebp
80106178:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010617b:	8b 45 08             	mov    0x8(%ebp),%eax
8010617e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106181:	90                   	nop
80106182:	8b 45 10             	mov    0x10(%ebp),%eax
80106185:	8d 50 ff             	lea    -0x1(%eax),%edx
80106188:	89 55 10             	mov    %edx,0x10(%ebp)
8010618b:	85 c0                	test   %eax,%eax
8010618d:	7e 2c                	jle    801061bb <strncpy+0x46>
8010618f:	8b 45 08             	mov    0x8(%ebp),%eax
80106192:	8d 50 01             	lea    0x1(%eax),%edx
80106195:	89 55 08             	mov    %edx,0x8(%ebp)
80106198:	8b 55 0c             	mov    0xc(%ebp),%edx
8010619b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010619e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801061a1:	0f b6 12             	movzbl (%edx),%edx
801061a4:	88 10                	mov    %dl,(%eax)
801061a6:	0f b6 00             	movzbl (%eax),%eax
801061a9:	84 c0                	test   %al,%al
801061ab:	75 d5                	jne    80106182 <strncpy+0xd>
    ;
  while(n-- > 0)
801061ad:	eb 0c                	jmp    801061bb <strncpy+0x46>
    *s++ = 0;
801061af:	8b 45 08             	mov    0x8(%ebp),%eax
801061b2:	8d 50 01             	lea    0x1(%eax),%edx
801061b5:	89 55 08             	mov    %edx,0x8(%ebp)
801061b8:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801061bb:	8b 45 10             	mov    0x10(%ebp),%eax
801061be:	8d 50 ff             	lea    -0x1(%eax),%edx
801061c1:	89 55 10             	mov    %edx,0x10(%ebp)
801061c4:	85 c0                	test   %eax,%eax
801061c6:	7f e7                	jg     801061af <strncpy+0x3a>
    *s++ = 0;
  return os;
801061c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801061cb:	c9                   	leave  
801061cc:	c3                   	ret    

801061cd <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801061cd:	55                   	push   %ebp
801061ce:	89 e5                	mov    %esp,%ebp
801061d0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801061d3:	8b 45 08             	mov    0x8(%ebp),%eax
801061d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801061d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801061dd:	7f 05                	jg     801061e4 <safestrcpy+0x17>
    return os;
801061df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061e2:	eb 31                	jmp    80106215 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801061e4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801061e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801061ec:	7e 1e                	jle    8010620c <safestrcpy+0x3f>
801061ee:	8b 45 08             	mov    0x8(%ebp),%eax
801061f1:	8d 50 01             	lea    0x1(%eax),%edx
801061f4:	89 55 08             	mov    %edx,0x8(%ebp)
801061f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801061fa:	8d 4a 01             	lea    0x1(%edx),%ecx
801061fd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106200:	0f b6 12             	movzbl (%edx),%edx
80106203:	88 10                	mov    %dl,(%eax)
80106205:	0f b6 00             	movzbl (%eax),%eax
80106208:	84 c0                	test   %al,%al
8010620a:	75 d8                	jne    801061e4 <safestrcpy+0x17>
    ;
  *s = 0;
8010620c:	8b 45 08             	mov    0x8(%ebp),%eax
8010620f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106212:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106215:	c9                   	leave  
80106216:	c3                   	ret    

80106217 <strlen>:

int
strlen(const char *s)
{
80106217:	55                   	push   %ebp
80106218:	89 e5                	mov    %esp,%ebp
8010621a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010621d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106224:	eb 04                	jmp    8010622a <strlen+0x13>
80106226:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010622a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010622d:	8b 45 08             	mov    0x8(%ebp),%eax
80106230:	01 d0                	add    %edx,%eax
80106232:	0f b6 00             	movzbl (%eax),%eax
80106235:	84 c0                	test   %al,%al
80106237:	75 ed                	jne    80106226 <strlen+0xf>
    ;
  return n;
80106239:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010623c:	c9                   	leave  
8010623d:	c3                   	ret    

8010623e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010623e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106242:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106246:	55                   	push   %ebp
  pushl %ebx
80106247:	53                   	push   %ebx
  pushl %esi
80106248:	56                   	push   %esi
  pushl %edi
80106249:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010624a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010624c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010624e:	5f                   	pop    %edi
  popl %esi
8010624f:	5e                   	pop    %esi
  popl %ebx
80106250:	5b                   	pop    %ebx
  popl %ebp
80106251:	5d                   	pop    %ebp
  ret
80106252:	c3                   	ret    

80106253 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106253:	55                   	push   %ebp
80106254:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106256:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010625c:	8b 00                	mov    (%eax),%eax
8010625e:	3b 45 08             	cmp    0x8(%ebp),%eax
80106261:	76 12                	jbe    80106275 <fetchint+0x22>
80106263:	8b 45 08             	mov    0x8(%ebp),%eax
80106266:	8d 50 04             	lea    0x4(%eax),%edx
80106269:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010626f:	8b 00                	mov    (%eax),%eax
80106271:	39 c2                	cmp    %eax,%edx
80106273:	76 07                	jbe    8010627c <fetchint+0x29>
    return -1;
80106275:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627a:	eb 0f                	jmp    8010628b <fetchint+0x38>
  *ip = *(int*)(addr);
8010627c:	8b 45 08             	mov    0x8(%ebp),%eax
8010627f:	8b 10                	mov    (%eax),%edx
80106281:	8b 45 0c             	mov    0xc(%ebp),%eax
80106284:	89 10                	mov    %edx,(%eax)
  return 0;
80106286:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010628b:	5d                   	pop    %ebp
8010628c:	c3                   	ret    

8010628d <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010628d:	55                   	push   %ebp
8010628e:	89 e5                	mov    %esp,%ebp
80106290:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106293:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106299:	8b 00                	mov    (%eax),%eax
8010629b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010629e:	77 07                	ja     801062a7 <fetchstr+0x1a>
    return -1;
801062a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a5:	eb 46                	jmp    801062ed <fetchstr+0x60>
  *pp = (char*)addr;
801062a7:	8b 55 08             	mov    0x8(%ebp),%edx
801062aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801062ad:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801062af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b5:	8b 00                	mov    (%eax),%eax
801062b7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801062ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801062bd:	8b 00                	mov    (%eax),%eax
801062bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
801062c2:	eb 1c                	jmp    801062e0 <fetchstr+0x53>
    if(*s == 0)
801062c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062c7:	0f b6 00             	movzbl (%eax),%eax
801062ca:	84 c0                	test   %al,%al
801062cc:	75 0e                	jne    801062dc <fetchstr+0x4f>
      return s - *pp;
801062ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801062d4:	8b 00                	mov    (%eax),%eax
801062d6:	29 c2                	sub    %eax,%edx
801062d8:	89 d0                	mov    %edx,%eax
801062da:	eb 11                	jmp    801062ed <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801062dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801062e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062e3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801062e6:	72 dc                	jb     801062c4 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801062e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062ed:	c9                   	leave  
801062ee:	c3                   	ret    

801062ef <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801062ef:	55                   	push   %ebp
801062f0:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801062f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062f8:	8b 40 18             	mov    0x18(%eax),%eax
801062fb:	8b 40 44             	mov    0x44(%eax),%eax
801062fe:	8b 55 08             	mov    0x8(%ebp),%edx
80106301:	c1 e2 02             	shl    $0x2,%edx
80106304:	01 d0                	add    %edx,%eax
80106306:	83 c0 04             	add    $0x4,%eax
80106309:	ff 75 0c             	pushl  0xc(%ebp)
8010630c:	50                   	push   %eax
8010630d:	e8 41 ff ff ff       	call   80106253 <fetchint>
80106312:	83 c4 08             	add    $0x8,%esp
}
80106315:	c9                   	leave  
80106316:	c3                   	ret    

80106317 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106317:	55                   	push   %ebp
80106318:	89 e5                	mov    %esp,%ebp
8010631a:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010631d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106320:	50                   	push   %eax
80106321:	ff 75 08             	pushl  0x8(%ebp)
80106324:	e8 c6 ff ff ff       	call   801062ef <argint>
80106329:	83 c4 08             	add    $0x8,%esp
8010632c:	85 c0                	test   %eax,%eax
8010632e:	79 07                	jns    80106337 <argptr+0x20>
    return -1;
80106330:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106335:	eb 3b                	jmp    80106372 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106337:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010633d:	8b 00                	mov    (%eax),%eax
8010633f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106342:	39 d0                	cmp    %edx,%eax
80106344:	76 16                	jbe    8010635c <argptr+0x45>
80106346:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106349:	89 c2                	mov    %eax,%edx
8010634b:	8b 45 10             	mov    0x10(%ebp),%eax
8010634e:	01 c2                	add    %eax,%edx
80106350:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106356:	8b 00                	mov    (%eax),%eax
80106358:	39 c2                	cmp    %eax,%edx
8010635a:	76 07                	jbe    80106363 <argptr+0x4c>
    return -1;
8010635c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106361:	eb 0f                	jmp    80106372 <argptr+0x5b>
  *pp = (char*)i;
80106363:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106366:	89 c2                	mov    %eax,%edx
80106368:	8b 45 0c             	mov    0xc(%ebp),%eax
8010636b:	89 10                	mov    %edx,(%eax)
  return 0;
8010636d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106372:	c9                   	leave  
80106373:	c3                   	ret    

80106374 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106374:	55                   	push   %ebp
80106375:	89 e5                	mov    %esp,%ebp
80106377:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010637a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010637d:	50                   	push   %eax
8010637e:	ff 75 08             	pushl  0x8(%ebp)
80106381:	e8 69 ff ff ff       	call   801062ef <argint>
80106386:	83 c4 08             	add    $0x8,%esp
80106389:	85 c0                	test   %eax,%eax
8010638b:	79 07                	jns    80106394 <argstr+0x20>
    return -1;
8010638d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106392:	eb 0f                	jmp    801063a3 <argstr+0x2f>
  return fetchstr(addr, pp);
80106394:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106397:	ff 75 0c             	pushl  0xc(%ebp)
8010639a:	50                   	push   %eax
8010639b:	e8 ed fe ff ff       	call   8010628d <fetchstr>
801063a0:	83 c4 08             	add    $0x8,%esp
}
801063a3:	c9                   	leave  
801063a4:	c3                   	ret    

801063a5 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801063a5:	55                   	push   %ebp
801063a6:	89 e5                	mov    %esp,%ebp
801063a8:	53                   	push   %ebx
801063a9:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801063ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b2:	8b 40 18             	mov    0x18(%eax),%eax
801063b5:	8b 40 1c             	mov    0x1c(%eax),%eax
801063b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801063bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063bf:	7e 30                	jle    801063f1 <syscall+0x4c>
801063c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c4:	83 f8 15             	cmp    $0x15,%eax
801063c7:	77 28                	ja     801063f1 <syscall+0x4c>
801063c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063cc:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
801063d3:	85 c0                	test   %eax,%eax
801063d5:	74 1a                	je     801063f1 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801063d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063dd:	8b 58 18             	mov    0x18(%eax),%ebx
801063e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e3:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
801063ea:	ff d0                	call   *%eax
801063ec:	89 43 1c             	mov    %eax,0x1c(%ebx)
801063ef:	eb 34                	jmp    80106425 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801063f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063f7:	8d 50 6c             	lea    0x6c(%eax),%edx
801063fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106400:	8b 40 10             	mov    0x10(%eax),%eax
80106403:	ff 75 f4             	pushl  -0xc(%ebp)
80106406:	52                   	push   %edx
80106407:	50                   	push   %eax
80106408:	68 cb a2 10 80       	push   $0x8010a2cb
8010640d:	e8 b4 9f ff ff       	call   801003c6 <cprintf>
80106412:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106415:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010641b:	8b 40 18             	mov    0x18(%eax),%eax
8010641e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106425:	90                   	nop
80106426:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106429:	c9                   	leave  
8010642a:	c3                   	ret    

8010642b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010642b:	55                   	push   %ebp
8010642c:	89 e5                	mov    %esp,%ebp
8010642e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106431:	83 ec 08             	sub    $0x8,%esp
80106434:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106437:	50                   	push   %eax
80106438:	ff 75 08             	pushl  0x8(%ebp)
8010643b:	e8 af fe ff ff       	call   801062ef <argint>
80106440:	83 c4 10             	add    $0x10,%esp
80106443:	85 c0                	test   %eax,%eax
80106445:	79 07                	jns    8010644e <argfd+0x23>
    return -1;
80106447:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010644c:	eb 50                	jmp    8010649e <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010644e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106451:	85 c0                	test   %eax,%eax
80106453:	78 21                	js     80106476 <argfd+0x4b>
80106455:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106458:	83 f8 0f             	cmp    $0xf,%eax
8010645b:	7f 19                	jg     80106476 <argfd+0x4b>
8010645d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106463:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106466:	83 c2 08             	add    $0x8,%edx
80106469:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010646d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106470:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106474:	75 07                	jne    8010647d <argfd+0x52>
    return -1;
80106476:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647b:	eb 21                	jmp    8010649e <argfd+0x73>
  if(pfd)
8010647d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106481:	74 08                	je     8010648b <argfd+0x60>
    *pfd = fd;
80106483:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106486:	8b 45 0c             	mov    0xc(%ebp),%eax
80106489:	89 10                	mov    %edx,(%eax)
  if(pf)
8010648b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010648f:	74 08                	je     80106499 <argfd+0x6e>
    *pf = f;
80106491:	8b 45 10             	mov    0x10(%ebp),%eax
80106494:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106497:	89 10                	mov    %edx,(%eax)
  return 0;
80106499:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010649e:	c9                   	leave  
8010649f:	c3                   	ret    

801064a0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801064a0:	55                   	push   %ebp
801064a1:	89 e5                	mov    %esp,%ebp
801064a3:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801064a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801064ad:	eb 30                	jmp    801064df <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801064af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064b5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801064b8:	83 c2 08             	add    $0x8,%edx
801064bb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801064bf:	85 c0                	test   %eax,%eax
801064c1:	75 18                	jne    801064db <fdalloc+0x3b>
      proc->ofile[fd] = f;
801064c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801064cc:	8d 4a 08             	lea    0x8(%edx),%ecx
801064cf:	8b 55 08             	mov    0x8(%ebp),%edx
801064d2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801064d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801064d9:	eb 0f                	jmp    801064ea <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801064db:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801064df:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801064e3:	7e ca                	jle    801064af <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801064e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801064ea:	c9                   	leave  
801064eb:	c3                   	ret    

801064ec <sys_dup>:

int
sys_dup(void)
{
801064ec:	55                   	push   %ebp
801064ed:	89 e5                	mov    %esp,%ebp
801064ef:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801064f2:	83 ec 04             	sub    $0x4,%esp
801064f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064f8:	50                   	push   %eax
801064f9:	6a 00                	push   $0x0
801064fb:	6a 00                	push   $0x0
801064fd:	e8 29 ff ff ff       	call   8010642b <argfd>
80106502:	83 c4 10             	add    $0x10,%esp
80106505:	85 c0                	test   %eax,%eax
80106507:	79 07                	jns    80106510 <sys_dup+0x24>
    return -1;
80106509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650e:	eb 31                	jmp    80106541 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106510:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106513:	83 ec 0c             	sub    $0xc,%esp
80106516:	50                   	push   %eax
80106517:	e8 84 ff ff ff       	call   801064a0 <fdalloc>
8010651c:	83 c4 10             	add    $0x10,%esp
8010651f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106522:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106526:	79 07                	jns    8010652f <sys_dup+0x43>
    return -1;
80106528:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652d:	eb 12                	jmp    80106541 <sys_dup+0x55>
  filedup(f);
8010652f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106532:	83 ec 0c             	sub    $0xc,%esp
80106535:	50                   	push   %eax
80106536:	e8 57 ae ff ff       	call   80101392 <filedup>
8010653b:	83 c4 10             	add    $0x10,%esp
  return fd;
8010653e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106541:	c9                   	leave  
80106542:	c3                   	ret    

80106543 <sys_read>:

int
sys_read(void)
{
80106543:	55                   	push   %ebp
80106544:	89 e5                	mov    %esp,%ebp
80106546:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106549:	83 ec 04             	sub    $0x4,%esp
8010654c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010654f:	50                   	push   %eax
80106550:	6a 00                	push   $0x0
80106552:	6a 00                	push   $0x0
80106554:	e8 d2 fe ff ff       	call   8010642b <argfd>
80106559:	83 c4 10             	add    $0x10,%esp
8010655c:	85 c0                	test   %eax,%eax
8010655e:	78 2e                	js     8010658e <sys_read+0x4b>
80106560:	83 ec 08             	sub    $0x8,%esp
80106563:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106566:	50                   	push   %eax
80106567:	6a 02                	push   $0x2
80106569:	e8 81 fd ff ff       	call   801062ef <argint>
8010656e:	83 c4 10             	add    $0x10,%esp
80106571:	85 c0                	test   %eax,%eax
80106573:	78 19                	js     8010658e <sys_read+0x4b>
80106575:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106578:	83 ec 04             	sub    $0x4,%esp
8010657b:	50                   	push   %eax
8010657c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010657f:	50                   	push   %eax
80106580:	6a 01                	push   $0x1
80106582:	e8 90 fd ff ff       	call   80106317 <argptr>
80106587:	83 c4 10             	add    $0x10,%esp
8010658a:	85 c0                	test   %eax,%eax
8010658c:	79 07                	jns    80106595 <sys_read+0x52>
    return -1;
8010658e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106593:	eb 17                	jmp    801065ac <sys_read+0x69>
  return fileread(f, p, n);
80106595:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106598:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010659b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659e:	83 ec 04             	sub    $0x4,%esp
801065a1:	51                   	push   %ecx
801065a2:	52                   	push   %edx
801065a3:	50                   	push   %eax
801065a4:	e8 79 af ff ff       	call   80101522 <fileread>
801065a9:	83 c4 10             	add    $0x10,%esp
}
801065ac:	c9                   	leave  
801065ad:	c3                   	ret    

801065ae <sys_write>:

int
sys_write(void)
{
801065ae:	55                   	push   %ebp
801065af:	89 e5                	mov    %esp,%ebp
801065b1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801065b4:	83 ec 04             	sub    $0x4,%esp
801065b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065ba:	50                   	push   %eax
801065bb:	6a 00                	push   $0x0
801065bd:	6a 00                	push   $0x0
801065bf:	e8 67 fe ff ff       	call   8010642b <argfd>
801065c4:	83 c4 10             	add    $0x10,%esp
801065c7:	85 c0                	test   %eax,%eax
801065c9:	78 2e                	js     801065f9 <sys_write+0x4b>
801065cb:	83 ec 08             	sub    $0x8,%esp
801065ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065d1:	50                   	push   %eax
801065d2:	6a 02                	push   $0x2
801065d4:	e8 16 fd ff ff       	call   801062ef <argint>
801065d9:	83 c4 10             	add    $0x10,%esp
801065dc:	85 c0                	test   %eax,%eax
801065de:	78 19                	js     801065f9 <sys_write+0x4b>
801065e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e3:	83 ec 04             	sub    $0x4,%esp
801065e6:	50                   	push   %eax
801065e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065ea:	50                   	push   %eax
801065eb:	6a 01                	push   $0x1
801065ed:	e8 25 fd ff ff       	call   80106317 <argptr>
801065f2:	83 c4 10             	add    $0x10,%esp
801065f5:	85 c0                	test   %eax,%eax
801065f7:	79 07                	jns    80106600 <sys_write+0x52>
    return -1;
801065f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065fe:	eb 17                	jmp    80106617 <sys_write+0x69>
  return filewrite(f, p, n);
80106600:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106603:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106609:	83 ec 04             	sub    $0x4,%esp
8010660c:	51                   	push   %ecx
8010660d:	52                   	push   %edx
8010660e:	50                   	push   %eax
8010660f:	e8 c6 af ff ff       	call   801015da <filewrite>
80106614:	83 c4 10             	add    $0x10,%esp
}
80106617:	c9                   	leave  
80106618:	c3                   	ret    

80106619 <sys_close>:

int
sys_close(void)
{
80106619:	55                   	push   %ebp
8010661a:	89 e5                	mov    %esp,%ebp
8010661c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010661f:	83 ec 04             	sub    $0x4,%esp
80106622:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106625:	50                   	push   %eax
80106626:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106629:	50                   	push   %eax
8010662a:	6a 00                	push   $0x0
8010662c:	e8 fa fd ff ff       	call   8010642b <argfd>
80106631:	83 c4 10             	add    $0x10,%esp
80106634:	85 c0                	test   %eax,%eax
80106636:	79 07                	jns    8010663f <sys_close+0x26>
    return -1;
80106638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663d:	eb 28                	jmp    80106667 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010663f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106645:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106648:	83 c2 08             	add    $0x8,%edx
8010664b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106652:	00 
  fileclose(f);
80106653:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106656:	83 ec 0c             	sub    $0xc,%esp
80106659:	50                   	push   %eax
8010665a:	e8 84 ad ff ff       	call   801013e3 <fileclose>
8010665f:	83 c4 10             	add    $0x10,%esp
  return 0;
80106662:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106667:	c9                   	leave  
80106668:	c3                   	ret    

80106669 <sys_fstat>:

int
sys_fstat(void)
{
80106669:	55                   	push   %ebp
8010666a:	89 e5                	mov    %esp,%ebp
8010666c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010666f:	83 ec 04             	sub    $0x4,%esp
80106672:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106675:	50                   	push   %eax
80106676:	6a 00                	push   $0x0
80106678:	6a 00                	push   $0x0
8010667a:	e8 ac fd ff ff       	call   8010642b <argfd>
8010667f:	83 c4 10             	add    $0x10,%esp
80106682:	85 c0                	test   %eax,%eax
80106684:	78 17                	js     8010669d <sys_fstat+0x34>
80106686:	83 ec 04             	sub    $0x4,%esp
80106689:	6a 14                	push   $0x14
8010668b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010668e:	50                   	push   %eax
8010668f:	6a 01                	push   $0x1
80106691:	e8 81 fc ff ff       	call   80106317 <argptr>
80106696:	83 c4 10             	add    $0x10,%esp
80106699:	85 c0                	test   %eax,%eax
8010669b:	79 07                	jns    801066a4 <sys_fstat+0x3b>
    return -1;
8010669d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a2:	eb 13                	jmp    801066b7 <sys_fstat+0x4e>
  return filestat(f, st);
801066a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801066a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066aa:	83 ec 08             	sub    $0x8,%esp
801066ad:	52                   	push   %edx
801066ae:	50                   	push   %eax
801066af:	e8 17 ae ff ff       	call   801014cb <filestat>
801066b4:	83 c4 10             	add    $0x10,%esp
}
801066b7:	c9                   	leave  
801066b8:	c3                   	ret    

801066b9 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801066b9:	55                   	push   %ebp
801066ba:	89 e5                	mov    %esp,%ebp
801066bc:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801066bf:	83 ec 08             	sub    $0x8,%esp
801066c2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801066c5:	50                   	push   %eax
801066c6:	6a 00                	push   $0x0
801066c8:	e8 a7 fc ff ff       	call   80106374 <argstr>
801066cd:	83 c4 10             	add    $0x10,%esp
801066d0:	85 c0                	test   %eax,%eax
801066d2:	78 15                	js     801066e9 <sys_link+0x30>
801066d4:	83 ec 08             	sub    $0x8,%esp
801066d7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801066da:	50                   	push   %eax
801066db:	6a 01                	push   $0x1
801066dd:	e8 92 fc ff ff       	call   80106374 <argstr>
801066e2:	83 c4 10             	add    $0x10,%esp
801066e5:	85 c0                	test   %eax,%eax
801066e7:	79 0a                	jns    801066f3 <sys_link+0x3a>
    return -1;
801066e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ee:	e9 68 01 00 00       	jmp    8010685b <sys_link+0x1a2>

  begin_op();
801066f3:	e8 4b d6 ff ff       	call   80103d43 <begin_op>
  if((ip = namei(old)) == 0){
801066f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801066fb:	83 ec 0c             	sub    $0xc,%esp
801066fe:	50                   	push   %eax
801066ff:	e8 b6 c1 ff ff       	call   801028ba <namei>
80106704:	83 c4 10             	add    $0x10,%esp
80106707:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010670a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010670e:	75 0f                	jne    8010671f <sys_link+0x66>
    end_op();
80106710:	e8 ba d6 ff ff       	call   80103dcf <end_op>
    return -1;
80106715:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671a:	e9 3c 01 00 00       	jmp    8010685b <sys_link+0x1a2>
  }

  ilock(ip);
8010671f:	83 ec 0c             	sub    $0xc,%esp
80106722:	ff 75 f4             	pushl  -0xc(%ebp)
80106725:	e8 d2 b5 ff ff       	call   80101cfc <ilock>
8010672a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010672d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106730:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106734:	66 83 f8 01          	cmp    $0x1,%ax
80106738:	75 1d                	jne    80106757 <sys_link+0x9e>
    iunlockput(ip);
8010673a:	83 ec 0c             	sub    $0xc,%esp
8010673d:	ff 75 f4             	pushl  -0xc(%ebp)
80106740:	e8 77 b8 ff ff       	call   80101fbc <iunlockput>
80106745:	83 c4 10             	add    $0x10,%esp
    end_op();
80106748:	e8 82 d6 ff ff       	call   80103dcf <end_op>
    return -1;
8010674d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106752:	e9 04 01 00 00       	jmp    8010685b <sys_link+0x1a2>
  }

  ip->nlink++;
80106757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010675e:	83 c0 01             	add    $0x1,%eax
80106761:	89 c2                	mov    %eax,%edx
80106763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106766:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010676a:	83 ec 0c             	sub    $0xc,%esp
8010676d:	ff 75 f4             	pushl  -0xc(%ebp)
80106770:	e8 ad b3 ff ff       	call   80101b22 <iupdate>
80106775:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106778:	83 ec 0c             	sub    $0xc,%esp
8010677b:	ff 75 f4             	pushl  -0xc(%ebp)
8010677e:	e8 d7 b6 ff ff       	call   80101e5a <iunlock>
80106783:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80106786:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106789:	83 ec 08             	sub    $0x8,%esp
8010678c:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010678f:	52                   	push   %edx
80106790:	50                   	push   %eax
80106791:	e8 40 c1 ff ff       	call   801028d6 <nameiparent>
80106796:	83 c4 10             	add    $0x10,%esp
80106799:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010679c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067a0:	74 71                	je     80106813 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801067a2:	83 ec 0c             	sub    $0xc,%esp
801067a5:	ff 75 f0             	pushl  -0x10(%ebp)
801067a8:	e8 4f b5 ff ff       	call   80101cfc <ilock>
801067ad:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801067b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067b3:	8b 10                	mov    (%eax),%edx
801067b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b8:	8b 00                	mov    (%eax),%eax
801067ba:	39 c2                	cmp    %eax,%edx
801067bc:	75 1d                	jne    801067db <sys_link+0x122>
801067be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c1:	8b 40 04             	mov    0x4(%eax),%eax
801067c4:	83 ec 04             	sub    $0x4,%esp
801067c7:	50                   	push   %eax
801067c8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801067cb:	50                   	push   %eax
801067cc:	ff 75 f0             	pushl  -0x10(%ebp)
801067cf:	e8 4a be ff ff       	call   8010261e <dirlink>
801067d4:	83 c4 10             	add    $0x10,%esp
801067d7:	85 c0                	test   %eax,%eax
801067d9:	79 10                	jns    801067eb <sys_link+0x132>
    iunlockput(dp);
801067db:	83 ec 0c             	sub    $0xc,%esp
801067de:	ff 75 f0             	pushl  -0x10(%ebp)
801067e1:	e8 d6 b7 ff ff       	call   80101fbc <iunlockput>
801067e6:	83 c4 10             	add    $0x10,%esp
    goto bad;
801067e9:	eb 29                	jmp    80106814 <sys_link+0x15b>
  }
  iunlockput(dp);
801067eb:	83 ec 0c             	sub    $0xc,%esp
801067ee:	ff 75 f0             	pushl  -0x10(%ebp)
801067f1:	e8 c6 b7 ff ff       	call   80101fbc <iunlockput>
801067f6:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801067f9:	83 ec 0c             	sub    $0xc,%esp
801067fc:	ff 75 f4             	pushl  -0xc(%ebp)
801067ff:	e8 c8 b6 ff ff       	call   80101ecc <iput>
80106804:	83 c4 10             	add    $0x10,%esp

  end_op();
80106807:	e8 c3 d5 ff ff       	call   80103dcf <end_op>

  return 0;
8010680c:	b8 00 00 00 00       	mov    $0x0,%eax
80106811:	eb 48                	jmp    8010685b <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106813:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80106814:	83 ec 0c             	sub    $0xc,%esp
80106817:	ff 75 f4             	pushl  -0xc(%ebp)
8010681a:	e8 dd b4 ff ff       	call   80101cfc <ilock>
8010681f:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106825:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106829:	83 e8 01             	sub    $0x1,%eax
8010682c:	89 c2                	mov    %eax,%edx
8010682e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106831:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106835:	83 ec 0c             	sub    $0xc,%esp
80106838:	ff 75 f4             	pushl  -0xc(%ebp)
8010683b:	e8 e2 b2 ff ff       	call   80101b22 <iupdate>
80106840:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106843:	83 ec 0c             	sub    $0xc,%esp
80106846:	ff 75 f4             	pushl  -0xc(%ebp)
80106849:	e8 6e b7 ff ff       	call   80101fbc <iunlockput>
8010684e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106851:	e8 79 d5 ff ff       	call   80103dcf <end_op>
  return -1;
80106856:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010685b:	c9                   	leave  
8010685c:	c3                   	ret    

8010685d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
int
isdirempty(struct inode *dp)
{
8010685d:	55                   	push   %ebp
8010685e:	89 e5                	mov    %esp,%ebp
80106860:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106863:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010686a:	eb 40                	jmp    801068ac <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010686c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010686f:	6a 10                	push   $0x10
80106871:	50                   	push   %eax
80106872:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106875:	50                   	push   %eax
80106876:	ff 75 08             	pushl  0x8(%ebp)
80106879:	e8 ec b9 ff ff       	call   8010226a <readi>
8010687e:	83 c4 10             	add    $0x10,%esp
80106881:	83 f8 10             	cmp    $0x10,%eax
80106884:	74 0d                	je     80106893 <isdirempty+0x36>
      panic("isdirempty: readi");
80106886:	83 ec 0c             	sub    $0xc,%esp
80106889:	68 e7 a2 10 80       	push   $0x8010a2e7
8010688e:	e8 d3 9c ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80106893:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106897:	66 85 c0             	test   %ax,%ax
8010689a:	74 07                	je     801068a3 <isdirempty+0x46>
      return 0;
8010689c:	b8 00 00 00 00       	mov    $0x0,%eax
801068a1:	eb 1b                	jmp    801068be <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801068a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a6:	83 c0 10             	add    $0x10,%eax
801068a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068ac:	8b 45 08             	mov    0x8(%ebp),%eax
801068af:	8b 50 18             	mov    0x18(%eax),%edx
801068b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b5:	39 c2                	cmp    %eax,%edx
801068b7:	77 b3                	ja     8010686c <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801068b9:	b8 01 00 00 00       	mov    $0x1,%eax
}
801068be:	c9                   	leave  
801068bf:	c3                   	ret    

801068c0 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801068c0:	55                   	push   %ebp
801068c1:	89 e5                	mov    %esp,%ebp
801068c3:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801068c6:	83 ec 08             	sub    $0x8,%esp
801068c9:	8d 45 cc             	lea    -0x34(%ebp),%eax
801068cc:	50                   	push   %eax
801068cd:	6a 00                	push   $0x0
801068cf:	e8 a0 fa ff ff       	call   80106374 <argstr>
801068d4:	83 c4 10             	add    $0x10,%esp
801068d7:	85 c0                	test   %eax,%eax
801068d9:	79 0a                	jns    801068e5 <sys_unlink+0x25>
    return -1;
801068db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068e0:	e9 bc 01 00 00       	jmp    80106aa1 <sys_unlink+0x1e1>

  begin_op();
801068e5:	e8 59 d4 ff ff       	call   80103d43 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801068ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
801068ed:	83 ec 08             	sub    $0x8,%esp
801068f0:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801068f3:	52                   	push   %edx
801068f4:	50                   	push   %eax
801068f5:	e8 dc bf ff ff       	call   801028d6 <nameiparent>
801068fa:	83 c4 10             	add    $0x10,%esp
801068fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106900:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106904:	75 0f                	jne    80106915 <sys_unlink+0x55>
    end_op();
80106906:	e8 c4 d4 ff ff       	call   80103dcf <end_op>
    return -1;
8010690b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106910:	e9 8c 01 00 00       	jmp    80106aa1 <sys_unlink+0x1e1>
  }

  ilock(dp);
80106915:	83 ec 0c             	sub    $0xc,%esp
80106918:	ff 75 f4             	pushl  -0xc(%ebp)
8010691b:	e8 dc b3 ff ff       	call   80101cfc <ilock>
80106920:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106923:	83 ec 08             	sub    $0x8,%esp
80106926:	68 f9 a2 10 80       	push   $0x8010a2f9
8010692b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010692e:	50                   	push   %eax
8010692f:	e8 15 bc ff ff       	call   80102549 <namecmp>
80106934:	83 c4 10             	add    $0x10,%esp
80106937:	85 c0                	test   %eax,%eax
80106939:	0f 84 4a 01 00 00    	je     80106a89 <sys_unlink+0x1c9>
8010693f:	83 ec 08             	sub    $0x8,%esp
80106942:	68 fb a2 10 80       	push   $0x8010a2fb
80106947:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010694a:	50                   	push   %eax
8010694b:	e8 f9 bb ff ff       	call   80102549 <namecmp>
80106950:	83 c4 10             	add    $0x10,%esp
80106953:	85 c0                	test   %eax,%eax
80106955:	0f 84 2e 01 00 00    	je     80106a89 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010695b:	83 ec 04             	sub    $0x4,%esp
8010695e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106961:	50                   	push   %eax
80106962:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106965:	50                   	push   %eax
80106966:	ff 75 f4             	pushl  -0xc(%ebp)
80106969:	e8 f6 bb ff ff       	call   80102564 <dirlookup>
8010696e:	83 c4 10             	add    $0x10,%esp
80106971:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106974:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106978:	0f 84 0a 01 00 00    	je     80106a88 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
8010697e:	83 ec 0c             	sub    $0xc,%esp
80106981:	ff 75 f0             	pushl  -0x10(%ebp)
80106984:	e8 73 b3 ff ff       	call   80101cfc <ilock>
80106989:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010698c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010698f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106993:	66 85 c0             	test   %ax,%ax
80106996:	7f 0d                	jg     801069a5 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106998:	83 ec 0c             	sub    $0xc,%esp
8010699b:	68 fe a2 10 80       	push   $0x8010a2fe
801069a0:	e8 c1 9b ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801069a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801069ac:	66 83 f8 01          	cmp    $0x1,%ax
801069b0:	75 25                	jne    801069d7 <sys_unlink+0x117>
801069b2:	83 ec 0c             	sub    $0xc,%esp
801069b5:	ff 75 f0             	pushl  -0x10(%ebp)
801069b8:	e8 a0 fe ff ff       	call   8010685d <isdirempty>
801069bd:	83 c4 10             	add    $0x10,%esp
801069c0:	85 c0                	test   %eax,%eax
801069c2:	75 13                	jne    801069d7 <sys_unlink+0x117>
    iunlockput(ip);
801069c4:	83 ec 0c             	sub    $0xc,%esp
801069c7:	ff 75 f0             	pushl  -0x10(%ebp)
801069ca:	e8 ed b5 ff ff       	call   80101fbc <iunlockput>
801069cf:	83 c4 10             	add    $0x10,%esp
    goto bad;
801069d2:	e9 b2 00 00 00       	jmp    80106a89 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801069d7:	83 ec 04             	sub    $0x4,%esp
801069da:	6a 10                	push   $0x10
801069dc:	6a 00                	push   $0x0
801069de:	8d 45 e0             	lea    -0x20(%ebp),%eax
801069e1:	50                   	push   %eax
801069e2:	e8 e3 f5 ff ff       	call   80105fca <memset>
801069e7:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801069ea:	8b 45 c8             	mov    -0x38(%ebp),%eax
801069ed:	6a 10                	push   $0x10
801069ef:	50                   	push   %eax
801069f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801069f3:	50                   	push   %eax
801069f4:	ff 75 f4             	pushl  -0xc(%ebp)
801069f7:	e8 c5 b9 ff ff       	call   801023c1 <writei>
801069fc:	83 c4 10             	add    $0x10,%esp
801069ff:	83 f8 10             	cmp    $0x10,%eax
80106a02:	74 0d                	je     80106a11 <sys_unlink+0x151>
    panic("unlink: writei");
80106a04:	83 ec 0c             	sub    $0xc,%esp
80106a07:	68 10 a3 10 80       	push   $0x8010a310
80106a0c:	e8 55 9b ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a14:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a18:	66 83 f8 01          	cmp    $0x1,%ax
80106a1c:	75 21                	jne    80106a3f <sys_unlink+0x17f>
    dp->nlink--;
80106a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a21:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a25:	83 e8 01             	sub    $0x1,%eax
80106a28:	89 c2                	mov    %eax,%edx
80106a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106a31:	83 ec 0c             	sub    $0xc,%esp
80106a34:	ff 75 f4             	pushl  -0xc(%ebp)
80106a37:	e8 e6 b0 ff ff       	call   80101b22 <iupdate>
80106a3c:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106a3f:	83 ec 0c             	sub    $0xc,%esp
80106a42:	ff 75 f4             	pushl  -0xc(%ebp)
80106a45:	e8 72 b5 ff ff       	call   80101fbc <iunlockput>
80106a4a:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a50:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a54:	83 e8 01             	sub    $0x1,%eax
80106a57:	89 c2                	mov    %eax,%edx
80106a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a5c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106a60:	83 ec 0c             	sub    $0xc,%esp
80106a63:	ff 75 f0             	pushl  -0x10(%ebp)
80106a66:	e8 b7 b0 ff ff       	call   80101b22 <iupdate>
80106a6b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106a6e:	83 ec 0c             	sub    $0xc,%esp
80106a71:	ff 75 f0             	pushl  -0x10(%ebp)
80106a74:	e8 43 b5 ff ff       	call   80101fbc <iunlockput>
80106a79:	83 c4 10             	add    $0x10,%esp

  end_op();
80106a7c:	e8 4e d3 ff ff       	call   80103dcf <end_op>

  return 0;
80106a81:	b8 00 00 00 00       	mov    $0x0,%eax
80106a86:	eb 19                	jmp    80106aa1 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106a88:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106a89:	83 ec 0c             	sub    $0xc,%esp
80106a8c:	ff 75 f4             	pushl  -0xc(%ebp)
80106a8f:	e8 28 b5 ff ff       	call   80101fbc <iunlockput>
80106a94:	83 c4 10             	add    $0x10,%esp
  end_op();
80106a97:	e8 33 d3 ff ff       	call   80103dcf <end_op>
  return -1;
80106a9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106aa1:	c9                   	leave  
80106aa2:	c3                   	ret    

80106aa3 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
80106aa3:	55                   	push   %ebp
80106aa4:	89 e5                	mov    %esp,%ebp
80106aa6:	83 ec 38             	sub    $0x38,%esp
80106aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106aac:	8b 55 10             	mov    0x10(%ebp),%edx
80106aaf:	8b 45 14             	mov    0x14(%ebp),%eax
80106ab2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106ab6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106aba:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106abe:	83 ec 08             	sub    $0x8,%esp
80106ac1:	8d 45 de             	lea    -0x22(%ebp),%eax
80106ac4:	50                   	push   %eax
80106ac5:	ff 75 08             	pushl  0x8(%ebp)
80106ac8:	e8 09 be ff ff       	call   801028d6 <nameiparent>
80106acd:	83 c4 10             	add    $0x10,%esp
80106ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ad3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ad7:	75 0a                	jne    80106ae3 <create+0x40>
    return 0;
80106ad9:	b8 00 00 00 00       	mov    $0x0,%eax
80106ade:	e9 90 01 00 00       	jmp    80106c73 <create+0x1d0>
  ilock(dp);
80106ae3:	83 ec 0c             	sub    $0xc,%esp
80106ae6:	ff 75 f4             	pushl  -0xc(%ebp)
80106ae9:	e8 0e b2 ff ff       	call   80101cfc <ilock>
80106aee:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106af1:	83 ec 04             	sub    $0x4,%esp
80106af4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106af7:	50                   	push   %eax
80106af8:	8d 45 de             	lea    -0x22(%ebp),%eax
80106afb:	50                   	push   %eax
80106afc:	ff 75 f4             	pushl  -0xc(%ebp)
80106aff:	e8 60 ba ff ff       	call   80102564 <dirlookup>
80106b04:	83 c4 10             	add    $0x10,%esp
80106b07:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b0e:	74 50                	je     80106b60 <create+0xbd>
    iunlockput(dp);
80106b10:	83 ec 0c             	sub    $0xc,%esp
80106b13:	ff 75 f4             	pushl  -0xc(%ebp)
80106b16:	e8 a1 b4 ff ff       	call   80101fbc <iunlockput>
80106b1b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106b1e:	83 ec 0c             	sub    $0xc,%esp
80106b21:	ff 75 f0             	pushl  -0x10(%ebp)
80106b24:	e8 d3 b1 ff ff       	call   80101cfc <ilock>
80106b29:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106b2c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106b31:	75 15                	jne    80106b48 <create+0xa5>
80106b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b36:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106b3a:	66 83 f8 02          	cmp    $0x2,%ax
80106b3e:	75 08                	jne    80106b48 <create+0xa5>
      return ip;
80106b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b43:	e9 2b 01 00 00       	jmp    80106c73 <create+0x1d0>
    iunlockput(ip);
80106b48:	83 ec 0c             	sub    $0xc,%esp
80106b4b:	ff 75 f0             	pushl  -0x10(%ebp)
80106b4e:	e8 69 b4 ff ff       	call   80101fbc <iunlockput>
80106b53:	83 c4 10             	add    $0x10,%esp
    return 0;
80106b56:	b8 00 00 00 00       	mov    $0x0,%eax
80106b5b:	e9 13 01 00 00       	jmp    80106c73 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106b60:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b67:	8b 00                	mov    (%eax),%eax
80106b69:	83 ec 08             	sub    $0x8,%esp
80106b6c:	52                   	push   %edx
80106b6d:	50                   	push   %eax
80106b6e:	e8 d8 ae ff ff       	call   80101a4b <ialloc>
80106b73:	83 c4 10             	add    $0x10,%esp
80106b76:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b7d:	75 0d                	jne    80106b8c <create+0xe9>
    panic("create: ialloc");
80106b7f:	83 ec 0c             	sub    $0xc,%esp
80106b82:	68 1f a3 10 80       	push   $0x8010a31f
80106b87:	e8 da 99 ff ff       	call   80100566 <panic>

  ilock(ip);
80106b8c:	83 ec 0c             	sub    $0xc,%esp
80106b8f:	ff 75 f0             	pushl  -0x10(%ebp)
80106b92:	e8 65 b1 ff ff       	call   80101cfc <ilock>
80106b97:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b9d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106ba1:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ba8:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106bac:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bb3:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106bb9:	83 ec 0c             	sub    $0xc,%esp
80106bbc:	ff 75 f0             	pushl  -0x10(%ebp)
80106bbf:	e8 5e af ff ff       	call   80101b22 <iupdate>
80106bc4:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106bc7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106bcc:	75 6a                	jne    80106c38 <create+0x195>
    dp->nlink++;  // for ".."
80106bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106bd5:	83 c0 01             	add    $0x1,%eax
80106bd8:	89 c2                	mov    %eax,%edx
80106bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bdd:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106be1:	83 ec 0c             	sub    $0xc,%esp
80106be4:	ff 75 f4             	pushl  -0xc(%ebp)
80106be7:	e8 36 af ff ff       	call   80101b22 <iupdate>
80106bec:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bf2:	8b 40 04             	mov    0x4(%eax),%eax
80106bf5:	83 ec 04             	sub    $0x4,%esp
80106bf8:	50                   	push   %eax
80106bf9:	68 f9 a2 10 80       	push   $0x8010a2f9
80106bfe:	ff 75 f0             	pushl  -0x10(%ebp)
80106c01:	e8 18 ba ff ff       	call   8010261e <dirlink>
80106c06:	83 c4 10             	add    $0x10,%esp
80106c09:	85 c0                	test   %eax,%eax
80106c0b:	78 1e                	js     80106c2b <create+0x188>
80106c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c10:	8b 40 04             	mov    0x4(%eax),%eax
80106c13:	83 ec 04             	sub    $0x4,%esp
80106c16:	50                   	push   %eax
80106c17:	68 fb a2 10 80       	push   $0x8010a2fb
80106c1c:	ff 75 f0             	pushl  -0x10(%ebp)
80106c1f:	e8 fa b9 ff ff       	call   8010261e <dirlink>
80106c24:	83 c4 10             	add    $0x10,%esp
80106c27:	85 c0                	test   %eax,%eax
80106c29:	79 0d                	jns    80106c38 <create+0x195>
      panic("create dots");
80106c2b:	83 ec 0c             	sub    $0xc,%esp
80106c2e:	68 2e a3 10 80       	push   $0x8010a32e
80106c33:	e8 2e 99 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c3b:	8b 40 04             	mov    0x4(%eax),%eax
80106c3e:	83 ec 04             	sub    $0x4,%esp
80106c41:	50                   	push   %eax
80106c42:	8d 45 de             	lea    -0x22(%ebp),%eax
80106c45:	50                   	push   %eax
80106c46:	ff 75 f4             	pushl  -0xc(%ebp)
80106c49:	e8 d0 b9 ff ff       	call   8010261e <dirlink>
80106c4e:	83 c4 10             	add    $0x10,%esp
80106c51:	85 c0                	test   %eax,%eax
80106c53:	79 0d                	jns    80106c62 <create+0x1bf>
    panic("create: dirlink");
80106c55:	83 ec 0c             	sub    $0xc,%esp
80106c58:	68 3a a3 10 80       	push   $0x8010a33a
80106c5d:	e8 04 99 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106c62:	83 ec 0c             	sub    $0xc,%esp
80106c65:	ff 75 f4             	pushl  -0xc(%ebp)
80106c68:	e8 4f b3 ff ff       	call   80101fbc <iunlockput>
80106c6d:	83 c4 10             	add    $0x10,%esp

  return ip;
80106c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106c73:	c9                   	leave  
80106c74:	c3                   	ret    

80106c75 <sys_open>:

int
sys_open(void)
{
80106c75:	55                   	push   %ebp
80106c76:	89 e5                	mov    %esp,%ebp
80106c78:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106c7b:	83 ec 08             	sub    $0x8,%esp
80106c7e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106c81:	50                   	push   %eax
80106c82:	6a 00                	push   $0x0
80106c84:	e8 eb f6 ff ff       	call   80106374 <argstr>
80106c89:	83 c4 10             	add    $0x10,%esp
80106c8c:	85 c0                	test   %eax,%eax
80106c8e:	78 15                	js     80106ca5 <sys_open+0x30>
80106c90:	83 ec 08             	sub    $0x8,%esp
80106c93:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106c96:	50                   	push   %eax
80106c97:	6a 01                	push   $0x1
80106c99:	e8 51 f6 ff ff       	call   801062ef <argint>
80106c9e:	83 c4 10             	add    $0x10,%esp
80106ca1:	85 c0                	test   %eax,%eax
80106ca3:	79 0a                	jns    80106caf <sys_open+0x3a>
    return -1;
80106ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106caa:	e9 61 01 00 00       	jmp    80106e10 <sys_open+0x19b>

  begin_op();
80106caf:	e8 8f d0 ff ff       	call   80103d43 <begin_op>

  if(omode & O_CREATE){
80106cb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106cb7:	25 00 02 00 00       	and    $0x200,%eax
80106cbc:	85 c0                	test   %eax,%eax
80106cbe:	74 2a                	je     80106cea <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106cc0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106cc3:	6a 00                	push   $0x0
80106cc5:	6a 00                	push   $0x0
80106cc7:	6a 02                	push   $0x2
80106cc9:	50                   	push   %eax
80106cca:	e8 d4 fd ff ff       	call   80106aa3 <create>
80106ccf:	83 c4 10             	add    $0x10,%esp
80106cd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106cd5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cd9:	75 75                	jne    80106d50 <sys_open+0xdb>
      end_op();
80106cdb:	e8 ef d0 ff ff       	call   80103dcf <end_op>
      return -1;
80106ce0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ce5:	e9 26 01 00 00       	jmp    80106e10 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ced:	83 ec 0c             	sub    $0xc,%esp
80106cf0:	50                   	push   %eax
80106cf1:	e8 c4 bb ff ff       	call   801028ba <namei>
80106cf6:	83 c4 10             	add    $0x10,%esp
80106cf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d00:	75 0f                	jne    80106d11 <sys_open+0x9c>
      end_op();
80106d02:	e8 c8 d0 ff ff       	call   80103dcf <end_op>
      return -1;
80106d07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d0c:	e9 ff 00 00 00       	jmp    80106e10 <sys_open+0x19b>
    }
    ilock(ip);
80106d11:	83 ec 0c             	sub    $0xc,%esp
80106d14:	ff 75 f4             	pushl  -0xc(%ebp)
80106d17:	e8 e0 af ff ff       	call   80101cfc <ilock>
80106d1c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d22:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106d26:	66 83 f8 01          	cmp    $0x1,%ax
80106d2a:	75 24                	jne    80106d50 <sys_open+0xdb>
80106d2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d2f:	85 c0                	test   %eax,%eax
80106d31:	74 1d                	je     80106d50 <sys_open+0xdb>
      iunlockput(ip);
80106d33:	83 ec 0c             	sub    $0xc,%esp
80106d36:	ff 75 f4             	pushl  -0xc(%ebp)
80106d39:	e8 7e b2 ff ff       	call   80101fbc <iunlockput>
80106d3e:	83 c4 10             	add    $0x10,%esp
      end_op();
80106d41:	e8 89 d0 ff ff       	call   80103dcf <end_op>
      return -1;
80106d46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d4b:	e9 c0 00 00 00       	jmp    80106e10 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106d50:	e8 d0 a5 ff ff       	call   80101325 <filealloc>
80106d55:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d5c:	74 17                	je     80106d75 <sys_open+0x100>
80106d5e:	83 ec 0c             	sub    $0xc,%esp
80106d61:	ff 75 f0             	pushl  -0x10(%ebp)
80106d64:	e8 37 f7 ff ff       	call   801064a0 <fdalloc>
80106d69:	83 c4 10             	add    $0x10,%esp
80106d6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106d6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106d73:	79 2e                	jns    80106da3 <sys_open+0x12e>
    if(f)
80106d75:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d79:	74 0e                	je     80106d89 <sys_open+0x114>
      fileclose(f);
80106d7b:	83 ec 0c             	sub    $0xc,%esp
80106d7e:	ff 75 f0             	pushl  -0x10(%ebp)
80106d81:	e8 5d a6 ff ff       	call   801013e3 <fileclose>
80106d86:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106d89:	83 ec 0c             	sub    $0xc,%esp
80106d8c:	ff 75 f4             	pushl  -0xc(%ebp)
80106d8f:	e8 28 b2 ff ff       	call   80101fbc <iunlockput>
80106d94:	83 c4 10             	add    $0x10,%esp
    end_op();
80106d97:	e8 33 d0 ff ff       	call   80103dcf <end_op>
    return -1;
80106d9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106da1:	eb 6d                	jmp    80106e10 <sys_open+0x19b>
  }
  iunlock(ip);
80106da3:	83 ec 0c             	sub    $0xc,%esp
80106da6:	ff 75 f4             	pushl  -0xc(%ebp)
80106da9:	e8 ac b0 ff ff       	call   80101e5a <iunlock>
80106dae:	83 c4 10             	add    $0x10,%esp
  end_op();
80106db1:	e8 19 d0 ff ff       	call   80103dcf <end_op>

  f->type = FD_INODE;
80106db6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106db9:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106dc5:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dcb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106dd5:	83 e0 01             	and    $0x1,%eax
80106dd8:	85 c0                	test   %eax,%eax
80106dda:	0f 94 c0             	sete   %al
80106ddd:	89 c2                	mov    %eax,%edx
80106ddf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106de2:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106de8:	83 e0 01             	and    $0x1,%eax
80106deb:	85 c0                	test   %eax,%eax
80106ded:	75 0a                	jne    80106df9 <sys_open+0x184>
80106def:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106df2:	83 e0 02             	and    $0x2,%eax
80106df5:	85 c0                	test   %eax,%eax
80106df7:	74 07                	je     80106e00 <sys_open+0x18b>
80106df9:	b8 01 00 00 00       	mov    $0x1,%eax
80106dfe:	eb 05                	jmp    80106e05 <sys_open+0x190>
80106e00:	b8 00 00 00 00       	mov    $0x0,%eax
80106e05:	89 c2                	mov    %eax,%edx
80106e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e0a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106e0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106e10:	c9                   	leave  
80106e11:	c3                   	ret    

80106e12 <sys_mkdir>:

int
sys_mkdir(void)
{
80106e12:	55                   	push   %ebp
80106e13:	89 e5                	mov    %esp,%ebp
80106e15:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106e18:	e8 26 cf ff ff       	call   80103d43 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106e1d:	83 ec 08             	sub    $0x8,%esp
80106e20:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e23:	50                   	push   %eax
80106e24:	6a 00                	push   $0x0
80106e26:	e8 49 f5 ff ff       	call   80106374 <argstr>
80106e2b:	83 c4 10             	add    $0x10,%esp
80106e2e:	85 c0                	test   %eax,%eax
80106e30:	78 1b                	js     80106e4d <sys_mkdir+0x3b>
80106e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e35:	6a 00                	push   $0x0
80106e37:	6a 00                	push   $0x0
80106e39:	6a 01                	push   $0x1
80106e3b:	50                   	push   %eax
80106e3c:	e8 62 fc ff ff       	call   80106aa3 <create>
80106e41:	83 c4 10             	add    $0x10,%esp
80106e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e4b:	75 0c                	jne    80106e59 <sys_mkdir+0x47>
    end_op();
80106e4d:	e8 7d cf ff ff       	call   80103dcf <end_op>
    return -1;
80106e52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e57:	eb 18                	jmp    80106e71 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106e59:	83 ec 0c             	sub    $0xc,%esp
80106e5c:	ff 75 f4             	pushl  -0xc(%ebp)
80106e5f:	e8 58 b1 ff ff       	call   80101fbc <iunlockput>
80106e64:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e67:	e8 63 cf ff ff       	call   80103dcf <end_op>
  return 0;
80106e6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e71:	c9                   	leave  
80106e72:	c3                   	ret    

80106e73 <sys_mknod>:

int
sys_mknod(void)
{
80106e73:	55                   	push   %ebp
80106e74:	89 e5                	mov    %esp,%ebp
80106e76:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106e79:	e8 c5 ce ff ff       	call   80103d43 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106e7e:	83 ec 08             	sub    $0x8,%esp
80106e81:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e84:	50                   	push   %eax
80106e85:	6a 00                	push   $0x0
80106e87:	e8 e8 f4 ff ff       	call   80106374 <argstr>
80106e8c:	83 c4 10             	add    $0x10,%esp
80106e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e96:	78 4f                	js     80106ee7 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106e98:	83 ec 08             	sub    $0x8,%esp
80106e9b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e9e:	50                   	push   %eax
80106e9f:	6a 01                	push   $0x1
80106ea1:	e8 49 f4 ff ff       	call   801062ef <argint>
80106ea6:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106ea9:	85 c0                	test   %eax,%eax
80106eab:	78 3a                	js     80106ee7 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106ead:	83 ec 08             	sub    $0x8,%esp
80106eb0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106eb3:	50                   	push   %eax
80106eb4:	6a 02                	push   $0x2
80106eb6:	e8 34 f4 ff ff       	call   801062ef <argint>
80106ebb:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106ebe:	85 c0                	test   %eax,%eax
80106ec0:	78 25                	js     80106ee7 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ec5:	0f bf c8             	movswl %ax,%ecx
80106ec8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ecb:	0f bf d0             	movswl %ax,%edx
80106ece:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106ed1:	51                   	push   %ecx
80106ed2:	52                   	push   %edx
80106ed3:	6a 03                	push   $0x3
80106ed5:	50                   	push   %eax
80106ed6:	e8 c8 fb ff ff       	call   80106aa3 <create>
80106edb:	83 c4 10             	add    $0x10,%esp
80106ede:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ee1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ee5:	75 0c                	jne    80106ef3 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106ee7:	e8 e3 ce ff ff       	call   80103dcf <end_op>
    return -1;
80106eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ef1:	eb 18                	jmp    80106f0b <sys_mknod+0x98>
  }
  iunlockput(ip);
80106ef3:	83 ec 0c             	sub    $0xc,%esp
80106ef6:	ff 75 f0             	pushl  -0x10(%ebp)
80106ef9:	e8 be b0 ff ff       	call   80101fbc <iunlockput>
80106efe:	83 c4 10             	add    $0x10,%esp
  end_op();
80106f01:	e8 c9 ce ff ff       	call   80103dcf <end_op>
  return 0;
80106f06:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f0b:	c9                   	leave  
80106f0c:	c3                   	ret    

80106f0d <sys_chdir>:

int
sys_chdir(void)
{
80106f0d:	55                   	push   %ebp
80106f0e:	89 e5                	mov    %esp,%ebp
80106f10:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106f13:	e8 2b ce ff ff       	call   80103d43 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106f18:	83 ec 08             	sub    $0x8,%esp
80106f1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f1e:	50                   	push   %eax
80106f1f:	6a 00                	push   $0x0
80106f21:	e8 4e f4 ff ff       	call   80106374 <argstr>
80106f26:	83 c4 10             	add    $0x10,%esp
80106f29:	85 c0                	test   %eax,%eax
80106f2b:	78 18                	js     80106f45 <sys_chdir+0x38>
80106f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f30:	83 ec 0c             	sub    $0xc,%esp
80106f33:	50                   	push   %eax
80106f34:	e8 81 b9 ff ff       	call   801028ba <namei>
80106f39:	83 c4 10             	add    $0x10,%esp
80106f3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f43:	75 0c                	jne    80106f51 <sys_chdir+0x44>
    end_op();
80106f45:	e8 85 ce ff ff       	call   80103dcf <end_op>
    return -1;
80106f4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f4f:	eb 6e                	jmp    80106fbf <sys_chdir+0xb2>
  }
  ilock(ip);
80106f51:	83 ec 0c             	sub    $0xc,%esp
80106f54:	ff 75 f4             	pushl  -0xc(%ebp)
80106f57:	e8 a0 ad ff ff       	call   80101cfc <ilock>
80106f5c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f62:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106f66:	66 83 f8 01          	cmp    $0x1,%ax
80106f6a:	74 1a                	je     80106f86 <sys_chdir+0x79>
    iunlockput(ip);
80106f6c:	83 ec 0c             	sub    $0xc,%esp
80106f6f:	ff 75 f4             	pushl  -0xc(%ebp)
80106f72:	e8 45 b0 ff ff       	call   80101fbc <iunlockput>
80106f77:	83 c4 10             	add    $0x10,%esp
    end_op();
80106f7a:	e8 50 ce ff ff       	call   80103dcf <end_op>
    return -1;
80106f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f84:	eb 39                	jmp    80106fbf <sys_chdir+0xb2>
  }
  iunlock(ip);
80106f86:	83 ec 0c             	sub    $0xc,%esp
80106f89:	ff 75 f4             	pushl  -0xc(%ebp)
80106f8c:	e8 c9 ae ff ff       	call   80101e5a <iunlock>
80106f91:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106f94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f9a:	8b 40 68             	mov    0x68(%eax),%eax
80106f9d:	83 ec 0c             	sub    $0xc,%esp
80106fa0:	50                   	push   %eax
80106fa1:	e8 26 af ff ff       	call   80101ecc <iput>
80106fa6:	83 c4 10             	add    $0x10,%esp
  end_op();
80106fa9:	e8 21 ce ff ff       	call   80103dcf <end_op>
  proc->cwd = ip;
80106fae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fb7:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106fba:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fbf:	c9                   	leave  
80106fc0:	c3                   	ret    

80106fc1 <sys_exec>:

int
sys_exec(void)
{
80106fc1:	55                   	push   %ebp
80106fc2:	89 e5                	mov    %esp,%ebp
80106fc4:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106fca:	83 ec 08             	sub    $0x8,%esp
80106fcd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fd0:	50                   	push   %eax
80106fd1:	6a 00                	push   $0x0
80106fd3:	e8 9c f3 ff ff       	call   80106374 <argstr>
80106fd8:	83 c4 10             	add    $0x10,%esp
80106fdb:	85 c0                	test   %eax,%eax
80106fdd:	78 18                	js     80106ff7 <sys_exec+0x36>
80106fdf:	83 ec 08             	sub    $0x8,%esp
80106fe2:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106fe8:	50                   	push   %eax
80106fe9:	6a 01                	push   $0x1
80106feb:	e8 ff f2 ff ff       	call   801062ef <argint>
80106ff0:	83 c4 10             	add    $0x10,%esp
80106ff3:	85 c0                	test   %eax,%eax
80106ff5:	79 0a                	jns    80107001 <sys_exec+0x40>
    return -1;
80106ff7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ffc:	e9 c6 00 00 00       	jmp    801070c7 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80107001:	83 ec 04             	sub    $0x4,%esp
80107004:	68 80 00 00 00       	push   $0x80
80107009:	6a 00                	push   $0x0
8010700b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107011:	50                   	push   %eax
80107012:	e8 b3 ef ff ff       	call   80105fca <memset>
80107017:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010701a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107024:	83 f8 1f             	cmp    $0x1f,%eax
80107027:	76 0a                	jbe    80107033 <sys_exec+0x72>
      return -1;
80107029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010702e:	e9 94 00 00 00       	jmp    801070c7 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107036:	c1 e0 02             	shl    $0x2,%eax
80107039:	89 c2                	mov    %eax,%edx
8010703b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107041:	01 c2                	add    %eax,%edx
80107043:	83 ec 08             	sub    $0x8,%esp
80107046:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010704c:	50                   	push   %eax
8010704d:	52                   	push   %edx
8010704e:	e8 00 f2 ff ff       	call   80106253 <fetchint>
80107053:	83 c4 10             	add    $0x10,%esp
80107056:	85 c0                	test   %eax,%eax
80107058:	79 07                	jns    80107061 <sys_exec+0xa0>
      return -1;
8010705a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010705f:	eb 66                	jmp    801070c7 <sys_exec+0x106>
    if(uarg == 0){
80107061:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107067:	85 c0                	test   %eax,%eax
80107069:	75 27                	jne    80107092 <sys_exec+0xd1>
      argv[i] = 0;
8010706b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010706e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107075:	00 00 00 00 
      break;
80107079:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010707a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010707d:	83 ec 08             	sub    $0x8,%esp
80107080:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107086:	52                   	push   %edx
80107087:	50                   	push   %eax
80107088:	e8 e4 9a ff ff       	call   80100b71 <exec>
8010708d:	83 c4 10             	add    $0x10,%esp
80107090:	eb 35                	jmp    801070c7 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80107092:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010709b:	c1 e2 02             	shl    $0x2,%edx
8010709e:	01 c2                	add    %eax,%edx
801070a0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801070a6:	83 ec 08             	sub    $0x8,%esp
801070a9:	52                   	push   %edx
801070aa:	50                   	push   %eax
801070ab:	e8 dd f1 ff ff       	call   8010628d <fetchstr>
801070b0:	83 c4 10             	add    $0x10,%esp
801070b3:	85 c0                	test   %eax,%eax
801070b5:	79 07                	jns    801070be <sys_exec+0xfd>
      return -1;
801070b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070bc:	eb 09                	jmp    801070c7 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801070be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801070c2:	e9 5a ff ff ff       	jmp    80107021 <sys_exec+0x60>
  return exec(path, argv);
}
801070c7:	c9                   	leave  
801070c8:	c3                   	ret    

801070c9 <sys_pipe>:

int
sys_pipe(void)
{
801070c9:	55                   	push   %ebp
801070ca:	89 e5                	mov    %esp,%ebp
801070cc:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801070cf:	83 ec 04             	sub    $0x4,%esp
801070d2:	6a 08                	push   $0x8
801070d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801070d7:	50                   	push   %eax
801070d8:	6a 00                	push   $0x0
801070da:	e8 38 f2 ff ff       	call   80106317 <argptr>
801070df:	83 c4 10             	add    $0x10,%esp
801070e2:	85 c0                	test   %eax,%eax
801070e4:	79 0a                	jns    801070f0 <sys_pipe+0x27>
    return -1;
801070e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070eb:	e9 af 00 00 00       	jmp    8010719f <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801070f0:	83 ec 08             	sub    $0x8,%esp
801070f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801070f6:	50                   	push   %eax
801070f7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801070fa:	50                   	push   %eax
801070fb:	e8 37 d7 ff ff       	call   80104837 <pipealloc>
80107100:	83 c4 10             	add    $0x10,%esp
80107103:	85 c0                	test   %eax,%eax
80107105:	79 0a                	jns    80107111 <sys_pipe+0x48>
    return -1;
80107107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010710c:	e9 8e 00 00 00       	jmp    8010719f <sys_pipe+0xd6>
  fd0 = -1;
80107111:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107118:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010711b:	83 ec 0c             	sub    $0xc,%esp
8010711e:	50                   	push   %eax
8010711f:	e8 7c f3 ff ff       	call   801064a0 <fdalloc>
80107124:	83 c4 10             	add    $0x10,%esp
80107127:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010712a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010712e:	78 18                	js     80107148 <sys_pipe+0x7f>
80107130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107133:	83 ec 0c             	sub    $0xc,%esp
80107136:	50                   	push   %eax
80107137:	e8 64 f3 ff ff       	call   801064a0 <fdalloc>
8010713c:	83 c4 10             	add    $0x10,%esp
8010713f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107142:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107146:	79 3f                	jns    80107187 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107148:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010714c:	78 14                	js     80107162 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
8010714e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107154:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107157:	83 c2 08             	add    $0x8,%edx
8010715a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107161:	00 
    fileclose(rf);
80107162:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107165:	83 ec 0c             	sub    $0xc,%esp
80107168:	50                   	push   %eax
80107169:	e8 75 a2 ff ff       	call   801013e3 <fileclose>
8010716e:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80107171:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107174:	83 ec 0c             	sub    $0xc,%esp
80107177:	50                   	push   %eax
80107178:	e8 66 a2 ff ff       	call   801013e3 <fileclose>
8010717d:	83 c4 10             	add    $0x10,%esp
    return -1;
80107180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107185:	eb 18                	jmp    8010719f <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107187:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010718a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010718d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010718f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107192:	8d 50 04             	lea    0x4(%eax),%edx
80107195:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107198:	89 02                	mov    %eax,(%edx)
  return 0;
8010719a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010719f:	c9                   	leave  
801071a0:	c3                   	ret    

801071a1 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801071a1:	55                   	push   %ebp
801071a2:	89 e5                	mov    %esp,%ebp
801071a4:	83 ec 08             	sub    $0x8,%esp
  return fork();
801071a7:	e8 3d de ff ff       	call   80104fe9 <fork>
}
801071ac:	c9                   	leave  
801071ad:	c3                   	ret    

801071ae <sys_exit>:

int
sys_exit(void)
{
801071ae:	55                   	push   %ebp
801071af:	89 e5                	mov    %esp,%ebp
801071b1:	83 ec 08             	sub    $0x8,%esp
  exit();
801071b4:	e8 90 e2 ff ff       	call   80105449 <exit>
  return 0;  // not reached
801071b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071be:	c9                   	leave  
801071bf:	c3                   	ret    

801071c0 <sys_wait>:

int
sys_wait(void)
{
801071c0:	55                   	push   %ebp
801071c1:	89 e5                	mov    %esp,%ebp
801071c3:	83 ec 08             	sub    $0x8,%esp
  return wait();
801071c6:	e8 cb e3 ff ff       	call   80105596 <wait>
}
801071cb:	c9                   	leave  
801071cc:	c3                   	ret    

801071cd <sys_kill>:

int
sys_kill(void)
{
801071cd:	55                   	push   %ebp
801071ce:	89 e5                	mov    %esp,%ebp
801071d0:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801071d3:	83 ec 08             	sub    $0x8,%esp
801071d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071d9:	50                   	push   %eax
801071da:	6a 00                	push   $0x0
801071dc:	e8 0e f1 ff ff       	call   801062ef <argint>
801071e1:	83 c4 10             	add    $0x10,%esp
801071e4:	85 c0                	test   %eax,%eax
801071e6:	79 07                	jns    801071ef <sys_kill+0x22>
    return -1;
801071e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ed:	eb 0f                	jmp    801071fe <sys_kill+0x31>
  return kill(pid);
801071ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f2:	83 ec 0c             	sub    $0xc,%esp
801071f5:	50                   	push   %eax
801071f6:	e8 cc e7 ff ff       	call   801059c7 <kill>
801071fb:	83 c4 10             	add    $0x10,%esp
}
801071fe:	c9                   	leave  
801071ff:	c3                   	ret    

80107200 <sys_getpid>:

int
sys_getpid(void)
{
80107200:	55                   	push   %ebp
80107201:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107203:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107209:	8b 40 10             	mov    0x10(%eax),%eax
}
8010720c:	5d                   	pop    %ebp
8010720d:	c3                   	ret    

8010720e <sys_sbrk>:

int
sys_sbrk(void)
{
8010720e:	55                   	push   %ebp
8010720f:	89 e5                	mov    %esp,%ebp
80107211:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107214:	83 ec 08             	sub    $0x8,%esp
80107217:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010721a:	50                   	push   %eax
8010721b:	6a 00                	push   $0x0
8010721d:	e8 cd f0 ff ff       	call   801062ef <argint>
80107222:	83 c4 10             	add    $0x10,%esp
80107225:	85 c0                	test   %eax,%eax
80107227:	79 07                	jns    80107230 <sys_sbrk+0x22>
    return -1;
80107229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010722e:	eb 28                	jmp    80107258 <sys_sbrk+0x4a>
  addr = proc->sz;
80107230:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107236:	8b 00                	mov    (%eax),%eax
80107238:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010723b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010723e:	83 ec 0c             	sub    $0xc,%esp
80107241:	50                   	push   %eax
80107242:	e8 ff dc ff ff       	call   80104f46 <growproc>
80107247:	83 c4 10             	add    $0x10,%esp
8010724a:	85 c0                	test   %eax,%eax
8010724c:	79 07                	jns    80107255 <sys_sbrk+0x47>
    return -1;
8010724e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107253:	eb 03                	jmp    80107258 <sys_sbrk+0x4a>
  return addr;
80107255:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107258:	c9                   	leave  
80107259:	c3                   	ret    

8010725a <sys_sleep>:

int
sys_sleep(void)
{
8010725a:	55                   	push   %ebp
8010725b:	89 e5                	mov    %esp,%ebp
8010725d:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80107260:	83 ec 08             	sub    $0x8,%esp
80107263:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107266:	50                   	push   %eax
80107267:	6a 00                	push   $0x0
80107269:	e8 81 f0 ff ff       	call   801062ef <argint>
8010726e:	83 c4 10             	add    $0x10,%esp
80107271:	85 c0                	test   %eax,%eax
80107273:	79 07                	jns    8010727c <sys_sleep+0x22>
    return -1;
80107275:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010727a:	eb 77                	jmp    801072f3 <sys_sleep+0x99>
  acquire(&tickslock);
8010727c:	83 ec 0c             	sub    $0xc,%esp
8010727f:	68 c0 ba 11 80       	push   $0x8011bac0
80107284:	e8 de ea ff ff       	call   80105d67 <acquire>
80107289:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010728c:	a1 00 c3 11 80       	mov    0x8011c300,%eax
80107291:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107294:	eb 39                	jmp    801072cf <sys_sleep+0x75>
    if(proc->killed){
80107296:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010729c:	8b 40 24             	mov    0x24(%eax),%eax
8010729f:	85 c0                	test   %eax,%eax
801072a1:	74 17                	je     801072ba <sys_sleep+0x60>
      release(&tickslock);
801072a3:	83 ec 0c             	sub    $0xc,%esp
801072a6:	68 c0 ba 11 80       	push   $0x8011bac0
801072ab:	e8 1e eb ff ff       	call   80105dce <release>
801072b0:	83 c4 10             	add    $0x10,%esp
      return -1;
801072b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072b8:	eb 39                	jmp    801072f3 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801072ba:	83 ec 08             	sub    $0x8,%esp
801072bd:	68 c0 ba 11 80       	push   $0x8011bac0
801072c2:	68 00 c3 11 80       	push   $0x8011c300
801072c7:	e8 d6 e5 ff ff       	call   801058a2 <sleep>
801072cc:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801072cf:	a1 00 c3 11 80       	mov    0x8011c300,%eax
801072d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801072d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801072da:	39 d0                	cmp    %edx,%eax
801072dc:	72 b8                	jb     80107296 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801072de:	83 ec 0c             	sub    $0xc,%esp
801072e1:	68 c0 ba 11 80       	push   $0x8011bac0
801072e6:	e8 e3 ea ff ff       	call   80105dce <release>
801072eb:	83 c4 10             	add    $0x10,%esp
  return 0;
801072ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072f3:	c9                   	leave  
801072f4:	c3                   	ret    

801072f5 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801072f5:	55                   	push   %ebp
801072f6:	89 e5                	mov    %esp,%ebp
801072f8:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801072fb:	83 ec 0c             	sub    $0xc,%esp
801072fe:	68 c0 ba 11 80       	push   $0x8011bac0
80107303:	e8 5f ea ff ff       	call   80105d67 <acquire>
80107308:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010730b:	a1 00 c3 11 80       	mov    0x8011c300,%eax
80107310:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107313:	83 ec 0c             	sub    $0xc,%esp
80107316:	68 c0 ba 11 80       	push   $0x8011bac0
8010731b:	e8 ae ea ff ff       	call   80105dce <release>
80107320:	83 c4 10             	add    $0x10,%esp
  return xticks;
80107323:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107326:	c9                   	leave  
80107327:	c3                   	ret    

80107328 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107328:	55                   	push   %ebp
80107329:	89 e5                	mov    %esp,%ebp
8010732b:	83 ec 08             	sub    $0x8,%esp
8010732e:	8b 55 08             	mov    0x8(%ebp),%edx
80107331:	8b 45 0c             	mov    0xc(%ebp),%eax
80107334:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107338:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010733b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010733f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107343:	ee                   	out    %al,(%dx)
}
80107344:	90                   	nop
80107345:	c9                   	leave  
80107346:	c3                   	ret    

80107347 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107347:	55                   	push   %ebp
80107348:	89 e5                	mov    %esp,%ebp
8010734a:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010734d:	6a 34                	push   $0x34
8010734f:	6a 43                	push   $0x43
80107351:	e8 d2 ff ff ff       	call   80107328 <outb>
80107356:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80107359:	68 9c 00 00 00       	push   $0x9c
8010735e:	6a 40                	push   $0x40
80107360:	e8 c3 ff ff ff       	call   80107328 <outb>
80107365:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107368:	6a 2e                	push   $0x2e
8010736a:	6a 40                	push   $0x40
8010736c:	e8 b7 ff ff ff       	call   80107328 <outb>
80107371:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107374:	83 ec 0c             	sub    $0xc,%esp
80107377:	6a 00                	push   $0x0
80107379:	e8 a3 d3 ff ff       	call   80104721 <picenable>
8010737e:	83 c4 10             	add    $0x10,%esp
}
80107381:	90                   	nop
80107382:	c9                   	leave  
80107383:	c3                   	ret    

80107384 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107384:	1e                   	push   %ds
  pushl %es
80107385:	06                   	push   %es
  pushl %fs
80107386:	0f a0                	push   %fs
  pushl %gs
80107388:	0f a8                	push   %gs
  pushal
8010738a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010738b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010738f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107391:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107393:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107397:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107399:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010739b:	54                   	push   %esp
  call trap
8010739c:	e8 e4 01 00 00       	call   80107585 <trap>
  addl $4, %esp
801073a1:	83 c4 04             	add    $0x4,%esp

801073a4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801073a4:	61                   	popa   
  popl %gs
801073a5:	0f a9                	pop    %gs
  popl %fs
801073a7:	0f a1                	pop    %fs
  popl %es
801073a9:	07                   	pop    %es
  popl %ds
801073aa:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801073ab:	83 c4 08             	add    $0x8,%esp
  iret
801073ae:	cf                   	iret   

801073af <p2v>:
801073af:	55                   	push   %ebp
801073b0:	89 e5                	mov    %esp,%ebp
801073b2:	8b 45 08             	mov    0x8(%ebp),%eax
801073b5:	05 00 00 00 80       	add    $0x80000000,%eax
801073ba:	5d                   	pop    %ebp
801073bb:	c3                   	ret    

801073bc <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801073bc:	55                   	push   %ebp
801073bd:	89 e5                	mov    %esp,%ebp
801073bf:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801073c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801073c5:	83 e8 01             	sub    $0x1,%eax
801073c8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801073cc:	8b 45 08             	mov    0x8(%ebp),%eax
801073cf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801073d3:	8b 45 08             	mov    0x8(%ebp),%eax
801073d6:	c1 e8 10             	shr    $0x10,%eax
801073d9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801073dd:	8d 45 fa             	lea    -0x6(%ebp),%eax
801073e0:	0f 01 18             	lidtl  (%eax)
}
801073e3:	90                   	nop
801073e4:	c9                   	leave  
801073e5:	c3                   	ret    

801073e6 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801073e6:	55                   	push   %ebp
801073e7:	89 e5                	mov    %esp,%ebp
801073e9:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801073ec:	0f 20 d0             	mov    %cr2,%eax
801073ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801073f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801073f5:	c9                   	leave  
801073f6:	c3                   	ret    

801073f7 <tvinit>:
extern void updateLAP();
//finish

void
tvinit(void)
{
801073f7:	55                   	push   %ebp
801073f8:	89 e5                	mov    %esp,%ebp
801073fa:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801073fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107404:	e9 c3 00 00 00       	jmp    801074cc <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740c:	8b 04 85 98 d0 10 80 	mov    -0x7fef2f68(,%eax,4),%eax
80107413:	89 c2                	mov    %eax,%edx
80107415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107418:	66 89 14 c5 00 bb 11 	mov    %dx,-0x7fee4500(,%eax,8)
8010741f:	80 
80107420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107423:	66 c7 04 c5 02 bb 11 	movw   $0x8,-0x7fee44fe(,%eax,8)
8010742a:	80 08 00 
8010742d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107430:	0f b6 14 c5 04 bb 11 	movzbl -0x7fee44fc(,%eax,8),%edx
80107437:	80 
80107438:	83 e2 e0             	and    $0xffffffe0,%edx
8010743b:	88 14 c5 04 bb 11 80 	mov    %dl,-0x7fee44fc(,%eax,8)
80107442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107445:	0f b6 14 c5 04 bb 11 	movzbl -0x7fee44fc(,%eax,8),%edx
8010744c:	80 
8010744d:	83 e2 1f             	and    $0x1f,%edx
80107450:	88 14 c5 04 bb 11 80 	mov    %dl,-0x7fee44fc(,%eax,8)
80107457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745a:	0f b6 14 c5 05 bb 11 	movzbl -0x7fee44fb(,%eax,8),%edx
80107461:	80 
80107462:	83 e2 f0             	and    $0xfffffff0,%edx
80107465:	83 ca 0e             	or     $0xe,%edx
80107468:	88 14 c5 05 bb 11 80 	mov    %dl,-0x7fee44fb(,%eax,8)
8010746f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107472:	0f b6 14 c5 05 bb 11 	movzbl -0x7fee44fb(,%eax,8),%edx
80107479:	80 
8010747a:	83 e2 ef             	and    $0xffffffef,%edx
8010747d:	88 14 c5 05 bb 11 80 	mov    %dl,-0x7fee44fb(,%eax,8)
80107484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107487:	0f b6 14 c5 05 bb 11 	movzbl -0x7fee44fb(,%eax,8),%edx
8010748e:	80 
8010748f:	83 e2 9f             	and    $0xffffff9f,%edx
80107492:	88 14 c5 05 bb 11 80 	mov    %dl,-0x7fee44fb(,%eax,8)
80107499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749c:	0f b6 14 c5 05 bb 11 	movzbl -0x7fee44fb(,%eax,8),%edx
801074a3:	80 
801074a4:	83 ca 80             	or     $0xffffff80,%edx
801074a7:	88 14 c5 05 bb 11 80 	mov    %dl,-0x7fee44fb(,%eax,8)
801074ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b1:	8b 04 85 98 d0 10 80 	mov    -0x7fef2f68(,%eax,4),%eax
801074b8:	c1 e8 10             	shr    $0x10,%eax
801074bb:	89 c2                	mov    %eax,%edx
801074bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c0:	66 89 14 c5 06 bb 11 	mov    %dx,-0x7fee44fa(,%eax,8)
801074c7:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801074c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801074cc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801074d3:	0f 8e 30 ff ff ff    	jle    80107409 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801074d9:	a1 98 d1 10 80       	mov    0x8010d198,%eax
801074de:	66 a3 00 bd 11 80    	mov    %ax,0x8011bd00
801074e4:	66 c7 05 02 bd 11 80 	movw   $0x8,0x8011bd02
801074eb:	08 00 
801074ed:	0f b6 05 04 bd 11 80 	movzbl 0x8011bd04,%eax
801074f4:	83 e0 e0             	and    $0xffffffe0,%eax
801074f7:	a2 04 bd 11 80       	mov    %al,0x8011bd04
801074fc:	0f b6 05 04 bd 11 80 	movzbl 0x8011bd04,%eax
80107503:	83 e0 1f             	and    $0x1f,%eax
80107506:	a2 04 bd 11 80       	mov    %al,0x8011bd04
8010750b:	0f b6 05 05 bd 11 80 	movzbl 0x8011bd05,%eax
80107512:	83 c8 0f             	or     $0xf,%eax
80107515:	a2 05 bd 11 80       	mov    %al,0x8011bd05
8010751a:	0f b6 05 05 bd 11 80 	movzbl 0x8011bd05,%eax
80107521:	83 e0 ef             	and    $0xffffffef,%eax
80107524:	a2 05 bd 11 80       	mov    %al,0x8011bd05
80107529:	0f b6 05 05 bd 11 80 	movzbl 0x8011bd05,%eax
80107530:	83 c8 60             	or     $0x60,%eax
80107533:	a2 05 bd 11 80       	mov    %al,0x8011bd05
80107538:	0f b6 05 05 bd 11 80 	movzbl 0x8011bd05,%eax
8010753f:	83 c8 80             	or     $0xffffff80,%eax
80107542:	a2 05 bd 11 80       	mov    %al,0x8011bd05
80107547:	a1 98 d1 10 80       	mov    0x8010d198,%eax
8010754c:	c1 e8 10             	shr    $0x10,%eax
8010754f:	66 a3 06 bd 11 80    	mov    %ax,0x8011bd06

  initlock(&tickslock, "time");
80107555:	83 ec 08             	sub    $0x8,%esp
80107558:	68 4c a3 10 80       	push   $0x8010a34c
8010755d:	68 c0 ba 11 80       	push   $0x8011bac0
80107562:	e8 de e7 ff ff       	call   80105d45 <initlock>
80107567:	83 c4 10             	add    $0x10,%esp
}
8010756a:	90                   	nop
8010756b:	c9                   	leave  
8010756c:	c3                   	ret    

8010756d <idtinit>:

void
idtinit(void)
{
8010756d:	55                   	push   %ebp
8010756e:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107570:	68 00 08 00 00       	push   $0x800
80107575:	68 00 bb 11 80       	push   $0x8011bb00
8010757a:	e8 3d fe ff ff       	call   801073bc <lidt>
8010757f:	83 c4 08             	add    $0x8,%esp
}
80107582:	90                   	nop
80107583:	c9                   	leave  
80107584:	c3                   	ret    

80107585 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107585:	55                   	push   %ebp
80107586:	89 e5                	mov    %esp,%ebp
80107588:	57                   	push   %edi
80107589:	56                   	push   %esi
8010758a:	53                   	push   %ebx
8010758b:	83 ec 2c             	sub    $0x2c,%esp
  // assignment3 
  uint cr2Register; //register to determine the faulting address and identify the page.
  pde_t *pageDirVa; //page directory entry - first level
  // finish

  if(tf->trapno == T_SYSCALL){
8010758e:	8b 45 08             	mov    0x8(%ebp),%eax
80107591:	8b 40 30             	mov    0x30(%eax),%eax
80107594:	83 f8 40             	cmp    $0x40,%eax
80107597:	75 3e                	jne    801075d7 <trap+0x52>
    if(proc->killed)
80107599:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010759f:	8b 40 24             	mov    0x24(%eax),%eax
801075a2:	85 c0                	test   %eax,%eax
801075a4:	74 05                	je     801075ab <trap+0x26>
      exit();
801075a6:	e8 9e de ff ff       	call   80105449 <exit>
    proc->tf = tf;
801075ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075b1:	8b 55 08             	mov    0x8(%ebp),%edx
801075b4:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801075b7:	e8 e9 ed ff ff       	call   801063a5 <syscall>
    if(proc->killed)
801075bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075c2:	8b 40 24             	mov    0x24(%eax),%eax
801075c5:	85 c0                	test   %eax,%eax
801075c7:	0f 84 af 02 00 00    	je     8010787c <trap+0x2f7>
      exit();
801075cd:	e8 77 de ff ff       	call   80105449 <exit>
    return;
801075d2:	e9 a5 02 00 00       	jmp    8010787c <trap+0x2f7>
  }

  switch(tf->trapno){
801075d7:	8b 45 08             	mov    0x8(%ebp),%eax
801075da:	8b 40 30             	mov    0x30(%eax),%eax
801075dd:	83 e8 0e             	sub    $0xe,%eax
801075e0:	83 f8 31             	cmp    $0x31,%eax
801075e3:	0f 87 54 01 00 00    	ja     8010773d <trap+0x1b8>
801075e9:	8b 04 85 f4 a3 10 80 	mov    -0x7fef5c0c(,%eax,4),%eax
801075f0:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801075f2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801075f8:	0f b6 00             	movzbl (%eax),%eax
801075fb:	84 c0                	test   %al,%al
801075fd:	75 3d                	jne    8010763c <trap+0xb7>
      acquire(&tickslock);
801075ff:	83 ec 0c             	sub    $0xc,%esp
80107602:	68 c0 ba 11 80       	push   $0x8011bac0
80107607:	e8 5b e7 ff ff       	call   80105d67 <acquire>
8010760c:	83 c4 10             	add    $0x10,%esp
      #if LAP
        updateLAP(); 
      #endif
      // finish

      ticks++;
8010760f:	a1 00 c3 11 80       	mov    0x8011c300,%eax
80107614:	83 c0 01             	add    $0x1,%eax
80107617:	a3 00 c3 11 80       	mov    %eax,0x8011c300
      wakeup(&ticks);
8010761c:	83 ec 0c             	sub    $0xc,%esp
8010761f:	68 00 c3 11 80       	push   $0x8011c300
80107624:	e8 67 e3 ff ff       	call   80105990 <wakeup>
80107629:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010762c:	83 ec 0c             	sub    $0xc,%esp
8010762f:	68 c0 ba 11 80       	push   $0x8011bac0
80107634:	e8 95 e7 ff ff       	call   80105dce <release>
80107639:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010763c:	e8 da c1 ff ff       	call   8010381b <lapiceoi>
    break;
80107641:	e9 b0 01 00 00       	jmp    801077f6 <trap+0x271>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107646:	e8 79 b9 ff ff       	call   80102fc4 <ideintr>
    lapiceoi();
8010764b:	e8 cb c1 ff ff       	call   8010381b <lapiceoi>
    break;
80107650:	e9 a1 01 00 00       	jmp    801077f6 <trap+0x271>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107655:	e8 c3 bf ff ff       	call   8010361d <kbdintr>
    lapiceoi();
8010765a:	e8 bc c1 ff ff       	call   8010381b <lapiceoi>
    break;
8010765f:	e9 92 01 00 00       	jmp    801077f6 <trap+0x271>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107664:	e8 f4 03 00 00       	call   80107a5d <uartintr>
    lapiceoi();
80107669:	e8 ad c1 ff ff       	call   8010381b <lapiceoi>
    break;
8010766e:	e9 83 01 00 00       	jmp    801077f6 <trap+0x271>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107673:	8b 45 08             	mov    0x8(%ebp),%eax
80107676:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107679:	8b 45 08             	mov    0x8(%ebp),%eax
8010767c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107680:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107683:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107689:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010768c:	0f b6 c0             	movzbl %al,%eax
8010768f:	51                   	push   %ecx
80107690:	52                   	push   %edx
80107691:	50                   	push   %eax
80107692:	68 54 a3 10 80       	push   $0x8010a354
80107697:	e8 2a 8d ff ff       	call   801003c6 <cprintf>
8010769c:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010769f:	e8 77 c1 ff ff       	call   8010381b <lapiceoi>
    break;
801076a4:	e9 4d 01 00 00       	jmp    801077f6 <trap+0x271>

  // assignment3 
  case T_PGFLT:
    cr2Register = rcr2(); // register cr2 to check if this page exist
801076a9:	e8 38 fd ff ff       	call   801073e6 <rcr2>
801076ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pageDirVa = &proc->pgdir[PDX(cr2Register)] ;// get the entry in page directory
801076b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076b7:	8b 40 04             	mov    0x4(%eax),%eax
801076ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801076bd:	c1 ea 16             	shr    $0x16,%edx
801076c0:	c1 e2 02             	shl    $0x2,%edx
801076c3:	01 d0                	add    %edx,%eax
801076c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(((int)(*pageDirVa) & PTE_P) != 0) // check if the entry exist or this is a segmentation fault
801076c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801076cb:	8b 00                	mov    (%eax),%eax
801076cd:	83 e0 01             	and    $0x1,%eax
801076d0:	85 c0                	test   %eax,%eax
801076d2:	74 69                	je     8010773d <trap+0x1b8>
    {
        pte_t *pageTableAdd = (pte_t*)p2v(PTE_ADDR(*pageDirVa)); // we now have the second level entry
801076d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801076d7:	8b 00                	mov    (%eax),%eax
801076d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076de:	83 ec 0c             	sub    $0xc,%esp
801076e1:	50                   	push   %eax
801076e2:	e8 c8 fc ff ff       	call   801073af <p2v>
801076e7:	83 c4 10             	add    $0x10,%esp
801076ea:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if(pageTableAdd[PTX(cr2Register)] & PTE_PG) // check the page in the process swap file
801076ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801076f0:	c1 e8 0c             	shr    $0xc,%eax
801076f3:	25 ff 03 00 00       	and    $0x3ff,%eax
801076f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80107702:	01 d0                	add    %edx,%eax
80107704:	8b 00                	mov    (%eax),%eax
80107706:	25 00 02 00 00       	and    $0x200,%eax
8010770b:	85 c0                	test   %eax,%eax
8010770d:	74 2e                	je     8010773d <trap+0x1b8>
        {
            swapPagesInTrap(PTE_ADDR(cr2Register)); // found it in disc - put it in physical memory
8010770f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107712:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107717:	83 ec 0c             	sub    $0xc,%esp
8010771a:	50                   	push   %eax
8010771b:	e8 40 25 00 00       	call   80109c60 <swapPagesInTrap>
80107720:	83 c4 10             	add    $0x10,%esp
            proc->totalPageFaultCount++;	//update total Page Fault
80107723:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107729:	8b 90 bc 01 00 00    	mov    0x1bc(%eax),%edx
8010772f:	83 c2 01             	add    $0x1,%edx
80107732:	89 90 bc 01 00 00    	mov    %edx,0x1bc(%eax)
            return;
80107738:	e9 40 01 00 00       	jmp    8010787d <trap+0x2f8>
        }
    }
  //finish
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010773d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107743:	85 c0                	test   %eax,%eax
80107745:	74 11                	je     80107758 <trap+0x1d3>
80107747:	8b 45 08             	mov    0x8(%ebp),%eax
8010774a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010774e:	0f b7 c0             	movzwl %ax,%eax
80107751:	83 e0 03             	and    $0x3,%eax
80107754:	85 c0                	test   %eax,%eax
80107756:	75 40                	jne    80107798 <trap+0x213>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107758:	e8 89 fc ff ff       	call   801073e6 <rcr2>
8010775d:	89 c3                	mov    %eax,%ebx
8010775f:	8b 45 08             	mov    0x8(%ebp),%eax
80107762:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107765:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010776b:	0f b6 00             	movzbl (%eax),%eax
  //finish
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010776e:	0f b6 d0             	movzbl %al,%edx
80107771:	8b 45 08             	mov    0x8(%ebp),%eax
80107774:	8b 40 30             	mov    0x30(%eax),%eax
80107777:	83 ec 0c             	sub    $0xc,%esp
8010777a:	53                   	push   %ebx
8010777b:	51                   	push   %ecx
8010777c:	52                   	push   %edx
8010777d:	50                   	push   %eax
8010777e:	68 78 a3 10 80       	push   $0x8010a378
80107783:	e8 3e 8c ff ff       	call   801003c6 <cprintf>
80107788:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010778b:	83 ec 0c             	sub    $0xc,%esp
8010778e:	68 aa a3 10 80       	push   $0x8010a3aa
80107793:	e8 ce 8d ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107798:	e8 49 fc ff ff       	call   801073e6 <rcr2>
8010779d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801077a0:	8b 45 08             	mov    0x8(%ebp),%eax
801077a3:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
801077a6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077ac:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801077af:	0f b6 d8             	movzbl %al,%ebx
801077b2:	8b 45 08             	mov    0x8(%ebp),%eax
801077b5:	8b 48 34             	mov    0x34(%eax),%ecx
801077b8:	8b 45 08             	mov    0x8(%ebp),%eax
801077bb:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
801077be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077c4:	8d 78 6c             	lea    0x6c(%eax),%edi
801077c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801077cd:	8b 40 10             	mov    0x10(%eax),%eax
801077d0:	ff 75 d4             	pushl  -0x2c(%ebp)
801077d3:	56                   	push   %esi
801077d4:	53                   	push   %ebx
801077d5:	51                   	push   %ecx
801077d6:	52                   	push   %edx
801077d7:	57                   	push   %edi
801077d8:	50                   	push   %eax
801077d9:	68 b0 a3 10 80       	push   $0x8010a3b0
801077de:	e8 e3 8b ff ff       	call   801003c6 <cprintf>
801077e3:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
801077e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077ec:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801077f3:	eb 01                	jmp    801077f6 <trap+0x271>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801077f5:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801077f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077fc:	85 c0                	test   %eax,%eax
801077fe:	74 24                	je     80107824 <trap+0x29f>
80107800:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107806:	8b 40 24             	mov    0x24(%eax),%eax
80107809:	85 c0                	test   %eax,%eax
8010780b:	74 17                	je     80107824 <trap+0x29f>
8010780d:	8b 45 08             	mov    0x8(%ebp),%eax
80107810:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107814:	0f b7 c0             	movzwl %ax,%eax
80107817:	83 e0 03             	and    $0x3,%eax
8010781a:	83 f8 03             	cmp    $0x3,%eax
8010781d:	75 05                	jne    80107824 <trap+0x29f>
    exit();
8010781f:	e8 25 dc ff ff       	call   80105449 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107824:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010782a:	85 c0                	test   %eax,%eax
8010782c:	74 1e                	je     8010784c <trap+0x2c7>
8010782e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107834:	8b 40 0c             	mov    0xc(%eax),%eax
80107837:	83 f8 04             	cmp    $0x4,%eax
8010783a:	75 10                	jne    8010784c <trap+0x2c7>
8010783c:	8b 45 08             	mov    0x8(%ebp),%eax
8010783f:	8b 40 30             	mov    0x30(%eax),%eax
80107842:	83 f8 20             	cmp    $0x20,%eax
80107845:	75 05                	jne    8010784c <trap+0x2c7>
    yield();
80107847:	e8 d5 df ff ff       	call   80105821 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010784c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107852:	85 c0                	test   %eax,%eax
80107854:	74 27                	je     8010787d <trap+0x2f8>
80107856:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010785c:	8b 40 24             	mov    0x24(%eax),%eax
8010785f:	85 c0                	test   %eax,%eax
80107861:	74 1a                	je     8010787d <trap+0x2f8>
80107863:	8b 45 08             	mov    0x8(%ebp),%eax
80107866:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010786a:	0f b7 c0             	movzwl %ax,%eax
8010786d:	83 e0 03             	and    $0x3,%eax
80107870:	83 f8 03             	cmp    $0x3,%eax
80107873:	75 08                	jne    8010787d <trap+0x2f8>
    exit();
80107875:	e8 cf db ff ff       	call   80105449 <exit>
8010787a:	eb 01                	jmp    8010787d <trap+0x2f8>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010787c:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010787d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107880:	5b                   	pop    %ebx
80107881:	5e                   	pop    %esi
80107882:	5f                   	pop    %edi
80107883:	5d                   	pop    %ebp
80107884:	c3                   	ret    

80107885 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107885:	55                   	push   %ebp
80107886:	89 e5                	mov    %esp,%ebp
80107888:	83 ec 14             	sub    $0x14,%esp
8010788b:	8b 45 08             	mov    0x8(%ebp),%eax
8010788e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107892:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107896:	89 c2                	mov    %eax,%edx
80107898:	ec                   	in     (%dx),%al
80107899:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010789c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801078a0:	c9                   	leave  
801078a1:	c3                   	ret    

801078a2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801078a2:	55                   	push   %ebp
801078a3:	89 e5                	mov    %esp,%ebp
801078a5:	83 ec 08             	sub    $0x8,%esp
801078a8:	8b 55 08             	mov    0x8(%ebp),%edx
801078ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801078ae:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801078b2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801078b5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801078b9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801078bd:	ee                   	out    %al,(%dx)
}
801078be:	90                   	nop
801078bf:	c9                   	leave  
801078c0:	c3                   	ret    

801078c1 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801078c1:	55                   	push   %ebp
801078c2:	89 e5                	mov    %esp,%ebp
801078c4:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801078c7:	6a 00                	push   $0x0
801078c9:	68 fa 03 00 00       	push   $0x3fa
801078ce:	e8 cf ff ff ff       	call   801078a2 <outb>
801078d3:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801078d6:	68 80 00 00 00       	push   $0x80
801078db:	68 fb 03 00 00       	push   $0x3fb
801078e0:	e8 bd ff ff ff       	call   801078a2 <outb>
801078e5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801078e8:	6a 0c                	push   $0xc
801078ea:	68 f8 03 00 00       	push   $0x3f8
801078ef:	e8 ae ff ff ff       	call   801078a2 <outb>
801078f4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801078f7:	6a 00                	push   $0x0
801078f9:	68 f9 03 00 00       	push   $0x3f9
801078fe:	e8 9f ff ff ff       	call   801078a2 <outb>
80107903:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107906:	6a 03                	push   $0x3
80107908:	68 fb 03 00 00       	push   $0x3fb
8010790d:	e8 90 ff ff ff       	call   801078a2 <outb>
80107912:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107915:	6a 00                	push   $0x0
80107917:	68 fc 03 00 00       	push   $0x3fc
8010791c:	e8 81 ff ff ff       	call   801078a2 <outb>
80107921:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107924:	6a 01                	push   $0x1
80107926:	68 f9 03 00 00       	push   $0x3f9
8010792b:	e8 72 ff ff ff       	call   801078a2 <outb>
80107930:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107933:	68 fd 03 00 00       	push   $0x3fd
80107938:	e8 48 ff ff ff       	call   80107885 <inb>
8010793d:	83 c4 04             	add    $0x4,%esp
80107940:	3c ff                	cmp    $0xff,%al
80107942:	74 6e                	je     801079b2 <uartinit+0xf1>
    return;
  uart = 1;
80107944:	c7 05 4c d6 10 80 01 	movl   $0x1,0x8010d64c
8010794b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010794e:	68 fa 03 00 00       	push   $0x3fa
80107953:	e8 2d ff ff ff       	call   80107885 <inb>
80107958:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010795b:	68 f8 03 00 00       	push   $0x3f8
80107960:	e8 20 ff ff ff       	call   80107885 <inb>
80107965:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107968:	83 ec 0c             	sub    $0xc,%esp
8010796b:	6a 04                	push   $0x4
8010796d:	e8 af cd ff ff       	call   80104721 <picenable>
80107972:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107975:	83 ec 08             	sub    $0x8,%esp
80107978:	6a 00                	push   $0x0
8010797a:	6a 04                	push   $0x4
8010797c:	e8 e5 b8 ff ff       	call   80103266 <ioapicenable>
80107981:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107984:	c7 45 f4 bc a4 10 80 	movl   $0x8010a4bc,-0xc(%ebp)
8010798b:	eb 19                	jmp    801079a6 <uartinit+0xe5>
    uartputc(*p);
8010798d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107990:	0f b6 00             	movzbl (%eax),%eax
80107993:	0f be c0             	movsbl %al,%eax
80107996:	83 ec 0c             	sub    $0xc,%esp
80107999:	50                   	push   %eax
8010799a:	e8 16 00 00 00       	call   801079b5 <uartputc>
8010799f:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801079a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801079a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a9:	0f b6 00             	movzbl (%eax),%eax
801079ac:	84 c0                	test   %al,%al
801079ae:	75 dd                	jne    8010798d <uartinit+0xcc>
801079b0:	eb 01                	jmp    801079b3 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801079b2:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801079b3:	c9                   	leave  
801079b4:	c3                   	ret    

801079b5 <uartputc>:

void
uartputc(int c)
{
801079b5:	55                   	push   %ebp
801079b6:	89 e5                	mov    %esp,%ebp
801079b8:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801079bb:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
801079c0:	85 c0                	test   %eax,%eax
801079c2:	74 53                	je     80107a17 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801079c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079cb:	eb 11                	jmp    801079de <uartputc+0x29>
    microdelay(10);
801079cd:	83 ec 0c             	sub    $0xc,%esp
801079d0:	6a 0a                	push   $0xa
801079d2:	e8 5f be ff ff       	call   80103836 <microdelay>
801079d7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801079da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801079de:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801079e2:	7f 1a                	jg     801079fe <uartputc+0x49>
801079e4:	83 ec 0c             	sub    $0xc,%esp
801079e7:	68 fd 03 00 00       	push   $0x3fd
801079ec:	e8 94 fe ff ff       	call   80107885 <inb>
801079f1:	83 c4 10             	add    $0x10,%esp
801079f4:	0f b6 c0             	movzbl %al,%eax
801079f7:	83 e0 20             	and    $0x20,%eax
801079fa:	85 c0                	test   %eax,%eax
801079fc:	74 cf                	je     801079cd <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801079fe:	8b 45 08             	mov    0x8(%ebp),%eax
80107a01:	0f b6 c0             	movzbl %al,%eax
80107a04:	83 ec 08             	sub    $0x8,%esp
80107a07:	50                   	push   %eax
80107a08:	68 f8 03 00 00       	push   $0x3f8
80107a0d:	e8 90 fe ff ff       	call   801078a2 <outb>
80107a12:	83 c4 10             	add    $0x10,%esp
80107a15:	eb 01                	jmp    80107a18 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107a17:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107a18:	c9                   	leave  
80107a19:	c3                   	ret    

80107a1a <uartgetc>:

static int
uartgetc(void)
{
80107a1a:	55                   	push   %ebp
80107a1b:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107a1d:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
80107a22:	85 c0                	test   %eax,%eax
80107a24:	75 07                	jne    80107a2d <uartgetc+0x13>
    return -1;
80107a26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a2b:	eb 2e                	jmp    80107a5b <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107a2d:	68 fd 03 00 00       	push   $0x3fd
80107a32:	e8 4e fe ff ff       	call   80107885 <inb>
80107a37:	83 c4 04             	add    $0x4,%esp
80107a3a:	0f b6 c0             	movzbl %al,%eax
80107a3d:	83 e0 01             	and    $0x1,%eax
80107a40:	85 c0                	test   %eax,%eax
80107a42:	75 07                	jne    80107a4b <uartgetc+0x31>
    return -1;
80107a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a49:	eb 10                	jmp    80107a5b <uartgetc+0x41>
  return inb(COM1+0);
80107a4b:	68 f8 03 00 00       	push   $0x3f8
80107a50:	e8 30 fe ff ff       	call   80107885 <inb>
80107a55:	83 c4 04             	add    $0x4,%esp
80107a58:	0f b6 c0             	movzbl %al,%eax
}
80107a5b:	c9                   	leave  
80107a5c:	c3                   	ret    

80107a5d <uartintr>:

void
uartintr(void)
{
80107a5d:	55                   	push   %ebp
80107a5e:	89 e5                	mov    %esp,%ebp
80107a60:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107a63:	83 ec 0c             	sub    $0xc,%esp
80107a66:	68 1a 7a 10 80       	push   $0x80107a1a
80107a6b:	e8 89 8d ff ff       	call   801007f9 <consoleintr>
80107a70:	83 c4 10             	add    $0x10,%esp
}
80107a73:	90                   	nop
80107a74:	c9                   	leave  
80107a75:	c3                   	ret    

80107a76 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107a76:	6a 00                	push   $0x0
  pushl $0
80107a78:	6a 00                	push   $0x0
  jmp alltraps
80107a7a:	e9 05 f9 ff ff       	jmp    80107384 <alltraps>

80107a7f <vector1>:
.globl vector1
vector1:
  pushl $0
80107a7f:	6a 00                	push   $0x0
  pushl $1
80107a81:	6a 01                	push   $0x1
  jmp alltraps
80107a83:	e9 fc f8 ff ff       	jmp    80107384 <alltraps>

80107a88 <vector2>:
.globl vector2
vector2:
  pushl $0
80107a88:	6a 00                	push   $0x0
  pushl $2
80107a8a:	6a 02                	push   $0x2
  jmp alltraps
80107a8c:	e9 f3 f8 ff ff       	jmp    80107384 <alltraps>

80107a91 <vector3>:
.globl vector3
vector3:
  pushl $0
80107a91:	6a 00                	push   $0x0
  pushl $3
80107a93:	6a 03                	push   $0x3
  jmp alltraps
80107a95:	e9 ea f8 ff ff       	jmp    80107384 <alltraps>

80107a9a <vector4>:
.globl vector4
vector4:
  pushl $0
80107a9a:	6a 00                	push   $0x0
  pushl $4
80107a9c:	6a 04                	push   $0x4
  jmp alltraps
80107a9e:	e9 e1 f8 ff ff       	jmp    80107384 <alltraps>

80107aa3 <vector5>:
.globl vector5
vector5:
  pushl $0
80107aa3:	6a 00                	push   $0x0
  pushl $5
80107aa5:	6a 05                	push   $0x5
  jmp alltraps
80107aa7:	e9 d8 f8 ff ff       	jmp    80107384 <alltraps>

80107aac <vector6>:
.globl vector6
vector6:
  pushl $0
80107aac:	6a 00                	push   $0x0
  pushl $6
80107aae:	6a 06                	push   $0x6
  jmp alltraps
80107ab0:	e9 cf f8 ff ff       	jmp    80107384 <alltraps>

80107ab5 <vector7>:
.globl vector7
vector7:
  pushl $0
80107ab5:	6a 00                	push   $0x0
  pushl $7
80107ab7:	6a 07                	push   $0x7
  jmp alltraps
80107ab9:	e9 c6 f8 ff ff       	jmp    80107384 <alltraps>

80107abe <vector8>:
.globl vector8
vector8:
  pushl $8
80107abe:	6a 08                	push   $0x8
  jmp alltraps
80107ac0:	e9 bf f8 ff ff       	jmp    80107384 <alltraps>

80107ac5 <vector9>:
.globl vector9
vector9:
  pushl $0
80107ac5:	6a 00                	push   $0x0
  pushl $9
80107ac7:	6a 09                	push   $0x9
  jmp alltraps
80107ac9:	e9 b6 f8 ff ff       	jmp    80107384 <alltraps>

80107ace <vector10>:
.globl vector10
vector10:
  pushl $10
80107ace:	6a 0a                	push   $0xa
  jmp alltraps
80107ad0:	e9 af f8 ff ff       	jmp    80107384 <alltraps>

80107ad5 <vector11>:
.globl vector11
vector11:
  pushl $11
80107ad5:	6a 0b                	push   $0xb
  jmp alltraps
80107ad7:	e9 a8 f8 ff ff       	jmp    80107384 <alltraps>

80107adc <vector12>:
.globl vector12
vector12:
  pushl $12
80107adc:	6a 0c                	push   $0xc
  jmp alltraps
80107ade:	e9 a1 f8 ff ff       	jmp    80107384 <alltraps>

80107ae3 <vector13>:
.globl vector13
vector13:
  pushl $13
80107ae3:	6a 0d                	push   $0xd
  jmp alltraps
80107ae5:	e9 9a f8 ff ff       	jmp    80107384 <alltraps>

80107aea <vector14>:
.globl vector14
vector14:
  pushl $14
80107aea:	6a 0e                	push   $0xe
  jmp alltraps
80107aec:	e9 93 f8 ff ff       	jmp    80107384 <alltraps>

80107af1 <vector15>:
.globl vector15
vector15:
  pushl $0
80107af1:	6a 00                	push   $0x0
  pushl $15
80107af3:	6a 0f                	push   $0xf
  jmp alltraps
80107af5:	e9 8a f8 ff ff       	jmp    80107384 <alltraps>

80107afa <vector16>:
.globl vector16
vector16:
  pushl $0
80107afa:	6a 00                	push   $0x0
  pushl $16
80107afc:	6a 10                	push   $0x10
  jmp alltraps
80107afe:	e9 81 f8 ff ff       	jmp    80107384 <alltraps>

80107b03 <vector17>:
.globl vector17
vector17:
  pushl $17
80107b03:	6a 11                	push   $0x11
  jmp alltraps
80107b05:	e9 7a f8 ff ff       	jmp    80107384 <alltraps>

80107b0a <vector18>:
.globl vector18
vector18:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $18
80107b0c:	6a 12                	push   $0x12
  jmp alltraps
80107b0e:	e9 71 f8 ff ff       	jmp    80107384 <alltraps>

80107b13 <vector19>:
.globl vector19
vector19:
  pushl $0
80107b13:	6a 00                	push   $0x0
  pushl $19
80107b15:	6a 13                	push   $0x13
  jmp alltraps
80107b17:	e9 68 f8 ff ff       	jmp    80107384 <alltraps>

80107b1c <vector20>:
.globl vector20
vector20:
  pushl $0
80107b1c:	6a 00                	push   $0x0
  pushl $20
80107b1e:	6a 14                	push   $0x14
  jmp alltraps
80107b20:	e9 5f f8 ff ff       	jmp    80107384 <alltraps>

80107b25 <vector21>:
.globl vector21
vector21:
  pushl $0
80107b25:	6a 00                	push   $0x0
  pushl $21
80107b27:	6a 15                	push   $0x15
  jmp alltraps
80107b29:	e9 56 f8 ff ff       	jmp    80107384 <alltraps>

80107b2e <vector22>:
.globl vector22
vector22:
  pushl $0
80107b2e:	6a 00                	push   $0x0
  pushl $22
80107b30:	6a 16                	push   $0x16
  jmp alltraps
80107b32:	e9 4d f8 ff ff       	jmp    80107384 <alltraps>

80107b37 <vector23>:
.globl vector23
vector23:
  pushl $0
80107b37:	6a 00                	push   $0x0
  pushl $23
80107b39:	6a 17                	push   $0x17
  jmp alltraps
80107b3b:	e9 44 f8 ff ff       	jmp    80107384 <alltraps>

80107b40 <vector24>:
.globl vector24
vector24:
  pushl $0
80107b40:	6a 00                	push   $0x0
  pushl $24
80107b42:	6a 18                	push   $0x18
  jmp alltraps
80107b44:	e9 3b f8 ff ff       	jmp    80107384 <alltraps>

80107b49 <vector25>:
.globl vector25
vector25:
  pushl $0
80107b49:	6a 00                	push   $0x0
  pushl $25
80107b4b:	6a 19                	push   $0x19
  jmp alltraps
80107b4d:	e9 32 f8 ff ff       	jmp    80107384 <alltraps>

80107b52 <vector26>:
.globl vector26
vector26:
  pushl $0
80107b52:	6a 00                	push   $0x0
  pushl $26
80107b54:	6a 1a                	push   $0x1a
  jmp alltraps
80107b56:	e9 29 f8 ff ff       	jmp    80107384 <alltraps>

80107b5b <vector27>:
.globl vector27
vector27:
  pushl $0
80107b5b:	6a 00                	push   $0x0
  pushl $27
80107b5d:	6a 1b                	push   $0x1b
  jmp alltraps
80107b5f:	e9 20 f8 ff ff       	jmp    80107384 <alltraps>

80107b64 <vector28>:
.globl vector28
vector28:
  pushl $0
80107b64:	6a 00                	push   $0x0
  pushl $28
80107b66:	6a 1c                	push   $0x1c
  jmp alltraps
80107b68:	e9 17 f8 ff ff       	jmp    80107384 <alltraps>

80107b6d <vector29>:
.globl vector29
vector29:
  pushl $0
80107b6d:	6a 00                	push   $0x0
  pushl $29
80107b6f:	6a 1d                	push   $0x1d
  jmp alltraps
80107b71:	e9 0e f8 ff ff       	jmp    80107384 <alltraps>

80107b76 <vector30>:
.globl vector30
vector30:
  pushl $0
80107b76:	6a 00                	push   $0x0
  pushl $30
80107b78:	6a 1e                	push   $0x1e
  jmp alltraps
80107b7a:	e9 05 f8 ff ff       	jmp    80107384 <alltraps>

80107b7f <vector31>:
.globl vector31
vector31:
  pushl $0
80107b7f:	6a 00                	push   $0x0
  pushl $31
80107b81:	6a 1f                	push   $0x1f
  jmp alltraps
80107b83:	e9 fc f7 ff ff       	jmp    80107384 <alltraps>

80107b88 <vector32>:
.globl vector32
vector32:
  pushl $0
80107b88:	6a 00                	push   $0x0
  pushl $32
80107b8a:	6a 20                	push   $0x20
  jmp alltraps
80107b8c:	e9 f3 f7 ff ff       	jmp    80107384 <alltraps>

80107b91 <vector33>:
.globl vector33
vector33:
  pushl $0
80107b91:	6a 00                	push   $0x0
  pushl $33
80107b93:	6a 21                	push   $0x21
  jmp alltraps
80107b95:	e9 ea f7 ff ff       	jmp    80107384 <alltraps>

80107b9a <vector34>:
.globl vector34
vector34:
  pushl $0
80107b9a:	6a 00                	push   $0x0
  pushl $34
80107b9c:	6a 22                	push   $0x22
  jmp alltraps
80107b9e:	e9 e1 f7 ff ff       	jmp    80107384 <alltraps>

80107ba3 <vector35>:
.globl vector35
vector35:
  pushl $0
80107ba3:	6a 00                	push   $0x0
  pushl $35
80107ba5:	6a 23                	push   $0x23
  jmp alltraps
80107ba7:	e9 d8 f7 ff ff       	jmp    80107384 <alltraps>

80107bac <vector36>:
.globl vector36
vector36:
  pushl $0
80107bac:	6a 00                	push   $0x0
  pushl $36
80107bae:	6a 24                	push   $0x24
  jmp alltraps
80107bb0:	e9 cf f7 ff ff       	jmp    80107384 <alltraps>

80107bb5 <vector37>:
.globl vector37
vector37:
  pushl $0
80107bb5:	6a 00                	push   $0x0
  pushl $37
80107bb7:	6a 25                	push   $0x25
  jmp alltraps
80107bb9:	e9 c6 f7 ff ff       	jmp    80107384 <alltraps>

80107bbe <vector38>:
.globl vector38
vector38:
  pushl $0
80107bbe:	6a 00                	push   $0x0
  pushl $38
80107bc0:	6a 26                	push   $0x26
  jmp alltraps
80107bc2:	e9 bd f7 ff ff       	jmp    80107384 <alltraps>

80107bc7 <vector39>:
.globl vector39
vector39:
  pushl $0
80107bc7:	6a 00                	push   $0x0
  pushl $39
80107bc9:	6a 27                	push   $0x27
  jmp alltraps
80107bcb:	e9 b4 f7 ff ff       	jmp    80107384 <alltraps>

80107bd0 <vector40>:
.globl vector40
vector40:
  pushl $0
80107bd0:	6a 00                	push   $0x0
  pushl $40
80107bd2:	6a 28                	push   $0x28
  jmp alltraps
80107bd4:	e9 ab f7 ff ff       	jmp    80107384 <alltraps>

80107bd9 <vector41>:
.globl vector41
vector41:
  pushl $0
80107bd9:	6a 00                	push   $0x0
  pushl $41
80107bdb:	6a 29                	push   $0x29
  jmp alltraps
80107bdd:	e9 a2 f7 ff ff       	jmp    80107384 <alltraps>

80107be2 <vector42>:
.globl vector42
vector42:
  pushl $0
80107be2:	6a 00                	push   $0x0
  pushl $42
80107be4:	6a 2a                	push   $0x2a
  jmp alltraps
80107be6:	e9 99 f7 ff ff       	jmp    80107384 <alltraps>

80107beb <vector43>:
.globl vector43
vector43:
  pushl $0
80107beb:	6a 00                	push   $0x0
  pushl $43
80107bed:	6a 2b                	push   $0x2b
  jmp alltraps
80107bef:	e9 90 f7 ff ff       	jmp    80107384 <alltraps>

80107bf4 <vector44>:
.globl vector44
vector44:
  pushl $0
80107bf4:	6a 00                	push   $0x0
  pushl $44
80107bf6:	6a 2c                	push   $0x2c
  jmp alltraps
80107bf8:	e9 87 f7 ff ff       	jmp    80107384 <alltraps>

80107bfd <vector45>:
.globl vector45
vector45:
  pushl $0
80107bfd:	6a 00                	push   $0x0
  pushl $45
80107bff:	6a 2d                	push   $0x2d
  jmp alltraps
80107c01:	e9 7e f7 ff ff       	jmp    80107384 <alltraps>

80107c06 <vector46>:
.globl vector46
vector46:
  pushl $0
80107c06:	6a 00                	push   $0x0
  pushl $46
80107c08:	6a 2e                	push   $0x2e
  jmp alltraps
80107c0a:	e9 75 f7 ff ff       	jmp    80107384 <alltraps>

80107c0f <vector47>:
.globl vector47
vector47:
  pushl $0
80107c0f:	6a 00                	push   $0x0
  pushl $47
80107c11:	6a 2f                	push   $0x2f
  jmp alltraps
80107c13:	e9 6c f7 ff ff       	jmp    80107384 <alltraps>

80107c18 <vector48>:
.globl vector48
vector48:
  pushl $0
80107c18:	6a 00                	push   $0x0
  pushl $48
80107c1a:	6a 30                	push   $0x30
  jmp alltraps
80107c1c:	e9 63 f7 ff ff       	jmp    80107384 <alltraps>

80107c21 <vector49>:
.globl vector49
vector49:
  pushl $0
80107c21:	6a 00                	push   $0x0
  pushl $49
80107c23:	6a 31                	push   $0x31
  jmp alltraps
80107c25:	e9 5a f7 ff ff       	jmp    80107384 <alltraps>

80107c2a <vector50>:
.globl vector50
vector50:
  pushl $0
80107c2a:	6a 00                	push   $0x0
  pushl $50
80107c2c:	6a 32                	push   $0x32
  jmp alltraps
80107c2e:	e9 51 f7 ff ff       	jmp    80107384 <alltraps>

80107c33 <vector51>:
.globl vector51
vector51:
  pushl $0
80107c33:	6a 00                	push   $0x0
  pushl $51
80107c35:	6a 33                	push   $0x33
  jmp alltraps
80107c37:	e9 48 f7 ff ff       	jmp    80107384 <alltraps>

80107c3c <vector52>:
.globl vector52
vector52:
  pushl $0
80107c3c:	6a 00                	push   $0x0
  pushl $52
80107c3e:	6a 34                	push   $0x34
  jmp alltraps
80107c40:	e9 3f f7 ff ff       	jmp    80107384 <alltraps>

80107c45 <vector53>:
.globl vector53
vector53:
  pushl $0
80107c45:	6a 00                	push   $0x0
  pushl $53
80107c47:	6a 35                	push   $0x35
  jmp alltraps
80107c49:	e9 36 f7 ff ff       	jmp    80107384 <alltraps>

80107c4e <vector54>:
.globl vector54
vector54:
  pushl $0
80107c4e:	6a 00                	push   $0x0
  pushl $54
80107c50:	6a 36                	push   $0x36
  jmp alltraps
80107c52:	e9 2d f7 ff ff       	jmp    80107384 <alltraps>

80107c57 <vector55>:
.globl vector55
vector55:
  pushl $0
80107c57:	6a 00                	push   $0x0
  pushl $55
80107c59:	6a 37                	push   $0x37
  jmp alltraps
80107c5b:	e9 24 f7 ff ff       	jmp    80107384 <alltraps>

80107c60 <vector56>:
.globl vector56
vector56:
  pushl $0
80107c60:	6a 00                	push   $0x0
  pushl $56
80107c62:	6a 38                	push   $0x38
  jmp alltraps
80107c64:	e9 1b f7 ff ff       	jmp    80107384 <alltraps>

80107c69 <vector57>:
.globl vector57
vector57:
  pushl $0
80107c69:	6a 00                	push   $0x0
  pushl $57
80107c6b:	6a 39                	push   $0x39
  jmp alltraps
80107c6d:	e9 12 f7 ff ff       	jmp    80107384 <alltraps>

80107c72 <vector58>:
.globl vector58
vector58:
  pushl $0
80107c72:	6a 00                	push   $0x0
  pushl $58
80107c74:	6a 3a                	push   $0x3a
  jmp alltraps
80107c76:	e9 09 f7 ff ff       	jmp    80107384 <alltraps>

80107c7b <vector59>:
.globl vector59
vector59:
  pushl $0
80107c7b:	6a 00                	push   $0x0
  pushl $59
80107c7d:	6a 3b                	push   $0x3b
  jmp alltraps
80107c7f:	e9 00 f7 ff ff       	jmp    80107384 <alltraps>

80107c84 <vector60>:
.globl vector60
vector60:
  pushl $0
80107c84:	6a 00                	push   $0x0
  pushl $60
80107c86:	6a 3c                	push   $0x3c
  jmp alltraps
80107c88:	e9 f7 f6 ff ff       	jmp    80107384 <alltraps>

80107c8d <vector61>:
.globl vector61
vector61:
  pushl $0
80107c8d:	6a 00                	push   $0x0
  pushl $61
80107c8f:	6a 3d                	push   $0x3d
  jmp alltraps
80107c91:	e9 ee f6 ff ff       	jmp    80107384 <alltraps>

80107c96 <vector62>:
.globl vector62
vector62:
  pushl $0
80107c96:	6a 00                	push   $0x0
  pushl $62
80107c98:	6a 3e                	push   $0x3e
  jmp alltraps
80107c9a:	e9 e5 f6 ff ff       	jmp    80107384 <alltraps>

80107c9f <vector63>:
.globl vector63
vector63:
  pushl $0
80107c9f:	6a 00                	push   $0x0
  pushl $63
80107ca1:	6a 3f                	push   $0x3f
  jmp alltraps
80107ca3:	e9 dc f6 ff ff       	jmp    80107384 <alltraps>

80107ca8 <vector64>:
.globl vector64
vector64:
  pushl $0
80107ca8:	6a 00                	push   $0x0
  pushl $64
80107caa:	6a 40                	push   $0x40
  jmp alltraps
80107cac:	e9 d3 f6 ff ff       	jmp    80107384 <alltraps>

80107cb1 <vector65>:
.globl vector65
vector65:
  pushl $0
80107cb1:	6a 00                	push   $0x0
  pushl $65
80107cb3:	6a 41                	push   $0x41
  jmp alltraps
80107cb5:	e9 ca f6 ff ff       	jmp    80107384 <alltraps>

80107cba <vector66>:
.globl vector66
vector66:
  pushl $0
80107cba:	6a 00                	push   $0x0
  pushl $66
80107cbc:	6a 42                	push   $0x42
  jmp alltraps
80107cbe:	e9 c1 f6 ff ff       	jmp    80107384 <alltraps>

80107cc3 <vector67>:
.globl vector67
vector67:
  pushl $0
80107cc3:	6a 00                	push   $0x0
  pushl $67
80107cc5:	6a 43                	push   $0x43
  jmp alltraps
80107cc7:	e9 b8 f6 ff ff       	jmp    80107384 <alltraps>

80107ccc <vector68>:
.globl vector68
vector68:
  pushl $0
80107ccc:	6a 00                	push   $0x0
  pushl $68
80107cce:	6a 44                	push   $0x44
  jmp alltraps
80107cd0:	e9 af f6 ff ff       	jmp    80107384 <alltraps>

80107cd5 <vector69>:
.globl vector69
vector69:
  pushl $0
80107cd5:	6a 00                	push   $0x0
  pushl $69
80107cd7:	6a 45                	push   $0x45
  jmp alltraps
80107cd9:	e9 a6 f6 ff ff       	jmp    80107384 <alltraps>

80107cde <vector70>:
.globl vector70
vector70:
  pushl $0
80107cde:	6a 00                	push   $0x0
  pushl $70
80107ce0:	6a 46                	push   $0x46
  jmp alltraps
80107ce2:	e9 9d f6 ff ff       	jmp    80107384 <alltraps>

80107ce7 <vector71>:
.globl vector71
vector71:
  pushl $0
80107ce7:	6a 00                	push   $0x0
  pushl $71
80107ce9:	6a 47                	push   $0x47
  jmp alltraps
80107ceb:	e9 94 f6 ff ff       	jmp    80107384 <alltraps>

80107cf0 <vector72>:
.globl vector72
vector72:
  pushl $0
80107cf0:	6a 00                	push   $0x0
  pushl $72
80107cf2:	6a 48                	push   $0x48
  jmp alltraps
80107cf4:	e9 8b f6 ff ff       	jmp    80107384 <alltraps>

80107cf9 <vector73>:
.globl vector73
vector73:
  pushl $0
80107cf9:	6a 00                	push   $0x0
  pushl $73
80107cfb:	6a 49                	push   $0x49
  jmp alltraps
80107cfd:	e9 82 f6 ff ff       	jmp    80107384 <alltraps>

80107d02 <vector74>:
.globl vector74
vector74:
  pushl $0
80107d02:	6a 00                	push   $0x0
  pushl $74
80107d04:	6a 4a                	push   $0x4a
  jmp alltraps
80107d06:	e9 79 f6 ff ff       	jmp    80107384 <alltraps>

80107d0b <vector75>:
.globl vector75
vector75:
  pushl $0
80107d0b:	6a 00                	push   $0x0
  pushl $75
80107d0d:	6a 4b                	push   $0x4b
  jmp alltraps
80107d0f:	e9 70 f6 ff ff       	jmp    80107384 <alltraps>

80107d14 <vector76>:
.globl vector76
vector76:
  pushl $0
80107d14:	6a 00                	push   $0x0
  pushl $76
80107d16:	6a 4c                	push   $0x4c
  jmp alltraps
80107d18:	e9 67 f6 ff ff       	jmp    80107384 <alltraps>

80107d1d <vector77>:
.globl vector77
vector77:
  pushl $0
80107d1d:	6a 00                	push   $0x0
  pushl $77
80107d1f:	6a 4d                	push   $0x4d
  jmp alltraps
80107d21:	e9 5e f6 ff ff       	jmp    80107384 <alltraps>

80107d26 <vector78>:
.globl vector78
vector78:
  pushl $0
80107d26:	6a 00                	push   $0x0
  pushl $78
80107d28:	6a 4e                	push   $0x4e
  jmp alltraps
80107d2a:	e9 55 f6 ff ff       	jmp    80107384 <alltraps>

80107d2f <vector79>:
.globl vector79
vector79:
  pushl $0
80107d2f:	6a 00                	push   $0x0
  pushl $79
80107d31:	6a 4f                	push   $0x4f
  jmp alltraps
80107d33:	e9 4c f6 ff ff       	jmp    80107384 <alltraps>

80107d38 <vector80>:
.globl vector80
vector80:
  pushl $0
80107d38:	6a 00                	push   $0x0
  pushl $80
80107d3a:	6a 50                	push   $0x50
  jmp alltraps
80107d3c:	e9 43 f6 ff ff       	jmp    80107384 <alltraps>

80107d41 <vector81>:
.globl vector81
vector81:
  pushl $0
80107d41:	6a 00                	push   $0x0
  pushl $81
80107d43:	6a 51                	push   $0x51
  jmp alltraps
80107d45:	e9 3a f6 ff ff       	jmp    80107384 <alltraps>

80107d4a <vector82>:
.globl vector82
vector82:
  pushl $0
80107d4a:	6a 00                	push   $0x0
  pushl $82
80107d4c:	6a 52                	push   $0x52
  jmp alltraps
80107d4e:	e9 31 f6 ff ff       	jmp    80107384 <alltraps>

80107d53 <vector83>:
.globl vector83
vector83:
  pushl $0
80107d53:	6a 00                	push   $0x0
  pushl $83
80107d55:	6a 53                	push   $0x53
  jmp alltraps
80107d57:	e9 28 f6 ff ff       	jmp    80107384 <alltraps>

80107d5c <vector84>:
.globl vector84
vector84:
  pushl $0
80107d5c:	6a 00                	push   $0x0
  pushl $84
80107d5e:	6a 54                	push   $0x54
  jmp alltraps
80107d60:	e9 1f f6 ff ff       	jmp    80107384 <alltraps>

80107d65 <vector85>:
.globl vector85
vector85:
  pushl $0
80107d65:	6a 00                	push   $0x0
  pushl $85
80107d67:	6a 55                	push   $0x55
  jmp alltraps
80107d69:	e9 16 f6 ff ff       	jmp    80107384 <alltraps>

80107d6e <vector86>:
.globl vector86
vector86:
  pushl $0
80107d6e:	6a 00                	push   $0x0
  pushl $86
80107d70:	6a 56                	push   $0x56
  jmp alltraps
80107d72:	e9 0d f6 ff ff       	jmp    80107384 <alltraps>

80107d77 <vector87>:
.globl vector87
vector87:
  pushl $0
80107d77:	6a 00                	push   $0x0
  pushl $87
80107d79:	6a 57                	push   $0x57
  jmp alltraps
80107d7b:	e9 04 f6 ff ff       	jmp    80107384 <alltraps>

80107d80 <vector88>:
.globl vector88
vector88:
  pushl $0
80107d80:	6a 00                	push   $0x0
  pushl $88
80107d82:	6a 58                	push   $0x58
  jmp alltraps
80107d84:	e9 fb f5 ff ff       	jmp    80107384 <alltraps>

80107d89 <vector89>:
.globl vector89
vector89:
  pushl $0
80107d89:	6a 00                	push   $0x0
  pushl $89
80107d8b:	6a 59                	push   $0x59
  jmp alltraps
80107d8d:	e9 f2 f5 ff ff       	jmp    80107384 <alltraps>

80107d92 <vector90>:
.globl vector90
vector90:
  pushl $0
80107d92:	6a 00                	push   $0x0
  pushl $90
80107d94:	6a 5a                	push   $0x5a
  jmp alltraps
80107d96:	e9 e9 f5 ff ff       	jmp    80107384 <alltraps>

80107d9b <vector91>:
.globl vector91
vector91:
  pushl $0
80107d9b:	6a 00                	push   $0x0
  pushl $91
80107d9d:	6a 5b                	push   $0x5b
  jmp alltraps
80107d9f:	e9 e0 f5 ff ff       	jmp    80107384 <alltraps>

80107da4 <vector92>:
.globl vector92
vector92:
  pushl $0
80107da4:	6a 00                	push   $0x0
  pushl $92
80107da6:	6a 5c                	push   $0x5c
  jmp alltraps
80107da8:	e9 d7 f5 ff ff       	jmp    80107384 <alltraps>

80107dad <vector93>:
.globl vector93
vector93:
  pushl $0
80107dad:	6a 00                	push   $0x0
  pushl $93
80107daf:	6a 5d                	push   $0x5d
  jmp alltraps
80107db1:	e9 ce f5 ff ff       	jmp    80107384 <alltraps>

80107db6 <vector94>:
.globl vector94
vector94:
  pushl $0
80107db6:	6a 00                	push   $0x0
  pushl $94
80107db8:	6a 5e                	push   $0x5e
  jmp alltraps
80107dba:	e9 c5 f5 ff ff       	jmp    80107384 <alltraps>

80107dbf <vector95>:
.globl vector95
vector95:
  pushl $0
80107dbf:	6a 00                	push   $0x0
  pushl $95
80107dc1:	6a 5f                	push   $0x5f
  jmp alltraps
80107dc3:	e9 bc f5 ff ff       	jmp    80107384 <alltraps>

80107dc8 <vector96>:
.globl vector96
vector96:
  pushl $0
80107dc8:	6a 00                	push   $0x0
  pushl $96
80107dca:	6a 60                	push   $0x60
  jmp alltraps
80107dcc:	e9 b3 f5 ff ff       	jmp    80107384 <alltraps>

80107dd1 <vector97>:
.globl vector97
vector97:
  pushl $0
80107dd1:	6a 00                	push   $0x0
  pushl $97
80107dd3:	6a 61                	push   $0x61
  jmp alltraps
80107dd5:	e9 aa f5 ff ff       	jmp    80107384 <alltraps>

80107dda <vector98>:
.globl vector98
vector98:
  pushl $0
80107dda:	6a 00                	push   $0x0
  pushl $98
80107ddc:	6a 62                	push   $0x62
  jmp alltraps
80107dde:	e9 a1 f5 ff ff       	jmp    80107384 <alltraps>

80107de3 <vector99>:
.globl vector99
vector99:
  pushl $0
80107de3:	6a 00                	push   $0x0
  pushl $99
80107de5:	6a 63                	push   $0x63
  jmp alltraps
80107de7:	e9 98 f5 ff ff       	jmp    80107384 <alltraps>

80107dec <vector100>:
.globl vector100
vector100:
  pushl $0
80107dec:	6a 00                	push   $0x0
  pushl $100
80107dee:	6a 64                	push   $0x64
  jmp alltraps
80107df0:	e9 8f f5 ff ff       	jmp    80107384 <alltraps>

80107df5 <vector101>:
.globl vector101
vector101:
  pushl $0
80107df5:	6a 00                	push   $0x0
  pushl $101
80107df7:	6a 65                	push   $0x65
  jmp alltraps
80107df9:	e9 86 f5 ff ff       	jmp    80107384 <alltraps>

80107dfe <vector102>:
.globl vector102
vector102:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $102
80107e00:	6a 66                	push   $0x66
  jmp alltraps
80107e02:	e9 7d f5 ff ff       	jmp    80107384 <alltraps>

80107e07 <vector103>:
.globl vector103
vector103:
  pushl $0
80107e07:	6a 00                	push   $0x0
  pushl $103
80107e09:	6a 67                	push   $0x67
  jmp alltraps
80107e0b:	e9 74 f5 ff ff       	jmp    80107384 <alltraps>

80107e10 <vector104>:
.globl vector104
vector104:
  pushl $0
80107e10:	6a 00                	push   $0x0
  pushl $104
80107e12:	6a 68                	push   $0x68
  jmp alltraps
80107e14:	e9 6b f5 ff ff       	jmp    80107384 <alltraps>

80107e19 <vector105>:
.globl vector105
vector105:
  pushl $0
80107e19:	6a 00                	push   $0x0
  pushl $105
80107e1b:	6a 69                	push   $0x69
  jmp alltraps
80107e1d:	e9 62 f5 ff ff       	jmp    80107384 <alltraps>

80107e22 <vector106>:
.globl vector106
vector106:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $106
80107e24:	6a 6a                	push   $0x6a
  jmp alltraps
80107e26:	e9 59 f5 ff ff       	jmp    80107384 <alltraps>

80107e2b <vector107>:
.globl vector107
vector107:
  pushl $0
80107e2b:	6a 00                	push   $0x0
  pushl $107
80107e2d:	6a 6b                	push   $0x6b
  jmp alltraps
80107e2f:	e9 50 f5 ff ff       	jmp    80107384 <alltraps>

80107e34 <vector108>:
.globl vector108
vector108:
  pushl $0
80107e34:	6a 00                	push   $0x0
  pushl $108
80107e36:	6a 6c                	push   $0x6c
  jmp alltraps
80107e38:	e9 47 f5 ff ff       	jmp    80107384 <alltraps>

80107e3d <vector109>:
.globl vector109
vector109:
  pushl $0
80107e3d:	6a 00                	push   $0x0
  pushl $109
80107e3f:	6a 6d                	push   $0x6d
  jmp alltraps
80107e41:	e9 3e f5 ff ff       	jmp    80107384 <alltraps>

80107e46 <vector110>:
.globl vector110
vector110:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $110
80107e48:	6a 6e                	push   $0x6e
  jmp alltraps
80107e4a:	e9 35 f5 ff ff       	jmp    80107384 <alltraps>

80107e4f <vector111>:
.globl vector111
vector111:
  pushl $0
80107e4f:	6a 00                	push   $0x0
  pushl $111
80107e51:	6a 6f                	push   $0x6f
  jmp alltraps
80107e53:	e9 2c f5 ff ff       	jmp    80107384 <alltraps>

80107e58 <vector112>:
.globl vector112
vector112:
  pushl $0
80107e58:	6a 00                	push   $0x0
  pushl $112
80107e5a:	6a 70                	push   $0x70
  jmp alltraps
80107e5c:	e9 23 f5 ff ff       	jmp    80107384 <alltraps>

80107e61 <vector113>:
.globl vector113
vector113:
  pushl $0
80107e61:	6a 00                	push   $0x0
  pushl $113
80107e63:	6a 71                	push   $0x71
  jmp alltraps
80107e65:	e9 1a f5 ff ff       	jmp    80107384 <alltraps>

80107e6a <vector114>:
.globl vector114
vector114:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $114
80107e6c:	6a 72                	push   $0x72
  jmp alltraps
80107e6e:	e9 11 f5 ff ff       	jmp    80107384 <alltraps>

80107e73 <vector115>:
.globl vector115
vector115:
  pushl $0
80107e73:	6a 00                	push   $0x0
  pushl $115
80107e75:	6a 73                	push   $0x73
  jmp alltraps
80107e77:	e9 08 f5 ff ff       	jmp    80107384 <alltraps>

80107e7c <vector116>:
.globl vector116
vector116:
  pushl $0
80107e7c:	6a 00                	push   $0x0
  pushl $116
80107e7e:	6a 74                	push   $0x74
  jmp alltraps
80107e80:	e9 ff f4 ff ff       	jmp    80107384 <alltraps>

80107e85 <vector117>:
.globl vector117
vector117:
  pushl $0
80107e85:	6a 00                	push   $0x0
  pushl $117
80107e87:	6a 75                	push   $0x75
  jmp alltraps
80107e89:	e9 f6 f4 ff ff       	jmp    80107384 <alltraps>

80107e8e <vector118>:
.globl vector118
vector118:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $118
80107e90:	6a 76                	push   $0x76
  jmp alltraps
80107e92:	e9 ed f4 ff ff       	jmp    80107384 <alltraps>

80107e97 <vector119>:
.globl vector119
vector119:
  pushl $0
80107e97:	6a 00                	push   $0x0
  pushl $119
80107e99:	6a 77                	push   $0x77
  jmp alltraps
80107e9b:	e9 e4 f4 ff ff       	jmp    80107384 <alltraps>

80107ea0 <vector120>:
.globl vector120
vector120:
  pushl $0
80107ea0:	6a 00                	push   $0x0
  pushl $120
80107ea2:	6a 78                	push   $0x78
  jmp alltraps
80107ea4:	e9 db f4 ff ff       	jmp    80107384 <alltraps>

80107ea9 <vector121>:
.globl vector121
vector121:
  pushl $0
80107ea9:	6a 00                	push   $0x0
  pushl $121
80107eab:	6a 79                	push   $0x79
  jmp alltraps
80107ead:	e9 d2 f4 ff ff       	jmp    80107384 <alltraps>

80107eb2 <vector122>:
.globl vector122
vector122:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $122
80107eb4:	6a 7a                	push   $0x7a
  jmp alltraps
80107eb6:	e9 c9 f4 ff ff       	jmp    80107384 <alltraps>

80107ebb <vector123>:
.globl vector123
vector123:
  pushl $0
80107ebb:	6a 00                	push   $0x0
  pushl $123
80107ebd:	6a 7b                	push   $0x7b
  jmp alltraps
80107ebf:	e9 c0 f4 ff ff       	jmp    80107384 <alltraps>

80107ec4 <vector124>:
.globl vector124
vector124:
  pushl $0
80107ec4:	6a 00                	push   $0x0
  pushl $124
80107ec6:	6a 7c                	push   $0x7c
  jmp alltraps
80107ec8:	e9 b7 f4 ff ff       	jmp    80107384 <alltraps>

80107ecd <vector125>:
.globl vector125
vector125:
  pushl $0
80107ecd:	6a 00                	push   $0x0
  pushl $125
80107ecf:	6a 7d                	push   $0x7d
  jmp alltraps
80107ed1:	e9 ae f4 ff ff       	jmp    80107384 <alltraps>

80107ed6 <vector126>:
.globl vector126
vector126:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $126
80107ed8:	6a 7e                	push   $0x7e
  jmp alltraps
80107eda:	e9 a5 f4 ff ff       	jmp    80107384 <alltraps>

80107edf <vector127>:
.globl vector127
vector127:
  pushl $0
80107edf:	6a 00                	push   $0x0
  pushl $127
80107ee1:	6a 7f                	push   $0x7f
  jmp alltraps
80107ee3:	e9 9c f4 ff ff       	jmp    80107384 <alltraps>

80107ee8 <vector128>:
.globl vector128
vector128:
  pushl $0
80107ee8:	6a 00                	push   $0x0
  pushl $128
80107eea:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107eef:	e9 90 f4 ff ff       	jmp    80107384 <alltraps>

80107ef4 <vector129>:
.globl vector129
vector129:
  pushl $0
80107ef4:	6a 00                	push   $0x0
  pushl $129
80107ef6:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107efb:	e9 84 f4 ff ff       	jmp    80107384 <alltraps>

80107f00 <vector130>:
.globl vector130
vector130:
  pushl $0
80107f00:	6a 00                	push   $0x0
  pushl $130
80107f02:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107f07:	e9 78 f4 ff ff       	jmp    80107384 <alltraps>

80107f0c <vector131>:
.globl vector131
vector131:
  pushl $0
80107f0c:	6a 00                	push   $0x0
  pushl $131
80107f0e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107f13:	e9 6c f4 ff ff       	jmp    80107384 <alltraps>

80107f18 <vector132>:
.globl vector132
vector132:
  pushl $0
80107f18:	6a 00                	push   $0x0
  pushl $132
80107f1a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107f1f:	e9 60 f4 ff ff       	jmp    80107384 <alltraps>

80107f24 <vector133>:
.globl vector133
vector133:
  pushl $0
80107f24:	6a 00                	push   $0x0
  pushl $133
80107f26:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107f2b:	e9 54 f4 ff ff       	jmp    80107384 <alltraps>

80107f30 <vector134>:
.globl vector134
vector134:
  pushl $0
80107f30:	6a 00                	push   $0x0
  pushl $134
80107f32:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107f37:	e9 48 f4 ff ff       	jmp    80107384 <alltraps>

80107f3c <vector135>:
.globl vector135
vector135:
  pushl $0
80107f3c:	6a 00                	push   $0x0
  pushl $135
80107f3e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107f43:	e9 3c f4 ff ff       	jmp    80107384 <alltraps>

80107f48 <vector136>:
.globl vector136
vector136:
  pushl $0
80107f48:	6a 00                	push   $0x0
  pushl $136
80107f4a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107f4f:	e9 30 f4 ff ff       	jmp    80107384 <alltraps>

80107f54 <vector137>:
.globl vector137
vector137:
  pushl $0
80107f54:	6a 00                	push   $0x0
  pushl $137
80107f56:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107f5b:	e9 24 f4 ff ff       	jmp    80107384 <alltraps>

80107f60 <vector138>:
.globl vector138
vector138:
  pushl $0
80107f60:	6a 00                	push   $0x0
  pushl $138
80107f62:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107f67:	e9 18 f4 ff ff       	jmp    80107384 <alltraps>

80107f6c <vector139>:
.globl vector139
vector139:
  pushl $0
80107f6c:	6a 00                	push   $0x0
  pushl $139
80107f6e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107f73:	e9 0c f4 ff ff       	jmp    80107384 <alltraps>

80107f78 <vector140>:
.globl vector140
vector140:
  pushl $0
80107f78:	6a 00                	push   $0x0
  pushl $140
80107f7a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107f7f:	e9 00 f4 ff ff       	jmp    80107384 <alltraps>

80107f84 <vector141>:
.globl vector141
vector141:
  pushl $0
80107f84:	6a 00                	push   $0x0
  pushl $141
80107f86:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107f8b:	e9 f4 f3 ff ff       	jmp    80107384 <alltraps>

80107f90 <vector142>:
.globl vector142
vector142:
  pushl $0
80107f90:	6a 00                	push   $0x0
  pushl $142
80107f92:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107f97:	e9 e8 f3 ff ff       	jmp    80107384 <alltraps>

80107f9c <vector143>:
.globl vector143
vector143:
  pushl $0
80107f9c:	6a 00                	push   $0x0
  pushl $143
80107f9e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107fa3:	e9 dc f3 ff ff       	jmp    80107384 <alltraps>

80107fa8 <vector144>:
.globl vector144
vector144:
  pushl $0
80107fa8:	6a 00                	push   $0x0
  pushl $144
80107faa:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107faf:	e9 d0 f3 ff ff       	jmp    80107384 <alltraps>

80107fb4 <vector145>:
.globl vector145
vector145:
  pushl $0
80107fb4:	6a 00                	push   $0x0
  pushl $145
80107fb6:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107fbb:	e9 c4 f3 ff ff       	jmp    80107384 <alltraps>

80107fc0 <vector146>:
.globl vector146
vector146:
  pushl $0
80107fc0:	6a 00                	push   $0x0
  pushl $146
80107fc2:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107fc7:	e9 b8 f3 ff ff       	jmp    80107384 <alltraps>

80107fcc <vector147>:
.globl vector147
vector147:
  pushl $0
80107fcc:	6a 00                	push   $0x0
  pushl $147
80107fce:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107fd3:	e9 ac f3 ff ff       	jmp    80107384 <alltraps>

80107fd8 <vector148>:
.globl vector148
vector148:
  pushl $0
80107fd8:	6a 00                	push   $0x0
  pushl $148
80107fda:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107fdf:	e9 a0 f3 ff ff       	jmp    80107384 <alltraps>

80107fe4 <vector149>:
.globl vector149
vector149:
  pushl $0
80107fe4:	6a 00                	push   $0x0
  pushl $149
80107fe6:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107feb:	e9 94 f3 ff ff       	jmp    80107384 <alltraps>

80107ff0 <vector150>:
.globl vector150
vector150:
  pushl $0
80107ff0:	6a 00                	push   $0x0
  pushl $150
80107ff2:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107ff7:	e9 88 f3 ff ff       	jmp    80107384 <alltraps>

80107ffc <vector151>:
.globl vector151
vector151:
  pushl $0
80107ffc:	6a 00                	push   $0x0
  pushl $151
80107ffe:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108003:	e9 7c f3 ff ff       	jmp    80107384 <alltraps>

80108008 <vector152>:
.globl vector152
vector152:
  pushl $0
80108008:	6a 00                	push   $0x0
  pushl $152
8010800a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010800f:	e9 70 f3 ff ff       	jmp    80107384 <alltraps>

80108014 <vector153>:
.globl vector153
vector153:
  pushl $0
80108014:	6a 00                	push   $0x0
  pushl $153
80108016:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010801b:	e9 64 f3 ff ff       	jmp    80107384 <alltraps>

80108020 <vector154>:
.globl vector154
vector154:
  pushl $0
80108020:	6a 00                	push   $0x0
  pushl $154
80108022:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108027:	e9 58 f3 ff ff       	jmp    80107384 <alltraps>

8010802c <vector155>:
.globl vector155
vector155:
  pushl $0
8010802c:	6a 00                	push   $0x0
  pushl $155
8010802e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108033:	e9 4c f3 ff ff       	jmp    80107384 <alltraps>

80108038 <vector156>:
.globl vector156
vector156:
  pushl $0
80108038:	6a 00                	push   $0x0
  pushl $156
8010803a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010803f:	e9 40 f3 ff ff       	jmp    80107384 <alltraps>

80108044 <vector157>:
.globl vector157
vector157:
  pushl $0
80108044:	6a 00                	push   $0x0
  pushl $157
80108046:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010804b:	e9 34 f3 ff ff       	jmp    80107384 <alltraps>

80108050 <vector158>:
.globl vector158
vector158:
  pushl $0
80108050:	6a 00                	push   $0x0
  pushl $158
80108052:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108057:	e9 28 f3 ff ff       	jmp    80107384 <alltraps>

8010805c <vector159>:
.globl vector159
vector159:
  pushl $0
8010805c:	6a 00                	push   $0x0
  pushl $159
8010805e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108063:	e9 1c f3 ff ff       	jmp    80107384 <alltraps>

80108068 <vector160>:
.globl vector160
vector160:
  pushl $0
80108068:	6a 00                	push   $0x0
  pushl $160
8010806a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010806f:	e9 10 f3 ff ff       	jmp    80107384 <alltraps>

80108074 <vector161>:
.globl vector161
vector161:
  pushl $0
80108074:	6a 00                	push   $0x0
  pushl $161
80108076:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010807b:	e9 04 f3 ff ff       	jmp    80107384 <alltraps>

80108080 <vector162>:
.globl vector162
vector162:
  pushl $0
80108080:	6a 00                	push   $0x0
  pushl $162
80108082:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108087:	e9 f8 f2 ff ff       	jmp    80107384 <alltraps>

8010808c <vector163>:
.globl vector163
vector163:
  pushl $0
8010808c:	6a 00                	push   $0x0
  pushl $163
8010808e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108093:	e9 ec f2 ff ff       	jmp    80107384 <alltraps>

80108098 <vector164>:
.globl vector164
vector164:
  pushl $0
80108098:	6a 00                	push   $0x0
  pushl $164
8010809a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010809f:	e9 e0 f2 ff ff       	jmp    80107384 <alltraps>

801080a4 <vector165>:
.globl vector165
vector165:
  pushl $0
801080a4:	6a 00                	push   $0x0
  pushl $165
801080a6:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801080ab:	e9 d4 f2 ff ff       	jmp    80107384 <alltraps>

801080b0 <vector166>:
.globl vector166
vector166:
  pushl $0
801080b0:	6a 00                	push   $0x0
  pushl $166
801080b2:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801080b7:	e9 c8 f2 ff ff       	jmp    80107384 <alltraps>

801080bc <vector167>:
.globl vector167
vector167:
  pushl $0
801080bc:	6a 00                	push   $0x0
  pushl $167
801080be:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801080c3:	e9 bc f2 ff ff       	jmp    80107384 <alltraps>

801080c8 <vector168>:
.globl vector168
vector168:
  pushl $0
801080c8:	6a 00                	push   $0x0
  pushl $168
801080ca:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801080cf:	e9 b0 f2 ff ff       	jmp    80107384 <alltraps>

801080d4 <vector169>:
.globl vector169
vector169:
  pushl $0
801080d4:	6a 00                	push   $0x0
  pushl $169
801080d6:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801080db:	e9 a4 f2 ff ff       	jmp    80107384 <alltraps>

801080e0 <vector170>:
.globl vector170
vector170:
  pushl $0
801080e0:	6a 00                	push   $0x0
  pushl $170
801080e2:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801080e7:	e9 98 f2 ff ff       	jmp    80107384 <alltraps>

801080ec <vector171>:
.globl vector171
vector171:
  pushl $0
801080ec:	6a 00                	push   $0x0
  pushl $171
801080ee:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801080f3:	e9 8c f2 ff ff       	jmp    80107384 <alltraps>

801080f8 <vector172>:
.globl vector172
vector172:
  pushl $0
801080f8:	6a 00                	push   $0x0
  pushl $172
801080fa:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801080ff:	e9 80 f2 ff ff       	jmp    80107384 <alltraps>

80108104 <vector173>:
.globl vector173
vector173:
  pushl $0
80108104:	6a 00                	push   $0x0
  pushl $173
80108106:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010810b:	e9 74 f2 ff ff       	jmp    80107384 <alltraps>

80108110 <vector174>:
.globl vector174
vector174:
  pushl $0
80108110:	6a 00                	push   $0x0
  pushl $174
80108112:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108117:	e9 68 f2 ff ff       	jmp    80107384 <alltraps>

8010811c <vector175>:
.globl vector175
vector175:
  pushl $0
8010811c:	6a 00                	push   $0x0
  pushl $175
8010811e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108123:	e9 5c f2 ff ff       	jmp    80107384 <alltraps>

80108128 <vector176>:
.globl vector176
vector176:
  pushl $0
80108128:	6a 00                	push   $0x0
  pushl $176
8010812a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010812f:	e9 50 f2 ff ff       	jmp    80107384 <alltraps>

80108134 <vector177>:
.globl vector177
vector177:
  pushl $0
80108134:	6a 00                	push   $0x0
  pushl $177
80108136:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010813b:	e9 44 f2 ff ff       	jmp    80107384 <alltraps>

80108140 <vector178>:
.globl vector178
vector178:
  pushl $0
80108140:	6a 00                	push   $0x0
  pushl $178
80108142:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108147:	e9 38 f2 ff ff       	jmp    80107384 <alltraps>

8010814c <vector179>:
.globl vector179
vector179:
  pushl $0
8010814c:	6a 00                	push   $0x0
  pushl $179
8010814e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108153:	e9 2c f2 ff ff       	jmp    80107384 <alltraps>

80108158 <vector180>:
.globl vector180
vector180:
  pushl $0
80108158:	6a 00                	push   $0x0
  pushl $180
8010815a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010815f:	e9 20 f2 ff ff       	jmp    80107384 <alltraps>

80108164 <vector181>:
.globl vector181
vector181:
  pushl $0
80108164:	6a 00                	push   $0x0
  pushl $181
80108166:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010816b:	e9 14 f2 ff ff       	jmp    80107384 <alltraps>

80108170 <vector182>:
.globl vector182
vector182:
  pushl $0
80108170:	6a 00                	push   $0x0
  pushl $182
80108172:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108177:	e9 08 f2 ff ff       	jmp    80107384 <alltraps>

8010817c <vector183>:
.globl vector183
vector183:
  pushl $0
8010817c:	6a 00                	push   $0x0
  pushl $183
8010817e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108183:	e9 fc f1 ff ff       	jmp    80107384 <alltraps>

80108188 <vector184>:
.globl vector184
vector184:
  pushl $0
80108188:	6a 00                	push   $0x0
  pushl $184
8010818a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010818f:	e9 f0 f1 ff ff       	jmp    80107384 <alltraps>

80108194 <vector185>:
.globl vector185
vector185:
  pushl $0
80108194:	6a 00                	push   $0x0
  pushl $185
80108196:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010819b:	e9 e4 f1 ff ff       	jmp    80107384 <alltraps>

801081a0 <vector186>:
.globl vector186
vector186:
  pushl $0
801081a0:	6a 00                	push   $0x0
  pushl $186
801081a2:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801081a7:	e9 d8 f1 ff ff       	jmp    80107384 <alltraps>

801081ac <vector187>:
.globl vector187
vector187:
  pushl $0
801081ac:	6a 00                	push   $0x0
  pushl $187
801081ae:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801081b3:	e9 cc f1 ff ff       	jmp    80107384 <alltraps>

801081b8 <vector188>:
.globl vector188
vector188:
  pushl $0
801081b8:	6a 00                	push   $0x0
  pushl $188
801081ba:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801081bf:	e9 c0 f1 ff ff       	jmp    80107384 <alltraps>

801081c4 <vector189>:
.globl vector189
vector189:
  pushl $0
801081c4:	6a 00                	push   $0x0
  pushl $189
801081c6:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801081cb:	e9 b4 f1 ff ff       	jmp    80107384 <alltraps>

801081d0 <vector190>:
.globl vector190
vector190:
  pushl $0
801081d0:	6a 00                	push   $0x0
  pushl $190
801081d2:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801081d7:	e9 a8 f1 ff ff       	jmp    80107384 <alltraps>

801081dc <vector191>:
.globl vector191
vector191:
  pushl $0
801081dc:	6a 00                	push   $0x0
  pushl $191
801081de:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801081e3:	e9 9c f1 ff ff       	jmp    80107384 <alltraps>

801081e8 <vector192>:
.globl vector192
vector192:
  pushl $0
801081e8:	6a 00                	push   $0x0
  pushl $192
801081ea:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801081ef:	e9 90 f1 ff ff       	jmp    80107384 <alltraps>

801081f4 <vector193>:
.globl vector193
vector193:
  pushl $0
801081f4:	6a 00                	push   $0x0
  pushl $193
801081f6:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801081fb:	e9 84 f1 ff ff       	jmp    80107384 <alltraps>

80108200 <vector194>:
.globl vector194
vector194:
  pushl $0
80108200:	6a 00                	push   $0x0
  pushl $194
80108202:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108207:	e9 78 f1 ff ff       	jmp    80107384 <alltraps>

8010820c <vector195>:
.globl vector195
vector195:
  pushl $0
8010820c:	6a 00                	push   $0x0
  pushl $195
8010820e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108213:	e9 6c f1 ff ff       	jmp    80107384 <alltraps>

80108218 <vector196>:
.globl vector196
vector196:
  pushl $0
80108218:	6a 00                	push   $0x0
  pushl $196
8010821a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010821f:	e9 60 f1 ff ff       	jmp    80107384 <alltraps>

80108224 <vector197>:
.globl vector197
vector197:
  pushl $0
80108224:	6a 00                	push   $0x0
  pushl $197
80108226:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010822b:	e9 54 f1 ff ff       	jmp    80107384 <alltraps>

80108230 <vector198>:
.globl vector198
vector198:
  pushl $0
80108230:	6a 00                	push   $0x0
  pushl $198
80108232:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108237:	e9 48 f1 ff ff       	jmp    80107384 <alltraps>

8010823c <vector199>:
.globl vector199
vector199:
  pushl $0
8010823c:	6a 00                	push   $0x0
  pushl $199
8010823e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108243:	e9 3c f1 ff ff       	jmp    80107384 <alltraps>

80108248 <vector200>:
.globl vector200
vector200:
  pushl $0
80108248:	6a 00                	push   $0x0
  pushl $200
8010824a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010824f:	e9 30 f1 ff ff       	jmp    80107384 <alltraps>

80108254 <vector201>:
.globl vector201
vector201:
  pushl $0
80108254:	6a 00                	push   $0x0
  pushl $201
80108256:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010825b:	e9 24 f1 ff ff       	jmp    80107384 <alltraps>

80108260 <vector202>:
.globl vector202
vector202:
  pushl $0
80108260:	6a 00                	push   $0x0
  pushl $202
80108262:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108267:	e9 18 f1 ff ff       	jmp    80107384 <alltraps>

8010826c <vector203>:
.globl vector203
vector203:
  pushl $0
8010826c:	6a 00                	push   $0x0
  pushl $203
8010826e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108273:	e9 0c f1 ff ff       	jmp    80107384 <alltraps>

80108278 <vector204>:
.globl vector204
vector204:
  pushl $0
80108278:	6a 00                	push   $0x0
  pushl $204
8010827a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010827f:	e9 00 f1 ff ff       	jmp    80107384 <alltraps>

80108284 <vector205>:
.globl vector205
vector205:
  pushl $0
80108284:	6a 00                	push   $0x0
  pushl $205
80108286:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010828b:	e9 f4 f0 ff ff       	jmp    80107384 <alltraps>

80108290 <vector206>:
.globl vector206
vector206:
  pushl $0
80108290:	6a 00                	push   $0x0
  pushl $206
80108292:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108297:	e9 e8 f0 ff ff       	jmp    80107384 <alltraps>

8010829c <vector207>:
.globl vector207
vector207:
  pushl $0
8010829c:	6a 00                	push   $0x0
  pushl $207
8010829e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801082a3:	e9 dc f0 ff ff       	jmp    80107384 <alltraps>

801082a8 <vector208>:
.globl vector208
vector208:
  pushl $0
801082a8:	6a 00                	push   $0x0
  pushl $208
801082aa:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801082af:	e9 d0 f0 ff ff       	jmp    80107384 <alltraps>

801082b4 <vector209>:
.globl vector209
vector209:
  pushl $0
801082b4:	6a 00                	push   $0x0
  pushl $209
801082b6:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801082bb:	e9 c4 f0 ff ff       	jmp    80107384 <alltraps>

801082c0 <vector210>:
.globl vector210
vector210:
  pushl $0
801082c0:	6a 00                	push   $0x0
  pushl $210
801082c2:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801082c7:	e9 b8 f0 ff ff       	jmp    80107384 <alltraps>

801082cc <vector211>:
.globl vector211
vector211:
  pushl $0
801082cc:	6a 00                	push   $0x0
  pushl $211
801082ce:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801082d3:	e9 ac f0 ff ff       	jmp    80107384 <alltraps>

801082d8 <vector212>:
.globl vector212
vector212:
  pushl $0
801082d8:	6a 00                	push   $0x0
  pushl $212
801082da:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801082df:	e9 a0 f0 ff ff       	jmp    80107384 <alltraps>

801082e4 <vector213>:
.globl vector213
vector213:
  pushl $0
801082e4:	6a 00                	push   $0x0
  pushl $213
801082e6:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801082eb:	e9 94 f0 ff ff       	jmp    80107384 <alltraps>

801082f0 <vector214>:
.globl vector214
vector214:
  pushl $0
801082f0:	6a 00                	push   $0x0
  pushl $214
801082f2:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801082f7:	e9 88 f0 ff ff       	jmp    80107384 <alltraps>

801082fc <vector215>:
.globl vector215
vector215:
  pushl $0
801082fc:	6a 00                	push   $0x0
  pushl $215
801082fe:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108303:	e9 7c f0 ff ff       	jmp    80107384 <alltraps>

80108308 <vector216>:
.globl vector216
vector216:
  pushl $0
80108308:	6a 00                	push   $0x0
  pushl $216
8010830a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010830f:	e9 70 f0 ff ff       	jmp    80107384 <alltraps>

80108314 <vector217>:
.globl vector217
vector217:
  pushl $0
80108314:	6a 00                	push   $0x0
  pushl $217
80108316:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010831b:	e9 64 f0 ff ff       	jmp    80107384 <alltraps>

80108320 <vector218>:
.globl vector218
vector218:
  pushl $0
80108320:	6a 00                	push   $0x0
  pushl $218
80108322:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108327:	e9 58 f0 ff ff       	jmp    80107384 <alltraps>

8010832c <vector219>:
.globl vector219
vector219:
  pushl $0
8010832c:	6a 00                	push   $0x0
  pushl $219
8010832e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108333:	e9 4c f0 ff ff       	jmp    80107384 <alltraps>

80108338 <vector220>:
.globl vector220
vector220:
  pushl $0
80108338:	6a 00                	push   $0x0
  pushl $220
8010833a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010833f:	e9 40 f0 ff ff       	jmp    80107384 <alltraps>

80108344 <vector221>:
.globl vector221
vector221:
  pushl $0
80108344:	6a 00                	push   $0x0
  pushl $221
80108346:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010834b:	e9 34 f0 ff ff       	jmp    80107384 <alltraps>

80108350 <vector222>:
.globl vector222
vector222:
  pushl $0
80108350:	6a 00                	push   $0x0
  pushl $222
80108352:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108357:	e9 28 f0 ff ff       	jmp    80107384 <alltraps>

8010835c <vector223>:
.globl vector223
vector223:
  pushl $0
8010835c:	6a 00                	push   $0x0
  pushl $223
8010835e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108363:	e9 1c f0 ff ff       	jmp    80107384 <alltraps>

80108368 <vector224>:
.globl vector224
vector224:
  pushl $0
80108368:	6a 00                	push   $0x0
  pushl $224
8010836a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010836f:	e9 10 f0 ff ff       	jmp    80107384 <alltraps>

80108374 <vector225>:
.globl vector225
vector225:
  pushl $0
80108374:	6a 00                	push   $0x0
  pushl $225
80108376:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010837b:	e9 04 f0 ff ff       	jmp    80107384 <alltraps>

80108380 <vector226>:
.globl vector226
vector226:
  pushl $0
80108380:	6a 00                	push   $0x0
  pushl $226
80108382:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108387:	e9 f8 ef ff ff       	jmp    80107384 <alltraps>

8010838c <vector227>:
.globl vector227
vector227:
  pushl $0
8010838c:	6a 00                	push   $0x0
  pushl $227
8010838e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108393:	e9 ec ef ff ff       	jmp    80107384 <alltraps>

80108398 <vector228>:
.globl vector228
vector228:
  pushl $0
80108398:	6a 00                	push   $0x0
  pushl $228
8010839a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010839f:	e9 e0 ef ff ff       	jmp    80107384 <alltraps>

801083a4 <vector229>:
.globl vector229
vector229:
  pushl $0
801083a4:	6a 00                	push   $0x0
  pushl $229
801083a6:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801083ab:	e9 d4 ef ff ff       	jmp    80107384 <alltraps>

801083b0 <vector230>:
.globl vector230
vector230:
  pushl $0
801083b0:	6a 00                	push   $0x0
  pushl $230
801083b2:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801083b7:	e9 c8 ef ff ff       	jmp    80107384 <alltraps>

801083bc <vector231>:
.globl vector231
vector231:
  pushl $0
801083bc:	6a 00                	push   $0x0
  pushl $231
801083be:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801083c3:	e9 bc ef ff ff       	jmp    80107384 <alltraps>

801083c8 <vector232>:
.globl vector232
vector232:
  pushl $0
801083c8:	6a 00                	push   $0x0
  pushl $232
801083ca:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801083cf:	e9 b0 ef ff ff       	jmp    80107384 <alltraps>

801083d4 <vector233>:
.globl vector233
vector233:
  pushl $0
801083d4:	6a 00                	push   $0x0
  pushl $233
801083d6:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801083db:	e9 a4 ef ff ff       	jmp    80107384 <alltraps>

801083e0 <vector234>:
.globl vector234
vector234:
  pushl $0
801083e0:	6a 00                	push   $0x0
  pushl $234
801083e2:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801083e7:	e9 98 ef ff ff       	jmp    80107384 <alltraps>

801083ec <vector235>:
.globl vector235
vector235:
  pushl $0
801083ec:	6a 00                	push   $0x0
  pushl $235
801083ee:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801083f3:	e9 8c ef ff ff       	jmp    80107384 <alltraps>

801083f8 <vector236>:
.globl vector236
vector236:
  pushl $0
801083f8:	6a 00                	push   $0x0
  pushl $236
801083fa:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801083ff:	e9 80 ef ff ff       	jmp    80107384 <alltraps>

80108404 <vector237>:
.globl vector237
vector237:
  pushl $0
80108404:	6a 00                	push   $0x0
  pushl $237
80108406:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010840b:	e9 74 ef ff ff       	jmp    80107384 <alltraps>

80108410 <vector238>:
.globl vector238
vector238:
  pushl $0
80108410:	6a 00                	push   $0x0
  pushl $238
80108412:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108417:	e9 68 ef ff ff       	jmp    80107384 <alltraps>

8010841c <vector239>:
.globl vector239
vector239:
  pushl $0
8010841c:	6a 00                	push   $0x0
  pushl $239
8010841e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108423:	e9 5c ef ff ff       	jmp    80107384 <alltraps>

80108428 <vector240>:
.globl vector240
vector240:
  pushl $0
80108428:	6a 00                	push   $0x0
  pushl $240
8010842a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010842f:	e9 50 ef ff ff       	jmp    80107384 <alltraps>

80108434 <vector241>:
.globl vector241
vector241:
  pushl $0
80108434:	6a 00                	push   $0x0
  pushl $241
80108436:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010843b:	e9 44 ef ff ff       	jmp    80107384 <alltraps>

80108440 <vector242>:
.globl vector242
vector242:
  pushl $0
80108440:	6a 00                	push   $0x0
  pushl $242
80108442:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108447:	e9 38 ef ff ff       	jmp    80107384 <alltraps>

8010844c <vector243>:
.globl vector243
vector243:
  pushl $0
8010844c:	6a 00                	push   $0x0
  pushl $243
8010844e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108453:	e9 2c ef ff ff       	jmp    80107384 <alltraps>

80108458 <vector244>:
.globl vector244
vector244:
  pushl $0
80108458:	6a 00                	push   $0x0
  pushl $244
8010845a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010845f:	e9 20 ef ff ff       	jmp    80107384 <alltraps>

80108464 <vector245>:
.globl vector245
vector245:
  pushl $0
80108464:	6a 00                	push   $0x0
  pushl $245
80108466:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010846b:	e9 14 ef ff ff       	jmp    80107384 <alltraps>

80108470 <vector246>:
.globl vector246
vector246:
  pushl $0
80108470:	6a 00                	push   $0x0
  pushl $246
80108472:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108477:	e9 08 ef ff ff       	jmp    80107384 <alltraps>

8010847c <vector247>:
.globl vector247
vector247:
  pushl $0
8010847c:	6a 00                	push   $0x0
  pushl $247
8010847e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108483:	e9 fc ee ff ff       	jmp    80107384 <alltraps>

80108488 <vector248>:
.globl vector248
vector248:
  pushl $0
80108488:	6a 00                	push   $0x0
  pushl $248
8010848a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010848f:	e9 f0 ee ff ff       	jmp    80107384 <alltraps>

80108494 <vector249>:
.globl vector249
vector249:
  pushl $0
80108494:	6a 00                	push   $0x0
  pushl $249
80108496:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010849b:	e9 e4 ee ff ff       	jmp    80107384 <alltraps>

801084a0 <vector250>:
.globl vector250
vector250:
  pushl $0
801084a0:	6a 00                	push   $0x0
  pushl $250
801084a2:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801084a7:	e9 d8 ee ff ff       	jmp    80107384 <alltraps>

801084ac <vector251>:
.globl vector251
vector251:
  pushl $0
801084ac:	6a 00                	push   $0x0
  pushl $251
801084ae:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801084b3:	e9 cc ee ff ff       	jmp    80107384 <alltraps>

801084b8 <vector252>:
.globl vector252
vector252:
  pushl $0
801084b8:	6a 00                	push   $0x0
  pushl $252
801084ba:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801084bf:	e9 c0 ee ff ff       	jmp    80107384 <alltraps>

801084c4 <vector253>:
.globl vector253
vector253:
  pushl $0
801084c4:	6a 00                	push   $0x0
  pushl $253
801084c6:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801084cb:	e9 b4 ee ff ff       	jmp    80107384 <alltraps>

801084d0 <vector254>:
.globl vector254
vector254:
  pushl $0
801084d0:	6a 00                	push   $0x0
  pushl $254
801084d2:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801084d7:	e9 a8 ee ff ff       	jmp    80107384 <alltraps>

801084dc <vector255>:
.globl vector255
vector255:
  pushl $0
801084dc:	6a 00                	push   $0x0
  pushl $255
801084de:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801084e3:	e9 9c ee ff ff       	jmp    80107384 <alltraps>

801084e8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801084e8:	55                   	push   %ebp
801084e9:	89 e5                	mov    %esp,%ebp
801084eb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801084ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801084f1:	83 e8 01             	sub    $0x1,%eax
801084f4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801084f8:	8b 45 08             	mov    0x8(%ebp),%eax
801084fb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801084ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108502:	c1 e8 10             	shr    $0x10,%eax
80108505:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108509:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010850c:	0f 01 10             	lgdtl  (%eax)
}
8010850f:	90                   	nop
80108510:	c9                   	leave  
80108511:	c3                   	ret    

80108512 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108512:	55                   	push   %ebp
80108513:	89 e5                	mov    %esp,%ebp
80108515:	83 ec 04             	sub    $0x4,%esp
80108518:	8b 45 08             	mov    0x8(%ebp),%eax
8010851b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010851f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108523:	0f 00 d8             	ltr    %ax
}
80108526:	90                   	nop
80108527:	c9                   	leave  
80108528:	c3                   	ret    

80108529 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108529:	55                   	push   %ebp
8010852a:	89 e5                	mov    %esp,%ebp
8010852c:	83 ec 04             	sub    $0x4,%esp
8010852f:	8b 45 08             	mov    0x8(%ebp),%eax
80108532:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108536:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010853a:	8e e8                	mov    %eax,%gs
}
8010853c:	90                   	nop
8010853d:	c9                   	leave  
8010853e:	c3                   	ret    

8010853f <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010853f:	55                   	push   %ebp
80108540:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108542:	8b 45 08             	mov    0x8(%ebp),%eax
80108545:	0f 22 d8             	mov    %eax,%cr3
}
80108548:	90                   	nop
80108549:	5d                   	pop    %ebp
8010854a:	c3                   	ret    

8010854b <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010854b:	55                   	push   %ebp
8010854c:	89 e5                	mov    %esp,%ebp
8010854e:	8b 45 08             	mov    0x8(%ebp),%eax
80108551:	05 00 00 00 80       	add    $0x80000000,%eax
80108556:	5d                   	pop    %ebp
80108557:	c3                   	ret    

80108558 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108558:	55                   	push   %ebp
80108559:	89 e5                	mov    %esp,%ebp
8010855b:	8b 45 08             	mov    0x8(%ebp),%eax
8010855e:	05 00 00 00 80       	add    $0x80000000,%eax
80108563:	5d                   	pop    %ebp
80108564:	c3                   	ret    

80108565 <seginit>:
void insertNewPage(char *va);
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108565:	55                   	push   %ebp
80108566:	89 e5                	mov    %esp,%ebp
80108568:	53                   	push   %ebx
80108569:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010856c:	e8 51 b2 ff ff       	call   801037c2 <cpunum>
80108571:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108577:	05 80 43 11 80       	add    $0x80114380,%eax
8010857c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010857f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108582:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108594:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010859f:	83 e2 f0             	and    $0xfffffff0,%edx
801085a2:	83 ca 0a             	or     $0xa,%edx
801085a5:	88 50 7d             	mov    %dl,0x7d(%eax)
801085a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ab:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085af:	83 ca 10             	or     $0x10,%edx
801085b2:	88 50 7d             	mov    %dl,0x7d(%eax)
801085b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085bc:	83 e2 9f             	and    $0xffffff9f,%edx
801085bf:	88 50 7d             	mov    %dl,0x7d(%eax)
801085c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085c9:	83 ca 80             	or     $0xffffff80,%edx
801085cc:	88 50 7d             	mov    %dl,0x7d(%eax)
801085cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801085d6:	83 ca 0f             	or     $0xf,%edx
801085d9:	88 50 7e             	mov    %dl,0x7e(%eax)
801085dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085df:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801085e3:	83 e2 ef             	and    $0xffffffef,%edx
801085e6:	88 50 7e             	mov    %dl,0x7e(%eax)
801085e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ec:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801085f0:	83 e2 df             	and    $0xffffffdf,%edx
801085f3:	88 50 7e             	mov    %dl,0x7e(%eax)
801085f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801085fd:	83 ca 40             	or     $0x40,%edx
80108600:	88 50 7e             	mov    %dl,0x7e(%eax)
80108603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108606:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010860a:	83 ca 80             	or     $0xffffff80,%edx
8010860d:	88 50 7e             	mov    %dl,0x7e(%eax)
80108610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108613:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108621:	ff ff 
80108623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108626:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010862d:	00 00 
8010862f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108632:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108643:	83 e2 f0             	and    $0xfffffff0,%edx
80108646:	83 ca 02             	or     $0x2,%edx
80108649:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010864f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108652:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108659:	83 ca 10             	or     $0x10,%edx
8010865c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108665:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010866c:	83 e2 9f             	and    $0xffffff9f,%edx
8010866f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108678:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010867f:	83 ca 80             	or     $0xffffff80,%edx
80108682:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108692:	83 ca 0f             	or     $0xf,%edx
80108695:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010869b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086a5:	83 e2 ef             	and    $0xffffffef,%edx
801086a8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086b8:	83 e2 df             	and    $0xffffffdf,%edx
801086bb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086cb:	83 ca 40             	or     $0x40,%edx
801086ce:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086de:	83 ca 80             	or     $0xffffff80,%edx
801086e1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ea:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801086f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f4:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801086fb:	ff ff 
801086fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108700:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108707:	00 00 
80108709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108716:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010871d:	83 e2 f0             	and    $0xfffffff0,%edx
80108720:	83 ca 0a             	or     $0xa,%edx
80108723:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108733:	83 ca 10             	or     $0x10,%edx
80108736:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010873c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108746:	83 ca 60             	or     $0x60,%edx
80108749:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010874f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108752:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108759:	83 ca 80             	or     $0xffffff80,%edx
8010875c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108765:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010876c:	83 ca 0f             	or     $0xf,%edx
8010876f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108778:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010877f:	83 e2 ef             	and    $0xffffffef,%edx
80108782:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108792:	83 e2 df             	and    $0xffffffdf,%edx
80108795:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010879b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087a5:	83 ca 40             	or     $0x40,%edx
801087a8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087b8:	83 ca 80             	or     $0xffffff80,%edx
801087bb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c4:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801087cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ce:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801087d5:	ff ff 
801087d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087da:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801087e1:	00 00 
801087e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e6:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801087ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801087f7:	83 e2 f0             	and    $0xfffffff0,%edx
801087fa:	83 ca 02             	or     $0x2,%edx
801087fd:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108806:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010880d:	83 ca 10             	or     $0x10,%edx
80108810:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108819:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108820:	83 ca 60             	or     $0x60,%edx
80108823:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108833:	83 ca 80             	or     $0xffffff80,%edx
80108836:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010883c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108846:	83 ca 0f             	or     $0xf,%edx
80108849:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010884f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108852:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108859:	83 e2 ef             	and    $0xffffffef,%edx
8010885c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108865:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010886c:	83 e2 df             	and    $0xffffffdf,%edx
8010886f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108878:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010887f:	83 ca 40             	or     $0x40,%edx
80108882:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108892:	83 ca 80             	or     $0xffffff80,%edx
80108895:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010889b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889e:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801088a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a8:	05 b4 00 00 00       	add    $0xb4,%eax
801088ad:	89 c3                	mov    %eax,%ebx
801088af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b2:	05 b4 00 00 00       	add    $0xb4,%eax
801088b7:	c1 e8 10             	shr    $0x10,%eax
801088ba:	89 c2                	mov    %eax,%edx
801088bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088bf:	05 b4 00 00 00       	add    $0xb4,%eax
801088c4:	c1 e8 18             	shr    $0x18,%eax
801088c7:	89 c1                	mov    %eax,%ecx
801088c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cc:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801088d3:	00 00 
801088d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d8:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801088df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e2:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801088e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088eb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801088f2:	83 e2 f0             	and    $0xfffffff0,%edx
801088f5:	83 ca 02             	or     $0x2,%edx
801088f8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108901:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108908:	83 ca 10             	or     $0x10,%edx
8010890b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108914:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010891b:	83 e2 9f             	and    $0xffffff9f,%edx
8010891e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108927:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010892e:	83 ca 80             	or     $0xffffff80,%edx
80108931:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108941:	83 e2 f0             	and    $0xfffffff0,%edx
80108944:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010894a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108954:	83 e2 ef             	and    $0xffffffef,%edx
80108957:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010895d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108960:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108967:	83 e2 df             	and    $0xffffffdf,%edx
8010896a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108973:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010897a:	83 ca 40             	or     $0x40,%edx
8010897d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108986:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010898d:	83 ca 80             	or     $0xffffff80,%edx
80108990:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108999:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010899f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a2:	83 c0 70             	add    $0x70,%eax
801089a5:	83 ec 08             	sub    $0x8,%esp
801089a8:	6a 38                	push   $0x38
801089aa:	50                   	push   %eax
801089ab:	e8 38 fb ff ff       	call   801084e8 <lgdt>
801089b0:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801089b3:	83 ec 0c             	sub    $0xc,%esp
801089b6:	6a 18                	push   $0x18
801089b8:	e8 6c fb ff ff       	call   80108529 <loadgs>
801089bd:	83 c4 10             	add    $0x10,%esp

  // Initialize cpu-local storage.
  cpu = c;
801089c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c3:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801089c9:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801089d0:	00 00 00 00 
}
801089d4:	90                   	nop
801089d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089d8:	c9                   	leave  
801089d9:	c3                   	ret    

801089da <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801089da:	55                   	push   %ebp
801089db:	89 e5                	mov    %esp,%ebp
801089dd:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801089e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e3:	c1 e8 16             	shr    $0x16,%eax
801089e6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089ed:	8b 45 08             	mov    0x8(%ebp),%eax
801089f0:	01 d0                	add    %edx,%eax
801089f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801089f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089f8:	8b 00                	mov    (%eax),%eax
801089fa:	83 e0 01             	and    $0x1,%eax
801089fd:	85 c0                	test   %eax,%eax
801089ff:	74 18                	je     80108a19 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a04:	8b 00                	mov    (%eax),%eax
80108a06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a0b:	50                   	push   %eax
80108a0c:	e8 47 fb ff ff       	call   80108558 <p2v>
80108a11:	83 c4 04             	add    $0x4,%esp
80108a14:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a17:	eb 48                	jmp    80108a61 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108a19:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108a1d:	74 0e                	je     80108a2d <walkpgdir+0x53>
80108a1f:	e8 2b aa ff ff       	call   8010344f <kalloc>
80108a24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a2b:	75 07                	jne    80108a34 <walkpgdir+0x5a>
      return 0;
80108a2d:	b8 00 00 00 00       	mov    $0x0,%eax
80108a32:	eb 44                	jmp    80108a78 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108a34:	83 ec 04             	sub    $0x4,%esp
80108a37:	68 00 10 00 00       	push   $0x1000
80108a3c:	6a 00                	push   $0x0
80108a3e:	ff 75 f4             	pushl  -0xc(%ebp)
80108a41:	e8 84 d5 ff ff       	call   80105fca <memset>
80108a46:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108a49:	83 ec 0c             	sub    $0xc,%esp
80108a4c:	ff 75 f4             	pushl  -0xc(%ebp)
80108a4f:	e8 f7 fa ff ff       	call   8010854b <v2p>
80108a54:	83 c4 10             	add    $0x10,%esp
80108a57:	83 c8 07             	or     $0x7,%eax
80108a5a:	89 c2                	mov    %eax,%edx
80108a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108a61:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a64:	c1 e8 0c             	shr    $0xc,%eax
80108a67:	25 ff 03 00 00       	and    $0x3ff,%eax
80108a6c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a76:	01 d0                	add    %edx,%eax
}
80108a78:	c9                   	leave  
80108a79:	c3                   	ret    

80108a7a <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108a7a:	55                   	push   %ebp
80108a7b:	89 e5                	mov    %esp,%ebp
80108a7d:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108a80:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a8e:	8b 45 10             	mov    0x10(%ebp),%eax
80108a91:	01 d0                	add    %edx,%eax
80108a93:	83 e8 01             	sub    $0x1,%eax
80108a96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108a9e:	83 ec 04             	sub    $0x4,%esp
80108aa1:	6a 01                	push   $0x1
80108aa3:	ff 75 f4             	pushl  -0xc(%ebp)
80108aa6:	ff 75 08             	pushl  0x8(%ebp)
80108aa9:	e8 2c ff ff ff       	call   801089da <walkpgdir>
80108aae:	83 c4 10             	add    $0x10,%esp
80108ab1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108ab4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108ab8:	75 07                	jne    80108ac1 <mappages+0x47>
      return -1;
80108aba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108abf:	eb 47                	jmp    80108b08 <mappages+0x8e>
    if(*pte & PTE_P)
80108ac1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ac4:	8b 00                	mov    (%eax),%eax
80108ac6:	83 e0 01             	and    $0x1,%eax
80108ac9:	85 c0                	test   %eax,%eax
80108acb:	74 0d                	je     80108ada <mappages+0x60>
      panic("remap");
80108acd:	83 ec 0c             	sub    $0xc,%esp
80108ad0:	68 c4 a4 10 80       	push   $0x8010a4c4
80108ad5:	e8 8c 7a ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108ada:	8b 45 18             	mov    0x18(%ebp),%eax
80108add:	0b 45 14             	or     0x14(%ebp),%eax
80108ae0:	83 c8 01             	or     $0x1,%eax
80108ae3:	89 c2                	mov    %eax,%edx
80108ae5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ae8:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aed:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108af0:	74 10                	je     80108b02 <mappages+0x88>
      break;
    a += PGSIZE;
80108af2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108af9:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108b00:	eb 9c                	jmp    80108a9e <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108b02:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108b03:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b08:	c9                   	leave  
80108b09:	c3                   	ret    

80108b0a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108b0a:	55                   	push   %ebp
80108b0b:	89 e5                	mov    %esp,%ebp
80108b0d:	53                   	push   %ebx
80108b0e:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108b11:	e8 39 a9 ff ff       	call   8010344f <kalloc>
80108b16:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b1d:	75 0a                	jne    80108b29 <setupkvm+0x1f>
    return 0;
80108b1f:	b8 00 00 00 00       	mov    $0x0,%eax
80108b24:	e9 8e 00 00 00       	jmp    80108bb7 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108b29:	83 ec 04             	sub    $0x4,%esp
80108b2c:	68 00 10 00 00       	push   $0x1000
80108b31:	6a 00                	push   $0x0
80108b33:	ff 75 f0             	pushl  -0x10(%ebp)
80108b36:	e8 8f d4 ff ff       	call   80105fca <memset>
80108b3b:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108b3e:	83 ec 0c             	sub    $0xc,%esp
80108b41:	68 00 00 00 0e       	push   $0xe000000
80108b46:	e8 0d fa ff ff       	call   80108558 <p2v>
80108b4b:	83 c4 10             	add    $0x10,%esp
80108b4e:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108b53:	76 0d                	jbe    80108b62 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108b55:	83 ec 0c             	sub    $0xc,%esp
80108b58:	68 ca a4 10 80       	push   $0x8010a4ca
80108b5d:	e8 04 7a ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b62:	c7 45 f4 a0 d4 10 80 	movl   $0x8010d4a0,-0xc(%ebp)
80108b69:	eb 40                	jmp    80108bab <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b6e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b74:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7a:	8b 58 08             	mov    0x8(%eax),%ebx
80108b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b80:	8b 40 04             	mov    0x4(%eax),%eax
80108b83:	29 c3                	sub    %eax,%ebx
80108b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b88:	8b 00                	mov    (%eax),%eax
80108b8a:	83 ec 0c             	sub    $0xc,%esp
80108b8d:	51                   	push   %ecx
80108b8e:	52                   	push   %edx
80108b8f:	53                   	push   %ebx
80108b90:	50                   	push   %eax
80108b91:	ff 75 f0             	pushl  -0x10(%ebp)
80108b94:	e8 e1 fe ff ff       	call   80108a7a <mappages>
80108b99:	83 c4 20             	add    $0x20,%esp
80108b9c:	85 c0                	test   %eax,%eax
80108b9e:	79 07                	jns    80108ba7 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108ba0:	b8 00 00 00 00       	mov    $0x0,%eax
80108ba5:	eb 10                	jmp    80108bb7 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108ba7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108bab:	81 7d f4 e0 d4 10 80 	cmpl   $0x8010d4e0,-0xc(%ebp)
80108bb2:	72 b7                	jb     80108b6b <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108bb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108bba:	c9                   	leave  
80108bbb:	c3                   	ret    

80108bbc <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108bbc:	55                   	push   %ebp
80108bbd:	89 e5                	mov    %esp,%ebp
80108bbf:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108bc2:	e8 43 ff ff ff       	call   80108b0a <setupkvm>
80108bc7:	a3 58 c3 11 80       	mov    %eax,0x8011c358
  switchkvm();
80108bcc:	e8 03 00 00 00       	call   80108bd4 <switchkvm>
}
80108bd1:	90                   	nop
80108bd2:	c9                   	leave  
80108bd3:	c3                   	ret    

80108bd4 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108bd4:	55                   	push   %ebp
80108bd5:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108bd7:	a1 58 c3 11 80       	mov    0x8011c358,%eax
80108bdc:	50                   	push   %eax
80108bdd:	e8 69 f9 ff ff       	call   8010854b <v2p>
80108be2:	83 c4 04             	add    $0x4,%esp
80108be5:	50                   	push   %eax
80108be6:	e8 54 f9 ff ff       	call   8010853f <lcr3>
80108beb:	83 c4 04             	add    $0x4,%esp
}
80108bee:	90                   	nop
80108bef:	c9                   	leave  
80108bf0:	c3                   	ret    

80108bf1 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108bf1:	55                   	push   %ebp
80108bf2:	89 e5                	mov    %esp,%ebp
80108bf4:	56                   	push   %esi
80108bf5:	53                   	push   %ebx
  pushcli();
80108bf6:	e8 c9 d2 ff ff       	call   80105ec4 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108bfb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c01:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c08:	83 c2 08             	add    $0x8,%edx
80108c0b:	89 d6                	mov    %edx,%esi
80108c0d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c14:	83 c2 08             	add    $0x8,%edx
80108c17:	c1 ea 10             	shr    $0x10,%edx
80108c1a:	89 d3                	mov    %edx,%ebx
80108c1c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c23:	83 c2 08             	add    $0x8,%edx
80108c26:	c1 ea 18             	shr    $0x18,%edx
80108c29:	89 d1                	mov    %edx,%ecx
80108c2b:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108c32:	67 00 
80108c34:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108c3b:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108c41:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c48:	83 e2 f0             	and    $0xfffffff0,%edx
80108c4b:	83 ca 09             	or     $0x9,%edx
80108c4e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c54:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c5b:	83 ca 10             	or     $0x10,%edx
80108c5e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c64:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c6b:	83 e2 9f             	and    $0xffffff9f,%edx
80108c6e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c74:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c7b:	83 ca 80             	or     $0xffffff80,%edx
80108c7e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c84:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c8b:	83 e2 f0             	and    $0xfffffff0,%edx
80108c8e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c94:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c9b:	83 e2 ef             	and    $0xffffffef,%edx
80108c9e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108ca4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cab:	83 e2 df             	and    $0xffffffdf,%edx
80108cae:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cb4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cbb:	83 ca 40             	or     $0x40,%edx
80108cbe:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cc4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ccb:	83 e2 7f             	and    $0x7f,%edx
80108cce:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cd4:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108cda:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ce0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ce7:	83 e2 ef             	and    $0xffffffef,%edx
80108cea:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108cf0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108cf6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108cfc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d02:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d09:	8b 52 08             	mov    0x8(%edx),%edx
80108d0c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108d12:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108d15:	83 ec 0c             	sub    $0xc,%esp
80108d18:	6a 30                	push   $0x30
80108d1a:	e8 f3 f7 ff ff       	call   80108512 <ltr>
80108d1f:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108d22:	8b 45 08             	mov    0x8(%ebp),%eax
80108d25:	8b 40 04             	mov    0x4(%eax),%eax
80108d28:	85 c0                	test   %eax,%eax
80108d2a:	75 0d                	jne    80108d39 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108d2c:	83 ec 0c             	sub    $0xc,%esp
80108d2f:	68 db a4 10 80       	push   $0x8010a4db
80108d34:	e8 2d 78 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108d39:	8b 45 08             	mov    0x8(%ebp),%eax
80108d3c:	8b 40 04             	mov    0x4(%eax),%eax
80108d3f:	83 ec 0c             	sub    $0xc,%esp
80108d42:	50                   	push   %eax
80108d43:	e8 03 f8 ff ff       	call   8010854b <v2p>
80108d48:	83 c4 10             	add    $0x10,%esp
80108d4b:	83 ec 0c             	sub    $0xc,%esp
80108d4e:	50                   	push   %eax
80108d4f:	e8 eb f7 ff ff       	call   8010853f <lcr3>
80108d54:	83 c4 10             	add    $0x10,%esp
  popcli();
80108d57:	e8 ad d1 ff ff       	call   80105f09 <popcli>
}
80108d5c:	90                   	nop
80108d5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108d60:	5b                   	pop    %ebx
80108d61:	5e                   	pop    %esi
80108d62:	5d                   	pop    %ebp
80108d63:	c3                   	ret    

80108d64 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108d64:	55                   	push   %ebp
80108d65:	89 e5                	mov    %esp,%ebp
80108d67:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108d6a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108d71:	76 0d                	jbe    80108d80 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108d73:	83 ec 0c             	sub    $0xc,%esp
80108d76:	68 ef a4 10 80       	push   $0x8010a4ef
80108d7b:	e8 e6 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108d80:	e8 ca a6 ff ff       	call   8010344f <kalloc>
80108d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108d88:	83 ec 04             	sub    $0x4,%esp
80108d8b:	68 00 10 00 00       	push   $0x1000
80108d90:	6a 00                	push   $0x0
80108d92:	ff 75 f4             	pushl  -0xc(%ebp)
80108d95:	e8 30 d2 ff ff       	call   80105fca <memset>
80108d9a:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108d9d:	83 ec 0c             	sub    $0xc,%esp
80108da0:	ff 75 f4             	pushl  -0xc(%ebp)
80108da3:	e8 a3 f7 ff ff       	call   8010854b <v2p>
80108da8:	83 c4 10             	add    $0x10,%esp
80108dab:	83 ec 0c             	sub    $0xc,%esp
80108dae:	6a 06                	push   $0x6
80108db0:	50                   	push   %eax
80108db1:	68 00 10 00 00       	push   $0x1000
80108db6:	6a 00                	push   $0x0
80108db8:	ff 75 08             	pushl  0x8(%ebp)
80108dbb:	e8 ba fc ff ff       	call   80108a7a <mappages>
80108dc0:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108dc3:	83 ec 04             	sub    $0x4,%esp
80108dc6:	ff 75 10             	pushl  0x10(%ebp)
80108dc9:	ff 75 0c             	pushl  0xc(%ebp)
80108dcc:	ff 75 f4             	pushl  -0xc(%ebp)
80108dcf:	e8 b5 d2 ff ff       	call   80106089 <memmove>
80108dd4:	83 c4 10             	add    $0x10,%esp
}
80108dd7:	90                   	nop
80108dd8:	c9                   	leave  
80108dd9:	c3                   	ret    

80108dda <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108dda:	55                   	push   %ebp
80108ddb:	89 e5                	mov    %esp,%ebp
80108ddd:	53                   	push   %ebx
80108dde:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108de1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108de4:	25 ff 0f 00 00       	and    $0xfff,%eax
80108de9:	85 c0                	test   %eax,%eax
80108deb:	74 0d                	je     80108dfa <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108ded:	83 ec 0c             	sub    $0xc,%esp
80108df0:	68 0c a5 10 80       	push   $0x8010a50c
80108df5:	e8 6c 77 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108dfa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e01:	e9 95 00 00 00       	jmp    80108e9b <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108e06:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e0c:	01 d0                	add    %edx,%eax
80108e0e:	83 ec 04             	sub    $0x4,%esp
80108e11:	6a 00                	push   $0x0
80108e13:	50                   	push   %eax
80108e14:	ff 75 08             	pushl  0x8(%ebp)
80108e17:	e8 be fb ff ff       	call   801089da <walkpgdir>
80108e1c:	83 c4 10             	add    $0x10,%esp
80108e1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e22:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e26:	75 0d                	jne    80108e35 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108e28:	83 ec 0c             	sub    $0xc,%esp
80108e2b:	68 2f a5 10 80       	push   $0x8010a52f
80108e30:	e8 31 77 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108e35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e38:	8b 00                	mov    (%eax),%eax
80108e3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108e42:	8b 45 18             	mov    0x18(%ebp),%eax
80108e45:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108e48:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108e4d:	77 0b                	ja     80108e5a <loaduvm+0x80>
      n = sz - i;
80108e4f:	8b 45 18             	mov    0x18(%ebp),%eax
80108e52:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108e55:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108e58:	eb 07                	jmp    80108e61 <loaduvm+0x87>
    else
      n = PGSIZE;
80108e5a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108e61:	8b 55 14             	mov    0x14(%ebp),%edx
80108e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e67:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108e6a:	83 ec 0c             	sub    $0xc,%esp
80108e6d:	ff 75 e8             	pushl  -0x18(%ebp)
80108e70:	e8 e3 f6 ff ff       	call   80108558 <p2v>
80108e75:	83 c4 10             	add    $0x10,%esp
80108e78:	ff 75 f0             	pushl  -0x10(%ebp)
80108e7b:	53                   	push   %ebx
80108e7c:	50                   	push   %eax
80108e7d:	ff 75 10             	pushl  0x10(%ebp)
80108e80:	e8 e5 93 ff ff       	call   8010226a <readi>
80108e85:	83 c4 10             	add    $0x10,%esp
80108e88:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108e8b:	74 07                	je     80108e94 <loaduvm+0xba>
      return -1;
80108e8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e92:	eb 18                	jmp    80108eac <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108e94:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9e:	3b 45 18             	cmp    0x18(%ebp),%eax
80108ea1:	0f 82 5f ff ff ff    	jb     80108e06 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108ea7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108eac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108eaf:	c9                   	leave  
80108eb0:	c3                   	ret    

80108eb1 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108eb1:	55                   	push   %ebp
80108eb2:	89 e5                	mov    %esp,%ebp
80108eb4:	83 ec 18             	sub    $0x18,%esp
  //assignment3
  // if its non-normal selection
  #ifndef NONE
  uint newpage = 0; // 0 - write to physical memory ; 1- write to disc
80108eb7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  // finish

  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108ebe:	8b 45 10             	mov    0x10(%ebp),%eax
80108ec1:	85 c0                	test   %eax,%eax
80108ec3:	79 0a                	jns    80108ecf <allocuvm+0x1e>
    return 0;
80108ec5:	b8 00 00 00 00       	mov    $0x0,%eax
80108eca:	e9 ef 00 00 00       	jmp    80108fbe <allocuvm+0x10d>
  if(newsz < oldsz)
80108ecf:	8b 45 10             	mov    0x10(%ebp),%eax
80108ed2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ed5:	73 08                	jae    80108edf <allocuvm+0x2e>
    return oldsz;
80108ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eda:	e9 df 00 00 00       	jmp    80108fbe <allocuvm+0x10d>

  a = PGROUNDUP(oldsz);
80108edf:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ee2:	05 ff 0f 00 00       	add    $0xfff,%eax
80108ee7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(; a < newsz; a += PGSIZE){
80108eef:	e9 bb 00 00 00       	jmp    80108faf <allocuvm+0xfe>
    //assignment3 
    //if exceed physicalPages size copy a page to disc and reset page for this new page
    #ifndef NONE
    if (proc->pagesInPhMem >= MAX_PSYC_PAGES){
80108ef4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108efa:	8b 80 b4 01 00 00    	mov    0x1b4(%eax),%eax
80108f00:	83 f8 0e             	cmp    $0xe,%eax
80108f03:	7e 16                	jle    80108f1b <allocuvm+0x6a>
      writeToSwapFileFunction((char*)a);
80108f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f08:	83 ec 0c             	sub    $0xc,%esp
80108f0b:	50                   	push   %eax
80108f0c:	e8 c0 08 00 00       	call   801097d1 <writeToSwapFileFunction>
80108f11:	83 c4 10             	add    $0x10,%esp
        newpage = 1;
80108f14:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    }
    #endif

    mem = kalloc();
80108f1b:	e8 2f a5 ff ff       	call   8010344f <kalloc>
80108f20:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(mem == 0){
80108f23:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f27:	75 2b                	jne    80108f54 <allocuvm+0xa3>
      cprintf("allocuvm out of memory\n");
80108f29:	83 ec 0c             	sub    $0xc,%esp
80108f2c:	68 4d a5 10 80       	push   $0x8010a54d
80108f31:	e8 90 74 ff ff       	call   801003c6 <cprintf>
80108f36:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108f39:	83 ec 04             	sub    $0x4,%esp
80108f3c:	ff 75 0c             	pushl  0xc(%ebp)
80108f3f:	ff 75 10             	pushl  0x10(%ebp)
80108f42:	ff 75 08             	pushl  0x8(%ebp)
80108f45:	e8 76 00 00 00       	call   80108fc0 <deallocuvm>
80108f4a:	83 c4 10             	add    $0x10,%esp
      return 0;
80108f4d:	b8 00 00 00 00       	mov    $0x0,%eax
80108f52:	eb 6a                	jmp    80108fbe <allocuvm+0x10d>
    }
    //if there is place in physicalPages ,add it
    #ifndef NONE
    if (newpage == 0)
80108f54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f58:	75 0f                	jne    80108f69 <allocuvm+0xb8>
      insertNewPage((char*)a);
80108f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5d:	83 ec 0c             	sub    $0xc,%esp
80108f60:	50                   	push   %eax
80108f61:	e8 13 0a 00 00       	call   80109979 <insertNewPage>
80108f66:	83 c4 10             	add    $0x10,%esp
    #endif
	//finish
    memset(mem, 0, PGSIZE);
80108f69:	83 ec 04             	sub    $0x4,%esp
80108f6c:	68 00 10 00 00       	push   $0x1000
80108f71:	6a 00                	push   $0x0
80108f73:	ff 75 ec             	pushl  -0x14(%ebp)
80108f76:	e8 4f d0 ff ff       	call   80105fca <memset>
80108f7b:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108f7e:	83 ec 0c             	sub    $0xc,%esp
80108f81:	ff 75 ec             	pushl  -0x14(%ebp)
80108f84:	e8 c2 f5 ff ff       	call   8010854b <v2p>
80108f89:	83 c4 10             	add    $0x10,%esp
80108f8c:	89 c2                	mov    %eax,%edx
80108f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f91:	83 ec 0c             	sub    $0xc,%esp
80108f94:	6a 06                	push   $0x6
80108f96:	52                   	push   %edx
80108f97:	68 00 10 00 00       	push   $0x1000
80108f9c:	50                   	push   %eax
80108f9d:	ff 75 08             	pushl  0x8(%ebp)
80108fa0:	e8 d5 fa ff ff       	call   80108a7a <mappages>
80108fa5:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108fa8:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80108faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb2:	3b 45 10             	cmp    0x10(%ebp),%eax
80108fb5:	0f 82 39 ff ff ff    	jb     80108ef4 <allocuvm+0x43>
    #endif
	//finish
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108fbb:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108fbe:	c9                   	leave  
80108fbf:	c3                   	ret    

80108fc0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108fc0:	55                   	push   %ebp
80108fc1:	89 e5                	mov    %esp,%ebp
80108fc3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;
  int i;

  if(newsz >= oldsz)
80108fc6:	8b 45 10             	mov    0x10(%ebp),%eax
80108fc9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fcc:	72 08                	jb     80108fd6 <deallocuvm+0x16>
    return oldsz;
80108fce:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fd1:	e9 35 03 00 00       	jmp    8010930b <deallocuvm+0x34b>

  a = PGROUNDUP(newsz);
80108fd6:	8b 45 10             	mov    0x10(%ebp),%eax
80108fd9:	05 ff 0f 00 00       	add    $0xfff,%eax
80108fde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fe3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108fe6:	e9 11 03 00 00       	jmp    801092fc <deallocuvm+0x33c>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fee:	83 ec 04             	sub    $0x4,%esp
80108ff1:	6a 00                	push   $0x0
80108ff3:	50                   	push   %eax
80108ff4:	ff 75 08             	pushl  0x8(%ebp)
80108ff7:	e8 de f9 ff ff       	call   801089da <walkpgdir>
80108ffc:	83 c4 10             	add    $0x10,%esp
80108fff:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(!pte)
80109002:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109006:	75 0c                	jne    80109014 <deallocuvm+0x54>
      a += (NPTENTRIES - 1) * PGSIZE;
80109008:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010900f:	e9 e1 02 00 00       	jmp    801092f5 <deallocuvm+0x335>
    else if((*pte & PTE_P) != 0){
80109014:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109017:	8b 00                	mov    (%eax),%eax
80109019:	83 e0 01             	and    $0x1,%eax
8010901c:	85 c0                	test   %eax,%eax
8010901e:	0f 84 56 02 00 00    	je     8010927a <deallocuvm+0x2ba>
      pa = PTE_ADDR(*pte);
80109024:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109027:	8b 00                	mov    (%eax),%eax
80109029:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010902e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(pa == 0)
80109031:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109035:	75 0d                	jne    80109044 <deallocuvm+0x84>
        panic("kfree");
80109037:	83 ec 0c             	sub    $0xc,%esp
8010903a:	68 65 a5 10 80       	push   $0x8010a565
8010903f:	e8 22 75 ff ff       	call   80100566 <panic>
        //assignment3
        if (proc->pgdir == pgdir) {
80109044:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010904a:	8b 40 04             	mov    0x4(%eax),%eax
8010904d:	3b 45 08             	cmp    0x8(%ebp),%eax
80109050:	0f 85 fa 01 00 00    	jne    80109250 <deallocuvm+0x290>
		#ifndef NONE
		//search for index that points to virtual address a
          for (i = 0; i < MAX_PSYC_PAGES; i++) {
80109056:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010905d:	eb 21                	jmp    80109080 <deallocuvm+0xc0>
            if (proc->physical[i].virtualAdress == (char*)a)
8010905f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109065:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109068:	83 c2 0b             	add    $0xb,%edx
8010906b:	c1 e2 04             	shl    $0x4,%edx
8010906e:	01 d0                	add    %edx,%eax
80109070:	83 c0 0c             	add    $0xc,%eax
80109073:	8b 10                	mov    (%eax),%edx
80109075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109078:	39 c2                	cmp    %eax,%edx
8010907a:	74 17                	je     80109093 <deallocuvm+0xd3>
        panic("kfree");
        //assignment3
        if (proc->pgdir == pgdir) {
		#ifndef NONE
		//search for index that points to virtual address a
          for (i = 0; i < MAX_PSYC_PAGES; i++) {
8010907c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109080:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80109084:	7e d9                	jle    8010905f <deallocuvm+0x9f>
            if (proc->physical[i].virtualAdress == (char*)a)
              goto foundEntry;
          }
          panic("deallocuvm: no entry found in physical memory");
80109086:	83 ec 0c             	sub    $0xc,%esp
80109089:	68 6c a5 10 80       	push   $0x8010a56c
8010908e:	e8 d3 74 ff ff       	call   80100566 <panic>
        if (proc->pgdir == pgdir) {
		#ifndef NONE
		//search for index that points to virtual address a
          for (i = 0; i < MAX_PSYC_PAGES; i++) {
            if (proc->physical[i].virtualAdress == (char*)a)
              goto foundEntry;
80109093:	90                   	nop
          }
          panic("deallocuvm: no entry found in physical memory");
  foundEntry:
  //reset virtualAdress
          proc->physical[i].virtualAdress = (char*) 0xffffffff;
80109094:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010909a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010909d:	83 c2 0b             	add    $0xb,%edx
801090a0:	c1 e2 04             	shl    $0x4,%edx
801090a3:	01 d0                	add    %edx,%eax
801090a5:	83 c0 0c             	add    $0xc,%eax
801090a8:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
            // remove the physical[i] from the linked list
			//first check if head points to physical[i]
          if (proc->head == &proc->physical[i]){
801090ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090b4:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
801090ba:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801090c1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801090c4:	83 c1 0b             	add    $0xb,%ecx
801090c7:	c1 e1 04             	shl    $0x4,%ecx
801090ca:	01 ca                	add    %ecx,%edx
801090cc:	83 c2 0c             	add    $0xc,%edx
801090cf:	39 d0                	cmp    %edx,%eax
801090d1:	75 4f                	jne    80109122 <deallocuvm+0x162>
            proc->head = proc->physical[i].next;
801090d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090d9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801090e0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801090e3:	83 c1 0b             	add    $0xb,%ecx
801090e6:	c1 e1 04             	shl    $0x4,%ecx
801090e9:	01 ca                	add    %ecx,%edx
801090eb:	83 c2 14             	add    $0x14,%edx
801090ee:	8b 12                	mov    (%edx),%edx
801090f0:	89 90 ac 01 00 00    	mov    %edx,0x1ac(%eax)
            if(proc->head != 0)
801090f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090fc:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109102:	85 c0                	test   %eax,%eax
80109104:	0f 84 fc 00 00 00    	je     80109206 <deallocuvm+0x246>
              proc->head->prev = 0;
8010910a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109110:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109116:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
            goto done;
8010911d:	e9 e4 00 00 00       	jmp    80109206 <deallocuvm+0x246>
          }
		  // check if tail points to physical[i]
          if (proc->tail == &proc->physical[i]){
80109122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109128:	8b 80 b0 01 00 00    	mov    0x1b0(%eax),%eax
8010912e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109135:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80109138:	83 c1 0b             	add    $0xb,%ecx
8010913b:	c1 e1 04             	shl    $0x4,%ecx
8010913e:	01 ca                	add    %ecx,%edx
80109140:	83 c2 0c             	add    $0xc,%edx
80109143:	39 d0                	cmp    %edx,%eax
80109145:	75 28                	jne    8010916f <deallocuvm+0x1af>
            proc->tail = proc->physical[i].prev;
80109147:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010914d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109154:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80109157:	83 c1 0b             	add    $0xb,%ecx
8010915a:	c1 e1 04             	shl    $0x4,%ecx
8010915d:	01 ca                	add    %ecx,%edx
8010915f:	83 c2 18             	add    $0x18,%edx
80109162:	8b 12                	mov    (%edx),%edx
80109164:	89 90 b0 01 00 00    	mov    %edx,0x1b0(%eax)
            goto done;
8010916a:	e9 98 00 00 00       	jmp    80109207 <deallocuvm+0x247>
          }
		  //if its neither of them than remove from linked list in normal way
          struct physicalPages *temp = proc->head;
8010916f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109175:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
8010917b:	89 45 ec             	mov    %eax,-0x14(%ebp)
		  //find link before physical[i] or before null if not found
          while (temp->next != 0 && temp->next != &proc->physical[i]){
8010917e:	eb 09                	jmp    80109189 <deallocuvm+0x1c9>
            temp = temp->next;
80109180:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109183:	8b 40 08             	mov    0x8(%eax),%eax
80109186:	89 45 ec             	mov    %eax,-0x14(%ebp)
            goto done;
          }
		  //if its neither of them than remove from linked list in normal way
          struct physicalPages *temp = proc->head;
		  //find link before physical[i] or before null if not found
          while (temp->next != 0 && temp->next != &proc->physical[i]){
80109189:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010918c:	8b 40 08             	mov    0x8(%eax),%eax
8010918f:	85 c0                	test   %eax,%eax
80109191:	74 1f                	je     801091b2 <deallocuvm+0x1f2>
80109193:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109196:	8b 40 08             	mov    0x8(%eax),%eax
80109199:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801091a0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801091a3:	83 c1 0b             	add    $0xb,%ecx
801091a6:	c1 e1 04             	shl    $0x4,%ecx
801091a9:	01 ca                	add    %ecx,%edx
801091ab:	83 c2 0c             	add    $0xc,%edx
801091ae:	39 d0                	cmp    %edx,%eax
801091b0:	75 ce                	jne    80109180 <deallocuvm+0x1c0>
            temp = temp->next;
          }
		  //change the next of link before physical[i] to physical[i].next 
          temp->next = proc->physical[i].next;
801091b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801091bb:	83 c2 0b             	add    $0xb,%edx
801091be:	c1 e2 04             	shl    $0x4,%edx
801091c1:	01 d0                	add    %edx,%eax
801091c3:	83 c0 14             	add    $0x14,%eax
801091c6:	8b 10                	mov    (%eax),%edx
801091c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091cb:	89 50 08             	mov    %edx,0x8(%eax)
          if (proc->physical[i].next != 0){
801091ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801091d7:	83 c2 0b             	add    $0xb,%edx
801091da:	c1 e2 04             	shl    $0x4,%edx
801091dd:	01 d0                	add    %edx,%eax
801091df:	83 c0 14             	add    $0x14,%eax
801091e2:	8b 00                	mov    (%eax),%eax
801091e4:	85 c0                	test   %eax,%eax
801091e6:	74 1f                	je     80109207 <deallocuvm+0x247>
            proc->physical[i].next->prev = temp; 
801091e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801091f1:	83 c2 0b             	add    $0xb,%edx
801091f4:	c1 e2 04             	shl    $0x4,%edx
801091f7:	01 d0                	add    %edx,%eax
801091f9:	83 c0 14             	add    $0x14,%eax
801091fc:	8b 00                	mov    (%eax),%eax
801091fe:	8b 55 ec             	mov    -0x14(%ebp),%edx
80109201:	89 50 0c             	mov    %edx,0xc(%eax)
80109204:	eb 01                	jmp    80109207 <deallocuvm+0x247>
			//first check if head points to physical[i]
          if (proc->head == &proc->physical[i]){
            proc->head = proc->physical[i].next;
            if(proc->head != 0)
              proc->head->prev = 0;
            goto done;
80109206:	90                   	nop
          if (proc->physical[i].next != 0){
            proc->physical[i].next->prev = temp; 
          }
  done:
  //reset pointers
          proc->physical[i].next = 0;
80109207:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010920d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109210:	83 c2 0b             	add    $0xb,%edx
80109213:	c1 e2 04             	shl    $0x4,%edx
80109216:	01 d0                	add    %edx,%eax
80109218:	83 c0 14             	add    $0x14,%eax
8010921b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
          proc->physical[i].prev = 0;
80109221:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109227:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010922a:	83 c2 0b             	add    $0xb,%edx
8010922d:	c1 e2 04             	shl    $0x4,%edx
80109230:	01 d0                	add    %edx,%eax
80109232:	83 c0 18             	add    $0x18,%eax
80109235:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  #endif
	//decrement total pages in physical memory
  	//cprintf("deallocuvm - pages in mem before dealloc  %d\n" ,proc->pagesInPhMem);
          proc->pagesInPhMem--;
8010923b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109241:	8b 90 b4 01 00 00    	mov    0x1b4(%eax),%edx
80109247:	83 ea 01             	sub    $0x1,%edx
8010924a:	89 90 b4 01 00 00    	mov    %edx,0x1b4(%eax)
        }
      char *v = p2v(pa);
80109250:	83 ec 0c             	sub    $0xc,%esp
80109253:	ff 75 e4             	pushl  -0x1c(%ebp)
80109256:	e8 fd f2 ff ff       	call   80108558 <p2v>
8010925b:	83 c4 10             	add    $0x10,%esp
8010925e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      kfree(v);
80109261:	83 ec 0c             	sub    $0xc,%esp
80109264:	ff 75 e0             	pushl  -0x20(%ebp)
80109267:	e8 39 a1 ff ff       	call   801033a5 <kfree>
8010926c:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010926f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109272:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80109278:	eb 7b                	jmp    801092f5 <deallocuvm+0x335>
    }
    //entry not found in physical memory , search in disc
  else if (*pte & PTE_PG && proc->pgdir == pgdir) {
8010927a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010927d:	8b 00                	mov    (%eax),%eax
8010927f:	25 00 02 00 00       	and    $0x200,%eax
80109284:	85 c0                	test   %eax,%eax
80109286:	74 6d                	je     801092f5 <deallocuvm+0x335>
80109288:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010928e:	8b 40 04             	mov    0x4(%eax),%eax
80109291:	3b 45 08             	cmp    0x8(%ebp),%eax
80109294:	75 5f                	jne    801092f5 <deallocuvm+0x335>
      for (i = 0; i < MAX_PSYC_PAGES; i++) {
80109296:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010929d:	eb 1a                	jmp    801092b9 <deallocuvm+0x2f9>
        if (proc->disc[i].virtualAdress == (char*)a)
8010929f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801092a8:	83 c2 20             	add    $0x20,%edx
801092ab:	8b 14 90             	mov    (%eax,%edx,4),%edx
801092ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b1:	39 c2                	cmp    %eax,%edx
801092b3:	74 17                	je     801092cc <deallocuvm+0x30c>
      kfree(v);
      *pte = 0;
    }
    //entry not found in physical memory , search in disc
  else if (*pte & PTE_PG && proc->pgdir == pgdir) {
      for (i = 0; i < MAX_PSYC_PAGES; i++) {
801092b5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801092b9:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
801092bd:	7e e0                	jle    8010929f <deallocuvm+0x2df>
        if (proc->disc[i].virtualAdress == (char*)a)
          goto foundEntryDisc;
      }
    panic("deallocuvm: no entry found in disc");
801092bf:	83 ec 0c             	sub    $0xc,%esp
801092c2:	68 9c a5 10 80       	push   $0x8010a59c
801092c7:	e8 9a 72 ff ff       	call   80100566 <panic>
    }
    //entry not found in physical memory , search in disc
  else if (*pte & PTE_PG && proc->pgdir == pgdir) {
      for (i = 0; i < MAX_PSYC_PAGES; i++) {
        if (proc->disc[i].virtualAdress == (char*)a)
          goto foundEntryDisc;
801092cc:	90                   	nop
      }
    panic("deallocuvm: no entry found in disc");
	foundEntryDisc:
      proc->disc[i].virtualAdress = (char*) 0xffffffff;
801092cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801092d6:	83 c2 20             	add    $0x20,%edx
801092d9:	c7 04 90 ff ff ff ff 	movl   $0xffffffff,(%eax,%edx,4)
	  //cprintf("total pages in disc: %d    one page is removed from disc %d \n",proc->pagesInDisc,proc->pagesInDisc-1);
	  //decrement pages in disc
      proc->pagesInDisc--;
801092e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092e6:	8b 90 b8 01 00 00    	mov    0x1b8(%eax),%edx
801092ec:	83 ea 01             	sub    $0x1,%edx
801092ef:	89 90 b8 01 00 00    	mov    %edx,0x1b8(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801092f5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801092fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ff:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109302:	0f 82 e3 fc ff ff    	jb     80108feb <deallocuvm+0x2b>
      proc->pagesInDisc--;
	  //finish
  }
}

  return newsz;
80109308:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010930b:	c9                   	leave  
8010930c:	c3                   	ret    

8010930d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010930d:	55                   	push   %ebp
8010930e:	89 e5                	mov    %esp,%ebp
80109310:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109313:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109317:	75 0d                	jne    80109326 <freevm+0x19>
    panic("freevm: no pgdir");
80109319:	83 ec 0c             	sub    $0xc,%esp
8010931c:	68 bf a5 10 80       	push   $0x8010a5bf
80109321:	e8 40 72 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109326:	83 ec 04             	sub    $0x4,%esp
80109329:	6a 00                	push   $0x0
8010932b:	68 00 00 00 80       	push   $0x80000000
80109330:	ff 75 08             	pushl  0x8(%ebp)
80109333:	e8 88 fc ff ff       	call   80108fc0 <deallocuvm>
80109338:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010933b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109342:	eb 4f                	jmp    80109393 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109347:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010934e:	8b 45 08             	mov    0x8(%ebp),%eax
80109351:	01 d0                	add    %edx,%eax
80109353:	8b 00                	mov    (%eax),%eax
80109355:	83 e0 01             	and    $0x1,%eax
80109358:	85 c0                	test   %eax,%eax
8010935a:	74 33                	je     8010938f <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010935c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010935f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109366:	8b 45 08             	mov    0x8(%ebp),%eax
80109369:	01 d0                	add    %edx,%eax
8010936b:	8b 00                	mov    (%eax),%eax
8010936d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109372:	83 ec 0c             	sub    $0xc,%esp
80109375:	50                   	push   %eax
80109376:	e8 dd f1 ff ff       	call   80108558 <p2v>
8010937b:	83 c4 10             	add    $0x10,%esp
8010937e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109381:	83 ec 0c             	sub    $0xc,%esp
80109384:	ff 75 f0             	pushl  -0x10(%ebp)
80109387:	e8 19 a0 ff ff       	call   801033a5 <kfree>
8010938c:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010938f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109393:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010939a:	76 a8                	jbe    80109344 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010939c:	83 ec 0c             	sub    $0xc,%esp
8010939f:	ff 75 08             	pushl  0x8(%ebp)
801093a2:	e8 fe 9f ff ff       	call   801033a5 <kfree>
801093a7:	83 c4 10             	add    $0x10,%esp
}
801093aa:	90                   	nop
801093ab:	c9                   	leave  
801093ac:	c3                   	ret    

801093ad <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801093ad:	55                   	push   %ebp
801093ae:	89 e5                	mov    %esp,%ebp
801093b0:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801093b3:	83 ec 04             	sub    $0x4,%esp
801093b6:	6a 00                	push   $0x0
801093b8:	ff 75 0c             	pushl  0xc(%ebp)
801093bb:	ff 75 08             	pushl  0x8(%ebp)
801093be:	e8 17 f6 ff ff       	call   801089da <walkpgdir>
801093c3:	83 c4 10             	add    $0x10,%esp
801093c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801093c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801093cd:	75 0d                	jne    801093dc <clearpteu+0x2f>
    panic("clearpteu");
801093cf:	83 ec 0c             	sub    $0xc,%esp
801093d2:	68 d0 a5 10 80       	push   $0x8010a5d0
801093d7:	e8 8a 71 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801093dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093df:	8b 00                	mov    (%eax),%eax
801093e1:	83 e0 fb             	and    $0xfffffffb,%eax
801093e4:	89 c2                	mov    %eax,%edx
801093e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e9:	89 10                	mov    %edx,(%eax)
}
801093eb:	90                   	nop
801093ec:	c9                   	leave  
801093ed:	c3                   	ret    

801093ee <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801093ee:	55                   	push   %ebp
801093ef:	89 e5                	mov    %esp,%ebp
801093f1:	53                   	push   %ebx
801093f2:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801093f5:	e8 10 f7 ff ff       	call   80108b0a <setupkvm>
801093fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801093fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109401:	75 0a                	jne    8010940d <copyuvm+0x1f>
    return 0;
80109403:	b8 00 00 00 00       	mov    $0x0,%eax
80109408:	e9 36 01 00 00       	jmp    80109543 <copyuvm+0x155>
  for(i = 0; i < sz; i += PGSIZE){
8010940d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109414:	e9 02 01 00 00       	jmp    8010951b <copyuvm+0x12d>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010941c:	83 ec 04             	sub    $0x4,%esp
8010941f:	6a 00                	push   $0x0
80109421:	50                   	push   %eax
80109422:	ff 75 08             	pushl  0x8(%ebp)
80109425:	e8 b0 f5 ff ff       	call   801089da <walkpgdir>
8010942a:	83 c4 10             	add    $0x10,%esp
8010942d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109430:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109434:	75 0d                	jne    80109443 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109436:	83 ec 0c             	sub    $0xc,%esp
80109439:	68 da a5 10 80       	push   $0x8010a5da
8010943e:	e8 23 71 ff ff       	call   80100566 <panic>
    // check if the page exist and that PTE_PG is on
    // assignment3
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
80109443:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109446:	8b 00                	mov    (%eax),%eax
80109448:	83 e0 01             	and    $0x1,%eax
8010944b:	85 c0                	test   %eax,%eax
8010944d:	75 1b                	jne    8010946a <copyuvm+0x7c>
8010944f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109452:	8b 00                	mov    (%eax),%eax
80109454:	25 00 02 00 00       	and    $0x200,%eax
80109459:	85 c0                	test   %eax,%eax
8010945b:	75 0d                	jne    8010946a <copyuvm+0x7c>
      panic("copyuvm: page not present or is not page out");
8010945d:	83 ec 0c             	sub    $0xc,%esp
80109460:	68 f4 a5 10 80       	push   $0x8010a5f4
80109465:	e8 fc 70 ff ff       	call   80100566 <panic>

    if(*pte & PTE_PG) // there was a page out
8010946a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010946d:	8b 00                	mov    (%eax),%eax
8010946f:	25 00 02 00 00       	and    $0x200,%eax
80109474:	85 c0                	test   %eax,%eax
80109476:	74 22                	je     8010949a <copyuvm+0xac>
    {
      pte = walkpgdir(d, (void*)i, 1);
80109478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010947b:	83 ec 04             	sub    $0x4,%esp
8010947e:	6a 01                	push   $0x1
80109480:	50                   	push   %eax
80109481:	ff 75 f0             	pushl  -0x10(%ebp)
80109484:	e8 51 f5 ff ff       	call   801089da <walkpgdir>
80109489:	83 c4 10             	add    $0x10,%esp
8010948c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  // update the flags of the swapped out PGE to : not present, pagedOut, user, writeable
      *pte = PTE_U | PTE_W | PTE_PG;
8010948f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109492:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      continue;
80109498:	eb 7a                	jmp    80109514 <copyuvm+0x126>
    }
    // finish
    pa = PTE_ADDR(*pte);
8010949a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010949d:	8b 00                	mov    (%eax),%eax
8010949f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801094a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801094a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801094aa:	8b 00                	mov    (%eax),%eax
801094ac:	25 ff 0f 00 00       	and    $0xfff,%eax
801094b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801094b4:	e8 96 9f ff ff       	call   8010344f <kalloc>
801094b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801094bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801094c0:	74 6a                	je     8010952c <copyuvm+0x13e>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801094c2:	83 ec 0c             	sub    $0xc,%esp
801094c5:	ff 75 e8             	pushl  -0x18(%ebp)
801094c8:	e8 8b f0 ff ff       	call   80108558 <p2v>
801094cd:	83 c4 10             	add    $0x10,%esp
801094d0:	83 ec 04             	sub    $0x4,%esp
801094d3:	68 00 10 00 00       	push   $0x1000
801094d8:	50                   	push   %eax
801094d9:	ff 75 e0             	pushl  -0x20(%ebp)
801094dc:	e8 a8 cb ff ff       	call   80106089 <memmove>
801094e1:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801094e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801094e7:	83 ec 0c             	sub    $0xc,%esp
801094ea:	ff 75 e0             	pushl  -0x20(%ebp)
801094ed:	e8 59 f0 ff ff       	call   8010854b <v2p>
801094f2:	83 c4 10             	add    $0x10,%esp
801094f5:	89 c2                	mov    %eax,%edx
801094f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094fa:	83 ec 0c             	sub    $0xc,%esp
801094fd:	53                   	push   %ebx
801094fe:	52                   	push   %edx
801094ff:	68 00 10 00 00       	push   $0x1000
80109504:	50                   	push   %eax
80109505:	ff 75 f0             	pushl  -0x10(%ebp)
80109508:	e8 6d f5 ff ff       	call   80108a7a <mappages>
8010950d:	83 c4 20             	add    $0x20,%esp
80109510:	85 c0                	test   %eax,%eax
80109512:	78 1b                	js     8010952f <copyuvm+0x141>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109514:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010951b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010951e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109521:	0f 82 f2 fe ff ff    	jb     80109419 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109527:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010952a:	eb 17                	jmp    80109543 <copyuvm+0x155>
    }
    // finish
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010952c:	90                   	nop
8010952d:	eb 01                	jmp    80109530 <copyuvm+0x142>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010952f:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109530:	83 ec 0c             	sub    $0xc,%esp
80109533:	ff 75 f0             	pushl  -0x10(%ebp)
80109536:	e8 d2 fd ff ff       	call   8010930d <freevm>
8010953b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010953e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109546:	c9                   	leave  
80109547:	c3                   	ret    

80109548 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109548:	55                   	push   %ebp
80109549:	89 e5                	mov    %esp,%ebp
8010954b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010954e:	83 ec 04             	sub    $0x4,%esp
80109551:	6a 00                	push   $0x0
80109553:	ff 75 0c             	pushl  0xc(%ebp)
80109556:	ff 75 08             	pushl  0x8(%ebp)
80109559:	e8 7c f4 ff ff       	call   801089da <walkpgdir>
8010955e:	83 c4 10             	add    $0x10,%esp
80109561:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109567:	8b 00                	mov    (%eax),%eax
80109569:	83 e0 01             	and    $0x1,%eax
8010956c:	85 c0                	test   %eax,%eax
8010956e:	75 07                	jne    80109577 <uva2ka+0x2f>
    return 0;
80109570:	b8 00 00 00 00       	mov    $0x0,%eax
80109575:	eb 29                	jmp    801095a0 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010957a:	8b 00                	mov    (%eax),%eax
8010957c:	83 e0 04             	and    $0x4,%eax
8010957f:	85 c0                	test   %eax,%eax
80109581:	75 07                	jne    8010958a <uva2ka+0x42>
    return 0;
80109583:	b8 00 00 00 00       	mov    $0x0,%eax
80109588:	eb 16                	jmp    801095a0 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010958a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958d:	8b 00                	mov    (%eax),%eax
8010958f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109594:	83 ec 0c             	sub    $0xc,%esp
80109597:	50                   	push   %eax
80109598:	e8 bb ef ff ff       	call   80108558 <p2v>
8010959d:	83 c4 10             	add    $0x10,%esp
}
801095a0:	c9                   	leave  
801095a1:	c3                   	ret    

801095a2 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801095a2:	55                   	push   %ebp
801095a3:	89 e5                	mov    %esp,%ebp
801095a5:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801095a8:	8b 45 10             	mov    0x10(%ebp),%eax
801095ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801095ae:	eb 7f                	jmp    8010962f <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801095b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801095b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801095b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801095bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095be:	83 ec 08             	sub    $0x8,%esp
801095c1:	50                   	push   %eax
801095c2:	ff 75 08             	pushl  0x8(%ebp)
801095c5:	e8 7e ff ff ff       	call   80109548 <uva2ka>
801095ca:	83 c4 10             	add    $0x10,%esp
801095cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801095d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801095d4:	75 07                	jne    801095dd <copyout+0x3b>
      return -1;
801095d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095db:	eb 61                	jmp    8010963e <copyout+0x9c>
    n = PGSIZE - (va - va0);
801095dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095e0:	2b 45 0c             	sub    0xc(%ebp),%eax
801095e3:	05 00 10 00 00       	add    $0x1000,%eax
801095e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801095eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ee:	3b 45 14             	cmp    0x14(%ebp),%eax
801095f1:	76 06                	jbe    801095f9 <copyout+0x57>
      n = len;
801095f3:	8b 45 14             	mov    0x14(%ebp),%eax
801095f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801095f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801095fc:	2b 45 ec             	sub    -0x14(%ebp),%eax
801095ff:	89 c2                	mov    %eax,%edx
80109601:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109604:	01 d0                	add    %edx,%eax
80109606:	83 ec 04             	sub    $0x4,%esp
80109609:	ff 75 f0             	pushl  -0x10(%ebp)
8010960c:	ff 75 f4             	pushl  -0xc(%ebp)
8010960f:	50                   	push   %eax
80109610:	e8 74 ca ff ff       	call   80106089 <memmove>
80109615:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109618:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010961b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010961e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109621:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109624:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109627:	05 00 10 00 00       	add    $0x1000,%eax
8010962c:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010962f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109633:	0f 85 77 ff ff ff    	jne    801095b0 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109639:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010963e:	c9                   	leave  
8010963f:	c3                   	ret    

80109640 <checkAccBit>:

//assignment3
// helper function for the access bit
int checkAccBit(char *va){
80109640:	55                   	push   %ebp
80109641:	89 e5                	mov    %esp,%ebp
80109643:	83 ec 18             	sub    $0x18,%esp
  uint accBit;
  //get address of PTE
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
80109646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010964c:	8b 40 04             	mov    0x4(%eax),%eax
8010964f:	83 ec 04             	sub    $0x4,%esp
80109652:	6a 00                	push   $0x0
80109654:	ff 75 08             	pushl  0x8(%ebp)
80109657:	50                   	push   %eax
80109658:	e8 7d f3 ff ff       	call   801089da <walkpgdir>
8010965d:	83 c4 10             	add    $0x10,%esp
80109660:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //check if empty
  if (!*pte)
80109663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109666:	8b 00                	mov    (%eax),%eax
80109668:	85 c0                	test   %eax,%eax
8010966a:	75 0d                	jne    80109679 <checkAccBit+0x39>
    panic("checkAccBit: pte1 is empty");
8010966c:	83 ec 0c             	sub    $0xc,%esp
8010966f:	68 21 a6 10 80       	push   $0x8010a621
80109674:	e8 ed 6e ff ff       	call   80100566 <panic>
    //get accessBit
  accBit = (*pte) & PTE_A;
80109679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010967c:	8b 00                	mov    (%eax),%eax
8010967e:	83 e0 20             	and    $0x20,%eax
80109681:	89 45 f0             	mov    %eax,-0x10(%ebp)
  (*pte) &= ~PTE_A; // reset to PTE_A only bit
80109684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109687:	8b 00                	mov    (%eax),%eax
80109689:	83 e0 df             	and    $0xffffffdf,%eax
8010968c:	89 c2                	mov    %eax,%edx
8010968e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109691:	89 10                	mov    %edx,(%eax)
  return accBit;
80109693:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109696:	c9                   	leave  
80109697:	c3                   	ret    

80109698 <changeToScFifo>:


void changeToScFifo() {
80109698:	55                   	push   %ebp
80109699:	89 e5                	mov    %esp,%ebp
8010969b:	83 ec 18             	sub    $0x18,%esp
  struct physicalPages *temp = proc->tail;
8010969e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096a4:	8b 80 b0 01 00 00    	mov    0x1b0(%eax),%eax
801096aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  do{
    //move temp from tail to head
    proc->tail = proc->tail->prev;
801096ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096b3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801096ba:	8b 92 b0 01 00 00    	mov    0x1b0(%edx),%edx
801096c0:	8b 52 0c             	mov    0xc(%edx),%edx
801096c3:	89 90 b0 01 00 00    	mov    %edx,0x1b0(%eax)
    proc->tail->next = 0;
801096c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096cf:	8b 80 b0 01 00 00    	mov    0x1b0(%eax),%eax
801096d5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    temp->prev = 0;
801096dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096df:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    temp->next = proc->head;
801096e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096ec:	8b 90 ac 01 00 00    	mov    0x1ac(%eax),%edx
801096f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f5:	89 50 08             	mov    %edx,0x8(%eax)
    proc->head->prev = temp;
801096f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096fe:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109704:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109707:	89 50 0c             	mov    %edx,0xc(%eax)
    proc->head = temp;
8010970a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109710:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109713:	89 90 ac 01 00 00    	mov    %edx,0x1ac(%eax)
    temp = proc->tail;
80109719:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010971f:	8b 80 b0 01 00 00    	mov    0x1b0(%eax),%eax
80109725:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }while(checkAccBit(proc->head->virtualAdress));
80109728:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010972e:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109734:	8b 00                	mov    (%eax),%eax
80109736:	83 ec 0c             	sub    $0xc,%esp
80109739:	50                   	push   %eax
8010973a:	e8 01 ff ff ff       	call   80109640 <checkAccBit>
8010973f:	83 c4 10             	add    $0x10,%esp
80109742:	85 c0                	test   %eax,%eax
80109744:	0f 85 63 ff ff ff    	jne    801096ad <changeToScFifo+0x15>

}
8010974a:	90                   	nop
8010974b:	c9                   	leave  
8010974c:	c3                   	ret    

8010974d <findMinAccessed>:

// searching for the minimum accessed bit
int findMinAccessed () {
8010974d:	55                   	push   %ebp
8010974e:	89 e5                	mov    %esp,%ebp
80109750:	83 ec 10             	sub    $0x10,%esp
    int min= 1000000;
80109753:	c7 45 fc 40 42 0f 00 	movl   $0xf4240,-0x4(%ebp)
    int index = -1;
8010975a:	c7 45 f8 ff ff ff ff 	movl   $0xffffffff,-0x8(%ebp)
  // find the minimum accessed page
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
80109761:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109768:	eb 5c                	jmp    801097c6 <findMinAccessed+0x79>
    //if virtualAdress points to null cont
    if (proc->physical[i].virtualAdress == (char*)0xffffffff)
8010976a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109770:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109773:	83 c2 0b             	add    $0xb,%edx
80109776:	c1 e2 04             	shl    $0x4,%edx
80109779:	01 d0                	add    %edx,%eax
8010977b:	83 c0 0c             	add    $0xc,%eax
8010977e:	8b 00                	mov    (%eax),%eax
80109780:	83 f8 ff             	cmp    $0xffffffff,%eax
80109783:	74 3c                	je     801097c1 <findMinAccessed+0x74>
      continue;
      //update is found smaller
      if(proc->physical[i].accessCount <  min){
80109785:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010978b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010978e:	83 c2 0b             	add    $0xb,%edx
80109791:	c1 e2 04             	shl    $0x4,%edx
80109794:	01 d0                	add    %edx,%eax
80109796:	83 c0 10             	add    $0x10,%eax
80109799:	8b 00                	mov    (%eax),%eax
8010979b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
8010979e:	7d 22                	jge    801097c2 <findMinAccessed+0x75>
       min = proc->physical[i].accessCount;
801097a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097a9:	83 c2 0b             	add    $0xb,%edx
801097ac:	c1 e2 04             	shl    $0x4,%edx
801097af:	01 d0                	add    %edx,%eax
801097b1:	83 c0 10             	add    $0x10,%eax
801097b4:	8b 00                	mov    (%eax),%eax
801097b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
       index = i;
801097b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
801097bf:	eb 01                	jmp    801097c2 <findMinAccessed+0x75>
    int index = -1;
  // find the minimum accessed page
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    //if virtualAdress points to null cont
    if (proc->physical[i].virtualAdress == (char*)0xffffffff)
      continue;
801097c1:	90                   	nop
// searching for the minimum accessed bit
int findMinAccessed () {
    int min= 1000000;
    int index = -1;
  // find the minimum accessed page
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
801097c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097c6:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801097ca:	7e 9e                	jle    8010976a <findMinAccessed+0x1d>
      if(proc->physical[i].accessCount <  min){
       min = proc->physical[i].accessCount;
       index = i;
    }
  }
  return index;
801097cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801097cf:	c9                   	leave  
801097d0:	c3                   	ret    

801097d1 <writeToSwapFileFunction>:

// doing the actual swap
struct physicalPages *writeToSwapFileFunction(char *va){
801097d1:	55                   	push   %ebp
801097d2:	89 e5                	mov    %esp,%ebp
801097d4:	83 ec 18             	sub    $0x18,%esp

  if (proc->head == 0 || (proc->head->next == 0))
801097d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097dd:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
801097e3:	85 c0                	test   %eax,%eax
801097e5:	74 13                	je     801097fa <writeToSwapFileFunction+0x29>
801097e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097ed:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
801097f3:	8b 40 08             	mov    0x8(%eax),%eax
801097f6:	85 c0                	test   %eax,%eax
801097f8:	75 0d                	jne    80109807 <writeToSwapFileFunction+0x36>
    panic("writeToSwapFileFunction: proc->head is NULL or single page in physical memory");
801097fa:	83 ec 0c             	sub    $0xc,%esp
801097fd:	68 3c a6 10 80       	push   $0x8010a63c
80109802:	e8 5f 6d ff ff       	call   80100566 <panic>

  int i;
  struct physicalPages *pageToWrite = 0;
80109807:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int index = findMinAccessed();
  pageToWrite = &proc->physical[index];
  
  #elif SCFIFO
  //if SCFIFO is selected we remove according to create time and PTE_A flag (accBit)
  changeToScFifo();
8010980e:	e8 85 fe ff ff       	call   80109698 <changeToScFifo>
  pageToWrite = proc->head;
80109813:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109819:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
8010981f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  //if FIFO is selected we remove the last one 
  pageToWrite = proc->head;
  #endif

  // searching for a free page slot in the disc
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109822:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109829:	eb 18                	jmp    80109843 <writeToSwapFileFunction+0x72>
    if (proc->disc[i].virtualAdress == (char*)0xffffffff)
8010982b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109831:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109834:	83 c2 20             	add    $0x20,%edx
80109837:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010983a:	83 f8 ff             	cmp    $0xffffffff,%eax
8010983d:	74 17                	je     80109856 <writeToSwapFileFunction+0x85>
  //if FIFO is selected we remove the last one 
  pageToWrite = proc->head;
  #endif

  // searching for a free page slot in the disc
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010983f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109843:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80109847:	7e e2                	jle    8010982b <writeToSwapFileFunction+0x5a>
    if (proc->disc[i].virtualAdress == (char*)0xffffffff)
      goto foundDiscSlot;
  }
  panic("writeToSwapFileFunction: can't find slot in disc");
80109849:	83 ec 0c             	sub    $0xc,%esp
8010984c:	68 8c a6 10 80       	push   $0x8010a68c
80109851:	e8 10 6d ff ff       	call   80100566 <panic>
  #endif

  // searching for a free page slot in the disc
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->disc[i].virtualAdress == (char*)0xffffffff)
      goto foundDiscSlot;
80109856:	90                   	nop
  }
  panic("writeToSwapFileFunction: can't find slot in disc");
foundDiscSlot:
  // save the pageToWrite object into the disc
  proc->disc[i].virtualAdress = pageToWrite->virtualAdress;
80109857:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010985d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109860:	8b 12                	mov    (%edx),%edx
80109862:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80109865:	83 c1 20             	add    $0x20,%ecx
80109868:	89 14 88             	mov    %edx,(%eax,%ecx,4)
  if ( writeToSwapFile(proc, (char*)PTE_ADDR(pageToWrite->virtualAdress), i * PGSIZE, PGSIZE) == 0) //if 0 returned writeToSwapFile failed
8010986b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010986e:	c1 e0 0c             	shl    $0xc,%eax
80109871:	89 c1                	mov    %eax,%ecx
80109873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109876:	8b 00                	mov    (%eax),%eax
80109878:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010987d:	89 c2                	mov    %eax,%edx
8010987f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109885:	68 00 10 00 00       	push   $0x1000
8010988a:	51                   	push   %ecx
8010988b:	52                   	push   %edx
8010988c:	50                   	push   %eax
8010988d:	e8 ff 93 ff ff       	call   80102c91 <writeToSwapFile>
80109892:	83 c4 10             	add    $0x10,%esp
80109895:	85 c0                	test   %eax,%eax
80109897:	75 0a                	jne    801098a3 <writeToSwapFileFunction+0xd2>
    return 0;
80109899:	b8 00 00 00 00       	mov    $0x0,%eax
8010989e:	e9 d4 00 00 00       	jmp    80109977 <writeToSwapFileFunction+0x1a6>
  // search for the PTE of the previous page
  pte_t *pte_temp = walkpgdir(proc->pgdir, (void*)pageToWrite->virtualAdress, 0);
801098a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098a6:	8b 10                	mov    (%eax),%edx
801098a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098ae:	8b 40 04             	mov    0x4(%eax),%eax
801098b1:	83 ec 04             	sub    $0x4,%esp
801098b4:	6a 00                	push   $0x0
801098b6:	52                   	push   %edx
801098b7:	50                   	push   %eax
801098b8:	e8 1d f1 ff ff       	call   801089da <walkpgdir>
801098bd:	83 c4 10             	add    $0x10,%esp
801098c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (!*pte_temp)
801098c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098c6:	8b 00                	mov    (%eax),%eax
801098c8:	85 c0                	test   %eax,%eax
801098ca:	75 0d                	jne    801098d9 <writeToSwapFileFunction+0x108>
    panic("writeToSwapFileFunction: pte1 is empty");
801098cc:	83 ec 0c             	sub    $0xc,%esp
801098cf:	68 c0 a6 10 80       	push   $0x8010a6c0
801098d4:	e8 8d 6c ff ff       	call   80100566 <panic>
 // cprintf("swapping out address: %x\n", pageToWrite->virtualAdress);
  kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, pageToWrite->virtualAdress, 0))));
801098d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098dc:	8b 10                	mov    (%eax),%edx
801098de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098e4:	8b 40 04             	mov    0x4(%eax),%eax
801098e7:	83 ec 04             	sub    $0x4,%esp
801098ea:	6a 00                	push   $0x0
801098ec:	52                   	push   %edx
801098ed:	50                   	push   %eax
801098ee:	e8 e7 f0 ff ff       	call   801089da <walkpgdir>
801098f3:	83 c4 10             	add    $0x10,%esp
801098f6:	8b 00                	mov    (%eax),%eax
801098f8:	05 00 00 00 80       	add    $0x80000000,%eax
801098fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109902:	83 ec 0c             	sub    $0xc,%esp
80109905:	50                   	push   %eax
80109906:	e8 9a 9a ff ff       	call   801033a5 <kfree>
8010990b:	83 c4 10             	add    $0x10,%esp
  // set the default flags 
  *pte_temp = PTE_W | PTE_U | PTE_PG;
8010990e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109911:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
  
  proc->totalSwappedCount++; //update totalPagesCount
80109917:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010991d:	8b 90 c0 01 00 00    	mov    0x1c0(%eax),%edx
80109923:	83 c2 01             	add    $0x1,%edx
80109926:	89 90 c0 01 00 00    	mov    %edx,0x1c0(%eax)
  proc->pagesInDisc++;  //update pages in disc
8010992c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109932:	8b 90 b8 01 00 00    	mov    0x1b8(%eax),%edx
80109938:	83 c2 01             	add    $0x1,%edx
8010993b:	89 90 b8 01 00 00    	mov    %edx,0x1b8(%eax)
  lcr3(v2p(proc->pgdir)); // change the register
80109941:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109947:	8b 40 04             	mov    0x4(%eax),%eax
8010994a:	83 ec 0c             	sub    $0xc,%esp
8010994d:	50                   	push   %eax
8010994e:	e8 f8 eb ff ff       	call   8010854b <v2p>
80109953:	83 c4 10             	add    $0x10,%esp
80109956:	83 ec 0c             	sub    $0xc,%esp
80109959:	50                   	push   %eax
8010995a:	e8 e0 eb ff ff       	call   8010853f <lcr3>
8010995f:	83 c4 10             	add    $0x10,%esp

  pageToWrite->virtualAdress = va; // change the swapped page to be the new one
80109962:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109965:	8b 55 08             	mov    0x8(%ebp),%edx
80109968:	89 10                	mov    %edx,(%eax)
  pageToWrite->accessCount = 0; //reset accessCount
8010996a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010996d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  return pageToWrite;
80109974:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109977:	c9                   	leave  
80109978:	c3                   	ret    

80109979 <insertNewPage>:


// this function record a new page
void insertNewPage(char *va) {
80109979:	55                   	push   %ebp
8010997a:	89 e5                	mov    %esp,%ebp
8010997c:	83 ec 18             	sub    $0x18,%esp
  int i;
  //looking for unused physical index 
  for (i = 0; i < MAX_PSYC_PAGES; i++)
8010997f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109986:	eb 1f                	jmp    801099a7 <insertNewPage+0x2e>
    if (proc->physical[i].virtualAdress == (char*)0xffffffff)
80109988:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010998e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109991:	83 c2 0b             	add    $0xb,%edx
80109994:	c1 e2 04             	shl    $0x4,%edx
80109997:	01 d0                	add    %edx,%eax
80109999:	83 c0 0c             	add    $0xc,%eax
8010999c:	8b 00                	mov    (%eax),%eax
8010999e:	83 f8 ff             	cmp    $0xffffffff,%eax
801099a1:	74 17                	je     801099ba <insertNewPage+0x41>

// this function record a new page
void insertNewPage(char *va) {
  int i;
  //looking for unused physical index 
  for (i = 0; i < MAX_PSYC_PAGES; i++)
801099a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801099a7:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801099ab:	7e db                	jle    80109988 <insertNewPage+0xf>
    if (proc->physical[i].virtualAdress == (char*)0xffffffff)
      goto foundSpace;
   panic("insertNewPage: no free pages");
801099ad:	83 ec 0c             	sub    $0xc,%esp
801099b0:	68 e7 a6 10 80       	push   $0x8010a6e7
801099b5:	e8 ac 6b ff ff       	call   80100566 <panic>
void insertNewPage(char *va) {
  int i;
  //looking for unused physical index 
  for (i = 0; i < MAX_PSYC_PAGES; i++)
    if (proc->physical[i].virtualAdress == (char*)0xffffffff)
      goto foundSpace;
801099ba:	90                   	nop
   panic("insertNewPage: no free pages");
  // enter the new physicalPages in the head of the list
foundSpace:
	//cprintf("insert new page : found empty space in position %d\n",i);
	// first set the page fields
  proc->physical[i].virtualAdress = va; // set the virtualAdress
801099bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099c4:	83 c2 0b             	add    $0xb,%edx
801099c7:	c1 e2 04             	shl    $0x4,%edx
801099ca:	01 d0                	add    %edx,%eax
801099cc:	8d 50 0c             	lea    0xc(%eax),%edx
801099cf:	8b 45 08             	mov    0x8(%ebp),%eax
801099d2:	89 02                	mov    %eax,(%edx)
  proc->physical[i].accessCount = 0; // reset the accessCount to 0 for a new page.
801099d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099dd:	83 c2 0b             	add    $0xb,%edx
801099e0:	c1 e2 04             	shl    $0x4,%edx
801099e3:	01 d0                	add    %edx,%eax
801099e5:	83 c0 10             	add    $0x10,%eax
801099e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  proc->physical[i].next = proc->head; // set the new page to point at head
801099ee:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801099f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099fb:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109a01:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80109a04:	83 c1 0b             	add    $0xb,%ecx
80109a07:	c1 e1 04             	shl    $0x4,%ecx
80109a0a:	01 ca                	add    %ecx,%edx
80109a0c:	83 c2 14             	add    $0x14,%edx
80109a0f:	89 02                	mov    %eax,(%edx)
  proc->physical[i].prev = 0; // the prev will be null
80109a11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a17:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a1a:	83 c2 0b             	add    $0xb,%edx
80109a1d:	c1 e2 04             	shl    $0x4,%edx
80109a20:	01 d0                	add    %edx,%eax
80109a22:	83 c0 18             	add    $0x18,%eax
80109a25:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  // update list
  if(proc->head != 0) // if head is not null , set head prev to point at our page
80109a2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a31:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109a37:	85 c0                	test   %eax,%eax
80109a39:	74 26                	je     80109a61 <insertNewPage+0xe8>
    proc->head->prev = &proc->physical[i];
80109a3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a41:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109a47:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109a4e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80109a51:	83 c1 0b             	add    $0xb,%ecx
80109a54:	c1 e1 04             	shl    $0x4,%ecx
80109a57:	01 ca                	add    %ecx,%edx
80109a59:	83 c2 0c             	add    $0xc,%edx
80109a5c:	89 50 0c             	mov    %edx,0xc(%eax)
80109a5f:	eb 21                	jmp    80109a82 <insertNewPage+0x109>
  else //head is null so first link inserted is also the tail
    proc->tail = &proc->physical[i];
80109a61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a67:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109a6e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80109a71:	83 c1 0b             	add    $0xb,%ecx
80109a74:	c1 e1 04             	shl    $0x4,%ecx
80109a77:	01 ca                	add    %ecx,%edx
80109a79:	83 c2 0c             	add    $0xc,%edx
80109a7c:	89 90 b0 01 00 00    	mov    %edx,0x1b0(%eax)
  proc->head = &proc->physical[i]; //know set head to the new page
80109a82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a88:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109a8f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80109a92:	83 c1 0b             	add    $0xb,%ecx
80109a95:	c1 e1 04             	shl    $0x4,%ecx
80109a98:	01 ca                	add    %ecx,%edx
80109a9a:	83 c2 0c             	add    $0xc,%edx
80109a9d:	89 90 ac 01 00 00    	mov    %edx,0x1ac(%eax)
  proc->pagesInPhMem++;
80109aa3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109aa9:	8b 90 b4 01 00 00    	mov    0x1b4(%eax),%edx
80109aaf:	83 c2 01             	add    $0x1,%edx
80109ab2:	89 90 b4 01 00 00    	mov    %edx,0x1b4(%eax)
  //cprintf("pages in memory after insert new page %d\n" ,proc->pagesInPhMem);
}
80109ab8:	90                   	nop
80109ab9:	c9                   	leave  
80109aba:	c3                   	ret    

80109abb <swapHelperFunction>:

void swapHelperFunction(void* vaOut, uint vaIn) {
80109abb:	55                   	push   %ebp
80109abc:	89 e5                	mov    %esp,%ebp
80109abe:	81 ec 28 08 00 00    	sub    $0x828,%esp
  int i, j;
  char buf[BUF_SIZE];
  pte_t *pte_out, *pte_in;
  pte_out = walkpgdir(proc->pgdir, vaOut, 0); // take the page table adress to swap into the swapFile
80109ac4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109aca:	8b 40 04             	mov    0x4(%eax),%eax
80109acd:	83 ec 04             	sub    $0x4,%esp
80109ad0:	6a 00                	push   $0x0
80109ad2:	ff 75 08             	pushl  0x8(%ebp)
80109ad5:	50                   	push   %eax
80109ad6:	e8 ff ee ff ff       	call   801089da <walkpgdir>
80109adb:	83 c4 10             	add    $0x10,%esp
80109ade:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (!*pte_out)
80109ae1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ae4:	8b 00                	mov    (%eax),%eax
80109ae6:	85 c0                	test   %eax,%eax
80109ae8:	75 0d                	jne    80109af7 <swapHelperFunction+0x3c>
    panic("swapHelperFunction: pte_out is empty");
80109aea:	83 ec 0c             	sub    $0xc,%esp
80109aed:	68 04 a7 10 80       	push   $0x8010a704
80109af2:	e8 6f 6a ff ff       	call   80100566 <panic>
  //searching for unused disc index 
  for (i = 0; i < MAX_PSYC_PAGES; i++)
80109af7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109afe:	eb 20                	jmp    80109b20 <swapHelperFunction+0x65>
    if (proc->disc[i].virtualAdress == (char*)PTE_ADDR(vaIn))
80109b00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b09:	83 c2 20             	add    $0x20,%edx
80109b0c:	8b 04 90             	mov    (%eax,%edx,4),%eax
80109b0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80109b12:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80109b18:	39 d0                	cmp    %edx,%eax
80109b1a:	74 17                	je     80109b33 <swapHelperFunction+0x78>
  pte_t *pte_out, *pte_in;
  pte_out = walkpgdir(proc->pgdir, vaOut, 0); // take the page table adress to swap into the swapFile
  if (!*pte_out)
    panic("swapHelperFunction: pte_out is empty");
  //searching for unused disc index 
  for (i = 0; i < MAX_PSYC_PAGES; i++)
80109b1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109b20:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80109b24:	7e da                	jle    80109b00 <swapHelperFunction+0x45>
    if (proc->disc[i].virtualAdress == (char*)PTE_ADDR(vaIn))
      goto foundInDisc;
  panic("swapHelperFunction: no slot in disc");
80109b26:	83 ec 0c             	sub    $0xc,%esp
80109b29:	68 2c a7 10 80       	push   $0x8010a72c
80109b2e:	e8 33 6a ff ff       	call   80100566 <panic>
  if (!*pte_out)
    panic("swapHelperFunction: pte_out is empty");
  //searching for unused disc index 
  for (i = 0; i < MAX_PSYC_PAGES; i++)
    if (proc->disc[i].virtualAdress == (char*)PTE_ADDR(vaIn))
      goto foundInDisc;
80109b33:	90                   	nop
  panic("swapHelperFunction: no slot in disc");
foundInDisc:
 //cprintf("swap helper function : found virtual address in position %d\n",i);
  proc->disc[i].virtualAdress  = vaOut; //update relevant fields for the swaped page
80109b34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109b3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b3d:	8d 4a 20             	lea    0x20(%edx),%ecx
80109b40:	8b 55 08             	mov    0x8(%ebp),%edx
80109b43:	89 14 88             	mov    %edx,(%eax,%ecx,4)
  //assign the physical page to addr in the relevant page table
  pte_in = walkpgdir(proc->pgdir, (void*)vaIn, 0);
80109b46:	8b 55 0c             	mov    0xc(%ebp),%edx
80109b49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109b4f:	8b 40 04             	mov    0x4(%eax),%eax
80109b52:	83 ec 04             	sub    $0x4,%esp
80109b55:	6a 00                	push   $0x0
80109b57:	52                   	push   %edx
80109b58:	50                   	push   %eax
80109b59:	e8 7c ee ff ff       	call   801089da <walkpgdir>
80109b5e:	83 c4 10             	add    $0x10,%esp
80109b61:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if (!*pte_in)
80109b64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b67:	8b 00                	mov    (%eax),%eax
80109b69:	85 c0                	test   %eax,%eax
80109b6b:	75 0d                	jne    80109b7a <swapHelperFunction+0xbf>
    panic("swapHelperFunction: pte_in is empty");
80109b6d:	83 ec 0c             	sub    $0xc,%esp
80109b70:	68 50 a7 10 80       	push   $0x8010a750
80109b75:	e8 ec 69 ff ff       	call   80100566 <panic>
  //set new page table entry
  *pte_in = PTE_ADDR(*pte_out) | PTE_U | PTE_W | PTE_P;
80109b7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b7d:	8b 00                	mov    (%eax),%eax
80109b7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b84:	83 c8 07             	or     $0x7,%eax
80109b87:	89 c2                	mov    %eax,%edx
80109b89:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b8c:	89 10                	mov    %edx,(%eax)
  // doing the actual swap 
  for (j = 0; j < 2; j++) {
80109b8e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109b95:	e9 b0 00 00 00       	jmp    80109c4a <swapHelperFunction+0x18f>
    int loc = (i * PGSIZE) + ((PGSIZE / 2) * j);
80109b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b9d:	8d 14 00             	lea    (%eax,%eax,1),%edx
80109ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ba3:	01 d0                	add    %edx,%eax
80109ba5:	c1 e0 0b             	shl    $0xb,%eax
80109ba8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int addroffset = ((PGSIZE / 2) * j);
80109bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bae:	c1 e0 0b             	shl    $0xb,%eax
80109bb1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // set the buffer to zero
    memset(buf, 0, BUF_SIZE);
80109bb4:	83 ec 04             	sub    $0x4,%esp
80109bb7:	68 00 08 00 00       	push   $0x800
80109bbc:	6a 00                	push   $0x0
80109bbe:	8d 85 e0 f7 ff ff    	lea    -0x820(%ebp),%eax
80109bc4:	50                   	push   %eax
80109bc5:	e8 00 c4 ff ff       	call   80105fca <memset>
80109bca:	83 c4 10             	add    $0x10,%esp
   // read from the swap file to the buffer (reading the page we bringing)
    readFromSwapFile(proc, buf, loc, BUF_SIZE);
80109bcd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109bd6:	68 00 08 00 00       	push   $0x800
80109bdb:	52                   	push   %edx
80109bdc:	8d 95 e0 f7 ff ff    	lea    -0x820(%ebp),%edx
80109be2:	52                   	push   %edx
80109be3:	50                   	push   %eax
80109be4:	e8 d5 90 ff ff       	call   80102cbe <readFromSwapFile>
80109be9:	83 c4 10             	add    $0x10,%esp
    // write the page we swapping out to the swapFile
    writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_out)) + addroffset), loc, BUF_SIZE);
80109bec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bf2:	8b 00                	mov    (%eax),%eax
80109bf4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109bf9:	89 c1                	mov    %eax,%ecx
80109bfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bfe:	01 c8                	add    %ecx,%eax
80109c00:	05 00 00 00 80       	add    $0x80000000,%eax
80109c05:	89 c1                	mov    %eax,%ecx
80109c07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c0d:	68 00 08 00 00       	push   $0x800
80109c12:	52                   	push   %edx
80109c13:	51                   	push   %ecx
80109c14:	50                   	push   %eax
80109c15:	e8 77 90 ff ff       	call   80102c91 <writeToSwapFile>
80109c1a:	83 c4 10             	add    $0x10,%esp
    //copy the new page from buff to the main memory
    memmove((void*)(PTE_ADDR(vaIn) + addroffset), (void*)buf, BUF_SIZE);
80109c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109c25:	89 c2                	mov    %eax,%edx
80109c27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c2a:	01 d0                	add    %edx,%eax
80109c2c:	89 c2                	mov    %eax,%edx
80109c2e:	83 ec 04             	sub    $0x4,%esp
80109c31:	68 00 08 00 00       	push   $0x800
80109c36:	8d 85 e0 f7 ff ff    	lea    -0x820(%ebp),%eax
80109c3c:	50                   	push   %eax
80109c3d:	52                   	push   %edx
80109c3e:	e8 46 c4 ff ff       	call   80106089 <memmove>
80109c43:	83 c4 10             	add    $0x10,%esp
  if (!*pte_in)
    panic("swapHelperFunction: pte_in is empty");
  //set new page table entry
  *pte_in = PTE_ADDR(*pte_out) | PTE_U | PTE_W | PTE_P;
  // doing the actual swap 
  for (j = 0; j < 2; j++) {
80109c46:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109c4a:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80109c4e:	0f 8e 46 ff ff ff    	jle    80109b9a <swapHelperFunction+0xdf>
    writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_out)) + addroffset), loc, BUF_SIZE);
    //copy the new page from buff to the main memory
    memmove((void*)(PTE_ADDR(vaIn) + addroffset), (void*)buf, BUF_SIZE);
  }
   // update the flags of the swapped out PGE to : not present, pagedOut, user, writeable
  *pte_out = PTE_U | PTE_W | PTE_PG;
80109c54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c57:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
}
80109c5d:	90                   	nop
80109c5e:	c9                   	leave  
80109c5f:	c3                   	ret    

80109c60 <swapPagesInTrap>:


void swapPagesInTrap(uint addr){
80109c60:	55                   	push   %ebp
80109c61:	89 e5                	mov    %esp,%ebp
80109c63:	83 ec 08             	sub    $0x8,%esp
  //ignore init and shell 
 if (proc->pid <= 2) {
80109c66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c6c:	8b 40 10             	mov    0x10(%eax),%eax
80109c6f:	83 f8 02             	cmp    $0x2,%eax
80109c72:	7f 1a                	jg     80109c8e <swapPagesInTrap+0x2e>
    proc->pagesInPhMem++;
80109c74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c7a:	8b 90 b4 01 00 00    	mov    0x1b4(%eax),%edx
80109c80:	83 c2 01             	add    $0x1,%edx
80109c83:	89 90 b4 01 00 00    	mov    %edx,0x1b4(%eax)
    return;
80109c89:	e9 9f 00 00 00       	jmp    80109d2d <swapPagesInTrap+0xcd>
  }
//check for errors
  if (proc->head == 0 || (proc->head->next == 0))
80109c8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c94:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109c9a:	85 c0                	test   %eax,%eax
80109c9c:	74 13                	je     80109cb1 <swapPagesInTrap+0x51>
80109c9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ca4:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109caa:	8b 40 08             	mov    0x8(%eax),%eax
80109cad:	85 c0                	test   %eax,%eax
80109caf:	75 0d                	jne    80109cbe <swapPagesInTrap+0x5e>
    panic("writeToSwapFileFunction: proc->head is NULL or single page in physical memory");
80109cb1:	83 ec 0c             	sub    $0xc,%esp
80109cb4:	68 3c a6 10 80       	push   $0x8010a63c
80109cb9:	e8 a8 68 ff ff       	call   80100566 <panic>

#if LIFO
  swapHelperFunction(proc->head->virtualAdress,addr);
  proc->head->virtualAdress = (char*)PTE_ADDR(addr); //update head 
#elif SCFIFO
  changeToScFifo(); 
80109cbe:	e8 d5 f9 ff ff       	call   80109698 <changeToScFifo>
   swapHelperFunction(proc->head->virtualAdress,addr);
80109cc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109cc9:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109ccf:	8b 00                	mov    (%eax),%eax
80109cd1:	83 ec 08             	sub    $0x8,%esp
80109cd4:	ff 75 08             	pushl  0x8(%ebp)
80109cd7:	50                   	push   %eax
80109cd8:	e8 de fd ff ff       	call   80109abb <swapHelperFunction>
80109cdd:	83 c4 10             	add    $0x10,%esp
  proc->head->virtualAdress = (char*)PTE_ADDR(addr);//update head 
80109ce0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ce6:	8b 80 ac 01 00 00    	mov    0x1ac(%eax),%eax
80109cec:	8b 55 08             	mov    0x8(%ebp),%edx
80109cef:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80109cf5:	89 10                	mov    %edx,(%eax)
  int index = findMinAccessed(); //find minimum accessed index to be swapped
   swapHelperFunction( proc->physical[index].virtualAdress,addr); //swap
  proc->physical[index].virtualAdress = (char*)PTE_ADDR(addr); //update head
#endif

  lcr3(v2p(proc->pgdir)); // update the page directory
80109cf7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109cfd:	8b 40 04             	mov    0x4(%eax),%eax
80109d00:	83 ec 0c             	sub    $0xc,%esp
80109d03:	50                   	push   %eax
80109d04:	e8 42 e8 ff ff       	call   8010854b <v2p>
80109d09:	83 c4 10             	add    $0x10,%esp
80109d0c:	83 ec 0c             	sub    $0xc,%esp
80109d0f:	50                   	push   %eax
80109d10:	e8 2a e8 ff ff       	call   8010853f <lcr3>
80109d15:	83 c4 10             	add    $0x10,%esp
   proc->totalSwappedCount++;
80109d18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d1e:	8b 90 c0 01 00 00    	mov    0x1c0(%eax),%edx
80109d24:	83 c2 01             	add    $0x1,%edx
80109d27:	89 90 c0 01 00 00    	mov    %edx,0x1c0(%eax)
}
80109d2d:	c9                   	leave  
80109d2e:	c3                   	ret    
