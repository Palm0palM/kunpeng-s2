	.arch armv8-a
	.file	"trsm.c"
	.text
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
	.type	trsm_sve_has_eight_doubles, %function
trsm_sve_has_eight_doubles:
.LFB4365:
	.cfi_startproc
	cntd	x0
	cmp	x0, 8
	cset	w0, eq
	ret
	.cfi_endproc
.LFE4365:
	.size	trsm_sve_has_eight_doubles, .-trsm_sve_has_eight_doubles
	.align	2
	.p2align 4,,11
	.type	update8x8_sve, %function
update8x8_sve:
.LFB4367:
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
.LFE4367:
	.size	update8x8_sve, .-update8x8_sve
	.align	2
	.p2align 4,,11
	.type	update16x8_sve, %function
update16x8_sve:
.LFB4368:
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
.LFE4368:
	.size	update16x8_sve, .-update16x8_sve
	.align	2
	.p2align 4,,11
	.type	update4x8_sve, %function
update4x8_sve:
.LFB4366:
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
.LFE4366:
	.size	update4x8_sve, .-update4x8_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4371:
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
	cbz	w1, .L184
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 484]
.L184:
	ldr	w0, [sp, 264]
	cmp	w0, 0
	ble	.L23
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
	b	.L85
.L363:
	add	w0, w1, 256
	str	w0, [sp, 328]
	ldr	w0, [sp, 544]
	cmp	w27, w0
	bgt	.L360
.L27:
	str	w7, [sp, 132]
	bl	GOMP_barrier
	ldr	w0, [sp, 264]
	ldr	w1, [sp, 328]
	ldr	w7, [sp, 132]
	cmp	w0, w1
	ble	.L87
	ldr	w0, [sp, 264]
	ldr	w1, [sp, 328]
	add	w0, w0, 63
	sub	w0, w0, w1
	ldr	w1, [sp, 332]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L87
	ldr	w1, [sp, 520]
	ldr	w2, [sp, 692]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	cmp	w25, w0
	bcc	.L88
.L183:
	madd	w0, w1, w25, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L361
.L87:
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
	ble	.L362
.L85:
	ldr	x1, [sp, 176]
	str	w1, [sp, 268]
	ldr	w0, [sp, 264]
	mov	w7, w1
	sub	w0, w0, w1
	cmp	w0, 255
	bgt	.L363
	ldr	w0, [sp, 544]
	cmp	w27, w0
	ble	.L185
	ldr	w0, [sp, 264]
	str	w0, [sp, 328]
	str	d8, [sp, 96]
	.cfi_offset 72, -928
.L186:
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
.L31:
	ldr	x0, [sp, 312]
	mov	w3, 8
	ldr	w1, [sp, 132]
	ldr	x0, [x0, 16]
	cmp	w1, 8
	csel	w3, w1, w3, le
	ldr	x25, [x0]
	cbz	x25, .L364
	cmp	w28, 0
	add	w1, w28, 7
	csel	w1, w1, w28, lt
	asr	w1, w1, 3
	sbfiz	x21, x1, 14, 32
	sxtw	x1, w1
	add	x21, x25, x21
	cmp	w30, 0
	ble	.L32
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
.L81:
	cmp	w20, 0
	ble	.L52
.L51:
	ldr	w0, [sp, 256]
	smaddl	x1, w21, w0, x27
	lsl	x0, x1, 3
	ldr	d0, [x26, x1, lsl 3]
	add	x0, x26, x0
	str	d0, [x19]
	cmp	w20, 1
	ble	.L52
	ldr	d0, [x0, 8]
	str	d0, [x19, 8]
	cmp	w20, 2
	ble	.L52
	ldr	d0, [x0, 16]
	str	d0, [x19, 16]
	cmp	w20, 3
	ble	.L52
	ldr	d0, [x0, 24]
	str	d0, [x19, 24]
	cmp	w20, 4
	ble	.L52
	ldr	d0, [x0, 32]
	str	d0, [x19, 32]
	cmp	w20, 5
	ble	.L52
	ldr	d0, [x0, 40]
	str	d0, [x19, 40]
	cmp	w20, 6
	ble	.L52
	ldr	d0, [x0, 48]
	str	d0, [x19, 48]
	cmp	w20, 7
	ble	.L52
	ldr	d0, [x0, 56]
	add	w21, w21, 1
	add	x19, x19, 64
	str	d0, [x19, -8]
	cmp	w24, w21
	bne	.L51
.L358:
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
.L59:
	stp	q17, q17, [x0]
	stp	q17, q17, [x0, 32]
	stp	q17, q17, [x0, 64]
	stp	q17, q17, [x0, 96]
	stp	q17, q17, [x0, 128]
	stp	q17, q17, [x0, 160]
	stp	q17, q17, [x0, 192]
	stp	q17, q17, [x0, 224]
	cmp	w4, 3
	ble	.L365
	movi	v0.2d, 0
	cbz	w3, .L192
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
.L79:
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
	bne	.L79
.L78:
	stp	q8, q31, [sp, 768]
	stp	q30, q29, [sp, 800]
	stp	q28, q27, [sp, 832]
	stp	q26, q25, [sp, 864]
	stp	q24, q23, [sp, 896]
	stp	q22, q21, [sp, 928]
	stp	q20, q19, [sp, 960]
	stp	q18, q0, [sp, 992]
.L80:
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
	beq	.L69
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
	b	.L70
.L73:
	add	x6, x6, 64
	add	x11, x11, x22
	cmp	w9, 2
	beq	.L190
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
.L71:
	add	x8, x8, 64
	ldr	x16, [sp, 424]
	add	x18, x18, x16
.L70:
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
	bge	.L72
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
	bne	.L72
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
.L72:
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
	bne	.L73
.L69:
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
	bgt	.L59
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
	ble	.L32
	ldr	x0, [sp, 136]
	add	x1, x16, 1
	add	x1, x21, x1, lsl 6
	add	x0, x26, x0, lsl 3
.L56:
	ldr	d0, [x20]
	str	d0, [x0]
	cmp	w3, 1
	ble	.L54
	ldr	d0, [x20, 8]
	str	d0, [x0, 8]
	cmp	w3, 2
	ble	.L54
	ldr	d0, [x20, 16]
	str	d0, [x0, 16]
	cmp	w3, 3
	ble	.L54
	ldr	d0, [x20, 24]
	str	d0, [x0, 24]
	cmp	w3, 4
	ble	.L54
	ldr	d0, [x20, 32]
	str	d0, [x0, 32]
	cmp	w3, 5
	ble	.L54
	ldr	d0, [x20, 40]
	str	d0, [x0, 40]
	cmp	w3, 6
	ble	.L54
	ldr	d0, [x20, 48]
	str	d0, [x0, 48]
	cmp	w3, 7
	ble	.L54
	ldr	d0, [x20, 56]
	str	d0, [x0, 56]
.L54:
	ldr	x4, [sp, 120]
	add	x20, x20, 64
	add	x0, x0, x4
	cmp	x20, x1
	bne	.L56
.L32:
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
	bgt	.L31
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	w25, w9
	ldr	w7, [sp, 144]
	mov	w27, w6
	mov	w21, w23
	mov	x20, x2
	b	.L27
.L52:
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
	bne	.L81
	b	.L358
.L365:
	cbz	w3, .L80
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
.L76:
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
	ble	.L74
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
	bne	.L74
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
.L74:
	ldr	x0, [sp, 184]
	add	x8, x8, 8
	mov	v8.16b, v26.16b
	add	x9, x9, 64
	mov	v19.16b, v27.16b
	mov	v21.16b, v18.16b
	cmp	x8, x0
	bne	.L76
	stp	q20, q26, [sp, 768]
	stp	q27, q18, [sp, 800]
	ldr	x0, [sp, 288]
	cbz	w6, .L61
	str	q0, [sp, 880]
.L61:
	cbz	w11, .L62
	str	q1, [sp, 864]
.L62:
	cbz	w13, .L63
	str	q16, [sp, 848]
.L63:
	cbz	w12, .L64
	str	q2, [sp, 832]
.L64:
	cbz	w28, .L65
	str	q25, [sp, 944]
.L65:
	cbz	w17, .L66
	str	q24, [sp, 928]
.L66:
	cbz	w16, .L67
	str	q23, [sp, 912]
.L67:
	cbz	w2, .L80
	str	q22, [sp, 896]
	b	.L80
.L364:
	cmp	w24, w17
	ble	.L32
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
.L35:
	ldr	d1, [x12]
	cmp	w5, 0
	ble	.L49
	cmp	w5, 1
	beq	.L189
	ldr	q2, [x0]
	dup	v0.2d, v1.d[0]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0]
	cmp	w8, 1
	bls	.L48
	ldr	q2, [x0, 16]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 16]
	cmp	w8, 2
	beq	.L48
	ldr	q2, [x0, 32]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 32]
	cmp	w8, 3
	beq	.L48
	ldr	q2, [x0, 48]
	fdiv	v0.2d, v2.2d, v0.2d
	str	q0, [x0, 48]
.L48:
	mov	w1, w20
	cbz	w13, .L49
.L47:
	add	x1, x11, w1, sxtw
	ldr	d0, [x26, x1, lsl 3]
	fdiv	d0, d0, d1
	str	d0, [x26, x1, lsl 3]
.L49:
	ldr	x1, [sp, 424]
	add	w4, w4, 1
	add	x12, x12, x1
	ldr	x1, [sp, 168]
	add	x11, x11, x1
	ldr	x1, [sp, 120]
	add	x0, x0, x1
	cmp	w4, w10
	ble	.L35
	cmp	w4, w24
	bge	.L32
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
.L45:
	stp	q2, q2, [x0]
	stp	q2, q2, [x0, 32]
	cmp	w14, 0
	ble	.L36
	ldr	x11, [sp, 136]
	mov	x5, x21
	ldr	x7, [sp, 176]
.L39:
	ldr	d0, [x10, x7, lsl 3]
	cmp	w14, 1
	beq	.L187
	ldr	q3, [x5]
	ldr	q1, [sp, 768]
	fmul	v3.2d, v3.2d, v0.d[0]
	dup	v4.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 768]
	cmp	w8, 1
	bls	.L38
	ldr	q3, [x5, 16]
	ldr	q1, [sp, 784]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 784]
	cmp	w8, 2
	beq	.L38
	ldr	q3, [x5, 32]
	ldr	q1, [sp, 800]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 800]
	cmp	w8, 3
	beq	.L38
	ldr	q3, [x5, 48]
	ldr	q1, [sp, 816]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 816]
.L38:
	sxtw	x1, w20
	cbz	w25, .L41
.L37:
	add	x13, x1, x11
	ldr	d1, [x0, x1, lsl 3]
	ldr	d3, [x26, x13, lsl 3]
	fmul	d0, d0, d3
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L41:
	ldr	x1, [sp, 168]
	add	x7, x7, 1
	add	x11, x11, x1
	ldr	x1, [sp, 120]
	add	x5, x5, x1
	cmp	w4, w7
	bgt	.L39
	ldr	d3, [x15]
	cmp	w14, 1
	beq	.L188
	ldr	q0, [x3]
	ldr	q4, [sp, 768]
	dup	v1.2d, v3.d[0]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3]
	cmp	w8, 1
	bls	.L43
	ldr	q0, [x3, 16]
	ldr	q4, [sp, 784]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 16]
	cmp	w8, 2
	beq	.L43
	ldr	q0, [x3, 32]
	ldr	q4, [sp, 800]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 32]
	cmp	w8, 3
	beq	.L43
	ldr	q0, [x3, 48]
	ldr	q4, [sp, 816]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 48]
.L43:
	sxtw	x1, w20
	cbz	w25, .L36
.L42:
	add	x5, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x26, x5, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d3
	str	d0, [x26, x5, lsl 3]
.L36:
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
	bne	.L45
	b	.L32
.L188:
	mov	x1, 0
	b	.L42
.L187:
	mov	x1, 0
	b	.L37
.L189:
	mov	w1, 0
	b	.L47
.L192:
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
	b	.L78
.L361:
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
.L89:
	ldr	w0, [sp, 524]
	add	w1, w15, 64
	ldr	w2, [sp, 332]
	ldr	w3, [sp, 264]
	cmp	w0, 63
	sub	w0, w2, w27
	csel	w4, w1, w3, gt
	cmp	w0, 63
	bgt	.L91
	ldr	w0, [sp, 272]
	mov	w26, w15
	str	w2, [sp, 136]
	cbnz	w0, .L180
.L92:
	cmp	w4, w26
	ble	.L148
	ldr	w0, [sp, 136]
	cmp	w27, w0
	bge	.L148
.L181:
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
.L156:
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
.L150:
	ldr	x0, [x10, 16]
	ldr	w2, [sp, 136]
	ldr	x3, [x0]
	sub	w8, w2, w21
	cbz	x3, .L366
	asr	w0, w21, 3
	mov	x6, 8
	mov	w4, w6
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 232]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	ble	.L367
.L154:
	ldr	w0, [sp, 272]
	cbnz	w0, .L176
	movi	v16.2d, 0
	ldr	w0, [sp, 456]
	cmp	w0, 0
	ble	.L208
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
.L178:
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
	bne	.L178
.L177:
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
.L160:
	ldr	w0, [sp, 136]
	add	w21, w21, 8
	add	x9, x9, 8
	add	x15, x15, 64
	add	x20, x20, 64
	cmp	w21, w0
	blt	.L150
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
	bgt	.L156
	mov	x25, x18
	ldr	w15, [sp, 724]
	mov	x18, x23
	ldr	w23, [sp, 480]
	mov	x28, x27
	mov	w27, w4
.L148:
	ldr	w0, [sp, 460]
	ldr	w1, [sp, 688]
	cmp	w0, w1
	beq	.L354
.L374:
	ldr	w0, [sp, 332]
	add	w27, w27, 64
	cmp	w0, w27
	ble	.L368
.L151:
	ldr	w0, [sp, 460]
	add	w0, w0, 1
	str	w0, [sp, 460]
	b	.L89
.L176:
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
	b	.L160
.L366:
	ldr	x0, [sp, 352]
	ldr	x6, [sp, 168]
	add	x3, x15, x0
	ldr	w0, [sp, 232]
	ldr	w4, [sp, 256]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	bgt	.L154
.L367:
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
.L159:
	ldr	w1, [sp, 248]
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w1, w19
	bge	.L158
	cmp	w9, w30
	ble	.L204
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
	b	.L170
.L371:
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
.L167:
	add	w2, w1, 2
	add	x28, x28, 16
	add	x25, x25, x20
	add	x21, x21, x20
	add	x15, x15, x10
	add	x16, x16, x10
	cmp	w2, w9
	bge	.L369
	.p2align 3,,7
.L206:
	mov	w1, w2
.L170:
	ldr	w2, [sp, 224]
	ldr	d0, [x28]
	cmp	w2, 2
	bls	.L370
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
	beq	.L371
	cmp	w8, 4
	beq	.L167
	mov	x4, 4
	mov	w2, w4
.L165:
	sub	w24, w14, w4
	sxtw	x13, w1
	cmp	w24, 1
	beq	.L168
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
	tbz	x24, 0, .L167
	and	w24, w24, -2
	add	w2, w2, w24
.L168:
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
	blt	.L206
.L369:
	ldp	x13, x4, [sp, 296]
	add	w1, w1, 1
	ldr	x18, [sp, 208]
	ldr	w24, [sp, 216]
.L164:
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
	b	.L174
	.p2align 2,,3
.L373:
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w18, 2
	beq	.L172
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w18, 4
	bne	.L172
	ldr	q1, [x16, 48]
	ldr	q0, [sp, 816]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [sp, 816]
.L173:
	add	x21, x21, 1
	add	x15, x15, x27
	add	x16, x16, x28
	cmp	w19, w21
	ble	.L372
	.p2align 3,,7
.L174:
	ldr	d0, [x25, x21, lsl 3]
	cmp	w8, 1
	beq	.L207
	ldr	q2, [x16]
	sxtw	x1, w23
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w18, 1
	bhi	.L373
.L172:
	cmp	w14, w23
	beq	.L173
.L171:
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
	bgt	.L174
.L372:
	ldp	x18, x27, [sp, 208]
.L158:
	cmp	w8, 1
	beq	.L203
	ldr	q0, [x13]
	ldr	q1, [sp, 768]
	ldr	w1, [sp, 192]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13]
	cmp	w1, 1
	bls	.L162
	ldr	q0, [x13, 16]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 16]
	cmp	w1, 2
	beq	.L162
	ldr	q0, [x13, 32]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 32]
	cmp	w1, 4
	bne	.L162
	ldr	q0, [x13, 48]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 48]
	.p2align 3,,7
.L163:
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
	blt	.L159
	ldr	x23, [sp, 184]
	mov	x26, x4
	ldr	x15, [sp, 528]
	mov	x1, x5
	ldr	x20, [sp, 536]
	mov	x25, x6
	ldr	w21, [sp, 548]
	mov	x9, x7
	mov	x10, x11
	b	.L160
.L162:
	ldr	w1, [sp, 288]
	cmp	w14, w1
	beq	.L163
.L161:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x18, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x18, x2, lsl 3]
	b	.L163
.L207:
	mov	x1, 0
	b	.L171
.L203:
	mov	w1, 0
	b	.L161
.L204:
	ldr	w1, [sp, 268]
	b	.L164
.L370:
	mov	x4, 0
	mov	w2, 0
	b	.L165
.L208:
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
	b	.L177
.L91:
	add	w0, w27, 64
	str	w0, [sp, 136]
	ldr	w0, [sp, 272]
	cbnz	w0, .L180
	mov	w26, w15
	cmp	w15, w4
	blt	.L181
	ldr	w0, [sp, 460]
	ldr	w1, [sp, 688]
	cmp	w0, w1
	bne	.L374
.L354:
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
	b	.L87
.L180:
	.cfi_restore_state
	sub	w0, w4, w15
	cmp	w0, 15
	ble	.L194
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
.L123:
	ldr	w0, [sp, 136]
	cmp	w27, w0
	bge	.L95
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
	b	.L128
.L126:
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
	bge	.L375
.L128:
	ldr	x0, [sp, 312]
	ldr	w1, [sp, 136]
	ldr	x0, [x0, 16]
	sub	w6, w1, w20
	ldr	x3, [x0]
	cbz	x3, .L376
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L147:
	cmp	w6, 7
	bgt	.L126
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
.L131:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w18, w23
	bge	.L130
	ldr	w1, [sp, 132]
	cmp	w1, w24
	ble	.L200
	ldr	x1, [sp, 144]
	mov	x10, x3
	mov	x16, x8
	mov	x15, 0
	sub	x20, x5, x1
	mov	w1, w24
	stp	x25, x27, [sp, 184]
	stp	x5, x22, [sp, 200]
	str	w4, [sp, 216]
	b	.L140
	.p2align 2,,3
.L201:
	mov	w1, w2
.L140:
	ldr	w2, [sp, 224]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x5, x4, x19
	cmp	w2, 2
	bls	.L377
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
	cbz	w5, .L145
.L146:
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
	beq	.L138
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
	tbz	x13, 0, .L145
.L138:
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
.L145:
	ldr	x4, [sp, 240]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x10, x10, x4
	ldr	x4, [sp, 232]
	add	x15, x15, x4
	add	x16, x16, x4
	ldr	w4, [sp, 132]
	cmp	w2, w4
	blt	.L201
	ldp	x25, x27, [sp, 184]
	add	w1, w1, 1
	ldp	x5, x22, [sp, 200]
	ldr	w4, [sp, 216]
.L136:
	sxtw	x13, w1
	ldr	x1, [sp, 176]
	sub	x14, x13, x1
	mul	x10, x8, x14
	madd	x14, x14, x7, x3
	.p2align 3,,7
.L144:
	ldr	d0, [x5, x13, lsl 3]
	cmp	w6, 1
	beq	.L202
	ldr	q2, [x14]
	sxtw	x1, w11
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w4, 1
	bls	.L142
	ldr	q2, [x14, 16]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w4, 3
	bne	.L142
	ldr	q2, [x14, 32]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
.L142:
	cbz	w9, .L143
.L141:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L143:
	add	x13, x13, 1
	add	x10, x10, x8
	add	x14, x14, x7
	cmp	w23, w13
	bgt	.L144
.L130:
	cmp	w6, 1
	beq	.L199
	ldr	q0, [x17]
	ldr	q1, [sp, 768]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17]
	cmp	w4, 1
	bls	.L134
	ldr	q0, [x17, 16]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 16]
	cmp	w4, 3
	bne	.L134
	ldr	q0, [x17, 32]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 32]
.L134:
	sxtw	x1, w11
	cbz	w9, .L135
.L133:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x25, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x25, x2, lsl 3]
.L135:
	ldr	x1, [sp, 120]
	add	x12, x12, x22
	add	x19, x19, x27
	subs	w26, w26, #1
	add	x17, x17, x1
	ldr	x1, [sp, 160]
	add	x5, x5, x1
	bne	.L131
	ldr	x10, [sp, 528]
	ldr	x13, [sp, 536]
	add	x10, x10, 8
	ldr	w20, [sp, 504]
	ldr	w0, [sp, 136]
	add	x13, x13, 64
	add	w20, w20, 8
	cmp	w20, w0
	blt	.L128
.L375:
	ldp	x1, x14, [sp, 280]
	mov	x26, x27
	ldr	x15, [sp, 296]
	ldr	x21, [sp, 472]
	ldr	x22, [sp, 488]
	ldr	w27, [sp, 352]
	ldr	w19, [sp, 464]
	ldr	w4, [sp, 480]
.L95:
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
	bgt	.L123
	mov	x18, x26
	ldr	w15, [sp, 344]
	mov	w26, w19
	mov	w23, w24
	b	.L93
	.p2align 2,,3
.L202:
	mov	x1, 0
	b	.L141
.L199:
	mov	x1, 0
	b	.L133
.L200:
	ldr	w1, [sp, 268]
	b	.L136
.L377:
	mov	w13, 0
	mov	w2, 0
	b	.L146
.L376:
	ldr	x0, [sp, 288]
	mov	x8, x22
	ldr	w4, [sp, 256]
	add	x3, x13, x0
	b	.L147
.L362:
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
.L23:
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
.L88:
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
	b	.L183
.L368:
	.cfi_offset 72, -928
	ldr	w0, [sp, 264]
	add	w15, w15, 64
	mov	w27, 0
	sub	w0, w0, w15
	str	w0, [sp, 524]
	b	.L151
.L194:
	mov	w26, w15
.L93:
	add	w0, w26, 7
	cmp	w4, w0
	ble	.L92
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
.L97:
	ldr	w0, [sp, 136]
	cmp	w27, w0
	bge	.L103
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
	b	.L102
.L100:
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
	bge	.L378
.L102:
	ldr	x0, [sp, 312]
	ldr	w2, [sp, 136]
	ldr	x0, [x0, 16]
	sub	w5, w2, w20
	ldr	x3, [x0]
	cbz	x3, .L379
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L122:
	cmp	w5, 7
	bgt	.L100
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
.L106:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w30, w24
	bge	.L105
	cmp	w13, w28
	ble	.L196
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
	b	.L115
.L197:
	mov	w1, w2
.L115:
	ldr	w2, [sp, 208]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x11, x4, x19
	cmp	w2, 2
	bls	.L380
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
	cbz	w26, .L120
.L121:
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
	beq	.L113
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
	tbz	x12, 0, .L120
.L113:
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
.L120:
	ldr	x4, [sp, 216]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x15, x15, x18
	add	x16, x16, x18
	add	x10, x10, x4
	cmp	w2, w13
	blt	.L197
	ldp	x23, x22, [sp, 224]
	add	w1, w1, 1
	ldr	x4, [sp, 288]
	ldr	x12, [sp, 304]
	ldr	w11, [sp, 240]
	ldr	w17, [sp, 280]
	ldr	w24, [sp, 296]
.L111:
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
.L119:
	ldr	d0, [x21, x15, lsl 3]
	cmp	w5, 1
	beq	.L198
	ldr	q2, [x16]
	sxtw	x1, w11
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w20, 1
	bls	.L117
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w20, 3
	bne	.L117
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
.L117:
	cbz	w25, .L118
.L116:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L118:
	add	x15, x15, 1
	add	x10, x10, x23
	add	x16, x16, x7
	cmp	w24, w15
	bgt	.L119
	ldp	x23, x25, [sp, 232]
	ldr	w21, [sp, 224]
.L105:
	cmp	w5, 1
	beq	.L195
	ldr	q0, [x14]
	ldr	q1, [sp, 768]
	ldr	w1, [sp, 184]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14]
	cmp	w1, 1
	bls	.L109
	ldr	q0, [x14, 16]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 16]
	cmp	w1, 3
	bne	.L109
	ldr	q0, [x14, 32]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 32]
.L109:
	ldr	w1, [sp, 192]
	cbz	w1, .L110
	sxtw	x1, w11
.L108:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x23, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x23, x2, lsl 3]
.L110:
	ldp	x2, x1, [sp, 160]
	add	x19, x19, x22
	subs	w17, w17, #1
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	add	x14, x14, x1
	ldr	x1, [sp, 152]
	add	x1, x1, x2
	str	x1, [sp, 152]
	bne	.L106
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
	blt	.L102
.L378:
	ldr	x19, [sp, 504]
	mov	x18, x22
	ldr	x22, [sp, 528]
	mov	x2, x10
	ldr	w27, [sp, 472]
	ldr	w4, [sp, 488]
	ldr	w26, [sp, 536]
	ldr	w21, [sp, 548]
.L103:
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
	bne	.L97
	ldr	w24, [sp, 480]
	mov	w0, w28
	ldr	w2, [sp, 464]
	mov	x28, x25
	and	w24, w24, -8
	mov	x25, x23
	ldr	w15, [sp, 352]
	mov	w23, w0
	add	w26, w24, w2
	b	.L92
.L198:
	mov	x1, 0
	b	.L116
.L195:
	mov	x1, 0
	b	.L108
.L196:
	ldr	w1, [sp, 268]
	b	.L111
.L379:
	ldr	x8, [sp, 168]
	add	x3, x13, x10
	ldr	w4, [sp, 256]
	b	.L122
.L380:
	mov	w12, 0
	mov	w2, 0
	b	.L121
.L360:
	.cfi_restore 72
	str	d8, [sp, 96]
	.cfi_offset 72, -928
	b	.L186
.L190:
	mov	w12, 0
	b	.L71
	.p2align 2,,3
.L185:
	.cfi_restore 72
	bl	GOMP_barrier
	b	.L87
	.cfi_endproc
.LFE4371:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4372:
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
	ldr	x2, [x3]
	stp	x23, x24, [sp, 48]
	stp	x27, x28, [sp, 80]
	.cfi_offset 23, -544
	.cfi_offset 24, -536
	.cfi_offset 27, -512
	.cfi_offset 28, -504
	ldp	w28, w24, [x3, 16]
	stp	x19, x20, [sp, 16]
	str	x2, [sp, 176]
	ldr	x2, [x3, 8]
	.cfi_offset 19, -576
	.cfi_offset 20, -568
	sbfiz	x20, x28, 6, 32
	stp	x21, x22, [sp, 32]
	stp	x25, x26, [sp, 64]
	.cfi_offset 21, -560
	.cfi_offset 22, -552
	.cfi_offset 25, -528
	.cfi_offset 26, -520
	ldp	w25, w21, [x3, 24]
	str	x2, [sp, 216]
	mov	x2, x20
	bl	posix_memalign
	ldr	x22, [sp, 328]
	cmp	w0, 0
	csel	x22, xzr, x22, ne
	bl	omp_get_num_threads
	mov	w19, w0
	bl	omp_get_thread_num
	mov	w3, w0
	add	w1, w24, 14
	adds	w2, w24, 7
	csel	w0, w1, w2, mi
	asr	w0, w0, 3
	sdiv	w1, w0, w19
	msub	w0, w1, w19, w0
	cmp	w3, w0
	blt	.L383
.L424:
	madd	w0, w1, w3, w0
	add	w3, w1, w0
	cmp	w0, w3
	bge	.L384
	lsl	w6, w0, 3
	sxtw	x19, w25
	ldr	x0, [sp, 176]
	mov	w2, 24
	lsl	x1, x19, 3
	add	x8, x19, 1
	add	x15, x0, x1
	smnegl	x0, w2, w25
	lsl	w2, w3, 3
	add	x16, x15, x1
	str	w2, [sp, 312]
	add	x2, x20, x22
	lsl	x4, x8, 5
	str	x2, [sp, 192]
	add	x2, x16, x1
	str	x2, [sp, 256]
	sub	x2, x4, #32
	str	x2, [sp, 264]
	lsl	x2, x8, 2
	str	x2, [sp, 160]
	add	x2, x1, 8
	str	x2, [sp, 184]
	sxtw	x2, w6
	str	x2, [sp, 200]
	ldr	x2, [sp, 216]
	sbfiz	x23, x25, 1, 32
	str	x0, [sp, 168]
	sub	w0, w24, w6
	add	x20, x23, x19
	mov	w27, w0
	add	x7, x2, w6, sxtw 3
	sxtw	x2, w21
	sbfiz	x21, x21, 3, 32
	str	w6, [sp, 228]
	str	x4, [sp, 240]
	str	x2, [sp, 248]
	stp	x15, x8, [sp, 272]
	stp	x16, x1, [sp, 288]
	stp	d8, d9, [sp, 96]
	.cfi_offset 73, -488
	.cfi_offset 72, -496
	stp	d10, d11, [sp, 112]
	.cfi_offset 75, -472
	.cfi_offset 74, -480
	str	d12, [sp, 128]
	.cfi_offset 76, -464
.L387:
	cmp	w27, 8
	mov	w0, 8
	csel	w6, w27, w0, le
	cbz	x22, .L471
	cmp	w28, 0
	ble	.L388
	sub	w0, w6, #1
	mov	w1, 7
	add	x0, x0, 1
	sub	w1, w1, w6
	add	x1, x1, 1
	cmp	w27, 0
	lsl	x0, x0, 3
	mov	x3, 8
	csel	x0, x0, x3, gt
	lsl	x1, x1, 3
	stp	x0, x1, [sp, 144]
	mov	x0, x19
	sbfiz	x24, x6, 3, 32
	str	w28, [sp, 208]
	mov	x25, x7
	ldr	x28, [sp, 192]
	mov	x19, x22
	mov	x26, x0
	str	x7, [sp, 232]
.L418:
	ldr	x2, [sp, 144]
	mov	x1, x25
	mov	x0, x19
	cmp	w27, 0
	ble	.L390
	bl	memcpy
	cmp	w27, 7
	bgt	.L472
.L390:
	ldr	x2, [sp, 152]
	add	x0, x19, x24
	add	x25, x25, x21
	add	x19, x19, 64
	mov	w1, 0
	bl	memset
	cmp	x28, x19
	bne	.L418
	ldr	x7, [sp, 232]
	mov	x19, x26
	ldr	w28, [sp, 208]
.L416:
	ldr	x1, [sp, 176]
	mov	w5, w28
	ldr	x13, [sp, 256]
	str	w28, [sp, 152]
	ldr	x28, [sp, 264]
	str	x21, [sp, 304]
	ldr	x21, [sp, 240]
	mov	x4, x22
	ldr	x26, [sp, 272]
	add	x6, sp, 336
	ldr	x18, [sp, 288]
	str	w27, [sp, 316]
	movi	v17.4s, 0
	mov	x27, x19
	mov	x30, x1
	mov	x0, x1
	mov	w25, 2
	add	x1, x1, 8
	mov	w24, 1
	mov	x10, 0
	str	x1, [sp, 208]
	str	x7, [sp, 232]
.L394:
	cmp	w5, 3
	bgt	.L473
	stp	q17, q17, [x6]
	stp	q17, q17, [x6, 32]
	stp	q17, q17, [x6, 64]
	stp	q17, q17, [x6, 96]
	stp	q17, q17, [x6, 128]
	stp	q17, q17, [x6, 160]
	stp	q17, q17, [x6, 192]
	stp	q17, q17, [x6, 224]
	cbz	w10, .L396
	movi	v5.2d, 0
	uxtw	x7, w24
	uxtw	x8, w25
	sub	x7, x7, x10
	sub	x8, x8, x10
	mov	x1, x22
	mov	x3, x0
	mov	w2, 0
	mul	x7, x7, x19
	mov	w9, 0
	mul	x8, x8, x19
	mov	w12, 0
	mov	v24.16b, v5.16b
	mov	w11, 0
	mov	v23.16b, v5.16b
	mov	w17, 0
	mov	v22.16b, v5.16b
	mov	w16, 0
	mov	v27.16b, v5.16b
	mov	w15, 0
	mov	v26.16b, v5.16b
	mov	w14, 0
	mov	v25.16b, v5.16b
	mov	v8.16b, v5.16b
	mov	v18.16b, v5.16b
	mov	v16.16b, v5.16b
	mov	v7.16b, v5.16b
	mov	v6.16b, v5.16b
	.p2align 3,,7
.L411:
	ldp	q4, q3, [x1]
	ldp	q2, q1, [x1, 32]
	ld1r	{v0.2d}, [x3]
	fmul	v21.2d, v0.2d, v4.2d
	fmul	v20.2d, v0.2d, v3.2d
	fmul	v19.2d, v0.2d, v2.2d
	fmul	v0.2d, v0.2d, v1.2d
	fadd	v6.2d, v6.2d, v21.2d
	fadd	v7.2d, v7.2d, v20.2d
	fadd	v16.2d, v16.2d, v19.2d
	fadd	v18.2d, v18.2d, v0.2d
	cmp	w5, 1
	ble	.L397
	ldr	d0, [x3, x7, lsl 3]
	mov	w2, 1
	mov	w9, w2
	mov	w12, w2
	mov	w11, w2
	fmul	v21.2d, v4.2d, v0.d[0]
	fmul	v20.2d, v3.2d, v0.d[0]
	fmul	v19.2d, v2.2d, v0.d[0]
	fmul	v0.2d, v1.2d, v0.d[0]
	fadd	v22.2d, v22.2d, v21.2d
	fadd	v23.2d, v23.2d, v20.2d
	fadd	v24.2d, v24.2d, v19.2d
	fadd	v5.2d, v5.2d, v0.2d
	cmp	w5, 3
	bne	.L397
	ldr	d0, [x3, x8, lsl 3]
	mov	w17, w2
	mov	w16, w2
	mov	w15, w2
	mov	w14, w2
	fmul	v4.2d, v4.2d, v0.d[0]
	fmul	v3.2d, v3.2d, v0.d[0]
	fmul	v2.2d, v2.2d, v0.d[0]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v8.2d, v8.2d, v4.2d
	fadd	v25.2d, v25.2d, v3.2d
	fadd	v26.2d, v26.2d, v2.2d
	fadd	v27.2d, v27.2d, v1.2d
.L397:
	add	x1, x1, 64
	add	x3, x3, 8
	cmp	x4, x1
	bne	.L411
	stp	q6, q7, [sp, 336]
	stp	q16, q18, [sp, 368]
	cbz	w2, .L399
	str	q5, [sp, 448]
.L399:
	cbz	w9, .L400
	str	q24, [sp, 432]
.L400:
	cbz	w12, .L401
	str	q23, [sp, 416]
.L401:
	cbz	w11, .L402
	str	q22, [sp, 400]
.L402:
	cbz	w17, .L403
	str	q27, [sp, 512]
.L403:
	cbz	w16, .L404
	str	q26, [sp, 496]
.L404:
	cbz	w15, .L405
	str	q25, [sp, 480]
.L405:
	cbz	w14, .L396
	str	q8, [sp, 464]
.L396:
	ldr	x1, [sp, 168]
	ldp	q4, q3, [x4]
	ldp	q2, q1, [x4, 32]
	ldp	q8, q7, [sp, 336]
	ldp	q6, q5, [sp, 368]
	fsub	v4.2d, v4.2d, v8.2d
	ldr	d0, [x13, x1]
	fsub	v3.2d, v3.2d, v7.2d
	fsub	v2.2d, v2.2d, v6.2d
	dup	v0.2d, v0.d[0]
	fsub	v1.2d, v1.2d, v5.2d
	fdiv	v4.2d, v4.2d, v0.2d
	fdiv	v3.2d, v3.2d, v0.2d
	fdiv	v2.2d, v2.2d, v0.2d
	fdiv	v0.2d, v1.2d, v0.2d
	stp	q4, q3, [x4]
	stp	q2, q0, [x4, 32]
	cmp	w5, 1
	beq	.L415
	add	x12, x10, 1
	mov	x2, x6
	ldr	x14, [sp, 176]
	mov	x1, x4
	mov	x8, x27
	add	x12, x22, x12, lsl 6
	mov	x7, x26
	add	x11, x22, x10, lsl 6
	mov	w3, 1
	mov	w9, 0
	b	.L407
	.p2align 2,,3
.L410:
	add	x2, x2, 64
	add	x8, x8, x19
	cmp	w3, 3
	bne	.L426
	ldp	q1, q0, [x4]
	mov	w9, 2
	ldr	d5, [x14, x8, lsl 3]
	ldp	q3, q2, [x2, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldr	x15, [sp, 208]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	ldr	d4, [x15, x8, lsl 3]
	ldp	q7, q6, [x2, 96]
	stp	q1, q0, [x2, 64]
	ldp	q3, q2, [x4, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x2, 64]
	ldp	q1, q0, [x4, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x2, 96]
	ldp	q3, q2, [x4, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x2, 96]
.L408:
	add	x1, x1, 64
	ldr	x15, [sp, 184]
	add	x7, x7, x15
.L407:
	ldr	q0, [x11]
	add	w9, w9, 1
	ldr	d4, [x14, x8, lsl 3]
	ldp	q1, q2, [x2, 64]
	fmul	v0.2d, v0.2d, v4.d[0]
	ldp	q6, q5, [x2, 96]
	fadd	v1.2d, v0.2d, v1.2d
	str	q1, [x2, 64]
	ldr	q3, [x11, 16]
	fmul	v3.2d, v3.2d, v4.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x2, 80]
	ldr	q2, [x11, 32]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	str	q2, [x2, 96]
	ldr	q0, [x11, 48]
	fmul	v0.2d, v0.2d, v4.d[0]
	fadd	v0.2d, v0.2d, v5.2d
	str	q0, [x2, 112]
	cmp	w3, w9
	ble	.L409
	add	x9, x8, 1
	ldr	q4, [x12]
	ldr	d5, [x14, x9, lsl 3]
	fmul	v4.2d, v4.2d, v5.d[0]
	fadd	v1.2d, v4.2d, v1.2d
	str	q1, [x2, 64]
	ldr	q4, [x12, 16]
	fmul	v4.2d, v4.2d, v5.d[0]
	fadd	v3.2d, v4.2d, v3.2d
	str	q3, [x2, 80]
	ldr	q3, [x12, 32]
	fmul	v3.2d, v3.2d, v5.d[0]
	fadd	v2.2d, v3.2d, v2.2d
	str	q2, [x2, 96]
	ldr	q2, [x12, 48]
	fmul	v2.2d, v2.2d, v5.d[0]
	fadd	v0.2d, v2.2d, v0.2d
	str	q0, [x2, 112]
.L409:
	ldr	d0, [x7, 8]
	ldp	q4, q3, [x1, 64]
	add	w3, w3, 1
	dup	v0.2d, v0.d[0]
	ldr	q2, [x1, 96]
	fsub	v4.2d, v4.2d, v1.2d
	ldr	q1, [x1, 112]
	fdiv	v4.2d, v4.2d, v0.2d
	str	q4, [x1, 64]
	ldr	q4, [x2, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v0.2d
	str	q3, [x1, 80]
	ldr	q3, [x2, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x1, 96]
	ldr	q2, [x2, 112]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q0, [x1, 112]
	cmp	w5, w3
	bne	.L410
.L415:
	ldr	x1, [sp, 160]
	add	x10, x10, 4
	sub	w5, w5, #4
	add	x4, x4, 256
	add	x27, x27, x1
	ldr	w1, [sp, 152]
	add	x26, x26, x21
	add	w24, w24, 4
	add	x18, x18, x21
	add	w25, w25, 4
	add	x13, x13, x21
	add	x30, x30, x28
	add	x0, x0, x28
	cmp	w1, w10
	bgt	.L394
	ldr	w27, [sp, 316]
	ldr	x7, [sp, 232]
	ldr	x21, [sp, 304]
	ldr	w28, [sp, 152]
	cmp	w27, 0
	ble	.L388
	ldr	x25, [sp, 192]
	mov	x0, x19
	mov	x3, x7
	mov	x26, x7
	mov	x19, x22
	mov	x24, x0
.L391:
	ldr	x2, [sp, 144]
	mov	x1, x19
	mov	x0, x3
	add	x19, x19, 64
	bl	memcpy
	add	x3, x0, x21
	cmp	x25, x19
	bne	.L391
	mov	x7, x26
	mov	x19, x24
.L388:
	ldr	x1, [sp, 200]
	sub	w27, w27, #8
	ldr	w0, [sp, 228]
	add	x7, x7, 64
	add	x1, x1, 8
	str	x1, [sp, 200]
	ldr	w1, [sp, 312]
	add	w0, w0, 8
	str	w0, [sp, 228]
	cmp	w1, w0
	bgt	.L387
	ldp	d8, d9, [sp, 96]
	.cfi_restore 73
	.cfi_restore 72
	ldp	d10, d11, [sp, 112]
	.cfi_restore 75
	.cfi_restore 74
	ldr	d12, [sp, 128]
	.cfi_restore 76
.L384:
	bl	GOMP_barrier
	ldp	x29, x30, [sp]
	mov	x0, x22
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 592
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
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	b	free
.L473:
	.cfi_def_cfa_offset 592
	.cfi_offset 19, -576
	.cfi_offset 20, -568
	.cfi_offset 21, -560
	.cfi_offset 22, -552
	.cfi_offset 23, -544
	.cfi_offset 24, -536
	.cfi_offset 25, -528
	.cfi_offset 26, -520
	.cfi_offset 27, -512
	.cfi_offset 28, -504
	.cfi_offset 29, -592
	.cfi_offset 30, -584
	.cfi_offset 72, -496
	.cfi_offset 73, -488
	.cfi_offset 74, -480
	.cfi_offset 75, -472
	.cfi_offset 76, -464
	movi	v16.2d, 0
	cbz	w10, .L427
	mov	v18.16b, v16.16b
	mov	x2, x30
	mov	v19.16b, v16.16b
	mov	x1, x22
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
.L414:
	ldp	q4, q3, [x1]
	ldp	q2, q0, [x1, 32]
	add	x1, x1, 64
	ldr	d6, [x2, x19, lsl 3]
	ldr	d5, [x2, x23, lsl 3]
	ldr	d1, [x2, x20, lsl 3]
	fmla	v28.2d, v4.2d, v6.d[0]
	ld1r	{v7.2d}, [x2]
	fmla	v27.2d, v3.2d, v6.d[0]
	add	x2, x2, 8
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
	cmp	x1, x4
	bne	.L414
.L413:
	ldr	x1, [sp, 168]
	ubfiz	x9, x24, 6, 32
	ldp	q3, q2, [x4]
	add	x3, x22, x9
	ldr	d5, [x13, x1]
	ubfiz	x8, x25, 6, 32
	ldp	q1, q0, [x4, 32]
	add	x2, x22, x8
	fsub	v3.2d, v3.2d, v8.2d
	ld1r	{v4.2d}, [x26]
	dup	v8.2d, v5.d[0]
	ldr	d6, [x26, 8]
	fsub	v2.2d, v2.2d, v31.2d
	ld1r	{v31.2d}, [x18]
	fsub	v1.2d, v1.2d, v30.2d
	ldr	d7, [x18, 8]
	fsub	v0.2d, v0.2d, v29.2d
	ld1r	{v29.2d}, [x13]
	fdiv	v3.2d, v3.2d, v8.2d
	dup	v30.2d, v6.d[0]
	ldr	d5, [x18, 16]
	ldr	d6, [x13, 8]
	add	w7, w10, 3
	fdiv	v2.2d, v2.2d, v8.2d
	dup	v5.2d, v5.d[0]
	lsl	x7, x7, 6
	add	x1, x22, x7
	fdiv	v1.2d, v1.2d, v8.2d
	fdiv	v0.2d, v0.2d, v8.2d
	fmul	v11.2d, v3.2d, v4.2d
	fmul	v9.2d, v3.2d, v31.2d
	fmul	v10.2d, v2.2d, v4.2d
	stp	q3, q2, [x4]
	fadd	v11.2d, v11.2d, v28.2d
	fmul	v12.2d, v1.2d, v4.2d
	fadd	v10.2d, v10.2d, v27.2d
	fmul	v3.2d, v3.2d, v29.2d
	fmul	v4.2d, v0.2d, v4.2d
	stp	q1, q0, [x4, 32]
	ldp	q8, q27, [x3, 16]
	ldr	q28, [x22, x9]
	fadd	v26.2d, v12.2d, v26.2d
	fadd	v4.2d, v4.2d, v25.2d
	fsub	v8.2d, v8.2d, v10.2d
	ldr	q10, [x3, 48]
	fsub	v25.2d, v28.2d, v11.2d
	fsub	v27.2d, v27.2d, v26.2d
	fsub	v4.2d, v10.2d, v4.2d
	fdiv	v8.2d, v8.2d, v30.2d
	fadd	v26.2d, v9.2d, v24.2d
	fmul	v10.2d, v1.2d, v31.2d
	fdiv	v25.2d, v25.2d, v30.2d
	fmul	v1.2d, v1.2d, v29.2d
	fmul	v11.2d, v2.2d, v31.2d
	fdiv	v24.2d, v27.2d, v30.2d
	fmul	v31.2d, v0.2d, v31.2d
	fmul	v0.2d, v0.2d, v29.2d
	fdiv	v4.2d, v4.2d, v30.2d
	fadd	v18.2d, v1.2d, v18.2d
	fmul	v2.2d, v2.2d, v29.2d
	fadd	v16.2d, v0.2d, v16.2d
	fadd	v23.2d, v11.2d, v23.2d
	fadd	v22.2d, v10.2d, v22.2d
	fadd	v31.2d, v31.2d, v21.2d
	fadd	v20.2d, v3.2d, v20.2d
	fadd	v19.2d, v2.2d, v19.2d
	fmul	v0.2d, v8.2d, v7.d[0]
	fmul	v1.2d, v25.2d, v7.d[0]
	str	q25, [x22, x9]
	fadd	v23.2d, v23.2d, v0.2d
	fmul	v9.2d, v24.2d, v7.d[0]
	stp	q8, q24, [x3, 16]
	fadd	v26.2d, v26.2d, v1.2d
	fmul	v7.2d, v4.2d, v7.d[0]
	str	q4, [x3, 48]
	ldr	q3, [x22, x8]
	ldp	q2, q1, [x2, 16]
	fadd	v22.2d, v22.2d, v9.2d
	ldr	q0, [x2, 48]
	fadd	v31.2d, v31.2d, v7.2d
	fsub	v3.2d, v3.2d, v26.2d
	fsub	v2.2d, v2.2d, v23.2d
	fsub	v1.2d, v1.2d, v22.2d
	fsub	v0.2d, v0.2d, v31.2d
	fdiv	v3.2d, v3.2d, v5.2d
	fmul	v8.2d, v8.2d, v6.d[0]
	fmul	v4.2d, v4.2d, v6.d[0]
	fdiv	v2.2d, v2.2d, v5.2d
	fmul	v25.2d, v25.2d, v6.d[0]
	fadd	v19.2d, v19.2d, v8.2d
	fdiv	v1.2d, v1.2d, v5.2d
	fadd	v8.2d, v16.2d, v4.2d
	fmul	v24.2d, v24.2d, v6.d[0]
	fdiv	v0.2d, v0.2d, v5.2d
	fadd	v20.2d, v20.2d, v25.2d
	fadd	v18.2d, v18.2d, v24.2d
	str	q3, [x22, x8]
	stp	q2, q1, [x2, 16]
	str	q0, [x2, 48]
	ldp	d5, d4, [x13, 16]
	ldr	q7, [x22, x7]
	fmul	v3.2d, v3.2d, v5.d[0]
	fmul	v2.2d, v2.2d, v5.d[0]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v20.2d, v20.2d, v3.2d
	ldr	q6, [x1, 16]
	ldp	q5, q3, [x1, 32]
	fadd	v16.2d, v19.2d, v2.2d
	fadd	v2.2d, v18.2d, v1.2d
	fadd	v1.2d, v8.2d, v0.2d
	fsub	v7.2d, v7.2d, v20.2d
	dup	v0.2d, v4.d[0]
	fsub	v2.2d, v5.2d, v2.2d
	fsub	v1.2d, v3.2d, v1.2d
	fsub	v4.2d, v6.2d, v16.2d
	fdiv	v5.2d, v7.2d, v0.2d
	fdiv	v3.2d, v4.2d, v0.2d
	fdiv	v2.2d, v2.2d, v0.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q5, [x22, x7]
	stp	q3, q2, [x1, 16]
	str	q0, [x1, 48]
	b	.L415
.L427:
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
	b	.L413
.L471:
	cmp	w27, 0
	ble	.L388
	cmp	w28, 0
	ble	.L388
	ldr	x9, [sp, 200]
	mov	x8, x7
	ldr	x0, [sp, 280]
	lsl	x10, x19, 3
	ldp	x12, x13, [sp, 176]
	add	x6, x9, w6, uxtw
	ldr	x2, [sp, 296]
	lsl	x11, x0, 3
.L420:
	ldr	d0, [x8]
	ldr	d1, [x12]
	fdiv	d0, d0, d1
	str	d0, [x8]
	cmp	w28, 1
	beq	.L423
	ldr	x0, [sp, 248]
	add	x4, x12, x11
	ldr	x3, [sp, 216]
	add	x0, x0, x9
	add	x5, x12, x10
	mov	w1, 1
	add	x0, x3, x0, lsl 3
.L422:
	movi	d1, #0
	mov	x14, x8
	mov	x3, 0
.L421:
	ldr	d2, [x5, x3, lsl 3]
	add	x3, x3, 1
	ldr	d0, [x14]
	add	x14, x14, x21
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w1, w3
	bgt	.L421
	ldr	d0, [x0]
	add	w1, w1, 1
	ldr	d2, [x4]
	add	x5, x5, x2
	add	x4, x4, x13
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x0]
	add	x0, x0, x21
	cmp	w28, w1
	bne	.L422
.L423:
	add	x9, x9, 1
	add	x8, x8, 8
	cmp	x9, x6
	bne	.L420
	b	.L388
.L383:
	.cfi_restore 72
	.cfi_restore 73
	.cfi_restore 74
	.cfi_restore 75
	.cfi_restore 76
	add	w1, w1, 1
	mov	w0, 0
	b	.L424
.L472:
	.cfi_offset 72, -496
	.cfi_offset 73, -488
	.cfi_offset 74, -480
	.cfi_offset 75, -472
	.cfi_offset 76, -464
	ldr	x7, [sp, 232]
	mov	x0, x26
	ldr	w28, [sp, 208]
	mov	x26, x19
	mov	x24, x7
	mov	x19, x0
	b	.L417
	.p2align 2,,3
.L474:
	ldr	x2, [sp, 144]
	mov	x1, x25
	mov	x0, x26
	bl	memcpy
.L417:
	ldr	x0, [sp, 192]
	add	x26, x26, 64
	add	x25, x25, x21
	cmp	x0, x26
	bne	.L474
	mov	x7, x24
	b	.L416
.L426:
	mov	w9, 0
	b	.L408
	.cfi_endproc
.LFE4372:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4370:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L480
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
	bls	.L477
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	str	xzr, [sp, 64]
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L478
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L478:
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
.L477:
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
.L480:
	ret
	.cfi_endproc
.LFE4370:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (gcc for openEuler 3.0.2) 12.3.1"
	.section	.note.GNU-stack,"",@progbits
