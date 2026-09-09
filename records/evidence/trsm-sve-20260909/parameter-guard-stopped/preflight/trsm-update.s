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
	.type	update4x8_sve, %function
update4x8_sve:
.LFB4281:
	.cfi_startproc
	cmp	w0, 0
	ble	.L9
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
.L8:
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
	bne	.L8
.L7:
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
.L9:
	mov	z1.d, #0
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	b	.L7
	.cfi_endproc
.LFE4281:
	.size	update4x8_sve, .-update4x8_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4284:
	.cfi_startproc
	sub	sp, sp, #544
	.cfi_def_cfa_offset 544
	stp	x29, x30, [sp]
	.cfi_offset 29, -544
	.cfi_offset 30, -536
	mov	x29, sp
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -512
	.cfi_offset 22, -504
	mov	x21, x0
	ldr	w0, [x0, 40]
	stp	x27, x28, [sp, 80]
	.cfi_offset 27, -464
	.cfi_offset 28, -456
	ldp	x1, x27, [x21]
	str	x1, [sp, 104]
	ldr	w1, [x21, 24]
	str	w1, [sp, 140]
	ldr	w1, [x21, 28]
	str	w1, [sp, 272]
	ldr	w1, [x21, 32]
	str	w1, [sp, 152]
	ldr	w1, [x21, 36]
	str	w0, [sp, 136]
	str	w1, [sp, 348]
	cbz	w0, .L80
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	csinc	w0, w0, wzr, eq
	str	w0, [sp, 136]
.L80:
	ldr	w0, [sp, 140]
	cmp	w0, 0
	ble	.L11
	stp	x19, x20, [sp, 16]
	.cfi_offset 20, -520
	.cfi_offset 19, -528
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -488
	.cfi_offset 23, -496
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -472
	.cfi_offset 25, -480
	bl	omp_get_num_threads
	mov	w19, w0
	str	w0, [sp, 380]
	bl	omp_get_thread_num
	ldr	w6, [sp, 272]
	mov	w10, w0
	ldr	w7, [sp, 348]
	add	x26, sp, 480
	adds	w2, w6, 7
	add	w1, w6, 14
	csel	w0, w1, w2, mi
	mov	w2, 24
	sxtw	x5, w7
	sbfiz	x28, x7, 3, 32
	add	x1, x5, 1
	asr	w0, w0, 3
	smull	x2, w7, w2
	ldr	w11, [sp, 152]
	lsl	x8, x1, 4
	add	w3, w6, 63
	add	x7, x8, 16
	stp	x8, x7, [sp, 216]
	add	x7, x8, 32
	sdiv	w1, w0, w19
	str	x7, [sp, 232]
	add	x7, x2, 16
	sxtw	x25, w11
	str	x7, [sp, 240]
	add	x7, x2, 32
	add	x4, x25, 1
	add	x2, x2, 48
	stp	x7, x2, [sp, 248]
	msub	w0, w1, w19, w0
	lsl	x9, x25, 3
	ldr	x7, [sp, 104]
	lsl	x2, x4, 11
	cmp	w10, w0
	str	x2, [sp, 448]
	add	x2, x7, x9
	cinc	w1, w1, lt
	str	x2, [sp, 320]
	add	x2, x9, 8
	str	x2, [sp, 424]
	lsl	x2, x5, 8
	str	x2, [sp, 440]
	lsl	x2, x25, 8
	mul	w4, w1, w10
	str	x2, [sp, 456]
	lsl	x2, x25, 5
	str	x2, [sp, 408]
	neg	x2, x5, lsl 5
	add	w0, w4, w0
	str	x2, [sp, 464]
	lsl	x2, x5, 5
	csel	w0, w4, w0, lt
	str	x2, [sp, 392]
	asr	w2, w3, 6
	add	w1, w1, w0
	str	w2, [sp, 364]
	add	x2, x28, 16
	str	x2, [sp, 192]
	add	x2, x28, 32
	str	w0, [sp, 404]
	lsl	w0, w0, 3
	sbfiz	x23, x11, 1, 32
	str	x9, [sp, 128]
	str	x5, [sp, 184]
	add	x20, x23, x25
	str	x2, [sp, 200]
	add	x2, x28, 48
	str	x2, [sp, 208]
	str	x7, [sp, 312]
	str	x25, [sp, 328]
	str	w10, [sp, 352]
	str	w0, [sp, 356]
	str	w1, [sp, 400]
	lsl	w1, w1, 3
	str	w1, [sp, 360]
	sub	w1, w6, w0
	sxtw	x0, w0
	str	x0, [sp, 432]
	mov	x0, x20
	mov	x20, x27
	mov	x27, x0
	str	x21, [sp, 336]
	mov	x21, x23
	str	xzr, [sp, 96]
	stp	xzr, xzr, [sp, 296]
	str	w1, [sp, 416]
.L34:
	ldr	x2, [sp, 96]
	str	w2, [sp, 156]
	ldr	w3, [sp, 140]
	add	w0, w2, 256
	mov	w23, w2
	sub	w1, w3, w2
	cmp	w1, 255
	ldr	w1, [sp, 404]
	csel	w24, w0, w3, gt
	ldr	w0, [sp, 400]
	cmp	w0, w1
	bgt	.L154
	bl	GOMP_barrier
	ldr	x0, [sp, 336]
	ldr	x0, [x0, 16]
	ldr	x0, [x0]
	cbz	x0, .L79
.L71:
	bl	GOMP_barrier
.L79:
	ldr	w0, [sp, 140]
	cmp	w24, w0
	bge	.L36
	ldr	w0, [sp, 140]
	add	w1, w0, 63
	subs	w1, w1, w24
	add	w0, w1, 63
	csel	w0, w0, w1, mi
	ldr	w1, [sp, 272]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L36
	ldr	w1, [sp, 364]
	ldr	w2, [sp, 380]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	ldr	w2, [sp, 352]
	cmp	w2, w0
	bcc	.L37
.L70:
	ldr	w2, [sp, 352]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L155
.L36:
	bl	GOMP_barrier
	ldr	x2, [sp, 296]
	ldr	x1, [sp, 440]
	ldr	x0, [sp, 96]
	add	x2, x2, x1
	str	x2, [sp, 296]
	ldr	x2, [sp, 304]
	add	x0, x0, 256
	str	x0, [sp, 96]
	add	x1, x2, x1
	str	x1, [sp, 304]
	ldr	x2, [sp, 312]
	ldr	x1, [sp, 448]
	add	x2, x2, x1
	str	x2, [sp, 312]
	ldr	x2, [sp, 320]
	add	x1, x2, x1
	str	x1, [sp, 320]
	ldr	x1, [sp, 328]
	ldr	x2, [sp, 456]
	add	x1, x1, x2
	str	x1, [sp, 328]
	ldr	w1, [sp, 140]
	cmp	w1, w0
	bgt	.L34
	ldp	x19, x20, [sp, 16]
	.cfi_restore 20
	.cfi_restore 19
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
.L11:
	ldp	x29, x30, [sp]
	ldp	x21, x22, [sp, 32]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 544
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 21
	.cfi_restore 22
	.cfi_def_cfa_offset 0
	ret
.L154:
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
	ldr	x1, [sp, 304]
	mov	w19, w2
	ldr	x0, [sp, 432]
	mov	w30, 8
	ldr	w17, [sp, 356]
	mov	w18, 1
	add	x22, x0, x1
	ldr	x1, [sp, 104]
	mov	x16, x22
	ldr	x10, [sp, 184]
	add	x0, x1, x2, lsl 3
	stp	x0, x21, [sp, 112]
.L17:
	ldr	w0, [sp, 272]
	sub	w7, w0, w17
	cmp	w7, 8
	csel	w8, w7, w30, le
	cmp	w24, w19
	ble	.L22
	ldp	x14, x0, [sp, 312]
	cmp	w7, 0
	csel	w8, w8, w18, gt
	add	x21, x20, x16, lsl 3
	ldr	w13, [sp, 156]
	mov	x12, x21
	ldr	x15, [sp, 328]
	and	w6, w8, -2
	add	x9, x0, 8
	add	x0, sp, 512
	lsr	w5, w8, 1
	mov	x11, x16
	stp	xzr, xzr, [sp, 480]
	stp	xzr, xzr, [sp, 496]
	stp	xzr, xzr, [x0]
	stp	xzr, xzr, [x0, 16]
.L83:
	ldr	d2, [x14]
	cmp	w7, 0
	ble	.L25
	cmp	w7, 1
	ble	.L85
	ldr	q0, [x12]
	ldr	q3, [sp, 480]
	dup	v1.2d, v2.d[0]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x12]
	cmp	w5, 1
	bls	.L24
	ldr	q0, [x12, 16]
	ldr	q3, [sp, 496]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x12, 16]
	cmp	w5, 2
	beq	.L24
	ldr	q0, [x12, 32]
	ldr	q3, [sp, 512]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x12, 32]
	cmp	w5, 3
	beq	.L24
	ldr	q0, [x12, 48]
	ldr	q3, [sp, 528]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x12, 48]
.L24:
	sxtw	x0, w6
	cmp	w6, w8
	beq	.L25
.L23:
	add	x1, x0, x11
	ldr	d1, [x26, x0, lsl 3]
	ldr	d0, [x20, x1, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x20, x1, lsl 3]
.L25:
	add	w13, w13, 1
	cmp	w24, w13
	beq	.L22
	add	x0, sp, 512
	stp	xzr, xzr, [sp, 480]
	stp	xzr, xzr, [sp, 496]
	stp	xzr, xzr, [x0]
	stp	xzr, xzr, [x0, 16]
	cmp	w13, w19
	ble	.L27
	cmp	w7, 0
	ble	.L27
	ldr	x0, [sp, 112]
	mov	x3, x21
	mov	x2, x16
	add	x4, x0, x15, lsl 3
	.p2align 3,,7
.L30:
	ldr	d0, [x4]
	cmp	w7, 1
	ble	.L156
	dup	v3.2d, v0.d[0]
	ldr	q2, [x3]
	ldr	q1, [sp, 480]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 480]
	cmp	w5, 1
	bls	.L31
	ldr	q2, [x3, 16]
	ldr	q1, [sp, 496]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 496]
	cmp	w5, 2
	beq	.L31
	ldr	q2, [x3, 32]
	ldr	q1, [sp, 512]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 512]
	cmp	w5, 3
	beq	.L31
	ldr	q2, [x3, 48]
	ldr	q1, [sp, 528]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 528]
.L31:
	sxtw	x0, w6
	cmp	w6, w8
	beq	.L32
.L28:
	add	x1, x0, x2
	ldr	d1, [x26, x0, lsl 3]
	ldr	d2, [x20, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x26, x0, lsl 3]
.L32:
	add	x4, x4, 8
	add	x2, x2, x10
	add	x3, x3, x28
	cmp	x4, x9
	bne	.L30
.L27:
	ldr	x0, [sp, 424]
	add	x15, x15, x25
	add	x11, x11, x10
	add	x12, x12, x28
	add	x14, x14, x0
	add	x9, x9, x0
	b	.L83
.L156:
	mov	x0, 0
	b	.L28
.L85:
	mov	x0, 0
	b	.L23
.L22:
	ldr	w0, [sp, 360]
	add	w17, w17, 8
	add	x16, x16, 8
	cmp	w0, w17
	bgt	.L17
	ldr	x21, [sp, 120]
	bl	GOMP_barrier
	ldr	x0, [sp, 336]
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L79
	cmp	w24, w19
	ble	.L71
	mvn	w0, w23
	ldr	w4, [sp, 356]
	add	w0, w0, w24
	ldr	w5, [sp, 416]
	add	x0, x0, 1
	add	x6, x20, x22, lsl 3
	mov	x7, x27
	mov	w22, w5
	lsl	x9, x0, 6
	mov	x5, x25
	mov	x27, x9
	mov	x25, x3
	mov	w9, w23
	mov	w3, w24
	mov	w23, w4
	mov	x24, x6
	mov	x4, x20
	mov	x6, x21
	mov	w11, 8
	mov	w10, 7
	mov	x8, 8
.L74:
	cmp	w22, 8
	add	w19, w23, 7
	csel	w0, w22, w11, le
	cmp	w23, 0
	csel	w19, w19, w23, lt
	sub	w21, w10, w0
	add	x21, x21, 1
	cmp	w22, 7
	asr	w19, w19, 3
	sbfiz	x12, x0, 3, 32
	lsl	x21, x21, 3
	mov	x20, x24
	sbfiz	x19, x19, 14, 32
	csel	x21, x21, x8, le
	add	x19, x25, x19
	stp	x25, x24, [sp, 112]
	add	x13, x27, x19
	mov	w25, w3
	mov	x24, x12
	str	x27, [sp, 144]
	mov	w27, w23
	mov	x23, x13
.L75:
	cmp	w22, 0
	ble	.L73
	ldr	d0, [x20]
	str	d0, [x19]
	cmp	w22, 1
	ble	.L78
	ldr	d0, [x20, 8]
	str	d0, [x19, 8]
	cmp	w22, 2
	beq	.L73
	ldr	d0, [x20, 16]
	str	d0, [x19, 16]
	cmp	w22, 3
	beq	.L73
	ldr	d0, [x20, 24]
	str	d0, [x19, 24]
	cmp	w22, 4
	beq	.L73
	ldr	d0, [x20, 32]
	str	d0, [x19, 32]
	cmp	w22, 5
	beq	.L73
	ldr	d0, [x20, 40]
	str	d0, [x19, 40]
	cmp	w22, 6
	beq	.L73
	ldr	d0, [x20, 48]
	str	d0, [x19, 48]
	cmp	w22, 7
	ble	.L73
	ldr	d0, [x20, 56]
	str	d0, [x19, 56]
.L78:
	cmp	w22, 7
	bgt	.L77
.L73:
	mov	x2, x21
	add	x0, x19, x24
	mov	w1, 0
	stp	x4, x5, [sp, 160]
	str	x6, [sp, 176]
	str	x7, [sp, 264]
	str	w9, [sp, 276]
	bl	memset
	ldp	x4, x5, [sp, 160]
	mov	w11, 8
	ldr	w9, [sp, 276]
	mov	w10, 7
	ldr	x6, [sp, 176]
	mov	x8, 8
	ldr	x7, [sp, 264]
.L77:
	add	x19, x19, 64
	add	x20, x20, x28
	cmp	x19, x23
	bne	.L75
	mov	w3, w25
	ldr	w0, [sp, 360]
	ldp	x25, x24, [sp, 112]
	add	w23, w27, 8
	sub	w22, w22, #8
	ldr	x27, [sp, 144]
	add	x24, x24, 64
	cmp	w0, w23
	bgt	.L74
	mov	w24, w3
	mov	x20, x4
	mov	x25, x5
	mov	x21, x6
	mov	x27, x7
	mov	w23, w9
	b	.L71
.L155:
	ldr	w3, [sp, 364]
	sub	w4, w24, w23
	sub	w1, w1, #1
	ldr	w19, [sp, 96]
	str	w1, [sp, 420]
	sub	w1, w4, #1
	str	w19, [sp, 344]
	udiv	w2, w0, w3
	ldr	w19, [sp, 348]
	str	x1, [sp, 368]
	ldr	x22, [sp, 336]
	str	w4, [sp, 176]
	msub	w0, w2, w3, w0
	add	w1, w24, w2, lsl 6
	ldr	w2, [sp, 140]
	str	w1, [sp, 288]
	lsl	w0, w0, 6
	sub	w1, w2, w1
	str	w0, [sp, 168]
	str	wzr, [sp, 292]
	str	w1, [sp, 376]
.L38:
	ldr	w3, [sp, 168]
	ldr	w4, [sp, 272]
	ldr	w0, [sp, 376]
	add	w15, w3, 64
	ldr	w2, [sp, 288]
	ldr	w5, [sp, 140]
	cmp	w0, 63
	add	w1, w2, 64
	sub	w0, w4, w3
	csel	w1, w1, w5, gt
	cmp	w0, 63
	str	w1, [sp, 276]
	mov	w0, w3
	csel	w15, w15, w4, gt
	mov	w3, w1
	cmp	w2, w1
	bge	.L41
	mov	w1, w0
	cmp	w0, w15
	bge	.L41
	sxtw	x4, w1
	ldr	w1, [sp, 152]
	ldr	x5, [sp, 96]
	smull	x0, w19, w2
	mov	w6, w19
	str	x4, [sp, 384]
	smaddl	x1, w1, w2, x5
	sub	w2, w3, w2
	str	w2, [sp, 160]
	ldr	x2, [sp, 296]
	ldr	x3, [sp, 368]
	sub	x2, x2, x0
	add	x0, x4, x0
	add	x3, x3, 1
	lsl	x2, x2, 3
	add	x0, x20, x0, lsl 3
	str	x0, [sp, 280]
	mov	x0, x1
	str	x2, [sp, 144]
	ldr	x1, [sp, 104]
	str	x3, [sp, 472]
	add	x0, x1, x0, lsl 3
	str	x0, [sp, 120]
.L44:
	ldr	w0, [sp, 160]
	mov	w23, 4
	ldr	x1, [sp, 120]
	cmp	w0, 4
	csel	w23, w0, w23, le
	cmp	w0, 3
	cset	w0, gt
	str	w0, [sp, 112]
	ldr	x0, [sp, 472]
	ldr	w13, [sp, 168]
	ldr	x12, [sp, 280]
	add	x14, x1, x0, lsl 3
	ldr	x18, [sp, 384]
	.p2align 3,,7
.L42:
	sub	w10, w15, w13
	ldr	x0, [x22, 16]
	ldr	x3, [x0]
	cbz	x3, .L157
	asr	w0, w13, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 112]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	ble	.L158
.L47:
	ldr	w0, [sp, 136]
	cbnz	w0, .L63
	movi	v16.2d, 0
	ldr	w0, [sp, 176]
	cmp	w0, 0
	ble	.L89
	mov	v17.16b, v16.16b
	lsl	x8, x8, 3
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
	ldr	x0, [sp, 120]
	.p2align 3,,7
.L65:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, x8
	ld1r	{v7.2d}, [x0]
	ldr	d6, [x0, x25, lsl 3]
	ldr	d5, [x0, x21, lsl 3]
	fmla	v31.2d, v4.2d, v7.2d
	ldr	d1, [x0, x27, lsl 3]
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
	bne	.L65
.L64:
	ldp	q3, q2, [x12]
	add	x0, x28, x12
	ldp	q1, q0, [x12, 32]
	add	x1, x28, x0
	fsub	v3.2d, v3.2d, v31.2d
	fsub	v2.2d, v2.2d, v30.2d
	fsub	v0.2d, v0.2d, v28.2d
	fsub	v1.2d, v1.2d, v29.2d
	stp	q3, q2, [x12]
	stp	q1, q0, [x12, 32]
	ldr	q0, [x28, x12]
	fsub	v0.2d, v0.2d, v27.2d
	str	q0, [x28, x12]
	ldr	x2, [sp, 192]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v26.2d
	str	q0, [x2, x12]
	ldr	x2, [sp, 200]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v25.2d
	str	q0, [x2, x12]
	ldr	x2, [sp, 208]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v24.2d
	str	q0, [x2, x12]
	ldr	q0, [x28, x0]
	fsub	v0.2d, v0.2d, v23.2d
	str	q0, [x28, x0]
	ldr	x0, [sp, 216]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v22.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 224]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v21.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 232]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v20.2d
	str	q0, [x0, x12]
	ldr	q0, [x1, x28]
	fsub	v0.2d, v0.2d, v19.2d
	str	q0, [x1, x28]
	ldr	x0, [sp, 240]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v18.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 248]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v17.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 256]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v16.2d
	str	q0, [x0, x12]
.L66:
	add	w13, w13, 8
	add	x12, x12, 64
	add	x18, x18, 8
	cmp	w15, w13
	bgt	.L42
	ldr	x1, [sp, 120]
	ldr	x2, [sp, 408]
	ldr	x3, [sp, 464]
	add	x1, x1, x2
	ldr	x2, [sp, 144]
	str	x1, [sp, 120]
	ldr	w0, [sp, 160]
	add	x2, x2, x3
	str	x2, [sp, 144]
	ldr	x2, [sp, 280]
	sub	w0, w0, #4
	ldr	x3, [sp, 392]
	str	w0, [sp, 160]
	ldr	w1, [sp, 276]
	add	x2, x2, x3
	str	x2, [sp, 280]
	sub	w0, w1, w0
	cmp	w1, w0
	bgt	.L44
	mov	w19, w6
.L41:
	ldr	w0, [sp, 292]
	ldr	w1, [sp, 420]
	cmp	w0, w1
	beq	.L36
	ldr	w0, [sp, 168]
	ldr	w1, [sp, 272]
	add	w0, w0, 64
	str	w0, [sp, 168]
	cmp	w1, w0
	ble	.L159
.L43:
	ldr	w0, [sp, 292]
	add	w0, w0, 1
	str	w0, [sp, 292]
	b	.L38
.L63:
	ldp	w2, w0, [sp, 152]
	mov	x5, x12
	ldr	x1, [sp, 120]
	sub	w0, w24, w0
	bl	update4x8_sve
	b	.L66
.L157:
	ldr	x0, [sp, 144]
	mov	w4, w6
	ldr	x8, [sp, 184]
	add	x3, x0, x12
	ldr	w0, [sp, 112]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	bgt	.L47
.L158:
	ldr	w0, [sp, 160]
	cmp	w0, 0
	ble	.L66
	cmp	w10, 8
	mov	w16, 8
	csel	w16, w10, w16, le
	cmp	w10, 0
	csinc	w16, w16, wzr, gt
	ldr	w1, [sp, 276]
	str	x12, [sp, 264]
	and	w9, w16, -2
	ldr	w12, [sp, 344]
	lsl	x17, x8, 3
	lsr	w5, w16, 1
	sub	w19, w1, w0
	mov	w30, 0
.L53:
	add	x0, sp, 512
	stp	xzr, xzr, [sp, 480]
	stp	xzr, xzr, [sp, 496]
	stp	xzr, xzr, [x0]
	stp	xzr, xzr, [x0, 16]
	cmp	w24, w12
	ble	.L160
	sxtw	x11, w19
	cmp	w10, 0
	ble	.L56
	ldp	x7, x1, [sp, 96]
	mov	x4, x3
	ldr	x0, [sp, 128]
	mov	x2, 0
	madd	x11, x11, x0, x1
	.p2align 3,,7
.L60:
	ldr	d0, [x11, x7, lsl 3]
	cmp	w10, 1
	ble	.L161
	dup	v3.2d, v0.d[0]
	ldr	q2, [x4]
	ldr	q1, [sp, 480]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 480]
	cmp	w5, 1
	bls	.L61
	ldr	q2, [x4, 16]
	ldr	q1, [sp, 496]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 496]
	cmp	w5, 2
	beq	.L61
	ldr	q2, [x4, 32]
	ldr	q1, [sp, 512]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 512]
	cmp	w5, 3
	beq	.L61
	ldr	q2, [x4, 48]
	ldr	q1, [sp, 528]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 528]
.L61:
	sxtw	x0, w9
	cmp	w9, w16
	beq	.L62
.L58:
	add	x1, x0, x2
	ldr	d1, [x26, x0, lsl 3]
	ldr	d2, [x3, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x26, x0, lsl 3]
.L62:
	add	x7, x7, 1
	add	x2, x2, x8
	add	x4, x4, x17
	cmp	w24, w7
	bgt	.L60
	smaddl	x0, w19, w6, x18
	cmp	w10, 1
	ble	.L87
.L162:
	lsl	x2, x0, 3
	ldr	q1, [sp, 480]
	add	x1, x20, x2
	ldr	q0, [x20, x2]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x20, x2]
	cmp	w5, 1
	bls	.L55
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 496]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w5, 2
	beq	.L55
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 512]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w5, 3
	beq	.L55
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 528]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L55:
	sxtw	x1, w9
	cmp	w9, w16
	beq	.L56
.L54:
	add	x0, x1, x0
	ldr	d1, [x26, x1, lsl 3]
	ldr	d0, [x20, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x20, x0, lsl 3]
.L56:
	add	w30, w30, 1
	add	w19, w19, 1
	cmp	w30, w23
	blt	.L53
	ldr	x12, [sp, 264]
	b	.L66
	.p2align 2,,3
.L161:
	mov	x0, 0
	b	.L58
.L160:
	cmp	w10, 0
	ble	.L56
	smaddl	x0, w19, w6, x18
	cmp	w10, 1
	bgt	.L162
.L87:
	mov	x1, 0
	b	.L54
.L89:
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
	b	.L64
.L159:
	ldr	w0, [sp, 288]
	ldr	w1, [sp, 140]
	add	w0, w0, 64
	str	wzr, [sp, 168]
	str	w0, [sp, 288]
	sub	w0, w1, w0
	str	w0, [sp, 376]
	b	.L43
.L37:
	add	w1, w1, 1
	mov	w0, 0
	b	.L70
	.cfi_endproc
.LFE4284:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4285:
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
	blt	.L165
.L217:
	madd	w0, w1, w2, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L166
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
.L169:
	ldr	w0, [sp, 188]
	mov	w19, 8
	cmp	w0, 8
	csel	w19, w0, w19, le
	cbz	x25, .L280
	ldr	w0, [sp, 128]
	cmp	w0, 0
	ble	.L170
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
.L208:
	mov	x2, x19
	mov	x1, x25
	mov	x0, x24
	cmp	w28, 0
	ble	.L172
	bl	memcpy
	cmp	w28, 7
	bgt	.L210
.L172:
	mov	x2, x21
	add	x0, x24, x22
	mov	w1, 0
	bl	memset
.L210:
	add	x24, x24, 64
	add	x25, x25, x23
	cmp	x24, x20
	bne	.L208
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
	ble	.L176
	movi	v0.2d, 0
	stp	q0, q0, [sp, 336]
	stp	q0, q0, [sp, 368]
	stp	q0, q0, [sp, 400]
	stp	q0, q0, [sp, 432]
	stp	q0, q0, [sp, 464]
	stp	q0, q0, [sp, 496]
	stp	q0, q0, [sp, 528]
	stp	q0, q0, [sp, 560]
.L176:
	sub	w9, w19, #1
	mov	x3, x27
	add	x0, sp, 336
	mov	x1, x25
	mov	x6, x28
	mov	w2, 0
.L202:
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
	beq	.L281
	add	w7, w2, 1
	cmp	w7, 0
	ble	.L207
	cmp	w2, 1
	ble	.L222
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
.L206:
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
	bge	.L207
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
	ble	.L207
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
.L207:
	add	x6, x6, x26
	add	x1, x1, 64
	add	x0, x0, 64
	add	x3, x3, x27
	mov	w2, w7
	b	.L202
.L281:
	ldr	w1, [sp, 128]
	cmp	w1, 4
	ble	.L177
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
.L201:
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
	ble	.L282
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
.L195:
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
	bgt	.L195
	stp	q31, q30, [sp, 336]
	stp	q29, q28, [sp, 368]
	stp	q27, q26, [sp, 400]
	stp	q25, q24, [sp, 432]
	stp	q23, q22, [sp, 464]
	stp	q21, q20, [sp, 496]
	stp	q19, q18, [sp, 528]
	stp	q17, q16, [sp, 560]
.L180:
	ldr	w0, [sp, 184]
	ldp	x5, x4, [sp, 104]
	sub	w14, w0, #1
	mov	x1, x19
	add	x0, sp, 336
	mov	w3, 0
.L198:
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
	beq	.L196
	add	w7, w3, 1
	cmp	w7, 0
	ble	.L200
	cmp	w3, 1
	ble	.L221
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
.L199:
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
	bge	.L200
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
	bge	.L200
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
.L200:
	add	x5, x5, x10
	add	x1, x1, 64
	add	x0, x0, 64
	add	x4, x4, x27
	mov	w3, w7
	b	.L198
.L196:
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
	blt	.L201
	ldr	x23, [sp, 312]
	mov	x26, x10
	mov	x24, x13
.L177:
	ldr	w0, [sp, 188]
	cmp	w0, 0
	ble	.L170
	ldr	x3, [sp, 192]
	mov	x19, x25
	ldr	x21, [sp, 216]
	ldr	x20, [sp, 232]
.L174:
	mov	x1, x19
	mov	x0, x3
	mov	x2, x20
	add	x19, x19, 64
	bl	memcpy
	add	x3, x0, x23
	cmp	x19, x21
	bne	.L174
.L170:
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
	bgt	.L169
.L166:
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
.L282:
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
	b	.L182
	.p2align 2,,3
.L284:
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
	ble	.L220
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
.L181:
	add	x1, x1, 64
	add	x2, x2, 8
	cmp	x5, x1
	beq	.L283
.L182:
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
	beq	.L181
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
	bne	.L284
	add	x1, x1, 64
	mov	w3, 1
	add	x2, x2, 8
	mov	w8, w3
	mov	w14, w3
	mov	w15, w3
	cmp	x5, x1
	bne	.L182
.L283:
	stp	q16, q7, [sp, 336]
	stp	q6, q5, [sp, 368]
	cbz	w30, .L183
	str	q24, [sp, 528]
.L183:
	cbz	w12, .L184
	str	q27, [sp, 544]
.L184:
	cbz	w11, .L185
	str	q26, [sp, 560]
.L185:
	cbz	w9, .L186
	str	q25, [sp, 576]
.L186:
	cbz	w15, .L187
	str	q20, [sp, 400]
.L187:
	cbz	w14, .L188
	str	q19, [sp, 416]
.L188:
	cbz	w8, .L189
	str	q18, [sp, 432]
.L189:
	cbz	w3, .L190
	str	q17, [sp, 448]
.L190:
	cbz	w18, .L191
	str	q23, [sp, 464]
.L191:
	cbz	w17, .L192
	str	q22, [sp, 480]
.L192:
	cbz	w16, .L193
	str	q21, [sp, 496]
.L193:
	cbz	w0, .L180
	str	q4, [sp, 512]
	b	.L180
	.p2align 2,,3
.L220:
	mov	w0, 1
	mov	w16, w0
	mov	w17, w0
	mov	w18, w0
	mov	w3, w0
	mov	w8, w0
	mov	w14, w0
	mov	w15, w0
	b	.L181
.L222:
	mov	w4, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L206
.L221:
	mov	w2, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L199
.L280:
	ldr	w0, [sp, 224]
	add	w19, w0, w19
	cmp	w0, w19
	bge	.L170
	ldr	w7, [sp, 128]
	cmp	w7, 0
	ble	.L170
	ldr	x8, [sp, 192]
	ldr	x9, [sp, 208]
.L215:
	ldr	d0, [x8]
	ldr	d1, [x28]
	fdiv	d0, d0, d1
	str	d0, [x8]
	cmp	w7, 1
	beq	.L212
	ldp	x5, x2, [sp, 264]
	add	x3, x8, x23
	mov	x6, x27
	mov	w4, 1
	.p2align 3,,7
.L214:
	movi	d1, #0
	add	x1, x28, x6, lsl 3
	mov	x0, x8
	.p2align 3,,7
.L213:
	ldr	d2, [x0]
	add	x0, x0, x23
	ldr	d0, [x1], 8
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	x2, x1
	bne	.L213
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
	bne	.L214
.L212:
	add	x9, x9, 1
	add	x8, x8, 8
	cmp	w19, w9
	bgt	.L215
	b	.L170
.L165:
	add	w1, w1, 1
	mov	w0, 0
	b	.L217
	.cfi_endproc
.LFE4285:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4283:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L291
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
	bls	.L287
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L288
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L289:
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
.L287:
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
.L291:
	ret
	.p2align 2,,3
.L288:
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
	b	.L289
	.cfi_endproc
.LFE4283:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (GNU) 10.3.1"
	.section	.note.GNU-stack,"",@progbits
