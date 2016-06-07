#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define TRUE 1
#define FALSE 0

#define MAX 300 

char* toupperStr(char* str);

int main ()
{
	char line[MAX],space;
	short i;
	while (fgets(line,MAX,stdin)!=NULL)
	{  
		if (!strncmp(toupperStr(line),"DESCRIPTION",strlen("DESCRIPTION")))
			break;
	}
	
	while (fgets(line,MAX,stdin)!=NULL)
	{
		if (line[0]=='\n') 
			continue;

		if(line[0]==' ' || line[0]=='\t')
		{
			i=0;
			while((line[i]==' ' || line[i]=='\t') && line[i]!='\0')
				i++;
			
			space=FALSE;		
			for( ;i<strlen(line);i++)
			{
				if((line[i]=='\t' || line[i]==' ') && space==FALSE)
				{
					putchar(' ');
					space=TRUE;
				}
				else
				{
					space=FALSE;
					putchar(line[i]);
				}
			}
		}
		else
			break;
	}
	return EXIT_SUCCESS;	
}

char* toupperStr(char* str)
{
	int i;
	for (i=0;i<strlen(str);i++)
		str[i]=(char)toupper((int)str[i]);

	return str;
}
