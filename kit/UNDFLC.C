#include <stdio.h>

/*
!	%build
!	cc undflc
!	link undflc,dcc:flib/bot:2000
!	%end
*/

int main(){
  union{ double f; long i; } val;
  int steps;

  val.f=1.0;
  for(steps = 0; val.f != 0; val.f/=2, steps++ ){
    printf("value = 1/(2**%d) = %g, stored as %012lo (octal) %08lx (hex)\n",steps,val.f,val.i,val.i);
  }
}
                                                                                                                                                                                