#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
int main()
{
   setuid( 0 );
      system( "/etc/nrpe.d/scripts/check_lvm.sh -w 85 -c 90" );
         return 0;
         }
