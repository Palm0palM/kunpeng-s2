	.arch armv8-a
	.file	"trsm.c"
	.text
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
	.type	trsm_sve_has_eight_doubles, %function
trsm_sve_has_eight_doubles:
.LFB4280:
	.cfi_startproc
	cntd	x0
	cmp	x0, 8
	cset	w0, eq
	ret
	.cfi_endproc
.LFE4280:
	.size	trsm_sve_has_eight_doubles, .-trsm_sve_has_eight_doubles
	.align	2
	.p2align 4,,11
	.type	update8x8_sve, %function
update8x8_sve:
.LFB4282:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
	cmp	w0, 0
	ble	.L9
	sxtw	x12, w2
	mov	w15, 6
	sub	w13, w0, #1
	add	x0, x12, x2, sxtw 1
	smull	x15, w2, w15
	lsl	x18, x12, 3
	sub	x17, x18, x12
	add	x16, x12, x12, lsl 2
	add	x2, x1, 8
	lsl	x30, x12, 4
	sbfiz	x14, x4, 3, 32
	add	x13, x2, x13, uxtw 3
	lsl	x17, x17, 3
	lsl	x0, x0, 3
	lsl	x16, x16, 3
	lsl	x15, x15, 3
	lsl	x12, x12, 5
	mov	z1.d, #0
	ptrue	p0.b, all
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	mov	z5.d, z1.d
	mov	z6.d, z1.d
	mov	z7.d, z1.d
	mov	z16.d, z1.d
	.p2align 3,,7
.L8:
	add	x10, x1, x30
	ld1rd	z17.d, p0/z, [x10]
	ld1d	z0.d, p0/z, [x3]
	ld1rd	z18.d, p0/z, [x1]
	add	x8, x1, x12
	fmla	z6.d, p0/m, z0.d, z17.d
	ld1rd	z17.d, p0/z, [x8]
	add	x11, x1, x18
	add	x9, x1, x0
	add	x7, x1, x16
	add	x4, x1, x15
	add	x2, x1, x17
	fmla	z16.d, p0/m, z0.d, z18.d
	fmla	z4.d, p0/m, z0.d, z17.d
	ld1rd	z18.d, p0/z, [x9]
	ld1rd	z17.d, p0/z, [x4]
	add	x1, x1, 8
	ld1rd	z19.d, p0/z, [x11]
	fmla	z5.d, p0/m, z0.d, z18.d
	fmla	z2.d, p0/m, z0.d, z17.d
	ld1rd	z18.d, p0/z, [x7]
	ld1rd	z17.d, p0/z, [x2]
	add	x3, x3, x14
	fmla	z7.d, p0/m, z0.d, z19.d
	fmla	z3.d, p0/m, z0.d, z18.d
	fmla	z1.d, p0/m, z0.d, z17.d
	cmp	x13, x1
	bne	.L8
.L7:
	ptrue	p0.b, all
	sbfiz	x6, x6, 3, 32
	ld1d	z0.d, p0/z, [x5]
	fsub	z0.d, z0.d, z16.d
	st1d	z0.d, p0, [x5]
	add	x0, x5, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z7.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z6.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z5.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z4.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z3.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z2.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z1.d
	st1d	z0.d, p0, [x0]
	ldp	x29, x30, [sp], 16
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L9:
	.cfi_restore_state
	mov	z1.d, #0
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	mov	z5.d, z1.d
	mov	z6.d, z1.d
	mov	z7.d, z1.d
	mov	z16.d, z1.d
	b	.L7
	.cfi_endproc
.LFE4282:
	.size	update8x8_sve, .-update8x8_sve
	.align	2
	.p2align 4,,11
	.type	update16x8_sve, %function
update16x8_sve:
.LFB4283:
	.cfi_startproc
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp
	cmp	w0, 0
	ble	.L15
	sxtw	x7, w2
	mov	w30, 12
	mov	w18, 13
	mov	w17, 14
	stp	x19, x20, [sp, 16]
	.cfi_offset 20, -72
	.cfi_offset 19, -80
	mov	w20, 10
	mov	w19, 11
	mov	z1.d, #0
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -56
	.cfi_offset 21, -64
	mov	w21, 6
	smull	x20, w2, w20
	ptrue	p0.b, all
	smull	x21, w2, w21
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -24
	.cfi_offset 25, -32
	smull	x19, w2, w19
	mov	z2.d, z1.d
	lsl	x26, x7, 3
	smull	x30, w2, w30
	smull	x18, w2, w18
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -8
	.cfi_offset 27, -16
	smull	x17, w2, w17
	mov	z3.d, z1.d
	lsl	x27, x7, 4
	sub	x25, x26, x7
	add	x2, x7, x2, sxtw 1
	add	x22, x7, x7, lsl 2
	sub	w0, w0, #1
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -40
	.cfi_offset 23, -48
	add	x24, x26, x7
	mov	z4.d, z1.d
	sub	x23, x27, x7
	add	x8, x1, 8
	lsl	x28, x7, 5
	sbfiz	x4, x4, 3, 32
	add	x0, x8, x0, uxtw 3
	lsl	x25, x25, 3
	lsl	x24, x24, 3
	lsl	x23, x23, 3
	lsl	x2, x2, 3
	lsl	x22, x22, 3
	lsl	x21, x21, 3
	lsl	x20, x20, 3
	lsl	x19, x19, 3
	lsl	x30, x30, 3
	lsl	x18, x18, 3
	lsl	x17, x17, 3
	lsl	x7, x7, 6
	mov	z5.d, z1.d
	mov	z6.d, z1.d
	mov	z7.d, z1.d
	mov	z16.d, z1.d
	mov	z17.d, z1.d
	mov	z18.d, z1.d
	mov	z19.d, z1.d
	mov	z20.d, z1.d
	mov	z21.d, z1.d
	mov	z22.d, z1.d
	mov	z23.d, z1.d
	mov	z24.d, z1.d
	.p2align 3,,7
.L14:
	add	x12, x1, x27
	ld1rd	z25.d, p0/z, [x12]
	ld1d	z0.d, p0/z, [x3]
	add	x11, x1, x2
	fmla	z22.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x11]
	add	x10, x1, x28
	fmla	z21.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x10]
	add	x9, x1, x22
	fmla	z20.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x9]
	add	x8, x1, x21
	fmla	z19.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x8]
	add	x13, x1, x26
	ld1rd	z26.d, p0/z, [x1]
	add	x15, x1, x7
	fmla	z18.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x15]
	add	x16, x1, x25
	ld1rd	z27.d, p0/z, [x13]
	fmla	z24.d, p0/m, z0.d, z26.d
	add	x13, x1, x20
	ld1rd	z26.d, p0/z, [x16]
	fmla	z16.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x13]
	add	x14, x1, x24
	add	x11, x1, x30
	fmla	z17.d, p0/m, z0.d, z26.d
	fmla	z6.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x14]
	ld1rd	z25.d, p0/z, [x11]
	add	x12, x1, x19
	add	x10, x1, x18
	add	x9, x1, x17
	add	x8, x1, x23
	fmla	z7.d, p0/m, z0.d, z26.d
	fmla	z4.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x12]
	ld1rd	z25.d, p0/z, [x9]
	add	x1, x1, 8
	fmla	z5.d, p0/m, z0.d, z26.d
	fmla	z2.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x10]
	ld1rd	z25.d, p0/z, [x8]
	add	x3, x3, x4
	fmla	z23.d, p0/m, z0.d, z27.d
	fmla	z3.d, p0/m, z0.d, z26.d
	fmla	z1.d, p0/m, z0.d, z25.d
	cmp	x0, x1
	bne	.L14
	ldp	x19, x20, [sp, 16]
	.cfi_restore 20
	.cfi_restore 19
	ldp	x21, x22, [sp, 32]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L13:
	ptrue	p0.b, all
	sbfiz	x6, x6, 3, 32
	ld1d	z0.d, p0/z, [x5]
	fsub	z0.d, z0.d, z24.d
	st1d	z0.d, p0, [x5]
	add	x0, x5, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z23.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z22.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z21.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z20.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z19.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z18.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z17.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z16.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z7.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z6.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z5.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z4.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z3.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z2.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x6
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z1.d
	st1d	z0.d, p0, [x0]
	ldp	x29, x30, [sp], 96
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L15:
	.cfi_restore_state
	mov	z1.d, #0
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	mov	z5.d, z1.d
	mov	z6.d, z1.d
	mov	z7.d, z1.d
	mov	z16.d, z1.d
	mov	z17.d, z1.d
	mov	z18.d, z1.d
	mov	z19.d, z1.d
	mov	z20.d, z1.d
	mov	z21.d, z1.d
	mov	z22.d, z1.d
	mov	z23.d, z1.d
	mov	z24.d, z1.d
	b	.L13
	.cfi_endproc
.LFE4283:
	.size	update16x8_sve, .-update16x8_sve
	.align	2
	.p2align 4,,11
	.type	update4x8_sve, %function
update4x8_sve:
.LFB4281:
	.cfi_startproc
	cmp	w0, 0
	ble	.L21
	sxtw	x10, w2
	sub	w0, w0, #1
	add	x2, x10, x2, sxtw 1
	add	x7, x1, 8
	lsl	x11, x10, 3
	sbfiz	x9, x4, 3, 32
	add	x7, x7, x0, uxtw 3
	lsl	x8, x2, 3
	lsl	x10, x10, 4
	mov	z1.d, #0
	ptrue	p0.b, all
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	.p2align 3,,7
.L20:
	add	x4, x1, x11
	add	x2, x1, x10
	add	x0, x1, x8
	ld1rd	z6.d, p0/z, [x1]
	ld1rd	z5.d, p0/z, [x2]
	add	x1, x1, 8
	ld1d	z0.d, p0/z, [x3]
	ld1rd	z7.d, p0/z, [x4]
	fmla	z2.d, p0/m, z0.d, z5.d
	add	x3, x3, x9
	ld1rd	z5.d, p0/z, [x0]
	fmla	z3.d, p0/m, z0.d, z7.d
	fmla	z4.d, p0/m, z0.d, z6.d
	fmla	z1.d, p0/m, z0.d, z5.d
	cmp	x7, x1
	bne	.L20
.L19:
	ptrue	p0.b, all
	sbfiz	x0, x6, 3, 32
	ld1d	z0.d, p0/z, [x5]
	fsub	z0.d, z0.d, z4.d
	st1d	z0.d, p0, [x5]
	add	x5, x5, x0
	ld1d	z0.d, p0/z, [x5]
	fsub	z0.d, z0.d, z3.d
	st1d	z0.d, p0, [x5]
	add	x5, x5, x0
	ld1d	z0.d, p0/z, [x5]
	fsub	z0.d, z0.d, z2.d
	st1d	z0.d, p0, [x5]
	add	x5, x5, x0
	ld1d	z0.d, p0/z, [x5]
	fsub	z0.d, z0.d, z1.d
	st1d	z0.d, p0, [x5]
	ret
	.p2align 2,,3
.L21:
	mov	z1.d, #0
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	b	.L19
	.cfi_endproc
.LFE4281:
	.size	update4x8_sve, .-update4x8_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4286:
	.cfi_startproc
	sub	sp, sp, #656
	.cfi_def_cfa_offset 656
	stp	x29, x30, [sp]
	.cfi_offset 29, -656
	.cfi_offset 30, -648
	mov	x29, sp
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -624
	.cfi_offset 22, -616
	ldp	x2, x21, [x0]
	str	x2, [sp, 192]
	ldr	w2, [x0, 24]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -640
	.cfi_offset 20, -632
	ldp	w20, w1, [x0, 36]
	str	w2, [sp, 128]
	ldr	w2, [x0, 28]
	str	w2, [sp, 176]
	ldr	w2, [x0, 32]
	str	w2, [sp, 104]
	str	w1, [sp, 108]
	str	x0, [sp, 168]
	cbz	w1, .L140
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	csinc	w0, w0, wzr, eq
	str	w0, [sp, 108]
.L140:
	ldr	w0, [sp, 128]
	cmp	w0, 0
	ble	.L23
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -600
	.cfi_offset 23, -608
	add	x24, sp, 592
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -584
	.cfi_offset 25, -592
	sbfiz	x25, x20, 3, 32
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -568
	.cfi_offset 27, -576
	bl	omp_get_num_threads
	mov	w19, w0
	str	w0, [sp, 384]
	bl	omp_get_thread_num
	ldr	w8, [sp, 176]
	mov	w11, w0
	sxtw	x6, w20
	ldr	w13, [sp, 104]
	adds	w2, w8, 7
	add	w1, w8, 14
	csel	w0, w1, w2, mi
	add	x1, x6, 1
	mov	w2, 24
	sxtw	x7, w13
	asr	w0, w0, 3
	lsl	x9, x1, 4
	smull	x2, w20, w2
	add	x14, x9, 16
	stp	x9, x14, [sp, 224]
	add	x9, x9, 32
	add	x5, x7, 1
	sdiv	w1, w0, w19
	str	x9, [sp, 240]
	ldr	x12, [sp, 192]
	add	x9, x2, 16
	str	x9, [sp, 248]
	add	x9, x2, 32
	add	x2, x2, 48
	lsl	x10, x7, 3
	add	x4, x12, 8
	stp	x9, x2, [sp, 256]
	lsl	x2, x5, 11
	msub	w0, w1, w19, w0
	str	x2, [sp, 504]
	add	x2, x4, x10
	sbfiz	x13, x13, 1, 32
	neg	x4, x6, lsl 7
	str	x2, [sp, 304]
	add	x2, x10, 8
	cmp	w11, w0
	str	x4, [sp, 520]
	lsl	x4, x6, 7
	stp	x4, x2, [sp, 472]
	add	x2, x13, x7
	cinc	w1, w1, lt
	lsl	x4, x7, 6
	stp	x2, x4, [sp, 408]
	lsl	x2, x6, 8
	str	x2, [sp, 496]
	lsl	x2, x7, 8
	str	x2, [sp, 512]
	lsl	x2, x7, 7
	str	x2, [sp, 464]
	mul	w2, w1, w11
	neg	x4, x6, lsl 6
	str	x6, [sp, 144]
	add	w0, w0, w2
	str	x10, [sp, 312]
	csel	w0, w2, w0, lt
	lsl	x2, x6, 6
	add	w1, w1, w0
	str	w0, [sp, 440]
	lsl	w0, w0, 3
	str	w11, [sp, 328]
	str	w0, [sp, 332]
	add	w3, w8, 63
	str	x7, [sp, 336]
	mov	x27, x25
	str	w1, [sp, 388]
	lsl	w1, w1, 3
	str	x13, [sp, 400]
	mov	x28, x21
	str	x2, [sp, 456]
	lsl	x2, x7, 5
	str	x2, [sp, 448]
	neg	x2, x6, lsl 5
	str	x4, [sp, 528]
	str	x2, [sp, 536]
	str	w1, [sp, 344]
	sub	w1, w8, w0
	sxtw	x0, w0
	str	x0, [sp, 488]
	lsl	x0, x6, 5
	str	x0, [sp, 424]
	asr	w0, w3, 6
	str	w0, [sp, 348]
	add	x0, x25, 16
	str	x0, [sp, 200]
	add	x0, x25, 32
	str	x0, [sp, 208]
	add	x0, x25, 48
	mov	w25, w20
	stp	xzr, xzr, [sp, 152]
	str	x0, [sp, 216]
	stp	xzr, x12, [sp, 288]
	str	x7, [sp, 320]
	str	w1, [sp, 444]
.L46:
	ldr	x2, [sp, 160]
	str	w2, [sp, 100]
	ldr	w3, [sp, 128]
	add	w0, w2, 256
	str	w2, [sp, 132]
	sub	w1, w3, w2
	cmp	w1, 255
	ldr	w1, [sp, 440]
	csel	w26, w0, w3, gt
	ldr	w0, [sp, 388]
	cmp	w0, w1
	bgt	.L264
	bl	GOMP_barrier
	ldr	x0, [sp, 168]
	ldr	x0, [x0, 16]
	ldr	x0, [x0]
	cbz	x0, .L139
.L131:
	bl	GOMP_barrier
.L139:
	ldr	w0, [sp, 128]
	cmp	w26, w0
	bge	.L48
	ldr	w0, [sp, 128]
	add	w1, w0, 63
	subs	w1, w1, w26
	add	w0, w1, 63
	csel	w0, w0, w1, mi
	ldr	w1, [sp, 176]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L48
	ldr	w1, [sp, 348]
	ldr	w2, [sp, 384]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	ldr	w2, [sp, 328]
	cmp	w2, w0
	bcc	.L49
.L130:
	ldr	w2, [sp, 328]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L265
.L48:
	bl	GOMP_barrier
	ldp	x2, x0, [sp, 152]
	ldr	x1, [sp, 496]
	add	x2, x2, x1
	add	x0, x0, 256
	stp	x2, x0, [sp, 152]
	ldr	x2, [sp, 288]
	add	x1, x2, x1
	str	x1, [sp, 288]
	ldr	x2, [sp, 296]
	ldr	x1, [sp, 504]
	add	x2, x2, x1
	str	x2, [sp, 296]
	ldr	x2, [sp, 304]
	add	x1, x2, x1
	str	x1, [sp, 304]
	ldr	x1, [sp, 320]
	ldr	x2, [sp, 512]
	add	x1, x1, x2
	str	x1, [sp, 320]
	ldr	w1, [sp, 128]
	cmp	w1, w0
	bgt	.L46
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L23:
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	add	sp, sp, 656
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L264:
	.cfi_def_cfa_offset 656
	.cfi_offset 19, -640
	.cfi_offset 20, -632
	.cfi_offset 21, -624
	.cfi_offset 22, -616
	.cfi_offset 23, -608
	.cfi_offset 24, -600
	.cfi_offset 25, -592
	.cfi_offset 26, -584
	.cfi_offset 27, -576
	.cfi_offset 28, -568
	.cfi_offset 29, -656
	.cfi_offset 30, -648
	ldp	x23, x0, [sp, 480]
	mov	w21, 8
	ldr	x1, [sp, 288]
	mov	w22, 1
	ldr	w17, [sp, 332]
	ldr	x10, [sp, 144]
	add	x20, x0, x1
	ldr	x0, [sp, 160]
	mov	x16, x20
	ldr	x1, [sp, 192]
	mov	w19, w0
	add	x18, x1, x0, lsl 3
.L29:
	ldr	w0, [sp, 176]
	sub	w5, w0, w17
	cmp	w5, 8
	csel	w7, w5, w21, le
	cmp	w26, w19
	ble	.L34
	cmp	w5, 0
	add	x0, sp, 512
	ldp	x13, x9, [sp, 296]
	csel	w7, w7, w22, gt
	add	x15, x28, x16, lsl 3
	ldr	w12, [sp, 132]
	ldr	x14, [sp, 320]
	mov	x8, x15
	and	w6, w7, -2
	mov	x11, x16
	lsr	w4, w7, 1
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
.L143:
	ldr	d2, [x13]
	cmp	w5, 0
	ble	.L37
	cmp	w5, 1
	ble	.L145
	ldr	q0, [x8]
	ldr	q3, [sp, 592]
	dup	v1.2d, v2.d[0]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x8]
	cmp	w4, 1
	bls	.L36
	ldr	q0, [x8, 16]
	ldr	q3, [sp, 608]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x8, 16]
	cmp	w4, 2
	beq	.L36
	ldr	q0, [x8, 32]
	ldr	q3, [sp, 624]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x8, 32]
	cmp	w4, 3
	beq	.L36
	ldr	q0, [x8, 48]
	ldr	q3, [sp, 640]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x8, 48]
.L36:
	sxtw	x0, w6
	cmp	w6, w7
	beq	.L37
.L35:
	add	x1, x0, x11
	ldr	d1, [x24, x0, lsl 3]
	ldr	d0, [x28, x1, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x28, x1, lsl 3]
.L37:
	add	w12, w12, 1
	cmp	w26, w12
	beq	.L34
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w12, w19
	ble	.L39
	cmp	w5, 0
	ble	.L39
	add	x3, x18, x14, lsl 3
	mov	x2, x15
	mov	x1, x16
.L42:
	ldr	d0, [x3]
	cmp	w5, 1
	ble	.L266
	dup	v3.2d, v0.d[0]
	ldr	q2, [x2]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w4, 1
	bls	.L43
	ldr	q2, [x2, 16]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
	cmp	w4, 2
	beq	.L43
	ldr	q2, [x2, 32]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w4, 3
	beq	.L43
	ldr	q2, [x2, 48]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
.L43:
	sxtw	x0, w6
	cmp	w6, w7
	beq	.L44
.L40:
	add	x30, x0, x1
	ldr	d1, [x24, x0, lsl 3]
	ldr	d2, [x28, x30, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x24, x0, lsl 3]
.L44:
	add	x3, x3, 8
	add	x1, x1, x10
	add	x2, x2, x27
	cmp	x3, x9
	bne	.L42
.L39:
	ldr	x0, [sp, 336]
	add	x13, x13, x23
	add	x9, x9, x23
	add	x11, x11, x10
	add	x8, x8, x27
	add	x14, x14, x0
	b	.L143
.L266:
	mov	x0, 0
	b	.L40
.L145:
	mov	x0, 0
	b	.L35
.L34:
	ldr	w0, [sp, 344]
	add	w17, w17, 8
	add	x16, x16, 8
	cmp	w0, w17
	bgt	.L29
	bl	GOMP_barrier
	ldr	x0, [sp, 168]
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L139
	cmp	w26, w19
	ble	.L131
	ldr	w0, [sp, 100]
	add	x4, x28, x20, lsl 3
	mov	x2, x3
	mov	x1, x4
	mvn	w0, w0
	ldr	w22, [sp, 332]
	add	w0, w0, w26
	ldr	w20, [sp, 444]
	add	x0, x0, 1
	mov	w3, w26
	mov	w4, w25
	mov	x26, x2
	lsl	x5, x0, 6
	mov	x25, x1
	mov	x0, x5
	mov	x5, x28
	mov	x28, x0
	mov	w8, 8
	mov	w7, 7
	mov	x6, 8
.L134:
	cmp	w20, 8
	add	w19, w22, 7
	csel	w0, w20, w8, le
	cmp	w22, 0
	csel	w19, w19, w22, lt
	sub	w23, w7, w0
	add	x23, x23, 1
	cmp	w20, 7
	asr	w19, w19, 3
	sbfiz	x9, x0, 3, 32
	lsl	x23, x23, 3
	mov	x21, x25
	sbfiz	x19, x19, 14, 32
	csel	x23, x23, x6, le
	add	x19, x26, x19
	stp	x26, x25, [sp, 112]
	add	x10, x28, x19
	mov	w26, w3
	mov	x25, x9
	str	x28, [sp, 136]
	mov	w28, w22
	mov	x22, x10
.L135:
	cmp	w20, 0
	ble	.L133
	ldr	d0, [x21]
	str	d0, [x19]
	cmp	w20, 1
	ble	.L138
	ldr	d0, [x21, 8]
	str	d0, [x19, 8]
	cmp	w20, 2
	beq	.L133
	ldr	d0, [x21, 16]
	str	d0, [x19, 16]
	cmp	w20, 3
	beq	.L133
	ldr	d0, [x21, 24]
	str	d0, [x19, 24]
	cmp	w20, 4
	beq	.L133
	ldr	d0, [x21, 32]
	str	d0, [x19, 32]
	cmp	w20, 5
	beq	.L133
	ldr	d0, [x21, 40]
	str	d0, [x19, 40]
	cmp	w20, 6
	beq	.L133
	ldr	d0, [x21, 48]
	str	d0, [x19, 48]
	cmp	w20, 7
	ble	.L133
	ldr	d0, [x21, 56]
	str	d0, [x19, 56]
.L138:
	cmp	w20, 7
	bgt	.L137
.L133:
	mov	x2, x23
	add	x0, x19, x25
	mov	w1, 0
	str	w4, [sp, 180]
	str	x5, [sp, 184]
	bl	memset
	ldr	w4, [sp, 180]
	mov	w8, 8
	ldr	x5, [sp, 184]
	mov	w7, 7
	mov	x6, 8
.L137:
	add	x19, x19, 64
	add	x21, x21, x27
	cmp	x19, x22
	bne	.L135
	mov	w3, w26
	ldr	w0, [sp, 344]
	ldp	x26, x25, [sp, 112]
	add	w22, w28, 8
	sub	w20, w20, #8
	ldr	x28, [sp, 136]
	add	x25, x25, 64
	cmp	w0, w22
	bgt	.L134
	mov	w26, w3
	mov	w25, w4
	mov	x28, x5
	bl	GOMP_barrier
	b	.L139
.L265:
	ldr	w3, [sp, 348]
	sub	w1, w1, #1
	ldr	w4, [sp, 100]
	ldr	x22, [sp, 160]
	sub	w4, w26, w4
	udiv	w2, w0, w3
	str	w1, [sp, 576]
	sub	w1, w4, #1
	str	x1, [sp, 392]
	ldr	x21, [sp, 192]
	mov	w20, w22
	msub	w0, w2, w3, w0
	add	w1, w26, w2, lsl 6
	ldr	w2, [sp, 128]
	str	w1, [sp, 180]
	lsl	w0, w0, 6
	sub	w1, w2, w1
	str	w0, [sp, 100]
	str	w4, [sp, 280]
	str	wzr, [sp, 284]
	str	w1, [sp, 368]
.L50:
	ldp	w2, w18, [sp, 176]
	ldr	w3, [sp, 100]
	ldr	w0, [sp, 368]
	add	w1, w18, 64
	ldr	w4, [sp, 128]
	add	w19, w3, 64
	cmp	w0, 63
	sub	w0, w2, w3
	csel	w1, w1, w4, gt
	cmp	w0, 63
	ldr	w0, [sp, 108]
	csel	w19, w19, w2, gt
	str	w1, [sp, 120]
	cbnz	w0, .L267
.L53:
	ldr	w0, [sp, 120]
	cmp	w0, w18
	ble	.L60
	ldr	w1, [sp, 100]
	cmp	w1, w19
	bge	.L60
	sxtw	x3, w1
	ldr	w2, [sp, 120]
	ldr	w1, [sp, 104]
	smull	x0, w25, w18
	sub	w2, w2, w18
	str	w2, [sp, 136]
	ldr	x2, [sp, 152]
	str	x3, [sp, 376]
	smaddl	x1, w1, w18, x22
	stp	x21, x22, [sp, 352]
	sub	x2, x2, x0
	add	x0, x3, x0
	str	w20, [sp, 372]
	ldr	x3, [sp, 392]
	add	x23, x21, x1, lsl 3
	ldr	x20, [sp, 168]
	mov	w6, w25
	ldr	x15, [sp, 336]
	lsl	x2, x2, 3
	ldr	x18, [sp, 400]
	add	x0, x28, x0, lsl 3
	ldr	x21, [sp, 408]
	add	x3, x3, 1
	str	x2, [sp, 184]
	str	x0, [sp, 272]
	str	x3, [sp, 544]
.L104:
	ldr	w1, [sp, 136]
	mov	w0, 4
	ldr	w13, [sp, 100]
	cmp	w1, 4
	csel	w0, w1, w0, le
	cmp	w1, 3
	str	w0, [sp, 432]
	cset	w0, gt
	str	w0, [sp, 112]
	ldr	x0, [sp, 544]
	ldr	x12, [sp, 272]
	ldr	x22, [sp, 376]
	add	x14, x23, x0, lsl 3
.L102:
	ldr	x0, [x20, 16]
	sub	w10, w19, w13
	ldr	x3, [x0]
	cbz	x3, .L268
	asr	w0, w13, 3
	mov	x9, 8
	mov	w4, w9
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 112]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	ble	.L269
.L107:
	ldr	w0, [sp, 108]
	cbnz	w0, .L123
	movi	v16.2d, 0
	ldr	w0, [sp, 280]
	cmp	w0, 0
	ble	.L155
	mov	v17.16b, v16.16b
	lsl	x9, x9, 3
	mov	v18.16b, v16.16b
	mov	x0, x23
	mov	v19.16b, v16.16b
	mov	v20.16b, v16.16b
	mov	v21.16b, v16.16b
	mov	v22.16b, v16.16b
	mov	v23.16b, v16.16b
	mov	v24.16b, v16.16b
	mov	v25.16b, v16.16b
	mov	v26.16b, v16.16b
	mov	v27.16b, v16.16b
	mov	v28.16b, v16.16b
	mov	v29.16b, v16.16b
	mov	v30.16b, v16.16b
	mov	v31.16b, v16.16b
	.p2align 3,,7
.L125:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, x9
	ld1r	{v7.2d}, [x0]
	ldr	d6, [x0, x15, lsl 3]
	ldr	d5, [x0, x18, lsl 3]
	fmla	v31.2d, v4.2d, v7.2d
	ldr	d1, [x0, x21, lsl 3]
	fmla	v30.2d, v3.2d, v7.2d
	add	x0, x0, 8
	fmla	v29.2d, v2.2d, v7.2d
	fmla	v28.2d, v0.2d, v7.2d
	fmla	v27.2d, v4.2d, v6.d[0]
	fmla	v26.2d, v3.2d, v6.d[0]
	fmla	v25.2d, v2.2d, v6.d[0]
	fmla	v24.2d, v0.2d, v6.d[0]
	fmla	v23.2d, v4.2d, v5.d[0]
	fmla	v22.2d, v3.2d, v5.d[0]
	fmla	v21.2d, v2.2d, v5.d[0]
	fmla	v20.2d, v0.2d, v5.d[0]
	fmla	v19.2d, v4.2d, v1.d[0]
	fmla	v18.2d, v3.2d, v1.d[0]
	fmla	v17.2d, v2.2d, v1.d[0]
	fmla	v16.2d, v0.2d, v1.d[0]
	cmp	x0, x14
	bne	.L125
.L124:
	ldp	q3, q2, [x12]
	add	x0, x27, x12
	ldp	q1, q0, [x12, 32]
	add	x1, x27, x0
	fsub	v3.2d, v3.2d, v31.2d
	fsub	v2.2d, v2.2d, v30.2d
	fsub	v0.2d, v0.2d, v28.2d
	fsub	v1.2d, v1.2d, v29.2d
	stp	q3, q2, [x12]
	stp	q1, q0, [x12, 32]
	ldr	q0, [x27, x12]
	fsub	v0.2d, v0.2d, v27.2d
	str	q0, [x27, x12]
	ldr	x2, [sp, 200]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v26.2d
	str	q0, [x2, x12]
	ldr	x2, [sp, 208]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v25.2d
	str	q0, [x2, x12]
	ldr	x2, [sp, 216]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v24.2d
	str	q0, [x2, x12]
	ldr	q0, [x27, x0]
	fsub	v0.2d, v0.2d, v23.2d
	str	q0, [x27, x0]
	ldr	x0, [sp, 224]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v22.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 232]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v21.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 240]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v20.2d
	str	q0, [x0, x12]
	ldr	q0, [x27, x1]
	fsub	v0.2d, v0.2d, v19.2d
	str	q0, [x27, x1]
	ldr	x0, [sp, 248]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v18.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 256]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v17.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 264]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v16.2d
	str	q0, [x0, x12]
.L126:
	add	w13, w13, 8
	add	x12, x12, 64
	add	x22, x22, 8
	cmp	w19, w13
	bgt	.L102
	ldr	x2, [sp, 184]
	ldr	x3, [sp, 536]
	ldr	x1, [sp, 448]
	add	x2, x2, x3
	ldr	w0, [sp, 136]
	str	x2, [sp, 184]
	add	x23, x23, x1
	ldr	x2, [sp, 272]
	sub	w0, w0, #4
	ldr	x3, [sp, 424]
	str	w0, [sp, 136]
	ldr	w1, [sp, 120]
	add	x2, x2, x3
	str	x2, [sp, 272]
	sub	w0, w1, w0
	cmp	w1, w0
	bgt	.L104
	ldp	x21, x22, [sp, 352]
	mov	w25, w6
	ldr	w20, [sp, 372]
.L60:
	ldr	w0, [sp, 284]
	ldr	w1, [sp, 576]
	cmp	w0, w1
	beq	.L48
	ldr	w0, [sp, 100]
	ldr	w1, [sp, 176]
	add	w0, w0, 64
	str	w0, [sp, 100]
	cmp	w1, w0
	ble	.L270
.L103:
	ldr	w0, [sp, 284]
	add	w0, w0, 1
	str	w0, [sp, 284]
	b	.L50
.L123:
	ldr	w2, [sp, 104]
	mov	x5, x12
	ldr	w0, [sp, 132]
	mov	x1, x23
	sub	w0, w26, w0
	bl	update4x8_sve
	b	.L126
.L268:
	ldr	x0, [sp, 184]
	mov	w4, w6
	ldr	x9, [sp, 144]
	add	x3, x12, x0
	ldr	w0, [sp, 112]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	bgt	.L107
.L269:
	ldr	w0, [sp, 136]
	cmp	w0, 0
	ble	.L126
	cmp	w10, 8
	mov	w16, 8
	csel	w16, w10, w16, le
	cmp	w10, 0
	str	x12, [sp, 568]
	csinc	w16, w16, wzr, gt
	str	w13, [sp, 580]
	and	w5, w16, -2
	ldp	x12, x13, [sp, 352]
	str	w19, [sp, 552]
	ldr	w1, [sp, 120]
	lsl	x17, x9, 3
	ldr	w19, [sp, 372]
	mov	w30, 0
	str	x15, [sp, 560]
	sub	w25, w1, w0
	ldr	w15, [sp, 432]
	lsr	w1, w16, 1
	str	x14, [sp, 584]
	ldr	x14, [sp, 312]
.L113:
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w19
	ble	.L271
	sxtw	x11, w25
	cmp	w10, 0
	ble	.L116
	madd	x11, x11, x14, x12
	mov	x7, x3
	mov	x8, x13
	mov	x4, 0
	.p2align 3,,7
.L120:
	ldr	d0, [x11, x8, lsl 3]
	cmp	w10, 1
	ble	.L272
	dup	v3.2d, v0.d[0]
	ldr	q2, [x7]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w1, 1
	bls	.L121
	ldr	q2, [x7, 16]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
	cmp	w1, 2
	beq	.L121
	ldr	q2, [x7, 32]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w1, 3
	beq	.L121
	ldr	q2, [x7, 48]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
.L121:
	sxtw	x0, w5
	cmp	w5, w16
	beq	.L122
.L118:
	add	x2, x0, x4
	ldr	d1, [x24, x0, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x24, x0, lsl 3]
.L122:
	add	x8, x8, 1
	add	x4, x4, x9
	add	x7, x7, x17
	cmp	w26, w8
	bgt	.L120
	smaddl	x0, w25, w6, x22
	cmp	w10, 1
	ble	.L153
.L273:
	lsl	x4, x0, 3
	ldr	q1, [sp, 592]
	add	x2, x28, x4
	ldr	q0, [x28, x4]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x28, x4]
	cmp	w1, 1
	bls	.L115
	ldr	q0, [x2, 16]
	ldr	q1, [sp, 608]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 16]
	cmp	w1, 2
	beq	.L115
	ldr	q0, [x2, 32]
	ldr	q1, [sp, 624]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 32]
	cmp	w1, 3
	beq	.L115
	ldr	q0, [x2, 48]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 48]
.L115:
	sxtw	x2, w5
	cmp	w5, w16
	beq	.L116
.L114:
	add	x0, x2, x0
	ldr	d1, [x24, x2, lsl 3]
	ldr	d0, [x28, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x28, x0, lsl 3]
.L116:
	add	w30, w30, 1
	add	w25, w25, 1
	cmp	w30, w15
	blt	.L113
	ldr	w19, [sp, 552]
	ldr	w13, [sp, 580]
	ldr	x15, [sp, 560]
	ldr	x12, [sp, 568]
	ldr	x14, [sp, 584]
	b	.L126
.L272:
	mov	x0, 0
	b	.L118
.L271:
	cmp	w10, 0
	ble	.L116
	smaddl	x0, w25, w6, x22
	cmp	w10, 1
	bgt	.L273
.L153:
	mov	x2, 0
	b	.L114
.L155:
	mov	v17.16b, v16.16b
	mov	v18.16b, v16.16b
	mov	v19.16b, v16.16b
	mov	v20.16b, v16.16b
	mov	v21.16b, v16.16b
	mov	v22.16b, v16.16b
	mov	v23.16b, v16.16b
	mov	v24.16b, v16.16b
	mov	v25.16b, v16.16b
	mov	v26.16b, v16.16b
	mov	v27.16b, v16.16b
	mov	v28.16b, v16.16b
	mov	v29.16b, v16.16b
	mov	v30.16b, v16.16b
	mov	v31.16b, v16.16b
	b	.L124
.L267:
	uxtw	x0, w1
	sub	w0, w0, w18
	cmp	w0, 15
	ble	.L54
	ldr	w2, [sp, 104]
	smull	x0, w25, w18
	ldrsw	x3, [sp, 100]
	mov	x10, x27
	ldr	x9, [sp, 168]
	mov	w8, w19
	smaddl	x1, w2, w18, x22
	str	x3, [sp, 272]
	ldr	x2, [sp, 152]
	ldr	x27, [sp, 312]
	sub	x2, x2, x0
	add	x0, x0, x3
	lsl	x2, x2, 3
	str	x2, [sp, 136]
	add	x0, x28, x0, lsl 3
	str	x0, [sp, 184]
	add	x0, x21, x1, lsl 3
	str	x0, [sp, 112]
.L82:
	ldr	w0, [sp, 100]
	add	w23, w18, 16
	cmp	w0, w8
	bge	.L56
	ldr	w7, [sp, 100]
	add	w23, w18, 16
	ldr	x5, [sp, 184]
	ldr	x19, [sp, 272]
	b	.L87
.L85:
	ldr	w2, [sp, 104]
	mov	w6, w25
	ldr	x1, [sp, 112]
	str	w8, [sp, 352]
	ldr	w0, [sp, 132]
	str	w18, [sp, 360]
	sub	w0, w26, w0
	str	w7, [sp, 372]
	str	x10, [sp, 376]
	str	x9, [sp, 432]
	bl	update16x8_sve
	ldr	w8, [sp, 352]
	ldr	w18, [sp, 360]
	ldr	w7, [sp, 372]
	ldr	x10, [sp, 376]
	ldr	x9, [sp, 432]
.L91:
	add	w7, w7, 8
	add	x5, x5, 64
	add	x19, x19, 8
	cmp	w8, w7
	ble	.L56
.L87:
	ldr	x0, [x9, 16]
	sub	w13, w8, w7
	ldr	x3, [x0]
	cbz	x3, .L274
	asr	w0, w7, 3
	mov	x14, 8
	mov	w4, w14
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L101:
	cmp	w13, 7
	bgt	.L85
	add	x0, sp, 512
	cmp	w13, 0
	csinc	w15, w13, wzr, gt
	lsl	x16, x14, 3
	mov	w17, w18
	and	w11, w15, -2
	stp	xzr, xzr, [x0, 80]
	lsr	w6, w15, 1
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w20
	ble	.L275
	.p2align 3,,7
.L88:
	sxtw	x12, w17
	cmp	w13, 0
	ble	.L94
	madd	x12, x12, x27, x21
	mov	x2, x3
	mov	x4, x22
	mov	x1, 0
	.p2align 3,,7
.L98:
	ldr	d0, [x12, x4, lsl 3]
	cmp	w13, 1
	ble	.L276
	dup	v3.2d, v0.d[0]
	ldr	q2, [x2]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w6, 1
	bls	.L99
	ldr	q2, [x2, 16]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
	cmp	w6, 2
	beq	.L99
	ldr	q2, [x2, 32]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w6, 3
	beq	.L99
	ldr	q2, [x2, 48]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
.L99:
	sxtw	x0, w11
	cmp	w11, w15
	beq	.L100
.L96:
	add	x30, x0, x1
	ldr	d1, [x24, x0, lsl 3]
	ldr	d2, [x3, x30, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x24, x0, lsl 3]
.L100:
	add	x4, x4, 1
	add	x1, x1, x14
	add	x2, x2, x16
	cmp	w26, w4
	bgt	.L98
	smaddl	x0, w17, w25, x19
	cmp	w13, 1
	ble	.L151
.L277:
	lsl	x2, x0, 3
	ldr	q1, [sp, 592]
	add	x1, x28, x2
	ldr	q0, [x28, x2]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x28, x2]
	cmp	w6, 1
	bls	.L93
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 608]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w6, 2
	beq	.L93
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 624]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w6, 3
	beq	.L93
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L93:
	sxtw	x1, w11
	cmp	w11, w15
	beq	.L94
.L92:
	add	x0, x1, x0
	ldr	d1, [x24, x1, lsl 3]
	ldr	d0, [x28, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x28, x0, lsl 3]
.L94:
	add	w17, w17, 1
	cmp	w17, w23
	beq	.L91
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w20
	bgt	.L88
.L275:
	cmp	w13, 0
	ble	.L94
	smaddl	x0, w17, w25, x19
	cmp	w13, 1
	bgt	.L277
.L151:
	mov	x1, 0
	b	.L92
	.p2align 2,,3
.L276:
	mov	x0, 0
	b	.L96
.L274:
	ldp	x0, x14, [sp, 136]
	mov	w4, w25
	add	x3, x5, x0
	b	.L101
.L56:
	ldr	x0, [sp, 112]
	mov	w18, w23
	ldr	x1, [sp, 464]
	ldr	x2, [sp, 520]
	add	x0, x0, x1
	ldr	x1, [sp, 136]
	str	x0, [sp, 112]
	ldr	w0, [sp, 120]
	add	x1, x1, x2
	str	x1, [sp, 136]
	ldr	x1, [sp, 184]
	sub	w0, w0, w23
	ldr	x2, [sp, 472]
	add	x1, x1, x2
	str	x1, [sp, 184]
	cmp	w0, 15
	bgt	.L82
	mov	w19, w8
	mov	x27, x10
.L54:
	ldr	w1, [sp, 120]
	add	w0, w18, 7
	cmp	w1, w0
	ble	.L53
	ldr	w2, [sp, 104]
	smull	x0, w18, w25
	ldr	x3, [sp, 152]
	sub	w1, w1, #8
	ldrsw	x4, [sp, 100]
	sub	w1, w1, w18
	smaddl	x2, w18, w2, x22
	sub	x3, x3, x0
	add	x0, x0, x4
	mov	x10, x27
	ldr	x9, [sp, 168]
	add	x0, x28, x0, lsl 3
	ldr	x7, [sp, 312]
	mov	x27, x22
	mov	w8, w19
	mov	x22, x21
	str	x0, [sp, 184]
	add	x0, x21, x2, lsl 3
	mov	w21, w20
	str	x4, [sp, 352]
	add	w4, w18, 8
	str	w1, [sp, 360]
	and	w1, w1, -8
	lsl	x3, x3, 3
	add	w1, w4, w1
	str	x3, [sp, 112]
	str	x0, [sp, 136]
	str	w1, [sp, 272]
	str	w4, [sp, 372]
.L61:
	ldr	w0, [sp, 100]
	add	w19, w18, 8
	cmp	w0, w8
	bge	.L58
	ldr	w20, [sp, 100]
	add	w19, w18, 8
	ldr	x5, [sp, 184]
	ldr	x23, [sp, 352]
	b	.L67
.L65:
	ldr	w2, [sp, 104]
	mov	w6, w25
	ldr	x1, [sp, 136]
	str	w8, [sp, 376]
	ldr	w0, [sp, 132]
	str	w18, [sp, 432]
	sub	w0, w26, w0
	str	x10, [sp, 544]
	str	x7, [sp, 552]
	str	x9, [sp, 560]
	bl	update8x8_sve
	ldr	w8, [sp, 376]
	ldr	w18, [sp, 432]
	ldr	x10, [sp, 544]
	ldr	x7, [sp, 552]
	ldr	x9, [sp, 560]
.L71:
	add	w20, w20, 8
	add	x5, x5, 64
	add	x23, x23, 8
	cmp	w8, w20
	ble	.L58
.L67:
	ldr	x0, [x9, 16]
	sub	w12, w8, w20
	ldr	x3, [x0]
	cbz	x3, .L278
	asr	w0, w20, 3
	mov	x14, 8
	mov	w4, w14
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L81:
	cmp	w12, 7
	bgt	.L65
	add	x0, sp, 512
	cmp	w12, 0
	csinc	w15, w12, wzr, gt
	lsl	x16, x14, 3
	mov	w17, w18
	and	w11, w15, -2
	stp	xzr, xzr, [x0, 80]
	lsr	w6, w15, 1
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w21
	ble	.L279
.L68:
	sxtw	x13, w17
	cmp	w12, 0
	ble	.L74
	madd	x13, x13, x7, x22
	mov	x2, x3
	mov	x4, x27
	mov	x1, 0
	.p2align 3,,7
.L78:
	ldr	d0, [x13, x4, lsl 3]
	cmp	w12, 1
	ble	.L280
	dup	v3.2d, v0.d[0]
	ldr	q2, [x2]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w6, 1
	bls	.L79
	ldr	q2, [x2, 16]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
	cmp	w6, 2
	beq	.L79
	ldr	q2, [x2, 32]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w6, 3
	beq	.L79
	ldr	q2, [x2, 48]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
.L79:
	sxtw	x0, w11
	cmp	w11, w15
	beq	.L80
.L76:
	add	x30, x0, x1
	ldr	d1, [x24, x0, lsl 3]
	ldr	d2, [x3, x30, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x24, x0, lsl 3]
.L80:
	add	x4, x4, 1
	add	x1, x1, x14
	add	x2, x2, x16
	cmp	w26, w4
	bgt	.L78
	smaddl	x0, w17, w25, x23
	cmp	w12, 1
	ble	.L149
.L281:
	lsl	x2, x0, 3
	ldr	q1, [sp, 592]
	add	x1, x28, x2
	ldr	q0, [x28, x2]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x28, x2]
	cmp	w6, 1
	bls	.L73
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 608]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w6, 2
	beq	.L73
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 624]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w6, 3
	beq	.L73
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L73:
	sxtw	x1, w11
	cmp	w11, w15
	beq	.L74
.L72:
	add	x0, x1, x0
	ldr	d1, [x24, x1, lsl 3]
	ldr	d0, [x28, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x28, x0, lsl 3]
.L74:
	add	w17, w17, 1
	cmp	w19, w17
	beq	.L71
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w21
	bgt	.L68
.L279:
	cmp	w12, 0
	ble	.L74
	smaddl	x0, w17, w25, x23
	cmp	w12, 1
	bgt	.L281
.L149:
	mov	x1, 0
	b	.L72
.L280:
	mov	x0, 0
	b	.L76
.L278:
	ldr	x0, [sp, 112]
	mov	w4, w25
	ldr	x14, [sp, 144]
	add	x3, x0, x5
	b	.L81
.L58:
	ldr	x0, [sp, 136]
	mov	w18, w19
	ldr	x1, [sp, 416]
	add	x0, x0, x1
	str	x0, [sp, 136]
	ldr	x0, [sp, 112]
	ldr	x1, [sp, 528]
	add	x0, x0, x1
	str	x0, [sp, 112]
	ldr	x0, [sp, 184]
	ldr	x1, [sp, 456]
	add	x0, x0, x1
	str	x0, [sp, 184]
	ldr	w0, [sp, 272]
	cmp	w0, w19
	bne	.L61
	ldr	w0, [sp, 360]
	mov	w20, w21
	ldr	w1, [sp, 372]
	mov	x21, x22
	and	w0, w0, -8
	mov	x22, x27
	mov	w19, w8
	mov	x27, x10
	add	w18, w0, w1
	b	.L53
.L49:
	add	w1, w1, 1
	mov	w0, 0
	b	.L130
.L270:
	ldr	w0, [sp, 180]
	ldr	w1, [sp, 128]
	add	w0, w0, 64
	str	wzr, [sp, 100]
	str	w0, [sp, 180]
	sub	w0, w1, w0
	str	w0, [sp, 368]
	b	.L103
	.cfi_endproc
.LFE4286:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4287:
	.cfi_startproc
	sub	sp, sp, #592
	.cfi_def_cfa_offset 592
	mov	x3, x0
	mov	x1, 64
	add	x0, sp, 328
	stp	x29, x30, [sp]
	.cfi_offset 29, -592
	.cfi_offset 30, -584
	mov	x29, sp
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -560
	.cfi_offset 22, -552
	ldp	w2, w22, [x3, 16]
	stp	x19, x20, [sp, 16]
	stp	x23, x24, [sp, 48]
	.cfi_offset 19, -576
	.cfi_offset 20, -568
	.cfi_offset 23, -544
	.cfi_offset 24, -536
	ldp	w23, w20, [x3, 24]
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	.cfi_offset 25, -528
	.cfi_offset 26, -520
	.cfi_offset 27, -512
	.cfi_offset 28, -504
	str	w2, [sp, 128]
	sbfiz	x2, x2, 6, 32
	ldp	x28, x21, [x3]
	bl	posix_memalign
	cmp	w0, 0
	ldr	x0, [sp, 328]
	csel	x25, xzr, x0, ne
	bl	omp_get_num_threads
	mov	w19, w0
	bl	omp_get_thread_num
	mov	w2, w0
	add	w1, w22, 14
	adds	w3, w22, 7
	csel	w0, w1, w3, mi
	asr	w0, w0, 3
	sdiv	w1, w0, w19
	msub	w0, w1, w19, w0
	cmp	w2, w0
	blt	.L284
.L336:
	madd	w0, w1, w2, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L285
	sxtw	x27, w23
	ldr	w2, [sp, 128]
	add	x3, x27, 1
	lsl	w1, w1, 3
	sub	w2, w2, #1
	mov	w6, 40
	lsl	x26, x3, 3
	add	x24, x28, 8
	sub	x8, x26, #8
	lsl	w7, w0, 3
	add	x0, x2, 1
	stp	w7, w1, [sp, 224]
	add	x1, x24, x8
	smull	x2, w23, w6
	sbfiz	x4, x23, 1, 32
	lsl	x5, x27, 2
	str	x1, [sp, 272]
	add	x1, x28, x26
	lsl	x9, x3, 5
	add	x0, x25, x0, lsl 6
	str	x1, [sp, 264]
	lsl	x1, x3, 2
	stp	x5, x2, [sp, 288]
	add	x5, x4, x5
	sub	w6, w22, w7
	str	x1, [sp, 176]
	sub	x1, x9, #32
	str	x0, [sp, 216]
	sxtw	x0, w7
	sbfiz	x23, x20, 3, 32
	str	x0, [sp, 208]
	neg	x0, x27, lsl 4
	str	x1, [sp, 248]
	lsl	x1, x5, 3
	str	x9, [sp, 168]
	str	w6, [sp, 188]
	add	x6, x21, x7, sxtw 3
	stp	x6, x0, [sp, 192]
	add	x0, x27, x27, lsl 2
	str	x8, [sp, 256]
	str	x0, [sp, 280]
	str	x1, [sp, 304]
	add	x1, x4, x27
	str	x1, [sp, 240]
.L288:
	ldr	w0, [sp, 188]
	mov	w19, 8
	cmp	w0, 8
	csel	w19, w0, w19, le
	cbz	x25, .L399
	ldr	w0, [sp, 128]
	cmp	w0, 0
	ble	.L289
	sub	w0, w19, #1
	ldr	w2, [sp, 188]
	add	x0, x0, 1
	mov	w20, 7
	sub	w20, w20, w19
	cmp	w2, 0
	add	x20, x20, 1
	lsl	x0, x0, 3
	mov	x1, 8
	csel	x3, x0, x1, gt
	lsl	x20, x20, 3
	cmp	w2, 7
	ldr	x22, [sp, 192]
	mov	x21, x25
	csel	x20, x20, x1, le
	sbfiz	x19, x19, 3, 32
	str	x24, [sp, 120]
	mov	x24, x21
	mov	x21, x20
	stp	x28, x25, [sp, 104]
	mov	x25, x22
	ldr	x20, [sp, 216]
	mov	x22, x19
	mov	w28, w2
	mov	x19, x3
	str	x3, [sp, 232]
.L327:
	mov	x2, x19
	mov	x1, x25
	mov	x0, x24
	cmp	w28, 0
	ble	.L291
	bl	memcpy
	cmp	w28, 7
	bgt	.L329
.L291:
	mov	x2, x21
	add	x0, x24, x22
	mov	w1, 0
	bl	memset
.L329:
	add	x24, x24, 64
	add	x25, x25, x23
	cmp	x24, x20
	bne	.L327
	ldr	w20, [sp, 128]
	mov	w9, 4
	add	x0, sp, 336
	mov	x2, 256
	cmp	w20, 4
	mov	w1, 0
	csel	w19, w20, w9, le
	ldp	x28, x25, [sp, 104]
	ldr	x24, [sp, 120]
	bl	memset
	cmp	w20, 3
	ble	.L295
	movi	v0.2d, 0
	stp	q0, q0, [sp, 336]
	stp	q0, q0, [sp, 368]
	stp	q0, q0, [sp, 400]
	stp	q0, q0, [sp, 432]
	stp	q0, q0, [sp, 464]
	stp	q0, q0, [sp, 496]
	stp	q0, q0, [sp, 528]
	stp	q0, q0, [sp, 560]
.L295:
	sub	w9, w19, #1
	mov	x3, x27
	add	x0, sp, 336
	mov	x1, x25
	mov	x6, x28
	mov	w2, 0
.L321:
	ldr	q0, [x0]
	ldp	q3, q2, [x1]
	ld1r	{v4.2d}, [x6]
	ldr	q1, [x1, 32]
	fsub	v3.2d, v3.2d, v0.2d
	ldr	q0, [x1, 48]
	fdiv	v3.2d, v3.2d, v4.2d
	str	q3, [x1]
	ldr	q3, [x0, 16]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v4.2d
	str	q2, [x1, 16]
	ldr	q2, [x0, 32]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v1.2d, v1.2d, v4.2d
	str	q1, [x1, 32]
	ldr	q1, [x0, 48]
	fsub	v0.2d, v0.2d, v1.2d
	fdiv	v0.2d, v0.2d, v4.2d
	str	q0, [x1, 48]
	cmp	w2, w9
	beq	.L400
	add	w7, w2, 1
	cmp	w7, 0
	ble	.L326
	cmp	w2, 1
	ble	.L341
	ldr	d1, [x28, x3, lsl 3]
	mov	w4, 2
	ldp	q3, q2, [x25]
	dup	v1.2d, v1.d[0]
	ldr	d0, [x24, x3, lsl 3]
	ldp	q5, q4, [x0, 64]
	dup	v0.2d, v0.d[0]
	fmul	v3.2d, v1.2d, v3.2d
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v5.2d, v3.2d, v5.2d
	fadd	v4.2d, v2.2d, v4.2d
	ldp	q3, q2, [x0, 96]
	stp	q5, q4, [x0, 64]
	ldp	q7, q6, [x25, 64]
	fmul	v7.2d, v0.2d, v7.2d
	fmul	v6.2d, v0.2d, v6.2d
	fadd	v5.2d, v7.2d, v5.2d
	fadd	v4.2d, v6.2d, v4.2d
	stp	q5, q4, [x0, 64]
	ldp	q6, q7, [x25, 32]
	fmul	v6.2d, v1.2d, v6.2d
	fmul	v1.2d, v1.2d, v7.2d
	fadd	v3.2d, v6.2d, v3.2d
	fadd	v2.2d, v1.2d, v2.2d
	stp	q3, q2, [x0, 96]
	ldp	q1, q6, [x25, 96]
	fmul	v1.2d, v0.2d, v1.2d
	fmul	v0.2d, v0.2d, v6.2d
	fadd	v3.2d, v1.2d, v3.2d
	fadd	v2.2d, v0.2d, v2.2d
	stp	q3, q2, [x0, 96]
.L325:
	sxtw	x5, w4
	add	x8, x5, x3
	add	w10, w4, 1
	lsl	x5, x5, 6
	ldr	d0, [x28, x8, lsl 3]
	add	x8, x25, x5
	ldr	q1, [x25, x5]
	dup	v0.2d, v0.d[0]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v5.2d, v1.2d, v5.2d
	str	q5, [x0, 64]
	ldr	q1, [x8, 16]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v4.2d, v1.2d, v4.2d
	str	q4, [x0, 80]
	ldr	q1, [x8, 32]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v3.2d, v1.2d, v3.2d
	str	q3, [x0, 96]
	ldr	q1, [x8, 48]
	fmul	v0.2d, v0.2d, v1.2d
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x0, 112]
	cmp	w4, w2
	bge	.L326
	sxtw	x5, w10
	add	w4, w4, 2
	add	x11, x5, x3
	lsl	x5, x5, 6
	add	x8, x25, x5
	ldr	d1, [x28, x11, lsl 3]
	ldr	q2, [x25, x5]
	dup	v1.2d, v1.d[0]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v5.2d, v2.2d, v5.2d
	str	q5, [x0, 64]
	ldr	q2, [x8, 16]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v4.2d, v2.2d, v4.2d
	str	q4, [x0, 80]
	ldr	q2, [x8, 32]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [x0, 96]
	ldr	q3, [x8, 48]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v1.2d, v0.2d
	str	q0, [x0, 112]
	cmp	w2, w10
	ble	.L326
	add	x5, x3, 2
	sbfiz	x2, x4, 6, 32
	add	x4, x25, x2
	ldr	d1, [x28, x5, lsl 3]
	ldr	q3, [x25, x2]
	dup	v1.2d, v1.d[0]
	fmul	v3.2d, v1.2d, v3.2d
	fadd	v3.2d, v3.2d, v5.2d
	str	q3, [x0, 64]
	ldr	q3, [x4, 16]
	fmul	v3.2d, v1.2d, v3.2d
	fadd	v3.2d, v3.2d, v4.2d
	str	q3, [x0, 80]
	ldr	q3, [x4, 32]
	fmul	v3.2d, v1.2d, v3.2d
	fadd	v2.2d, v3.2d, v2.2d
	str	q2, [x0, 96]
	ldr	q2, [x4, 48]
	fmul	v1.2d, v1.2d, v2.2d
	fadd	v0.2d, v1.2d, v0.2d
	str	q0, [x0, 112]
.L326:
	add	x6, x6, x26
	add	x1, x1, 64
	add	x0, x0, 64
	add	x3, x3, x27
	mov	w2, w7
	b	.L321
.L400:
	ldr	w1, [sp, 128]
	cmp	w1, 4
	ble	.L296
	mov	x10, x26
	mov	x13, x24
	ldp	x0, x26, [sp, 240]
	sub	w20, w1, #4
	ldr	x2, [sp, 288]
	add	x19, x25, 256
	str	x23, [sp, 312]
	add	x0, x0, x2
	mov	x2, 4
	mov	w21, w2
	str	x2, [sp, 136]
	add	x18, x28, x0, lsl 3
	ldr	x0, [sp, 168]
	mov	x23, x18
	add	x0, x28, x0
	str	x0, [sp, 104]
	ldr	x0, [sp, 280]
	add	x0, x0, x2
	str	x0, [sp, 112]
	ldr	x0, [sp, 256]
	add	x0, x28, x0, lsl 2
	str	x0, [sp, 144]
	ldr	x0, [sp, 296]
	add	x4, x28, x0
	ldr	x0, [sp, 304]
	mov	x24, x4
	add	x22, x28, x0
	mov	w0, 5
	str	w0, [sp, 132]
	mov	w0, 7
	str	w0, [sp, 120]
.L320:
	cmp	w20, 4
	mov	w0, 4
	csel	w0, w20, w0, le
	mov	x2, 256
	mov	w1, 0
	stp	x10, x13, [sp, 152]
	str	w0, [sp, 184]
	add	x0, sp, 336
	bl	memset
	cmp	w20, 3
	ldp	x10, x13, [sp, 152]
	ble	.L401
	movi	v16.2d, 0
	mov	x1, x25
	ldr	x0, [sp, 200]
	mov	v17.16b, v16.16b
	add	x2, x0, x22
	mov	v18.16b, v16.16b
	mov	x0, 0
	mov	v19.16b, v16.16b
	mov	v20.16b, v16.16b
	mov	v21.16b, v16.16b
	mov	v22.16b, v16.16b
	mov	v23.16b, v16.16b
	mov	v24.16b, v16.16b
	mov	v25.16b, v16.16b
	mov	v26.16b, v16.16b
	mov	v27.16b, v16.16b
	mov	v28.16b, v16.16b
	mov	v29.16b, v16.16b
	mov	v30.16b, v16.16b
	mov	v31.16b, v16.16b
	.p2align 3,,7
.L314:
	ldp	q4, q3, [x1]
	ldp	q2, q0, [x1, 32]
	add	x1, x1, 64
	ldr	d7, [x2, x0, lsl 3]
	ldr	d6, [x24, x0, lsl 3]
	ldr	d5, [x22, x0, lsl 3]
	fmla	v31.2d, v4.2d, v7.d[0]
	ldr	d1, [x23, x0, lsl 3]
	fmla	v30.2d, v3.2d, v7.d[0]
	add	x0, x0, 1
	fmla	v29.2d, v2.2d, v7.d[0]
	fmla	v28.2d, v0.2d, v7.d[0]
	fmla	v27.2d, v4.2d, v6.d[0]
	fmla	v26.2d, v3.2d, v6.d[0]
	fmla	v25.2d, v2.2d, v6.d[0]
	fmla	v24.2d, v0.2d, v6.d[0]
	fmla	v23.2d, v4.2d, v5.d[0]
	fmla	v22.2d, v3.2d, v5.d[0]
	fmla	v21.2d, v2.2d, v5.d[0]
	fmla	v20.2d, v0.2d, v5.d[0]
	fmla	v19.2d, v4.2d, v1.d[0]
	fmla	v18.2d, v3.2d, v1.d[0]
	fmla	v17.2d, v2.2d, v1.d[0]
	fmla	v16.2d, v0.2d, v1.d[0]
	cmp	w21, w0
	bgt	.L314
	stp	q31, q30, [sp, 336]
	stp	q29, q28, [sp, 368]
	stp	q27, q26, [sp, 400]
	stp	q25, q24, [sp, 432]
	stp	q23, q22, [sp, 464]
	stp	q21, q20, [sp, 496]
	stp	q19, q18, [sp, 528]
	stp	q17, q16, [sp, 560]
.L299:
	ldr	w0, [sp, 184]
	ldp	x5, x4, [sp, 104]
	sub	w14, w0, #1
	mov	x1, x19
	add	x0, sp, 336
	mov	w3, 0
.L317:
	ldr	q0, [x0]
	ldp	q3, q2, [x1]
	ld1r	{v4.2d}, [x5]
	ldr	q1, [x1, 32]
	fsub	v3.2d, v3.2d, v0.2d
	ldr	q0, [x1, 48]
	fdiv	v3.2d, v3.2d, v4.2d
	str	q3, [x1]
	ldr	q3, [x0, 16]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v4.2d
	str	q2, [x1, 16]
	ldr	q2, [x0, 32]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v1.2d, v1.2d, v4.2d
	str	q1, [x1, 32]
	ldr	q1, [x0, 48]
	fsub	v0.2d, v0.2d, v1.2d
	fdiv	v0.2d, v0.2d, v4.2d
	str	q0, [x1, 48]
	cmp	w3, w14
	beq	.L315
	add	w7, w3, 1
	cmp	w7, 0
	ble	.L319
	cmp	w3, 1
	ble	.L340
	ldr	d1, [x28, x4, lsl 3]
	mov	w2, 2
	ldp	q3, q2, [x19]
	dup	v1.2d, v1.d[0]
	ldr	d0, [x13, x4, lsl 3]
	ldp	q5, q4, [x0, 64]
	dup	v0.2d, v0.d[0]
	fmul	v3.2d, v1.2d, v3.2d
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v5.2d, v3.2d, v5.2d
	fadd	v4.2d, v2.2d, v4.2d
	ldp	q3, q2, [x0, 96]
	stp	q5, q4, [x0, 64]
	ldp	q7, q6, [x19, 64]
	fmul	v7.2d, v0.2d, v7.2d
	fmul	v6.2d, v0.2d, v6.2d
	fadd	v5.2d, v7.2d, v5.2d
	fadd	v4.2d, v6.2d, v4.2d
	stp	q5, q4, [x0, 64]
	ldp	q6, q7, [x19, 32]
	fmul	v6.2d, v1.2d, v6.2d
	fmul	v1.2d, v1.2d, v7.2d
	fadd	v3.2d, v6.2d, v3.2d
	fadd	v2.2d, v1.2d, v2.2d
	stp	q3, q2, [x0, 96]
	ldp	q1, q6, [x19, 96]
	fmul	v1.2d, v0.2d, v1.2d
	fmul	v0.2d, v0.2d, v6.2d
	fadd	v3.2d, v1.2d, v3.2d
	fadd	v2.2d, v0.2d, v2.2d
	stp	q3, q2, [x0, 96]
.L318:
	add	x8, x4, x2, sxtw
	add	w6, w2, w21
	add	w9, w2, 1
	sbfiz	x6, x6, 6, 32
	ldr	d0, [x28, x8, lsl 3]
	add	x8, x25, x6
	dup	v0.2d, v0.d[0]
	ldr	q1, [x25, x6]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v5.2d, v1.2d, v5.2d
	str	q5, [x0, 64]
	ldr	q1, [x8, 16]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v4.2d, v1.2d, v4.2d
	str	q4, [x0, 80]
	ldr	q1, [x8, 32]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v3.2d, v1.2d, v3.2d
	str	q3, [x0, 96]
	ldr	q1, [x8, 48]
	fmul	v0.2d, v0.2d, v1.2d
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x0, 112]
	cmp	w2, w3
	bge	.L319
	add	x8, x4, x9, sxtw
	add	w6, w21, w9
	add	w2, w2, 2
	sbfiz	x6, x6, 6, 32
	ldr	d1, [x28, x8, lsl 3]
	add	x8, x25, x6
	ldr	q2, [x25, x6]
	dup	v1.2d, v1.d[0]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v5.2d, v2.2d, v5.2d
	str	q5, [x0, 64]
	ldr	q2, [x8, 16]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v4.2d, v2.2d, v4.2d
	str	q4, [x0, 80]
	ldr	q2, [x8, 32]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [x0, 96]
	ldr	q3, [x8, 48]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v1.2d, v0.2d
	str	q0, [x0, 112]
	cmp	w9, w3
	bge	.L319
	add	x3, x4, 2
	add	w2, w21, w2
	sbfiz	x2, x2, 6, 32
	ldr	d1, [x28, x3, lsl 3]
	add	x3, x25, x2
	ldr	q3, [x25, x2]
	dup	v1.2d, v1.d[0]
	fmul	v3.2d, v1.2d, v3.2d
	fadd	v3.2d, v3.2d, v5.2d
	str	q3, [x0, 64]
	ldr	q3, [x3, 16]
	fmul	v3.2d, v1.2d, v3.2d
	fadd	v3.2d, v3.2d, v4.2d
	str	q3, [x0, 80]
	ldr	q3, [x3, 32]
	fmul	v3.2d, v1.2d, v3.2d
	fadd	v2.2d, v3.2d, v2.2d
	str	q2, [x0, 96]
	ldr	q2, [x3, 48]
	fmul	v1.2d, v1.2d, v2.2d
	fadd	v0.2d, v1.2d, v0.2d
	str	q0, [x0, 112]
.L319:
	add	x5, x5, x10
	add	x1, x1, 64
	add	x0, x0, 64
	add	x4, x4, x27
	mov	w3, w7
	b	.L317
.L315:
	ldr	x0, [sp, 136]
	add	w21, w21, 4
	ldr	x1, [sp, 168]
	add	x0, x0, 4
	str	x0, [sp, 136]
	sub	w20, w20, #4
	ldr	x0, [sp, 104]
	add	x19, x19, 256
	add	x24, x24, x26
	add	x22, x22, x26
	add	x0, x0, x1
	str	x0, [sp, 104]
	ldr	x0, [sp, 112]
	add	x23, x23, x26
	ldr	x1, [sp, 176]
	add	x0, x0, x1
	str	x0, [sp, 112]
	ldr	w0, [sp, 120]
	add	w0, w0, 4
	str	w0, [sp, 120]
	ldr	x0, [sp, 144]
	add	x0, x0, x26
	str	x0, [sp, 144]
	ldr	w0, [sp, 132]
	add	w0, w0, 4
	str	w0, [sp, 132]
	ldr	w0, [sp, 128]
	cmp	w21, w0
	blt	.L320
	ldr	x23, [sp, 312]
	mov	x26, x10
	mov	x24, x13
.L296:
	ldr	w0, [sp, 188]
	cmp	w0, 0
	ble	.L289
	ldr	x3, [sp, 192]
	mov	x19, x25
	ldr	x21, [sp, 216]
	ldr	x20, [sp, 232]
.L293:
	mov	x1, x19
	mov	x0, x3
	mov	x2, x20
	add	x19, x19, 64
	bl	memcpy
	add	x3, x0, x23
	cmp	x19, x21
	bne	.L293
.L289:
	ldr	w1, [sp, 188]
	ldr	w0, [sp, 224]
	sub	w1, w1, #8
	str	w1, [sp, 188]
	ldr	x1, [sp, 208]
	add	w0, w0, 8
	str	w0, [sp, 224]
	add	x1, x1, 8
	str	x1, [sp, 208]
	ldr	x1, [sp, 192]
	add	x1, x1, 64
	str	x1, [sp, 192]
	ldr	w1, [sp, 228]
	cmp	w1, w0
	bgt	.L288
.L285:
	bl	GOMP_barrier
	mov	x0, x25
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 592
	.cfi_remember_state
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	b	free
.L401:
	.cfi_restore_state
	ldp	x0, x2, [sp, 136]
	add	w6, w21, 2
	ldr	w7, [sp, 120]
	add	x3, x25, 64
	ldr	w4, [sp, 132]
	sub	w5, w21, #1
	movi	v4.2d, 0
	mov	w8, 64
	mov	x1, x25
	mov	w16, 0
	sub	x4, x4, x0
	sub	x6, x6, x0
	sub	x7, x7, x0
	umaddl	x5, w5, w8, x3
	mov	v21.16b, v4.16b
	mov	w17, 0
	mov	v22.16b, v4.16b
	mul	x4, x4, x27
	mov	v23.16b, v4.16b
	mul	x6, x6, x27
	mov	v17.16b, v4.16b
	mul	x7, x7, x27
	mov	v18.16b, v4.16b
	mov	w18, 0
	mov	v19.16b, v4.16b
	mov	w3, 0
	mov	v20.16b, v4.16b
	mov	w8, 0
	mov	v25.16b, v4.16b
	mov	w14, 0
	mov	v26.16b, v4.16b
	mov	w15, 0
	mov	v27.16b, v4.16b
	mov	w9, 0
	mov	v24.16b, v4.16b
	mov	w11, 0
	mov	v5.16b, v4.16b
	mov	w12, 0
	mov	v6.16b, v4.16b
	mov	w30, 0
	mov	v7.16b, v4.16b
	mov	w0, 0
	mov	v16.16b, v4.16b
	b	.L301
	.p2align 2,,3
.L403:
	ldr	d0, [x2, x6, lsl 3]
	mov	w0, 1
	mov	w16, w0
	mov	w17, w0
	mov	w18, w0
	mov	w3, w0
	dup	v0.2d, v0.d[0]
	mov	w8, w0
	mov	w14, w0
	mov	w15, w0
	fmul	v31.2d, v3.2d, v0.2d
	fmul	v30.2d, v2.2d, v0.2d
	fmul	v29.2d, v1.2d, v0.2d
	fmul	v0.2d, v28.2d, v0.2d
	fadd	v23.2d, v23.2d, v31.2d
	fadd	v22.2d, v22.2d, v30.2d
	fadd	v21.2d, v21.2d, v29.2d
	fadd	v4.2d, v4.2d, v0.2d
	cmp	w20, 3
	ble	.L339
	ldr	d0, [x2, x7, lsl 3]
	mov	w9, w0
	mov	w11, w0
	mov	w12, w0
	mov	w30, w0
	dup	v0.2d, v0.d[0]
	fmul	v3.2d, v0.2d, v3.2d
	fmul	v2.2d, v0.2d, v2.2d
	fmul	v1.2d, v0.2d, v1.2d
	fmul	v0.2d, v0.2d, v28.2d
	fadd	v24.2d, v24.2d, v3.2d
	fadd	v27.2d, v27.2d, v2.2d
	fadd	v26.2d, v26.2d, v1.2d
	fadd	v25.2d, v25.2d, v0.2d
.L300:
	add	x1, x1, 64
	add	x2, x2, 8
	cmp	x5, x1
	beq	.L402
.L301:
	ldp	q3, q2, [x1]
	ldp	q1, q28, [x1, 32]
	ld1r	{v0.2d}, [x2]
	fmul	v31.2d, v0.2d, v3.2d
	fmul	v30.2d, v0.2d, v2.2d
	fmul	v29.2d, v0.2d, v1.2d
	fmul	v0.2d, v0.2d, v28.2d
	fadd	v16.2d, v16.2d, v31.2d
	fadd	v7.2d, v7.2d, v30.2d
	fadd	v6.2d, v6.2d, v29.2d
	fadd	v5.2d, v5.2d, v0.2d
	cmp	w20, 1
	beq	.L300
	ldr	d0, [x2, x4, lsl 3]
	dup	v0.2d, v0.d[0]
	fmul	v31.2d, v3.2d, v0.2d
	fmul	v30.2d, v2.2d, v0.2d
	fmul	v29.2d, v1.2d, v0.2d
	fmul	v0.2d, v28.2d, v0.2d
	fadd	v20.2d, v20.2d, v31.2d
	fadd	v19.2d, v19.2d, v30.2d
	fadd	v18.2d, v18.2d, v29.2d
	fadd	v17.2d, v17.2d, v0.2d
	cmp	w20, 2
	bne	.L403
	add	x1, x1, 64
	mov	w3, 1
	add	x2, x2, 8
	mov	w8, w3
	mov	w14, w3
	mov	w15, w3
	cmp	x5, x1
	bne	.L301
.L402:
	stp	q16, q7, [sp, 336]
	stp	q6, q5, [sp, 368]
	cbz	w30, .L302
	str	q24, [sp, 528]
.L302:
	cbz	w12, .L303
	str	q27, [sp, 544]
.L303:
	cbz	w11, .L304
	str	q26, [sp, 560]
.L304:
	cbz	w9, .L305
	str	q25, [sp, 576]
.L305:
	cbz	w15, .L306
	str	q20, [sp, 400]
.L306:
	cbz	w14, .L307
	str	q19, [sp, 416]
.L307:
	cbz	w8, .L308
	str	q18, [sp, 432]
.L308:
	cbz	w3, .L309
	str	q17, [sp, 448]
.L309:
	cbz	w18, .L310
	str	q23, [sp, 464]
.L310:
	cbz	w17, .L311
	str	q22, [sp, 480]
.L311:
	cbz	w16, .L312
	str	q21, [sp, 496]
.L312:
	cbz	w0, .L299
	str	q4, [sp, 512]
	b	.L299
	.p2align 2,,3
.L339:
	mov	w0, 1
	mov	w16, w0
	mov	w17, w0
	mov	w18, w0
	mov	w3, w0
	mov	w8, w0
	mov	w14, w0
	mov	w15, w0
	b	.L300
.L341:
	mov	w4, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L325
.L340:
	mov	w2, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L318
.L399:
	ldr	w0, [sp, 224]
	add	w19, w0, w19
	cmp	w0, w19
	bge	.L289
	ldr	w7, [sp, 128]
	cmp	w7, 0
	ble	.L289
	ldr	x8, [sp, 192]
	ldr	x9, [sp, 208]
.L334:
	ldr	d0, [x8]
	ldr	d1, [x28]
	fdiv	d0, d0, d1
	str	d0, [x8]
	cmp	w7, 1
	beq	.L331
	ldp	x5, x2, [sp, 264]
	add	x3, x8, x23
	mov	x6, x27
	mov	w4, 1
	.p2align 3,,7
.L333:
	movi	d1, #0
	add	x1, x28, x6, lsl 3
	mov	x0, x8
	.p2align 3,,7
.L332:
	ldr	d2, [x0]
	add	x0, x0, x23
	ldr	d0, [x1], 8
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	x2, x1
	bne	.L332
	ldr	d0, [x3]
	add	w4, w4, 1
	ldr	d2, [x5]
	add	x6, x6, x27
	add	x2, x2, x26
	add	x5, x5, x26
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x3]
	add	x3, x3, x23
	cmp	w7, w4
	bne	.L333
.L331:
	add	x9, x9, 1
	add	x8, x8, 8
	cmp	w19, w9
	bgt	.L334
	b	.L289
.L284:
	add	w1, w1, 1
	mov	w0, 0
	b	.L336
	.cfi_endproc
.LFE4287:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4285:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L410
	stp	x29, x30, [sp, -128]!
	.cfi_def_cfa_offset 128
	.cfi_offset 29, -128
	.cfi_offset 30, -120
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -112
	.cfi_offset 20, -104
	mov	w19, w0
	sxtw	x0, w0
	mov	w20, w1
	mov	x1, 1
	stp	x21, x22, [sp, 32]
	movk	x1, 0x100, lsl 16
	madd	x0, x0, x0, x0
	stp	x23, x24, [sp, 48]
	.cfi_offset 21, -96
	.cfi_offset 22, -88
	.cfi_offset 23, -80
	.cfi_offset 24, -72
	mov	w21, w3
	mov	x24, x2
	mov	x22, x4
	mov	w23, w5
	cmp	x0, x1
	bls	.L406
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L407
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L408:
	mov	x0, 16
	bl	getauxval
	add	x5, sp, 64
	ubfx	w4, w0, 22, 1
	adrp	x1, solve_blocked._omp_fn.0
	mov	w3, 0
	add	x0, x1, :lo12:solve_blocked._omp_fn.0
	mov	w2, 0
	add	x1, sp, 80
	stp	x24, x22, [sp, 80]
	str	x5, [sp, 96]
	stp	w19, w20, [sp, 104]
	stp	w21, w23, [sp, 112]
	str	w4, [sp, 120]
	bl	GOMP_parallel
	ldr	x0, [sp, 64]
	bl	free
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 128
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L406:
	.cfi_restore_state
	add	x1, sp, 80
	mov	w3, 0
	mov	w2, 0
	adrp	x0, solve_panel._omp_fn.0
	add	x0, x0, :lo12:solve_panel._omp_fn.0
	stp	x24, x4, [sp, 80]
	stp	w19, w20, [sp, 96]
	stp	w21, w5, [sp, 104]
	bl	GOMP_parallel
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 128
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L410:
	ret
	.p2align 2,,3
.L407:
	.cfi_def_cfa_offset 128
	.cfi_offset 19, -112
	.cfi_offset 20, -104
	.cfi_offset 21, -96
	.cfi_offset 22, -88
	.cfi_offset 23, -80
	.cfi_offset 24, -72
	.cfi_offset 29, -128
	.cfi_offset 30, -120
	str	xzr, [sp, 64]
	b	.L408
	.cfi_endproc
.LFE4285:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (GNU) 10.3.1"
	.section	.note.GNU-stack,"",@progbits
