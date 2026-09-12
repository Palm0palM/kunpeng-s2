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
	blt	.L25
.L77:
	madd	w0, w1, w2, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L26
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
.L29:
	ldr	w0, [sp, 188]
	mov	w19, 8
	cmp	w0, 8
	csel	w19, w0, w19, le
	cbz	x25, .L141
	ldr	w0, [sp, 128]
	cmp	w0, 0
	ble	.L30
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
.L68:
	mov	x2, x19
	mov	x1, x25
	mov	x0, x24
	cmp	w28, 0
	ble	.L32
	bl	memcpy
	cmp	w28, 7
	bgt	.L70
.L32:
	mov	x2, x21
	add	x0, x24, x22
	mov	w1, 0
	bl	memset
.L70:
	add	x24, x24, 64
	add	x25, x25, x23
	cmp	x24, x20
	bne	.L68
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
	ble	.L36
	movi	v0.2d, 0
	stp	q0, q0, [sp, 336]
	stp	q0, q0, [sp, 368]
	stp	q0, q0, [sp, 400]
	stp	q0, q0, [sp, 432]
	stp	q0, q0, [sp, 464]
	stp	q0, q0, [sp, 496]
	stp	q0, q0, [sp, 528]
	stp	q0, q0, [sp, 560]
.L36:
	sub	w9, w19, #1
	mov	x3, x27
	add	x0, sp, 336
	mov	x1, x25
	mov	x6, x28
	mov	w2, 0
.L62:
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
	beq	.L142
	add	w7, w2, 1
	cmp	w7, 0
	ble	.L67
	cmp	w2, 1
	ble	.L82
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
.L66:
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
	bge	.L67
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
	ble	.L67
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
.L67:
	add	x6, x6, x26
	add	x1, x1, 64
	add	x0, x0, 64
	add	x3, x3, x27
	mov	w2, w7
	b	.L62
.L142:
	ldr	w1, [sp, 128]
	cmp	w1, 4
	ble	.L37
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
.L61:
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
	ble	.L143
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
.L55:
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
	bgt	.L55
	stp	q31, q30, [sp, 336]
	stp	q29, q28, [sp, 368]
	stp	q27, q26, [sp, 400]
	stp	q25, q24, [sp, 432]
	stp	q23, q22, [sp, 464]
	stp	q21, q20, [sp, 496]
	stp	q19, q18, [sp, 528]
	stp	q17, q16, [sp, 560]
.L40:
	ldr	w0, [sp, 184]
	ldp	x5, x4, [sp, 104]
	sub	w14, w0, #1
	mov	x1, x19
	add	x0, sp, 336
	mov	w3, 0
.L58:
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
	beq	.L56
	add	w7, w3, 1
	cmp	w7, 0
	ble	.L60
	cmp	w3, 1
	ble	.L81
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
.L59:
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
	bge	.L60
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
	bge	.L60
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
.L60:
	add	x5, x5, x10
	add	x1, x1, 64
	add	x0, x0, 64
	add	x4, x4, x27
	mov	w3, w7
	b	.L58
.L56:
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
	blt	.L61
	ldr	x23, [sp, 312]
	mov	x26, x10
	mov	x24, x13
.L37:
	ldr	w0, [sp, 188]
	cmp	w0, 0
	ble	.L30
	ldr	x3, [sp, 192]
	mov	x19, x25
	ldr	x21, [sp, 216]
	ldr	x20, [sp, 232]
.L34:
	mov	x1, x19
	mov	x0, x3
	mov	x2, x20
	add	x19, x19, 64
	bl	memcpy
	add	x3, x0, x23
	cmp	x19, x21
	bne	.L34
.L30:
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
	bgt	.L29
.L26:
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
.L143:
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
	b	.L42
	.p2align 2,,3
.L145:
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
	ble	.L80
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
.L41:
	add	x1, x1, 64
	add	x2, x2, 8
	cmp	x5, x1
	beq	.L144
.L42:
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
	beq	.L41
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
	bne	.L145
	add	x1, x1, 64
	mov	w3, 1
	add	x2, x2, 8
	mov	w8, w3
	mov	w14, w3
	mov	w15, w3
	cmp	x5, x1
	bne	.L42
.L144:
	stp	q16, q7, [sp, 336]
	stp	q6, q5, [sp, 368]
	cbz	w30, .L43
	str	q24, [sp, 528]
.L43:
	cbz	w12, .L44
	str	q27, [sp, 544]
.L44:
	cbz	w11, .L45
	str	q26, [sp, 560]
.L45:
	cbz	w9, .L46
	str	q25, [sp, 576]
.L46:
	cbz	w15, .L47
	str	q20, [sp, 400]
.L47:
	cbz	w14, .L48
	str	q19, [sp, 416]
.L48:
	cbz	w8, .L49
	str	q18, [sp, 432]
.L49:
	cbz	w3, .L50
	str	q17, [sp, 448]
.L50:
	cbz	w18, .L51
	str	q23, [sp, 464]
.L51:
	cbz	w17, .L52
	str	q22, [sp, 480]
.L52:
	cbz	w16, .L53
	str	q21, [sp, 496]
.L53:
	cbz	w0, .L40
	str	q4, [sp, 512]
	b	.L40
	.p2align 2,,3
.L80:
	mov	w0, 1
	mov	w16, w0
	mov	w17, w0
	mov	w18, w0
	mov	w3, w0
	mov	w8, w0
	mov	w14, w0
	mov	w15, w0
	b	.L41
.L82:
	mov	w4, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L66
.L81:
	mov	w2, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L59
.L141:
	ldr	w0, [sp, 224]
	add	w19, w0, w19
	cmp	w0, w19
	bge	.L30
	ldr	w7, [sp, 128]
	cmp	w7, 0
	ble	.L30
	ldr	x8, [sp, 192]
	ldr	x9, [sp, 208]
.L75:
	ldr	d0, [x8]
	ldr	d1, [x28]
	fdiv	d0, d0, d1
	str	d0, [x8]
	cmp	w7, 1
	beq	.L72
	ldp	x5, x2, [sp, 264]
	add	x3, x8, x23
	mov	x6, x27
	mov	w4, 1
	.p2align 3,,7
.L74:
	movi	d1, #0
	add	x1, x28, x6, lsl 3
	mov	x0, x8
	.p2align 3,,7
.L73:
	ldr	d2, [x0]
	add	x0, x0, x23
	ldr	d0, [x1], 8
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	x2, x1
	bne	.L73
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
	bne	.L74
.L72:
	add	x9, x9, 1
	add	x8, x8, 8
	cmp	w19, w9
	bgt	.L75
	b	.L30
.L25:
	add	w1, w1, 1
	mov	w0, 0
	b	.L77
	.cfi_endproc
.LFE4287:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4286:
	.cfi_startproc
	sub	sp, sp, #880
	.cfi_def_cfa_offset 880
	stp	x29, x30, [sp]
	.cfi_offset 29, -880
	.cfi_offset 30, -872
	mov	x29, sp
	stp	x25, x26, [sp, 64]
	.cfi_offset 25, -816
	.cfi_offset 26, -808
	ldp	x2, x25, [x0]
	stp	x0, x2, [sp, 192]
	ldr	w2, [x0, 24]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -864
	.cfi_offset 20, -856
	ldp	w20, w1, [x0, 36]
	str	w2, [sp, 112]
	ldr	w2, [x0, 28]
	str	w2, [sp, 176]
	ldr	w2, [x0, 32]
	str	w2, [sp, 108]
	str	w1, [sp, 116]
	cbz	w1, .L279
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	csinc	w0, w0, wzr, eq
	str	w0, [sp, 116]
.L279:
	ldr	w0, [sp, 112]
	cmp	w0, 0
	ble	.L146
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -840
	.cfi_offset 21, -848
	mov	x26, x25
	add	x21, sp, 624
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -824
	.cfi_offset 23, -832
	mov	x24, 0
	mov	x25, x24
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -792
	.cfi_offset 27, -800
	bl	omp_get_num_threads
	mov	w19, w0
	str	w0, [sp, 416]
	bl	omp_get_thread_num
	ldr	w3, [sp, 176]
	mov	w11, w0
	sxtw	x6, w20
	ldr	w8, [sp, 108]
	adds	w2, w3, 7
	add	w1, w3, 14
	csel	w0, w1, w2, mi
	add	x1, x6, 1
	mov	w2, 24
	sxtw	x7, w8
	asr	w0, w0, 3
	lsl	x9, x1, 4
	smull	x2, w20, w2
	add	x14, x9, 16
	stp	x9, x14, [sp, 248]
	add	x9, x9, 32
	add	x5, x7, 1
	sdiv	w1, w0, w19
	str	x9, [sp, 264]
	ldr	x12, [sp, 200]
	add	x9, x2, 16
	str	x9, [sp, 272]
	add	x9, x2, 32
	add	x2, x2, 48
	lsl	x10, x7, 3
	add	x4, x12, 8
	stp	x9, x2, [sp, 280]
	lsl	x2, x5, 11
	msub	w0, w1, w19, w0
	str	x2, [sp, 528]
	add	x2, x4, x10
	sbfiz	x13, x8, 1, 32
	str	x2, [sp, 328]
	add	x2, x10, 8
	cmp	w11, w0
	str	x2, [sp, 312]
	add	x2, x13, x7
	cinc	w1, w1, lt
	str	x2, [sp, 440]
	lsl	x2, x6, 8
	str	x2, [sp, 520]
	lsl	x2, x7, 8
	str	x2, [sp, 536]
	neg	x2, x6, lsl 8
	str	x2, [sp, 544]
	mul	w2, w1, w11
	lsl	x4, x7, 5
	str	x4, [sp, 376]
	add	w0, w2, w0
	lsl	x4, x7, 7
	csel	w0, w2, w0, lt
	lsl	x2, x7, 6
	add	w1, w1, w0
	str	w0, [sp, 372]
	lsl	w0, w0, 3
	str	x4, [sp, 456]
	neg	x4, x6, lsl 7
	sbfiz	x8, x20, 3, 32
	str	x7, [sp, 128]
	add	w3, w3, 63
	stp	x10, x6, [sp, 144]
	mov	w27, w20
	str	x8, [sp, 216]
	str	w11, [sp, 360]
	str	w1, [sp, 364]
	lsl	w1, w1, 3
	str	x13, [sp, 432]
	str	x2, [sp, 480]
	neg	x2, x6, lsl 6
	str	x4, [sp, 552]
	lsl	x4, x6, 7
	str	x4, [sp, 472]
	str	x2, [sp, 560]
	lsl	x2, x6, 6
	str	w0, [sp, 420]
	sxtw	x0, w0
	str	x0, [sp, 512]
	lsl	x0, x6, 5
	str	x0, [sp, 496]
	asr	w0, w3, 6
	str	w0, [sp, 368]
	add	x0, x8, 16
	str	x0, [sp, 224]
	add	x0, x8, 32
	str	xzr, [sp, 168]
	str	x0, [sp, 232]
	add	x0, x8, 48
	str	x0, [sp, 240]
	str	x12, [sp, 320]
	str	xzr, [sp, 336]
	stp	xzr, xzr, [sp, 344]
	str	x2, [sp, 448]
	str	w1, [sp, 600]
	neg	x1, x6, lsl 5
	str	x1, [sp, 568]
	b	.L194
.L426:
	cmp	w0, w1
	bgt	.L283
.L150:
	bl	GOMP_barrier
	ldr	w0, [sp, 112]
	cmp	w0, w28
	ble	.L196
	ldr	w0, [sp, 112]
	add	w1, w0, 63
	subs	w1, w1, w28
	add	w0, w1, 63
	csel	w0, w0, w1, mi
	ldr	w1, [sp, 176]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L196
	ldr	w1, [sp, 368]
	ldr	w2, [sp, 416]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	ldr	w2, [sp, 360]
	cmp	w2, w0
	bcc	.L197
.L278:
	ldr	w2, [sp, 360]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L424
.L196:
	bl	GOMP_barrier
	add	x25, x25, 256
	ldr	x1, [sp, 168]
	ldr	x0, [sp, 520]
	ldr	x2, [sp, 320]
	add	x1, x1, x0
	str	x1, [sp, 168]
	ldr	x1, [sp, 528]
	add	x2, x2, x1
	str	x2, [sp, 320]
	ldr	x2, [sp, 328]
	add	x1, x2, x1
	str	x1, [sp, 328]
	ldr	x1, [sp, 336]
	ldr	x2, [sp, 536]
	add	x1, x1, x2
	str	x1, [sp, 336]
	ldr	x1, [sp, 344]
	ldr	x2, [sp, 544]
	add	x1, x1, x2
	str	x1, [sp, 344]
	ldr	x1, [sp, 352]
	add	x0, x1, x0
	str	x0, [sp, 352]
	ldr	w0, [sp, 112]
	cmp	w0, w25
	ble	.L425
.L194:
	ldr	w0, [sp, 112]
	add	w28, w25, 256
	str	w25, [sp, 140]
	str	w25, [sp, 160]
	sub	w0, w0, w25
	cmp	w0, 255
	ldr	w1, [sp, 372]
	ldr	w0, [sp, 364]
	bgt	.L426
	cmp	w0, w1
	ble	.L282
	ldr	w28, [sp, 112]
.L283:
	ldr	x1, [sp, 128]
	sub	w18, w28, w25
	sub	w2, w18, #1
	str	x2, [sp, 208]
	ldr	x3, [sp, 352]
	mul	x0, x1, x25
	str	x0, [sp, 304]
	add	x0, x1, x0
	str	w28, [sp, 136]
	ldr	x1, [sp, 200]
	add	x0, x0, x25
	ldr	x2, [sp, 512]
	mov	w28, w18
	stp	w25, w27, [sp, 180]
	mov	x27, x1
	add	x2, x2, x3
	str	x2, [sp, 96]
	add	x2, x1, x25, lsl 3
	str	x2, [sp, 296]
	ldr	w2, [sp, 420]
	lsl	x0, x0, 3
	str	w2, [sp, 120]
	str	x0, [sp, 384]
.L153:
	ldr	x0, [sp, 192]
	ldr	w2, [sp, 120]
	ldr	w1, [sp, 176]
	ldr	x0, [x0, 16]
	sub	w19, w1, w2
	cmp	w19, 8
	mov	w2, 8
	csel	w2, w19, w2, le
	ldr	x5, [x0]
	cbz	x5, .L427
	ldr	w0, [sp, 120]
	cmp	w0, 0
	add	w23, w0, 7
	csel	w23, w23, w0, lt
	asr	w23, w23, 3
	sbfiz	x20, x23, 14, 32
	sxtw	x6, w23
	add	x20, x5, x20
	cmp	w28, 0
	ble	.L155
	mov	w0, 7
	sub	w0, w0, w2
	add	x0, x0, 1
	sbfiz	x4, x2, 3, 32
	mov	x1, 8
	cmp	w19, 7
	lsl	x2, x0, 3
	ldr	w7, [sp, 160]
	csel	x2, x2, x1, le
	mov	x24, x20
	ldr	x0, [sp, 96]
	mov	x22, x2
	ldr	x1, [sp, 344]
	str	w23, [sp, 392]
	mov	x23, x4
	str	x20, [sp, 400]
	add	x8, x0, x1
	str	w28, [sp, 408]
	mov	x28, x5
	str	x20, [sp, 424]
	mov	w20, w7
	str	x25, [sp, 464]
	mov	x25, x8
.L189:
	cmp	w19, 0
	ble	.L170
	ldr	w0, [sp, 184]
	smaddl	x1, w20, w0, x25
	lsl	x0, x1, 3
	ldr	d0, [x26, x1, lsl 3]
	str	d0, [x24]
	cmp	w19, 1
	ble	.L192
	add	x0, x26, x0
	ldr	d0, [x0, 8]
	str	d0, [x24, 8]
	cmp	w19, 2
	beq	.L170
	ldr	d0, [x0, 16]
	str	d0, [x24, 16]
	cmp	w19, 3
	beq	.L170
	ldr	d0, [x0, 24]
	str	d0, [x24, 24]
	cmp	w19, 4
	beq	.L170
	ldr	d0, [x0, 32]
	str	d0, [x24, 32]
	cmp	w19, 5
	beq	.L170
	ldr	d0, [x0, 40]
	str	d0, [x24, 40]
	cmp	w19, 6
	beq	.L170
	ldr	d0, [x0, 48]
	str	d0, [x24, 48]
	cmp	w19, 7
	ble	.L170
	ldr	d0, [x0, 56]
	str	d0, [x24, 56]
.L192:
	cmp	w19, 7
	bgt	.L191
.L170:
	mov	x2, x22
	add	x0, x24, x23
	mov	w1, 0
	str	x6, [sp, 488]
	bl	memset
	ldr	x6, [sp, 488]
.L191:
	add	w20, w20, 1
	ldr	w0, [sp, 136]
	add	x24, x24, 64
	cmp	w0, w20
	bne	.L189
	mov	x5, x28
	ldr	w28, [sp, 408]
	lsl	x6, x6, 11
	ldr	w23, [sp, 392]
	cmp	w28, 4
	mov	x0, x21
	mov	w24, 4
	mov	x2, 256
	csel	w24, w28, w24, le
	mov	w1, 0
	ldr	x20, [sp, 400]
	stp	x6, x5, [sp, 392]
	ldr	x22, [sp, 424]
	ldr	x25, [sp, 464]
	bl	memset
	cmp	w28, 3
	ldp	x6, x5, [sp, 392]
	bls	.L175
	movi	v0.2d, 0
	stp	q0, q0, [x21]
	stp	q0, q0, [x21, 32]
	stp	q0, q0, [x21, 64]
	stp	q0, q0, [x21, 96]
	stp	q0, q0, [x21, 128]
	stp	q0, q0, [x21, 160]
	stp	q0, q0, [x21, 192]
	stp	q0, q0, [x21, 224]
.L175:
	add	x4, x6, 8
	ldr	x0, [sp, 304]
	add	x2, x6, 16
	ldr	x1, [sp, 384]
	add	x7, x0, x25
	add	x4, x5, x4, lsl 3
	add	x2, x5, x2, lsl 3
	add	x9, x27, x1
	mov	x0, x21
	add	x7, x27, x7, lsl 3
	mov	x1, x20
	mov	w8, 0
.L280:
	ldr	q0, [x0]
	add	w3, w8, 1
	ldp	q3, q2, [x1]
	ld1r	{v4.2d}, [x7]
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
	cmp	w24, w3
	ble	.L187
	ldr	q3, [x20]
	ld1r	{v4.2d}, [x9]
	ldp	q2, q0, [x0, 64]
	fmul	v3.2d, v3.2d, v4.2d
	ldp	q1, q5, [x0, 96]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x0, 64]
	ldr	q2, [x20, 16]
	fmul	v2.2d, v2.2d, v4.2d
	fadd	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 80]
	ldr	q0, [x20, 32]
	fmul	v0.2d, v0.2d, v4.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [x0, 96]
	ldr	q1, [x20, 48]
	fmul	v1.2d, v1.2d, v4.2d
	fadd	v1.2d, v1.2d, v5.2d
	str	q1, [x0, 112]
	cbz	w8, .L188
	ldr	d5, [x9, 8]
	ldr	q4, [x4]
	dup	v5.2d, v5.d[0]
	fmul	v4.2d, v4.2d, v5.2d
	fadd	v4.2d, v4.2d, v3.2d
	str	q4, [x0, 64]
	ldr	q3, [x4, 16]
	fmul	v3.2d, v3.2d, v5.2d
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x0, 80]
	ldr	q2, [x4, 32]
	fmul	v2.2d, v2.2d, v5.2d
	fadd	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 96]
	ldr	q0, [x4, 48]
	fmul	v0.2d, v0.2d, v5.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [x0, 112]
	cmp	w8, 2
	bne	.L188
	ldr	d1, [x9, 16]
	ldr	q5, [x2]
	dup	v1.2d, v1.d[0]
	fmul	v5.2d, v5.2d, v1.2d
	fadd	v4.2d, v5.2d, v4.2d
	str	q4, [x0, 64]
	ldr	q4, [x2, 16]
	fmul	v4.2d, v4.2d, v1.2d
	fadd	v3.2d, v4.2d, v3.2d
	str	q3, [x0, 80]
	ldr	q3, [x2, 32]
	fmul	v3.2d, v3.2d, v1.2d
	fadd	v2.2d, v3.2d, v2.2d
	str	q2, [x0, 96]
	ldr	q2, [x2, 48]
	fmul	v1.2d, v2.2d, v1.2d
	fadd	v0.2d, v1.2d, v0.2d
	str	q0, [x0, 112]
.L188:
	add	x1, x1, 64
	ldr	x8, [sp, 312]
	add	x0, x0, 64
	add	x7, x7, x8
	ldr	x8, [sp, 144]
	add	x9, x9, x8
	mov	w8, w3
	b	.L280
.L187:
	cmp	w28, 4
	ble	.L176
	ldr	x2, [sp, 128]
	add	x8, x25, 4
	mov	x1, 4
	mov	w0, 256
	sub	w24, w28, #4
	add	w12, w25, 7
	madd	x7, x2, x8, x25
	ldr	w2, [sp, 160]
	smaddl	x23, w23, w0, x1
	add	w11, w25, 5
	add	w9, w2, 4
	add	w10, w25, 6
	add	x7, x27, x7, lsl 3
	mov	x13, x22
	mov	w22, w9
	mov	x9, x26
	mov	x26, x25
	mov	x25, x8
	mov	w8, w28
	mov	x28, x7
	mov	x7, x20
	ldr	w20, [sp, 108]
	mov	w14, w19
	add	x23, x5, x23, lsl 6
	mov	x19, x1
	mov	w3, 5
.L186:
	cmp	w24, 4
	mov	w0, 4
	csel	w4, w24, w0, le
	mov	x2, 256
	mov	x0, x21
	mov	w1, 0
	str	w4, [sp, 392]
	str	w19, [sp, 400]
	str	x9, [sp, 408]
	str	x5, [sp, 424]
	str	x7, [sp, 464]
	str	w8, [sp, 488]
	str	x13, [sp, 504]
	str	w11, [sp, 576]
	str	w10, [sp, 584]
	str	w3, [sp, 592]
	str	w12, [sp, 604]
	str	x6, [sp, 608]
	str	w14, [sp, 616]
	bl	memset
	ldr	w4, [sp, 392]
	cmp	w24, 3
	ldr	w15, [sp, 400]
	ldr	w8, [sp, 488]
	ldr	w11, [sp, 576]
	ldr	w10, [sp, 584]
	ldr	w3, [sp, 592]
	ldr	w12, [sp, 604]
	ldr	w14, [sp, 616]
	ldr	x9, [sp, 408]
	ldr	x5, [sp, 424]
	ldr	x7, [sp, 464]
	ldr	x13, [sp, 504]
	ldr	x6, [sp, 608]
	ble	.L428
	smaddl	x2, w20, w22, x26
	mov	x1, x7
	movi	v0.2d, 0
	mov	x0, 0
	ldr	x18, [sp, 144]
	add	x2, x27, x2, lsl 3
	mov	v17.16b, v0.16b
	add	x17, x2, x18
	mov	v18.16b, v0.16b
	add	x16, x17, x18
	mov	v19.16b, v0.16b
	add	x18, x16, x18
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
.L182:
	ldp	q5, q4, [x1]
	ldp	q3, q1, [x1, 32]
	add	x1, x1, 64
	ldr	d16, [x2, x0, lsl 3]
	ldr	d7, [x17, x0, lsl 3]
	ldr	d6, [x16, x0, lsl 3]
	fmla	v31.2d, v5.2d, v16.d[0]
	ldr	d2, [x18, x0, lsl 3]
	fmla	v30.2d, v4.2d, v16.d[0]
	add	x0, x0, 1
	fmla	v29.2d, v3.2d, v16.d[0]
	fmla	v28.2d, v1.2d, v16.d[0]
	fmla	v27.2d, v5.2d, v7.d[0]
	fmla	v26.2d, v4.2d, v7.d[0]
	fmla	v25.2d, v3.2d, v7.d[0]
	fmla	v24.2d, v1.2d, v7.d[0]
	fmla	v23.2d, v5.2d, v6.d[0]
	fmla	v22.2d, v4.2d, v6.d[0]
	fmla	v21.2d, v3.2d, v6.d[0]
	fmla	v20.2d, v1.2d, v6.d[0]
	fmla	v19.2d, v5.2d, v2.d[0]
	fmla	v18.2d, v4.2d, v2.d[0]
	fmla	v17.2d, v3.2d, v2.d[0]
	fmla	v0.2d, v1.2d, v2.d[0]
	cmp	w0, w19
	blt	.L182
	stp	q31, q30, [x21]
	stp	q29, q28, [x21, 32]
	stp	q27, q26, [x21, 64]
	stp	q25, q24, [x21, 96]
	stp	q23, q22, [x21, 128]
	stp	q21, q20, [x21, 160]
	stp	q19, q18, [x21, 192]
	stp	q17, q0, [x21, 224]
.L181:
	smull	x0, w22, w20
	ldr	x1, [sp, 128]
	add	w15, w15, 2
	add	x17, x6, x3, uxtw 3
	mov	w18, 0
	add	x16, x1, x0
	add	x15, x6, x15, uxtw 3
	add	x0, x0, x25
	add	x16, x16, x25
	add	x17, x5, x17, lsl 3
	add	x15, x5, x15, lsl 3
	add	x2, x27, x0, lsl 3
	add	x16, x27, x16, lsl 3
	mov	x0, x21
	mov	x1, x23
.L184:
	ldr	q0, [x0]
	add	w30, w18, 1
	ldp	q3, q2, [x1]
	ld1r	{v4.2d}, [x2]
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
	cmp	w30, w4
	bge	.L178
	ldr	q3, [x23]
	ld1r	{v4.2d}, [x16]
	ldp	q2, q0, [x0, 64]
	fmul	v3.2d, v3.2d, v4.2d
	ldp	q1, q5, [x0, 96]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x0, 64]
	ldr	q2, [x23, 16]
	fmul	v2.2d, v2.2d, v4.2d
	fadd	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 80]
	ldr	q0, [x23, 32]
	fmul	v0.2d, v0.2d, v4.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [x0, 96]
	ldr	q1, [x23, 48]
	fmul	v1.2d, v1.2d, v4.2d
	fadd	v1.2d, v1.2d, v5.2d
	str	q1, [x0, 112]
	cbz	w18, .L185
	ldr	d5, [x16, 8]
	ldr	q4, [x17]
	dup	v5.2d, v5.d[0]
	fmul	v4.2d, v4.2d, v5.2d
	fadd	v4.2d, v4.2d, v3.2d
	str	q4, [x0, 64]
	ldr	q3, [x17, 16]
	fmul	v3.2d, v3.2d, v5.2d
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x0, 80]
	ldr	q2, [x17, 32]
	fmul	v2.2d, v2.2d, v5.2d
	fadd	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 96]
	ldr	q0, [x17, 48]
	fmul	v0.2d, v0.2d, v5.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [x0, 112]
	cmp	w18, 2
	bne	.L185
	ldr	d1, [x16, 16]
	ldr	q5, [x15]
	dup	v1.2d, v1.d[0]
	fmul	v5.2d, v5.2d, v1.2d
	fadd	v4.2d, v5.2d, v4.2d
	str	q4, [x0, 64]
	ldr	q4, [x15, 16]
	fmul	v4.2d, v4.2d, v1.2d
	fadd	v3.2d, v4.2d, v3.2d
	str	q3, [x0, 80]
	ldr	q3, [x15, 32]
	fmul	v3.2d, v3.2d, v1.2d
	fadd	v2.2d, v3.2d, v2.2d
	str	q2, [x0, 96]
	ldr	q2, [x15, 48]
	fmul	v1.2d, v2.2d, v1.2d
	fadd	v0.2d, v1.2d, v0.2d
	str	q0, [x0, 112]
.L185:
	add	x1, x1, 64
	ldr	x18, [sp, 312]
	add	x0, x0, 64
	add	x2, x2, x18
	ldr	x18, [sp, 144]
	add	x16, x16, x18
	mov	w18, w30
	b	.L184
.L178:
	ldr	x0, [sp, 376]
	add	x19, x19, 4
	sub	w24, w24, #4
	add	x23, x23, 256
	add	w22, w22, 4
	add	x25, x25, 4
	add	w3, w3, 4
	add	w12, w12, 4
	add	w11, w11, 4
	add	w10, w10, 4
	add	x28, x28, x0
	cmp	w8, w19
	bgt	.L186
	mov	x25, x26
	mov	x20, x7
	mov	w28, w8
	mov	x22, x13
	mov	w19, w14
	mov	x26, x9
.L176:
	cmp	w19, 0
	ble	.L155
	ldr	x0, [sp, 208]
	add	x1, x0, 1
	ldr	x0, [sp, 96]
	add	x1, x20, x1, lsl 6
	add	x0, x26, x0, lsl 3
.L173:
	ldr	d0, [x22]
	str	d0, [x0]
	cmp	w19, 1
	ble	.L171
	ldr	d0, [x22, 8]
	str	d0, [x0, 8]
	cmp	w19, 2
	beq	.L171
	ldr	d0, [x22, 16]
	str	d0, [x0, 16]
	cmp	w19, 3
	beq	.L171
	ldr	d0, [x22, 24]
	str	d0, [x0, 24]
	cmp	w19, 4
	beq	.L171
	ldr	d0, [x22, 32]
	str	d0, [x0, 32]
	cmp	w19, 5
	beq	.L171
	ldr	d0, [x22, 40]
	str	d0, [x0, 40]
	cmp	w19, 6
	beq	.L171
	ldr	d0, [x22, 48]
	str	d0, [x0, 48]
	cmp	w19, 7
	ble	.L171
	ldr	d0, [x22, 56]
	str	d0, [x0, 56]
.L171:
	ldr	x2, [sp, 216]
	add	x22, x22, 64
	add	x0, x0, x2
	cmp	x1, x22
	bne	.L173
.L155:
	ldr	x1, [sp, 96]
	ldr	w0, [sp, 120]
	add	x1, x1, 8
	str	x1, [sp, 96]
	ldr	w1, [sp, 600]
	add	w0, w0, 8
	str	w0, [sp, 120]
	cmp	w1, w0
	bgt	.L153
	ldr	w28, [sp, 136]
	ldr	w27, [sp, 184]
	b	.L150
.L428:
	mov	w18, w19
	cmp	w24, 0
	ble	.L178
	smaddl	x17, w20, w11, x26
	mov	x0, x7
	smaddl	x16, w20, w10, x26
	mov	x1, 0
	smaddl	x2, w20, w12, x26
	ldp	q4, q3, [sp, 624]
	add	x17, x27, x17, lsl 3
	ldp	q2, q1, [sp, 656]
	add	x16, x27, x16, lsl 3
	add	x2, x27, x2, lsl 3
.L180:
	ldr	d0, [x28, x1, lsl 3]
	ldr	q5, [x0]
	dup	v0.2d, v0.d[0]
	fmul	v5.2d, v5.2d, v0.2d
	fadd	v4.2d, v4.2d, v5.2d
	str	q4, [sp, 624]
	ldr	q5, [x0, 16]
	fmul	v5.2d, v5.2d, v0.2d
	fadd	v3.2d, v3.2d, v5.2d
	str	q3, [sp, 640]
	ldr	q5, [x0, 32]
	fmul	v5.2d, v5.2d, v0.2d
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [sp, 656]
	ldr	q5, [x0, 48]
	fmul	v0.2d, v5.2d, v0.2d
	fadd	v1.2d, v1.2d, v0.2d
	str	q1, [sp, 672]
	cmp	w24, 1
	ble	.L179
	ldr	d0, [x17, x1, lsl 3]
	ldr	q17, [x0]
	dup	v0.2d, v0.d[0]
	ldp	q16, q7, [sp, 688]
	ldp	q6, q5, [sp, 720]
	fmul	v17.2d, v17.2d, v0.2d
	fadd	v16.2d, v16.2d, v17.2d
	str	q16, [sp, 688]
	ldr	q16, [x0, 16]
	fmul	v16.2d, v16.2d, v0.2d
	fadd	v7.2d, v7.2d, v16.2d
	str	q7, [sp, 704]
	ldr	q7, [x0, 32]
	fmul	v7.2d, v7.2d, v0.2d
	fadd	v6.2d, v6.2d, v7.2d
	str	q6, [sp, 720]
	ldr	q6, [x0, 48]
	fmul	v0.2d, v6.2d, v0.2d
	fadd	v0.2d, v5.2d, v0.2d
	str	q0, [sp, 736]
	cmp	w24, 2
	beq	.L179
	ldr	d0, [x16, x1, lsl 3]
	ldr	q16, [x0]
	dup	v0.2d, v0.d[0]
	ldp	q7, q6, [sp, 752]
	ldr	q5, [sp, 784]
	fmul	v16.2d, v16.2d, v0.2d
	fadd	v7.2d, v7.2d, v16.2d
	str	q7, [sp, 752]
	ldr	q7, [x0, 16]
	fmul	v7.2d, v7.2d, v0.2d
	fadd	v6.2d, v6.2d, v7.2d
	str	q6, [sp, 768]
	ldr	q6, [x0, 32]
	fmul	v6.2d, v6.2d, v0.2d
	fadd	v5.2d, v5.2d, v6.2d
	str	q5, [sp, 784]
	ldr	q6, [x0, 48]
	ldr	q5, [sp, 800]
	fmul	v0.2d, v6.2d, v0.2d
	fadd	v0.2d, v5.2d, v0.2d
	str	q0, [sp, 800]
	cmp	w24, 3
	ble	.L179
	ldr	d0, [x2, x1, lsl 3]
	ldr	q17, [x0]
	dup	v0.2d, v0.d[0]
	ldp	q16, q7, [sp, 816]
	ldp	q6, q5, [sp, 848]
	fmul	v17.2d, v17.2d, v0.2d
	fadd	v16.2d, v16.2d, v17.2d
	str	q16, [sp, 816]
	ldr	q16, [x0, 16]
	fmul	v16.2d, v16.2d, v0.2d
	fadd	v7.2d, v7.2d, v16.2d
	str	q7, [sp, 832]
	ldr	q7, [x0, 32]
	fmul	v7.2d, v7.2d, v0.2d
	fadd	v6.2d, v6.2d, v7.2d
	str	q6, [sp, 848]
	ldr	q6, [x0, 48]
	fmul	v0.2d, v6.2d, v0.2d
	fadd	v0.2d, v5.2d, v0.2d
	str	q0, [sp, 864]
.L179:
	add	x1, x1, 1
	add	x0, x0, 64
	cmp	w18, w1
	bgt	.L180
	b	.L181
.L427:
	ldr	w0, [sp, 136]
	ldr	w1, [sp, 180]
	cmp	w0, w1
	ble	.L155
	ldp	x9, x1, [sp, 328]
	cmp	w19, 0
	ldr	x11, [sp, 96]
	csinc	w2, w2, wzr, gt
	ldr	x0, [sp, 128]
	and	w8, w2, -2
	ldp	x17, x12, [sp, 312]
	add	x13, x0, x1
	add	x0, sp, 512
	add	x14, x26, x11, lsl 3
	ldr	w10, [sp, 140]
	lsr	w7, w2, 1
	ldr	x15, [sp, 152]
	mov	x6, x14
	ldr	x16, [sp, 216]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	stp	xzr, xzr, [x0, 144]
	stp	xzr, xzr, [x0, 160]
.L281:
	ldr	d2, [x12]
	cmp	w19, 0
	ble	.L161
	cmp	w19, 1
	ble	.L284
	ldr	q0, [x6]
	ldr	q3, [sp, 624]
	dup	v1.2d, v2.d[0]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x6]
	cmp	w7, 1
	bls	.L160
	ldr	q0, [x6, 16]
	ldr	q3, [sp, 640]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x6, 16]
	cmp	w7, 2
	beq	.L160
	ldr	q0, [x6, 32]
	ldr	q3, [sp, 656]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x6, 32]
	cmp	w7, 3
	beq	.L160
	ldr	q0, [x6, 48]
	ldr	q3, [sp, 672]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x6, 48]
.L160:
	sxtw	x0, w8
	cmp	w2, w8
	beq	.L161
.L159:
	add	x1, x0, x11
	ldr	d1, [x21, x0, lsl 3]
	ldr	d0, [x26, x1, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x26, x1, lsl 3]
.L161:
	ldr	w0, [sp, 136]
	add	w10, w10, 1
	cmp	w10, w0
	beq	.L155
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	stp	xzr, xzr, [x0, 144]
	stp	xzr, xzr, [x0, 160]
	ldr	w0, [sp, 180]
	cmp	w10, w0
	ble	.L163
	cmp	w19, 0
	ble	.L163
	ldr	x0, [sp, 296]
	mov	x4, x14
	ldr	x3, [sp, 96]
	add	x5, x0, x13, lsl 3
.L166:
	ldr	d0, [x5]
	cmp	w19, 1
	ble	.L429
	dup	v3.2d, v0.d[0]
	ldr	q2, [x4]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w7, 1
	bls	.L167
	ldr	q2, [x4, 16]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
	cmp	w7, 2
	beq	.L167
	ldr	q2, [x4, 32]
	ldr	q1, [sp, 656]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 656]
	cmp	w7, 3
	beq	.L167
	ldr	q2, [x4, 48]
	ldr	q1, [sp, 672]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 672]
.L167:
	sxtw	x0, w8
	cmp	w2, w8
	beq	.L168
.L164:
	add	x1, x0, x3
	ldr	d1, [x21, x0, lsl 3]
	ldr	d2, [x26, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x21, x0, lsl 3]
.L168:
	add	x5, x5, 8
	add	x3, x3, x15
	add	x4, x4, x16
	cmp	x5, x9
	bne	.L166
.L163:
	ldr	x0, [sp, 128]
	add	x12, x12, x17
	add	x9, x9, x17
	add	x11, x11, x15
	add	x6, x6, x16
	add	x13, x13, x0
	b	.L281
.L429:
	mov	x0, 0
	b	.L164
.L284:
	mov	x0, 0
	b	.L159
.L425:
	ldp	x21, x22, [sp, 32]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L146:
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x25, x26, [sp, 64]
	add	sp, sp, 880
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L424:
	.cfi_def_cfa_offset 880
	.cfi_offset 19, -864
	.cfi_offset 20, -856
	.cfi_offset 21, -848
	.cfi_offset 22, -840
	.cfi_offset 23, -832
	.cfi_offset 24, -824
	.cfi_offset 25, -816
	.cfi_offset 26, -808
	.cfi_offset 27, -800
	.cfi_offset 28, -792
	.cfi_offset 29, -880
	.cfi_offset 30, -872
	ldr	w3, [sp, 368]
	sub	w1, w1, #1
	ldr	w4, [sp, 160]
	mov	w20, w25
	str	w1, [sp, 424]
	sub	w4, w28, w4
	str	w4, [sp, 208]
	udiv	w2, w0, w3
	sub	w1, w4, #1
	str	x1, [sp, 488]
	ldr	x22, [sp, 200]
	str	wzr, [sp, 296]
	msub	w0, w2, w3, w0
	add	w1, w28, w2, lsl 6
	ldr	w2, [sp, 112]
	ldr	x23, [sp, 216]
	lsl	w0, w0, 6
	str	w0, [sp, 96]
	str	w1, [sp, 180]
	sub	w1, w2, w1
	str	w1, [sp, 384]
.L198:
	ldp	w2, w18, [sp, 176]
	ldr	w3, [sp, 96]
	ldr	w0, [sp, 384]
	add	w1, w18, 64
	ldr	w4, [sp, 112]
	add	w19, w3, 64
	cmp	w0, 63
	sub	w0, w2, w3
	csel	w1, w1, w4, gt
	cmp	w0, 63
	ldr	w0, [sp, 116]
	csel	w19, w19, w2, gt
	str	w1, [sp, 136]
	cbnz	w0, .L430
.L201:
	ldr	w0, [sp, 136]
	cmp	w0, w18
	ble	.L208
	ldr	w1, [sp, 96]
	cmp	w1, w19
	bge	.L208
	sxtw	x3, w1
	ldr	w2, [sp, 136]
	ldr	w1, [sp, 108]
	smull	x0, w27, w18
	sub	w2, w2, w18
	str	w2, [sp, 160]
	ldr	x2, [sp, 168]
	str	x3, [sp, 504]
	smaddl	x1, w1, w18, x25
	stp	x22, x25, [sp, 392]
	sub	x2, x2, x0
	add	x0, x0, x3
	str	w20, [sp, 408]
	ldr	x3, [sp, 488]
	add	x24, x22, x1, lsl 3
	ldr	x15, [sp, 128]
	mov	w6, w27
	ldr	x20, [sp, 192]
	lsl	x2, x2, 3
	ldr	x18, [sp, 432]
	add	x0, x26, x0, lsl 3
	ldr	x22, [sp, 440]
	add	x3, x3, 1
	str	x2, [sp, 184]
	str	x0, [sp, 304]
	str	x3, [sp, 576]
.L252:
	ldr	w1, [sp, 160]
	mov	w0, 4
	ldr	w13, [sp, 96]
	cmp	w1, 4
	csel	w0, w1, w0, le
	cmp	w1, 3
	str	w0, [sp, 464]
	cset	w0, gt
	str	w0, [sp, 120]
	ldr	x0, [sp, 576]
	ldr	x12, [sp, 304]
	ldr	x25, [sp, 504]
	add	x14, x24, x0, lsl 3
.L250:
	ldr	x0, [x20, 16]
	sub	w10, w19, w13
	ldr	x3, [x0]
	cbz	x3, .L431
	asr	w0, w13, 3
	mov	x9, 8
	mov	w4, w9
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 120]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	ble	.L432
.L255:
	ldr	w0, [sp, 116]
	cbnz	w0, .L271
	movi	v16.2d, 0
	ldr	w0, [sp, 208]
	cmp	w0, 0
	ble	.L294
	mov	v17.16b, v16.16b
	lsl	x9, x9, 3
	mov	v18.16b, v16.16b
	mov	x0, x24
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
.L273:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, x9
	ld1r	{v7.2d}, [x0]
	ldr	d6, [x0, x15, lsl 3]
	ldr	d5, [x0, x18, lsl 3]
	fmla	v31.2d, v4.2d, v7.2d
	ldr	d1, [x0, x22, lsl 3]
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
	cmp	x14, x0
	bne	.L273
.L272:
	ldp	q3, q2, [x12]
	add	x0, x23, x12
	ldp	q1, q0, [x12, 32]
	add	x1, x0, x23
	fsub	v3.2d, v3.2d, v31.2d
	fsub	v2.2d, v2.2d, v30.2d
	fsub	v0.2d, v0.2d, v28.2d
	fsub	v1.2d, v1.2d, v29.2d
	stp	q3, q2, [x12]
	stp	q1, q0, [x12, 32]
	ldr	q0, [x23, x12]
	fsub	v0.2d, v0.2d, v27.2d
	str	q0, [x23, x12]
	ldr	x2, [sp, 224]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v26.2d
	str	q0, [x2, x12]
	ldr	x2, [sp, 232]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v25.2d
	str	q0, [x2, x12]
	ldr	x2, [sp, 240]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v24.2d
	str	q0, [x2, x12]
	ldr	q0, [x0, x23]
	fsub	v0.2d, v0.2d, v23.2d
	str	q0, [x0, x23]
	ldr	x0, [sp, 248]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v22.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 256]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v21.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 264]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v20.2d
	str	q0, [x0, x12]
	ldr	q0, [x23, x1]
	fsub	v0.2d, v0.2d, v19.2d
	str	q0, [x23, x1]
	ldr	x0, [sp, 272]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v18.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 280]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v17.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 288]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v16.2d
	str	q0, [x0, x12]
.L274:
	add	w13, w13, 8
	add	x12, x12, 64
	add	x25, x25, 8
	cmp	w19, w13
	bgt	.L250
	ldr	x2, [sp, 184]
	ldr	x3, [sp, 568]
	ldr	x1, [sp, 376]
	add	x2, x2, x3
	ldr	w0, [sp, 160]
	str	x2, [sp, 184]
	add	x24, x24, x1
	ldr	x2, [sp, 304]
	sub	w0, w0, #4
	ldr	x3, [sp, 496]
	str	w0, [sp, 160]
	ldr	w1, [sp, 136]
	add	x2, x2, x3
	str	x2, [sp, 304]
	sub	w0, w1, w0
	cmp	w1, w0
	bgt	.L252
	ldp	x22, x25, [sp, 392]
	mov	w27, w6
	ldr	w20, [sp, 408]
.L208:
	ldr	w1, [sp, 296]
	ldr	w0, [sp, 424]
	cmp	w0, w1
	beq	.L196
	ldr	w0, [sp, 96]
	ldr	w1, [sp, 176]
	add	w0, w0, 64
	str	w0, [sp, 96]
	cmp	w1, w0
	ble	.L433
.L251:
	ldr	w0, [sp, 296]
	add	w0, w0, 1
	str	w0, [sp, 296]
	b	.L198
.L271:
	ldr	w2, [sp, 108]
	mov	x5, x12
	ldr	w0, [sp, 140]
	mov	x1, x24
	sub	w0, w28, w0
	bl	update4x8_sve
	b	.L274
.L431:
	ldr	x0, [sp, 184]
	mov	w4, w6
	ldr	x9, [sp, 152]
	add	x3, x12, x0
	ldr	w0, [sp, 120]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	bgt	.L255
.L432:
	ldr	w0, [sp, 160]
	cmp	w0, 0
	ble	.L274
	cmp	w10, 8
	mov	w16, 8
	csel	w16, w10, w16, le
	cmp	w10, 0
	str	w13, [sp, 604]
	csinc	w16, w16, wzr, gt
	str	x12, [sp, 616]
	and	w5, w16, -2
	ldp	x12, x13, [sp, 392]
	str	w19, [sp, 584]
	ldr	w1, [sp, 136]
	lsl	x17, x9, 3
	ldr	w19, [sp, 408]
	mov	w30, 0
	str	x15, [sp, 592]
	sub	w27, w1, w0
	ldr	w15, [sp, 464]
	lsr	w1, w16, 1
	str	x14, [sp, 608]
	ldr	x14, [sp, 144]
.L261:
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	stp	xzr, xzr, [x0, 144]
	stp	xzr, xzr, [x0, 160]
	cmp	w28, w19
	ble	.L434
	sxtw	x11, w27
	cmp	w10, 0
	ble	.L264
	madd	x11, x11, x14, x12
	mov	x7, x3
	mov	x8, x13
	mov	x4, 0
	.p2align 3,,7
.L268:
	ldr	d0, [x11, x8, lsl 3]
	cmp	w10, 1
	ble	.L435
	dup	v3.2d, v0.d[0]
	ldr	q2, [x7]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w1, 1
	bls	.L269
	ldr	q2, [x7, 16]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
	cmp	w1, 2
	beq	.L269
	ldr	q2, [x7, 32]
	ldr	q1, [sp, 656]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 656]
	cmp	w1, 3
	beq	.L269
	ldr	q2, [x7, 48]
	ldr	q1, [sp, 672]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 672]
.L269:
	sxtw	x0, w5
	cmp	w5, w16
	beq	.L270
.L266:
	add	x2, x0, x4
	ldr	d1, [x21, x0, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x21, x0, lsl 3]
.L270:
	add	x8, x8, 1
	add	x4, x4, x9
	add	x7, x7, x17
	cmp	w28, w8
	bgt	.L268
	smaddl	x0, w27, w6, x25
	cmp	w10, 1
	ble	.L292
.L436:
	lsl	x4, x0, 3
	ldr	q1, [sp, 624]
	add	x2, x26, x4
	ldr	q0, [x26, x4]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x26, x4]
	cmp	w1, 1
	bls	.L263
	ldr	q0, [x2, 16]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 16]
	cmp	w1, 2
	beq	.L263
	ldr	q0, [x2, 32]
	ldr	q1, [sp, 656]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 32]
	cmp	w1, 3
	beq	.L263
	ldr	q0, [x2, 48]
	ldr	q1, [sp, 672]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 48]
.L263:
	sxtw	x2, w5
	cmp	w5, w16
	beq	.L264
.L262:
	add	x0, x2, x0
	ldr	d1, [x21, x2, lsl 3]
	ldr	d0, [x26, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x26, x0, lsl 3]
.L264:
	add	w30, w30, 1
	add	w27, w27, 1
	cmp	w30, w15
	blt	.L261
	ldr	w19, [sp, 584]
	ldr	w13, [sp, 604]
	ldr	x15, [sp, 592]
	ldr	x14, [sp, 608]
	ldr	x12, [sp, 616]
	b	.L274
.L435:
	mov	x0, 0
	b	.L266
.L434:
	cmp	w10, 0
	ble	.L264
	smaddl	x0, w27, w6, x25
	cmp	w10, 1
	bgt	.L436
.L292:
	mov	x2, 0
	b	.L262
.L294:
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
	b	.L272
.L433:
	ldr	w0, [sp, 180]
	ldr	w1, [sp, 112]
	add	w0, w0, 64
	str	wzr, [sp, 96]
	str	w0, [sp, 180]
	sub	w0, w1, w0
	str	w0, [sp, 384]
	b	.L251
.L430:
	uxtw	x0, w1
	sub	w0, w0, w18
	cmp	w0, 15
	ble	.L202
	ldr	w2, [sp, 108]
	smull	x0, w27, w18
	ldrsw	x3, [sp, 96]
	mov	x10, x23
	ldr	x23, [sp, 144]
	mov	w8, w19
	smaddl	x1, w2, w18, x25
	str	x3, [sp, 304]
	ldr	x2, [sp, 168]
	ldr	x9, [sp, 192]
	sub	x2, x2, x0
	add	x0, x0, x3
	lsl	x2, x2, 3
	str	x2, [sp, 160]
	add	x0, x26, x0, lsl 3
	str	x0, [sp, 184]
	add	x0, x22, x1, lsl 3
	str	x0, [sp, 120]
.L230:
	ldr	w0, [sp, 96]
	add	w24, w18, 16
	cmp	w0, w8
	bge	.L204
	ldr	w7, [sp, 96]
	add	w24, w18, 16
	ldr	x5, [sp, 184]
	ldr	x19, [sp, 304]
	b	.L235
.L233:
	ldr	w2, [sp, 108]
	mov	w6, w27
	ldr	x1, [sp, 120]
	str	w8, [sp, 392]
	ldr	w0, [sp, 140]
	str	w18, [sp, 400]
	sub	w0, w28, w0
	str	w7, [sp, 408]
	str	x10, [sp, 464]
	str	x9, [sp, 504]
	bl	update16x8_sve
	ldr	w8, [sp, 392]
	ldr	w18, [sp, 400]
	ldr	w7, [sp, 408]
	ldr	x10, [sp, 464]
	ldr	x9, [sp, 504]
.L239:
	add	w7, w7, 8
	add	x5, x5, 64
	add	x19, x19, 8
	cmp	w8, w7
	ble	.L204
.L235:
	ldr	x0, [x9, 16]
	sub	w13, w8, w7
	ldr	x3, [x0]
	cbz	x3, .L437
	asr	w0, w7, 3
	mov	x14, 8
	mov	w4, w14
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L249:
	cmp	w13, 7
	bgt	.L233
	add	x0, sp, 512
	cmp	w13, 0
	csinc	w15, w13, wzr, gt
	lsl	x16, x14, 3
	mov	w17, w18
	and	w11, w15, -2
	stp	xzr, xzr, [x0, 112]
	lsr	w6, w15, 1
	stp	xzr, xzr, [x0, 128]
	stp	xzr, xzr, [x0, 144]
	stp	xzr, xzr, [x0, 160]
	cmp	w28, w20
	ble	.L438
	.p2align 3,,7
.L236:
	sxtw	x12, w17
	cmp	w13, 0
	ble	.L242
	madd	x12, x12, x23, x22
	mov	x2, x3
	mov	x4, x25
	mov	x1, 0
	.p2align 3,,7
.L246:
	ldr	d0, [x12, x4, lsl 3]
	cmp	w13, 1
	ble	.L439
	dup	v3.2d, v0.d[0]
	ldr	q2, [x2]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w6, 1
	bls	.L247
	ldr	q2, [x2, 16]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
	cmp	w6, 2
	beq	.L247
	ldr	q2, [x2, 32]
	ldr	q1, [sp, 656]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 656]
	cmp	w6, 3
	beq	.L247
	ldr	q2, [x2, 48]
	ldr	q1, [sp, 672]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 672]
.L247:
	sxtw	x0, w11
	cmp	w11, w15
	beq	.L248
.L244:
	add	x30, x0, x1
	ldr	d1, [x21, x0, lsl 3]
	ldr	d2, [x3, x30, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x21, x0, lsl 3]
.L248:
	add	x4, x4, 1
	add	x1, x1, x14
	add	x2, x2, x16
	cmp	w28, w4
	bgt	.L246
	smaddl	x0, w17, w27, x19
	cmp	w13, 1
	ble	.L290
.L440:
	lsl	x2, x0, 3
	ldr	q1, [sp, 624]
	add	x1, x26, x2
	ldr	q0, [x26, x2]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x26, x2]
	cmp	w6, 1
	bls	.L241
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w6, 2
	beq	.L241
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 656]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w6, 3
	beq	.L241
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 672]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L241:
	sxtw	x1, w11
	cmp	w11, w15
	beq	.L242
.L240:
	add	x0, x1, x0
	ldr	d1, [x21, x1, lsl 3]
	ldr	d0, [x26, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x26, x0, lsl 3]
.L242:
	add	w17, w17, 1
	cmp	w24, w17
	beq	.L239
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	stp	xzr, xzr, [x0, 144]
	stp	xzr, xzr, [x0, 160]
	cmp	w28, w20
	bgt	.L236
.L438:
	cmp	w13, 0
	ble	.L242
	smaddl	x0, w17, w27, x19
	cmp	w13, 1
	bgt	.L440
.L290:
	mov	x1, 0
	b	.L240
	.p2align 2,,3
.L439:
	mov	x0, 0
	b	.L244
.L437:
	ldp	x14, x0, [sp, 152]
	mov	w4, w27
	add	x3, x5, x0
	b	.L249
.L204:
	ldr	x0, [sp, 120]
	mov	w18, w24
	ldr	x1, [sp, 456]
	ldr	x2, [sp, 552]
	add	x0, x0, x1
	ldr	x1, [sp, 160]
	str	x0, [sp, 120]
	ldr	w0, [sp, 136]
	add	x1, x1, x2
	str	x1, [sp, 160]
	ldr	x1, [sp, 184]
	sub	w0, w0, w24
	ldr	x2, [sp, 472]
	add	x1, x1, x2
	str	x1, [sp, 184]
	cmp	w0, 15
	bgt	.L230
	mov	w19, w8
	mov	x23, x10
.L202:
	ldr	w1, [sp, 136]
	add	w0, w18, 7
	cmp	w1, w0
	ble	.L201
	ldr	w2, [sp, 108]
	smull	x0, w27, w18
	ldr	x3, [sp, 168]
	sub	w1, w1, #8
	ldrsw	x4, [sp, 96]
	sub	w1, w1, w18
	sub	x3, x3, x0
	smaddl	x2, w2, w18, x25
	add	x0, x4, x0
	mov	x10, x23
	ldr	x7, [sp, 144]
	add	x0, x26, x0, lsl 3
	ldr	x9, [sp, 192]
	mov	x23, x22
	mov	w8, w19
	str	x0, [sp, 120]
	add	x0, x22, x2, lsl 3
	mov	w22, w20
	str	x4, [sp, 304]
	add	w4, w18, 8
	str	w1, [sp, 392]
	and	w1, w1, -8
	lsl	x3, x3, 3
	add	w1, w4, w1
	str	x3, [sp, 160]
	str	x0, [sp, 184]
	str	w1, [sp, 400]
	str	w4, [sp, 408]
.L209:
	ldr	w0, [sp, 96]
	add	w19, w18, 8
	cmp	w0, w8
	bge	.L206
	ldr	w20, [sp, 96]
	add	w19, w18, 8
	ldr	x5, [sp, 120]
	ldr	x24, [sp, 304]
	b	.L215
.L213:
	ldr	w2, [sp, 108]
	mov	w6, w27
	ldr	x1, [sp, 184]
	str	w8, [sp, 464]
	ldr	w0, [sp, 140]
	str	w18, [sp, 504]
	sub	w0, w28, w0
	str	x10, [sp, 576]
	str	x7, [sp, 584]
	str	x9, [sp, 592]
	bl	update8x8_sve
	ldr	w8, [sp, 464]
	ldr	w18, [sp, 504]
	ldr	x10, [sp, 576]
	ldr	x7, [sp, 584]
	ldr	x9, [sp, 592]
.L219:
	add	w20, w20, 8
	add	x5, x5, 64
	add	x24, x24, 8
	cmp	w8, w20
	ble	.L206
.L215:
	ldr	x0, [x9, 16]
	sub	w12, w8, w20
	ldr	x3, [x0]
	cbz	x3, .L441
	asr	w0, w20, 3
	mov	x14, 8
	mov	w4, w14
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L229:
	cmp	w12, 7
	bgt	.L213
	add	x0, sp, 512
	cmp	w12, 0
	csinc	w15, w12, wzr, gt
	lsl	x16, x14, 3
	mov	w17, w18
	and	w11, w15, -2
	stp	xzr, xzr, [x0, 112]
	lsr	w6, w15, 1
	stp	xzr, xzr, [x0, 128]
	stp	xzr, xzr, [x0, 144]
	stp	xzr, xzr, [x0, 160]
	cmp	w28, w22
	ble	.L442
.L216:
	sxtw	x13, w17
	cmp	w12, 0
	ble	.L222
	madd	x13, x13, x7, x23
	mov	x2, x3
	mov	x4, x25
	mov	x1, 0
	.p2align 3,,7
.L226:
	ldr	d0, [x13, x4, lsl 3]
	cmp	w12, 1
	ble	.L443
	dup	v3.2d, v0.d[0]
	ldr	q2, [x2]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w6, 1
	bls	.L227
	ldr	q2, [x2, 16]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
	cmp	w6, 2
	beq	.L227
	ldr	q2, [x2, 32]
	ldr	q1, [sp, 656]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 656]
	cmp	w6, 3
	beq	.L227
	ldr	q2, [x2, 48]
	ldr	q1, [sp, 672]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 672]
.L227:
	sxtw	x0, w11
	cmp	w15, w11
	beq	.L228
.L224:
	add	x30, x0, x1
	ldr	d1, [x21, x0, lsl 3]
	ldr	d2, [x3, x30, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x21, x0, lsl 3]
.L228:
	add	x4, x4, 1
	add	x1, x1, x14
	add	x2, x2, x16
	cmp	w28, w4
	bgt	.L226
	smaddl	x0, w17, w27, x24
	cmp	w12, 1
	ble	.L288
.L444:
	lsl	x2, x0, 3
	ldr	q1, [sp, 624]
	add	x1, x26, x2
	ldr	q0, [x26, x2]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x26, x2]
	cmp	w6, 1
	bls	.L221
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w6, 2
	beq	.L221
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 656]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w6, 3
	beq	.L221
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 672]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L221:
	sxtw	x1, w11
	cmp	w15, w11
	beq	.L222
.L220:
	add	x0, x1, x0
	ldr	d1, [x21, x1, lsl 3]
	ldr	d0, [x26, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x26, x0, lsl 3]
.L222:
	add	w17, w17, 1
	cmp	w19, w17
	beq	.L219
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	stp	xzr, xzr, [x0, 144]
	stp	xzr, xzr, [x0, 160]
	cmp	w28, w22
	bgt	.L216
.L442:
	cmp	w12, 0
	ble	.L222
	smaddl	x0, w17, w27, x24
	cmp	w12, 1
	bgt	.L444
.L288:
	mov	x1, 0
	b	.L220
.L443:
	mov	x0, 0
	b	.L224
.L441:
	ldp	x14, x0, [sp, 152]
	mov	w4, w27
	add	x3, x0, x5
	b	.L229
.L206:
	ldr	x0, [sp, 184]
	mov	w18, w19
	ldr	x1, [sp, 480]
	add	x0, x0, x1
	str	x0, [sp, 184]
	ldr	x0, [sp, 160]
	ldr	x1, [sp, 560]
	add	x0, x0, x1
	str	x0, [sp, 160]
	ldr	x0, [sp, 120]
	ldr	x1, [sp, 448]
	add	x0, x0, x1
	str	x0, [sp, 120]
	ldr	w0, [sp, 400]
	cmp	w19, w0
	bne	.L209
	ldr	w0, [sp, 392]
	mov	w20, w22
	ldr	w1, [sp, 408]
	mov	x22, x23
	and	w0, w0, -8
	mov	w19, w8
	mov	x23, x10
	add	w18, w0, w1
	b	.L201
.L197:
	add	w1, w1, 1
	mov	w0, 0
	b	.L278
.L282:
	bl	GOMP_barrier
	b	.L196
	.cfi_endproc
.LFE4286:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4285:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L451
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
	bls	.L447
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L448
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L449:
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
.L447:
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
.L451:
	ret
	.p2align 2,,3
.L448:
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
	b	.L449
	.cfi_endproc
.LFE4285:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (GNU) 10.3.1"
	.section	.note.GNU-stack,"",@progbits
