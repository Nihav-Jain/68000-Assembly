*-----------------------------------------------------------
* Program Number: 1
* Written by    : Nihav Jain
* Date Created  : 09/13/2015
* Description   : Bubble sort on word sized data in a binary file
*
*-----------------------------------------------------------

START   ORG     $1000

        clr.l   d0              ; temporary variable
        
        lea     DataToSort,a0   ; ptr(a) = A (int A[n])
        lea     SortedData, a1  ; ptr(b) = B (int B[n])
        move.l  a1, a3          ; for outer loop condition (ptr(a) >= A + n)---SNEAK=SortedData right after DataToSort
        move.l  a1, a4          
        subq.w  #4, a4          ; for referencing A[n-2] (subtract 4 for word size)
OUTERLOOP:
        cmpa.l  a3, a0
        bge     DONE            ; break if ptr(a) >= A + n
        move.l  a4, a2          ; ptr(j) = &A[n-2]
INNERLOOP:
        cmpa.l  a0, a2
        blt     INNERCLOSE      ; break if ptr(j) < ptr(a)
        move.w  (a2),d0         ; move value at ptr(j) into temp
        cmp.w   2(a2),d0
        ble     NOSWAP          ; dont swap if ptr(j) < ptr(j+1) i.e. A[j] < A[j+1]
        move.w  2(a2),a2        ; ptr(j) = ptr(j+1), j++
        move.w  d0,2(a2)         ; ptr(j) = temp
NOSWAP:
        subq.w  #2, a2          ; ptr(j)--
        JMP     INNERLOOP       ; j loop
INNERCLOSE:
        move.w  (a0)+, (a1)+    ; ptr(b) = ptr(a), a++, b++
        JMP     OUTERLOOP       ; i loop
DONE:
        move.w  #10, d1         ; only to show done (remove before submitting)

*...by here, SortedData area of memory should contain
*...the data from DataToSort, sorted smallest to largest
        move.b  $9,d0
        TRAP #15
        
        STOP #$2000
LifeSaver       ds.l 0
DataToSort      INCBIN "randombigger.dat"


SortedData      ds.b  (SortedData-DataToSort)
AnyOtherVariable        ds.b 1
        END     START








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
