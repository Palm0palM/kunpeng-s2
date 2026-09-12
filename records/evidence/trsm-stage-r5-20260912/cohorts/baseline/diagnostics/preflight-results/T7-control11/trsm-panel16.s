	.arch armv8-a
	.file	"trsm.c"
	.text
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
	.type	trsm_sve_has_eight_doubles, %function
trsm_sve_has_eight_doubles:
.LFB4364:
	.cfi_startproc
	cntd	x0
	cmp	x0, 8
	cset	w0, eq
	ret
	.cfi_endproc
.LFE4364:
	.size	trsm_sve_has_eight_doubles, .-trsm_sve_has_eight_doubles
	.align	2
	.p2align 4,,11
	.type	update8x8_sve, %function
update8x8_sve:
.LFB4366:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
	cmp	w0, 0
	ble	.L9
	sxtw	x12, w2
	mov	w13, w0
	mov	w0, 6
	add	x16, x12, w2, sxtw 1
	lsl	x18, x12, 3
	add	x15, x12, x12, lsl 2
	smull	x2, w2, w0
	sub	x17, x18, x12
	lsl	x30, x12, 4
	add	x13, x1, w13, sxtw 3
	sbfiz	x14, x4, 3, 32
	lsl	x17, x17, 3
	lsl	x16, x16, 3
	lsl	x15, x15, 3
	lsl	x0, x2, 3
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
	add	x9, x1, x16
	add	x7, x1, x15
	add	x4, x1, x0
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
.LFE4366:
	.size	update8x8_sve, .-update8x8_sve
	.align	2
	.p2align 4,,11
	.type	update16x8_sve, %function
update16x8_sve:
.LFB4367:
	.cfi_startproc
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp
	cmp	w0, 0
	ble	.L15
	sxtw	x7, w2
	mov	w8, w0
	mov	w30, 11
	mov	w0, 14
	mov	w18, 12
	mov	w17, 13
	stp	x19, x20, [sp, 16]
	.cfi_offset 20, -72
	.cfi_offset 19, -80
	mov	w20, 6
	mov	w19, 10
	mov	z1.d, #0
	smull	x20, w2, w20
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -56
	.cfi_offset 21, -64
	smull	x19, w2, w19
	ptrue	p0.b, all
	smull	x30, w2, w30
	add	x22, x7, w2, sxtw 1
	smull	x18, w2, w18
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -24
	.cfi_offset 25, -32
	smull	x17, w2, w17
	mov	z2.d, z1.d
	smull	x2, w2, w0
	lsl	x26, x7, 3
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -8
	.cfi_offset 27, -16
	lsl	x27, x7, 4
	sub	x25, x26, x7
	mov	z3.d, z1.d
	add	x21, x7, x7, lsl 2
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -40
	.cfi_offset 23, -48
	add	x24, x26, x7
	mov	z4.d, z1.d
	sub	x23, x27, x7
	sbfiz	x16, x4, 3, 32
	add	x0, x1, w8, sxtw 3
	lsl	x25, x25, 3
	lsl	x24, x24, 3
	lsl	x23, x23, 3
	lsl	x22, x22, 3
	lsl	x21, x21, 3
	lsl	x20, x20, 3
	lsl	x19, x19, 3
	lsl	x30, x30, 3
	lsl	x18, x18, 3
	lsl	x17, x17, 3
	lsl	x2, x2, 3
	lsl	x28, x7, 5
	lsl	x4, x7, 6
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
	add	x11, x1, x27
	ld1rd	z25.d, p0/z, [x11]
	ld1d	z0.d, p0/z, [x3]
	add	x10, x1, x22
	fmla	z22.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x10]
	add	x9, x1, x28
	fmla	z21.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x9]
	add	x8, x1, x21
	fmla	z20.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x8]
	add	x7, x1, x20
	fmla	z19.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x7]
	add	x12, x1, x26
	ld1rd	z26.d, p0/z, [x1]
	add	x14, x1, x4
	fmla	z18.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x14]
	add	x15, x1, x25
	ld1rd	z27.d, p0/z, [x12]
	fmla	z24.d, p0/m, z0.d, z26.d
	add	x12, x1, x19
	ld1rd	z26.d, p0/z, [x15]
	fmla	z16.d, p0/m, z0.d, z25.d
	ld1rd	z25.d, p0/z, [x12]
	add	x13, x1, x24
	add	x10, x1, x18
	fmla	z17.d, p0/m, z0.d, z26.d
	fmla	z6.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x13]
	ld1rd	z25.d, p0/z, [x10]
	add	x11, x1, x30
	add	x9, x1, x17
	add	x8, x1, x2
	add	x7, x1, x23
	fmla	z7.d, p0/m, z0.d, z26.d
	fmla	z4.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x11]
	ld1rd	z25.d, p0/z, [x8]
	add	x1, x1, 8
	fmla	z5.d, p0/m, z0.d, z26.d
	fmla	z2.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x9]
	ld1rd	z25.d, p0/z, [x7]
	add	x3, x3, x16
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
.LFE4367:
	.size	update16x8_sve, .-update16x8_sve
	.align	2
	.p2align 4,,11
	.type	update4x8_sve, %function
update4x8_sve:
.LFB4365:
	.cfi_startproc
	cmp	w0, 0
	ble	.L21
	sxtw	x10, w2
	add	x8, x1, w0, sxtw 3
	add	x2, x10, w2, sxtw 1
	sbfiz	x9, x4, 3, 32
	lsl	x11, x10, 3
	lsl	x10, x10, 4
	lsl	x7, x2, 3
	mov	z1.d, #0
	ptrue	p0.b, all
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	.p2align 3,,7
.L20:
	add	x4, x1, x11
	add	x2, x1, x10
	add	x0, x1, x7
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
	cmp	x8, x1
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
.LFE4365:
	.size	update4x8_sve, .-update4x8_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4371:
	.cfi_startproc
	sub	sp, sp, #544
	.cfi_def_cfa_offset 544
	mov	x3, x0
	mov	x1, 64
	add	x0, sp, 280
	stp	x29, x30, [sp]
	.cfi_offset 29, -544
	.cfi_offset 30, -536
	mov	x29, sp
	stp	x23, x24, [sp, 48]
	.cfi_offset 23, -496
	.cfi_offset 24, -488
	ldp	w24, w23, [x3, 16]
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -512
	.cfi_offset 22, -504
	ldp	x21, x2, [x3]
	stp	x25, x26, [sp, 64]
	.cfi_offset 25, -480
	.cfi_offset 26, -472
	sbfiz	x25, x24, 6, 32
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -528
	.cfi_offset 20, -520
	ldp	w22, w20, [x3, 24]
	str	x2, [sp, 152]
	mov	x2, x25
	bl	posix_memalign
	ldr	x1, [sp, 280]
	cmp	w0, 0
	csel	x0, xzr, x1, ne
	str	x0, [sp, 160]
	bl	omp_get_num_threads
	mov	w19, w0
	bl	omp_get_thread_num
	mov	w3, w0
	add	w1, w23, 14
	adds	w2, w23, 7
	csel	w0, w1, w2, mi
	asr	w0, w0, 3
	sdiv	w1, w0, w19
	msub	w0, w1, w19, w0
	cmp	w3, w0
	blt	.L25
.L68:
	madd	w0, w1, w3, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L26
	ldr	x26, [sp, 160]
	sxtw	x19, w22
	add	x9, x19, 1
	lsl	w1, w1, 3
	lsl	w7, w0, 3
	stp	w7, w1, [sp, 224]
	add	x1, x25, x26
	lsl	x4, x19, 3
	str	x1, [sp, 136]
	lsl	x1, x9, 2
	str	x1, [sp, 120]
	add	x1, x21, x4
	str	x1, [sp, 248]
	neg	x1, x4
	str	x1, [sp, 232]
	add	x1, x4, 8
	str	x1, [sp, 112]
	sxtw	x1, w7
	str	x1, [sp, 144]
	sub	w0, w23, w7
	ldr	x1, [sp, 152]
	lsl	x2, x9, 5
	sbfiz	x22, x22, 1, 32
	sub	x12, x2, #32
	add	x23, x22, x19
	mov	w14, w0
	add	x8, x1, w7, sxtw 3
	sxtw	x1, w20
	sbfiz	x20, x20, 3, 32
	mov	x3, x8
	mov	x15, x20
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -456
	.cfi_offset 27, -464
	str	x2, [sp, 128]
	str	x1, [sp, 240]
	stp	x9, x4, [sp, 256]
	str	d8, [sp, 96]
	.cfi_offset 72, -448
.L29:
	cmp	w14, 8
	mov	w0, 8
	csel	w7, w14, w0, le
	cbz	x26, .L117
	cmp	w24, 0
	ble	.L30
	sub	w2, w7, #1
	mov	w28, 7
	add	x2, x2, 1
	sub	w28, w28, w7
	add	x28, x28, 1
	cmp	w14, 0
	lsl	x2, x2, 3
	mov	x4, 8
	csel	x0, x2, x4, gt
	lsl	x20, x28, 3
	mov	x28, x26
	stp	x0, x21, [sp, 168]
	sbfiz	x27, x7, 3, 32
	str	w24, [sp, 184]
	mov	x25, x3
	ldr	x24, [sp, 136]
	stp	x22, x12, [sp, 208]
	mov	x22, x0
	mov	x0, x19
	mov	w21, w14
	mov	x19, x28
	mov	x28, x0
	stp	x26, x3, [sp, 192]
	mov	x26, x15
.L61:
	mov	x1, x25
	mov	x2, x22
	mov	x0, x19
	cmp	w21, 0
	ble	.L32
	bl	memcpy
	cmp	w21, 7
	bgt	.L118
.L32:
	add	x0, x19, x27
	mov	x2, x20
	mov	w1, 0
	add	x19, x19, 64
	bl	memset
	add	x25, x25, x26
	cmp	x19, x24
	bne	.L61
	ldp	x22, x12, [sp, 208]
	mov	x15, x26
	ldp	x26, x3, [sp, 192]
	mov	w14, w21
	ldr	x21, [sp, 176]
	mov	x19, x28
	ldr	w24, [sp, 184]
.L59:
	add	x0, x21, 8
	stp	x0, x3, [sp, 176]
	mov	w6, w24
	ldr	x0, [sp, 232]
	mov	x28, x21
	ldr	x13, [sp, 248]
	mov	x18, x21
	movi	v17.4s, 0
	mov	x30, x19
	mov	x2, x26
	add	x4, sp, 288
	mov	w27, 1
	mov	w25, 2
	mov	x7, 0
	str	w14, [sp, 192]
	str	x15, [sp, 200]
.L37:
	stp	q17, q17, [x4]
	stp	q17, q17, [x4, 32]
	stp	q17, q17, [x4, 64]
	stp	q17, q17, [x4, 96]
	stp	q17, q17, [x4, 128]
	stp	q17, q17, [x4, 160]
	stp	q17, q17, [x4, 192]
	stp	q17, q17, [x4, 224]
	cmp	w6, 3
	ble	.L119
	movi	v16.2d, 0
	cbz	w7, .L72
	mov	v18.16b, v16.16b
	mov	x3, x18
	mov	v19.16b, v16.16b
	mov	x1, x26
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
	mov	v8.16b, v16.16b
	.p2align 3,,7
.L57:
	ldp	q4, q3, [x1]
	ldp	q2, q0, [x1, 32]
	add	x1, x1, 64
	ldr	d6, [x3, x19, lsl 3]
	ldr	d5, [x3, x22, lsl 3]
	ldr	d1, [x3, x23, lsl 3]
	fmla	v28.2d, v4.2d, v6.d[0]
	ld1r	{v7.2d}, [x3]
	fmla	v27.2d, v3.2d, v6.d[0]
	add	x3, x3, 8
	fmla	v26.2d, v2.2d, v6.d[0]
	fmla	v8.2d, v4.2d, v7.2d
	fmla	v31.2d, v3.2d, v7.2d
	fmla	v30.2d, v2.2d, v7.2d
	fmla	v29.2d, v0.2d, v7.2d
	fmla	v25.2d, v0.2d, v6.d[0]
	fmla	v24.2d, v4.2d, v5.d[0]
	fmla	v23.2d, v3.2d, v5.d[0]
	fmla	v22.2d, v2.2d, v5.d[0]
	fmla	v21.2d, v0.2d, v5.d[0]
	fmla	v20.2d, v4.2d, v1.d[0]
	fmla	v19.2d, v3.2d, v1.d[0]
	fmla	v18.2d, v2.2d, v1.d[0]
	fmla	v16.2d, v0.2d, v1.d[0]
	cmp	x1, x2
	bne	.L57
.L56:
	stp	q8, q31, [sp, 288]
	stp	q30, q29, [sp, 320]
	stp	q28, q27, [sp, 352]
	stp	q26, q25, [sp, 384]
	stp	q24, q23, [sp, 416]
	stp	q22, q21, [sp, 448]
	stp	q20, q19, [sp, 480]
	stp	q18, q16, [sp, 512]
.L58:
	ldr	d0, [x13, x0]
	ldp	q4, q3, [x2]
	ldp	q2, q1, [x2, 32]
	ldp	q8, q7, [sp, 288]
	ldp	q6, q5, [sp, 320]
	dup	v0.2d, v0.d[0]
	fsub	v4.2d, v4.2d, v8.2d
	fsub	v3.2d, v3.2d, v7.2d
	fsub	v2.2d, v2.2d, v6.2d
	fsub	v1.2d, v1.2d, v5.2d
	fdiv	v4.2d, v4.2d, v0.2d
	fdiv	v3.2d, v3.2d, v0.2d
	fdiv	v2.2d, v2.2d, v0.2d
	fdiv	v0.2d, v1.2d, v0.2d
	stp	q4, q3, [x2]
	stp	q2, q0, [x2, 32]
	cmp	w6, 1
	beq	.L47
	add	x16, x7, 1
	add	x17, x7, 2
	mov	w1, 4
	cmp	w6, 4
	ldr	x20, [sp, 176]
	csel	w10, w6, w1, le
	mov	x3, x4
	add	x16, x26, x16, lsl 6
	add	x17, x26, x17, lsl 6
	mov	x1, x2
	mov	x9, x30
	mov	x8, x13
	mov	w5, 1
	mov	w11, 0
	b	.L48
	.p2align 2,,3
.L51:
	add	x3, x3, 64
	add	x9, x9, x19
	cmp	w5, 2
	beq	.L70
	ldp	q1, q0, [x2]
	mov	w11, 2
	ldr	d5, [x21, x9, lsl 3]
	ldp	q3, q2, [x3, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	ldr	d4, [x20, x9, lsl 3]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldp	q7, q6, [x3, 96]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q1, q0, [x3, 64]
	ldp	q3, q2, [x2, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x3, 64]
	ldp	q1, q0, [x2, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x3, 96]
	ldp	q3, q2, [x2, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x3, 96]
.L49:
	add	x1, x1, 64
	ldr	x14, [sp, 112]
	add	x8, x8, x14
.L48:
	sxtw	x15, w11
	add	w11, w11, 1
	add	x14, x15, x7
	add	x15, x9, x15
	ldp	q1, q2, [x3, 64]
	lsl	x14, x14, 6
	ldr	d4, [x21, x15, lsl 3]
	add	x15, x26, x14
	ldp	q6, q5, [x3, 96]
	ldr	q0, [x26, x14]
	fmul	v0.2d, v0.2d, v4.d[0]
	fadd	v1.2d, v0.2d, v1.2d
	str	q1, [x3, 64]
	ldr	q3, [x15, 16]
	fmul	v3.2d, v3.2d, v4.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x3, 80]
	ldr	q2, [x15, 32]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	str	q2, [x3, 96]
	ldr	q0, [x15, 48]
	fmul	v0.2d, v0.2d, v4.d[0]
	fadd	v0.2d, v0.2d, v5.2d
	str	q0, [x3, 112]
	cmp	w5, w11
	ble	.L50
	add	x11, x9, 1
	ldr	q4, [x16]
	ldr	d6, [x21, x11, lsl 3]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v1.2d
	mov	v1.16b, v4.16b
	str	q4, [x3, 64]
	ldr	q5, [x16, 16]
	fmul	v5.2d, v5.2d, v6.d[0]
	fadd	v5.2d, v5.2d, v3.2d
	str	q5, [x3, 80]
	ldr	q3, [x16, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x3, 96]
	ldr	q2, [x16, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v0.2d, v2.2d, v0.2d
	str	q0, [x3, 112]
	cmp	w5, 3
	bne	.L50
	add	x11, x9, 2
	ldr	q1, [x17]
	ldr	d6, [x21, x11, lsl 3]
	fmul	v1.2d, v1.2d, v6.d[0]
	fadd	v1.2d, v1.2d, v4.2d
	str	q1, [x3, 64]
	ldr	q2, [x17, 16]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x3, 80]
	ldr	q2, [x17, 32]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [x3, 96]
	ldr	q2, [x17, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v0.2d, v2.2d, v0.2d
	str	q0, [x3, 112]
.L50:
	ldr	d0, [x8, 8]
	ldp	q4, q3, [x1, 64]
	add	w5, w5, 1
	dup	v0.2d, v0.d[0]
	ldr	q2, [x1, 96]
	fsub	v4.2d, v4.2d, v1.2d
	ldr	q1, [x1, 112]
	fdiv	v4.2d, v4.2d, v0.2d
	str	q4, [x1, 64]
	ldr	q4, [x3, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v0.2d
	str	q3, [x1, 80]
	ldr	q3, [x3, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x1, 96]
	ldr	q2, [x3, 112]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q0, [x1, 112]
	cmp	w10, w5
	bne	.L51
.L47:
	ldr	x1, [sp, 128]
	add	x7, x7, 4
	sub	w6, w6, #4
	add	x2, x2, 256
	add	x13, x13, x1
	add	w25, w25, 4
	ldr	x1, [sp, 120]
	add	x28, x28, x12
	add	w27, w27, 4
	add	x18, x18, x12
	add	x30, x30, x1
	cmp	w24, w7
	bgt	.L37
	ldr	w14, [sp, 192]
	ldr	x3, [sp, 184]
	ldr	x15, [sp, 200]
	cmp	w14, 0
	ble	.L30
	ldr	x20, [sp, 136]
	mov	x0, x19
	mov	x28, x21
	mov	x4, x3
	ldr	x21, [sp, 168]
	mov	x27, x15
	mov	x19, x26
	mov	x25, x0
	str	x3, [sp, 176]
	str	w14, [sp, 184]
	str	x12, [sp, 192]
.L34:
	mov	x1, x19
	mov	x0, x4
	mov	x2, x21
	add	x19, x19, 64
	bl	memcpy
	add	x4, x0, x27
	cmp	x19, x20
	bne	.L34
	ldr	x3, [sp, 176]
	mov	x21, x28
	ldr	x12, [sp, 192]
	mov	x15, x27
	ldr	w14, [sp, 184]
	mov	x19, x25
.L30:
	ldr	x1, [sp, 144]
	sub	w14, w14, #8
	ldr	w0, [sp, 224]
	add	x3, x3, 64
	add	x1, x1, 8
	str	x1, [sp, 144]
	ldr	w1, [sp, 228]
	add	w0, w0, 8
	str	w0, [sp, 224]
	cmp	w1, w0
	bgt	.L29
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
	ldr	d8, [sp, 96]
	.cfi_restore 72
.L26:
	bl	GOMP_barrier
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldr	x0, [sp, 160]
	add	sp, sp, 544
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	b	free
.L119:
	.cfi_def_cfa_offset 544
	.cfi_offset 19, -528
	.cfi_offset 20, -520
	.cfi_offset 21, -512
	.cfi_offset 22, -504
	.cfi_offset 23, -496
	.cfi_offset 24, -488
	.cfi_offset 25, -480
	.cfi_offset 26, -472
	.cfi_offset 27, -464
	.cfi_offset 28, -456
	.cfi_offset 29, -544
	.cfi_offset 30, -536
	.cfi_offset 72, -448
	cbz	w7, .L58
	movi	v1.2d, 0
	uxtw	x8, w27
	uxtw	x9, w25
	sub	x8, x8, x7
	sub	x9, x9, x7
	mov	x1, x26
	mov	x5, x28
	mov	w3, 0
	mul	x8, x8, x19
	mov	w10, 0
	mul	x9, x9, x19
	mov	w11, 0
	mov	v20.16b, v1.16b
	mov	w14, 0
	mov	v4.16b, v1.16b
	mov	w20, 0
	mov	v5.16b, v1.16b
	mov	w17, 0
	mov	v27.16b, v1.16b
	mov	w16, 0
	mov	v26.16b, v1.16b
	mov	w15, 0
	mov	v25.16b, v1.16b
	mov	v24.16b, v1.16b
	mov	v19.16b, v1.16b
	mov	v18.16b, v1.16b
	mov	v8.16b, v1.16b
	mov	v3.16b, v1.16b
	.p2align 3,,7
.L54:
	ldp	q16, q7, [x1]
	ldp	q6, q22, [x1, 32]
	ld1r	{v0.2d}, [x5]
	fmul	v2.2d, v0.2d, v16.2d
	fmul	v23.2d, v0.2d, v7.2d
	fmul	v28.2d, v0.2d, v6.2d
	fmul	v0.2d, v0.2d, v22.2d
	fadd	v3.2d, v2.2d, v3.2d
	fadd	v23.2d, v23.2d, v8.2d
	fadd	v28.2d, v28.2d, v18.2d
	fadd	v2.2d, v0.2d, v19.2d
	cmp	w6, 1
	ble	.L52
	ldr	d0, [x5, x8, lsl 3]
	mov	w3, 1
	mov	w10, w3
	mov	w11, w3
	mov	w14, w3
	fmul	v18.2d, v16.2d, v0.d[0]
	fmul	v19.2d, v7.2d, v0.d[0]
	fmul	v21.2d, v6.2d, v0.d[0]
	fmul	v0.2d, v22.2d, v0.d[0]
	fadd	v5.2d, v18.2d, v5.2d
	fadd	v4.2d, v19.2d, v4.2d
	fadd	v20.2d, v21.2d, v20.2d
	fadd	v1.2d, v0.2d, v1.2d
	cmp	w6, 3
	bne	.L52
	ldr	d18, [x5, x9, lsl 3]
	mov	w20, w3
	mov	w17, w3
	mov	w16, w3
	mov	w15, w3
	fmul	v16.2d, v16.2d, v18.d[0]
	fmul	v7.2d, v7.2d, v18.d[0]
	fmul	v6.2d, v6.2d, v18.d[0]
	fmul	v0.2d, v22.2d, v18.d[0]
	fadd	v24.2d, v16.2d, v24.2d
	fadd	v25.2d, v7.2d, v25.2d
	fadd	v26.2d, v6.2d, v26.2d
	fadd	v27.2d, v0.2d, v27.2d
.L52:
	add	x1, x1, 64
	add	x5, x5, 8
	mov	v8.16b, v23.16b
	mov	v18.16b, v28.16b
	mov	v19.16b, v2.16b
	cmp	x1, x2
	bne	.L54
	stp	q3, q23, [sp, 288]
	stp	q28, q2, [sp, 320]
	cbz	w3, .L39
	str	q1, [sp, 400]
.L39:
	cbz	w10, .L40
	str	q20, [sp, 384]
.L40:
	cbz	w11, .L41
	str	q4, [sp, 368]
.L41:
	cbz	w14, .L42
	str	q5, [sp, 352]
.L42:
	cbz	w20, .L43
	str	q27, [sp, 464]
.L43:
	cbz	w17, .L44
	str	q26, [sp, 448]
.L44:
	cbz	w16, .L45
	str	q25, [sp, 432]
.L45:
	cbz	w15, .L58
	str	q24, [sp, 416]
	b	.L58
.L72:
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
	mov	v8.16b, v16.16b
	b	.L56
.L117:
	cmp	w14, 0
	ble	.L30
	cmp	w24, 0
	ble	.L30
	ldp	x0, x1, [sp, 256]
	mov	x8, x3
	ldr	x9, [sp, 144]
	lsl	x10, x19, 3
	lsl	x11, x0, 3
	add	x7, x9, w7, uxtw
	ldr	x0, [sp, 112]
.L65:
	ldr	d0, [x8]
	ldr	d1, [x21]
	fdiv	d0, d0, d1
	str	d0, [x8]
	cmp	w24, 1
	beq	.L64
	ldr	x2, [sp, 240]
	add	x6, x21, x11
	ldr	x5, [sp, 152]
	add	x2, x2, x9
	add	x13, x21, x10
	mov	w4, 1
	add	x2, x5, x2, lsl 3
	.p2align 3,,7
.L67:
	movi	d1, #0
	mov	x16, x8
	mov	x5, 0
	.p2align 3,,7
.L66:
	ldr	d2, [x13, x5, lsl 3]
	add	x5, x5, 1
	ldr	d0, [x16]
	add	x16, x16, x15
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w4, w5
	bgt	.L66
	ldr	d0, [x2]
	add	w4, w4, 1
	ldr	d2, [x6]
	add	x13, x13, x1
	add	x6, x6, x0
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x2]
	add	x2, x2, x15
	cmp	w24, w4
	bne	.L67
.L64:
	add	x9, x9, 1
	add	x8, x8, 8
	cmp	x7, x9
	bne	.L65
	b	.L30
.L25:
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 72
	add	w1, w1, 1
	mov	w0, 0
	b	.L68
.L118:
	.cfi_offset 27, -464
	.cfi_offset 28, -456
	.cfi_offset 72, -448
	mov	x20, x26
	mov	x0, x28
	ldp	x26, x3, [sp, 192]
	mov	w14, w21
	ldr	x21, [sp, 176]
	mov	x28, x19
	ldp	x22, x12, [sp, 208]
	mov	x27, x0
	ldr	w24, [sp, 184]
	mov	x19, x3
	b	.L60
	.p2align 2,,3
.L120:
	ldr	x2, [sp, 168]
	mov	x1, x25
	mov	x0, x28
	str	w14, [sp, 176]
	str	x12, [sp, 184]
	bl	memcpy
	ldr	x12, [sp, 184]
	ldr	w14, [sp, 176]
.L60:
	ldr	x0, [sp, 136]
	add	x28, x28, 64
	add	x25, x25, x20
	cmp	x0, x28
	bne	.L120
	mov	x3, x19
	mov	x15, x20
	mov	x19, x27
	b	.L59
.L70:
	mov	w11, 0
	b	.L49
	.cfi_endproc
.LFE4371:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4370:
	.cfi_startproc
	sub	sp, sp, #1024
	.cfi_def_cfa_offset 1024
	stp	x29, x30, [sp]
	.cfi_offset 29, -1024
	.cfi_offset 30, -1016
	mov	x29, sp
	ldr	w2, [x0, 24]
	ldr	w1, [x0, 40]
	str	w2, [sp, 264]
	ldr	w2, [x0, 28]
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	.cfi_offset 19, -1008
	.cfi_offset 20, -1000
	.cfi_offset 21, -992
	.cfi_offset 22, -984
	ldp	x20, x22, [x0]
	str	x0, [sp, 312]
	str	w2, [sp, 332]
	ldp	w2, w0, [x0, 32]
	str	w0, [sp, 256]
	str	w2, [sp, 260]
	str	w1, [sp, 484]
	cbz	w1, .L282
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 484]
.L282:
	ldr	w0, [sp, 264]
	cmp	w0, 0
	ble	.L121
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -968
	.cfi_offset 23, -976
	mov	x19, x20
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -952
	.cfi_offset 25, -960
	mov	x26, x22
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -936
	.cfi_offset 27, -944
	bl	omp_get_num_threads
	mov	w23, w0
	bl	omp_get_thread_num
	mov	w1, w0
	ldr	w10, [sp, 332]
	mov	w25, w0
	ldrsw	x5, [sp, 260]
	mov	w4, 24
	adds	w3, w10, 7
	add	w2, w10, 14
	ldr	w9, [sp, 256]
	csel	w0, w2, w3, mi
	add	x17, x5, 1
	lsl	x14, x5, 1
	asr	w0, w0, 3
	lsl	x8, x5, 3
	lsl	x12, x17, 5
	lsl	x13, x17, 2
	smull	x4, w9, w4
	add	w3, w10, 63
	sdiv	w2, w0, w23
	str	x4, [sp, 560]
	sub	x4, x12, #32
	str	x4, [sp, 512]
	sub	x4, x13, #4
	str	x4, [sp, 616]
	lsl	x4, x17, 11
	str	x4, [sp, 648]
	lsl	x4, x17, 8
	msub	w0, w2, w23, w0
	str	x4, [sp, 656]
	mov	x4, x5
	add	x5, x14, x5
	str	x5, [sp, 496]
	add	x5, x20, x8
	cmp	w1, w0
	str	x5, [sp, 360]
	add	x5, x8, 8
	cinc	w2, w2, lt
	str	x5, [sp, 424]
	lsl	x5, x4, 7
	sxtw	x6, w9
	str	x5, [sp, 600]
	lsl	x5, x4, 4
	asr	w3, w3, 6
	str	x5, [sp, 624]
	lsl	x5, x4, 6
	str	w3, [sp, 520]
	mul	w3, w2, w1
	str	x5, [sp, 608]
	neg	x5, x6, lsl 7
	str	x5, [sp, 664]
	neg	x5, x6, lsl 6
	add	w0, w0, w3
	str	x5, [sp, 672]
	lsl	x5, x6, 2
	sbfiz	x7, x9, 3, 32
	stp	x8, x6, [sp, 160]
	sbfiz	x11, x9, 4, 32
	str	x5, [sp, 576]
	neg	x5, x6, lsl 5
	csel	w6, w3, w0, lt
	mov	x0, x7
	add	x3, x7, 16
	str	x7, [sp, 120]
	add	w7, w2, w6
	add	x2, x0, 32
	add	x0, x0, 48
	lsl	w8, w6, 3
	str	x11, [sp, 336]
	mov	x22, x4
	str	x14, [sp, 368]
	mov	w27, w7
	stp	x3, x2, [sp, 376]
	mov	w21, w8
	str	x0, [sp, 392]
	lsl	w0, w7, 3
	str	x4, [sp, 432]
	str	x13, [sp, 552]
	str	x12, [sp, 592]
	str	x5, [sp, 680]
	str	w0, [sp, 584]
	sub	w0, w10, w8
	str	w0, [sp, 588]
	sxtw	x0, w8
	str	x0, [sp, 632]
	add	x0, x11, 16
	str	x0, [sp, 400]
	add	x0, x11, 32
	str	x0, [sp, 408]
	add	x0, x11, 48
	str	x0, [sp, 416]
	sbfiz	x0, x9, 8, 32
	str	xzr, [sp, 176]
	str	xzr, [sp, 320]
	stp	x20, x20, [sp, 440]
	str	w6, [sp, 544]
	str	x0, [sp, 640]
	mov	x0, 0
	mov	x20, x0
	str	w23, [sp, 692]
	str	x17, [sp, 696]
	b	.L183
.L460:
	add	w0, w1, 256
	str	w0, [sp, 328]
	ldr	w0, [sp, 544]
	cmp	w27, w0
	bgt	.L457
.L125:
	str	w7, [sp, 132]
	bl	GOMP_barrier
	ldr	w0, [sp, 264]
	ldr	w1, [sp, 328]
	ldr	w7, [sp, 132]
	cmp	w0, w1
	ble	.L185
	ldr	w0, [sp, 264]
	ldr	w1, [sp, 328]
	add	w0, w0, 63
	sub	w0, w0, w1
	ldr	w1, [sp, 332]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L185
	ldr	w1, [sp, 520]
	ldr	w2, [sp, 692]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	cmp	w25, w0
	bcc	.L186
.L281:
	madd	w0, w1, w25, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L458
.L185:
	bl	GOMP_barrier
	ldr	x0, [sp, 176]
	ldr	x2, [sp, 640]
	add	x1, x0, 256
	ldr	x0, [sp, 320]
	add	x20, x20, x2
	ldr	x3, [sp, 360]
	add	x0, x0, x2
	str	x0, [sp, 320]
	ldr	x0, [sp, 648]
	str	x1, [sp, 176]
	ldr	x4, [sp, 656]
	add	x3, x3, x0
	str	x3, [sp, 360]
	ldr	x3, [sp, 432]
	ldr	x2, [sp, 448]
	add	x3, x3, x4
	str	x3, [sp, 432]
	ldr	x3, [sp, 440]
	add	x3, x3, x0
	add	x0, x2, x0
	stp	x3, x0, [sp, 440]
	ldr	w0, [sp, 264]
	cmp	w0, w1
	ble	.L459
.L183:
	ldr	x1, [sp, 176]
	str	w1, [sp, 268]
	ldr	w0, [sp, 264]
	mov	w7, w1
	sub	w0, w0, w1
	cmp	w0, 255
	bgt	.L460
	ldr	w0, [sp, 544]
	cmp	w27, w0
	ble	.L283
	ldr	w0, [sp, 264]
	str	w0, [sp, 328]
	str	d8, [sp, 96]
	.cfi_offset 72, -928
.L284:
	ldr	x15, [sp, 632]
	mov	w6, w27
	ldr	x2, [sp, 160]
	add	x24, x15, x20
	ldr	x1, [sp, 360]
	mov	w28, w21
	ldr	w0, [sp, 328]
	mov	w9, w25
	ldr	w23, [sp, 588]
	sub	x18, x1, x2
	sub	w30, w0, w7
	ldr	w17, [sp, 176]
	sub	w16, w30, #1
	mov	x27, x15
	mov	x2, x20
	str	w23, [sp, 132]
	mov	w23, w21
	str	x24, [sp, 136]
	mov	w24, w0
	str	w7, [sp, 144]
.L129:
	ldr	x0, [sp, 312]
	mov	w3, 8
	ldr	w1, [sp, 132]
	ldr	x0, [x0, 16]
	cmp	w1, 8
	csel	w3, w1, w3, le
	ldr	x25, [x0]
	cbz	x25, .L461
	cmp	w28, 0
	add	w1, w28, 7
	csel	w1, w1, w28, lt
	asr	w1, w1, 3
	sbfiz	x21, x1, 14, 32
	sxtw	x1, w1
	add	x21, x25, x21
	cmp	w30, 0
	ble	.L130
	ldr	w8, [sp, 144]
	mov	w0, 7
	sub	w0, w0, w3
	sbfiz	x4, x3, 3, 32
	mov	x7, x21
	add	x0, x0, 1
	ldr	w20, [sp, 132]
	mov	x5, x22
	mov	w3, w23
	mov	x22, x4
	mov	x23, x19
	mov	x4, x25
	mov	x10, x16
	mov	w25, w9
	mov	x11, x2
	mov	x9, x21
	mov	w12, w17
	mov	w21, w8
	mov	x13, x1
	mov	w8, w30
	mov	x19, x7
	lsl	x0, x0, 3
	str	x0, [sp, 152]
.L179:
	cmp	w20, 0
	ble	.L150
.L149:
	ldr	w0, [sp, 256]
	smaddl	x1, w21, w0, x27
	lsl	x0, x1, 3
	ldr	d0, [x26, x1, lsl 3]
	add	x0, x26, x0
	str	d0, [x19]
	cmp	w20, 1
	ble	.L150
	ldr	d0, [x0, 8]
	str	d0, [x19, 8]
	cmp	w20, 2
	ble	.L150
	ldr	d0, [x0, 16]
	str	d0, [x19, 16]
	cmp	w20, 3
	ble	.L150
	ldr	d0, [x0, 24]
	str	d0, [x19, 24]
	cmp	w20, 4
	ble	.L150
	ldr	d0, [x0, 32]
	str	d0, [x19, 32]
	cmp	w20, 5
	ble	.L150
	ldr	d0, [x0, 40]
	str	d0, [x19, 40]
	cmp	w20, 6
	ble	.L150
	ldr	d0, [x0, 48]
	str	d0, [x19, 48]
	cmp	w20, 7
	ble	.L150
	ldr	d0, [x0, 56]
	add	w21, w21, 1
	add	x19, x19, 64
	str	d0, [x19, -8]
	cmp	w24, w21
	bne	.L149
.L456:
	mov	x19, x23
	lsl	x0, x13, 8
	mov	w23, w3
	mov	x22, x5
	neg	x3, x5
	mov	x21, x7
	mov	x1, x7
	str	x0, [sp, 152]
	ldp	x7, x5, [sp, 432]
	mov	x16, x10
	ldr	w0, [sp, 144]
	mov	x20, x9
	ldr	x10, [sp, 360]
	mov	w9, w25
	movi	v17.4s, 0
	mov	x25, x4
	add	w15, w0, 2
	mov	w30, w8
	mov	x14, x18
	mov	w4, w8
	add	x0, sp, 768
	str	x3, [sp, 192]
	add	x3, x19, 8
	str	x26, [sp, 216]
	mov	x26, x18
	str	x3, [sp, 200]
	mov	x3, 0
	str	w28, [sp, 208]
	str	w9, [sp, 224]
	str	w6, [sp, 232]
	str	w23, [sp, 240]
	str	x16, [sp, 248]
	str	x11, [sp, 272]
	str	w12, [sp, 280]
.L157:
	stp	q17, q17, [x0]
	stp	q17, q17, [x0, 32]
	stp	q17, q17, [x0, 64]
	stp	q17, q17, [x0, 96]
	stp	q17, q17, [x0, 128]
	stp	q17, q17, [x0, 160]
	stp	q17, q17, [x0, 192]
	stp	q17, q17, [x0, 224]
	cmp	w4, 3
	ble	.L462
	movi	v0.2d, 0
	cbz	w3, .L290
	ldr	x2, [sp, 368]
	add	x9, x21, x3, lsl 6
	ldr	x11, [sp, 496]
	mov	x8, x14
	mov	v18.16b, v0.16b
	mov	x6, x21
	mov	v19.16b, v0.16b
	mov	v20.16b, v0.16b
	mov	v21.16b, v0.16b
	mov	v22.16b, v0.16b
	mov	v23.16b, v0.16b
	mov	v24.16b, v0.16b
	mov	v25.16b, v0.16b
	mov	v26.16b, v0.16b
	mov	v27.16b, v0.16b
	mov	v28.16b, v0.16b
	mov	v29.16b, v0.16b
	mov	v30.16b, v0.16b
	mov	v31.16b, v0.16b
	mov	v8.16b, v0.16b
.L177:
	ldp	q5, q4, [x6]
	ldp	q3, q1, [x6, 32]
	add	x6, x6, 64
	ldr	d7, [x8, x22, lsl 3]
	ldr	d6, [x8, x2, lsl 3]
	ldr	d2, [x8, x11, lsl 3]
	fmla	v28.2d, v5.2d, v7.d[0]
	ld1r	{v16.2d}, [x8]
	fmla	v27.2d, v4.2d, v7.d[0]
	add	x8, x8, 8
	fmla	v26.2d, v3.2d, v7.d[0]
	fmla	v8.2d, v5.2d, v16.2d
	fmla	v31.2d, v4.2d, v16.2d
	fmla	v30.2d, v3.2d, v16.2d
	fmla	v29.2d, v1.2d, v16.2d
	fmla	v25.2d, v1.2d, v7.d[0]
	fmla	v24.2d, v5.2d, v6.d[0]
	fmla	v23.2d, v4.2d, v6.d[0]
	fmla	v22.2d, v3.2d, v6.d[0]
	fmla	v21.2d, v1.2d, v6.d[0]
	fmla	v20.2d, v5.2d, v2.d[0]
	fmla	v19.2d, v4.2d, v2.d[0]
	fmla	v18.2d, v3.2d, v2.d[0]
	fmla	v0.2d, v1.2d, v2.d[0]
	cmp	x6, x9
	bne	.L177
.L176:
	stp	q8, q31, [sp, 768]
	stp	q30, q29, [sp, 800]
	stp	q28, q27, [sp, 832]
	stp	q26, q25, [sp, 864]
	stp	q24, q23, [sp, 896]
	stp	q22, q21, [sp, 928]
	stp	q20, q19, [sp, 960]
	stp	q18, q0, [sp, 992]
.L178:
	ldr	x2, [sp, 192]
	ldp	q4, q3, [x1]
	ldp	q2, q1, [x1, 32]
	ldp	q8, q7, [sp, 768]
	ldp	q6, q5, [sp, 800]
	fsub	v4.2d, v4.2d, v8.2d
	ldr	d0, [x10, x2, lsl 3]
	fsub	v3.2d, v3.2d, v7.2d
	fsub	v2.2d, v2.2d, v6.2d
	dup	v0.2d, v0.d[0]
	fsub	v1.2d, v1.2d, v5.2d
	fdiv	v4.2d, v4.2d, v0.2d
	fdiv	v3.2d, v3.2d, v0.2d
	fdiv	v2.2d, v2.2d, v0.2d
	fdiv	v0.2d, v1.2d, v0.2d
	stp	q4, q3, [x1]
	stp	q2, q0, [x1, 32]
	cmp	w4, 1
	beq	.L167
	ldr	x2, [sp, 152]
	cmp	w4, 4
	mov	x6, x0
	mov	x18, x10
	add	x28, x3, x2
	mov	x11, x7
	add	x8, x28, 2
	add	x13, x28, 1
	mov	w2, 4
	mov	w9, 1
	add	x23, x25, x8, lsl 6
	csel	w2, w4, w2, le
	add	x13, x25, x13, lsl 6
	mov	x8, x1
	mov	w12, 0
	b	.L168
.L171:
	add	x6, x6, 64
	add	x11, x11, x22
	cmp	w9, 2
	beq	.L288
	ldp	q1, q0, [x1]
	mov	w12, 2
	ldr	d5, [x19, x11, lsl 3]
	ldp	q3, q2, [x6, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldr	x16, [sp, 200]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	ldr	d4, [x16, x11, lsl 3]
	ldp	q7, q6, [x6, 96]
	stp	q1, q0, [x6, 64]
	ldp	q3, q2, [x1, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x6, 64]
	ldp	q1, q0, [x1, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x6, 96]
	ldp	q3, q2, [x1, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x6, 96]
.L169:
	add	x8, x8, 64
	ldr	x16, [sp, 424]
	add	x18, x18, x16
.L168:
	sxtw	x16, w12
	add	w12, w12, 1
	add	x17, x28, x16
	add	x16, x16, x11
	ldp	q1, q6, [x6, 64]
	lsl	x17, x17, 6
	ldr	d0, [x19, x16, lsl 3]
	add	x16, x25, x17
	ldp	q5, q4, [x6, 96]
	ldr	q2, [x25, x17]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x6, 64]
	ldr	q3, [x16, 16]
	fmul	v3.2d, v3.2d, v0.d[0]
	fadd	v3.2d, v3.2d, v6.2d
	str	q3, [x6, 80]
	ldr	q2, [x16, 32]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x6, 96]
	ldr	q5, [x16, 48]
	fmul	v5.2d, v5.2d, v0.d[0]
	fadd	v5.2d, v5.2d, v4.2d
	str	q5, [x6, 112]
	cmp	w12, w9
	bge	.L170
	add	x12, x11, 1
	ldr	q0, [x13]
	ldr	d6, [x19, x12, lsl 3]
	fmul	v0.2d, v0.2d, v6.d[0]
	fadd	v0.2d, v0.2d, v1.2d
	mov	v1.16b, v0.16b
	str	q0, [x6, 64]
	ldr	q4, [x13, 16]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v3.2d
	str	q4, [x6, 80]
	ldr	q3, [x13, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x6, 96]
	ldr	q2, [x13, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x6, 112]
	cmp	w9, 3
	bne	.L170
	add	x12, x11, 2
	ldr	q1, [x23]
	ldr	d5, [x19, x12, lsl 3]
	fmul	v1.2d, v1.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v0.2d
	str	q1, [x6, 64]
	ldr	q0, [x23, 16]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v4.2d
	str	q0, [x6, 80]
	ldr	q0, [x23, 32]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v3.2d
	str	q0, [x6, 96]
	ldr	q0, [x23, 48]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x6, 112]
.L170:
	ldr	d0, [x18, 8]
	ldp	q4, q3, [x8, 64]
	add	w9, w9, 1
	dup	v0.2d, v0.d[0]
	ldr	q2, [x8, 96]
	fsub	v4.2d, v4.2d, v1.2d
	ldr	q1, [x8, 112]
	fdiv	v4.2d, v4.2d, v0.2d
	str	q4, [x8, 64]
	ldr	q4, [x6, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v0.2d
	str	q3, [x8, 80]
	ldr	q3, [x6, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x8, 96]
	ldr	q2, [x6, 112]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q0, [x8, 112]
	cmp	w2, w9
	bne	.L171
.L167:
	ldr	x2, [sp, 592]
	add	x3, x3, 4
	sub	w4, w4, #4
	add	x1, x1, 256
	add	x10, x10, x2
	add	w15, w15, 4
	ldr	x2, [sp, 552]
	add	x7, x7, x2
	ldr	x2, [sp, 512]
	add	x5, x5, x2
	add	x14, x14, x2
	cmp	w30, w3
	bgt	.L157
	ldr	w3, [sp, 132]
	mov	x18, x26
	ldr	x26, [sp, 216]
	ldr	x16, [sp, 248]
	ldr	x2, [sp, 272]
	ldr	w28, [sp, 208]
	ldr	w9, [sp, 224]
	ldr	w6, [sp, 232]
	ldr	w23, [sp, 240]
	ldr	w17, [sp, 280]
	cmp	w3, 0
	ble	.L130
	ldr	x0, [sp, 136]
	add	x1, x16, 1
	add	x1, x21, x1, lsl 6
	add	x0, x26, x0, lsl 3
.L154:
	ldr	d0, [x20]
	str	d0, [x0]
	cmp	w3, 1
	ble	.L152
	ldr	d0, [x20, 8]
	str	d0, [x0, 8]
	cmp	w3, 2
	ble	.L152
	ldr	d0, [x20, 16]
	str	d0, [x0, 16]
	cmp	w3, 3
	ble	.L152
	ldr	d0, [x20, 24]
	str	d0, [x0, 24]
	cmp	w3, 4
	ble	.L152
	ldr	d0, [x20, 32]
	str	d0, [x0, 32]
	cmp	w3, 5
	ble	.L152
	ldr	d0, [x20, 40]
	str	d0, [x0, 40]
	cmp	w3, 6
	ble	.L152
	ldr	d0, [x20, 48]
	str	d0, [x0, 48]
	cmp	w3, 7
	ble	.L152
	ldr	d0, [x20, 56]
	str	d0, [x0, 56]
.L152:
	ldr	x4, [sp, 120]
	add	x20, x20, 64
	add	x0, x0, x4
	cmp	x20, x1
	bne	.L154
.L130:
	ldr	w0, [sp, 132]
	add	w28, w28, 8
	add	x27, x27, 8
	sub	w0, w0, #8
	str	w0, [sp, 132]
	ldr	x0, [sp, 136]
	add	x0, x0, 8
	str	x0, [sp, 136]
	ldr	w0, [sp, 584]
	cmp	w0, w28
	bgt	.L129
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	w25, w9
	ldr	w7, [sp, 144]
	mov	w27, w6
	mov	w21, w23
	mov	x20, x2
	b	.L125
.L150:
	.cfi_restore_state
	ldr	x2, [sp, 152]
	add	x0, x19, x22
	add	w21, w21, 1
	mov	w1, 0
	str	w6, [sp, 184]
	add	x19, x19, 64
	str	w3, [sp, 192]
	stp	x4, x5, [sp, 200]
	stp	x7, x18, [sp, 216]
	str	w8, [sp, 232]
	stp	x9, x10, [sp, 240]
	str	x11, [sp, 272]
	str	w12, [sp, 280]
	str	x13, [sp, 288]
	bl	memset
	ldp	x4, x5, [sp, 200]
	cmp	w24, w21
	ldp	x7, x18, [sp, 216]
	ldp	x9, x10, [sp, 240]
	ldr	x11, [sp, 272]
	ldr	x13, [sp, 288]
	ldr	w6, [sp, 184]
	ldr	w3, [sp, 192]
	ldr	w8, [sp, 232]
	ldr	w12, [sp, 280]
	bne	.L179
	b	.L456
.L462:
	cbz	w3, .L178
	ldr	x12, [sp, 176]
	sub	w8, w15, #1
	ldr	w2, [sp, 260]
	lsl	x6, x3, 3
	movi	v0.2d, 0
	mov	x9, x21
	mov	w13, 0
	mov	w28, 0
	mov	w17, 0
	mov	w16, 0
	smaddl	x11, w2, w15, x12
	str	x6, [sp, 184]
	smaddl	x8, w2, w8, x12
	mov	w6, 0
	mov	v1.16b, v0.16b
	mov	w12, 0
	mov	v16.16b, v0.16b
	add	x18, x19, x11, lsl 3
	mov	v2.16b, v0.16b
	add	x23, x19, x8, lsl 3
	mov	v25.16b, v0.16b
	mov	w11, 0
	mov	v24.16b, v0.16b
	mov	w2, 0
	mov	v23.16b, v0.16b
	mov	x8, 0
	mov	v22.16b, v0.16b
	str	x0, [sp, 288]
	mov	v21.16b, v0.16b
	mov	v19.16b, v0.16b
	mov	v8.16b, v0.16b
	mov	v20.16b, v0.16b
.L174:
	ldp	q7, q6, [x9]
	ldp	q5, q4, [x9, 32]
	ldr	d3, [x5, x8]
	fmul	v18.2d, v7.2d, v3.d[0]
	fmul	v26.2d, v6.2d, v3.d[0]
	fmul	v27.2d, v5.2d, v3.d[0]
	fmul	v3.2d, v4.2d, v3.d[0]
	fadd	v20.2d, v18.2d, v20.2d
	fadd	v26.2d, v26.2d, v8.2d
	fadd	v27.2d, v27.2d, v19.2d
	fadd	v18.2d, v3.2d, v21.2d
	cmp	w4, 1
	ble	.L172
	ldr	d3, [x23, x8]
	mov	w6, 1
	mov	w11, w6
	mov	w13, w6
	mov	w12, w6
	fmul	v8.2d, v7.2d, v3.d[0]
	fmul	v19.2d, v6.2d, v3.d[0]
	fmul	v21.2d, v5.2d, v3.d[0]
	fmul	v3.2d, v4.2d, v3.d[0]
	fadd	v2.2d, v8.2d, v2.2d
	fadd	v16.2d, v19.2d, v16.2d
	fadd	v1.2d, v21.2d, v1.2d
	fadd	v0.2d, v3.2d, v0.2d
	cmp	w4, 3
	bne	.L172
	ldr	d3, [x18, x8]
	mov	w28, w6
	mov	w17, w6
	mov	w16, w6
	mov	w2, w6
	fmul	v7.2d, v7.2d, v3.d[0]
	fmul	v6.2d, v6.2d, v3.d[0]
	fmul	v5.2d, v5.2d, v3.d[0]
	fmul	v4.2d, v4.2d, v3.d[0]
	fadd	v22.2d, v7.2d, v22.2d
	fadd	v23.2d, v6.2d, v23.2d
	fadd	v24.2d, v5.2d, v24.2d
	fadd	v25.2d, v4.2d, v25.2d
.L172:
	ldr	x0, [sp, 184]
	add	x8, x8, 8
	mov	v8.16b, v26.16b
	add	x9, x9, 64
	mov	v19.16b, v27.16b
	mov	v21.16b, v18.16b
	cmp	x8, x0
	bne	.L174
	stp	q20, q26, [sp, 768]
	stp	q27, q18, [sp, 800]
	ldr	x0, [sp, 288]
	cbz	w6, .L159
	str	q0, [sp, 880]
.L159:
	cbz	w11, .L160
	str	q1, [sp, 864]
.L160:
	cbz	w13, .L161
	str	q16, [sp, 848]
.L161:
	cbz	w12, .L162
	str	q2, [sp, 832]
.L162:
	cbz	w28, .L163
	str	q25, [sp, 944]
.L163:
	cbz	w17, .L164
	str	q24, [sp, 928]
.L164:
	cbz	w16, .L165
	str	q23, [sp, 912]
.L165:
	cbz	w2, .L178
	str	q22, [sp, 896]
	b	.L178
.L461:
	cmp	w24, w17
	ble	.L130
	ldr	w4, [sp, 268]
	sub	w10, w24, #1
	ldr	x11, [sp, 136]
	cmp	w10, w4
	ldr	w5, [sp, 132]
	csel	w10, w10, w4, le
	ldr	x12, [sp, 448]
	cmp	w5, 0
	csinc	w3, w3, wzr, gt
	add	x21, x26, x11, lsl 3
	and	w20, w3, -2
	and	w13, w3, 1
	lsr	w8, w3, 1
	mov	x0, x21
.L133:
	ldr	d1, [x12]
	cmp	w5, 0
	ble	.L147
	cmp	w5, 1
	beq	.L287
	ldr	q2, [x0]
	dup	v0.2d, v1.d[0]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0]
	cmp	w8, 1
	bls	.L146
	ldr	q2, [x0, 16]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 16]
	cmp	w8, 2
	beq	.L146
	ldr	q2, [x0, 32]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 32]
	cmp	w8, 3
	beq	.L146
	ldr	q2, [x0, 48]
	fdiv	v0.2d, v2.2d, v0.2d
	str	q0, [x0, 48]
.L146:
	mov	w1, w20
	cbz	w13, .L147
.L145:
	add	x1, x11, w1, sxtw
	ldr	d0, [x26, x1, lsl 3]
	fdiv	d0, d0, d1
	str	d0, [x26, x1, lsl 3]
.L147:
	ldr	x1, [sp, 424]
	add	w4, w4, 1
	add	x12, x12, x1
	ldr	x1, [sp, 168]
	add	x11, x11, x1
	ldr	x1, [sp, 120]
	add	x0, x0, x1
	cmp	w4, w10
	ble	.L133
	cmp	w4, w24
	bge	.L130
	ldr	w0, [sp, 256]
	sbfiz	x10, x4, 3, 32
	ldr	x1, [sp, 696]
	and	w25, w3, 1
	movi	v2.4s, 0
	ldr	w14, [sp, 132]
	smaddl	x12, w0, w4, x27
	add	x0, sp, 768
	madd	x15, x1, x10, x19
	madd	x10, x22, x10, x19
	add	x3, x26, x12, lsl 3
.L143:
	stp	q2, q2, [x0]
	stp	q2, q2, [x0, 32]
	cmp	w14, 0
	ble	.L134
	ldr	x11, [sp, 136]
	mov	x5, x21
	ldr	x7, [sp, 176]
.L137:
	ldr	d0, [x10, x7, lsl 3]
	cmp	w14, 1
	beq	.L285
	ldr	q3, [x5]
	ldr	q1, [sp, 768]
	fmul	v3.2d, v3.2d, v0.d[0]
	dup	v4.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 768]
	cmp	w8, 1
	bls	.L136
	ldr	q3, [x5, 16]
	ldr	q1, [sp, 784]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 784]
	cmp	w8, 2
	beq	.L136
	ldr	q3, [x5, 32]
	ldr	q1, [sp, 800]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 800]
	cmp	w8, 3
	beq	.L136
	ldr	q3, [x5, 48]
	ldr	q1, [sp, 816]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 816]
.L136:
	sxtw	x1, w20
	cbz	w25, .L139
.L135:
	add	x13, x1, x11
	ldr	d1, [x0, x1, lsl 3]
	ldr	d3, [x26, x13, lsl 3]
	fmul	d0, d0, d3
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L139:
	ldr	x1, [sp, 168]
	add	x7, x7, 1
	add	x11, x11, x1
	ldr	x1, [sp, 120]
	add	x5, x5, x1
	cmp	w4, w7
	bgt	.L137
	ldr	d3, [x15]
	cmp	w14, 1
	beq	.L286
	ldr	q0, [x3]
	ldr	q4, [sp, 768]
	dup	v1.2d, v3.d[0]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3]
	cmp	w8, 1
	bls	.L141
	ldr	q0, [x3, 16]
	ldr	q4, [sp, 784]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 16]
	cmp	w8, 2
	beq	.L141
	ldr	q0, [x3, 32]
	ldr	q4, [sp, 800]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 32]
	cmp	w8, 3
	beq	.L141
	ldr	q0, [x3, 48]
	ldr	q4, [sp, 816]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 48]
.L141:
	sxtw	x1, w20
	cbz	w25, .L134
.L140:
	add	x5, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x26, x5, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d3
	str	d0, [x26, x5, lsl 3]
.L134:
	ldr	x1, [sp, 424]
	add	w4, w4, 1
	add	x15, x15, x1
	ldr	x1, [sp, 168]
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	add	x3, x3, x1
	ldr	x1, [sp, 160]
	add	x10, x10, x1
	cmp	w4, w24
	bne	.L143
	b	.L130
.L286:
	mov	x1, 0
	b	.L140
.L285:
	mov	x1, 0
	b	.L135
.L287:
	mov	w1, 0
	b	.L145
.L290:
	mov	v18.16b, v0.16b
	mov	v19.16b, v0.16b
	mov	v20.16b, v0.16b
	mov	v21.16b, v0.16b
	mov	v22.16b, v0.16b
	mov	v23.16b, v0.16b
	mov	v24.16b, v0.16b
	mov	v25.16b, v0.16b
	mov	v26.16b, v0.16b
	mov	v27.16b, v0.16b
	mov	v28.16b, v0.16b
	mov	v29.16b, v0.16b
	mov	v30.16b, v0.16b
	mov	v31.16b, v0.16b
	mov	v8.16b, v0.16b
	b	.L176
.L458:
	.cfi_restore 72
	ldr	w3, [sp, 328]
	sub	w1, w1, #1
	ldr	w4, [sp, 520]
	add	w18, w7, 1
	sub	w10, w3, w7
	str	w1, [sp, 688]
	sub	w1, w10, #1
	str	x1, [sp, 568]
	ldr	x1, [sp, 176]
	str	w1, [sp, 248]
	udiv	w2, w0, w4
	mov	w15, 0
	mov	w23, w18
	mov	x28, x19
	neg	x5, x1, lsl 3
	sub	w1, w3, #1
	str	w1, [sp, 132]
	mov	x18, x22
	msub	w0, w2, w4, w0
	ldr	w1, [sp, 264]
	str	x5, [sp, 144]
	add	w5, w3, w2, lsl 6
	sub	w1, w1, w5
	str	w1, [sp, 524]
	lsl	w4, w0, 6
	ldr	w1, [sp, 484]
	str	w15, [sp, 460]
	mov	w15, w5
	str	w25, [sp, 704]
	mov	x25, x26
	str	w27, [sp, 708]
	mov	w27, w4
	and	w1, w1, 1
	str	w1, [sp, 272]
	str	w10, [sp, 456]
	str	x20, [sp, 712]
	str	w21, [sp, 720]
	str	d8, [sp, 96]
	.cfi_offset 72, -928
.L187:
	ldr	w0, [sp, 524]
	add	w1, w15, 64
	ldr	w2, [sp, 332]
	ldr	w3, [sp, 264]
	cmp	w0, 63
	sub	w0, w2, w27
	csel	w4, w1, w3, gt
	cmp	w0, 63
	bgt	.L189
	ldr	w0, [sp, 272]
	mov	w26, w15
	str	w2, [sp, 136]
	cbnz	w0, .L278
.L190:
	cmp	w4, w26
	ble	.L246
	ldr	w0, [sp, 136]
	cmp	w27, w0
	bge	.L246
.L279:
	ldr	w1, [sp, 256]
	sxtw	x13, w27
	ldr	w0, [sp, 260]
	mov	w12, w4
	ldr	w19, [sp, 328]
	mov	w4, w27
	mov	x22, x18
	mov	x27, x28
	smull	x2, w1, w26
	mov	x18, x25
	ldr	x1, [sp, 568]
	smull	x0, w0, w26
	str	x0, [sp, 344]
	add	x14, x1, 1
	str	w15, [sp, 724]
	ldr	x1, [sp, 176]
	str	w23, [sp, 480]
	add	x1, x0, x1
	ldr	x0, [sp, 320]
	add	x1, x28, x1, lsl 3
	sub	x3, x0, x2
	add	x0, x13, x2
	add	x24, x25, x0, lsl 3
	lsl	x3, x3, 3
	mov	x15, x24
	str	x3, [sp, 352]
.L254:
	sub	w0, w12, w26
	mov	w5, 4
	cmp	w0, 4
	add	x23, x1, x14, lsl 3
	ldr	x3, [sp, 560]
	csel	w5, w0, w5, le
	cmp	w0, 3
	str	w26, [sp, 740]
	cset	w0, gt
	str	w0, [sp, 232]
	ldr	x0, [sp, 144]
	add	x3, x15, x3
	ldr	x10, [sp, 312]
	mov	x25, x23
	ldr	x26, [sp, 496]
	mov	w21, w4
	mov	x23, x22
	mov	x9, x13
	mov	x20, x3
	add	x0, x1, x0
	str	x2, [sp, 464]
	str	x0, [sp, 488]
	str	w5, [sp, 504]
	str	w4, [sp, 728]
	str	w12, [sp, 736]
	str	x13, [sp, 744]
	str	x3, [sp, 752]
	str	x14, [sp, 760]
.L248:
	ldr	x0, [x10, 16]
	ldr	w2, [sp, 136]
	ldr	x3, [x0]
	sub	w8, w2, w21
	cbz	x3, .L463
	asr	w0, w21, 3
	mov	x6, 8
	mov	w4, w6
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 232]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	ble	.L464
.L252:
	ldr	w0, [sp, 272]
	cbnz	w0, .L274
	movi	v16.2d, 0
	ldr	w0, [sp, 456]
	cmp	w0, 0
	ble	.L306
	ldr	x28, [sp, 368]
	lsl	x6, x6, 3
	mov	v17.16b, v16.16b
	mov	x0, x1
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
	.p2align 3,,7
.L276:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, x6
	ldr	d6, [x0, x23, lsl 3]
	ldr	d5, [x0, x28, lsl 3]
	ldr	d1, [x0, x26, lsl 3]
	fmla	v27.2d, v4.2d, v6.d[0]
	ld1r	{v7.2d}, [x0]
	fmla	v26.2d, v3.2d, v6.d[0]
	add	x0, x0, 8
	fmla	v25.2d, v2.2d, v6.d[0]
	fmla	v31.2d, v4.2d, v7.2d
	fmla	v30.2d, v3.2d, v7.2d
	fmla	v29.2d, v2.2d, v7.2d
	fmla	v28.2d, v0.2d, v7.2d
	fmla	v24.2d, v0.2d, v6.d[0]
	fmla	v23.2d, v4.2d, v5.d[0]
	fmla	v22.2d, v3.2d, v5.d[0]
	fmla	v21.2d, v2.2d, v5.d[0]
	fmla	v20.2d, v0.2d, v5.d[0]
	fmla	v19.2d, v4.2d, v1.d[0]
	fmla	v18.2d, v3.2d, v1.d[0]
	fmla	v17.2d, v2.2d, v1.d[0]
	fmla	v16.2d, v0.2d, v1.d[0]
	cmp	x0, x25
	bne	.L276
.L275:
	ldp	q3, q2, [x15]
	ldp	q1, q0, [x15, 32]
	ldr	x0, [sp, 120]
	fsub	v3.2d, v3.2d, v31.2d
	fsub	v2.2d, v2.2d, v30.2d
	fsub	v1.2d, v1.2d, v29.2d
	fsub	v0.2d, v0.2d, v28.2d
	stp	q3, q2, [x15]
	stp	q1, q0, [x15, 32]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v27.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 376]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v26.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 384]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v25.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 392]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v24.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 336]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v23.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 400]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v22.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 408]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v21.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 416]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v20.2d
	str	q0, [x15, x0]
	ldp	q3, q2, [x20]
	ldp	q1, q0, [x20, 32]
	fsub	v3.2d, v3.2d, v19.2d
	fsub	v2.2d, v2.2d, v18.2d
	fsub	v1.2d, v1.2d, v17.2d
	fsub	v0.2d, v0.2d, v16.2d
	stp	q3, q2, [x20]
	stp	q1, q0, [x20, 32]
.L258:
	ldr	w0, [sp, 136]
	add	w21, w21, 8
	add	x9, x9, 8
	add	x15, x15, 64
	add	x20, x20, 64
	cmp	w21, w0
	blt	.L248
	ldr	x0, [sp, 512]
	mov	x22, x23
	ldr	x5, [sp, 680]
	add	x1, x1, x0
	ldr	x0, [sp, 352]
	ldr	x3, [sp, 752]
	add	x0, x0, x5
	str	x0, [sp, 352]
	ldr	x0, [sp, 120]
	ldr	x2, [sp, 464]
	add	x15, x0, x3
	ldr	x0, [sp, 344]
	ldr	x3, [sp, 616]
	ldr	w26, [sp, 740]
	add	x0, x0, x3
	str	x0, [sp, 344]
	ldr	x0, [sp, 576]
	add	w26, w26, 4
	ldr	w12, [sp, 736]
	ldr	x13, [sp, 744]
	add	x2, x2, x0
	ldr	x14, [sp, 760]
	ldr	w4, [sp, 728]
	cmp	w12, w26
	bgt	.L254
	mov	x25, x18
	ldr	w15, [sp, 724]
	mov	x18, x23
	ldr	w23, [sp, 480]
	mov	x28, x27
	mov	w27, w4
.L246:
	ldr	w0, [sp, 460]
	ldr	w1, [sp, 688]
	cmp	w0, w1
	beq	.L452
.L471:
	ldr	w0, [sp, 332]
	add	w27, w27, 64
	cmp	w0, w27
	ble	.L465
.L249:
	ldr	w0, [sp, 460]
	add	w0, w0, 1
	str	w0, [sp, 460]
	b	.L187
.L274:
	ldr	w6, [sp, 256]
	mov	x5, x15
	ldr	w2, [sp, 260]
	ldr	w0, [sp, 268]
	str	x1, [sp, 152]
	sub	w0, w19, w0
	stp	x9, x10, [sp, 184]
	bl	update4x8_sve
	ldr	x1, [sp, 152]
	ldp	x9, x10, [sp, 184]
	b	.L258
.L463:
	ldr	x0, [sp, 352]
	ldr	x6, [sp, 168]
	add	x3, x15, x0
	ldr	w0, [sp, 232]
	ldr	w4, [sp, 256]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	bgt	.L252
.L464:
	cmp	w8, 8
	mov	w14, 8
	csel	w14, w8, w14, le
	lsl	x5, x6, 3
	sub	w0, w14, #1
	str	w0, [sp, 224]
	lsr	w0, w14, 2
	str	w0, [sp, 280]
	add	x0, x3, x5
	str	x0, [sp, 240]
	ldr	x0, [sp, 464]
	lsr	w4, w14, 1
	and	w7, w14, -2
	lsl	x2, x6, 4
	ldr	x22, [sp, 344]
	lsl	x16, x6, 1
	ldr	x11, [sp, 488]
	add	x12, x0, x9
	movi	v4.4s, 0
	ldr	w30, [sp, 480]
	ldr	w17, [sp, 504]
	mov	x13, x15
	str	w4, [sp, 192]
	mov	x4, x26
	ldr	x26, [sp, 160]
	str	w7, [sp, 288]
	mov	x7, x9
	ldr	w9, [sp, 132]
	add	x0, sp, 768
	str	x11, [sp, 152]
	mov	x11, x10
	mov	x10, x16
	str	x6, [sp, 200]
	mov	x6, x25
	str	x5, [sp, 472]
	mov	x5, x1
	str	x20, [sp, 536]
	mov	x20, x2
	mov	w24, 0
	str	x23, [sp, 184]
	str	x15, [sp, 528]
	str	w21, [sp, 548]
.L257:
	ldr	w1, [sp, 248]
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w1, w19
	bge	.L256
	cmp	w9, w30
	ble	.L302
	ldp	x2, x1, [sp, 144]
	mov	x25, x3
	ldr	x16, [sp, 200]
	mov	x15, 0
	ldr	x21, [sp, 240]
	str	x18, [sp, 208]
	sub	x28, x1, x2
	mov	w1, w30
	str	w24, [sp, 216]
	stp	x13, x4, [sp, 296]
	b	.L268
.L468:
	ldp	q0, q1, [x25, 32]
	ldp	q2, q5, [x21, 32]
	ldp	q6, q8, [sp, 800]
	fmul	v1.2d, v1.2d, v7.2d
	fmul	v0.2d, v0.2d, v7.2d
	fmul	v5.2d, v5.2d, v3.2d
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v8.2d
	fadd	v0.2d, v0.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q0, q1, [sp, 800]
.L265:
	add	w2, w1, 2
	add	x28, x28, 16
	add	x25, x25, x20
	add	x21, x21, x20
	add	x15, x15, x10
	add	x16, x16, x10
	cmp	w2, w9
	bge	.L466
	.p2align 3,,7
.L304:
	mov	w1, w2
.L268:
	ldr	w2, [sp, 224]
	ldr	d0, [x28]
	cmp	w2, 2
	bls	.L467
	ldp	q1, q2, [x25]
	ldp	q5, q6, [x21]
	ldp	q16, q17, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d3, [x28, 8]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w2, [sp, 280]
	dup	v7.2d, v0.d[0]
	fmul	v6.2d, v6.2d, v3.d[0]
	fmul	v5.2d, v5.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v17.2d
	fadd	v1.2d, v1.2d, v16.2d
	dup	v3.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	stp	q1, q2, [sp, 768]
	cmp	w2, 2
	beq	.L468
	cmp	w8, 4
	beq	.L265
	mov	x4, 4
	mov	w2, w4
.L263:
	sub	w24, w14, w4
	sxtw	x13, w1
	cmp	w24, 1
	beq	.L266
	add	x23, x4, x15
	add	x18, x4, x16
	lsl	x4, x4, 3
	lsl	x23, x23, 3
	lsl	x18, x18, 3
	ldr	q2, [x0, x4]
	ldr	q1, [x3, x23]
	add	x23, x13, x22
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x4]
	ldr	d3, [x27, x23, lsl 3]
	ldr	q2, [x3, x18]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x4]
	tbz	x24, 0, .L265
	and	w24, w24, -2
	add	w2, w2, w24
.L266:
	sxtw	x2, w2
	add	x13, x13, x22
	add	x18, x2, x15
	add	x4, x2, x16
	add	x28, x28, 16
	add	x25, x25, x20
	ldr	d2, [x0, x2, lsl 3]
	add	x21, x21, x20
	ldr	d5, [x3, x18, lsl 3]
	add	x15, x15, x10
	ldr	d1, [x3, x4, lsl 3]
	add	x16, x16, x10
	ldr	d3, [x27, x13, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
	add	w2, w1, 2
	cmp	w2, w9
	blt	.L304
.L466:
	ldp	x13, x4, [sp, 296]
	add	w1, w1, 1
	ldr	x18, [sp, 208]
	ldr	w24, [sp, 216]
.L262:
	sxtw	x21, w1
	ldr	w23, [sp, 288]
	ldr	x1, [sp, 176]
	stp	x18, x27, [sp, 208]
	ldr	w18, [sp, 192]
	ldr	x28, [sp, 472]
	sub	x16, x21, x1
	ldr	x1, [sp, 200]
	ldr	x25, [sp, 152]
	mov	x27, x1
	mul	x15, x1, x16
	madd	x16, x16, x28, x3
	b	.L272
	.p2align 2,,3
.L470:
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w18, 2
	beq	.L270
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w18, 4
	bne	.L270
	ldr	q1, [x16, 48]
	ldr	q0, [sp, 816]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [sp, 816]
.L271:
	add	x21, x21, 1
	add	x15, x15, x27
	add	x16, x16, x28
	cmp	w19, w21
	ble	.L469
	.p2align 3,,7
.L272:
	ldr	d0, [x25, x21, lsl 3]
	cmp	w8, 1
	beq	.L305
	ldr	q2, [x16]
	sxtw	x1, w23
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w18, 1
	bhi	.L470
.L270:
	cmp	w14, w23
	beq	.L271
.L269:
	add	x2, x1, x15
	ldr	d1, [x0, x1, lsl 3]
	add	x21, x21, 1
	add	x15, x15, x27
	add	x16, x16, x28
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
	cmp	w19, w21
	bgt	.L272
.L469:
	ldp	x18, x27, [sp, 208]
.L256:
	cmp	w8, 1
	beq	.L301
	ldr	q0, [x13]
	ldr	q1, [sp, 768]
	ldr	w1, [sp, 192]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13]
	cmp	w1, 1
	bls	.L260
	ldr	q0, [x13, 16]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 16]
	cmp	w1, 2
	beq	.L260
	ldr	q0, [x13, 32]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 32]
	cmp	w1, 4
	bne	.L260
	ldr	q0, [x13, 48]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 48]
	.p2align 3,,7
.L261:
	add	w24, w24, 1
	ldr	x1, [sp, 168]
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	add	x13, x13, x1
	ldr	x1, [sp, 184]
	add	x22, x22, x1
	ldr	x1, [sp, 152]
	add	x1, x1, x26
	str	x1, [sp, 152]
	cmp	w24, w17
	blt	.L257
	ldr	x23, [sp, 184]
	mov	x26, x4
	ldr	x15, [sp, 528]
	mov	x1, x5
	ldr	x20, [sp, 536]
	mov	x25, x6
	ldr	w21, [sp, 548]
	mov	x9, x7
	mov	x10, x11
	b	.L258
.L260:
	ldr	w1, [sp, 288]
	cmp	w14, w1
	beq	.L261
.L259:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x18, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x18, x2, lsl 3]
	b	.L261
.L305:
	mov	x1, 0
	b	.L269
.L301:
	mov	w1, 0
	b	.L259
.L302:
	ldr	w1, [sp, 268]
	b	.L262
.L467:
	mov	x4, 0
	mov	w2, 0
	b	.L263
.L306:
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
	b	.L275
.L189:
	add	w0, w27, 64
	str	w0, [sp, 136]
	ldr	w0, [sp, 272]
	cbnz	w0, .L278
	mov	w26, w15
	cmp	w15, w4
	blt	.L279
	ldr	w0, [sp, 460]
	ldr	w1, [sp, 688]
	cmp	w0, w1
	bne	.L471
.L452:
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	x26, x25
	ldr	x20, [sp, 712]
	mov	x19, x28
	ldr	w25, [sp, 704]
	mov	x22, x18
	ldr	w27, [sp, 708]
	ldr	w21, [sp, 720]
	b	.L185
.L278:
	.cfi_restore_state
	sub	w0, w4, w15
	cmp	w0, 15
	ble	.L292
	ldr	w1, [sp, 260]
	mov	w24, w23
	ldr	w0, [sp, 256]
	mov	w19, w15
	ldr	w23, [sp, 328]
	mov	x26, x18
	str	w15, [sp, 344]
	smull	x10, w1, w15
	ldr	x1, [sp, 320]
	smull	x0, w0, w15
	mov	x15, x10
	sub	x1, x1, x0
	add	x22, x0, w27, sxtw
	ldr	x0, [sp, 176]
	lsl	x13, x1, 3
	add	x2, x25, x22, lsl 3
	mov	x14, x13
	add	x0, x10, x0
	mov	x21, x2
	add	x1, x28, x0, lsl 3
.L221:
	ldr	w0, [sp, 136]
	cmp	w27, w0
	bge	.L193
	ldr	x0, [sp, 144]
	mov	x10, x22
	mov	w20, w27
	mov	x13, x21
	add	x0, x1, x0
	stp	x1, x14, [sp, 280]
	stp	x15, x0, [sp, 296]
	str	w27, [sp, 352]
	mov	x27, x26
	str	w19, [sp, 464]
	str	x21, [sp, 472]
	str	w4, [sp, 480]
	str	x22, [sp, 488]
	ldr	x22, [sp, 168]
	b	.L226
.L224:
	ldr	x1, [sp, 280]
	mov	x5, x13
	ldr	w6, [sp, 256]
	add	w20, w20, 8
	ldr	w2, [sp, 260]
	ldr	w0, [sp, 268]
	str	x13, [sp, 152]
	sub	w0, w23, w0
	str	x10, [sp, 184]
	bl	update16x8_sve
	ldr	x13, [sp, 152]
	ldr	x10, [sp, 184]
	add	x13, x13, 64
	ldr	w0, [sp, 136]
	add	x10, x10, 8
	cmp	w20, w0
	bge	.L472
.L226:
	ldr	x0, [sp, 312]
	ldr	w1, [sp, 136]
	ldr	x0, [x0, 16]
	sub	w6, w1, w20
	ldr	x3, [x0]
	cbz	x3, .L473
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L245:
	cmp	w6, 7
	bgt	.L224
	ldp	x19, x5, [sp, 296]
	lsl	x0, x8, 4
	str	x0, [sp, 240]
	lsl	x0, x8, 1
	lsl	x7, x8, 3
	ldr	w18, [sp, 248]
	movi	v4.4s, 0
	str	x0, [sp, 232]
	sub	w0, w6, #1
	add	x17, x25, x10, lsl 3
	add	x30, x7, 16
	and	w21, w6, -4
	lsr	w4, w6, 1
	and	w11, w6, -2
	mov	x12, x10
	and	w9, w6, 1
	str	w0, [sp, 224]
	add	x0, sp, 768
	and	w1, w6, 3
	mov	w26, 16
	str	w1, [sp, 152]
	str	w20, [sp, 504]
	str	x10, [sp, 528]
	str	x13, [sp, 536]
	.p2align 3,,7
.L229:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w18, w23
	bge	.L228
	ldr	w1, [sp, 132]
	cmp	w1, w24
	ble	.L298
	ldr	x1, [sp, 144]
	mov	x10, x3
	mov	x16, x8
	mov	x15, 0
	sub	x20, x5, x1
	mov	w1, w24
	stp	x25, x27, [sp, 184]
	stp	x5, x22, [sp, 200]
	str	w4, [sp, 216]
	b	.L238
	.p2align 2,,3
.L299:
	mov	w1, w2
.L238:
	ldr	w2, [sp, 224]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x5, x4, x19
	cmp	w2, 2
	bls	.L474
	ldp	q1, q2, [x10]
	mov	w13, w21
	ldr	q5, [x10, x30]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x28, x5, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w5, [sp, 152]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 768]
	cbz	w5, .L243
.L244:
	uxtw	x5, w13
	add	x25, x4, x19
	add	x22, x5, x15
	add	x14, x5, x16
	sub	w13, w6, w13
	lsl	x5, x5, 3
	mov	x4, x25
	lsl	x22, x22, 3
	lsl	x14, x14, 3
	and	w27, w13, -2
	cmp	w13, 1
	beq	.L236
	ldr	q1, [x3, x22]
	add	w2, w2, w27
	ldr	q2, [x0, x5]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x5]
	ldr	d3, [x28, x25, lsl 3]
	ldr	q2, [x3, x14]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x5]
	tbz	x13, 0, .L243
.L236:
	sxtw	x2, w2
	ldr	d1, [x28, x4, lsl 3]
	add	x5, x2, x15
	add	x4, x2, x16
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x5, lsl 3]
	ldr	d3, [x3, x4, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
.L243:
	ldr	x4, [sp, 240]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x10, x10, x4
	ldr	x4, [sp, 232]
	add	x15, x15, x4
	add	x16, x16, x4
	ldr	w4, [sp, 132]
	cmp	w2, w4
	blt	.L299
	ldp	x25, x27, [sp, 184]
	add	w1, w1, 1
	ldp	x5, x22, [sp, 200]
	ldr	w4, [sp, 216]
.L234:
	sxtw	x13, w1
	ldr	x1, [sp, 176]
	sub	x14, x13, x1
	mul	x10, x8, x14
	madd	x14, x14, x7, x3
	.p2align 3,,7
.L242:
	ldr	d0, [x5, x13, lsl 3]
	cmp	w6, 1
	beq	.L300
	ldr	q2, [x14]
	sxtw	x1, w11
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w4, 1
	bls	.L240
	ldr	q2, [x14, 16]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w4, 3
	bne	.L240
	ldr	q2, [x14, 32]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
.L240:
	cbz	w9, .L241
.L239:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L241:
	add	x13, x13, 1
	add	x10, x10, x8
	add	x14, x14, x7
	cmp	w23, w13
	bgt	.L242
.L228:
	cmp	w6, 1
	beq	.L297
	ldr	q0, [x17]
	ldr	q1, [sp, 768]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17]
	cmp	w4, 1
	bls	.L232
	ldr	q0, [x17, 16]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 16]
	cmp	w4, 3
	bne	.L232
	ldr	q0, [x17, 32]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 32]
.L232:
	sxtw	x1, w11
	cbz	w9, .L233
.L231:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x25, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x25, x2, lsl 3]
.L233:
	ldr	x1, [sp, 120]
	add	x12, x12, x22
	add	x19, x19, x27
	subs	w26, w26, #1
	add	x17, x17, x1
	ldr	x1, [sp, 160]
	add	x5, x5, x1
	bne	.L229
	ldr	x10, [sp, 528]
	ldr	x13, [sp, 536]
	add	x10, x10, 8
	ldr	w20, [sp, 504]
	ldr	w0, [sp, 136]
	add	x13, x13, 64
	add	w20, w20, 8
	cmp	w20, w0
	blt	.L226
.L472:
	ldp	x1, x14, [sp, 280]
	mov	x26, x27
	ldr	x15, [sp, 296]
	ldr	x21, [sp, 472]
	ldr	x22, [sp, 488]
	ldr	w27, [sp, 352]
	ldr	w19, [sp, 464]
	ldr	w4, [sp, 480]
.L193:
	ldr	x0, [sp, 600]
	add	w19, w19, 16
	sub	w3, w4, w19
	add	x1, x1, x0
	ldr	x0, [sp, 624]
	add	x15, x15, x0
	ldr	x0, [sp, 664]
	add	x14, x14, x0
	sub	x21, x21, x0
	ldr	x0, [sp, 336]
	add	x22, x22, x0
	cmp	w3, 15
	bgt	.L221
	mov	x18, x26
	ldr	w15, [sp, 344]
	mov	w26, w19
	mov	w23, w24
	b	.L191
	.p2align 2,,3
.L300:
	mov	x1, 0
	b	.L239
.L297:
	mov	x1, 0
	b	.L231
.L298:
	ldr	w1, [sp, 268]
	b	.L234
.L474:
	mov	w13, 0
	mov	w2, 0
	b	.L244
.L473:
	ldr	x0, [sp, 288]
	mov	x8, x22
	ldr	w4, [sp, 256]
	add	x3, x13, x0
	b	.L245
.L459:
	.cfi_restore 72
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L121:
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	add	sp, sp, 1024
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
.L186:
	.cfi_def_cfa_offset 1024
	.cfi_offset 19, -1008
	.cfi_offset 20, -1000
	.cfi_offset 21, -992
	.cfi_offset 22, -984
	.cfi_offset 23, -976
	.cfi_offset 24, -968
	.cfi_offset 25, -960
	.cfi_offset 26, -952
	.cfi_offset 27, -944
	.cfi_offset 28, -936
	.cfi_offset 29, -1024
	.cfi_offset 30, -1016
	add	w1, w1, 1
	mov	w0, 0
	b	.L281
.L465:
	.cfi_offset 72, -928
	ldr	w0, [sp, 264]
	add	w15, w15, 64
	mov	w27, 0
	sub	w0, w0, w15
	str	w0, [sp, 524]
	b	.L249
.L292:
	mov	w26, w15
.L191:
	add	w0, w26, 7
	cmp	w4, w0
	ble	.L190
	ldr	w0, [sp, 256]
	ldr	w1, [sp, 260]
	str	w15, [sp, 352]
	smull	x2, w0, w26
	sub	w0, w4, #8
	sub	w24, w0, w26
	smull	x10, w1, w26
	ldr	x0, [sp, 320]
	add	x22, x2, w27, sxtw
	and	w1, w24, -8
	str	w24, [sp, 480]
	sub	x0, x0, x2
	ldr	w24, [sp, 328]
	ldr	x2, [sp, 176]
	lsl	x8, x0, 3
	add	x0, x25, x22, lsl 3
	mov	x15, x10
	add	x3, x10, x2
	add	w2, w26, 8
	add	w19, w1, w2
	str	w2, [sp, 464]
	mov	w21, w19
	mov	x19, x0
	mov	w0, w23
	add	x1, x28, x3, lsl 3
	mov	x23, x25
	mov	x2, x8
	mov	x25, x28
	mov	w28, w0
.L195:
	ldr	w0, [sp, 136]
	cmp	w27, w0
	bge	.L201
	ldr	x0, [sp, 144]
	mov	x10, x22
	mov	x13, x19
	mov	w20, w27
	add	x0, x1, x0
	str	x0, [sp, 344]
	str	w27, [sp, 472]
	str	w4, [sp, 488]
	str	x19, [sp, 504]
	str	x22, [sp, 528]
	mov	x22, x18
	str	w26, [sp, 536]
	mov	x26, x10
	mov	x10, x2
	str	w21, [sp, 548]
	b	.L200
.L198:
	ldr	w6, [sp, 256]
	mov	x5, x13
	ldr	w2, [sp, 260]
	add	w20, w20, 8
	ldr	w0, [sp, 268]
	add	x26, x26, 8
	str	x1, [sp, 152]
	sub	w0, w24, w0
	stp	x13, x10, [sp, 184]
	str	x15, [sp, 200]
	bl	update8x8_sve
	ldp	x13, x10, [sp, 184]
	ldr	w0, [sp, 136]
	ldr	x1, [sp, 152]
	ldr	x15, [sp, 200]
	add	x13, x13, 64
	cmp	w20, w0
	bge	.L475
.L200:
	ldr	x0, [sp, 312]
	ldr	w2, [sp, 136]
	ldr	x0, [x0, 16]
	sub	w5, w2, w20
	ldr	x3, [x0]
	cbz	x3, .L476
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L220:
	cmp	w5, 7
	bgt	.L198
	lsl	x0, x8, 4
	lsl	x7, x8, 3
	ldr	x6, [sp, 344]
	lsr	w4, w5, 1
	and	w9, w5, 1
	and	w2, w5, 3
	movi	v4.4s, 0
	ldr	w30, [sp, 248]
	str	x0, [sp, 216]
	sub	w0, w5, #1
	str	x13, [sp, 728]
	add	x14, x23, x26, lsl 3
	ldr	w13, [sp, 132]
	lsl	x18, x8, 1
	mov	x12, x26
	add	x27, x7, 16
	and	w21, w5, -4
	and	w11, w5, -2
	mov	x19, x15
	str	x6, [sp, 152]
	mov	x6, x1
	str	w4, [sp, 184]
	mov	x4, x26
	mov	w26, w2
	str	w9, [sp, 192]
	mov	x9, x15
	str	x8, [sp, 200]
	mov	x8, x10
	str	w0, [sp, 208]
	add	x0, sp, 768
	mov	w17, 8
	str	w20, [sp, 724]
.L204:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w30, w24
	bge	.L203
	cmp	w13, w28
	ble	.L294
	ldp	x2, x1, [sp, 144]
	mov	x10, x3
	ldr	x16, [sp, 200]
	mov	x15, 0
	stp	x23, x22, [sp, 224]
	sub	x20, x1, x2
	mov	w1, w28
	str	w11, [sp, 240]
	str	w17, [sp, 280]
	str	x4, [sp, 288]
	str	w24, [sp, 296]
	str	x12, [sp, 304]
	b	.L213
.L295:
	mov	w1, w2
.L213:
	ldr	w2, [sp, 208]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x11, x4, x19
	cmp	w2, 2
	bls	.L477
	ldp	q1, q2, [x10]
	mov	w12, w21
	ldr	q5, [x10, x27]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x25, x11, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 768]
	cbz	w26, .L218
.L219:
	uxtw	x11, w12
	add	x23, x4, x19
	add	x22, x11, x15
	add	x17, x11, x16
	sub	w12, w5, w12
	lsl	x11, x11, 3
	mov	x4, x23
	lsl	x22, x22, 3
	lsl	x17, x17, 3
	and	w24, w12, -2
	cmp	w12, 1
	beq	.L211
	ldr	q1, [x3, x22]
	add	w2, w2, w24
	ldr	q2, [x0, x11]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x11]
	ldr	d3, [x25, x23, lsl 3]
	ldr	q2, [x3, x17]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x11]
	tbz	x12, 0, .L218
.L211:
	sxtw	x2, w2
	ldr	d1, [x25, x4, lsl 3]
	add	x11, x2, x15
	add	x4, x2, x16
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x11, lsl 3]
	ldr	d3, [x3, x4, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
.L218:
	ldr	x4, [sp, 216]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x15, x15, x18
	add	x16, x16, x18
	add	x10, x10, x4
	cmp	w2, w13
	blt	.L295
	ldp	x23, x22, [sp, 224]
	add	w1, w1, 1
	ldr	x4, [sp, 288]
	ldr	x12, [sp, 304]
	ldr	w11, [sp, 240]
	ldr	w17, [sp, 280]
	ldr	w24, [sp, 296]
.L209:
	sxtw	x15, w1
	ldr	w20, [sp, 184]
	ldr	x1, [sp, 176]
	str	w21, [sp, 224]
	ldr	x21, [sp, 152]
	sub	x16, x15, x1
	ldr	x1, [sp, 200]
	stp	x23, x25, [sp, 232]
	ldr	w25, [sp, 192]
	mov	x23, x1
	mul	x10, x16, x1
	madd	x16, x16, x7, x3
	.p2align 3,,7
.L217:
	ldr	d0, [x21, x15, lsl 3]
	cmp	w5, 1
	beq	.L296
	ldr	q2, [x16]
	sxtw	x1, w11
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w20, 1
	bls	.L215
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w20, 3
	bne	.L215
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
.L215:
	cbz	w25, .L216
.L214:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L216:
	add	x15, x15, 1
	add	x10, x10, x23
	add	x16, x16, x7
	cmp	w24, w15
	bgt	.L217
	ldp	x23, x25, [sp, 232]
	ldr	w21, [sp, 224]
.L203:
	cmp	w5, 1
	beq	.L293
	ldr	q0, [x14]
	ldr	q1, [sp, 768]
	ldr	w1, [sp, 184]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14]
	cmp	w1, 1
	bls	.L207
	ldr	q0, [x14, 16]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 16]
	cmp	w1, 3
	bne	.L207
	ldr	q0, [x14, 32]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 32]
.L207:
	ldr	w1, [sp, 192]
	cbz	w1, .L208
	sxtw	x1, w11
.L206:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x23, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x23, x2, lsl 3]
.L208:
	ldp	x2, x1, [sp, 160]
	add	x19, x19, x22
	subs	w17, w17, #1
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	add	x14, x14, x1
	ldr	x1, [sp, 152]
	add	x1, x1, x2
	str	x1, [sp, 152]
	bne	.L204
	ldr	x13, [sp, 728]
	mov	x26, x4
	ldr	w20, [sp, 724]
	mov	x1, x6
	ldr	w0, [sp, 136]
	mov	x10, x8
	add	w20, w20, 8
	mov	x15, x9
	add	x13, x13, 64
	add	x26, x26, 8
	cmp	w20, w0
	blt	.L200
.L475:
	ldr	x19, [sp, 504]
	mov	x18, x22
	ldr	x22, [sp, 528]
	mov	x2, x10
	ldr	w27, [sp, 472]
	ldr	w4, [sp, 488]
	ldr	w26, [sp, 536]
	ldr	w21, [sp, 548]
.L201:
	ldr	x0, [sp, 608]
	add	w26, w26, 8
	add	x1, x1, x0
	ldr	x0, [sp, 160]
	add	x15, x15, x0
	ldr	x0, [sp, 672]
	add	x2, x2, x0
	sub	x19, x19, x0
	ldr	x0, [sp, 120]
	add	x22, x22, x0
	cmp	w26, w21
	bne	.L195
	ldr	w24, [sp, 480]
	mov	w0, w28
	ldr	w2, [sp, 464]
	mov	x28, x25
	and	w24, w24, -8
	mov	x25, x23
	ldr	w15, [sp, 352]
	mov	w23, w0
	add	w26, w24, w2
	b	.L190
.L296:
	mov	x1, 0
	b	.L214
.L293:
	mov	x1, 0
	b	.L206
.L294:
	ldr	w1, [sp, 268]
	b	.L209
.L476:
	ldr	x8, [sp, 168]
	add	x3, x13, x10
	ldr	w4, [sp, 256]
	b	.L220
.L477:
	mov	w12, 0
	mov	w2, 0
	b	.L219
.L457:
	.cfi_restore 72
	str	d8, [sp, 96]
	.cfi_offset 72, -928
	b	.L284
.L288:
	mov	w12, 0
	b	.L169
	.p2align 2,,3
.L283:
	.cfi_restore 72
	bl	GOMP_barrier
	b	.L185
	.cfi_endproc
.LFE4370:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4369:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L483
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
	mov	w22, w3
	mov	x24, x2
	mov	x23, x4
	mov	w21, w5
	cmp	x0, x1
	bls	.L480
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	str	xzr, [sp, 64]
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L481
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L481:
	mov	x0, 16
	bl	getauxval
	add	x5, sp, 64
	ubfx	w4, w0, 22, 1
	adrp	x1, solve_blocked._omp_fn.0
	mov	w3, 0
	add	x0, x1, :lo12:solve_blocked._omp_fn.0
	mov	w2, 0
	add	x1, sp, 80
	stp	x24, x23, [sp, 80]
	str	x5, [sp, 96]
	stp	w19, w20, [sp, 104]
	stp	w22, w21, [sp, 112]
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
.L480:
	.cfi_restore_state
	add	x1, sp, 80
	mov	w3, 0
	mov	w2, 0
	adrp	x0, solve_panel._omp_fn.0
	add	x0, x0, :lo12:solve_panel._omp_fn.0
	stp	x24, x4, [sp, 80]
	stp	w19, w20, [sp, 96]
	stp	w22, w5, [sp, 104]
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
.L483:
	ret
	.cfi_endproc
.LFE4369:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (gcc for openEuler 3.0.2) 12.3.1"
	.section	.note.GNU-stack,"",@progbits
