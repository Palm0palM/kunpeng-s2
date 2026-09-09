	.arch armv8-a
	.file	"trsm.c"
	.text
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
	.type	trsm_sve_has_eight_doubles, %function
trsm_sve_has_eight_doubles:
.LFB4278:
	.cfi_startproc
	cntd	x0
	cmp	x0, 8
	cset	w0, eq
	ret
	.cfi_endproc
.LFE4278:
	.size	trsm_sve_has_eight_doubles, .-trsm_sve_has_eight_doubles
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4284:
	.cfi_startproc
	sub	sp, sp, #528
	.cfi_def_cfa_offset 528
	stp	x29, x30, [sp]
	.cfi_offset 29, -528
	.cfi_offset 30, -520
	mov	x29, sp
	ldp	w1, w6, [x0, 24]
	stp	x19, x20, [sp, 16]
	stp	x23, x24, [sp, 48]
	.cfi_offset 19, -512
	.cfi_offset 20, -504
	.cfi_offset 23, -480
	.cfi_offset 24, -472
	ldp	w23, w8, [x0, 32]
	str	w8, [sp, 128]
	ldp	x9, x20, [x0]
	str	x9, [sp, 112]
	stp	w1, w6, [sp, 248]
	str	x0, [sp, 328]
	str	w23, [sp, 360]
	cmp	w1, 0
	ble	.L6
	mov	w19, w6
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -488
	.cfi_offset 21, -496
	mov	w21, w8
	mov	x22, x9
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -456
	.cfi_offset 25, -464
	sxtw	x26, w23
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -440
	.cfi_offset 27, -448
	bl	omp_get_num_threads
	mov	w24, w0
	str	w0, [sp, 364]
	bl	omp_get_thread_num
	adds	w2, w19, 7
	add	w1, w19, 14
	mov	w13, w0
	csel	w0, w1, w2, mi
	sxtw	x7, w21
	mov	w2, 24
	add	x1, x7, 1
	asr	w0, w0, 3
	smull	x2, w21, w2
	mov	w11, w24
	lsl	x10, x1, 4
	add	x5, x26, 1
	sdiv	w1, w0, w24
	add	x8, x10, 16
	stp	x10, x8, [sp, 192]
	add	x8, x10, 32
	lsl	x12, x26, 3
	str	x8, [sp, 208]
	add	x8, x2, 16
	str	x8, [sp, 216]
	add	x8, x2, 32
	add	x2, x2, 48
	msub	w0, w1, w11, w0
	add	x4, x22, 8
	stp	x8, x2, [sp, 224]
	lsl	x2, x5, 11
	str	x2, [sp, 432]
	add	x2, x4, x12
	cmp	w13, w0
	str	x2, [sp, 312]
	add	x2, x12, 8
	cinc	w1, w1, lt
	str	x2, [sp, 408]
	lsl	x2, x7, 8
	str	x2, [sp, 424]
	lsl	x2, x26, 8
	str	x2, [sp, 440]
	neg	x2, x7, lsl 5
	str	x2, [sp, 448]
	mul	w2, w1, w13
	sbfiz	x25, x21, 3, 32
	sbfiz	x24, x23, 1, 32
	add	w0, w2, w0
	add	w3, w19, 63
	csel	w0, w2, w0, lt
	add	x2, x25, 16
	add	w1, w1, w0
	str	w0, [sp, 396]
	lsl	w0, w0, 3
	add	x27, x24, x26
	lsl	x4, x7, 5
	str	x2, [sp, 168]
	add	x2, x25, 32
	str	w1, [sp, 392]
	lsl	w1, w1, 3
	mov	x9, x22
	asr	w3, w3, 6
	mov	x22, x27
	mov	x23, x25
	mov	x27, x26
	add	x28, sp, 464
	str	x12, [sp, 120]
	str	x2, [sp, 176]
	add	x2, x25, 48
	mov	x25, x24
	str	x2, [sp, 184]
	str	x7, [sp, 272]
	stp	xzr, x9, [sp, 296]
	str	x26, [sp, 320]
	str	w13, [sp, 340]
	str	w0, [sp, 344]
	str	w1, [sp, 348]
	sub	w1, w19, w0
	sxtw	x0, w0
	str	w3, [sp, 352]
	str	x4, [sp, 384]
	lsl	x4, x26, 5
	mov	x26, x20
	str	x4, [sp, 368]
	str	w1, [sp, 400]
	str	x0, [sp, 416]
	str	xzr, [sp, 288]
	str	xzr, [sp, 104]
.L28:
	ldr	x2, [sp, 104]
	str	w2, [sp, 132]
	ldr	w3, [sp, 248]
	add	w0, w2, 256
	mov	w18, w2
	sub	w1, w3, w2
	cmp	w1, 255
	ldr	w1, [sp, 396]
	csel	w24, w0, w3, gt
	ldr	w0, [sp, 392]
	cmp	w0, w1
	bgt	.L145
	bl	GOMP_barrier
	ldr	x0, [sp, 328]
	ldr	x0, [x0, 16]
	ldr	x0, [x0]
	cbz	x0, .L72
.L64:
	bl	GOMP_barrier
.L72:
	ldr	w0, [sp, 248]
	cmp	w24, w0
	bge	.L30
	ldr	w0, [sp, 248]
	add	w1, w0, 63
	subs	w1, w1, w24
	add	w0, w1, 63
	csel	w0, w0, w1, mi
	ldr	w1, [sp, 252]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L30
	ldr	w1, [sp, 352]
	mul	w0, w0, w1
	ldr	w1, [sp, 364]
	udiv	w2, w0, w1
	msub	w0, w2, w1, w0
	ldr	w1, [sp, 340]
	cmp	w1, w0
	bcc	.L31
.L63:
	ldr	w1, [sp, 340]
	madd	w0, w2, w1, w0
	add	w1, w2, w0
	cmp	w0, w1
	bcc	.L146
.L30:
	bl	GOMP_barrier
	ldr	x2, [sp, 288]
	ldr	x1, [sp, 424]
	ldr	x0, [sp, 104]
	add	x2, x2, x1
	str	x2, [sp, 288]
	ldr	x2, [sp, 296]
	add	x0, x0, 256
	str	x0, [sp, 104]
	add	x1, x2, x1
	str	x1, [sp, 296]
	ldr	x2, [sp, 304]
	ldr	x1, [sp, 432]
	add	x2, x2, x1
	str	x2, [sp, 304]
	ldr	x2, [sp, 312]
	add	x1, x2, x1
	str	x1, [sp, 312]
	ldr	x1, [sp, 320]
	ldr	x2, [sp, 440]
	add	x1, x1, x2
	str	x1, [sp, 320]
	ldr	w1, [sp, 248]
	cmp	w1, w0
	bgt	.L28
	ldp	x21, x22, [sp, 32]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L6:
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x23, x24, [sp, 48]
	add	sp, sp, 528
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L145:
	.cfi_def_cfa_offset 528
	.cfi_offset 19, -512
	.cfi_offset 20, -504
	.cfi_offset 21, -496
	.cfi_offset 22, -488
	.cfi_offset 23, -480
	.cfi_offset 24, -472
	.cfi_offset 25, -464
	.cfi_offset 26, -456
	.cfi_offset 27, -448
	.cfi_offset 28, -440
	.cfi_offset 29, -528
	.cfi_offset 30, -520
	ldr	x1, [sp, 296]
	mov	w30, 1
	ldr	x0, [sp, 416]
	ldr	w17, [sp, 344]
	add	x20, x0, x1
	str	x20, [sp, 136]
	ldp	x0, x1, [sp, 104]
	mov	x16, x20
	ldr	x11, [sp, 272]
	mov	w19, w0
	add	x21, x1, x0, lsl 3
.L11:
	ldr	w0, [sp, 252]
	sub	w7, w0, w17
	mov	w0, 8
	cmp	w7, 8
	csel	w8, w7, w0, le
	cmp	w24, w19
	ble	.L16
	cmp	w7, 0
	add	x0, sp, 512
	ldp	x14, x10, [sp, 304]
	csel	w8, w8, w30, gt
	add	x20, x26, x16, lsl 3
	and	w6, w8, -2
	ldr	x15, [sp, 320]
	mov	x9, x20
	mov	x12, x16
	lsr	w5, w8, 1
	mov	w13, w18
	stp	xzr, xzr, [sp, 464]
	stp	xzr, xzr, [sp, 480]
	stp	xzr, xzr, [sp, 496]
	stp	xzr, xzr, [x0]
.L75:
	ldr	d2, [x14]
	cmp	w7, 0
	ble	.L19
	cmp	w7, 1
	ble	.L77
	ldr	q0, [x9]
	ldr	q3, [sp, 464]
	dup	v1.2d, v2.d[0]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x9]
	cmp	w5, 1
	bls	.L18
	ldr	q0, [x9, 16]
	ldr	q3, [sp, 480]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x9, 16]
	cmp	w5, 2
	beq	.L18
	ldr	q0, [x9, 32]
	ldr	q3, [sp, 496]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x9, 32]
	cmp	w5, 3
	beq	.L18
	ldr	q0, [x9, 48]
	ldr	q3, [sp, 512]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x9, 48]
.L18:
	sxtw	x0, w6
	cmp	w6, w8
	beq	.L19
.L17:
	add	x1, x0, x12
	ldr	d1, [x28, x0, lsl 3]
	ldr	d0, [x26, x1, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x26, x1, lsl 3]
.L19:
	add	w13, w13, 1
	cmp	w24, w13
	beq	.L16
	add	x0, sp, 512
	stp	xzr, xzr, [sp, 464]
	stp	xzr, xzr, [sp, 480]
	stp	xzr, xzr, [sp, 496]
	stp	xzr, xzr, [x0]
	cmp	w13, w19
	ble	.L21
	cmp	w7, 0
	ble	.L21
	add	x4, x21, x15, lsl 3
	mov	x3, x20
	mov	x2, x16
.L24:
	ldr	d0, [x4]
	cmp	w7, 1
	ble	.L147
	dup	v3.2d, v0.d[0]
	ldr	q2, [x3]
	ldr	q1, [sp, 464]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 464]
	cmp	w5, 1
	bls	.L25
	ldr	q2, [x3, 16]
	ldr	q1, [sp, 480]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 480]
	cmp	w5, 2
	beq	.L25
	ldr	q2, [x3, 32]
	ldr	q1, [sp, 496]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 496]
	cmp	w5, 3
	beq	.L25
	ldr	q2, [x3, 48]
	ldr	q1, [sp, 512]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 512]
.L25:
	sxtw	x0, w6
	cmp	w6, w8
	beq	.L26
.L22:
	add	x1, x0, x2
	ldr	d1, [x28, x0, lsl 3]
	ldr	d2, [x26, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x28, x0, lsl 3]
.L26:
	add	x4, x4, 8
	add	x2, x2, x11
	add	x3, x3, x23
	cmp	x4, x10
	bne	.L24
.L21:
	ldr	x0, [sp, 408]
	add	x15, x15, x27
	add	x12, x12, x11
	add	x9, x9, x23
	add	x14, x14, x0
	add	x10, x10, x0
	b	.L75
.L147:
	mov	x0, 0
	b	.L22
.L77:
	mov	x0, 0
	b	.L17
.L16:
	ldr	w0, [sp, 348]
	add	w17, w17, 8
	add	x16, x16, 8
	cmp	w0, w17
	bgt	.L11
	ldr	x20, [sp, 136]
	bl	GOMP_barrier
	ldr	x0, [sp, 328]
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L72
	cmp	w24, w19
	ble	.L64
	ldr	w0, [sp, 132]
	add	x5, x26, x20, lsl 3
	ldr	w4, [sp, 344]
	mov	x10, x22
	mvn	w0, w0
	ldr	w20, [sp, 400]
	add	w0, w0, w24
	mov	w9, 8
	add	x0, x0, 1
	mov	w8, 7
	mov	x6, 8
	lsl	x7, x0, 6
	mov	x0, x7
	mov	x7, x25
	mov	x25, x23
	mov	w23, w4
	mov	x4, x26
	mov	x26, x3
	mov	w3, w24
	mov	x24, x5
	mov	x5, x27
	mov	x27, x0
.L67:
	cmp	w20, 8
	add	w19, w23, 7
	csel	w1, w20, w9, le
	cmp	w23, 0
	csel	w19, w19, w23, lt
	sub	w0, w8, w1
	add	x0, x0, 1
	cmp	w20, 7
	asr	w19, w19, 3
	sbfiz	x11, x1, 3, 32
	lsl	x0, x0, 3
	mov	x21, x24
	sbfiz	x19, x19, 14, 32
	csel	x22, x0, x6, le
	add	x19, x26, x19
	stp	x26, x24, [sp, 136]
	add	x12, x27, x19
	mov	w26, w3
	mov	x24, x11
	str	x27, [sp, 152]
	mov	w27, w23
	mov	x23, x12
.L68:
	cmp	w20, 0
	ble	.L66
	ldr	d0, [x21]
	str	d0, [x19]
	cmp	w20, 1
	ble	.L71
	ldr	d0, [x21, 8]
	str	d0, [x19, 8]
	cmp	w20, 2
	beq	.L66
	ldr	d0, [x21, 16]
	str	d0, [x19, 16]
	cmp	w20, 3
	beq	.L66
	ldr	d0, [x21, 24]
	str	d0, [x19, 24]
	cmp	w20, 4
	beq	.L66
	ldr	d0, [x21, 32]
	str	d0, [x19, 32]
	cmp	w20, 5
	beq	.L66
	ldr	d0, [x21, 40]
	str	d0, [x19, 40]
	cmp	w20, 6
	beq	.L66
	ldr	d0, [x21, 48]
	str	d0, [x19, 48]
	cmp	w20, 7
	ble	.L66
	ldr	d0, [x21, 56]
	str	d0, [x19, 56]
.L71:
	cmp	w20, 7
	bgt	.L70
.L66:
	mov	x2, x22
	add	x0, x19, x24
	mov	w1, 0
	str	x4, [sp, 160]
	str	x5, [sp, 240]
	stp	x7, x10, [sp, 256]
	bl	memset
	mov	w9, 8
	ldp	x7, x10, [sp, 256]
	mov	w8, 7
	ldr	x4, [sp, 160]
	mov	x6, 8
	ldr	x5, [sp, 240]
.L70:
	add	x19, x19, 64
	add	x21, x21, x25
	cmp	x19, x23
	bne	.L68
	mov	w3, w26
	ldr	w0, [sp, 348]
	ldp	x26, x24, [sp, 136]
	add	w23, w27, 8
	sub	w20, w20, #8
	ldr	x27, [sp, 152]
	add	x24, x24, 64
	cmp	w0, w23
	bgt	.L67
	mov	x23, x25
	mov	w24, w3
	mov	x26, x4
	mov	x27, x5
	mov	x22, x10
	mov	x25, x7
	bl	GOMP_barrier
	b	.L72
.L146:
	ldr	w4, [sp, 352]
	sub	w2, w2, #1
	ldr	w3, [sp, 132]
	str	w2, [sp, 404]
	sub	w3, w24, w3
	str	w3, [sp, 160]
	udiv	w1, w0, w4
	sub	w3, w3, #1
	add	x2, x3, 1
	ldr	w30, [sp, 104]
	ldr	x21, [sp, 328]
	lsl	x2, x2, 3
	msub	w0, w1, w4, w0
	str	x2, [sp, 456]
	ldr	w2, [sp, 248]
	add	w1, w24, w1, lsl 6
	str	w1, [sp, 264]
	lsl	w0, w0, 6
	sub	w1, w2, w1
	str	w0, [sp, 152]
	str	wzr, [sp, 336]
	str	w1, [sp, 356]
.L32:
	ldp	w5, w4, [sp, 248]
	ldr	w3, [sp, 152]
	ldr	w0, [sp, 356]
	ldr	w2, [sp, 264]
	add	w19, w3, 64
	cmp	w0, 63
	sub	w0, w4, w3
	add	w1, w2, 64
	csel	w1, w1, w5, gt
	cmp	w0, 63
	str	w1, [sp, 240]
	mov	w0, w3
	csel	w19, w19, w4, gt
	mov	w3, w1
	cmp	w2, w1
	bge	.L35
	cmp	w0, w19
	bge	.L35
	sxtw	x4, w0
	ldr	w0, [sp, 128]
	sub	w1, w3, w2
	str	w1, [sp, 144]
	ldr	x1, [sp, 288]
	str	x4, [sp, 376]
	smull	x0, w0, w2
	ldr	w5, [sp, 360]
	ldr	x6, [sp, 104]
	sub	x1, x1, x0
	add	x0, x4, x0
	lsl	x1, x1, 3
	str	x1, [sp, 256]
	ldr	x1, [sp, 112]
	smaddl	x2, w5, w2, x6
	add	x0, x26, x0, lsl 3
	str	x0, [sp, 280]
	add	x0, x1, x2, lsl 3
	str	x0, [sp, 136]
.L38:
	ldr	w0, [sp, 144]
	ldr	x2, [sp, 136]
	cmp	w0, 4
	ldr	x1, [sp, 456]
	ldr	w16, [sp, 152]
	ldr	x9, [sp, 280]
	add	x17, x1, x2
	ldr	x18, [sp, 376]
	mov	w1, 4
	csel	w20, w0, w1, le
	cmp	w0, 3
	cset	w0, gt
	str	w0, [sp, 132]
.L36:
	ldr	x0, [x21, 16]
	sub	w10, w19, w16
	ldr	x2, [x0]
	cbz	x2, .L148
	asr	w0, w16, 3
	mov	x8, 8
	sbfiz	x0, x0, 14, 32
	add	x2, x2, x0
.L60:
	ldr	w0, [sp, 132]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	ble	.L149
	movi	v16.2d, 0
	ldr	w0, [sp, 160]
	cmp	w0, 0
	ble	.L81
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
	ldr	x0, [sp, 136]
	.p2align 3,,7
.L58:
	ldp	q4, q3, [x2]
	ldp	q2, q0, [x2, 32]
	add	x2, x2, x8
	ld1r	{v7.2d}, [x0]
	ldr	d6, [x0, x27, lsl 3]
	ldr	d5, [x0, x25, lsl 3]
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
	cmp	x0, x17
	bne	.L58
.L57:
	ldp	q3, q2, [x9]
	add	x0, x23, x9
	ldp	q1, q0, [x9, 32]
	add	x1, x23, x0
	fsub	v3.2d, v3.2d, v31.2d
	fsub	v2.2d, v2.2d, v30.2d
	fsub	v0.2d, v0.2d, v28.2d
	fsub	v1.2d, v1.2d, v29.2d
	stp	q3, q2, [x9]
	stp	q1, q0, [x9, 32]
	ldr	q0, [x23, x9]
	fsub	v0.2d, v0.2d, v27.2d
	str	q0, [x23, x9]
	ldr	x2, [sp, 168]
	ldr	q0, [x2, x9]
	fsub	v0.2d, v0.2d, v26.2d
	str	q0, [x2, x9]
	ldr	x2, [sp, 176]
	ldr	q0, [x2, x9]
	fsub	v0.2d, v0.2d, v25.2d
	str	q0, [x2, x9]
	ldr	x2, [sp, 184]
	ldr	q0, [x2, x9]
	fsub	v0.2d, v0.2d, v24.2d
	str	q0, [x2, x9]
	ldr	q0, [x23, x0]
	fsub	v0.2d, v0.2d, v23.2d
	str	q0, [x23, x0]
	ldr	x0, [sp, 192]
	ldr	q0, [x0, x9]
	fsub	v0.2d, v0.2d, v22.2d
	str	q0, [x0, x9]
	ldr	x0, [sp, 200]
	ldr	q0, [x0, x9]
	fsub	v0.2d, v0.2d, v21.2d
	str	q0, [x0, x9]
	ldr	x0, [sp, 208]
	ldr	q0, [x0, x9]
	fsub	v0.2d, v0.2d, v20.2d
	str	q0, [x0, x9]
	ldr	q0, [x1, x23]
	fsub	v0.2d, v0.2d, v19.2d
	str	q0, [x1, x23]
	ldr	x0, [sp, 216]
	ldr	q0, [x0, x9]
	fsub	v0.2d, v0.2d, v18.2d
	str	q0, [x0, x9]
	ldr	x0, [sp, 224]
	ldr	q0, [x0, x9]
	fsub	v0.2d, v0.2d, v17.2d
	str	q0, [x0, x9]
	ldr	x0, [sp, 232]
	ldr	q0, [x0, x9]
	fsub	v0.2d, v0.2d, v16.2d
	str	q0, [x0, x9]
.L59:
	add	w16, w16, 8
	add	x9, x9, 64
	add	x18, x18, 8
	cmp	w19, w16
	bgt	.L36
	ldr	x1, [sp, 256]
	ldr	x2, [sp, 448]
	ldr	x3, [sp, 384]
	add	x1, x1, x2
	ldr	x2, [sp, 280]
	str	x1, [sp, 256]
	ldr	w0, [sp, 144]
	add	x2, x2, x3
	str	x2, [sp, 280]
	ldr	x2, [sp, 136]
	sub	w0, w0, #4
	ldr	x3, [sp, 368]
	str	w0, [sp, 144]
	ldr	w1, [sp, 240]
	add	x2, x2, x3
	str	x2, [sp, 136]
	sub	w0, w1, w0
	cmp	w1, w0
	bgt	.L38
.L35:
	ldr	w0, [sp, 336]
	ldr	w1, [sp, 404]
	cmp	w0, w1
	beq	.L30
	ldr	w0, [sp, 152]
	ldr	w1, [sp, 252]
	add	w0, w0, 64
	str	w0, [sp, 152]
	cmp	w1, w0
	ble	.L150
.L37:
	ldr	w0, [sp, 336]
	add	w0, w0, 1
	str	w0, [sp, 336]
	b	.L32
.L149:
	ldr	w0, [sp, 144]
	cmp	w0, 0
	ble	.L59
	ldr	w1, [sp, 240]
	cmp	w10, 8
	stp	xzr, xzr, [sp, 464]
	lsl	x13, x8, 3
	sub	w14, w1, w0
	mov	w0, 8
	csel	w12, w10, w0, le
	add	x0, sp, 512
	cmp	w10, 0
	csinc	w12, w12, wzr, gt
	stp	xzr, xzr, [sp, 480]
	and	w7, w12, -2
	stp	xzr, xzr, [sp, 496]
	lsr	w6, w12, 1
	mov	w15, 0
	stp	xzr, xzr, [x0]
	cmp	w24, w30
	ble	.L151
.L45:
	sxtw	x11, w14
	cmp	w10, 0
	ble	.L50
	ldp	x5, x1, [sp, 104]
	mov	x4, x2
	ldr	x0, [sp, 120]
	mov	x3, 0
	madd	x11, x11, x0, x1
	.p2align 3,,7
.L54:
	ldr	d0, [x11, x5, lsl 3]
	cmp	w10, 1
	ble	.L152
	dup	v3.2d, v0.d[0]
	ldr	q2, [x4]
	ldr	q1, [sp, 464]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 464]
	cmp	w6, 1
	bls	.L55
	ldr	q2, [x4, 16]
	ldr	q1, [sp, 480]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 480]
	cmp	w6, 2
	beq	.L55
	ldr	q2, [x4, 32]
	ldr	q1, [sp, 496]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 496]
	cmp	w6, 3
	beq	.L55
	ldr	q2, [x4, 48]
	ldr	q1, [sp, 512]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 512]
.L55:
	sxtw	x0, w7
	cmp	w7, w12
	beq	.L56
.L52:
	add	x1, x0, x3
	ldr	d1, [x28, x0, lsl 3]
	ldr	d2, [x2, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x28, x0, lsl 3]
.L56:
	add	x5, x5, 1
	add	x3, x3, x8
	add	x4, x4, x13
	cmp	w24, w5
	bgt	.L54
	ldr	w0, [sp, 128]
	smaddl	x0, w14, w0, x18
	cmp	w10, 1
	ble	.L79
.L153:
	lsl	x3, x0, 3
	ldr	q1, [sp, 464]
	add	x1, x26, x3
	ldr	q0, [x26, x3]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x26, x3]
	cmp	w6, 1
	bls	.L49
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 480]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w6, 2
	beq	.L49
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 496]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w6, 3
	beq	.L49
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 512]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L49:
	sxtw	x1, w7
	cmp	w7, w12
	beq	.L50
.L48:
	add	x0, x1, x0
	ldr	d1, [x28, x1, lsl 3]
	ldr	d0, [x26, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x26, x0, lsl 3]
.L50:
	add	w15, w15, 1
	add	w14, w14, 1
	cmp	w15, w20
	bge	.L59
	add	x0, sp, 512
	stp	xzr, xzr, [sp, 464]
	stp	xzr, xzr, [sp, 480]
	stp	xzr, xzr, [sp, 496]
	stp	xzr, xzr, [x0]
	cmp	w24, w30
	bgt	.L45
.L151:
	cmp	w10, 0
	ble	.L50
	ldr	w0, [sp, 128]
	smaddl	x0, w14, w0, x18
	cmp	w10, 1
	bgt	.L153
.L79:
	mov	x1, 0
	b	.L48
	.p2align 2,,3
.L152:
	mov	x0, 0
	b	.L52
.L148:
	ldr	x0, [sp, 256]
	ldr	x8, [sp, 272]
	add	x2, x9, x0
	b	.L60
.L81:
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
	b	.L57
.L150:
	ldr	w0, [sp, 264]
	ldr	w1, [sp, 248]
	add	w0, w0, 64
	str	wzr, [sp, 152]
	str	w0, [sp, 264]
	sub	w0, w1, w0
	str	w0, [sp, 356]
	b	.L37
.L31:
	add	w2, w2, 1
	mov	w0, 0
	b	.L63
	.cfi_endproc
.LFE4284:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
	.type	panel_sums_sve, %function
panel_sums_sve:
.LFB4279:
	.cfi_startproc
	cbz	w0, .L157
	sbfiz	x1, x1, 3, 32
	sbfiz	x9, x0, 3, 32
	add	x11, x2, x1
	mov	x0, 0
	add	x10, x11, x1
	mov	z1.d, #0
	add	x1, x10, x1
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	ptrue	p0.b, all
	.p2align 3,,7
.L156:
	ld1d	z0.d, p0/z, [x3, x0, lsl 3]
	add	x8, x2, x0
	add	x7, x11, x0
	add	x6, x10, x0
	add	x5, x1, x0
	ld1rd	z6.d, p0/z, [x8]
	ld1rd	z5.d, p0/z, [x7]
	add	x0, x0, 8
	fmla	z4.d, p0/m, z0.d, z6.d
	fmla	z3.d, p0/m, z0.d, z5.d
	ld1rd	z6.d, p0/z, [x6]
	ld1rd	z5.d, p0/z, [x5]
	fmla	z2.d, p0/m, z0.d, z6.d
	fmla	z1.d, p0/m, z0.d, z5.d
	cmp	x9, x0
	bne	.L156
.L155:
	ptrue	p0.b, all
	st1d	z4.d, p0, [x4]
	add	x0, x4, 64
	st1d	z3.d, p0, [x0]
	add	x0, x4, 128
	st1d	z2.d, p0, [x0]
	add	x4, x4, 192
	st1d	z1.d, p0, [x4]
	ret
	.p2align 2,,3
.L157:
	mov	z1.d, #0
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	b	.L155
	.cfi_endproc
.LFE4279:
	.size	panel_sums_sve, .-panel_sums_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4285:
	.cfi_startproc
	sub	sp, sp, #544
	.cfi_def_cfa_offset 544
	mov	x1, x0
	mov	x0, 16
	stp	x29, x30, [sp]
	.cfi_offset 29, -544
	.cfi_offset 30, -536
	mov	x29, sp
	stp	x23, x24, [sp, 48]
	.cfi_offset 23, -496
	.cfi_offset 24, -488
	ldp	w2, w23, [x1, 16]
	str	w2, [sp, 144]
	ldr	w2, [x1, 24]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -528
	.cfi_offset 20, -520
	ldr	w20, [x1, 28]
	stp	x21, x22, [sp, 32]
	str	w2, [sp, 176]
	.cfi_offset 21, -512
	.cfi_offset 22, -504
	ldp	x21, x22, [x1]
	bl	getauxval
	tbnz	x0, 22, .L160
	str	wzr, [sp, 148]
.L216:
	ldr	w0, [sp, 144]
	mov	x1, 64
	sbfiz	x2, x0, 6, 32
	add	x0, sp, 280
	bl	posix_memalign
	cmp	w0, 0
	ldr	x19, [sp, 280]
	csel	x19, xzr, x19, ne
	bl	omp_get_num_threads
	mov	w24, w0
	bl	omp_get_thread_num
	add	w1, w23, 14
	adds	w3, w23, 7
	mov	w2, w0
	csel	w0, w1, w3, mi
	asr	w0, w0, 3
	sdiv	w1, w0, w24
	msub	w0, w1, w24, w0
	cmp	w2, w0
	blt	.L162
.L214:
	madd	w0, w1, w2, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L163
	ldr	w7, [sp, 176]
	lsl	w4, w0, 3
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -472
	.cfi_offset 25, -480
	add	x24, x21, 8
	ldr	w2, [sp, 144]
	sxtw	x25, w7
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -456
	.cfi_offset 27, -464
	add	x3, x25, 1
	sub	w2, w2, #1
	lsl	w1, w1, 3
	lsl	x27, x3, 3
	add	x0, x2, 1
	sub	x6, x27, #8
	stp	w4, w1, [sp, 224]
	add	x1, x24, x6
	mov	w2, w4
	sbfiz	x7, x7, 1, 32
	add	x0, x19, x0, lsl 6
	str	x1, [sp, 256]
	add	x1, x21, x27
	sub	w4, w23, w4
	lsl	x5, x3, 5
	sbfiz	x28, x20, 3, 32
	mov	x23, x24
	str	x0, [sp, 216]
	add	x0, x7, x25
	str	x1, [sp, 248]
	lsl	x1, x3, 2
	str	x5, [sp, 152]
	str	x1, [sp, 160]
	sub	x1, x5, #32
	str	x1, [sp, 168]
	str	w4, [sp, 180]
	add	x4, x22, x2, sxtw 3
	str	x4, [sp, 184]
	str	x0, [sp, 192]
	sxtw	x0, w2
	str	x6, [sp, 200]
	str	x0, [sp, 208]
	str	x7, [sp, 232]
.L166:
	ldr	w0, [sp, 180]
	mov	w20, 8
	cmp	w0, 8
	csel	w20, w0, w20, le
	cbz	x19, .L280
	ldr	w0, [sp, 144]
	cmp	w0, 0
	ble	.L167
	sub	w0, w20, #1
	ldr	w2, [sp, 180]
	add	x0, x0, 1
	mov	w22, 7
	sub	w22, w22, w20
	cmp	w2, 0
	add	x22, x22, 1
	lsl	x0, x0, 3
	ldr	x26, [sp, 184]
	sbfiz	x20, x20, 3, 32
	mov	x1, 8
	lsl	x22, x22, 3
	csel	x3, x0, x1, gt
	cmp	w2, 7
	stp	x19, x21, [sp, 104]
	mov	x24, x19
	csel	x22, x22, x1, le
	ldr	x21, [sp, 216]
	mov	w19, w2
	str	x25, [sp, 120]
	mov	x25, x26
	mov	x26, x23
	mov	x23, x20
	mov	x20, x3
	str	x3, [sp, 240]
	.p2align 3,,7
.L205:
	mov	x2, x20
	mov	x1, x25
	mov	x0, x24
	cmp	w19, 0
	ble	.L169
	bl	memcpy
	cmp	w19, 7
	bgt	.L207
.L169:
	mov	x2, x22
	add	x0, x24, x23
	mov	w1, 0
	bl	memset
.L207:
	add	x24, x24, 64
	add	x25, x25, x28
	cmp	x24, x21
	bne	.L205
	ldr	w22, [sp, 144]
	mov	w9, 4
	mov	x23, x26
	add	x0, sp, 288
	cmp	w22, 4
	mov	x2, 256
	csel	w20, w22, w9, le
	mov	w1, 0
	ldp	x19, x21, [sp, 104]
	ldr	x25, [sp, 120]
	bl	memset
	cmp	w22, 3
	ble	.L173
	ldr	w0, [sp, 148]
	cbnz	w0, .L204
	movi	v0.2d, 0
	stp	q0, q0, [sp, 288]
	stp	q0, q0, [sp, 320]
	stp	q0, q0, [sp, 352]
	stp	q0, q0, [sp, 384]
	stp	q0, q0, [sp, 416]
	stp	q0, q0, [sp, 448]
	stp	q0, q0, [sp, 480]
	stp	q0, q0, [sp, 512]
.L173:
	sub	w9, w20, #1
	mov	x3, x25
	add	x0, sp, 288
	mov	x1, x19
	mov	x6, x21
	mov	w2, 0
.L198:
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
	cmp	w9, w2
	beq	.L281
	add	w7, w2, 1
	cmp	w7, 0
	ble	.L203
	cmp	w2, 1
	ble	.L220
	ldr	d1, [x21, x3, lsl 3]
	mov	w4, 2
	ldp	q3, q2, [x19]
	dup	v1.2d, v1.d[0]
	ldr	d0, [x23, x3, lsl 3]
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
.L202:
	sxtw	x5, w4
	add	x8, x5, x3
	add	w10, w4, 1
	lsl	x5, x5, 6
	ldr	d0, [x21, x8, lsl 3]
	add	x8, x19, x5
	ldr	q1, [x19, x5]
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
	bge	.L203
	sxtw	x5, w10
	add	w4, w4, 2
	add	x11, x5, x3
	lsl	x5, x5, 6
	add	x8, x19, x5
	ldr	d1, [x21, x11, lsl 3]
	ldr	q2, [x19, x5]
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
	ble	.L203
	add	x5, x3, 2
	sbfiz	x2, x4, 6, 32
	add	x4, x19, x2
	ldr	d1, [x21, x5, lsl 3]
	ldr	q3, [x19, x2]
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
.L203:
	add	x6, x6, x27
	add	x1, x1, 64
	add	x0, x0, 64
	add	x3, x3, x25
	mov	w2, w7
	b	.L198
	.p2align 2,,3
.L281:
	ldr	w0, [sp, 144]
	cmp	w0, 4
	ble	.L174
	ldr	x2, [sp, 200]
	mov	x0, 4
	mov	w1, 5
	mov	x24, x0
	str	x28, [sp, 264]
	mov	x6, x27
	add	x7, x21, x2, lsl 2
	ldr	w2, [sp, 176]
	ldr	x28, [sp, 232]
	add	x20, x19, 256
	mov	x10, x23
	mov	x27, x7
	smaddl	x0, w2, w1, x0
	stp	x0, x7, [sp, 104]
	ldr	x0, [sp, 152]
	add	x5, x21, x0
	.p2align 3,,7
.L197:
	ldr	w0, [sp, 144]
	mov	x2, 256
	mov	w1, 0
	stp	x5, x6, [sp, 120]
	sub	w22, w0, w24
	cmp	w22, 4
	mov	w0, 4
	csel	w26, w22, w0, le
	add	x0, sp, 288
	str	x10, [sp, 136]
	mov	w23, w24
	bl	memset
	cmp	w22, 3
	ldp	x5, x6, [sp, 120]
	ldr	x10, [sp, 136]
	ble	.L282
	ldr	w0, [sp, 148]
	cbnz	w0, .L190
	movi	v16.2d, 0
	add	x3, x19, 64
	sub	w2, w24, #1
	mov	w4, 64
	ldr	x1, [sp, 112]
	mov	x0, x19
	mov	v17.16b, v16.16b
	umaddl	x2, w2, w4, x3
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
	ldr	x3, [sp, 192]
	.p2align 3,,7
.L191:
	ldp	q4, q3, [x0]
	ldp	q2, q0, [x0, 32]
	add	x0, x0, 64
	ld1r	{v7.2d}, [x1]
	ldr	d6, [x1, x25, lsl 3]
	ldr	d5, [x1, x28, lsl 3]
	fmla	v31.2d, v4.2d, v7.2d
	ldr	d1, [x1, x3, lsl 3]
	fmla	v30.2d, v3.2d, v7.2d
	add	x1, x1, 8
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
	cmp	x2, x0
	bne	.L191
	stp	q31, q30, [sp, 288]
	stp	q29, q28, [sp, 320]
	stp	q27, q26, [sp, 352]
	stp	q25, q24, [sp, 384]
	stp	q23, q22, [sp, 416]
	stp	q21, q20, [sp, 448]
	stp	q19, q18, [sp, 480]
	stp	q17, q16, [sp, 512]
.L189:
	sub	w26, w26, #1
	ldr	x4, [sp, 104]
	add	x0, sp, 288
	mov	x1, x20
	mov	x13, x5
	mov	w3, 0
.L194:
	ldr	q0, [x0]
	ldp	q3, q2, [x1]
	ld1r	{v4.2d}, [x13]
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
	cmp	w3, w26
	beq	.L192
	add	w8, w3, 1
	cmp	w8, 0
	ble	.L196
	cmp	w3, 1
	ble	.L219
	ldr	d1, [x21, x4, lsl 3]
	mov	w2, 2
	ldp	q3, q2, [x20]
	dup	v1.2d, v1.d[0]
	ldr	d0, [x10, x4, lsl 3]
	ldp	q5, q4, [x0, 64]
	dup	v0.2d, v0.d[0]
	fmul	v3.2d, v1.2d, v3.2d
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v5.2d, v3.2d, v5.2d
	fadd	v4.2d, v2.2d, v4.2d
	ldp	q3, q2, [x0, 96]
	stp	q5, q4, [x0, 64]
	ldp	q7, q6, [x20, 64]
	fmul	v7.2d, v0.2d, v7.2d
	fmul	v6.2d, v0.2d, v6.2d
	fadd	v5.2d, v7.2d, v5.2d
	fadd	v4.2d, v6.2d, v4.2d
	stp	q5, q4, [x0, 64]
	ldp	q6, q7, [x20, 32]
	fmul	v6.2d, v1.2d, v6.2d
	fmul	v1.2d, v1.2d, v7.2d
	fadd	v3.2d, v6.2d, v3.2d
	fadd	v2.2d, v1.2d, v2.2d
	stp	q3, q2, [x0, 96]
	ldp	q1, q6, [x20, 96]
	fmul	v1.2d, v0.2d, v1.2d
	fmul	v0.2d, v0.2d, v6.2d
	fadd	v3.2d, v1.2d, v3.2d
	fadd	v2.2d, v0.2d, v2.2d
	stp	q3, q2, [x0, 96]
.L195:
	add	x9, x4, x2, sxtw
	add	w7, w2, w23
	add	w11, w2, 1
	sbfiz	x7, x7, 6, 32
	ldr	d0, [x21, x9, lsl 3]
	add	x9, x19, x7
	dup	v0.2d, v0.d[0]
	ldr	q1, [x19, x7]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v5.2d, v1.2d, v5.2d
	str	q5, [x0, 64]
	ldr	q1, [x9, 16]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v4.2d, v1.2d, v4.2d
	str	q4, [x0, 80]
	ldr	q1, [x9, 32]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v3.2d, v1.2d, v3.2d
	str	q3, [x0, 96]
	ldr	q1, [x9, 48]
	fmul	v0.2d, v0.2d, v1.2d
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x0, 112]
	cmp	w2, w3
	bge	.L196
	add	x9, x4, x11, sxtw
	add	w7, w23, w11
	add	w2, w2, 2
	sbfiz	x7, x7, 6, 32
	ldr	d1, [x21, x9, lsl 3]
	add	x9, x19, x7
	ldr	q2, [x19, x7]
	dup	v1.2d, v1.d[0]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v5.2d, v2.2d, v5.2d
	str	q5, [x0, 64]
	ldr	q2, [x9, 16]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v4.2d, v2.2d, v4.2d
	str	q4, [x0, 80]
	ldr	q2, [x9, 32]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [x0, 96]
	ldr	q3, [x9, 48]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v1.2d, v0.2d
	str	q0, [x0, 112]
	cmp	w3, w11
	ble	.L196
	add	x3, x4, 2
	add	w2, w23, w2
	sbfiz	x2, x2, 6, 32
	ldr	d1, [x21, x3, lsl 3]
	add	x3, x19, x2
	ldr	q3, [x19, x2]
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
.L196:
	add	x13, x13, x6
	add	x1, x1, 64
	add	x0, x0, 64
	add	x4, x4, x25
	mov	w3, w8
	b	.L194
	.p2align 2,,3
.L192:
	ldp	x0, x1, [sp, 152]
	add	x24, x24, 4
	add	x20, x20, 256
	add	x5, x5, x0
	ldr	x0, [sp, 104]
	add	x0, x0, x1
	str	x0, [sp, 104]
	ldr	x1, [sp, 112]
	ldr	x0, [sp, 168]
	add	x1, x1, x0
	add	x27, x27, x0
	ldr	w0, [sp, 144]
	str	x1, [sp, 112]
	cmp	w0, w24
	bgt	.L197
	ldr	x28, [sp, 264]
	mov	x27, x6
	mov	x23, x10
.L174:
	ldr	w0, [sp, 180]
	cmp	w0, 0
	ble	.L167
	ldr	x3, [sp, 184]
	mov	x20, x19
	ldr	x24, [sp, 216]
	ldr	x22, [sp, 240]
.L171:
	mov	x1, x20
	mov	x0, x3
	mov	x2, x22
	add	x20, x20, 64
	bl	memcpy
	add	x3, x0, x28
	cmp	x20, x24
	bne	.L171
.L167:
	ldr	w1, [sp, 180]
	ldr	w0, [sp, 224]
	sub	w1, w1, #8
	str	w1, [sp, 180]
	ldr	x1, [sp, 208]
	add	w0, w0, 8
	str	w0, [sp, 224]
	add	x1, x1, 8
	str	x1, [sp, 208]
	ldr	x1, [sp, 184]
	add	x1, x1, 64
	str	x1, [sp, 184]
	ldr	w1, [sp, 228]
	cmp	w1, w0
	bgt	.L166
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L163:
	bl	GOMP_barrier
	mov	x0, x19
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	add	sp, sp, 544
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	b	free
.L204:
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
	ldr	w1, [sp, 176]
	add	x4, sp, 288
	mov	x3, x19
	mov	x2, x21
	mov	w0, 0
	bl	panel_sums_sve
	b	.L173
.L190:
	ldr	w1, [sp, 176]
	add	x4, sp, 288
	ldr	x2, [sp, 112]
	mov	x3, x19
	mov	w0, w24
	stp	x5, x6, [sp, 120]
	str	x10, [sp, 136]
	bl	panel_sums_sve
	ldp	x5, x6, [sp, 120]
	ldr	x10, [sp, 136]
	b	.L189
.L220:
	mov	w4, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L202
.L219:
	mov	w2, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L195
.L282:
	movi	v5.2d, 0
	add	w4, w24, 1
	ldr	x2, [sp, 200]
	add	w15, w24, 2
	add	w16, w24, 3
	mov	x1, x19
	mov	v22.16b, v5.16b
	mov	w0, 0
	madd	x4, x4, x2, x21
	mov	w17, 0
	madd	x15, x15, x2, x21
	mov	w18, 0
	madd	x16, x16, x2, x21
	mov	w30, 0
	mov	v23.16b, v5.16b
	mov	w3, 0
	mov	v24.16b, v5.16b
	mov	w12, 0
	mov	v18.16b, v5.16b
	mov	w13, 0
	mov	v19.16b, v5.16b
	mov	w14, 0
	mov	v20.16b, v5.16b
	mov	w7, 0
	mov	v21.16b, v5.16b
	mov	w11, 0
	mov	v25.16b, v5.16b
	mov	w8, 0
	mov	v26.16b, v5.16b
	mov	w9, 0
	mov	v27.16b, v5.16b
	mov	x2, 0
	mov	v28.16b, v5.16b
	mov	v6.16b, v5.16b
	mov	v7.16b, v5.16b
	mov	v16.16b, v5.16b
	mov	v17.16b, v5.16b
	b	.L177
	.p2align 2,,3
.L284:
	ldr	d0, [x15, x2, lsl 3]
	mov	w0, 1
	mov	w17, w0
	mov	w18, w0
	mov	w30, w0
	mov	w3, w0
	dup	v0.2d, v0.d[0]
	mov	w12, w0
	mov	w13, w0
	mov	w14, w0
	fmul	v31.2d, v3.2d, v0.2d
	fmul	v30.2d, v2.2d, v0.2d
	fmul	v29.2d, v1.2d, v0.2d
	fmul	v0.2d, v4.2d, v0.2d
	fadd	v24.2d, v24.2d, v31.2d
	fadd	v23.2d, v23.2d, v30.2d
	fadd	v22.2d, v22.2d, v29.2d
	fadd	v5.2d, v5.2d, v0.2d
	cmp	w22, 3
	ble	.L218
	ldr	d0, [x16, x2, lsl 3]
	mov	w7, w0
	mov	w11, w0
	mov	w8, w0
	mov	w9, w0
	dup	v0.2d, v0.d[0]
	fmul	v3.2d, v0.2d, v3.2d
	fmul	v2.2d, v0.2d, v2.2d
	fmul	v1.2d, v0.2d, v1.2d
	fmul	v0.2d, v0.2d, v4.2d
	fadd	v28.2d, v28.2d, v3.2d
	fadd	v27.2d, v27.2d, v2.2d
	fadd	v26.2d, v26.2d, v1.2d
	fadd	v25.2d, v25.2d, v0.2d
.L176:
	add	x2, x2, 1
	add	x1, x1, 64
	cmp	w2, w24
	bge	.L283
.L177:
	ldr	d0, [x27, x2, lsl 3]
	ldp	q3, q2, [x1]
	dup	v0.2d, v0.d[0]
	ldp	q1, q4, [x1, 32]
	fmul	v31.2d, v0.2d, v3.2d
	fmul	v30.2d, v0.2d, v2.2d
	fmul	v29.2d, v0.2d, v1.2d
	fmul	v0.2d, v0.2d, v4.2d
	fadd	v17.2d, v17.2d, v31.2d
	fadd	v16.2d, v16.2d, v30.2d
	fadd	v7.2d, v7.2d, v29.2d
	fadd	v6.2d, v6.2d, v0.2d
	cmp	w22, 1
	beq	.L176
	ldr	d0, [x4, x2, lsl 3]
	dup	v0.2d, v0.d[0]
	fmul	v31.2d, v3.2d, v0.2d
	fmul	v30.2d, v2.2d, v0.2d
	fmul	v29.2d, v1.2d, v0.2d
	fmul	v0.2d, v4.2d, v0.2d
	fadd	v21.2d, v21.2d, v31.2d
	fadd	v20.2d, v20.2d, v30.2d
	fadd	v19.2d, v19.2d, v29.2d
	fadd	v18.2d, v18.2d, v0.2d
	cmp	w22, 2
	bne	.L284
	add	x2, x2, 1
	mov	w3, 1
	add	x1, x1, 64
	mov	w12, w3
	mov	w13, w3
	mov	w14, w3
	cmp	w2, w24
	blt	.L177
.L283:
	stp	q17, q16, [sp, 288]
	stp	q7, q6, [sp, 320]
	cbz	w9, .L178
	str	q28, [sp, 480]
.L178:
	cbz	w8, .L179
	str	q27, [sp, 496]
.L179:
	cbz	w11, .L180
	str	q26, [sp, 512]
.L180:
	cbz	w7, .L181
	str	q25, [sp, 528]
.L181:
	cbz	w14, .L182
	str	q21, [sp, 352]
.L182:
	cbz	w13, .L183
	str	q20, [sp, 368]
.L183:
	cbz	w12, .L184
	str	q19, [sp, 384]
.L184:
	cbz	w3, .L185
	str	q18, [sp, 400]
.L185:
	cbz	w30, .L186
	str	q24, [sp, 416]
.L186:
	cbz	w18, .L187
	str	q23, [sp, 432]
.L187:
	cbz	w17, .L188
	str	q22, [sp, 448]
.L188:
	cbz	w0, .L189
	str	q5, [sp, 464]
	b	.L189
	.p2align 2,,3
.L218:
	mov	w0, 1
	mov	w17, w0
	mov	w18, w0
	mov	w30, w0
	mov	w3, w0
	mov	w12, w0
	mov	w13, w0
	mov	w14, w0
	b	.L176
.L280:
	ldr	w0, [sp, 224]
	add	w20, w0, w20
	cmp	w0, w20
	bge	.L167
	ldr	w7, [sp, 144]
	cmp	w7, 0
	ble	.L167
	ldr	x8, [sp, 184]
	ldr	x9, [sp, 208]
.L212:
	ldr	d0, [x8]
	ldr	d1, [x21]
	fdiv	d0, d0, d1
	str	d0, [x8]
	cmp	w7, 1
	beq	.L209
	ldp	x5, x2, [sp, 248]
	add	x3, x8, x28
	mov	x6, x25
	mov	w4, 1
	.p2align 3,,7
.L211:
	movi	d1, #0
	add	x1, x21, x6, lsl 3
	mov	x0, x8
	.p2align 3,,7
.L210:
	ldr	d2, [x0]
	add	x0, x0, x28
	ldr	d0, [x1], 8
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	x2, x1
	bne	.L210
	ldr	d0, [x3]
	add	w4, w4, 1
	ldr	d2, [x5]
	add	x6, x6, x25
	add	x2, x2, x27
	add	x5, x5, x27
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x3]
	add	x3, x3, x28
	cmp	w7, w4
	bne	.L211
.L209:
	add	x9, x9, 1
	add	x8, x8, 8
	cmp	w20, w9
	bgt	.L212
	b	.L167
.L160:
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 27
	.cfi_restore 28
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	csinc	w0, w0, wzr, eq
	str	w0, [sp, 148]
	b	.L216
.L162:
	add	w1, w1, 1
	mov	w0, 0
	b	.L214
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
	mov	x21, x2
	mov	w22, w3
	mov	x23, x4
	mov	w24, w5
	cmp	x0, x1
	bls	.L287
	sxtw	x2, w20
	add	x0, sp, 80
	add	x2, x2, 7
	mov	x1, 64
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L288
	ldr	x0, [sp, 80]
	str	x0, [sp, 72]
.L289:
	add	x4, sp, 72
	add	x1, sp, 88
	mov	w3, 0
	mov	w2, 0
	adrp	x0, solve_blocked._omp_fn.0
	add	x0, x0, :lo12:solve_blocked._omp_fn.0
	stp	x21, x23, [sp, 88]
	str	x4, [sp, 104]
	stp	w19, w20, [sp, 112]
	stp	w22, w24, [sp, 120]
	bl	GOMP_parallel
	ldr	x0, [sp, 72]
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
	add	x1, sp, 88
	mov	w3, 0
	mov	w2, 0
	adrp	x0, solve_panel._omp_fn.0
	add	x0, x0, :lo12:solve_panel._omp_fn.0
	stp	x21, x4, [sp, 88]
	stp	w19, w20, [sp, 104]
	stp	w22, w5, [sp, 112]
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
	str	xzr, [sp, 72]
	b	.L289
	.cfi_endproc
.LFE4283:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (GNU) 10.3.1"
	.section	.note.GNU-stack,"",@progbits
