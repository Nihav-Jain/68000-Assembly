*-----------------------------------------------------------
* Program Number: 2
* Written by    : Nihav Jain
* Date Created  : 09/26/2015
* Description   : Display the specified part of a bitmap
* Bitmap Type   : True color, 24 bit, no compression
*-----------------------------------------------------------

ALL_REGS            REG     D0-D7/A0
        
*-------------------
* MAIN
*-------------------
START   ORG     $1000
        
        move.l  ImageDataOffset, d5     ; precondition for byte swapping subroutine
        JSR     SR_SWAP_LONG
        lea     BitmapData, a0
        adda.l  d5, a0                  ; adding image data offset to bitmap data start address, a0 now points to the image data
        move.l  a0, -(sp)
        
        move.l  BitsPerPixel, d5
        JSR     SR_SWAP_LONG
        move.l  d5, d7
        move.l  d5, -(sp)               ; required for calculatiung the number of garbage bytes at the end of each row
        
        move.l  ImageHeight, d5
        JSR     SR_SWAP_LONG
        move.l  d5, d4
        move.l  d5, -(sp)
        
    *-------------------
    * BMP image data  have garbage bytes at the end of each row
    * Number of bytes per row (incl. garbage) = Math.floor((BitsPerPixel*ImageWidth + 31)/32) * 4
    *-------------------
        move.l  ImageWidth, d5
        JSR     SR_SWAP_LONG        
        mulu    d5, d7
        addi.l  #31, d7
        divu    #32, d7
        mulu    #4, d7
        move.l  d7, -(sp)
        
        move.l  #0, d3
    DRAW_ROWS:
        move.l  d3, d2
    NEXT_ALTERNATE_ROW:
        move.l  #0, -(sp)
        move.l  d2, -(sp)
        move.l  d5, -(sp)
        move.l  d2, -(sp)
        JSR     SR_DRAW_CLIP_RECTANGLE
        add.l   #16, sp
        addi.l  #2, d2
        cmp.l   d4, d2
        blt     NEXT_ALTERNATE_ROW
        
        addi.l  #1, d3
        cmp.l   #2, d3
        blt     DRAW_ROWS
        
        add.l   #16, sp                 ; clearing the image data parameters
        
        move.b  $9,d0
        TRAP    #15

        STOP #$F000
        

*-------------------
* Subroutine : Draws the specified clipping rectangle
* Parameteres: (LONG) image-data-offset, (LONG) bits-per-pixel, (LONG) image-height, (LONG) bytes-per-row,
*              (LONG) top-left-x, (LONG) top-left-y, (LONG) bottom-right-x, (LONG) bottom-right-y (order to push onto stack)
*              [68(sp), 64(sp), 60(sp), 56(sp), 52(sp), 48(sp), 44(sp), 40(sp)]
*-------------------
*-------------------
* a0 : address of image data
* d0 : trap code
* d1 : trap code requirements
* d2 : Y coordinate
* d3 : X coordinate
* d4 : byte offset of current row in image data
* d5 : number of bytes per row
* d6 : pixel offset
* d7 : offset of the number of bytes in a row
*-------------------
SR_DRAW_CLIP_RECTANGLE:

        movem.l ALL_REGS, -(sp)         ; saving the values of all the registers to be used
        
        move.l  68(sp), a0              ; image data offset
        
        move.l  52(sp), d3              ; top-left-x to d3
        move.l  48(sp), d2              ; top-left-y to d2
        
        move.l  64(sp), d7              ; bits per pixel
        
        move.l  60(sp), d2              ; image height
        
    *-------------------
    * Image data in BMP is inverted 
    * i.e. the last row of data corresponds to the first row of the actual image
    * where Row[y] = (ImageHeight - y - 1) // for Row[0...ImageHeight-1]
    *-------------------
        sub.l   48(sp), d2
        subi.l  #1, d2
        
        move.l  56(sp), d5              ; number of bytes per row
        
        move.l  d3, d7
        mulu    #3, d7                  ; x (column) offset (in bytes) (3 corresponds to 24bits per pixel)
        move.l  d5, d4
        mulu    d2, d4                  ; y offset (row offset)
        move.l  d4, d6      
        add.l   d7, d6                  ; offset (in bytes) of pixel to be drawn from the image data
        move.l  48(sp), d2

    CONTINUE_ROW:
        clr.l   d1
        
        move.b  (a0, d6.l), d1          ; #$000000BB
        swap    d1                      ; #$00BB0000
        move.b  1(a0, d6.l), d1         ; #$00BB00GG
        lsl.w   #8, d1                  ; #$00BBGG00
        move.b  2(a0, d6.l), d1         ; #$00BBGGRR
        
        move.l  #CMD_PEN_COLOR, d0
        TRAP    #15
        
        move.l  d3, d1
        move.l  #CMD_DRAW_PIXEL, d0
        TRAP    #15
        
        addi.l  #1, d3                  ; increment X coordinate
        addi.l  #3, d6
        
        cmp.l   44(sp), d3
        blt     CONTINUE_ROW
        
        sub.l   d5, d4                  ; update row pointer to to previous row (current = current - NumBytesPerRow)
        move.l  d4, d6                  
        add.l   d7, d6
        move.l  52(sp), d3              ; reset X coordinate
        addi.l  #1, d2
        cmp.l   40(sp), d2
        blt     CONTINUE_ROW

        movem.l (sp)+, ALL_REGS         ; reverting value of all used registers
        RTS

        
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

        
*----------------------------------------------------------*
*----------------------------------------------------------*


*-------------------
* Coordinates of the top-left and bottom-right of the clipping rectangle to be drawn
*-------------------
TOP_LEFT_X          EQU     0
TOP_LEFT_Y          EQU     0
BOTTOM_RIGHT_X      EQU     100
BOTTOM_RIGHT_Y      EQU     100

*-------------------
* Trap codes
*-------------------
CMD_PEN_COLOR       EQU     80
CMD_DRAW_PIXEL      EQU     82
CMD_OUTPUT_RES      EQU     33
CMD_CLEAR_SCREEN    EQU     11

*-------------------
* Bitmap file descriptors
*-------------------
BitmapData          INCBIN  "tiger.bmp"
ImageDataOffset     EQU     (BitmapData+10)      ; LONG
ImageWidth          EQU     (ImageDataOffset+8)  ; LONG
ImageHeight         EQU     (ImageWidth+4)       ; LONG
BitsPerPixel        EQU     (ImageHeight+6)      ; WORD
ImageSize           EQU     (BitsPerPixel+6)     ; LONG
NumOfColors         EQU     (ImageSize+12)       ; LONG

        END     START
        

        







*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
