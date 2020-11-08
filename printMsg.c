#include "stm32f4xx.h"
#include <string.h>
#include <float.h>



void printMsg4p(const int a, const int b, const int c, const int d)
{
	 char Msg[100];
	 char *ptr;
	
	 sprintf(Msg, "%x\t", a);
	 ptr = Msg ;
   while(*ptr != '\0')
	 {
      ITM_SendChar(*ptr);
      ++ptr;
   }
	
	 sprintf(Msg, "%x\t", b);
	 ptr = Msg ;
   while(*ptr != '\0')
	 {
      ITM_SendChar(*ptr);
      ++ptr;
   }
	 
	 sprintf(Msg, "%x\t", c);
	 ptr = Msg ;
   while(*ptr != '\0')
	 {
      ITM_SendChar(*ptr);
      ++ptr;
   }

	 sprintf(Msg, "%x\n", d);
	 ptr = Msg ;
   while(*ptr != '\0')
	 {
      ITM_SendChar(*ptr);
      ++ptr;
	 }
}
void print_header(const int select)
{
	 char *str;
	 
	 if(select==0){ str = "\nLogic Function: AND\nX0\tX1\tX2\tY\n"; }
	 else if(select==1){ str = "\nLogic Function: OR\nX0\tX1\tX2\tY\n"; }
	 else if(select==2){ str = "\nLogic Function: NAND\nX0\tX1\tX2\tY\n"; }
	 else if(select==3){ str = "\nLogic Function: NOR\nX0\tX1\tX2\tY\n"; }
	 else if(select==4){ str = "\nLogic Function: XOR\nX0\tX1\tX2\tY\n"; }
	 else if(select==5){ str = "\nLogic Function: XNOR\nX0\tX1\tX2\tY\n"; }
	 else if(select==6){ str = "\nLogic Function: NOT\nX0\tX1\tY\n"; }
	
	 while(*str != '\0'){
      ITM_SendChar(*str);
      ++str;
   }
	 return;}
