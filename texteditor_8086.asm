;By: Akanksha Jagdish

.model small ;specify small memory model
;ASCI codes
BS equ 08h
ESCP equ 1bh
WS equ 20h
;Dimensions of editing area
COLUMNS equ 40
ROWS equ 10
MAX_X equ COLUMNS-1
MAX_Y equ ROWS-1 

.stack 200h ;specify a stack size of 512 bytes
.data
 cursor_x db 0 ;cursor horizontal position
 cursor_y db 0 ;cursor vertical position
.code
start:
 mov ax,@data ;set-up ds to be able to access our data
 mov ds,ax
 ;Use BIOS interrupt 10h, Service 06h to scroll window up
 ;this creates a clear screen effect
 ;also set-up colors (blue background & red text)
 mov ax,0600h
 mov bh,1ch
 mov cx,0
 mov dx,184fh
 int 10h

set_cursor:
 ;Use BIOS interrupt 10h, Service 02h to position cursor
 mov ah,02h
 mov dl,cursor_x
 mov dh,cursor_y
 mov bh,0
 int 10h

read_key:
 ;Use BIOS interrupt 16h, Service 00h to read keyboard
 ;(returns ASCII code in al)
 mov ah,0
 int 16h

 ; Check if the entered key is ESCAPE
 cmp al, ESCP
 je exit ; If the entered key is ESCAPE, jump to the exit label


 ; Check if the entered key is BACKSPACE
 cmp al, BS
 je backspace ; If the entered key is BACKSPACE, jump to the backspace label


 ;Use BIOS interrupt 10h, service 0ah to print character
 ;at current cursor position
 mov ah,0ah
 mov cx,1
 mov bh,0
 int 10h
 
 ; Check if the cursor position has reached the maximum allowed horizontally
 cmp cursor_x, MAX_X
 je move_down ; If the cursor position has reached the maximum, jump to the move_down label


 ; Increment cursor_x
 inc cursor_x
 ; Unconditional branch to set_cursor label
 jmp set_cursor


move_down:

 ; Check if the cursor position has reached the maximum allowed vertically
 cmp cursor_y, MAX_Y
 je read_key ; If the cursor position has reached the maximum, jump to the read_key label


 ; Make cursor_x = 0
 mov cursor_x, 0
 ; Increment cursor_y
 inc cursor_y
 ; Unconditional branch to set_cursor label
 jmp set_cursor


backspace:

 ; Check if cursor_x is at the beginning of a line
 cmp cursor_x, 0
 je move_up ; If cursor_x is 0, jump to the move_up label


 ; Decrement cursor_x
 dec cursor_x
 ; Unconditional branch to erase label
 jmp erase


move_up:

 ; Check if cursor_y is at the first line
 cmp cursor_y, 0
 je read_key ; If cursor_y is 0, jump to the read_key label


 ; Set cursor_x to MAX_X
 mov cursor_x, MAX_X
 ; Decrement cursor_y
 dec cursor_y

erase:
 ;Use BIOS interrupt 10h, Service 02h to position cursor
 mov ah,02h
 mov dl,cursor_x
 mov dh,cursor_y
 mov bh,0
 int 10h
 ;Use BIOS interrupt 10h, service 0ah to print whitespace
 ;at current cursor position (erase)
mov ah,0ah
 mov al,WS
 mov cx,1
 int 10h
 jmp read_key
exit:
 ;Use DOS interrupt 21h, service 4ch to exit program
 mov ax,4c00h
 int 21h

end start ;tell assembler to finish


