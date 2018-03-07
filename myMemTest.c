#include "types.h"
#include "stat.h"
#include "user.h"
#include "syscall.h"

#define PGSIZE 4096
#define DEBUG 0

char *arr[14];


void passSomeTime() {
	int i = 0, j = 0 , k;
	for(i = 0; i < 1000; i++) {
		for(j = 1; j < 100; j++) {
			k = ((i/j +4 )%5) *345 / 6;
		}
	}
	i = k/2;
	j = i*3;
}

void lifoTest()
{
	char input[10];
	int i;
	// Allocate 12 physical pages
	for (i = 0; i < 12; ++i) {
		arr[i] = sbrk(PGSIZE);
	}
	printf(1, "we now have 15 pages.\n");

	// now we have 16 page
	arr[12] = sbrk(PGSIZE);
	printf(1, "we now have 16 pages, there wiil be a page fault now.\n");

	// there will now be 17 pages
	arr[13] = sbrk(PGSIZE);
	printf(1, "we now have 17 pages, there wiil be a page fault now.\n");

	/*
	when 13 entered 12 got swapped - because we are in LIFO , in all our iteration 12 and 13 will swap
 	therefor there will be 10 page fault/
	*/
	for (i = 0; i < 10; i++) {
		if(i%2 == 0)
			arr[12][0] = '1';
		else
			arr[13][0] = '1';
	}
	printf(1, "you now can check statistic \n");
	gets(input, 10);

	if (fork() == 0) {
		printf(1, "this is the child!\n");
		gets(input, 10);

		// causing a page fault
		arr[12][0] = '1';
		printf(1, "A page fault should have occurred.\n");
		exit();
	}
	else {
		wait();
		// Deallocate all the pages.
		//sbrk(-14 * PGSIZE);
		printf(1, "we are in the father!\n");
	}
}

void scFifoTest()
{
	int i;
	char input[10];
	// Allocate 11 physical pages
	for (i = 0; i < 11; ++i) {
		arr[i] = sbrk(PGSIZE);
	}
	printf(1, "we now have 15 pages.\n");

	// now we have 16 page
	arr[11] = sbrk(PGSIZE);
	printf(1, "we now have 16 pages, there wiil be a page fault now.\n");

	// there will now be 17 pages
	arr[12] = sbrk(PGSIZE);
	printf(1, "we now have 17 pages, there will be a page fault now.\n");

	/*
	we expect 5 page fault . the next page to swap is 4 (not acsess) and we incerment
	to the next one and every time there will be a page fault
	*/
	for (i = 0; i < 5; i++) {
		arr[i][0] = '1';
	}
		printf(1, "you now can check statistic \n");
	gets(input, 10);

	if (fork() == 0) {
		printf(1, "this is the child!\n");
		gets(input, 10);
		// causing a page fault
		arr[5][0] = '1';
		printf(1, "A Page fault should have occurred in child proccess.\n");
		exit();
	}
	else {
		wait();

		/*
		Deallocate all the pages.
		we can see here that the page-fault of the child did't effect the father proccess
		*/
		//sbrk(-13 * PGSIZE);
		printf(1, "we are in the father!\n");
	}
}

void lapTest()
{
	int i,j;
	char input[10];
	// Allocate another 11 pages
	for (i = 0; i < 11; ++i) {
		arr[i] = sbrk(PGSIZE);
	}
	printf(1, "all physical pages are taken.\n");

	// access arr[0] 1 time, arr[1] 2 times an so on...
	for(i = 0; i < 11; i++){
		for(j = 0; j < i+1; j++) {
			arr[i][j] = 'k';
			passSomeTime();
      passSomeTime();
      passSomeTime();
		}
	}
	// there is 16 pages
	arr[11] = sbrk(PGSIZE);
	printf(1, "there is 16 pages now.\n");

	//after this 11 is not consider
	for(i = 0; i < 20; i++) {
		arr[11][i] = '1';
		passSomeTime();
   passSomeTime();
   passSomeTime();
		arr[11][i] = '1';
	}

	// now we have 17 pages
	arr[12] = sbrk(PGSIZE);
	printf(1, "there is now 17 pagese, no page fault should occure\n");

	gets(input, 10);
	//we access a lot of times to arr[12] because we want him to be "out of the game"
	for(i = 0; i < 20; i++) {
		arr[12][i] = '1';
		passSomeTime();
   passSomeTime();
   passSomeTime();
		arr[12][i] = '1';
	}

	/*
	Access page (arr[0]), causing a PGFLT, since it is in the swap file. It would be
	swapped with page of arr[1] because we accessed this page only twice. Page of arr[1] is accessed next, so another PGFLT is invoked,
	and this process repeats a total of 5 times.
	*/
	for (i = 0; i < 5; i++) {
		if(i > 0){
			for(j = 0; j < 20; j++) {
			arr[i-1][j] = '1';
			passSomeTime();
      passSomeTime();
      passSomeTime();
			arr[i-1][j] = '1';
			}
		}
		arr[i][0] = '1';
	}

	printf(1, "you now can check statistic \n");
	gets(input, 10);

	if (fork() == 0) {

		printf(1, "this is the child!\n");
		gets(input, 10);

		// causing a page fault
		arr[5][0] = 'k';
		printf(1, "Press any key to exit the child code.\n");
		exit();
	}
	else {
		wait();
		// Deallocate all the pages
		sbrk(-13 * PGSIZE);
		printf(1, "Press any key to exit the father code.\n");
	}
}



int
main(int argc, char *argv[]){

#if LIFO
printf(1, "this is LIFO policy.\nNo page faults should occur.\n");
	lifoTest();

#elif SCFIFO
printf(1, "this is SCFIFO policy.\nNo page faults should occur.\n");
	scFifoTest();

#elif LAP
  printf(1, "this is LAP policy.\nNo page faults should occur.\n");
	lapTest();

#else
	char* arr[50];
	int i = 50;
	printf(1, "this is the default policy.\nNo page faults should occur.\n");
	for (i = 0; i < 50; i++) {
		arr[i] = sbrk(PGSIZE);
	}
	#endif
exit();
}
