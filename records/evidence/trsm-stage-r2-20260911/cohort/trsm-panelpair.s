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
	.type	update4x8_sve, %function
update4x8_sve:
.LFB4281:
	.cfi_startproc
	cmp	w0, 0
	ble	.L15
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
.L14:
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
	bne	.L14
.L13:
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
.L15:
	mov	z1.d, #0
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	b	.L13
	.cfi_endproc
.LFE4281:
	.size	update4x8_sve, .-update4x8_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4285:
	.cfi_startproc
	sub	sp, sp, #624
	.cfi_def_cfa_offset 624
	stp	x29, x30, [sp]
	.cfi_offset 29, -624
	.cfi_offset 30, -616
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -608
	.cfi_offset 20, -600
	mov	x20, x0
	ldr	w0, [x0, 40]
	stp	x21, x22, [sp, 32]
	ldr	w19, [x20, 36]
	.cfi_offset 21, -592
	.cfi_offset 22, -584
	ldp	x1, x22, [x20]
	str	x1, [sp, 112]
	ldr	w1, [x20, 24]
	str	w1, [sp, 152]
	ldr	w1, [x20, 28]
	str	w1, [sp, 288]
	ldr	w1, [x20, 32]
	str	w0, [sp, 136]
	str	w1, [sp, 140]
	cbz	w0, .L111
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	csinc	w0, w0, wzr, eq
	str	w0, [sp, 136]
.L111:
	ldr	w0, [sp, 152]
	cmp	w0, 0
	ble	.L17
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -568
	.cfi_offset 23, -576
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -552
	.cfi_offset 25, -560
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -536
	.cfi_offset 27, -544
	bl	omp_get_num_threads
	mov	w23, w0
	str	w0, [sp, 404]
	bl	omp_get_thread_num
	ldr	w6, [sp, 288]
	sxtw	x5, w19
	mov	w9, w0
	ldr	w10, [sp, 140]
	adds	w2, w6, 7
	add	w1, w6, 14
	csel	w0, w1, w2, mi
	add	x1, x5, 1
	mov	w2, 24
	sxtw	x21, w10
	lsl	x7, x1, 4
	asr	w0, w0, 3
	smull	x2, w19, w2
	add	x11, x7, 16
	stp	x7, x11, [sp, 224]
	add	x7, x7, 32
	add	x4, x21, 1
	str	x7, [sp, 240]
	add	x7, x2, 16
	str	x7, [sp, 248]
	add	x7, x2, 32
	add	x2, x2, 48
	stp	x7, x2, [sp, 256]
	lsl	x2, x4, 11
	sdiv	w1, w0, w23
	lsl	x8, x21, 3
	ldr	x4, [sp, 112]
	str	x2, [sp, 504]
	sbfiz	x10, x10, 1, 32
	add	w3, w6, 63
	add	x2, x4, x8
	msub	w0, w1, w23, w0
	str	x2, [sp, 352]
	add	x2, x8, 8
	str	x2, [sp, 480]
	add	x2, x10, x21
	cmp	w9, w0
	str	x2, [sp, 424]
	lsl	x2, x5, 8
	cinc	w1, w1, lt
	str	x2, [sp, 496]
	lsl	x2, x21, 8
	str	x2, [sp, 512]
	lsl	x2, x21, 6
	str	x2, [sp, 432]
	neg	x2, x5, lsl 6
	str	x2, [sp, 520]
	mul	w2, w1, w9
	lsl	x7, x5, 6
	str	x7, [sp, 456]
	add	w0, w0, w2
	lsl	x7, x21, 5
	csel	w2, w2, w0, lt
	asr	w0, w3, 6
	add	w1, w1, w2
	str	w0, [sp, 380]
	lsl	w0, w2, 3
	sbfiz	x28, x19, 3, 32
	str	x8, [sp, 128]
	mov	x26, x21
	str	x5, [sp, 168]
	add	x27, sp, 560
	str	x21, [sp, 360]
	mov	x24, x28
	str	w9, [sp, 368]
	mov	w21, w19
	str	w0, [sp, 372]
	str	w1, [sp, 408]
	lsl	w1, w1, 3
	str	x10, [sp, 416]
	str	x7, [sp, 448]
	neg	x7, x5, lsl 5
	lsl	x5, x5, 5
	str	x5, [sp, 392]
	str	w2, [sp, 472]
	add	x2, x28, 16
	str	x7, [sp, 528]
	str	x2, [sp, 200]
	str	w1, [sp, 376]
	sub	w1, w6, w0
	sxtw	x0, w0
	stp	xzr, x20, [sp, 296]
	mov	x20, x22
	str	x0, [sp, 488]
	add	x0, x28, 32
	str	xzr, [sp, 104]
	str	x0, [sp, 208]
	add	x0, x28, 48
	str	x0, [sp, 216]
	stp	xzr, x4, [sp, 336]
	str	w1, [sp, 412]
.L40:
	ldr	x2, [sp, 104]
	str	w2, [sp, 156]
	ldr	w3, [sp, 152]
	add	w0, w2, 256
	mov	w23, w2
	sub	w1, w3, w2
	cmp	w1, 255
	ldr	w1, [sp, 472]
	csel	w28, w0, w3, gt
	ldr	w0, [sp, 408]
	cmp	w0, w1
	bgt	.L213
	bl	GOMP_barrier
	ldr	x0, [sp, 304]
	ldr	x0, [x0, 16]
	ldr	x0, [x0]
	cbz	x0, .L110
.L102:
	bl	GOMP_barrier
.L110:
	ldr	w0, [sp, 152]
	cmp	w28, w0
	bge	.L42
	ldr	w0, [sp, 152]
	add	w1, w0, 63
	subs	w1, w1, w28
	add	w0, w1, 63
	csel	w0, w0, w1, mi
	ldr	w1, [sp, 288]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L42
	ldr	w1, [sp, 380]
	ldr	w2, [sp, 404]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	ldr	w2, [sp, 368]
	cmp	w2, w0
	bcc	.L43
.L101:
	ldr	w2, [sp, 368]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L214
.L42:
	bl	GOMP_barrier
	ldr	x2, [sp, 296]
	ldr	x1, [sp, 496]
	ldr	x0, [sp, 104]
	add	x2, x2, x1
	str	x2, [sp, 296]
	ldr	x2, [sp, 336]
	add	x0, x0, 256
	str	x0, [sp, 104]
	add	x1, x2, x1
	str	x1, [sp, 336]
	ldr	x2, [sp, 344]
	ldr	x1, [sp, 504]
	add	x2, x2, x1
	str	x2, [sp, 344]
	ldr	x2, [sp, 352]
	add	x1, x2, x1
	str	x1, [sp, 352]
	ldr	x1, [sp, 360]
	ldr	x2, [sp, 512]
	add	x1, x1, x2
	str	x1, [sp, 360]
	ldr	w1, [sp, 152]
	cmp	w1, w0
	bgt	.L40
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L17:
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	add	sp, sp, 624
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L213:
	.cfi_def_cfa_offset 624
	.cfi_offset 19, -608
	.cfi_offset 20, -600
	.cfi_offset 21, -592
	.cfi_offset 22, -584
	.cfi_offset 23, -576
	.cfi_offset 24, -568
	.cfi_offset 25, -560
	.cfi_offset 26, -552
	.cfi_offset 27, -544
	.cfi_offset 28, -536
	.cfi_offset 29, -624
	.cfi_offset 30, -616
	ldr	x1, [sp, 336]
	mov	w19, w2
	ldr	x0, [sp, 488]
	mov	w30, 8
	ldr	w17, [sp, 372]
	mov	w22, 1
	add	x25, x0, x1
	str	w21, [sp, 120]
	ldr	x1, [sp, 112]
	mov	x16, x25
	ldr	x10, [sp, 168]
	add	x18, x1, x2, lsl 3
.L23:
	ldr	w0, [sp, 288]
	sub	w7, w0, w17
	cmp	w7, 8
	csel	w8, w7, w30, le
	cmp	w28, w19
	ble	.L28
	ldp	x14, x0, [sp, 344]
	cmp	w7, 0
	csel	w8, w8, w22, gt
	add	x21, x20, x16, lsl 3
	ldr	w13, [sp, 156]
	mov	x12, x21
	ldr	x15, [sp, 360]
	and	w6, w8, -2
	add	x9, x0, 8
	add	x0, sp, 512
	lsr	w5, w8, 1
	mov	x11, x16
	stp	xzr, xzr, [x0, 48]
	stp	xzr, xzr, [x0, 64]
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
.L114:
	ldr	d2, [x14]
	cmp	w7, 0
	ble	.L31
	cmp	w7, 1
	ble	.L116
	ldr	q0, [x12]
	ldr	q3, [sp, 560]
	dup	v1.2d, v2.d[0]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x12]
	cmp	w5, 1
	bls	.L30
	ldr	q0, [x12, 16]
	ldr	q3, [sp, 576]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x12, 16]
	cmp	w5, 2
	beq	.L30
	ldr	q0, [x12, 32]
	ldr	q3, [sp, 592]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x12, 32]
	cmp	w5, 3
	beq	.L30
	ldr	q0, [x12, 48]
	ldr	q3, [sp, 608]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x12, 48]
.L30:
	sxtw	x0, w6
	cmp	w6, w8
	beq	.L31
.L29:
	add	x1, x0, x11
	ldr	d1, [x27, x0, lsl 3]
	ldr	d0, [x20, x1, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x20, x1, lsl 3]
.L31:
	add	w13, w13, 1
	cmp	w28, w13
	beq	.L28
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 48]
	stp	xzr, xzr, [x0, 64]
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	cmp	w13, w19
	ble	.L33
	cmp	w7, 0
	ble	.L33
	add	x4, x18, x15, lsl 3
	mov	x3, x21
	mov	x2, x16
	.p2align 3,,7
.L36:
	ldr	d0, [x4]
	cmp	w7, 1
	ble	.L215
	dup	v3.2d, v0.d[0]
	ldr	q2, [x3]
	ldr	q1, [sp, 560]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 560]
	cmp	w5, 1
	bls	.L37
	ldr	q2, [x3, 16]
	ldr	q1, [sp, 576]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 576]
	cmp	w5, 2
	beq	.L37
	ldr	q2, [x3, 32]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w5, 3
	beq	.L37
	ldr	q2, [x3, 48]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
.L37:
	sxtw	x0, w6
	cmp	w6, w8
	beq	.L38
.L34:
	add	x1, x0, x2
	ldr	d1, [x27, x0, lsl 3]
	ldr	d2, [x20, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x27, x0, lsl 3]
.L38:
	add	x4, x4, 8
	add	x2, x2, x10
	add	x3, x3, x24
	cmp	x4, x9
	bne	.L36
.L33:
	ldr	x0, [sp, 480]
	add	x15, x15, x26
	add	x11, x11, x10
	add	x12, x12, x24
	add	x14, x14, x0
	add	x9, x9, x0
	b	.L114
.L215:
	mov	x0, 0
	b	.L34
.L116:
	mov	x0, 0
	b	.L29
.L28:
	ldr	w0, [sp, 376]
	add	w17, w17, 8
	add	x16, x16, 8
	cmp	w0, w17
	bgt	.L23
	ldr	w21, [sp, 120]
	bl	GOMP_barrier
	ldr	x0, [sp, 304]
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L110
	cmp	w28, w19
	ble	.L102
	mvn	w0, w23
	ldr	w4, [sp, 412]
	add	w0, w0, w28
	add	x5, x20, x25, lsl 3
	add	x0, x0, 1
	ldr	w25, [sp, 372]
	mov	x6, x26
	mov	w22, w4
	lsl	x8, x0, 6
	mov	x26, x3
	mov	w4, w21
	mov	w3, w28
	mov	x28, x8
	mov	w8, w23
	mov	x23, x5
	mov	x5, x20
	mov	w10, 8
	mov	w9, 7
	mov	x7, 8
.L105:
	cmp	w22, 8
	add	w19, w25, 7
	csel	w1, w22, w10, le
	cmp	w25, 0
	csel	w19, w19, w25, lt
	sub	w0, w9, w1
	add	x0, x0, 1
	cmp	w22, 7
	asr	w19, w19, 3
	sbfiz	x11, x1, 3, 32
	lsl	x0, x0, 3
	mov	x20, x23
	sbfiz	x19, x19, 14, 32
	csel	x21, x0, x7, le
	add	x19, x26, x19
	str	x26, [sp, 120]
	add	x12, x28, x19
	mov	w26, w3
	str	x23, [sp, 144]
	mov	x23, x12
	str	x28, [sp, 160]
	mov	w28, w25
	mov	x25, x11
.L106:
	cmp	w22, 0
	ble	.L104
	ldr	d0, [x20]
	str	d0, [x19]
	cmp	w22, 1
	ble	.L109
	ldr	d0, [x20, 8]
	str	d0, [x19, 8]
	cmp	w22, 2
	beq	.L104
	ldr	d0, [x20, 16]
	str	d0, [x19, 16]
	cmp	w22, 3
	beq	.L104
	ldr	d0, [x20, 24]
	str	d0, [x19, 24]
	cmp	w22, 4
	beq	.L104
	ldr	d0, [x20, 32]
	str	d0, [x19, 32]
	cmp	w22, 5
	beq	.L104
	ldr	d0, [x20, 40]
	str	d0, [x19, 40]
	cmp	w22, 6
	beq	.L104
	ldr	d0, [x20, 48]
	str	d0, [x19, 48]
	cmp	w22, 7
	ble	.L104
	ldr	d0, [x20, 56]
	str	d0, [x19, 56]
.L109:
	cmp	w22, 7
	bgt	.L108
.L104:
	mov	x2, x21
	add	x0, x19, x25
	mov	w1, 0
	str	w4, [sp, 176]
	stp	x5, x6, [sp, 184]
	str	w8, [sp, 272]
	bl	memset
	ldp	x5, x6, [sp, 184]
	mov	w10, 8
	ldr	w4, [sp, 176]
	mov	w9, 7
	ldr	w8, [sp, 272]
	mov	x7, 8
.L108:
	add	x19, x19, 64
	add	x20, x20, x24
	cmp	x19, x23
	bne	.L106
	ldr	x23, [sp, 144]
	add	w25, w28, 8
	ldr	w0, [sp, 376]
	mov	w3, w26
	sub	w22, w22, #8
	add	x23, x23, 64
	ldr	x26, [sp, 120]
	ldr	x28, [sp, 160]
	cmp	w0, w25
	bgt	.L105
	mov	w28, w3
	mov	w21, w4
	mov	x20, x5
	mov	x26, x6
	mov	w23, w8
	b	.L102
.L214:
	ldr	w3, [sp, 380]
	sub	w4, w28, w23
	sub	w1, w1, #1
	str	w1, [sp, 536]
	sub	w1, w4, #1
	str	x1, [sp, 440]
	ldr	w19, [sp, 104]
	udiv	w2, w0, w3
	str	w4, [sp, 192]
	str	w19, [sp, 328]
	str	wzr, [sp, 332]
	msub	w0, w2, w3, w0
	add	w1, w28, w2, lsl 6
	ldr	w2, [sp, 152]
	str	w1, [sp, 292]
	lsl	w0, w0, 6
	sub	w1, w2, w1
	str	w0, [sp, 144]
	str	w1, [sp, 400]
.L44:
	ldr	w2, [sp, 292]
	ldr	w0, [sp, 400]
	ldr	w5, [sp, 152]
	add	w1, w2, 64
	cmp	w0, 63
	ldr	w4, [sp, 144]
	csel	w1, w1, w5, gt
	ldr	w3, [sp, 288]
	str	w1, [sp, 160]
	add	w23, w4, 64
	ldr	w1, [sp, 136]
	sub	w0, w3, w4
	cmp	w0, 63
	mov	w0, w2
	csel	w23, w23, w3, gt
	cbnz	w1, .L216
.L47:
	ldr	w1, [sp, 160]
	cmp	w1, w0
	ble	.L51
	ldr	w2, [sp, 144]
	cmp	w2, w23
	bge	.L51
	sxtw	x3, w2
	ldr	w2, [sp, 140]
	ldr	x4, [sp, 104]
	smull	x1, w21, w0
	ldp	x19, x22, [sp, 416]
	str	x3, [sp, 384]
	smaddl	x2, w2, w0, x4
	ldr	w4, [sp, 160]
	ldr	x18, [sp, 304]
	sub	w0, w4, w0
	str	w0, [sp, 184]
	mov	w6, w21
	ldr	x0, [sp, 296]
	sub	x0, x0, x1
	add	x1, x3, x1
	ldr	x3, [sp, 440]
	lsl	x0, x0, 3
	str	x0, [sp, 176]
	add	x0, x20, x1, lsl 3
	str	x0, [sp, 312]
	add	x3, x3, 1
	ldr	x0, [sp, 112]
	str	x3, [sp, 464]
	add	x25, x0, x2, lsl 3
.L75:
	ldr	w1, [sp, 184]
	mov	w0, 4
	ldr	w13, [sp, 144]
	cmp	w1, 4
	csel	w0, w1, w0, le
	cmp	w1, 3
	str	w0, [sp, 320]
	cset	w0, gt
	str	w0, [sp, 120]
	ldr	x0, [sp, 464]
	ldr	x12, [sp, 312]
	ldr	x15, [sp, 384]
	add	x14, x25, x0, lsl 3
	.p2align 3,,7
.L73:
	ldr	x0, [x18, 16]
	sub	w10, w23, w13
	ldr	x3, [x0]
	cbz	x3, .L217
	asr	w0, w13, 3
	mov	x5, 8
	mov	w4, w5
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 120]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	ble	.L218
.L78:
	ldr	w0, [sp, 136]
	cbnz	w0, .L94
	movi	v16.2d, 0
	ldr	w0, [sp, 192]
	cmp	w0, 0
	ble	.L124
	mov	v17.16b, v16.16b
	lsl	x5, x5, 3
	mov	v18.16b, v16.16b
	mov	x0, x25
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
.L96:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, x5
	ld1r	{v7.2d}, [x0]
	ldr	d6, [x0, x26, lsl 3]
	ldr	d5, [x0, x19, lsl 3]
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
	cmp	x0, x14
	bne	.L96
.L95:
	ldp	q3, q2, [x12]
	add	x0, x12, x24
	ldp	q1, q0, [x12, 32]
	add	x1, x24, x0
	fsub	v3.2d, v3.2d, v31.2d
	fsub	v2.2d, v2.2d, v30.2d
	fsub	v0.2d, v0.2d, v28.2d
	fsub	v1.2d, v1.2d, v29.2d
	stp	q3, q2, [x12]
	stp	q1, q0, [x12, 32]
	ldr	q0, [x12, x24]
	fsub	v0.2d, v0.2d, v27.2d
	str	q0, [x12, x24]
	ldr	x2, [sp, 200]
	ldr	q0, [x12, x2]
	fsub	v0.2d, v0.2d, v26.2d
	str	q0, [x12, x2]
	ldr	x2, [sp, 208]
	ldr	q0, [x12, x2]
	fsub	v0.2d, v0.2d, v25.2d
	str	q0, [x12, x2]
	ldr	x2, [sp, 216]
	ldr	q0, [x12, x2]
	fsub	v0.2d, v0.2d, v24.2d
	str	q0, [x12, x2]
	ldr	q0, [x24, x0]
	fsub	v0.2d, v0.2d, v23.2d
	str	q0, [x24, x0]
	ldr	x0, [sp, 224]
	ldr	q0, [x12, x0]
	fsub	v0.2d, v0.2d, v22.2d
	str	q0, [x12, x0]
	ldr	x0, [sp, 232]
	ldr	q0, [x12, x0]
	fsub	v0.2d, v0.2d, v21.2d
	str	q0, [x12, x0]
	ldr	x0, [sp, 240]
	ldr	q0, [x12, x0]
	fsub	v0.2d, v0.2d, v20.2d
	str	q0, [x12, x0]
	ldr	q0, [x24, x1]
	fsub	v0.2d, v0.2d, v19.2d
	str	q0, [x24, x1]
	ldr	x0, [sp, 248]
	ldr	q0, [x12, x0]
	fsub	v0.2d, v0.2d, v18.2d
	str	q0, [x12, x0]
	ldr	x0, [sp, 256]
	ldr	q0, [x12, x0]
	fsub	v0.2d, v0.2d, v17.2d
	str	q0, [x12, x0]
	ldr	x0, [sp, 264]
	ldr	q0, [x12, x0]
	fsub	v0.2d, v0.2d, v16.2d
	str	q0, [x12, x0]
.L97:
	add	w13, w13, 8
	add	x12, x12, 64
	add	x15, x15, 8
	cmp	w23, w13
	bgt	.L73
	ldr	x2, [sp, 176]
	ldr	x3, [sp, 528]
	ldr	x1, [sp, 448]
	add	x2, x2, x3
	ldr	w0, [sp, 184]
	str	x2, [sp, 176]
	add	x25, x25, x1
	ldr	x2, [sp, 312]
	sub	w0, w0, #4
	ldr	x3, [sp, 392]
	str	w0, [sp, 184]
	ldr	w1, [sp, 160]
	add	x2, x2, x3
	str	x2, [sp, 312]
	sub	w0, w1, w0
	cmp	w1, w0
	bgt	.L75
	mov	w21, w6
.L51:
	ldr	w0, [sp, 332]
	ldr	w1, [sp, 536]
	cmp	w0, w1
	beq	.L42
	ldr	w0, [sp, 144]
	ldr	w1, [sp, 288]
	add	w0, w0, 64
	str	w0, [sp, 144]
	cmp	w1, w0
	ble	.L219
.L74:
	ldr	w0, [sp, 332]
	add	w0, w0, 1
	str	w0, [sp, 332]
	b	.L44
.L94:
	ldr	w2, [sp, 140]
	mov	x5, x12
	ldr	w0, [sp, 156]
	mov	x1, x25
	sub	w0, w28, w0
	bl	update4x8_sve
	b	.L97
.L217:
	ldp	x5, x0, [sp, 168]
	mov	w4, w6
	add	x3, x12, x0
	ldr	w0, [sp, 120]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	bgt	.L78
.L218:
	ldr	w0, [sp, 184]
	cmp	w0, 0
	ble	.L97
	cmp	w10, 8
	mov	w16, 8
	csel	w16, w10, w16, le
	cmp	w10, 0
	ldr	w1, [sp, 160]
	csinc	w16, w16, wzr, gt
	str	x12, [sp, 272]
	and	w9, w16, -2
	ldr	w12, [sp, 320]
	sub	w21, w1, w0
	str	w13, [sp, 280]
	lsl	x17, x5, 3
	ldr	w13, [sp, 328]
	lsr	w1, w16, 1
	mov	w30, 0
.L84:
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 48]
	stp	xzr, xzr, [x0, 64]
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	cmp	w28, w13
	ble	.L220
	sxtw	x11, w21
	cmp	w10, 0
	ble	.L87
	ldp	x8, x2, [sp, 104]
	mov	x7, x3
	ldr	x0, [sp, 128]
	mov	x4, 0
	madd	x11, x11, x0, x2
	.p2align 3,,7
.L91:
	ldr	d0, [x11, x8, lsl 3]
	cmp	w10, 1
	ble	.L221
	dup	v3.2d, v0.d[0]
	ldr	q2, [x7]
	ldr	q1, [sp, 560]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 560]
	cmp	w1, 1
	bls	.L92
	ldr	q2, [x7, 16]
	ldr	q1, [sp, 576]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 576]
	cmp	w1, 2
	beq	.L92
	ldr	q2, [x7, 32]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w1, 3
	beq	.L92
	ldr	q2, [x7, 48]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
.L92:
	sxtw	x0, w9
	cmp	w9, w16
	beq	.L93
.L89:
	add	x2, x0, x4
	ldr	d1, [x27, x0, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x27, x0, lsl 3]
.L93:
	add	x8, x8, 1
	add	x4, x4, x5
	add	x7, x7, x17
	cmp	w28, w8
	bgt	.L91
	smaddl	x0, w21, w6, x15
	cmp	w10, 1
	ble	.L122
.L222:
	lsl	x4, x0, 3
	ldr	q1, [sp, 560]
	add	x2, x20, x4
	ldr	q0, [x20, x4]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x20, x4]
	cmp	w1, 1
	bls	.L86
	ldr	q0, [x2, 16]
	ldr	q1, [sp, 576]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 16]
	cmp	w1, 2
	beq	.L86
	ldr	q0, [x2, 32]
	ldr	q1, [sp, 592]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 32]
	cmp	w1, 3
	beq	.L86
	ldr	q0, [x2, 48]
	ldr	q1, [sp, 608]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 48]
.L86:
	sxtw	x2, w9
	cmp	w9, w16
	beq	.L87
.L85:
	add	x0, x2, x0
	ldr	d1, [x27, x2, lsl 3]
	ldr	d0, [x20, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x20, x0, lsl 3]
.L87:
	add	w30, w30, 1
	add	w21, w21, 1
	cmp	w30, w12
	blt	.L84
	ldr	w13, [sp, 280]
	ldr	x12, [sp, 272]
	b	.L97
	.p2align 2,,3
.L221:
	mov	x0, 0
	b	.L89
.L220:
	cmp	w10, 0
	ble	.L87
	smaddl	x0, w21, w6, x15
	cmp	w10, 1
	bgt	.L222
.L122:
	mov	x2, 0
	b	.L85
.L124:
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
	b	.L95
.L216:
	mov	x4, x2
	add	w1, w2, 7
	ldr	w2, [sp, 160]
	cmp	w2, w1
	ble	.L47
	ldr	w1, [sp, 140]
	smull	x0, w21, w0
	ldr	x9, [sp, 104]
	sub	w2, w2, w4
	ldr	x3, [sp, 296]
	sub	w2, w2, #8
	ldrsw	x5, [sp, 144]
	smaddl	x1, w1, w4, x9
	sub	x3, x3, x0
	mov	w22, w23
	add	x0, x0, x5
	ldr	w23, [sp, 328]
	lsl	x3, x3, 3
	str	x5, [sp, 384]
	add	x0, x20, x0, lsl 3
	stp	x3, x0, [sp, 176]
	mov	x0, x1
	ldr	x1, [sp, 112]
	add	w5, w4, 8
	ldr	x10, [sp, 128]
	str	w2, [sp, 464]
	add	x18, x1, x0, lsl 3
	and	w2, w2, -8
	str	x24, [sp, 552]
	mov	x24, x1
	mov	x1, x18
	add	w2, w5, w2
	str	w4, [sp, 120]
	str	w2, [sp, 476]
	str	w5, [sp, 540]
	str	x26, [sp, 544]
.L52:
	ldr	w0, [sp, 144]
	cmp	w0, w22
	bge	.L223
	ldr	w0, [sp, 120]
	ldr	w26, [sp, 144]
	add	w25, w0, 8
	mov	w0, w21
	mov	w21, w22
	mov	w22, w0
	ldr	x5, [sp, 184]
	ldr	x11, [sp, 304]
	ldr	x19, [sp, 384]
	b	.L58
.L56:
	ldr	w2, [sp, 140]
	mov	w6, w22
	ldr	w0, [sp, 156]
	stp	x1, x9, [sp, 272]
	sub	w0, w28, w0
	stp	x10, x11, [sp, 312]
	bl	update8x8_sve
	ldp	x1, x9, [sp, 272]
	ldp	x10, x11, [sp, 312]
.L62:
	add	w26, w26, 8
	add	x5, x5, 64
	add	x19, x19, 8
	cmp	w21, w26
	ble	.L224
.L58:
	ldr	x0, [x11, 16]
	sub	w14, w21, w26
	ldr	x3, [x0]
	cbz	x3, .L225
	asr	w0, w26, 3
	mov	x16, 8
	mov	w4, w16
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L72:
	cmp	w14, 7
	bgt	.L56
	add	x0, sp, 512
	cmp	w14, 0
	csinc	w17, w14, wzr, gt
	ldr	w30, [sp, 120]
	lsl	x18, x16, 3
	and	w13, w17, -2
	stp	xzr, xzr, [x0, 48]
	lsr	w12, w17, 1
	stp	xzr, xzr, [x0, 64]
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	cmp	w28, w23
	ble	.L226
	.p2align 3,,7
.L59:
	sxtw	x8, w30
	cmp	w14, 0
	ble	.L65
	madd	x8, x8, x10, x24
	mov	x6, x3
	mov	x7, x9
	mov	x4, 0
	.p2align 3,,7
.L69:
	ldr	d0, [x8, x7, lsl 3]
	cmp	w14, 1
	ble	.L227
	dup	v3.2d, v0.d[0]
	ldr	q2, [x6]
	ldr	q1, [sp, 560]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 560]
	cmp	w12, 1
	bls	.L70
	ldr	q2, [x6, 16]
	ldr	q1, [sp, 576]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 576]
	cmp	w12, 2
	beq	.L70
	ldr	q2, [x6, 32]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w12, 3
	beq	.L70
	ldr	q2, [x6, 48]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
.L70:
	sxtw	x0, w13
	cmp	w13, w17
	beq	.L71
.L67:
	add	x2, x0, x4
	ldr	d1, [x27, x0, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x27, x0, lsl 3]
.L71:
	add	x7, x7, 1
	add	x4, x4, x16
	add	x6, x6, x18
	cmp	w28, w7
	bgt	.L69
	smaddl	x0, w30, w22, x19
	cmp	w14, 1
	ble	.L120
.L228:
	lsl	x4, x0, 3
	ldr	q1, [sp, 560]
	add	x2, x20, x4
	ldr	q0, [x20, x4]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x20, x4]
	cmp	w12, 1
	bls	.L64
	ldr	q0, [x2, 16]
	ldr	q1, [sp, 576]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 16]
	cmp	w12, 2
	beq	.L64
	ldr	q0, [x2, 32]
	ldr	q1, [sp, 592]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 32]
	cmp	w12, 3
	beq	.L64
	ldr	q0, [x2, 48]
	ldr	q1, [sp, 608]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x2, 48]
.L64:
	sxtw	x2, w13
	cmp	w13, w17
	beq	.L65
.L63:
	add	x0, x2, x0
	ldr	d1, [x27, x2, lsl 3]
	ldr	d0, [x20, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x20, x0, lsl 3]
.L65:
	add	w30, w30, 1
	cmp	w30, w25
	beq	.L62
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 48]
	stp	xzr, xzr, [x0, 64]
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	cmp	w28, w23
	bgt	.L59
.L226:
	cmp	w14, 0
	ble	.L65
	smaddl	x0, w30, w22, x19
	cmp	w14, 1
	bgt	.L228
.L120:
	mov	x2, 0
	b	.L63
.L227:
	mov	x0, 0
	b	.L67
.L225:
	ldp	x16, x0, [sp, 168]
	mov	w4, w22
	add	x3, x5, x0
	b	.L72
.L224:
	mov	w0, w22
	mov	w22, w21
	mov	w21, w0
.L49:
	ldr	x0, [sp, 432]
	str	w25, [sp, 120]
	ldr	x2, [sp, 520]
	add	x1, x1, x0
	ldr	x0, [sp, 176]
	add	x0, x0, x2
	str	x0, [sp, 176]
	ldr	x0, [sp, 184]
	ldr	x2, [sp, 456]
	add	x0, x0, x2
	ldr	w2, [sp, 476]
	str	x0, [sp, 184]
	cmp	w25, w2
	bne	.L52
	ldr	w0, [sp, 464]
	mov	w23, w22
	ldr	w1, [sp, 540]
	and	w0, w0, -8
	add	w0, w0, w1
	ldr	x26, [sp, 544]
	ldr	x24, [sp, 552]
	b	.L47
.L223:
	ldr	w0, [sp, 120]
	add	w25, w0, 8
	b	.L49
.L219:
	ldr	w0, [sp, 292]
	ldr	w1, [sp, 152]
	add	w0, w0, 64
	str	wzr, [sp, 144]
	str	w0, [sp, 292]
	sub	w0, w1, w0
	str	w0, [sp, 400]
	b	.L74
.L43:
	add	w1, w1, 1
	mov	w0, 0
	b	.L101
	.cfi_endproc
.LFE4285:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4286:
	.cfi_startproc
	sub	sp, sp, #720
	.cfi_def_cfa_offset 720
	stp	x29, x30, [sp]
	.cfi_offset 29, -720
	.cfi_offset 30, -712
	mov	x29, sp
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -688
	.cfi_offset 22, -680
	ldp	w1, w22, [x0, 16]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -704
	.cfi_offset 20, -696
	add	w20, w22, 6
	stp	x23, x24, [sp, 48]
	.cfi_offset 23, -672
	.cfi_offset 24, -664
	subs	w24, w22, #1
	csel	w20, w20, w24, mi
	str	w1, [sp, 100]
	ldr	x1, [x0, 8]
	asr	w20, w20, 3
	add	w20, w20, 1
	stp	x25, x26, [sp, 64]
	ldp	w23, w19, [x0, 24]
	stp	x27, x28, [sp, 80]
	.cfi_offset 25, -656
	.cfi_offset 26, -648
	.cfi_offset 27, -640
	.cfi_offset 28, -632
	str	x1, [sp, 272]
	ldr	x28, [x0]
	bl	omp_get_num_threads
	sdiv	w21, w20, w0
	mov	w25, w0
	cmp	w21, 3
	bgt	.L230
	mov	x2, 1
	mov	w6, w2
	mov	w0, 8
	str	w0, [sp, 344]
.L293:
	ldr	w4, [sp, 100]
	mov	x1, 64
	add	x0, sp, 456
	str	w6, [sp, 112]
	msub	w25, w21, w25, w20
	sbfiz	x3, x4, 6, 32
	sxtw	x4, w4
	str	x3, [sp, 104]
	str	x4, [sp, 336]
	mul	x2, x2, x3
	bl	posix_memalign
	cmp	w0, 0
	ldr	x0, [sp, 456]
	csel	x27, xzr, x0, ne
	bl	omp_get_thread_num
	cmp	w0, w25
	ldr	w6, [sp, 112]
	mov	w1, w21
	blt	.L232
.L291:
	madd	w0, w1, w0, w25
	str	w0, [sp, 324]
	add	w1, w1, w0
	str	w1, [sp, 348]
	cmp	w0, w1
	bge	.L233
	mul	w1, w6, w0
	ldr	w0, [sp, 100]
	sxtw	x24, w23
	mov	w5, 40
	sub	w0, w0, #1
	add	x2, x24, 1
	add	x0, x0, 1
	lsl	w1, w1, 3
	lsl	x7, x2, 3
	mov	w11, w1
	add	x0, x27, x0, lsl 6
	str	x0, [sp, 328]
	neg	x0, x24, lsl 4
	str	x0, [sp, 312]
	add	x0, x24, x24, lsl 2
	sub	w10, w22, w1
	sub	x8, x7, #8
	smull	x1, w23, w5
	add	x25, x28, 8
	str	x0, [sp, 408]
	neg	w0, w6, lsl 3
	lsl	x4, x24, 2
	str	w0, [sp, 396]
	lsl	w0, w6, 3
	stp	x4, x1, [sp, 416]
	add	x1, x25, x8
	sbfiz	x3, x23, 1, 32
	str	x1, [sp, 376]
	add	x1, x28, x7
	str	w0, [sp, 392]
	ubfiz	x0, x6, 3, 2
	lsl	x9, x2, 5
	add	x4, x3, x4
	str	x1, [sp, 368]
	lsl	x1, x2, 2
	str	x0, [sp, 384]
	sbfiz	x26, x19, 3, 32
	ldr	x0, [sp, 336]
	str	x1, [sp, 288]
	sub	x1, x9, #32
	str	x1, [sp, 296]
	lsl	x1, x4, 3
	mov	x23, x24
	str	x1, [sp, 432]
	add	x1, x3, x24
	mov	x24, x26
	lsl	x0, x0, 3
	str	x0, [sp, 120]
	str	x7, [sp, 200]
	str	x9, [sp, 264]
	str	w10, [sp, 304]
	str	w10, [sp, 308]
	str	w11, [sp, 320]
	str	x1, [sp, 352]
	sxtw	x1, w11
	str	x1, [sp, 256]
	str	x8, [sp, 360]
.L236:
	ldr	w1, [sp, 344]
	ldr	w0, [sp, 308]
	cmp	w0, w1
	csel	w0, w0, w1, le
	add	w1, w0, 6
	subs	w2, w0, #1
	csel	w1, w1, w2, mi
	asr	w1, w1, 3
	str	w1, [sp, 112]
	add	w1, w1, 1
	cbz	x27, .L361
	cmp	w1, 0
	ble	.L238
	ldr	w1, [sp, 112]
	ldr	w22, [sp, 304]
	ldr	x26, [sp, 328]
	sub	w0, w22, #8
	lsl	w1, w1, 3
	str	w0, [sp, 404]
	sub	w0, w0, w1
	str	w0, [sp, 144]
	ldr	x0, [sp, 256]
	str	x27, [sp, 128]
	str	x0, [sp, 136]
	stp	x25, x23, [sp, 152]
	str	w1, [sp, 400]
.L281:
	mov	w0, 8
	cmp	w22, 8
	csel	w21, w22, w0, le
	ldr	w0, [sp, 100]
	cmp	w0, 0
	ble	.L278
	sub	w19, w21, #1
	mov	w0, 7
	add	x19, x19, 1
	sub	w20, w0, w21
	add	x20, x20, 1
	cmp	w22, 0
	lsl	x19, x19, 3
	mov	x0, 8
	lsl	x20, x20, 3
	csel	x19, x19, x0, gt
	cmp	w22, 7
	sbfiz	x21, x21, 3, 32
	csel	x20, x20, x0, le
	ldp	x23, x0, [sp, 128]
	ldr	x1, [sp, 272]
	add	x25, x1, x0, lsl 3
.L283:
	mov	x2, x19
	mov	x1, x25
	mov	x0, x23
	cmp	w22, 0
	ble	.L280
	bl	memcpy
	cmp	w22, 7
	bgt	.L284
.L280:
	mov	x2, x20
	add	x0, x23, x21
	mov	w1, 0
	bl	memset
.L284:
	add	x23, x23, 64
	add	x25, x25, x24
	cmp	x23, x26
	bne	.L283
.L278:
	ldr	x0, [sp, 104]
	sub	w22, w22, #8
	ldr	x1, [sp, 128]
	add	x26, x26, x0
	add	x0, x1, x0
	str	x0, [sp, 128]
	ldr	x0, [sp, 136]
	add	x0, x0, 8
	str	x0, [sp, 136]
	ldr	w0, [sp, 144]
	cmp	w22, w0
	bne	.L281
	ldr	w0, [sp, 100]
	ldp	x25, x23, [sp, 152]
	cmp	w0, 0
	ble	.L244
	ldr	w0, [sp, 100]
	mov	w21, 4
	mov	w26, 0
	mov	x20, 0
	cmp	w0, 4
	str	x24, [sp, 128]
	csel	w21, w0, w21, le
	add	x0, x27, 64
	sub	w21, w21, #1
	mov	w24, w26
	mov	x26, x25
	mov	w25, w21
	str	x0, [sp, 280]
	mov	x0, x23
	ldr	x21, [sp, 200]
	mov	x23, x20
	mov	x19, x27
	mov	x20, x0
	mov	x22, 0
.L243:
	add	x0, sp, 464
	mov	x2, 256
	mov	w1, 0
	bl	memset
	movi	v6.2d, 0
	ldr	w0, [sp, 100]
	cmp	w0, 3
	ble	.L270
	stp	q6, q6, [sp, 464]
	stp	q6, q6, [sp, 496]
	stp	q6, q6, [sp, 528]
	stp	q6, q6, [sp, 560]
	stp	q6, q6, [sp, 592]
	stp	q6, q6, [sp, 624]
	stp	q6, q6, [sp, 656]
	stp	q6, q6, [sp, 688]
.L270:
	add	x1, x27, x22
	mov	x4, x20
	add	x0, sp, 464
	mov	x5, x28
	mov	w3, 0
.L272:
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
	cmp	w25, w3
	beq	.L362
	add	w7, w3, 1
	cmp	w7, 0
	ble	.L277
	cmp	w3, 1
	ble	.L301
	ldr	d1, [x28, x4, lsl 3]
	mov	w2, 2
	ldp	q3, q2, [x19]
	dup	v1.2d, v1.d[0]
	ldr	d0, [x26, x4, lsl 3]
	ldp	q5, q4, [x0, 64]
	dup	v0.2d, v0.d[0]
	fmul	v3.2d, v1.2d, v3.2d
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v5.2d, v3.2d, v5.2d
	fadd	v4.2d, v2.2d, v4.2d
	ldp	q3, q2, [x0, 96]
	stp	q5, q4, [x0, 64]
	ldp	q16, q7, [x19, 64]
	fmul	v16.2d, v0.2d, v16.2d
	fmul	v7.2d, v0.2d, v7.2d
	fadd	v5.2d, v16.2d, v5.2d
	fadd	v4.2d, v7.2d, v4.2d
	stp	q5, q4, [x0, 64]
	ldp	q7, q16, [x19, 32]
	fmul	v7.2d, v1.2d, v7.2d
	fmul	v1.2d, v1.2d, v16.2d
	fadd	v3.2d, v7.2d, v3.2d
	fadd	v2.2d, v1.2d, v2.2d
	stp	q3, q2, [x0, 96]
	ldp	q1, q7, [x19, 96]
	fmul	v1.2d, v0.2d, v1.2d
	fmul	v0.2d, v0.2d, v7.2d
	fadd	v3.2d, v1.2d, v3.2d
	fadd	v2.2d, v0.2d, v2.2d
	stp	q3, q2, [x0, 96]
.L276:
	add	x8, x4, x2, sxtw
	add	x6, x23, x2, sxtw 3
	add	w9, w2, 1
	lsl	x6, x6, 3
	ldr	d0, [x28, x8, lsl 3]
	add	x8, x27, x6
	dup	v0.2d, v0.d[0]
	ldr	q1, [x27, x6]
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
	bge	.L277
	add	x8, x4, x9, sxtw
	add	x6, x23, x9, sxtw 3
	add	w2, w2, 2
	lsl	x6, x6, 3
	ldr	d1, [x28, x8, lsl 3]
	add	x8, x27, x6
	ldr	q2, [x27, x6]
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
	cmp	w3, w9
	ble	.L277
	add	x3, x4, 2
	add	x2, x23, x2, sxtw 3
	lsl	x2, x2, 3
	ldr	d1, [x28, x3, lsl 3]
	add	x3, x27, x2
	ldr	q3, [x27, x2]
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
.L277:
	add	x5, x5, x21
	add	x1, x1, 64
	add	x0, x0, 64
	add	x4, x4, x20
	mov	w3, w7
	b	.L272
.L362:
	ldr	x1, [sp, 120]
	ldr	x0, [sp, 104]
	add	x23, x23, x1
	ldr	w1, [sp, 112]
	add	x22, x22, x0
	add	x19, x19, x0
	add	w0, w24, 1
	cmp	w1, w24
	beq	.L363
	mov	w24, w0
	b	.L243
.L363:
	ldr	w0, [sp, 100]
	mov	x25, x26
	mov	x23, x20
	ldr	x24, [sp, 128]
	cmp	w0, 4
	ble	.L244
	ldr	x0, [sp, 352]
	mov	x7, x23
	ldr	x1, [sp, 416]
	str	x24, [sp, 440]
	ldr	x2, [sp, 264]
	add	x0, x0, x1
	mov	x1, 4
	mov	w20, w1
	add	x6, x28, x0, lsl 3
	add	x2, x28, x2
	ldr	x0, [sp, 408]
	str	x1, [sp, 232]
	add	x0, x0, x1
	stp	x0, x2, [sp, 184]
	ldr	x0, [sp, 360]
	add	x0, x28, x0, lsl 2
	str	x0, [sp, 216]
	ldr	x0, [sp, 424]
	add	x18, x28, x0
	ldr	x0, [sp, 432]
	add	x12, x28, x0
	mov	w0, 6
	mov	x23, x12
	mov	x12, x25
	mov	x25, x6
	str	w0, [sp, 224]
	mov	w0, 5
	str	w0, [sp, 228]
.L267:
	ldp	w1, w5, [sp, 224]
	add	w0, w20, 3
	ldr	x3, [sp, 232]
	sub	w22, w20, #1
	ldr	w2, [sp, 100]
	mov	w26, 4
	sub	x1, x1, x3
	sub	x0, x0, x3
	sub	w21, w2, w20
	mov	w2, 64
	sub	x5, x5, x3
	cmp	w21, 4
	mul	x0, x0, x7
	csel	w26, w21, w26, le
	mul	x1, x1, x7
	sub	w26, w26, #1
	stp	x0, x1, [sp, 240]
	lsl	x3, x3, 6
	mul	x5, x5, x7
	ldr	x0, [sp, 280]
	mov	w8, w26
	mov	x6, x27
	mov	x26, x18
	add	x19, x27, x3
	mov	x24, 0
	umaddl	x22, w22, w2, x0
	str	wzr, [sp, 128]
	ldr	x0, [sp, 312]
	str	x3, [sp, 208]
	add	x4, x23, x0
.L266:
	add	x0, sp, 464
	mov	x2, 256
	mov	w1, 0
	stp	x5, x6, [sp, 136]
	str	x4, [sp, 152]
	str	w8, [sp, 160]
	stp	x12, x7, [sp, 168]
	bl	memset
	ldr	w8, [sp, 160]
	cmp	w21, 3
	ldp	x5, x6, [sp, 136]
	ldr	x4, [sp, 152]
	ldp	x12, x7, [sp, 168]
	ble	.L364
	movi	v16.2d, 0
	mov	x1, x6
	mov	x0, 0
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
	.p2align 3,,7
.L245:
	ldp	q4, q3, [x1]
	ldp	q2, q0, [x1, 32]
	add	x1, x1, 64
	ldr	d7, [x4, x0, lsl 3]
	ldr	d6, [x26, x0, lsl 3]
	ldr	d5, [x23, x0, lsl 3]
	fmla	v31.2d, v4.2d, v7.d[0]
	ldr	d1, [x25, x0, lsl 3]
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
	cmp	w20, w0
	bgt	.L245
	stp	q31, q30, [sp, 464]
	stp	q29, q28, [sp, 496]
	stp	q27, q26, [sp, 528]
	stp	q25, q24, [sp, 560]
	stp	q23, q22, [sp, 592]
	stp	q21, q20, [sp, 624]
	stp	q19, q18, [sp, 656]
	stp	q17, q16, [sp, 688]
.L247:
	mov	w3, 0
	ldp	x13, x0, [sp, 200]
	ldp	x9, x14, [sp, 184]
	add	x1, x6, x0
	add	x0, sp, 464
.L263:
	ldr	q0, [x0]
	ldp	q3, q2, [x1]
	ld1r	{v4.2d}, [x14]
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
	cmp	w8, w3
	beq	.L261
	add	w11, w3, 1
	cmp	w11, 0
	ble	.L265
	cmp	w3, 1
	ble	.L298
	ldr	d1, [x28, x9, lsl 3]
	mov	w2, 2
	ldp	q3, q2, [x19]
	dup	v1.2d, v1.d[0]
	ldr	d0, [x12, x9, lsl 3]
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
.L264:
	add	w10, w2, w20
	add	x16, x9, x2, sxtw
	add	w15, w2, 1
	add	x10, x24, x10, sxtw 3
	lsl	x10, x10, 3
	ldr	d0, [x28, x16, lsl 3]
	add	x16, x27, x10
	dup	v0.2d, v0.d[0]
	ldr	q1, [x27, x10]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v5.2d, v1.2d, v5.2d
	str	q5, [x0, 64]
	ldr	q1, [x16, 16]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v4.2d, v1.2d, v4.2d
	str	q4, [x0, 80]
	ldr	q1, [x16, 32]
	fmul	v1.2d, v0.2d, v1.2d
	fadd	v3.2d, v1.2d, v3.2d
	str	q3, [x0, 96]
	ldr	q1, [x16, 48]
	fmul	v0.2d, v0.2d, v1.2d
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x0, 112]
	cmp	w2, w3
	bge	.L265
	add	w10, w20, w15
	add	x16, x9, x15, sxtw
	add	w2, w2, 2
	add	x10, x24, x10, sxtw 3
	ldr	d1, [x28, x16, lsl 3]
	lsl	x10, x10, 3
	add	x16, x27, x10
	dup	v1.2d, v1.d[0]
	ldr	q2, [x27, x10]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v5.2d, v2.2d, v5.2d
	str	q5, [x0, 64]
	ldr	q2, [x16, 16]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v4.2d, v2.2d, v4.2d
	str	q4, [x0, 80]
	ldr	q2, [x16, 32]
	fmul	v2.2d, v1.2d, v2.2d
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [x0, 96]
	ldr	q3, [x16, 48]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v1.2d, v0.2d
	str	q0, [x0, 112]
	cmp	w3, w15
	ble	.L265
	add	w2, w20, w2
	add	x3, x9, 2
	add	x2, x24, x2, sxtw 3
	ldr	d1, [x28, x3, lsl 3]
	lsl	x2, x2, 3
	add	x3, x27, x2
	dup	v1.2d, v1.d[0]
	ldr	q3, [x27, x2]
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
.L265:
	add	x14, x14, x13
	add	x1, x1, 64
	add	x0, x0, 64
	add	x9, x9, x7
	mov	w3, w11
	b	.L263
.L261:
	ldr	x0, [sp, 120]
	ldr	w1, [sp, 128]
	add	x24, x24, x0
	ldr	w2, [sp, 112]
	ldr	x0, [sp, 104]
	add	x19, x19, x0
	add	x22, x22, x0
	add	x6, x6, x0
	add	w0, w1, 1
	cmp	w2, w1
	beq	.L365
	str	w0, [sp, 128]
	b	.L266
.L364:
	movi	v4.2d, 0
	mov	x1, x6
	mov	w0, 0
	mov	w15, 0
	mov	w16, 0
	mov	w17, 0
	mov	w3, 0
	mov	w9, 0
	mov	v21.16b, v4.16b
	mov	w10, 0
	mov	v22.16b, v4.16b
	mov	w14, 0
	mov	v23.16b, v4.16b
	mov	w13, 0
	mov	v17.16b, v4.16b
	mov	w11, 0
	mov	v18.16b, v4.16b
	mov	w30, 0
	mov	v19.16b, v4.16b
	mov	w18, 0
	mov	v20.16b, v4.16b
	stp	x28, x25, [sp, 136]
	mov	v25.16b, v4.16b
	mov	v26.16b, v4.16b
	mov	v27.16b, v4.16b
	mov	v24.16b, v4.16b
	mov	v5.16b, v4.16b
	mov	v6.16b, v4.16b
	mov	v7.16b, v4.16b
	mov	v16.16b, v4.16b
	ldr	x2, [sp, 216]
	ldp	x28, x25, [sp, 240]
	b	.L246
	.p2align 2,,3
.L367:
	ldr	d0, [x2, x25, lsl 3]
	mov	w0, 1
	mov	w15, w0
	mov	w16, w0
	mov	w17, w0
	mov	w3, w0
	dup	v0.2d, v0.d[0]
	mov	w9, w0
	mov	w10, w0
	mov	w14, w0
	fmul	v31.2d, v3.2d, v0.2d
	fmul	v30.2d, v2.2d, v0.2d
	fmul	v29.2d, v1.2d, v0.2d
	fmul	v0.2d, v28.2d, v0.2d
	fadd	v23.2d, v23.2d, v31.2d
	fadd	v22.2d, v22.2d, v30.2d
	fadd	v21.2d, v21.2d, v29.2d
	fadd	v4.2d, v4.2d, v0.2d
	cmp	w21, 3
	ble	.L297
	ldr	d0, [x2, x28, lsl 3]
	mov	w13, w0
	mov	w11, w0
	mov	w30, w0
	mov	w18, w0
	dup	v0.2d, v0.d[0]
	fmul	v3.2d, v0.2d, v3.2d
	fmul	v2.2d, v0.2d, v2.2d
	fmul	v1.2d, v0.2d, v1.2d
	fmul	v0.2d, v0.2d, v28.2d
	fadd	v24.2d, v24.2d, v3.2d
	fadd	v27.2d, v27.2d, v2.2d
	fadd	v26.2d, v26.2d, v1.2d
	fadd	v25.2d, v25.2d, v0.2d
.L248:
	add	x1, x1, 64
	add	x2, x2, 8
	cmp	x22, x1
	beq	.L366
.L246:
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
	cmp	w21, 1
	beq	.L248
	ldr	d0, [x2, x5, lsl 3]
	dup	v0.2d, v0.d[0]
	fmul	v31.2d, v3.2d, v0.2d
	fmul	v30.2d, v2.2d, v0.2d
	fmul	v29.2d, v1.2d, v0.2d
	fmul	v0.2d, v28.2d, v0.2d
	fadd	v20.2d, v20.2d, v31.2d
	fadd	v19.2d, v19.2d, v30.2d
	fadd	v18.2d, v18.2d, v29.2d
	fadd	v17.2d, v17.2d, v0.2d
	cmp	w21, 2
	bne	.L367
	add	x1, x1, 64
	mov	w3, 1
	add	x2, x2, 8
	mov	w9, w3
	mov	w10, w3
	mov	w14, w3
	cmp	x22, x1
	bne	.L246
.L366:
	stp	q16, q7, [sp, 464]
	stp	q6, q5, [sp, 496]
	ldp	x28, x25, [sp, 136]
	cbz	w18, .L249
	str	q24, [sp, 656]
.L249:
	cbz	w30, .L250
	str	q27, [sp, 672]
.L250:
	cbz	w11, .L251
	str	q26, [sp, 688]
.L251:
	cbz	w13, .L252
	str	q25, [sp, 704]
.L252:
	cbz	w14, .L253
	str	q20, [sp, 528]
.L253:
	cbz	w10, .L254
	str	q19, [sp, 544]
.L254:
	cbz	w9, .L255
	str	q18, [sp, 560]
.L255:
	cbz	w3, .L256
	str	q17, [sp, 576]
.L256:
	cbz	w17, .L257
	str	q23, [sp, 592]
.L257:
	cbz	w16, .L258
	str	q22, [sp, 608]
.L258:
	cbz	w15, .L259
	str	q21, [sp, 624]
.L259:
	cbz	w0, .L247
	str	q4, [sp, 640]
	b	.L247
	.p2align 2,,3
.L297:
	mov	w0, 1
	mov	w15, w0
	mov	w16, w0
	mov	w17, w0
	mov	w3, w0
	mov	w9, w0
	mov	w10, w0
	mov	w14, w0
	b	.L248
.L365:
	ldr	x0, [sp, 232]
	add	w20, w20, 4
	ldr	x1, [sp, 264]
	add	x0, x0, 4
	str	x0, [sp, 232]
	ldr	x0, [sp, 192]
	add	x0, x0, x1
	str	x0, [sp, 192]
	ldr	x0, [sp, 184]
	ldr	x1, [sp, 288]
	add	x0, x0, x1
	str	x0, [sp, 184]
	ldr	x1, [sp, 216]
	ldr	x0, [sp, 296]
	add	x1, x1, x0
	str	x1, [sp, 216]
	ldr	w1, [sp, 228]
	add	x18, x26, x0
	add	x23, x23, x0
	add	x25, x25, x0
	add	w1, w1, 4
	str	w1, [sp, 228]
	ldr	w1, [sp, 224]
	ldr	w0, [sp, 100]
	add	w1, w1, 4
	str	w1, [sp, 224]
	cmp	w0, w20
	bgt	.L267
	ldr	x24, [sp, 440]
	mov	x25, x12
	mov	x23, x7
.L244:
	ldr	w1, [sp, 400]
	mov	x22, 0
	ldr	w0, [sp, 404]
	ldr	w20, [sp, 304]
	sub	w0, w0, w1
	str	w0, [sp, 128]
	ldr	x19, [sp, 328]
	ldr	x0, [sp, 256]
	str	x0, [sp, 112]
.L242:
	mov	w0, 8
	cmp	w20, 8
	csel	w2, w20, w0, le
	ldr	w0, [sp, 100]
	cmp	w0, 0
	ble	.L239
	cmp	w20, 0
	ble	.L239
	ldr	x0, [sp, 112]
	sub	w2, w2, #1
	ldr	x1, [sp, 272]
	add	x2, x2, 1
	add	x21, x27, x22, lsl 6
	lsl	x26, x2, 3
	add	x3, x1, x0, lsl 3
.L241:
	mov	x1, x21
	mov	x0, x3
	mov	x2, x26
	add	x21, x21, 64
	bl	memcpy
	add	x3, x0, x24
	cmp	x21, x19
	bne	.L241
.L239:
	ldr	x0, [sp, 336]
	sub	w20, w20, #8
	add	x22, x22, x0
	ldr	x0, [sp, 112]
	add	x0, x0, 8
	str	x0, [sp, 112]
	ldr	x0, [sp, 104]
	add	x19, x19, x0
	ldr	w0, [sp, 128]
	cmp	w20, w0
	bne	.L242
.L238:
	ldr	w1, [sp, 308]
	ldr	w2, [sp, 396]
	ldr	w0, [sp, 324]
	add	w1, w1, w2
	ldr	w2, [sp, 320]
	str	w1, [sp, 308]
	add	w0, w0, 1
	ldr	w1, [sp, 392]
	str	w0, [sp, 324]
	add	w2, w2, w1
	str	w2, [sp, 320]
	ldr	w2, [sp, 304]
	sub	w1, w2, w1
	str	w1, [sp, 304]
	ldr	x1, [sp, 256]
	ldr	x2, [sp, 384]
	add	x1, x1, x2
	str	x1, [sp, 256]
	ldr	w1, [sp, 348]
	cmp	w1, w0
	bne	.L236
.L233:
	bl	GOMP_barrier
	mov	x0, x27
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 720
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
.L301:
	.cfi_restore_state
	mov	w2, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L276
.L298:
	mov	w2, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L264
.L230:
	cmp	w24, 0
	add	w20, w22, 14
	csel	w20, w20, w24, lt
	mov	x2, 2
	mov	w0, 16
	mov	w6, w2
	asr	w20, w20, 4
	str	w0, [sp, 344]
	add	w20, w20, 1
	sdiv	w21, w20, w25
	b	.L293
.L361:
	ldr	w1, [sp, 320]
	add	w8, w1, w0
	cmp	w1, w8
	bge	.L238
	ldr	w11, [sp, 100]
	cmp	w11, 0
	ble	.L238
	ldr	x9, [sp, 256]
	ldr	x0, [sp, 272]
	ldr	x10, [sp, 200]
	add	x7, x0, x9, lsl 3
.L289:
	ldr	d0, [x7]
	ldr	d1, [x28]
	fdiv	d0, d0, d1
	str	d0, [x7]
	cmp	w11, 1
	beq	.L286
	ldp	x5, x2, [sp, 368]
	add	x3, x7, x24
	mov	x6, x23
	mov	w4, 1
.L288:
	movi	d1, #0
	add	x1, x28, x6, lsl 3
	mov	x0, x7
	.p2align 3,,7
.L287:
	ldr	d2, [x0]
	add	x0, x0, x24
	ldr	d0, [x1], 8
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	x2, x1
	bne	.L287
	ldr	d0, [x3]
	add	w4, w4, 1
	ldr	d2, [x5]
	add	x6, x6, x23
	add	x2, x2, x10
	add	x5, x5, x10
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x3]
	add	x3, x3, x24
	cmp	w11, w4
	bne	.L288
.L286:
	add	x9, x9, 1
	add	x7, x7, 8
	cmp	w8, w9
	bgt	.L289
	b	.L238
.L232:
	add	w1, w21, 1
	mov	w25, 0
	b	.L291
	.cfi_endproc
.LFE4286:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4284:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L374
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
	bls	.L370
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L371
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L372:
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
.L370:
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
.L374:
	ret
	.p2align 2,,3
.L371:
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
	b	.L372
	.cfi_endproc
.LFE4284:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (GNU) 10.3.1"
	.section	.note.GNU-stack,"",@progbits
