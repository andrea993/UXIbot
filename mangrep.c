#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

char* toupperStr(char* str);
int main ()
{
	char line[150],linecp[150];
	int end=0,i;

	while (!end &&fgets(line,150,stdin)!=NULL)
	{  
		line[strlen("DESCRIPTION")]='\0';
		if (strcmp(toupperStr(line),"DESCRIPTION")==0)
			end=1;
	}

	end=0;
	while (fgets(line,150,stdin)!=NULL && !end)
	{
		if (line[0]=='\n') 
			continue;
		if(line[0]==' ' || line[0]=='\t')
		{
			for(i=0;i<strlen(line)-1;i++)
			{
				if(line[i]=='\t') 
					line[i]=' ';
				if(line[i]==' ' && line[i+1]==' ')
				{
					strcpy(linecp, &line[i+1]);
					strcpy(&line[i],linecp);
					i--;
				}
			}
			if(strlen(line)>0)
			{
				strcpy(linecp,line);
				strcpy(line,&linecp[1]);
			}
			if (line[strlen(line)-2]==' ')
				line[strlen(line)-2]='\0';
			printf("%s",line);
		}
		else
			end=1;
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
