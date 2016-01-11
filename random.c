#include <stdio.h> 
#include <stdlib.h> 
#include <time.h>

int main (int argc, char **argv)
{
	long n,i;
	if (argc != 2) 
		return EXIT_FAILURE;

	n=atol(argv[1]);
	
	srand(time(NULL));
	for (i=0;i<n;i++)
		putchar(rand()%('~'-'!')+'!');
	printf("\n");

	return EXIT_SUCCESS;
}
