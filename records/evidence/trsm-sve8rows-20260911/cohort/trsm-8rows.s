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
	blt	.L231
.L283:
	madd	w0, w1, w2, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L232
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
.L235:
	ldr	w0, [sp, 188]
	mov	w19, 8
	cmp	w0, 8
	csel	w19, w0, w19, le
	cbz	x25, .L346
	ldr	w0, [sp, 128]
	cmp	w0, 0
	ble	.L236
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
.L274:
	mov	x2, x19
	mov	x1, x25
	mov	x0, x24
	cmp	w28, 0
	ble	.L238
	bl	memcpy
	cmp	w28, 7
	bgt	.L276
.L238:
	mov	x2, x21
	add	x0, x24, x22
	mov	w1, 0
	bl	memset
.L276:
	add	x24, x24, 64
	add	x25, x25, x23
	cmp	x24, x20
	bne	.L274
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
	ble	.L242
	movi	v0.2d, 0
	stp	q0, q0, [sp, 336]
	stp	q0, q0, [sp, 368]
	stp	q0, q0, [sp, 400]
	stp	q0, q0, [sp, 432]
	stp	q0, q0, [sp, 464]
	stp	q0, q0, [sp, 496]
	stp	q0, q0, [sp, 528]
	stp	q0, q0, [sp, 560]
.L242:
	sub	w9, w19, #1
	mov	x3, x27
	add	x0, sp, 336
	mov	x1, x25
	mov	x6, x28
	mov	w2, 0
.L268:
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
	beq	.L347
	add	w7, w2, 1
	cmp	w7, 0
	ble	.L273
	cmp	w2, 1
	ble	.L288
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
.L272:
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
	bge	.L273
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
	ble	.L273
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
.L273:
	add	x6, x6, x26
	add	x1, x1, 64
	add	x0, x0, 64
	add	x3, x3, x27
	mov	w2, w7
	b	.L268
.L347:
	ldr	w1, [sp, 128]
	cmp	w1, 4
	ble	.L243
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
.L267:
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
	ble	.L348
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
.L261:
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
	bgt	.L261
	stp	q31, q30, [sp, 336]
	stp	q29, q28, [sp, 368]
	stp	q27, q26, [sp, 400]
	stp	q25, q24, [sp, 432]
	stp	q23, q22, [sp, 464]
	stp	q21, q20, [sp, 496]
	stp	q19, q18, [sp, 528]
	stp	q17, q16, [sp, 560]
.L246:
	ldr	w0, [sp, 184]
	ldp	x5, x4, [sp, 104]
	sub	w14, w0, #1
	mov	x1, x19
	add	x0, sp, 336
	mov	w3, 0
.L264:
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
	beq	.L262
	add	w7, w3, 1
	cmp	w7, 0
	ble	.L266
	cmp	w3, 1
	ble	.L287
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
.L265:
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
	bge	.L266
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
	bge	.L266
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
.L266:
	add	x5, x5, x10
	add	x1, x1, 64
	add	x0, x0, 64
	add	x4, x4, x27
	mov	w3, w7
	b	.L264
.L262:
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
	blt	.L267
	ldr	x23, [sp, 312]
	mov	x26, x10
	mov	x24, x13
.L243:
	ldr	w0, [sp, 188]
	cmp	w0, 0
	ble	.L236
	ldr	x3, [sp, 192]
	mov	x19, x25
	ldr	x21, [sp, 216]
	ldr	x20, [sp, 232]
.L240:
	mov	x1, x19
	mov	x0, x3
	mov	x2, x20
	add	x19, x19, 64
	bl	memcpy
	add	x3, x0, x23
	cmp	x19, x21
	bne	.L240
.L236:
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
	bgt	.L235
.L232:
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
.L348:
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
	b	.L248
	.p2align 2,,3
.L350:
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
	ble	.L286
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
.L247:
	add	x1, x1, 64
	add	x2, x2, 8
	cmp	x5, x1
	beq	.L349
.L248:
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
	beq	.L247
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
	bne	.L350
	add	x1, x1, 64
	mov	w3, 1
	add	x2, x2, 8
	mov	w8, w3
	mov	w14, w3
	mov	w15, w3
	cmp	x5, x1
	bne	.L248
.L349:
	stp	q16, q7, [sp, 336]
	stp	q6, q5, [sp, 368]
	cbz	w30, .L249
	str	q24, [sp, 528]
.L249:
	cbz	w12, .L250
	str	q27, [sp, 544]
.L250:
	cbz	w11, .L251
	str	q26, [sp, 560]
.L251:
	cbz	w9, .L252
	str	q25, [sp, 576]
.L252:
	cbz	w15, .L253
	str	q20, [sp, 400]
.L253:
	cbz	w14, .L254
	str	q19, [sp, 416]
.L254:
	cbz	w8, .L255
	str	q18, [sp, 432]
.L255:
	cbz	w3, .L256
	str	q17, [sp, 448]
.L256:
	cbz	w18, .L257
	str	q23, [sp, 464]
.L257:
	cbz	w17, .L258
	str	q22, [sp, 480]
.L258:
	cbz	w16, .L259
	str	q21, [sp, 496]
.L259:
	cbz	w0, .L246
	str	q4, [sp, 512]
	b	.L246
	.p2align 2,,3
.L286:
	mov	w0, 1
	mov	w16, w0
	mov	w17, w0
	mov	w18, w0
	mov	w3, w0
	mov	w8, w0
	mov	w14, w0
	mov	w15, w0
	b	.L247
.L288:
	mov	w4, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L272
.L287:
	mov	w2, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L265
.L346:
	ldr	w0, [sp, 224]
	add	w19, w0, w19
	cmp	w0, w19
	bge	.L236
	ldr	w7, [sp, 128]
	cmp	w7, 0
	ble	.L236
	ldr	x8, [sp, 192]
	ldr	x9, [sp, 208]
.L281:
	ldr	d0, [x8]
	ldr	d1, [x28]
	fdiv	d0, d0, d1
	str	d0, [x8]
	cmp	w7, 1
	beq	.L278
	ldp	x5, x2, [sp, 264]
	add	x3, x8, x23
	mov	x6, x27
	mov	w4, 1
	.p2align 3,,7
.L280:
	movi	d1, #0
	add	x1, x28, x6, lsl 3
	mov	x0, x8
	.p2align 3,,7
.L279:
	ldr	d2, [x0]
	add	x0, x0, x23
	ldr	d0, [x1], 8
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	x2, x1
	bne	.L279
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
	bne	.L280
.L278:
	add	x9, x9, 1
	add	x8, x8, 8
	cmp	w19, w9
	bgt	.L281
	b	.L236
.L231:
	add	w1, w1, 1
	mov	w0, 0
	b	.L283
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
	ble	.L357
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
	bls	.L353
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L354
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L355:
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
.L353:
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
.L357:
	ret
	.p2align 2,,3
.L354:
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
	b	.L355
	.cfi_endproc
.LFE4284:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (GNU) 10.3.1"
	.section	.note.GNU-stack,"",@progbits
