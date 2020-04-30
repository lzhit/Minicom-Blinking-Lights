@
@  NAME 	: blinking_lights_asm.s
@  PROJECT	: SENG2010 - Assignment #4
@  PROGRAMMER	: Lidiia Zhitova and Ken Alparslan
@


@Data section - initialized values
    .data
    .align 3    @ This alignment is critical - to access our "huge" value, it must
                @ be 64 bit aligned
    huge:   .octa 0xAABBCCDDDDCCBBAA
    big:    .word 0xAAAABBBB
    num:    .byte 0xAB

    str2:   .asciz "Bonjour le Monde"
    count:  .word 12345         @ This is an initialized 32 bit value

    LEDaddress:   .word 0x48001014

    .code   16              @ This directive selects the instruction set being generated.
                            @ The value 16 selects Thumb, with the value 32 selecting ARM.
    .text                   @ Tell the assembler that the upcoming section is to be considered
                            @ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
    .align  2               @ Code alignment - 2^n alignment (n=2)
                            @ This causes the assembler to use 4 byte alignment
    .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                            @ instructions. The default is divided (separate instruction sets)
    .global lzTilt          @ Make the symbol name for the function visible to the linker
    .global lose
    .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
    .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                            @ encoded function. Necessary for interlinking between ARM and THUMB code.
    .type   lzTilt, %function   @ Declares that the symbol is a function (not strictly required)


.equ LOCATION, 0X32
.equ LSM303DLHC_OUT_X_H_A, 0X29     @Output Register X acceleration
.equ LSM303DLHC_OUT_Y_H_A, 0X2B     @Output Register Y acceleration





@ Function Declaration : int lzTilt(uint32_t delay, char *pattern, uint32_t target)
@
@ Input: r0, r1, r2 (i.e. r0 holds delay value, r1 holds the led pattern, r2 holds the target led index)
@ Returns: r0

lzTilt:
    push {r4-r7, lr}                  @ Put aside registers we want to restore later

    mov   r6, r0                      @ r6 holds delay
    mov   r7, r1                      @ r7 holds the target led index

    mov   r0, #LOCATION               @ move the variables in r0 and r1 to get the accelerometer x-axis value
    mov   r1, #LSM303DLHC_OUT_X_H_A
    bl    COMPASSACCELERO_IO_Read

    sxtb  r4, r0                      @ extend the x-axis value


    mov   r0, #LOCATION               @ move the variables in r0 and r1 to get the accelerometer y-axis value
    mov   r1, #LSM303DLHC_OUT_Y_H_A
    bl    COMPASSACCELERO_IO_Read

    sxtb  r5, r0                      @ extend the x-axis value

    mov   r0, r4                      @ x value
    mov   r1, r5                      @ y value
    mov   r2, r6                      @ delay value
    mov   r3, r7                      @ target led index
    bl    get_LED_index



    pop   {r4-r7, lr}                 @ Restore registers

    bx    lr




@ Function Description: turns on an led based on the accelerometer values, and then turns it off after a delay
@
@ Input: r0, r1, r2, r3 (i.e. x value, y value, delay value, target led index)
@ Returns:

get_LED_index:
    push  {r4-r8, lr}

    mov   r4, r0      @ move the arguments to registers r4-r8
    mov   r5, r1
    mov   r7, r2
    mov   r8, r3

    cmp   r4, #2      @ if x value is greater than 2, one of the northern leds should be turned on
    bgt   Top

    cmp   r4, #-2     @ if x value is less than -2, one of the southern leds should be turned on
    blt   Bottom

    cmp   r5, #2      @ if y value is greater than 2, one of the western leds should be turned on,
    bgt   W
    b     E           @ eastern otherwise

    E:
      mov   r6, #4    @ east = led 4
      b     Lights

    W:
      mov   r6, #3    @ west = led 3
      b     Lights

    Top:
      cmp   r5, #10   @ if y value is greater than 10, while x value is greater than 2,
      bgt   NW        @ northwestern led should be turned on

      cmp   r5, #-10  @ northeastern otherwise
      blt   NE
      b     N         @ northern led if y value is in the range between -10 and 10

      NW:
        mov   r6, #1  @ NW = led 1
        b     Lights

      NE:
        mov   r6, #2  @ NE = led 2
        b     Lights

      N:
        mov   r6, #0  @ N = led 0
        b     Lights

    Bottom:
      cmp   r5, #10   @ if y value is greater than 10, while x value is less than 2,
      bgt   SW        @ southwestern led will be turned on
      cmp   r5, #-10  @ southeastern otherwise
      blt   SE
      b     S

      SW:
        mov   r6, #5  @ SW = led 5
        b     Lights

      SE:
        mov   r6, #6  @ SE = led 6
        b     Lights

      S:
        mov   r6, #7  @ S = led 7
        b     Lights

    Lights:
      mov   r0, r6            @ call the function to lit up the appropriate led
      bl    BSP_LED_Toggle

      mov   r0, r7            @ make a delay
      bl    HAL_Delay

      mov   r0, r6            @ turn off the led
      bl    BSP_LED_Toggle


      cmp   r6, r8            @ if the led index matches the target led, call the win function
      bne   c
      bl    win
      mov   r0, #1            @ this function will return 1 if the user wins

    c:
    pop   {r4-r8, lr}
    bx    lr



@Function Description: blinks all leds twice
@
@ Input:    none
@ Returns:  none

win:
    push  {r4-r5, lr}             @ preserve the values

    mov   r5, #4                  @ put the counter value into r5

    counter:
        mov   r4, #0                  @ put the first led index into r4
        blink_all_leds:
            mov   r0, r4
            bl    BSP_LED_Toggle      @ toggle every led
            add   r4, r4, #1
            cmp   r4, #8              @ if at index 8, exit the loop
            blt   blink_all_leds

        ldr     r0, =#0x1f4
        bl      HAL_Delay

        subs    r5, r5, #1            @ loop 4 times
        bgt     counter


    mov   r0, #0
    pop   {r4-r5, lr}             @ restore the preserved values
    bx    lr                      @ return



@ Function Description: lights up the led, index of which is passed in r0, for a short time
@
@ Input: r0 (i.e. r0 contains the led index)
@ Returns: none

lose:
    push  {r4, lr}          @ preserve values
    mov   r4, r0            @ preserve target led index in r4

    bl    BSP_LED_Toggle    @ toggle the target led

    mov   r0, #0x1f4
    bl    HAL_Delay

    mov   r0, r4
    bl    BSP_LED_Toggle    @ toggle the target led to turn it off

    mov   r0, #0
    pop   {r4, lr}          @ restore the preserved values
    bx    lr                @ return




@Function Declaration : int busy_delay(int cycles)
@
@ Input: r0 (i.e. r0 holds number of cycles to delay)
@ Returns: r0

busy_delay:

  push {r4}

  mov r4, r0

  delay_loop:

    subs r4, r4, #1

    bgt delay_loop

  mov r0, #0                      @ Return zero (always successful)

  pop {r4}

  bx lr                           @ Return (Branch eXchange) to the address in the link register (lr)


.size   lzTilt, .-lzTilt   @@ - symbol size (not req)
.size   lose, .-lose


.end    @ Assembly file ended by single .end directive on its own line
