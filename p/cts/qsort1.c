#define alloc me_alc
#define free me_dlc
#define copy me_cop
/*--- EDIT # 0128	13 Apr 1982    9:14:42	DB1:[21,6]QKSORT.C;237  */
/*
	.title	qksort
;+
; index sort an array
; index quicksort
;
; usage
;	qksort(array, num_elements, elt_size, qkcmp);
;	??? array[];		The array to sort.
;	unsigned int num_elements;	The number of elements in
;					the array.
;	int elt_size;		sizeof an array element.
;	int (*qkcmp)();		user-supplied routine which
;				compares two array elements.
;
; description
;	Sort the array. The user must supply the routine which qksort
;	calls to compare two array elements. The routine is called as:
;	"qkcmp(a, b)  BYTE *a, *b;", and must return
;	a value just like strcmp does:
;		a < b  returns -1
;		a == b returns 0
;		a > b  returns +1
;
;	For example:
;	 int int_array[10];	integer array
;	 char *str_array[10];	array of pointers to strings
;	 qksort(int_array, 10, sizeof(int), &int_cmp);
;	 qksort(str_array, 10, sizeof(char *), &str_cmp);
;	 *********************
;	 int_cmp(a, b)
;	 int *a, *b;
;	 {
;	 return (*a - *b);
;	 }
;
;	 **********************
;	 str_cmp(a, b)
;	 char *a[], *b[];
;	 {
;	 return (strcmp(*a, *b));
;	 }
;
; bugs
;	The performance is best if array elements are aligned on
;	word boundaries. This will be the case if the array is of
;	int's, etc, or pointers to strings. The obvious choice for
;	strings is for it to be an array of pointers to
;	strings, anyway.
;
;	This routine is NOT recursive, requires minimal stack space,
;	and is efficient for any existing order in the original array,
;	even if it is already sorted, in reverse order, or
;	has all equal elements.
;
;	This is the slickest quicksort I have ever come across, and I
;	have been collecting them for several years.
;
; Author:
;	 Ray Van Tassle
;	 13 Apr 1982
;-
*/
/*
 * Super quickersort.
 * This one is non-recursive.
 *
 * by Ray Van Tassle	Feb, 1982
 *
 * This is essentially 'program 2' from R. Sedgewick,
 * "Implementing Quicksort Programs", Comm ACM, Oct 1978 p 847-856.
 * I tried several other variants of quicksort (I have amassed a
 * very large collection of books and articles on quicksort over
 * the years), and most of them turn out to not be improvements at
 * all. It is really surprising to find that an "obvious
 * improvement" degrades the performance substantially!
 * I found that the only way to check out variations was to code it up
 * and run it with a driver program. The one I used generates 500, 5000,
 * or 20000 random numbers and calls qksort 5 times each with these
 * differences: 1) from the random number generator, 2) the same, but
 * modulo 50, to give lots of equal keys, and 3)with the array already sorted.
 * I must report that this version is very slightly worse than the one
 * on the Structured Language tape spring 81 for case #1, very slightly
 * better for case #2, and a lot better for case #3 (the old one could
 * not handle a sorted array, and would blow sky high).
 *
 * The quicksort by Bob Denny and Tim Coad on the RSX Fall81 tape is
 * two times longer than the old Decus one for case #1 &2, but
 * will handle sorted arrays.
 * This version is twice as fast as the Denny/Coad version for case 1 & 2,
 * and slightly faster for case #3.
 *
 * So.......a word to would be improvers:
 *	Before inserting your favorite improvement to this quicksort,
 *	put it to a good test, ad make sure that you are not
 *	actually fouling it up.
 * I spent literally dozens and dozens of hours of CPU time running
 * tests.
 *
 *
 *   Test run times for 5 runs, in seconds "lowest" - highest".
 *   times for 5000 elements (int). On an 11/70 with cache and
 *	nothing else running. (The tests are compute bound).
 *	Old decus	Denny/Coad	RVT
 * #1	4.2 - 4.5	6.5 - 7.1	3.4 - 3.6
 * #2	4.5 - 4.7	5.0 - 5.4	2.8 - 2.8
 * #3	!bombs!		2.6 - 2.8	2.0 - 2.1
 *
 * These times are using "copy" to swap array members, which
 * means that the qksort can handle elements of any arbitrary size. The
 * actual decus & Denny/Coad code on the tapes do the swap by
 * just moving the 'int'. This version of the old decus one takes
 * about a second longer (the times shown above) than the one on the
 * tapes, which move int's. So in reality, when you compare like to like,
 * my version (this one) is actually faster than the old decus one.
 *
 *
 * We select the pivot element to be the median element of the 1st, last,
 * and middle elements of the segment.
 * 
 * Partitioning is not really that great for small segments (too much
 * overhead), so these
 * are done by an insertion sort, which is known to be quite
 * efficient for small segments. It is claimed that the best way to
 * do it is to ignore these small segments during the partitioning,
 * then run the entire array thru the insertionsort. This takes only
 * slightly longer than doing the individual segments, but the
 * set-up overhead price is paid only once.
 * The partitioning leaves these small segments
 * in the right spot, just out of sort within themselves, so we
 * never have to move more elements than those within each segment.
*/
#define TRYMAIN		/* Make a main testing program */
#undef TRYMAIN


#define LOW_BOUND 13	/* Smaller segments will be done differently */
#define BYTE char
/* Treat the array as bytes, as we really want
			 * to use 'elt_size', but C doesn't allow this,
			 * so we do it ourselves. */

#define INT_MSK 1   /* to mask the addr to see if it is on an int boundary */

#define LOC_SIZ 10	/* size of a local pivot area */

static int typ_swap = 0;	/* TRUE if we can swap by moving int's
				 * else we have to move bytes */
static int move_size = 0;	/* number of byte/int's to move (elt_size)*/

qsort (array, num_elements, elt_size, qkcmp)
BYTE array[];	/* the array to sort */
unsigned int num_elements;	/* the number of elements in the array */
int elt_size;		/* size of an element in bytes */
int (*qkcmp)();	/* routine called to compare two elements
		 * called with: "cmp_rtn(a, b)" which are pointers
		 * to two elements of the array  (or pointer to pivot)
		 * returns -1, 0, +1 ; if a<b, a==b, a>b*/
{
   register BYTE *i, *j;
   BYTE *i1, *lp, *rp;
   BYTE *p;	/* pointer to middle elt of a segment */
   BYTE *lv[18], *uv[18];	/* stack for non-recurs */
   int sp;			/* stack pointer */
   BYTE **lvsp, **lvsp1;	/* pointers for lv[sp] & lv[sp+1] */
   BYTE **uvsp, **uvsp1;	/* pointers for uv[sp] & uv[sp+1] */
   unsigned int ptr_diff;	/* the difference of 2 pointers */
   unsigned int ptr_limit;	/* difference limit for seqment size */
   register BYTE *jx;	/* inner index during insertionsort */
   BYTE *pivot;	/*addr of a scratch area */
   int loc_pivot[LOC_SIZ];	/* local pivot area for small elements */

   if (num_elements < 2) return;  /* The array is already sorted! */
   move_size = elt_size;
   /* see if we can move int's */
   if ((((int)array & INT_MSK) == 0) && (elt_size % (sizeof(int)) == 0)) {
      typ_swap = 1; /* yes, we can */
      move_size = elt_size/(sizeof (int));
   }
   pivot = &loc_pivot;
   if (elt_size > sizeof(loc_pivot))
      pivot = alloc(elt_size);
   sp=0;
   lvsp = &lv[0]; lvsp1 = lvsp + 1;
   uvsp = &uv[0]; uvsp1 = uvsp + 1;
   *lvsp = array;
   *uvsp = array + elt_size * (num_elements - 1);
   ptr_limit = LOW_BOUND * elt_size;
   while (sp >= 0) {
      lp = i = *lvsp;    rp =	j = *uvsp;
      ptr_diff = j-i;
      if (ptr_diff < ptr_limit) { /*small segment will be handled later */
	 sp--; lvsp--; lvsp1--; uvsp--; uvsp1--; /* pop it off */
      }
      else {
	 /* select a pivot element & move it around. */
	 p = ((ptr_diff/elt_size) / 2) * elt_size + i; /* middle element */
	 /* mung 1st, last, middle elements around */
	 qswap(p, i);
	 i1 = i+elt_size;
	 if ((*qkcmp)(i1, j) > 0) qswap(i1, j);
	 if ((*qkcmp)(i, j) > 0) qswap(i, j);
	 if ((*qkcmp)(i1, i) > 0) qswap(i1, i);
	 i = i1;
/* Get things on the proper side of the pivot.
 * The above munging around has cleverly set up the boundary conditions
 * so that we don't need to check the pointers against the partition
 * limits. So the inner loop is very fast.
*/
	 for (;;) {
	    do (i += elt_size);  while ((*qkcmp)(i, lp) < 0);
	    do (j -= elt_size);  while ((*qkcmp)(lp, j) < 0);
	    if (j < i) break;
	    qswap(i, j);
	 }
	 qswap(lp, j);
/* done with this partition */
	 if ( (j-lp) < (rp-j)) { /* stack so shorter is done first */
	    *lvsp1 = *lvsp;
	    *uvsp1 = j-elt_size;
	    *lvsp = j+elt_size;
	    sp++;  lvsp++;  lvsp1++;   uvsp++;   uvsp1++; /* push stack */
	 }
	 else {
	    *lvsp1 = j+elt_size;
	    *uvsp1 = *uvsp;
	    *uvsp = j-elt_size;
	    sp++;  lvsp++;  lvsp1++;   uvsp++;   uvsp1++; /* push stack */

	 }
      }
   }
/* Now do an insertionsort to get the small segments (which were
 * bypassed earlier) sorted.
*/
   p = array + elt_size * (num_elements - 1);	/* last element of array */
   for (i=array, j=i+elt_size; i<p; i=j, j+=elt_size) {
      if ((*qkcmp)(i,j) > 0) { /*we have hit an out-of-sort area */
	 copy(pivot, j, elt_size);
	 for (jx=j; (i >= array) && ((*qkcmp)(i,pivot) > 0)
	    ; jx=i, i-=elt_size) {
	    copy(jx, i, elt_size);
	 }
	 copy(jx, pivot, elt_size);
      }
   }
   if (elt_size > sizeof(loc_pivot))
      free(pivot);
}

/************************/
/** swap routine ****/
static qswap(a, b)
register int *a, *b;
{
   register int i;
   int t;
   char tc;

   if (typ_swap != 0) {	/* move an int at a time */
      for (i = move_size; i--; ) {
	 t = *a; *a++ = *b;    *b++ = t;
      }
   }
   else {		/* move a byte at a time */
      for (i = move_size; i--; ) {
	 tc = *(char *)a;
	 *((char *)a)++ = *(char *)b;
	 *((char *)b)++ = tc;
      }
   }
}
#ifdef TRYMAIN
#define LOOPCNT 5	/* number of times to go around */

#ifdef wsm
#include <std.h>
#else
#include <stdio.h>
#endif


#define SSIZE 5000
extern long int systime();	/* msec since midnight */
extern long int random();
extern int compare();
long int s_time = 0;		/* start time */

int array[SSIZE] = 0;		/* the array to sort */
int stmp = 0;
int lcnt = LOOPCNT;		/* # of times to go around */

long int cswap = 0;		/* swap count */
long int ccomp = 0;		/* compare count */
long int ccopy = 0;		/* copy count */

main()
{
   register int i;

   randinit(0);
   while (lcnt--) {
      for (i=0; i<SSIZE; i++)
	 array[i] = random() & 077777;
      i = isort();
      printf("Sort rand elapsed: %d.%0.1d sec\n", i/10, i%10);
      printf ("swap:%ld   comp:%ld   copy:%ld\n", cswap, ccomp, ccopy);
      cswap = ccomp = ccopy =0;
   }
   lcnt = LOOPCNT;

   randinit(0);
   while (lcnt--) {
      for (i=0; i<SSIZE; i++)
	 array[i] = random() % (SSIZE/100);
      i = isort();
      printf("Sort many eq elapsed: %d.%0.1d sec\n", i/10, i%10);
      printf ("swap:%ld   comp:%ld   copy:%ld\n", cswap, ccomp, ccopy);
      cswap = ccomp = ccopy =0;
   }
   lcnt = LOOPCNT;

   randinit(0);
   while (lcnt--) {
      for (i=0; i<SSIZE; i++)
	 array[i] = random() & 077777;
      isort();
      i = isort();
      printf("Sort sorted elapsed: %d.%0.1d sec\n", i/10, i%10);
      printf ("swap:%ld   comp:%ld   copy:%ld\n", cswap, ccomp, ccopy);
      cswap = ccomp = ccopy =0;
   }
   lcnt = LOOPCNT;
}

isort()
{
   int j;
   register int i;

   s_time = systime();
   qksort(array, SSIZE, sizeof(array[0]), &compare);
   j = (systime() - s_time) / 100;
   for (i=0; i<SSIZE-1; i++) {
      if (array[i] > array[i+1]) {
	 printf("Not in sort.\n");
	 break;
      }
   }
   return (j);
}

/* compare routine  */
compare(a,b)
int *a, *b;
{
   ccomp++;
   return (*a - *b);
}
#endif
