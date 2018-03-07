
_myMemTest:     file format elf32-i386


Disassembly of section .text:

00000000 <passSomeTime>:
#define DEBUG 0

char *arr[14];


void passSomeTime() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
	int i = 0, j = 0 , k;
   6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
   d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for(i = 0; i < 1000; i++) {
  14:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1b:	eb 59                	jmp    76 <passSomeTime+0x76>
		for(j = 1; j < 100; j++) {
  1d:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
  24:	eb 46                	jmp    6c <passSomeTime+0x6c>
			k = ((i/j +4 )%5) *345 / 6;
  26:	8b 45 fc             	mov    -0x4(%ebp),%eax
  29:	99                   	cltd   
  2a:	f7 7d f8             	idivl  -0x8(%ebp)
  2d:	8d 48 04             	lea    0x4(%eax),%ecx
  30:	ba 67 66 66 66       	mov    $0x66666667,%edx
  35:	89 c8                	mov    %ecx,%eax
  37:	f7 ea                	imul   %edx
  39:	d1 fa                	sar    %edx
  3b:	89 c8                	mov    %ecx,%eax
  3d:	c1 f8 1f             	sar    $0x1f,%eax
  40:	29 c2                	sub    %eax,%edx
  42:	89 d0                	mov    %edx,%eax
  44:	c1 e0 02             	shl    $0x2,%eax
  47:	01 d0                	add    %edx,%eax
  49:	29 c1                	sub    %eax,%ecx
  4b:	89 ca                	mov    %ecx,%edx
  4d:	69 ca 59 01 00 00    	imul   $0x159,%edx,%ecx
  53:	ba ab aa aa 2a       	mov    $0x2aaaaaab,%edx
  58:	89 c8                	mov    %ecx,%eax
  5a:	f7 ea                	imul   %edx
  5c:	89 c8                	mov    %ecx,%eax
  5e:	c1 f8 1f             	sar    $0x1f,%eax
  61:	29 c2                	sub    %eax,%edx
  63:	89 d0                	mov    %edx,%eax
  65:	89 45 f4             	mov    %eax,-0xc(%ebp)


void passSomeTime() {
	int i = 0, j = 0 , k;
	for(i = 0; i < 1000; i++) {
		for(j = 1; j < 100; j++) {
  68:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  6c:	83 7d f8 63          	cmpl   $0x63,-0x8(%ebp)
  70:	7e b4                	jle    26 <passSomeTime+0x26>
char *arr[14];


void passSomeTime() {
	int i = 0, j = 0 , k;
	for(i = 0; i < 1000; i++) {
  72:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  76:	81 7d fc e7 03 00 00 	cmpl   $0x3e7,-0x4(%ebp)
  7d:	7e 9e                	jle    1d <passSomeTime+0x1d>
		for(j = 1; j < 100; j++) {
			k = ((i/j +4 )%5) *345 / 6;
		}
	}
	i = k/2;
  7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  82:	89 c2                	mov    %eax,%edx
  84:	c1 ea 1f             	shr    $0x1f,%edx
  87:	01 d0                	add    %edx,%eax
  89:	d1 f8                	sar    %eax
  8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	j = i*3;
  8e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  91:	89 d0                	mov    %edx,%eax
  93:	01 c0                	add    %eax,%eax
  95:	01 d0                	add    %edx,%eax
  97:	89 45 f8             	mov    %eax,-0x8(%ebp)
}
  9a:	90                   	nop
  9b:	c9                   	leave  
  9c:	c3                   	ret    

0000009d <lifoTest>:

void lifoTest()
{
  9d:	55                   	push   %ebp
  9e:	89 e5                	mov    %esp,%ebp
  a0:	83 ec 18             	sub    $0x18,%esp
	char input[10];
	int i;
	// Allocate 12 physical pages
	for (i = 0; i < 12; ++i) {
  a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  aa:	eb 20                	jmp    cc <lifoTest+0x2f>
		arr[i] = sbrk(PGSIZE);
  ac:	83 ec 0c             	sub    $0xc,%esp
  af:	68 00 10 00 00       	push   $0x1000
  b4:	e8 f1 07 00 00       	call   8aa <sbrk>
  b9:	83 c4 10             	add    $0x10,%esp
  bc:	89 c2                	mov    %eax,%edx
  be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c1:	89 14 85 c0 12 00 00 	mov    %edx,0x12c0(,%eax,4)
void lifoTest()
{
	char input[10];
	int i;
	// Allocate 12 physical pages
	for (i = 0; i < 12; ++i) {
  c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  cc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
  d0:	7e da                	jle    ac <lifoTest+0xf>
		arr[i] = sbrk(PGSIZE);
	}
	printf(1, "we now have 15 pages.\n");
  d2:	83 ec 08             	sub    $0x8,%esp
  d5:	68 50 0d 00 00       	push   $0xd50
  da:	6a 01                	push   $0x1
  dc:	e8 b8 08 00 00       	call   999 <printf>
  e1:	83 c4 10             	add    $0x10,%esp

	// now we have 16 page
	arr[12] = sbrk(PGSIZE);
  e4:	83 ec 0c             	sub    $0xc,%esp
  e7:	68 00 10 00 00       	push   $0x1000
  ec:	e8 b9 07 00 00       	call   8aa <sbrk>
  f1:	83 c4 10             	add    $0x10,%esp
  f4:	a3 f0 12 00 00       	mov    %eax,0x12f0
	printf(1, "we now have 16 pages, there wiil be a page fault now.\n");
  f9:	83 ec 08             	sub    $0x8,%esp
  fc:	68 68 0d 00 00       	push   $0xd68
 101:	6a 01                	push   $0x1
 103:	e8 91 08 00 00       	call   999 <printf>
 108:	83 c4 10             	add    $0x10,%esp

	// there will now be 17 pages
	arr[13] = sbrk(PGSIZE);
 10b:	83 ec 0c             	sub    $0xc,%esp
 10e:	68 00 10 00 00       	push   $0x1000
 113:	e8 92 07 00 00       	call   8aa <sbrk>
 118:	83 c4 10             	add    $0x10,%esp
 11b:	a3 f4 12 00 00       	mov    %eax,0x12f4
	printf(1, "we now have 17 pages, there wiil be a page fault now.\n");
 120:	83 ec 08             	sub    $0x8,%esp
 123:	68 a0 0d 00 00       	push   $0xda0
 128:	6a 01                	push   $0x1
 12a:	e8 6a 08 00 00       	call   999 <printf>
 12f:	83 c4 10             	add    $0x10,%esp

	/*
	when 13 entered 12 got swapped - because we are in LIFO , in all our iteration 12 and 13 will swap
 	therefor there will be 10 page fault/
	*/
	for (i = 0; i < 10; i++) {
 132:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 139:	eb 20                	jmp    15b <lifoTest+0xbe>
		if(i%2 == 0)
 13b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 13e:	83 e0 01             	and    $0x1,%eax
 141:	85 c0                	test   %eax,%eax
 143:	75 0a                	jne    14f <lifoTest+0xb2>
			arr[12][0] = '1';
 145:	a1 f0 12 00 00       	mov    0x12f0,%eax
 14a:	c6 00 31             	movb   $0x31,(%eax)
 14d:	eb 08                	jmp    157 <lifoTest+0xba>
		else
			arr[13][0] = '1';
 14f:	a1 f4 12 00 00       	mov    0x12f4,%eax
 154:	c6 00 31             	movb   $0x31,(%eax)

	/*
	when 13 entered 12 got swapped - because we are in LIFO , in all our iteration 12 and 13 will swap
 	therefor there will be 10 page fault/
	*/
	for (i = 0; i < 10; i++) {
 157:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 15b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 15f:	7e da                	jle    13b <lifoTest+0x9e>
		if(i%2 == 0)
			arr[12][0] = '1';
		else
			arr[13][0] = '1';
	}
	printf(1, "you now can check statistic \n");
 161:	83 ec 08             	sub    $0x8,%esp
 164:	68 d7 0d 00 00       	push   $0xdd7
 169:	6a 01                	push   $0x1
 16b:	e8 29 08 00 00       	call   999 <printf>
 170:	83 c4 10             	add    $0x10,%esp
	gets(input, 10);
 173:	83 ec 08             	sub    $0x8,%esp
 176:	6a 0a                	push   $0xa
 178:	8d 45 ea             	lea    -0x16(%ebp),%eax
 17b:	50                   	push   %eax
 17c:	e8 53 05 00 00       	call   6d4 <gets>
 181:	83 c4 10             	add    $0x10,%esp

	if (fork() == 0) {
 184:	e8 91 06 00 00       	call   81a <fork>
 189:	85 c0                	test   %eax,%eax
 18b:	75 42                	jne    1cf <lifoTest+0x132>
		printf(1, "this is the child!\n");
 18d:	83 ec 08             	sub    $0x8,%esp
 190:	68 f5 0d 00 00       	push   $0xdf5
 195:	6a 01                	push   $0x1
 197:	e8 fd 07 00 00       	call   999 <printf>
 19c:	83 c4 10             	add    $0x10,%esp
		gets(input, 10);
 19f:	83 ec 08             	sub    $0x8,%esp
 1a2:	6a 0a                	push   $0xa
 1a4:	8d 45 ea             	lea    -0x16(%ebp),%eax
 1a7:	50                   	push   %eax
 1a8:	e8 27 05 00 00       	call   6d4 <gets>
 1ad:	83 c4 10             	add    $0x10,%esp

		// causing a page fault
		arr[12][0] = '1';
 1b0:	a1 f0 12 00 00       	mov    0x12f0,%eax
 1b5:	c6 00 31             	movb   $0x31,(%eax)
		printf(1, "A page fault should have occurred.\n");
 1b8:	83 ec 08             	sub    $0x8,%esp
 1bb:	68 0c 0e 00 00       	push   $0xe0c
 1c0:	6a 01                	push   $0x1
 1c2:	e8 d2 07 00 00       	call   999 <printf>
 1c7:	83 c4 10             	add    $0x10,%esp
		exit();
 1ca:	e8 53 06 00 00       	call   822 <exit>
	}
	else {
		wait();
 1cf:	e8 56 06 00 00       	call   82a <wait>
		// Deallocate all the pages.
		//sbrk(-14 * PGSIZE);
		printf(1, "we are in the father!\n");
 1d4:	83 ec 08             	sub    $0x8,%esp
 1d7:	68 30 0e 00 00       	push   $0xe30
 1dc:	6a 01                	push   $0x1
 1de:	e8 b6 07 00 00       	call   999 <printf>
 1e3:	83 c4 10             	add    $0x10,%esp
	}
}
 1e6:	90                   	nop
 1e7:	c9                   	leave  
 1e8:	c3                   	ret    

000001e9 <scFifoTest>:

void scFifoTest()
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	83 ec 18             	sub    $0x18,%esp
	int i;
	char input[10];
	// Allocate 11 physical pages
	for (i = 0; i < 11; ++i) {
 1ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1f6:	eb 20                	jmp    218 <scFifoTest+0x2f>
		arr[i] = sbrk(PGSIZE);
 1f8:	83 ec 0c             	sub    $0xc,%esp
 1fb:	68 00 10 00 00       	push   $0x1000
 200:	e8 a5 06 00 00       	call   8aa <sbrk>
 205:	83 c4 10             	add    $0x10,%esp
 208:	89 c2                	mov    %eax,%edx
 20a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20d:	89 14 85 c0 12 00 00 	mov    %edx,0x12c0(,%eax,4)
void scFifoTest()
{
	int i;
	char input[10];
	// Allocate 11 physical pages
	for (i = 0; i < 11; ++i) {
 214:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 218:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
 21c:	7e da                	jle    1f8 <scFifoTest+0xf>
		arr[i] = sbrk(PGSIZE);
	}
	printf(1, "we now have 15 pages.\n");
 21e:	83 ec 08             	sub    $0x8,%esp
 221:	68 50 0d 00 00       	push   $0xd50
 226:	6a 01                	push   $0x1
 228:	e8 6c 07 00 00       	call   999 <printf>
 22d:	83 c4 10             	add    $0x10,%esp

	// now we have 16 page
	arr[11] = sbrk(PGSIZE);
 230:	83 ec 0c             	sub    $0xc,%esp
 233:	68 00 10 00 00       	push   $0x1000
 238:	e8 6d 06 00 00       	call   8aa <sbrk>
 23d:	83 c4 10             	add    $0x10,%esp
 240:	a3 ec 12 00 00       	mov    %eax,0x12ec
	printf(1, "we now have 16 pages, there wiil be a page fault now.\n");
 245:	83 ec 08             	sub    $0x8,%esp
 248:	68 68 0d 00 00       	push   $0xd68
 24d:	6a 01                	push   $0x1
 24f:	e8 45 07 00 00       	call   999 <printf>
 254:	83 c4 10             	add    $0x10,%esp

	// there will now be 17 pages
	arr[12] = sbrk(PGSIZE);
 257:	83 ec 0c             	sub    $0xc,%esp
 25a:	68 00 10 00 00       	push   $0x1000
 25f:	e8 46 06 00 00       	call   8aa <sbrk>
 264:	83 c4 10             	add    $0x10,%esp
 267:	a3 f0 12 00 00       	mov    %eax,0x12f0
	printf(1, "we now have 17 pages, there will be a page fault now.\n");
 26c:	83 ec 08             	sub    $0x8,%esp
 26f:	68 48 0e 00 00       	push   $0xe48
 274:	6a 01                	push   $0x1
 276:	e8 1e 07 00 00       	call   999 <printf>
 27b:	83 c4 10             	add    $0x10,%esp

	/*
	we expect 5 page fault . the next page to swap is 4 (not acsess) and we incerment
	to the next one and every time there will be a page fault
	*/
	for (i = 0; i < 5; i++) {
 27e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 285:	eb 11                	jmp    298 <scFifoTest+0xaf>
		arr[i][0] = '1';
 287:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28a:	8b 04 85 c0 12 00 00 	mov    0x12c0(,%eax,4),%eax
 291:	c6 00 31             	movb   $0x31,(%eax)

	/*
	we expect 5 page fault . the next page to swap is 4 (not acsess) and we incerment
	to the next one and every time there will be a page fault
	*/
	for (i = 0; i < 5; i++) {
 294:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 298:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 29c:	7e e9                	jle    287 <scFifoTest+0x9e>
		arr[i][0] = '1';
	}
		printf(1, "you now can check statistic \n");
 29e:	83 ec 08             	sub    $0x8,%esp
 2a1:	68 d7 0d 00 00       	push   $0xdd7
 2a6:	6a 01                	push   $0x1
 2a8:	e8 ec 06 00 00       	call   999 <printf>
 2ad:	83 c4 10             	add    $0x10,%esp
	gets(input, 10);
 2b0:	83 ec 08             	sub    $0x8,%esp
 2b3:	6a 0a                	push   $0xa
 2b5:	8d 45 ea             	lea    -0x16(%ebp),%eax
 2b8:	50                   	push   %eax
 2b9:	e8 16 04 00 00       	call   6d4 <gets>
 2be:	83 c4 10             	add    $0x10,%esp

	if (fork() == 0) {
 2c1:	e8 54 05 00 00       	call   81a <fork>
 2c6:	85 c0                	test   %eax,%eax
 2c8:	75 42                	jne    30c <scFifoTest+0x123>
		printf(1, "this is the child!\n");
 2ca:	83 ec 08             	sub    $0x8,%esp
 2cd:	68 f5 0d 00 00       	push   $0xdf5
 2d2:	6a 01                	push   $0x1
 2d4:	e8 c0 06 00 00       	call   999 <printf>
 2d9:	83 c4 10             	add    $0x10,%esp
		gets(input, 10);
 2dc:	83 ec 08             	sub    $0x8,%esp
 2df:	6a 0a                	push   $0xa
 2e1:	8d 45 ea             	lea    -0x16(%ebp),%eax
 2e4:	50                   	push   %eax
 2e5:	e8 ea 03 00 00       	call   6d4 <gets>
 2ea:	83 c4 10             	add    $0x10,%esp
		// causing a page fault
		arr[5][0] = '1';
 2ed:	a1 d4 12 00 00       	mov    0x12d4,%eax
 2f2:	c6 00 31             	movb   $0x31,(%eax)
		printf(1, "A Page fault should have occurred in child proccess.\n");
 2f5:	83 ec 08             	sub    $0x8,%esp
 2f8:	68 80 0e 00 00       	push   $0xe80
 2fd:	6a 01                	push   $0x1
 2ff:	e8 95 06 00 00       	call   999 <printf>
 304:	83 c4 10             	add    $0x10,%esp
		exit();
 307:	e8 16 05 00 00       	call   822 <exit>
	}
	else {
		wait();
 30c:	e8 19 05 00 00       	call   82a <wait>
		/*
		Deallocate all the pages.
		we can see here that the page-fault of the child did't effect the father proccess
		*/
		//sbrk(-13 * PGSIZE);
		printf(1, "we are in the father!\n");
 311:	83 ec 08             	sub    $0x8,%esp
 314:	68 30 0e 00 00       	push   $0xe30
 319:	6a 01                	push   $0x1
 31b:	e8 79 06 00 00       	call   999 <printf>
 320:	83 c4 10             	add    $0x10,%esp
	}
}
 323:	90                   	nop
 324:	c9                   	leave  
 325:	c3                   	ret    

00000326 <lapTest>:

void lapTest()
{
 326:	55                   	push   %ebp
 327:	89 e5                	mov    %esp,%ebp
 329:	83 ec 28             	sub    $0x28,%esp
	int i,j;
	char input[10];
	// Allocate another 11 pages
	for (i = 0; i < 11; ++i) {
 32c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 333:	eb 20                	jmp    355 <lapTest+0x2f>
		arr[i] = sbrk(PGSIZE);
 335:	83 ec 0c             	sub    $0xc,%esp
 338:	68 00 10 00 00       	push   $0x1000
 33d:	e8 68 05 00 00       	call   8aa <sbrk>
 342:	83 c4 10             	add    $0x10,%esp
 345:	89 c2                	mov    %eax,%edx
 347:	8b 45 f4             	mov    -0xc(%ebp),%eax
 34a:	89 14 85 c0 12 00 00 	mov    %edx,0x12c0(,%eax,4)
void lapTest()
{
	int i,j;
	char input[10];
	// Allocate another 11 pages
	for (i = 0; i < 11; ++i) {
 351:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 355:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
 359:	7e da                	jle    335 <lapTest+0xf>
		arr[i] = sbrk(PGSIZE);
	}
	printf(1, "all physical pages are taken.\n");
 35b:	83 ec 08             	sub    $0x8,%esp
 35e:	68 b8 0e 00 00       	push   $0xeb8
 363:	6a 01                	push   $0x1
 365:	e8 2f 06 00 00       	call   999 <printf>
 36a:	83 c4 10             	add    $0x10,%esp

	// access arr[0] 1 time, arr[1] 2 times an so on...
	for(i = 0; i < 11; i++){
 36d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 374:	eb 3d                	jmp    3b3 <lapTest+0x8d>
		for(j = 0; j < i+1; j++) {
 376:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 37d:	eb 25                	jmp    3a4 <lapTest+0x7e>
			arr[i][j] = 'k';
 37f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 382:	8b 14 85 c0 12 00 00 	mov    0x12c0(,%eax,4),%edx
 389:	8b 45 f0             	mov    -0x10(%ebp),%eax
 38c:	01 d0                	add    %edx,%eax
 38e:	c6 00 6b             	movb   $0x6b,(%eax)
			passSomeTime();
 391:	e8 6a fc ff ff       	call   0 <passSomeTime>
      passSomeTime();
 396:	e8 65 fc ff ff       	call   0 <passSomeTime>
      passSomeTime();
 39b:	e8 60 fc ff ff       	call   0 <passSomeTime>
	}
	printf(1, "all physical pages are taken.\n");

	// access arr[0] 1 time, arr[1] 2 times an so on...
	for(i = 0; i < 11; i++){
		for(j = 0; j < i+1; j++) {
 3a0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 3a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a7:	83 c0 01             	add    $0x1,%eax
 3aa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
 3ad:	7f d0                	jg     37f <lapTest+0x59>
		arr[i] = sbrk(PGSIZE);
	}
	printf(1, "all physical pages are taken.\n");

	// access arr[0] 1 time, arr[1] 2 times an so on...
	for(i = 0; i < 11; i++){
 3af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3b3:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
 3b7:	7e bd                	jle    376 <lapTest+0x50>
      passSomeTime();
      passSomeTime();
		}
	}
	// there is 16 pages
	arr[11] = sbrk(PGSIZE);
 3b9:	83 ec 0c             	sub    $0xc,%esp
 3bc:	68 00 10 00 00       	push   $0x1000
 3c1:	e8 e4 04 00 00       	call   8aa <sbrk>
 3c6:	83 c4 10             	add    $0x10,%esp
 3c9:	a3 ec 12 00 00       	mov    %eax,0x12ec
	printf(1, "there is 16 pages now.\n");
 3ce:	83 ec 08             	sub    $0x8,%esp
 3d1:	68 d7 0e 00 00       	push   $0xed7
 3d6:	6a 01                	push   $0x1
 3d8:	e8 bc 05 00 00       	call   999 <printf>
 3dd:	83 c4 10             	add    $0x10,%esp

	//after this 11 is not consider
	for(i = 0; i < 20; i++) {
 3e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3e7:	eb 2f                	jmp    418 <lapTest+0xf2>
		arr[11][i] = '1';
 3e9:	8b 15 ec 12 00 00    	mov    0x12ec,%edx
 3ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f2:	01 d0                	add    %edx,%eax
 3f4:	c6 00 31             	movb   $0x31,(%eax)
		passSomeTime();
 3f7:	e8 04 fc ff ff       	call   0 <passSomeTime>
   passSomeTime();
 3fc:	e8 ff fb ff ff       	call   0 <passSomeTime>
   passSomeTime();
 401:	e8 fa fb ff ff       	call   0 <passSomeTime>
		arr[11][i] = '1';
 406:	8b 15 ec 12 00 00    	mov    0x12ec,%edx
 40c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40f:	01 d0                	add    %edx,%eax
 411:	c6 00 31             	movb   $0x31,(%eax)
	// there is 16 pages
	arr[11] = sbrk(PGSIZE);
	printf(1, "there is 16 pages now.\n");

	//after this 11 is not consider
	for(i = 0; i < 20; i++) {
 414:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 418:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
 41c:	7e cb                	jle    3e9 <lapTest+0xc3>
   passSomeTime();
		arr[11][i] = '1';
	}

	// now we have 17 pages
	arr[12] = sbrk(PGSIZE);
 41e:	83 ec 0c             	sub    $0xc,%esp
 421:	68 00 10 00 00       	push   $0x1000
 426:	e8 7f 04 00 00       	call   8aa <sbrk>
 42b:	83 c4 10             	add    $0x10,%esp
 42e:	a3 f0 12 00 00       	mov    %eax,0x12f0
	printf(1, "there is now 17 pagese, no page fault should occure\n");
 433:	83 ec 08             	sub    $0x8,%esp
 436:	68 f0 0e 00 00       	push   $0xef0
 43b:	6a 01                	push   $0x1
 43d:	e8 57 05 00 00       	call   999 <printf>
 442:	83 c4 10             	add    $0x10,%esp

	gets(input, 10);
 445:	83 ec 08             	sub    $0x8,%esp
 448:	6a 0a                	push   $0xa
 44a:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 44d:	50                   	push   %eax
 44e:	e8 81 02 00 00       	call   6d4 <gets>
 453:	83 c4 10             	add    $0x10,%esp
	//we access a lot of times to arr[12] because we want him to be "out of the game"
	for(i = 0; i < 20; i++) {
 456:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 45d:	eb 2f                	jmp    48e <lapTest+0x168>
		arr[12][i] = '1';
 45f:	8b 15 f0 12 00 00    	mov    0x12f0,%edx
 465:	8b 45 f4             	mov    -0xc(%ebp),%eax
 468:	01 d0                	add    %edx,%eax
 46a:	c6 00 31             	movb   $0x31,(%eax)
		passSomeTime();
 46d:	e8 8e fb ff ff       	call   0 <passSomeTime>
   passSomeTime();
 472:	e8 89 fb ff ff       	call   0 <passSomeTime>
   passSomeTime();
 477:	e8 84 fb ff ff       	call   0 <passSomeTime>
		arr[12][i] = '1';
 47c:	8b 15 f0 12 00 00    	mov    0x12f0,%edx
 482:	8b 45 f4             	mov    -0xc(%ebp),%eax
 485:	01 d0                	add    %edx,%eax
 487:	c6 00 31             	movb   $0x31,(%eax)
	arr[12] = sbrk(PGSIZE);
	printf(1, "there is now 17 pagese, no page fault should occure\n");

	gets(input, 10);
	//we access a lot of times to arr[12] because we want him to be "out of the game"
	for(i = 0; i < 20; i++) {
 48a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 48e:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
 492:	7e cb                	jle    45f <lapTest+0x139>
	/*
	Access page (arr[0]), causing a PGFLT, since it is in the swap file. It would be
	swapped with page of arr[1] because we accessed this page only twice. Page of arr[1] is accessed next, so another PGFLT is invoked,
	and this process repeats a total of 5 times.
	*/
	for (i = 0; i < 5; i++) {
 494:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 49b:	eb 63                	jmp    500 <lapTest+0x1da>
		if(i > 0){
 49d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4a1:	7e 4c                	jle    4ef <lapTest+0x1c9>
			for(j = 0; j < 20; j++) {
 4a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4aa:	eb 3d                	jmp    4e9 <lapTest+0x1c3>
			arr[i-1][j] = '1';
 4ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4af:	83 e8 01             	sub    $0x1,%eax
 4b2:	8b 14 85 c0 12 00 00 	mov    0x12c0(,%eax,4),%edx
 4b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4bc:	01 d0                	add    %edx,%eax
 4be:	c6 00 31             	movb   $0x31,(%eax)
			passSomeTime();
 4c1:	e8 3a fb ff ff       	call   0 <passSomeTime>
      passSomeTime();
 4c6:	e8 35 fb ff ff       	call   0 <passSomeTime>
      passSomeTime();
 4cb:	e8 30 fb ff ff       	call   0 <passSomeTime>
			arr[i-1][j] = '1';
 4d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d3:	83 e8 01             	sub    $0x1,%eax
 4d6:	8b 14 85 c0 12 00 00 	mov    0x12c0(,%eax,4),%edx
 4dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4e0:	01 d0                	add    %edx,%eax
 4e2:	c6 00 31             	movb   $0x31,(%eax)
	swapped with page of arr[1] because we accessed this page only twice. Page of arr[1] is accessed next, so another PGFLT is invoked,
	and this process repeats a total of 5 times.
	*/
	for (i = 0; i < 5; i++) {
		if(i > 0){
			for(j = 0; j < 20; j++) {
 4e5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 4e9:	83 7d f0 13          	cmpl   $0x13,-0x10(%ebp)
 4ed:	7e bd                	jle    4ac <lapTest+0x186>
      passSomeTime();
      passSomeTime();
			arr[i-1][j] = '1';
			}
		}
		arr[i][0] = '1';
 4ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f2:	8b 04 85 c0 12 00 00 	mov    0x12c0(,%eax,4),%eax
 4f9:	c6 00 31             	movb   $0x31,(%eax)
	/*
	Access page (arr[0]), causing a PGFLT, since it is in the swap file. It would be
	swapped with page of arr[1] because we accessed this page only twice. Page of arr[1] is accessed next, so another PGFLT is invoked,
	and this process repeats a total of 5 times.
	*/
	for (i = 0; i < 5; i++) {
 4fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 500:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 504:	7e 97                	jle    49d <lapTest+0x177>
			}
		}
		arr[i][0] = '1';
	}

	printf(1, "you now can check statistic \n");
 506:	83 ec 08             	sub    $0x8,%esp
 509:	68 d7 0d 00 00       	push   $0xdd7
 50e:	6a 01                	push   $0x1
 510:	e8 84 04 00 00       	call   999 <printf>
 515:	83 c4 10             	add    $0x10,%esp
	gets(input, 10);
 518:	83 ec 08             	sub    $0x8,%esp
 51b:	6a 0a                	push   $0xa
 51d:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 520:	50                   	push   %eax
 521:	e8 ae 01 00 00       	call   6d4 <gets>
 526:	83 c4 10             	add    $0x10,%esp

	if (fork() == 0) {
 529:	e8 ec 02 00 00       	call   81a <fork>
 52e:	85 c0                	test   %eax,%eax
 530:	75 42                	jne    574 <lapTest+0x24e>

		printf(1, "this is the child!\n");
 532:	83 ec 08             	sub    $0x8,%esp
 535:	68 f5 0d 00 00       	push   $0xdf5
 53a:	6a 01                	push   $0x1
 53c:	e8 58 04 00 00       	call   999 <printf>
 541:	83 c4 10             	add    $0x10,%esp
		gets(input, 10);
 544:	83 ec 08             	sub    $0x8,%esp
 547:	6a 0a                	push   $0xa
 549:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 54c:	50                   	push   %eax
 54d:	e8 82 01 00 00       	call   6d4 <gets>
 552:	83 c4 10             	add    $0x10,%esp

		// causing a page fault
		arr[5][0] = 'k';
 555:	a1 d4 12 00 00       	mov    0x12d4,%eax
 55a:	c6 00 6b             	movb   $0x6b,(%eax)
		printf(1, "Press any key to exit the child code.\n");
 55d:	83 ec 08             	sub    $0x8,%esp
 560:	68 28 0f 00 00       	push   $0xf28
 565:	6a 01                	push   $0x1
 567:	e8 2d 04 00 00       	call   999 <printf>
 56c:	83 c4 10             	add    $0x10,%esp
		exit();
 56f:	e8 ae 02 00 00       	call   822 <exit>
	}
	else {
		wait();
 574:	e8 b1 02 00 00       	call   82a <wait>
		// Deallocate all the pages
		sbrk(-13 * PGSIZE);
 579:	83 ec 0c             	sub    $0xc,%esp
 57c:	68 00 30 ff ff       	push   $0xffff3000
 581:	e8 24 03 00 00       	call   8aa <sbrk>
 586:	83 c4 10             	add    $0x10,%esp
		printf(1, "Press any key to exit the father code.\n");
 589:	83 ec 08             	sub    $0x8,%esp
 58c:	68 50 0f 00 00       	push   $0xf50
 591:	6a 01                	push   $0x1
 593:	e8 01 04 00 00       	call   999 <printf>
 598:	83 c4 10             	add    $0x10,%esp
	}
}
 59b:	90                   	nop
 59c:	c9                   	leave  
 59d:	c3                   	ret    

0000059e <main>:



int
main(int argc, char *argv[]){
 59e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 5a2:	83 e4 f0             	and    $0xfffffff0,%esp
 5a5:	ff 71 fc             	pushl  -0x4(%ecx)
 5a8:	55                   	push   %ebp
 5a9:	89 e5                	mov    %esp,%ebp
 5ab:	51                   	push   %ecx
 5ac:	83 ec 04             	sub    $0x4,%esp
#if LIFO
printf(1, "this is LIFO policy.\nNo page faults should occur.\n");
	lifoTest();

#elif SCFIFO
printf(1, "this is SCFIFO policy.\nNo page faults should occur.\n");
 5af:	83 ec 08             	sub    $0x8,%esp
 5b2:	68 78 0f 00 00       	push   $0xf78
 5b7:	6a 01                	push   $0x1
 5b9:	e8 db 03 00 00       	call   999 <printf>
 5be:	83 c4 10             	add    $0x10,%esp
	scFifoTest();
 5c1:	e8 23 fc ff ff       	call   1e9 <scFifoTest>
	printf(1, "this is the default policy.\nNo page faults should occur.\n");
	for (i = 0; i < 50; i++) {
		arr[i] = sbrk(PGSIZE);
	}
	#endif
exit();
 5c6:	e8 57 02 00 00       	call   822 <exit>

000005cb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 5cb:	55                   	push   %ebp
 5cc:	89 e5                	mov    %esp,%ebp
 5ce:	57                   	push   %edi
 5cf:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 5d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5d3:	8b 55 10             	mov    0x10(%ebp),%edx
 5d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d9:	89 cb                	mov    %ecx,%ebx
 5db:	89 df                	mov    %ebx,%edi
 5dd:	89 d1                	mov    %edx,%ecx
 5df:	fc                   	cld    
 5e0:	f3 aa                	rep stos %al,%es:(%edi)
 5e2:	89 ca                	mov    %ecx,%edx
 5e4:	89 fb                	mov    %edi,%ebx
 5e6:	89 5d 08             	mov    %ebx,0x8(%ebp)
 5e9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 5ec:	90                   	nop
 5ed:	5b                   	pop    %ebx
 5ee:	5f                   	pop    %edi
 5ef:	5d                   	pop    %ebp
 5f0:	c3                   	ret    

000005f1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 5f1:	55                   	push   %ebp
 5f2:	89 e5                	mov    %esp,%ebp
 5f4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 5f7:	8b 45 08             	mov    0x8(%ebp),%eax
 5fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 5fd:	90                   	nop
 5fe:	8b 45 08             	mov    0x8(%ebp),%eax
 601:	8d 50 01             	lea    0x1(%eax),%edx
 604:	89 55 08             	mov    %edx,0x8(%ebp)
 607:	8b 55 0c             	mov    0xc(%ebp),%edx
 60a:	8d 4a 01             	lea    0x1(%edx),%ecx
 60d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 610:	0f b6 12             	movzbl (%edx),%edx
 613:	88 10                	mov    %dl,(%eax)
 615:	0f b6 00             	movzbl (%eax),%eax
 618:	84 c0                	test   %al,%al
 61a:	75 e2                	jne    5fe <strcpy+0xd>
    ;
  return os;
 61c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 61f:	c9                   	leave  
 620:	c3                   	ret    

00000621 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 621:	55                   	push   %ebp
 622:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 624:	eb 08                	jmp    62e <strcmp+0xd>
    p++, q++;
 626:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 62a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 62e:	8b 45 08             	mov    0x8(%ebp),%eax
 631:	0f b6 00             	movzbl (%eax),%eax
 634:	84 c0                	test   %al,%al
 636:	74 10                	je     648 <strcmp+0x27>
 638:	8b 45 08             	mov    0x8(%ebp),%eax
 63b:	0f b6 10             	movzbl (%eax),%edx
 63e:	8b 45 0c             	mov    0xc(%ebp),%eax
 641:	0f b6 00             	movzbl (%eax),%eax
 644:	38 c2                	cmp    %al,%dl
 646:	74 de                	je     626 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 648:	8b 45 08             	mov    0x8(%ebp),%eax
 64b:	0f b6 00             	movzbl (%eax),%eax
 64e:	0f b6 d0             	movzbl %al,%edx
 651:	8b 45 0c             	mov    0xc(%ebp),%eax
 654:	0f b6 00             	movzbl (%eax),%eax
 657:	0f b6 c0             	movzbl %al,%eax
 65a:	29 c2                	sub    %eax,%edx
 65c:	89 d0                	mov    %edx,%eax
}
 65e:	5d                   	pop    %ebp
 65f:	c3                   	ret    

00000660 <strlen>:

uint
strlen(char *s)
{
 660:	55                   	push   %ebp
 661:	89 e5                	mov    %esp,%ebp
 663:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 666:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 66d:	eb 04                	jmp    673 <strlen+0x13>
 66f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 673:	8b 55 fc             	mov    -0x4(%ebp),%edx
 676:	8b 45 08             	mov    0x8(%ebp),%eax
 679:	01 d0                	add    %edx,%eax
 67b:	0f b6 00             	movzbl (%eax),%eax
 67e:	84 c0                	test   %al,%al
 680:	75 ed                	jne    66f <strlen+0xf>
    ;
  return n;
 682:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 685:	c9                   	leave  
 686:	c3                   	ret    

00000687 <memset>:

void*
memset(void *dst, int c, uint n)
{
 687:	55                   	push   %ebp
 688:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 68a:	8b 45 10             	mov    0x10(%ebp),%eax
 68d:	50                   	push   %eax
 68e:	ff 75 0c             	pushl  0xc(%ebp)
 691:	ff 75 08             	pushl  0x8(%ebp)
 694:	e8 32 ff ff ff       	call   5cb <stosb>
 699:	83 c4 0c             	add    $0xc,%esp
  return dst;
 69c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 69f:	c9                   	leave  
 6a0:	c3                   	ret    

000006a1 <strchr>:

char*
strchr(const char *s, char c)
{
 6a1:	55                   	push   %ebp
 6a2:	89 e5                	mov    %esp,%ebp
 6a4:	83 ec 04             	sub    $0x4,%esp
 6a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 6aa:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 6ad:	eb 14                	jmp    6c3 <strchr+0x22>
    if(*s == c)
 6af:	8b 45 08             	mov    0x8(%ebp),%eax
 6b2:	0f b6 00             	movzbl (%eax),%eax
 6b5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 6b8:	75 05                	jne    6bf <strchr+0x1e>
      return (char*)s;
 6ba:	8b 45 08             	mov    0x8(%ebp),%eax
 6bd:	eb 13                	jmp    6d2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 6bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6c3:	8b 45 08             	mov    0x8(%ebp),%eax
 6c6:	0f b6 00             	movzbl (%eax),%eax
 6c9:	84 c0                	test   %al,%al
 6cb:	75 e2                	jne    6af <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 6cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 6d2:	c9                   	leave  
 6d3:	c3                   	ret    

000006d4 <gets>:

char*
gets(char *buf, int max)
{
 6d4:	55                   	push   %ebp
 6d5:	89 e5                	mov    %esp,%ebp
 6d7:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 6e1:	eb 42                	jmp    725 <gets+0x51>
    cc = read(0, &c, 1);
 6e3:	83 ec 04             	sub    $0x4,%esp
 6e6:	6a 01                	push   $0x1
 6e8:	8d 45 ef             	lea    -0x11(%ebp),%eax
 6eb:	50                   	push   %eax
 6ec:	6a 00                	push   $0x0
 6ee:	e8 47 01 00 00       	call   83a <read>
 6f3:	83 c4 10             	add    $0x10,%esp
 6f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 6f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6fd:	7e 33                	jle    732 <gets+0x5e>
      break;
    buf[i++] = c;
 6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 702:	8d 50 01             	lea    0x1(%eax),%edx
 705:	89 55 f4             	mov    %edx,-0xc(%ebp)
 708:	89 c2                	mov    %eax,%edx
 70a:	8b 45 08             	mov    0x8(%ebp),%eax
 70d:	01 c2                	add    %eax,%edx
 70f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 713:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 715:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 719:	3c 0a                	cmp    $0xa,%al
 71b:	74 16                	je     733 <gets+0x5f>
 71d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 721:	3c 0d                	cmp    $0xd,%al
 723:	74 0e                	je     733 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 725:	8b 45 f4             	mov    -0xc(%ebp),%eax
 728:	83 c0 01             	add    $0x1,%eax
 72b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 72e:	7c b3                	jl     6e3 <gets+0xf>
 730:	eb 01                	jmp    733 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 732:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 733:	8b 55 f4             	mov    -0xc(%ebp),%edx
 736:	8b 45 08             	mov    0x8(%ebp),%eax
 739:	01 d0                	add    %edx,%eax
 73b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 73e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 741:	c9                   	leave  
 742:	c3                   	ret    

00000743 <stat>:

int
stat(char *n, struct stat *st)
{
 743:	55                   	push   %ebp
 744:	89 e5                	mov    %esp,%ebp
 746:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 749:	83 ec 08             	sub    $0x8,%esp
 74c:	6a 00                	push   $0x0
 74e:	ff 75 08             	pushl  0x8(%ebp)
 751:	e8 0c 01 00 00       	call   862 <open>
 756:	83 c4 10             	add    $0x10,%esp
 759:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 75c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 760:	79 07                	jns    769 <stat+0x26>
    return -1;
 762:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 767:	eb 25                	jmp    78e <stat+0x4b>
  r = fstat(fd, st);
 769:	83 ec 08             	sub    $0x8,%esp
 76c:	ff 75 0c             	pushl  0xc(%ebp)
 76f:	ff 75 f4             	pushl  -0xc(%ebp)
 772:	e8 03 01 00 00       	call   87a <fstat>
 777:	83 c4 10             	add    $0x10,%esp
 77a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 77d:	83 ec 0c             	sub    $0xc,%esp
 780:	ff 75 f4             	pushl  -0xc(%ebp)
 783:	e8 c2 00 00 00       	call   84a <close>
 788:	83 c4 10             	add    $0x10,%esp
  return r;
 78b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 78e:	c9                   	leave  
 78f:	c3                   	ret    

00000790 <atoi>:

int
atoi(const char *s)
{
 790:	55                   	push   %ebp
 791:	89 e5                	mov    %esp,%ebp
 793:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 796:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 79d:	eb 25                	jmp    7c4 <atoi+0x34>
    n = n*10 + *s++ - '0';
 79f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 7a2:	89 d0                	mov    %edx,%eax
 7a4:	c1 e0 02             	shl    $0x2,%eax
 7a7:	01 d0                	add    %edx,%eax
 7a9:	01 c0                	add    %eax,%eax
 7ab:	89 c1                	mov    %eax,%ecx
 7ad:	8b 45 08             	mov    0x8(%ebp),%eax
 7b0:	8d 50 01             	lea    0x1(%eax),%edx
 7b3:	89 55 08             	mov    %edx,0x8(%ebp)
 7b6:	0f b6 00             	movzbl (%eax),%eax
 7b9:	0f be c0             	movsbl %al,%eax
 7bc:	01 c8                	add    %ecx,%eax
 7be:	83 e8 30             	sub    $0x30,%eax
 7c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 7c4:	8b 45 08             	mov    0x8(%ebp),%eax
 7c7:	0f b6 00             	movzbl (%eax),%eax
 7ca:	3c 2f                	cmp    $0x2f,%al
 7cc:	7e 0a                	jle    7d8 <atoi+0x48>
 7ce:	8b 45 08             	mov    0x8(%ebp),%eax
 7d1:	0f b6 00             	movzbl (%eax),%eax
 7d4:	3c 39                	cmp    $0x39,%al
 7d6:	7e c7                	jle    79f <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7db:	c9                   	leave  
 7dc:	c3                   	ret    

000007dd <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 7dd:	55                   	push   %ebp
 7de:	89 e5                	mov    %esp,%ebp
 7e0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 7e3:	8b 45 08             	mov    0x8(%ebp),%eax
 7e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 7e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 7ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 7ef:	eb 17                	jmp    808 <memmove+0x2b>
    *dst++ = *src++;
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8d 50 01             	lea    0x1(%eax),%edx
 7f7:	89 55 fc             	mov    %edx,-0x4(%ebp)
 7fa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7fd:	8d 4a 01             	lea    0x1(%edx),%ecx
 800:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 803:	0f b6 12             	movzbl (%edx),%edx
 806:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 808:	8b 45 10             	mov    0x10(%ebp),%eax
 80b:	8d 50 ff             	lea    -0x1(%eax),%edx
 80e:	89 55 10             	mov    %edx,0x10(%ebp)
 811:	85 c0                	test   %eax,%eax
 813:	7f dc                	jg     7f1 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 815:	8b 45 08             	mov    0x8(%ebp),%eax
}
 818:	c9                   	leave  
 819:	c3                   	ret    

0000081a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 81a:	b8 01 00 00 00       	mov    $0x1,%eax
 81f:	cd 40                	int    $0x40
 821:	c3                   	ret    

00000822 <exit>:
SYSCALL(exit)
 822:	b8 02 00 00 00       	mov    $0x2,%eax
 827:	cd 40                	int    $0x40
 829:	c3                   	ret    

0000082a <wait>:
SYSCALL(wait)
 82a:	b8 03 00 00 00       	mov    $0x3,%eax
 82f:	cd 40                	int    $0x40
 831:	c3                   	ret    

00000832 <pipe>:
SYSCALL(pipe)
 832:	b8 04 00 00 00       	mov    $0x4,%eax
 837:	cd 40                	int    $0x40
 839:	c3                   	ret    

0000083a <read>:
SYSCALL(read)
 83a:	b8 05 00 00 00       	mov    $0x5,%eax
 83f:	cd 40                	int    $0x40
 841:	c3                   	ret    

00000842 <write>:
SYSCALL(write)
 842:	b8 10 00 00 00       	mov    $0x10,%eax
 847:	cd 40                	int    $0x40
 849:	c3                   	ret    

0000084a <close>:
SYSCALL(close)
 84a:	b8 15 00 00 00       	mov    $0x15,%eax
 84f:	cd 40                	int    $0x40
 851:	c3                   	ret    

00000852 <kill>:
SYSCALL(kill)
 852:	b8 06 00 00 00       	mov    $0x6,%eax
 857:	cd 40                	int    $0x40
 859:	c3                   	ret    

0000085a <exec>:
SYSCALL(exec)
 85a:	b8 07 00 00 00       	mov    $0x7,%eax
 85f:	cd 40                	int    $0x40
 861:	c3                   	ret    

00000862 <open>:
SYSCALL(open)
 862:	b8 0f 00 00 00       	mov    $0xf,%eax
 867:	cd 40                	int    $0x40
 869:	c3                   	ret    

0000086a <mknod>:
SYSCALL(mknod)
 86a:	b8 11 00 00 00       	mov    $0x11,%eax
 86f:	cd 40                	int    $0x40
 871:	c3                   	ret    

00000872 <unlink>:
SYSCALL(unlink)
 872:	b8 12 00 00 00       	mov    $0x12,%eax
 877:	cd 40                	int    $0x40
 879:	c3                   	ret    

0000087a <fstat>:
SYSCALL(fstat)
 87a:	b8 08 00 00 00       	mov    $0x8,%eax
 87f:	cd 40                	int    $0x40
 881:	c3                   	ret    

00000882 <link>:
SYSCALL(link)
 882:	b8 13 00 00 00       	mov    $0x13,%eax
 887:	cd 40                	int    $0x40
 889:	c3                   	ret    

0000088a <mkdir>:
SYSCALL(mkdir)
 88a:	b8 14 00 00 00       	mov    $0x14,%eax
 88f:	cd 40                	int    $0x40
 891:	c3                   	ret    

00000892 <chdir>:
SYSCALL(chdir)
 892:	b8 09 00 00 00       	mov    $0x9,%eax
 897:	cd 40                	int    $0x40
 899:	c3                   	ret    

0000089a <dup>:
SYSCALL(dup)
 89a:	b8 0a 00 00 00       	mov    $0xa,%eax
 89f:	cd 40                	int    $0x40
 8a1:	c3                   	ret    

000008a2 <getpid>:
SYSCALL(getpid)
 8a2:	b8 0b 00 00 00       	mov    $0xb,%eax
 8a7:	cd 40                	int    $0x40
 8a9:	c3                   	ret    

000008aa <sbrk>:
SYSCALL(sbrk)
 8aa:	b8 0c 00 00 00       	mov    $0xc,%eax
 8af:	cd 40                	int    $0x40
 8b1:	c3                   	ret    

000008b2 <sleep>:
SYSCALL(sleep)
 8b2:	b8 0d 00 00 00       	mov    $0xd,%eax
 8b7:	cd 40                	int    $0x40
 8b9:	c3                   	ret    

000008ba <uptime>:
SYSCALL(uptime)
 8ba:	b8 0e 00 00 00       	mov    $0xe,%eax
 8bf:	cd 40                	int    $0x40
 8c1:	c3                   	ret    

000008c2 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 8c2:	55                   	push   %ebp
 8c3:	89 e5                	mov    %esp,%ebp
 8c5:	83 ec 18             	sub    $0x18,%esp
 8c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 8cb:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 8ce:	83 ec 04             	sub    $0x4,%esp
 8d1:	6a 01                	push   $0x1
 8d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
 8d6:	50                   	push   %eax
 8d7:	ff 75 08             	pushl  0x8(%ebp)
 8da:	e8 63 ff ff ff       	call   842 <write>
 8df:	83 c4 10             	add    $0x10,%esp
}
 8e2:	90                   	nop
 8e3:	c9                   	leave  
 8e4:	c3                   	ret    

000008e5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 8e5:	55                   	push   %ebp
 8e6:	89 e5                	mov    %esp,%ebp
 8e8:	53                   	push   %ebx
 8e9:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 8ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 8f3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 8f7:	74 17                	je     910 <printint+0x2b>
 8f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 8fd:	79 11                	jns    910 <printint+0x2b>
    neg = 1;
 8ff:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 906:	8b 45 0c             	mov    0xc(%ebp),%eax
 909:	f7 d8                	neg    %eax
 90b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 90e:	eb 06                	jmp    916 <printint+0x31>
  } else {
    x = xx;
 910:	8b 45 0c             	mov    0xc(%ebp),%eax
 913:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 916:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 91d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 920:	8d 41 01             	lea    0x1(%ecx),%eax
 923:	89 45 f4             	mov    %eax,-0xc(%ebp)
 926:	8b 5d 10             	mov    0x10(%ebp),%ebx
 929:	8b 45 ec             	mov    -0x14(%ebp),%eax
 92c:	ba 00 00 00 00       	mov    $0x0,%edx
 931:	f7 f3                	div    %ebx
 933:	89 d0                	mov    %edx,%eax
 935:	0f b6 80 7c 12 00 00 	movzbl 0x127c(%eax),%eax
 93c:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 940:	8b 5d 10             	mov    0x10(%ebp),%ebx
 943:	8b 45 ec             	mov    -0x14(%ebp),%eax
 946:	ba 00 00 00 00       	mov    $0x0,%edx
 94b:	f7 f3                	div    %ebx
 94d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 950:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 954:	75 c7                	jne    91d <printint+0x38>
  if(neg)
 956:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 95a:	74 2d                	je     989 <printint+0xa4>
    buf[i++] = '-';
 95c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95f:	8d 50 01             	lea    0x1(%eax),%edx
 962:	89 55 f4             	mov    %edx,-0xc(%ebp)
 965:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 96a:	eb 1d                	jmp    989 <printint+0xa4>
    putc(fd, buf[i]);
 96c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 96f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 972:	01 d0                	add    %edx,%eax
 974:	0f b6 00             	movzbl (%eax),%eax
 977:	0f be c0             	movsbl %al,%eax
 97a:	83 ec 08             	sub    $0x8,%esp
 97d:	50                   	push   %eax
 97e:	ff 75 08             	pushl  0x8(%ebp)
 981:	e8 3c ff ff ff       	call   8c2 <putc>
 986:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 989:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 98d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 991:	79 d9                	jns    96c <printint+0x87>
    putc(fd, buf[i]);
}
 993:	90                   	nop
 994:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 997:	c9                   	leave  
 998:	c3                   	ret    

00000999 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 999:	55                   	push   %ebp
 99a:	89 e5                	mov    %esp,%ebp
 99c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 99f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 9a6:	8d 45 0c             	lea    0xc(%ebp),%eax
 9a9:	83 c0 04             	add    $0x4,%eax
 9ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 9af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 9b6:	e9 59 01 00 00       	jmp    b14 <printf+0x17b>
    c = fmt[i] & 0xff;
 9bb:	8b 55 0c             	mov    0xc(%ebp),%edx
 9be:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c1:	01 d0                	add    %edx,%eax
 9c3:	0f b6 00             	movzbl (%eax),%eax
 9c6:	0f be c0             	movsbl %al,%eax
 9c9:	25 ff 00 00 00       	and    $0xff,%eax
 9ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 9d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9d5:	75 2c                	jne    a03 <printf+0x6a>
      if(c == '%'){
 9d7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9db:	75 0c                	jne    9e9 <printf+0x50>
        state = '%';
 9dd:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 9e4:	e9 27 01 00 00       	jmp    b10 <printf+0x177>
      } else {
        putc(fd, c);
 9e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9ec:	0f be c0             	movsbl %al,%eax
 9ef:	83 ec 08             	sub    $0x8,%esp
 9f2:	50                   	push   %eax
 9f3:	ff 75 08             	pushl  0x8(%ebp)
 9f6:	e8 c7 fe ff ff       	call   8c2 <putc>
 9fb:	83 c4 10             	add    $0x10,%esp
 9fe:	e9 0d 01 00 00       	jmp    b10 <printf+0x177>
      }
    } else if(state == '%'){
 a03:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a07:	0f 85 03 01 00 00    	jne    b10 <printf+0x177>
      if(c == 'd'){
 a0d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 a11:	75 1e                	jne    a31 <printf+0x98>
        printint(fd, *ap, 10, 1);
 a13:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a16:	8b 00                	mov    (%eax),%eax
 a18:	6a 01                	push   $0x1
 a1a:	6a 0a                	push   $0xa
 a1c:	50                   	push   %eax
 a1d:	ff 75 08             	pushl  0x8(%ebp)
 a20:	e8 c0 fe ff ff       	call   8e5 <printint>
 a25:	83 c4 10             	add    $0x10,%esp
        ap++;
 a28:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a2c:	e9 d8 00 00 00       	jmp    b09 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 a31:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 a35:	74 06                	je     a3d <printf+0xa4>
 a37:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 a3b:	75 1e                	jne    a5b <printf+0xc2>
        printint(fd, *ap, 16, 0);
 a3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a40:	8b 00                	mov    (%eax),%eax
 a42:	6a 00                	push   $0x0
 a44:	6a 10                	push   $0x10
 a46:	50                   	push   %eax
 a47:	ff 75 08             	pushl  0x8(%ebp)
 a4a:	e8 96 fe ff ff       	call   8e5 <printint>
 a4f:	83 c4 10             	add    $0x10,%esp
        ap++;
 a52:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a56:	e9 ae 00 00 00       	jmp    b09 <printf+0x170>
      } else if(c == 's'){
 a5b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a5f:	75 43                	jne    aa4 <printf+0x10b>
        s = (char*)*ap;
 a61:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a64:	8b 00                	mov    (%eax),%eax
 a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a69:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a71:	75 25                	jne    a98 <printf+0xff>
          s = "(null)";
 a73:	c7 45 f4 ad 0f 00 00 	movl   $0xfad,-0xc(%ebp)
        while(*s != 0){
 a7a:	eb 1c                	jmp    a98 <printf+0xff>
          putc(fd, *s);
 a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7f:	0f b6 00             	movzbl (%eax),%eax
 a82:	0f be c0             	movsbl %al,%eax
 a85:	83 ec 08             	sub    $0x8,%esp
 a88:	50                   	push   %eax
 a89:	ff 75 08             	pushl  0x8(%ebp)
 a8c:	e8 31 fe ff ff       	call   8c2 <putc>
 a91:	83 c4 10             	add    $0x10,%esp
          s++;
 a94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9b:	0f b6 00             	movzbl (%eax),%eax
 a9e:	84 c0                	test   %al,%al
 aa0:	75 da                	jne    a7c <printf+0xe3>
 aa2:	eb 65                	jmp    b09 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 aa4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 aa8:	75 1d                	jne    ac7 <printf+0x12e>
        putc(fd, *ap);
 aaa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 aad:	8b 00                	mov    (%eax),%eax
 aaf:	0f be c0             	movsbl %al,%eax
 ab2:	83 ec 08             	sub    $0x8,%esp
 ab5:	50                   	push   %eax
 ab6:	ff 75 08             	pushl  0x8(%ebp)
 ab9:	e8 04 fe ff ff       	call   8c2 <putc>
 abe:	83 c4 10             	add    $0x10,%esp
        ap++;
 ac1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 ac5:	eb 42                	jmp    b09 <printf+0x170>
      } else if(c == '%'){
 ac7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 acb:	75 17                	jne    ae4 <printf+0x14b>
        putc(fd, c);
 acd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 ad0:	0f be c0             	movsbl %al,%eax
 ad3:	83 ec 08             	sub    $0x8,%esp
 ad6:	50                   	push   %eax
 ad7:	ff 75 08             	pushl  0x8(%ebp)
 ada:	e8 e3 fd ff ff       	call   8c2 <putc>
 adf:	83 c4 10             	add    $0x10,%esp
 ae2:	eb 25                	jmp    b09 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 ae4:	83 ec 08             	sub    $0x8,%esp
 ae7:	6a 25                	push   $0x25
 ae9:	ff 75 08             	pushl  0x8(%ebp)
 aec:	e8 d1 fd ff ff       	call   8c2 <putc>
 af1:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 af4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 af7:	0f be c0             	movsbl %al,%eax
 afa:	83 ec 08             	sub    $0x8,%esp
 afd:	50                   	push   %eax
 afe:	ff 75 08             	pushl  0x8(%ebp)
 b01:	e8 bc fd ff ff       	call   8c2 <putc>
 b06:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 b09:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 b10:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 b14:	8b 55 0c             	mov    0xc(%ebp),%edx
 b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b1a:	01 d0                	add    %edx,%eax
 b1c:	0f b6 00             	movzbl (%eax),%eax
 b1f:	84 c0                	test   %al,%al
 b21:	0f 85 94 fe ff ff    	jne    9bb <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 b27:	90                   	nop
 b28:	c9                   	leave  
 b29:	c3                   	ret    

00000b2a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b2a:	55                   	push   %ebp
 b2b:	89 e5                	mov    %esp,%ebp
 b2d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b30:	8b 45 08             	mov    0x8(%ebp),%eax
 b33:	83 e8 08             	sub    $0x8,%eax
 b36:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b39:	a1 a8 12 00 00       	mov    0x12a8,%eax
 b3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b41:	eb 24                	jmp    b67 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b43:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b46:	8b 00                	mov    (%eax),%eax
 b48:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b4b:	77 12                	ja     b5f <free+0x35>
 b4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b50:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b53:	77 24                	ja     b79 <free+0x4f>
 b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b58:	8b 00                	mov    (%eax),%eax
 b5a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b5d:	77 1a                	ja     b79 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b62:	8b 00                	mov    (%eax),%eax
 b64:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b67:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b6a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b6d:	76 d4                	jbe    b43 <free+0x19>
 b6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b72:	8b 00                	mov    (%eax),%eax
 b74:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b77:	76 ca                	jbe    b43 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 b79:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b7c:	8b 40 04             	mov    0x4(%eax),%eax
 b7f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b86:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b89:	01 c2                	add    %eax,%edx
 b8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b8e:	8b 00                	mov    (%eax),%eax
 b90:	39 c2                	cmp    %eax,%edx
 b92:	75 24                	jne    bb8 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b94:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b97:	8b 50 04             	mov    0x4(%eax),%edx
 b9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b9d:	8b 00                	mov    (%eax),%eax
 b9f:	8b 40 04             	mov    0x4(%eax),%eax
 ba2:	01 c2                	add    %eax,%edx
 ba4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ba7:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 baa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bad:	8b 00                	mov    (%eax),%eax
 baf:	8b 10                	mov    (%eax),%edx
 bb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bb4:	89 10                	mov    %edx,(%eax)
 bb6:	eb 0a                	jmp    bc2 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 bb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bbb:	8b 10                	mov    (%eax),%edx
 bbd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bc0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 bc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bc5:	8b 40 04             	mov    0x4(%eax),%eax
 bc8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 bcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd2:	01 d0                	add    %edx,%eax
 bd4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bd7:	75 20                	jne    bf9 <free+0xcf>
    p->s.size += bp->s.size;
 bd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bdc:	8b 50 04             	mov    0x4(%eax),%edx
 bdf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 be2:	8b 40 04             	mov    0x4(%eax),%eax
 be5:	01 c2                	add    %eax,%edx
 be7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bea:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 bed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bf0:	8b 10                	mov    (%eax),%edx
 bf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf5:	89 10                	mov    %edx,(%eax)
 bf7:	eb 08                	jmp    c01 <free+0xd7>
  } else
    p->s.ptr = bp;
 bf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bfc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 bff:	89 10                	mov    %edx,(%eax)
  freep = p;
 c01:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c04:	a3 a8 12 00 00       	mov    %eax,0x12a8
}
 c09:	90                   	nop
 c0a:	c9                   	leave  
 c0b:	c3                   	ret    

00000c0c <morecore>:

static Header*
morecore(uint nu)
{
 c0c:	55                   	push   %ebp
 c0d:	89 e5                	mov    %esp,%ebp
 c0f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 c12:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 c19:	77 07                	ja     c22 <morecore+0x16>
    nu = 4096;
 c1b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 c22:	8b 45 08             	mov    0x8(%ebp),%eax
 c25:	c1 e0 03             	shl    $0x3,%eax
 c28:	83 ec 0c             	sub    $0xc,%esp
 c2b:	50                   	push   %eax
 c2c:	e8 79 fc ff ff       	call   8aa <sbrk>
 c31:	83 c4 10             	add    $0x10,%esp
 c34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 c37:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 c3b:	75 07                	jne    c44 <morecore+0x38>
    return 0;
 c3d:	b8 00 00 00 00       	mov    $0x0,%eax
 c42:	eb 26                	jmp    c6a <morecore+0x5e>
  hp = (Header*)p;
 c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c4d:	8b 55 08             	mov    0x8(%ebp),%edx
 c50:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c56:	83 c0 08             	add    $0x8,%eax
 c59:	83 ec 0c             	sub    $0xc,%esp
 c5c:	50                   	push   %eax
 c5d:	e8 c8 fe ff ff       	call   b2a <free>
 c62:	83 c4 10             	add    $0x10,%esp
  return freep;
 c65:	a1 a8 12 00 00       	mov    0x12a8,%eax
}
 c6a:	c9                   	leave  
 c6b:	c3                   	ret    

00000c6c <malloc>:

void*
malloc(uint nbytes)
{
 c6c:	55                   	push   %ebp
 c6d:	89 e5                	mov    %esp,%ebp
 c6f:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c72:	8b 45 08             	mov    0x8(%ebp),%eax
 c75:	83 c0 07             	add    $0x7,%eax
 c78:	c1 e8 03             	shr    $0x3,%eax
 c7b:	83 c0 01             	add    $0x1,%eax
 c7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c81:	a1 a8 12 00 00       	mov    0x12a8,%eax
 c86:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c89:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c8d:	75 23                	jne    cb2 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c8f:	c7 45 f0 a0 12 00 00 	movl   $0x12a0,-0x10(%ebp)
 c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c99:	a3 a8 12 00 00       	mov    %eax,0x12a8
 c9e:	a1 a8 12 00 00       	mov    0x12a8,%eax
 ca3:	a3 a0 12 00 00       	mov    %eax,0x12a0
    base.s.size = 0;
 ca8:	c7 05 a4 12 00 00 00 	movl   $0x0,0x12a4
 caf:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cb5:	8b 00                	mov    (%eax),%eax
 cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cbd:	8b 40 04             	mov    0x4(%eax),%eax
 cc0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 cc3:	72 4d                	jb     d12 <malloc+0xa6>
      if(p->s.size == nunits)
 cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc8:	8b 40 04             	mov    0x4(%eax),%eax
 ccb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 cce:	75 0c                	jne    cdc <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cd3:	8b 10                	mov    (%eax),%edx
 cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cd8:	89 10                	mov    %edx,(%eax)
 cda:	eb 26                	jmp    d02 <malloc+0x96>
      else {
        p->s.size -= nunits;
 cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cdf:	8b 40 04             	mov    0x4(%eax),%eax
 ce2:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ce5:	89 c2                	mov    %eax,%edx
 ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cea:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cf0:	8b 40 04             	mov    0x4(%eax),%eax
 cf3:	c1 e0 03             	shl    $0x3,%eax
 cf6:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cfc:	8b 55 ec             	mov    -0x14(%ebp),%edx
 cff:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d02:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d05:	a3 a8 12 00 00       	mov    %eax,0x12a8
      return (void*)(p + 1);
 d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d0d:	83 c0 08             	add    $0x8,%eax
 d10:	eb 3b                	jmp    d4d <malloc+0xe1>
    }
    if(p == freep)
 d12:	a1 a8 12 00 00       	mov    0x12a8,%eax
 d17:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 d1a:	75 1e                	jne    d3a <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 d1c:	83 ec 0c             	sub    $0xc,%esp
 d1f:	ff 75 ec             	pushl  -0x14(%ebp)
 d22:	e8 e5 fe ff ff       	call   c0c <morecore>
 d27:	83 c4 10             	add    $0x10,%esp
 d2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 d2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 d31:	75 07                	jne    d3a <malloc+0xce>
        return 0;
 d33:	b8 00 00 00 00       	mov    $0x0,%eax
 d38:	eb 13                	jmp    d4d <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d43:	8b 00                	mov    (%eax),%eax
 d45:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 d48:	e9 6d ff ff ff       	jmp    cba <malloc+0x4e>
}
 d4d:	c9                   	leave  
 d4e:	c3                   	ret    
