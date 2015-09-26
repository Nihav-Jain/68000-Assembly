*-----------------------------------------------------------
* Program Number: 2
* Written by    : Nihav Jain
* Date Created  : 09/26/2015
* Description   : Display the specified part of a bitmap
*
*-----------------------------------------------------------

START   ORG     $1000

*-------------------
* Bitmap file descriptors
*-------------------
BitmapData      INCBIN "TenByTenBMP.bmp"
ImageDataOffset EQU    (BitmapData+10)
ImageWidth      EQU    (ImageDataOffset+8)
ImageHeight     EQU    (ImageWidth+4)
BitsPerPixel    EQU    (ImageHeight+6)
ImageSize       EQU    (BitsPerPixel+6)
NumOfColors     EQU    (ImageSize+12)

*-------------------
* Coordinates of the top-left corner, width, height of the bitmap rectangle to be drawn
*-------------------
START_X         EQU     0
START_Y         EQU     0
WIDTH_TO_DRAW   EQU     10
HEIGHT_TO_DRAW  EQU     10

*-------------------
* Trap codes
*-------------------
CMD_PEN_COLOR   EQU     80
CMD_DRAW_PIXEL  EQU     82
CMD_OUTPUT_RES  EQU     33
CMD_CLEAR_SCREEN    EQU 11


        move.b  $9,d0
        TRAP #15
        
*-------------------
* Subroutine: Swaps the bytes of the lower word in d5
* Uses      : d5, d6 
*-------------------
SR_SWAP_WORD:
        clr.w   d6
        move.b  d5, d6
        lsr.w   #8, d5
        lsl.w   #8, d6
        or.w    d6, d5
        RTS
        
*-------------------
* Subroutine: Swaps the bytes of the long word in d5
* Uses      : d5, d6 
*-------------------
SR_SWAP_LONG:
        JSR     SR_SWAP_WORD
        swap    d5
        JSR     SR_SWAP_WORD
        RTS

        STOP #$2000
        END     START
        
*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
