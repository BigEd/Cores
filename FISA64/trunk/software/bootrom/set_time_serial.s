	code
	align	16
get_datetime:
	      	subui	sp,sp,#16
	      	push 	bp
	      	mov  	bp,sp
	      	subui	sp,sp,#8
	      	push 	r11
	      	push 	r12
	      	push 	r13
	      	push 	r14
	      	push 	r15
	      	push 	r16
	      	push 	r17
	      	ldi  	r11,#RTCC_BUF
	      	lw   	r12,80[bp]
	      	lw   	r13,72[bp]
	      	lw   	r14,64[bp]
	      	lw   	r15,56[bp]
	      	lw   	r16,48[bp]
	      	lw   	r17,40[bp]
	      	beq  	r17,set_time_serial_2
	      	lbu  	r3,6[r11]
	      	sxb  	r3,r3
	      	sw   	r3,-8[bp]
	      	ldi  	r3,#2000
	      	lw   	r4,-8[bp]
	      	and  	r4,r4,#15
	      	lw   	r5,-8[bp]
	      	and  	r5,r5,#240
	      	asri 	r5,r5,#4
	      	mul  	r5,r5,#10
	      	addu 	r4,r4,r5
	      	addu 	r3,r3,r4
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	sw   	r3,[r17]
set_time_serial_2:
	      	beq  	r16,set_time_serial_4
	      	lbu  	r3,4[r11]
	      	sxb  	r3,r3
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	and  	r3,r3,#15
	      	lw   	r4,-8[bp]
	      	and  	r4,r4,#16
	      	asri 	r4,r4,#4
	      	mul  	r4,r4,#10
	      	addu 	r3,r3,r4
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	sw   	r3,[r16]
set_time_serial_4:
	      	beq  	r15,set_time_serial_6
	      	lbu  	r3,5[r11]
	      	sxb  	r3,r3
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	and  	r3,r3,#15
	      	lw   	r4,-8[bp]
	      	and  	r4,r4,#48
	      	asri 	r4,r4,#4
	      	mul  	r4,r4,#10
	      	addu 	r3,r3,r4
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	sw   	r3,[r15]
set_time_serial_6:
	      	beq  	r14,set_time_serial_8
	      	lbu  	r3,2[r11]
	      	sxb  	r3,r3
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	and  	r3,r3,#15
	      	lw   	r4,-8[bp]
	      	and  	r4,r4,#48
	      	asri 	r4,r4,#4
	      	mul  	r4,r4,#10
	      	addu 	r3,r3,r4
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	and  	r3,r3,#63
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	sw   	r3,[r14]
set_time_serial_8:
	      	beq  	r13,set_time_serial_10
	      	lbu  	r3,1[r11]
	      	sxb  	r3,r3
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	and  	r3,r3,#15
	      	lw   	r4,-8[bp]
	      	and  	r4,r4,#112
	      	asri 	r4,r4,#4
	      	mul  	r4,r4,#10
	      	addu 	r3,r3,r4
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	sw   	r3,[r13]
set_time_serial_10:
	      	beq  	r12,set_time_serial_12
	      	lbu  	r3,[r11]
	      	sxb  	r3,r3
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	and  	r3,r3,#15
	      	lw   	r4,-8[bp]
	      	and  	r4,r4,#112
	      	asri 	r4,r4,#4
	      	mul  	r4,r4,#10
	      	addu 	r3,r3,r4
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	sw   	r3,[r12]
set_time_serial_12:
set_time_serial_14:
	      	pop  	r17
	      	pop  	r16
	      	pop  	r15
	      	pop  	r14
	      	pop  	r13
	      	pop  	r12
	      	pop  	r11
	      	mov  	sp,bp
	      	pop  	bp
	      	rtl  	#16
ToJul:
	      	subui	sp,sp,#16
	      	push 	bp
	      	mov  	bp,sp
	      	subui	sp,sp,#32
	      	lw   	r3,40[bp]
	      	sw   	r3,-16[bp]
	      	lw   	r3,48[bp]
	      	sw   	r3,-24[bp]
	      	lw   	r3,56[bp]
	      	sw   	r3,-32[bp]
	      	ldi  	r3,#-32075
	      	lw   	r4,-32[bp]
	      	ldi  	r5,#7012800
	      	lw   	r6,-16[bp]
	      	lw   	r7,-24[bp]
	      	subu 	r7,r7,#14
	      	divs 	r7,r7,#12
	      	addu 	r6,r6,r7
	      	mul  	r6,r6,#1461
	      	addu 	r5,r5,r6
	      	asri 	r5,r5,#2
	      	addu 	r4,r4,r5
	      	ldi  	r5,#-734
	      	lw   	r6,-24[bp]
	      	lw   	r7,-24[bp]
	      	subu 	r7,r7,#14
	      	divs 	r7,r7,#12
	      	mul  	r7,r7,#12
	      	subu 	r6,r6,r7
	      	mul  	r6,r6,#367
	      	addu 	r5,r5,r6
	      	divs 	r5,r5,#12
	      	addu 	r4,r4,r5
	      	ldi  	r5,#4900
	      	lw   	r6,-16[bp]
	      	lw   	r7,-24[bp]
	      	subu 	r7,r7,#14
	      	divs 	r7,r7,#12
	      	addu 	r6,r6,r7
	      	addu 	r5,r5,r6
	      	divs 	r5,r5,#100
	      	mul  	r5,r5,#3
	      	asri 	r5,r5,#2
	      	subu 	r4,r4,r5
	      	addu 	r3,r3,r4
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	mov  	r1,r3
set_time_serial_17:
	      	mov  	sp,bp
	      	pop  	bp
	      	rtl  	#16
set_time_serial:
	      	push 	lr
	      	push 	xlr
	      	push 	bp
	      	ldi  	xlr,#set_time_serial_19
	      	mov  	bp,sp
	      	subui	sp,sp,#72
	      	pea  	-64[bp]
	      	pea  	-56[bp]
	      	pea  	-48[bp]
	      	pea  	-40[bp]
	      	pea  	-32[bp]
	      	pea  	-24[bp]
	      	bsr  	get_datetime
	      	addui	sp,sp,#48
	      	lw   	r3,-64[bp]
	      	asli 	r3,r3,#10
	      	lw   	r4,-56[bp]
	      	mul  	r4,r4,#61440
	      	addu 	r3,r3,r4
	      	lw   	r4,-48[bp]
	      	mul  	r4,r4,#3686400
	      	addu 	r3,r3,r4
	      	push 	r3
	      	push 	-40[bp]
	      	push 	-32[bp]
	      	push 	-24[bp]
	      	bsr  	ToJul
	      	addui	sp,sp,#24
	      	pop  	r3
	      	mov  	r4,r1
	      	mul  	r4,r4,#88473600
	      	addu 	r3,r3,r4
	      	sw   	r3,Milliseconds
	      	lw   	r3,-16[bp]
	      	mov  	r1,r3
set_time_serial_20:
	      	mov  	sp,bp
	      	pop  	bp
	      	pop  	xlr
	      	pop  	lr
	      	rtl  	#0
set_time_serial_19:
	      	lw   	lr,8[bp]
	      	sw   	lr,16[bp]
	      	bra  	set_time_serial_20
	rodata
	align	16
	align	8
	extern	RTCC_BUF
	extern	Milliseconds