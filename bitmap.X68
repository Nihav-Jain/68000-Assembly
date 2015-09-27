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
* d5 : image width
* d6 : pixel offset
* d7 : offset of the number of bytes in a row
*-------------------

        move.l  ImageDataOffset, d5     ; precondition for byte swapping subroutine
        JSR     SR_SWAP_LONG
        lea     BitmapData, a0
        adda.l  d5, a0                  ; adding image data offset to bitmap data start address, a0 now points to the image data
        
        move.l  #START_X, d3
        move.l  #START_Y, d2

        move.l  ImageHeight, d5
        JSR     SR_SWAP_LONG
        move.l  d5, d2
        subi.l  #START_Y, d2
        
        move.l  ImageWidth, d5
        JSR     SR_SWAP_LONG
        addi.l  #2, d5
        mulu    #3, d5
        *move.l  d5, d4

        move.l  d3, d7
        mulu    #3, d7      ; x offset (column offset)
        move.l  d5, d4
        mulu    d2, d4
        move.l  d4, d6      ; y offset (row offset)
        add.l   d7, d6        
        move.l  #START_Y, d2

CONTINUE_ROW:
        clr.l   d1
        
        move.b  (a0, d6), d1
        swap    d1
        move.b  1(a0, d6), d1
        lsl.w   #8, d1
        move.b  2(a0, d6), d1
        
        move.l  #CMD_PEN_COLOR, d0
        TRAP    #15
        
        move.l  d3, d1
        move.l  #CMD_DRAW_PIXEL, d0
        TRAP    #15
        
        addi.l  #1, d3
        addi.l  #3, d6
        
        cmp.l   #END_X, d3
        blt     CONTINUE_ROW
        
        sub.l   d5, d4
        move.l  d4, d6      ; y offset (row offset)
        add.l   d7, d6
        move.l  #START_X, d3        
        addi.l  #1, d2
        cmp.l   #END_Y, d2
        blt     CONTINUE_ROW
        
        move.b  $9,d0
        TRAP #15
        
        STOP #$2000
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


*-------------------
* Bitmap file descriptors
*-------------------
START_X         EQU     0
START_Y         EQU     0
WIDTH_TO_DRAW   EQU     512
HEIGHT_TO_DRAW  EQU     512
END_X           EQU     (START_X+WIDTH_TO_DRAW)
END_Y           EQU     (START_Y+HEIGHT_TO_DRAW)
*BitmapData      INCBIN "lena.bmp"
*BitmapData      INCBIN "HundredSingleColor.bmp"
*BitmapData      INCBIN "HundredTwoColors.bmp"
BitmapData      INCBIN "SixBySixTwoColors.bmp"
*BitmapData      INCBIN "TenByTenBMP.bmp"
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
