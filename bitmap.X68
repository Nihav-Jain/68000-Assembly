*-----------------------------------------------------------
* Program Number: 2
* Written by    : Nihav Jain
* Date Created  : 09/26/2015
* Description   : Display the specified part of a bitmap
*
*-----------------------------------------------------------

START   ORG     $1000

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

*-------------------
* a0 : address of image data
* d1 : trap code requirements
* d2 : Y coordinate
* d3 : X coordinate
* d4 : image width
* d5 : image height
* d6 : pixel offset
*-------------------

        move.l  ImageDataOffset, d5     ; precondition for byte swapping subroutine
        JSR     SR_SWAP_LONG
        lea     BitmapData, a0
        adda.l  d5, a0                  ; adding image data offset to bitmap data start address, a0 now points to the image data
        
        move.l  #START_X, d3
        move.l  #START_Y, d2

        move.l  ImageWidth, d5
        JSR     SR_SWAP_LONG
        move.l  d5, d4
        move.l  ImageHeight, d5
        JSR     SR_SWAP_LONG
        
CONTINUE_ROW:
        move.l  d3, d7
        mulu    #3, d7      ; x offset (column offset)
        move.l  d2, d6
        mulu    d4, d6      ; y offset (row offset)
        add.l   d7, d6
        
        clr.l   d1
        move.b  (a0, d6), d1
        swap    d1
        move.b  1(a0, d6), d1
        lsl.b   #8, d1
        move.b  2(a0, d6), d1
        move.l  #CMD_PEN_COLOR, d0
        TRAP    #15
        
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
*-------------------
* Bitmap file descriptors
*-------------------
BitmapData      INCBIN "TenByTenBMP.bmp"
ImageDataOffset EQU    (BitmapData+10)      ; LONG
ImageWidth      EQU    (ImageDataOffset+8)  ; LONG
ImageHeight     EQU    (ImageWidth+4)       ; LONG
BitsPerPixel    EQU    (ImageHeight+6)      ; WORD
ImageSize       EQU    (BitsPerPixel+6)     ; LONG
NumOfColors     EQU    (ImageSize+12)       ; LONG

        END     START
        
*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
