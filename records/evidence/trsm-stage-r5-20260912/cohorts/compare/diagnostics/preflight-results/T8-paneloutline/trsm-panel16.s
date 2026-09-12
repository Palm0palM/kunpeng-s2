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
	.arch armv8-a
	.type	panel_sums, %function
panel_sums:
.LFB4361:
	.cfi_startproc
	movi	v16.2d, 0
	cbz	w0, .L9
	mov	w6, 64
	sxtw	x5, w1
	mov	v17.16b, v16.16b
	sbfiz	x1, x1, 1, 32
	mov	v18.16b, v16.16b
	smaddl	x0, w0, w6, x3
	mov	v19.16b, v16.16b
	add	x6, x1, x5
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
.L8:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, 64
	ldr	d6, [x2, x5, lsl 3]
	ldr	d5, [x2, x1, lsl 3]
	ldr	d1, [x2, x6, lsl 3]
	fmla	v27.2d, v4.2d, v6.d[0]
	ld1r	{v7.2d}, [x2]
	fmla	v26.2d, v3.2d, v6.d[0]
	add	x2, x2, 8
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
	cmp	x3, x0
	bne	.L8
.L7:
	stp	q31, q30, [x4]
	stp	q29, q28, [x4, 32]
	stp	q27, q26, [x4, 64]
	stp	q25, q24, [x4, 96]
	stp	q23, q22, [x4, 128]
	stp	q21, q20, [x4, 160]
	stp	q19, q18, [x4, 192]
	stp	q17, q16, [x4, 224]
	ret
	.p2align 2,,3
.L9:
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
	b	.L7
	.cfi_endproc
.LFE4361:
	.size	panel_sums, .-panel_sums
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
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
	ble	.L15
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
.L14:
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
	bne	.L14
.L13:
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
	b	.L13
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
	ble	.L21
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
.L20:
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
	bne	.L20
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
.L19:
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
.L21:
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
	b	.L19
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
	ble	.L27
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
.L26:
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
	bne	.L26
.L25:
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
.L27:
	mov	z1.d, #0
	mov	z2.d, z1.d
	mov	z3.d, z1.d
	mov	z4.d, z1.d
	b	.L25
	.cfi_endproc
.LFE4365:
	.size	update4x8_sve, .-update4x8_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4370:
	.cfi_startproc
	sub	sp, sp, #1008
	.cfi_def_cfa_offset 1008
	stp	x29, x30, [sp]
	.cfi_offset 29, -1008
	.cfi_offset 30, -1000
	mov	x29, sp
	ldr	w2, [x0, 24]
	ldr	w1, [x0, 40]
	str	w2, [sp, 248]
	ldr	w2, [x0, 28]
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	.cfi_offset 19, -992
	.cfi_offset 20, -984
	.cfi_offset 21, -976
	.cfi_offset 22, -968
	ldp	x20, x22, [x0]
	str	x0, [sp, 288]
	str	w2, [sp, 336]
	ldp	w2, w0, [x0, 32]
	stp	w0, w2, [sp, 232]
	str	w1, [sp, 456]
	cbz	w1, .L188
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 456]
.L188:
	ldr	w0, [sp, 248]
	cmp	w0, 0
	ble	.L29
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -936
	.cfi_offset 25, -944
	mov	x21, 0
	mov	x26, x22
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -920
	.cfi_offset 27, -928
	bl	omp_get_num_threads
	mov	w19, w0
	str	w0, [sp, 536]
	bl	omp_get_thread_num
	ldr	w8, [sp, 336]
	mov	w11, w19
	ldrsw	x5, [sp, 236]
	mov	w4, 24
	adds	w2, w8, 7
	add	w1, w8, 14
	csel	w1, w1, w2, mi
	add	x10, x5, 1
	lsl	x15, x5, 1
	ldr	w7, [sp, 232]
	asr	w1, w1, 3
	lsl	x12, x5, 3
	add	w3, w8, 63
	str	x5, [sp, 400]
	sxtw	x6, w7
	stp	x5, x6, [sp, 128]
	asr	w3, w3, 6
	sdiv	w2, w1, w11
	str	w3, [sp, 460]
	smull	x4, w7, w4
	lsl	x13, x10, 5
	str	x4, [sp, 568]
	mov	w4, w7
	sbfiz	x7, x7, 3, 32
	lsl	x14, x10, 2
	msub	w1, w2, w11, w1
	lsl	x11, x10, 8
	str	x11, [sp, 648]
	add	x11, x15, x5
	cmp	w0, w1
	str	x11, [sp, 560]
	add	x11, x20, x12
	cinc	w2, w2, lt
	str	x11, [sp, 328]
	add	x11, x12, 8
	str	x11, [sp, 392]
	lsl	x11, x5, 7
	str	x11, [sp, 624]
	lsl	x11, x5, 4
	mul	w3, w2, w0
	str	x11, [sp, 616]
	lsl	x11, x5, 6
	neg	x5, x6, lsl 7
	str	x5, [sp, 656]
	neg	x5, x6, lsl 6
	add	w1, w1, w3
	str	x5, [sp, 664]
	lsl	x5, x6, 2
	csel	w1, w3, w1, lt
	str	x5, [sp, 576]
	neg	x5, x6, lsl 5
	str	x5, [sp, 672]
	add	w5, w2, w1
	add	x2, x7, 32
	str	x2, [sp, 352]
	add	x2, x7, 48
	str	x13, [sp, 544]
	sub	x13, x13, #32
	sbfiz	x9, x4, 4, 32
	lsl	w6, w1, 3
	add	x3, x7, 16
	str	x7, [sp, 96]
	mov	x19, x20
	str	x12, [sp, 160]
	str	x9, [sp, 312]
	str	x3, [sp, 344]
	str	x2, [sp, 360]
	lsl	w2, w5, 3
	str	x13, [sp, 448]
	sub	x13, x14, #4
	str	x15, [sp, 464]
	str	x13, [sp, 592]
	lsl	x13, x10, 11
	str	x14, [sp, 600]
	str	x11, [sp, 608]
	str	w2, [sp, 540]
	sub	w2, w8, w6
	str	w2, [sp, 584]
	sxtw	x2, w6
	str	x2, [sp, 632]
	add	x2, x9, 16
	str	x2, [sp, 368]
	add	x2, x9, 32
	str	x2, [sp, 376]
	add	x2, x9, 48
	str	xzr, [sp, 152]
	str	xzr, [sp, 296]
	str	x2, [sp, 384]
	sbfiz	x2, x4, 8, 32
	stp	x20, x20, [sp, 408]
	mov	x20, x13
	str	w0, [sp, 492]
	str	w5, [sp, 496]
	str	w1, [sp, 500]
	str	x2, [sp, 640]
	str	x10, [sp, 680]
	str	w6, [sp, 712]
	b	.L89
.L363:
	add	w0, w1, 256
	ldr	w1, [sp, 500]
	str	w0, [sp, 108]
	ldr	w0, [sp, 496]
	cmp	w0, w1
	bgt	.L360
.L33:
	bl	GOMP_barrier
	ldr	w1, [sp, 108]
	ldr	w0, [sp, 248]
	cmp	w0, w1
	ble	.L91
	ldr	w0, [sp, 248]
	ldr	w1, [sp, 108]
	add	w0, w0, 63
	sub	w0, w0, w1
	ldr	w1, [sp, 336]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L91
	ldr	w1, [sp, 460]
	ldr	w2, [sp, 536]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	ldr	w2, [sp, 492]
	cmp	w2, w0
	bcc	.L92
.L187:
	ldr	w2, [sp, 492]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L361
.L91:
	bl	GOMP_barrier
	ldr	x2, [sp, 296]
	ldr	x1, [sp, 640]
	ldr	x3, [sp, 648]
	add	x2, x2, x1
	str	x2, [sp, 296]
	add	x21, x21, x1
	ldr	x2, [sp, 328]
	ldr	x1, [sp, 416]
	add	x2, x2, x20
	str	x2, [sp, 328]
	ldr	x2, [sp, 400]
	add	x1, x1, x20
	ldr	x0, [sp, 152]
	add	x2, x2, x3
	str	x2, [sp, 400]
	ldr	x2, [sp, 408]
	str	x1, [sp, 416]
	ldr	w1, [sp, 248]
	add	x0, x0, 256
	add	x2, x2, x20
	str	x0, [sp, 152]
	str	x2, [sp, 408]
	cmp	w1, w0
	ble	.L362
.L89:
	ldr	x1, [sp, 152]
	str	w1, [sp, 252]
	ldr	w0, [sp, 248]
	mov	w28, w1
	sub	w0, w0, w1
	cmp	w0, 255
	bgt	.L363
	ldr	w0, [sp, 496]
	ldr	w1, [sp, 500]
	cmp	w0, w1
	ble	.L189
	ldr	w0, [sp, 248]
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -952
	.cfi_offset 23, -960
	str	w0, [sp, 108]
.L190:
	ldr	w13, [sp, 108]
	mov	x18, x20
	ldr	x27, [sp, 632]
	sub	w0, w13, w28
	str	w0, [sp, 112]
	sub	w0, w0, #1
	str	x0, [sp, 176]
	mov	x14, x21
	ldr	w0, [sp, 152]
	add	x24, x27, x21
	ldr	x1, [sp, 160]
	str	w0, [sp, 200]
	ldr	x0, [sp, 328]
	ldr	x15, [sp, 96]
	sub	x0, x0, x1
	ldr	w23, [sp, 584]
	ldr	w25, [sp, 712]
	str	x0, [sp, 168]
.L37:
	ldr	x0, [sp, 288]
	cmp	w23, 8
	ldr	x1, [x0, 16]
	mov	w0, 8
	csel	w0, w23, w0, le
	ldr	x22, [x1]
	cbz	x22, .L364
	cmp	w25, 0
	add	w1, w25, 7
	csel	w1, w1, w25, lt
	ldr	w2, [sp, 112]
	asr	w1, w1, 3
	sbfiz	x21, x1, 14, 32
	sxtw	x1, w1
	add	x21, x22, x21
	cmp	w2, 0
	ble	.L38
	mov	w2, 7
	sub	w2, w2, w0
	add	x2, x2, 1
	sbfiz	x4, x0, 3, 32
	mov	x20, x21
	mov	w0, w28
	lsl	x2, x2, 3
	mov	x5, x21
	mov	x6, x24
	mov	w7, w28
	mov	x24, x4
	mov	x28, x19
	mov	x4, x21
	mov	x19, x20
	mov	x3, x22
	mov	w21, w13
	mov	x22, x2
	mov	x8, x1
	mov	w20, w0
.L85:
	cmp	w23, 0
	ble	.L58
.L57:
	ldr	w0, [sp, 232]
	smaddl	x1, w20, w0, x27
	lsl	x0, x1, 3
	ldr	d0, [x26, x1, lsl 3]
	add	x0, x26, x0
	str	d0, [x19]
	cmp	w23, 1
	ble	.L58
	ldr	d0, [x0, 8]
	str	d0, [x19, 8]
	cmp	w23, 2
	ble	.L58
	ldr	d0, [x0, 16]
	str	d0, [x19, 16]
	cmp	w23, 3
	ble	.L58
	ldr	d0, [x0, 24]
	str	d0, [x19, 24]
	cmp	w23, 4
	ble	.L58
	ldr	d0, [x0, 32]
	str	d0, [x19, 32]
	cmp	w23, 5
	ble	.L58
	ldr	d0, [x0, 40]
	str	d0, [x19, 40]
	cmp	w23, 6
	ble	.L58
	ldr	d0, [x0, 48]
	str	d0, [x19, 48]
	cmp	w23, 7
	ble	.L58
	ldr	d0, [x0, 56]
	add	w20, w20, 1
	add	x19, x19, 64
	str	d0, [x19, -8]
	cmp	w21, w20
	bne	.L57
.L359:
	lsl	x0, x8, 8
	str	x0, [sp, 184]
	ldr	x0, [sp, 168]
	str	x0, [sp, 120]
	ldr	x0, [sp, 400]
	str	x0, [sp, 144]
	ldr	x0, [sp, 128]
	mov	w13, w21
	ldr	x10, [sp, 328]
	mov	x19, x28
	ldr	x12, [sp, 408]
	mov	x21, x4
	ldr	w8, [sp, 112]
	mov	w28, w7
	add	w11, w7, 1
	mov	x22, x3
	mov	x7, x4
	mov	x20, x5
	mov	x24, x6
	add	x4, sp, 752
	neg	x0, x0
	mov	x9, 0
	str	x0, [sp, 208]
	str	x15, [sp, 216]
	str	w13, [sp, 224]
	str	x14, [sp, 240]
.L65:
	movi	v0.4s, 0
	stp	q0, q0, [x4]
	stp	q0, q0, [x4, 32]
	stp	q0, q0, [x4, 64]
	stp	q0, q0, [x4, 96]
	stp	q0, q0, [x4, 128]
	stp	q0, q0, [x4, 160]
	stp	q0, q0, [x4, 192]
	stp	q0, q0, [x4, 224]
	cmp	w8, 3
	ble	.L365
	ldr	x2, [sp, 120]
	mov	x3, x21
	ldr	w1, [sp, 236]
	mov	w0, w9
	bl	panel_sums
.L84:
	ldr	x0, [sp, 208]
	ldp	q4, q3, [x7]
	ldp	q2, q1, [x7, 32]
	ldp	q16, q7, [sp, 752]
	ldp	q6, q5, [sp, 784]
	fsub	v4.2d, v4.2d, v16.2d
	ldr	d0, [x10, x0, lsl 3]
	fsub	v3.2d, v3.2d, v7.2d
	fsub	v2.2d, v2.2d, v6.2d
	dup	v0.2d, v0.d[0]
	fsub	v1.2d, v1.2d, v5.2d
	fdiv	v4.2d, v4.2d, v0.2d
	fdiv	v3.2d, v3.2d, v0.2d
	fdiv	v2.2d, v2.2d, v0.2d
	fdiv	v0.2d, v1.2d, v0.2d
	stp	q4, q3, [x7]
	stp	q2, q0, [x7, 32]
	cmp	w8, 1
	beq	.L75
	ldr	x0, [sp, 184]
	mov	w1, 4
	cmp	w8, 4
	add	x13, x19, 8
	add	x30, x9, x0
	csel	w14, w8, w1, le
	add	x16, x30, 1
	add	x6, x30, 2
	ldr	x5, [sp, 144]
	mov	x1, x7
	mov	x17, x10
	mov	x0, x4
	add	x16, x22, x16, lsl 6
	add	x6, x22, x6, lsl 6
	mov	w2, 1
	mov	w3, 0
	b	.L76
.L79:
	ldr	x3, [sp, 128]
	add	x0, x0, 64
	add	x5, x5, x3
	cmp	w2, 2
	beq	.L194
	ldp	q1, q0, [x7]
	mov	w3, 2
	ldr	d5, [x19, x5, lsl 3]
	ldp	q3, q2, [x0, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	ldr	d4, [x13, x5, lsl 3]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldp	q7, q6, [x0, 96]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q1, q0, [x0, 64]
	ldp	q3, q2, [x7, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x0, 64]
	ldp	q1, q0, [x7, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x0, 96]
	ldp	q3, q2, [x7, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x0, 96]
.L77:
	add	x1, x1, 64
	ldr	x15, [sp, 392]
	add	x17, x17, x15
.L76:
	sxtw	x15, w3
	add	w3, w3, 1
	str	w3, [sp, 192]
	add	x3, x30, x15
	add	x15, x15, x5
	lsl	x3, x3, 6
	ldp	q0, q6, [x0, 64]
	ldr	q2, [x22, x3]
	ldr	d1, [x19, x15, lsl 3]
	add	x15, x22, x3
	ldp	q5, q4, [x0, 96]
	fmul	v2.2d, v2.2d, v1.d[0]
	ldr	w3, [sp, 192]
	fadd	v0.2d, v2.2d, v0.2d
	str	q0, [x0, 64]
	ldr	q3, [x15, 16]
	fmul	v3.2d, v3.2d, v1.d[0]
	fadd	v3.2d, v3.2d, v6.2d
	str	q3, [x0, 80]
	ldr	q2, [x15, 32]
	fmul	v2.2d, v2.2d, v1.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x0, 96]
	ldr	q5, [x15, 48]
	fmul	v5.2d, v5.2d, v1.d[0]
	fadd	v5.2d, v5.2d, v4.2d
	str	q5, [x0, 112]
	cmp	w3, w2
	bge	.L78
	add	x3, x5, 1
	ldr	q1, [x16]
	ldr	d6, [x19, x3, lsl 3]
	fmul	v1.2d, v1.2d, v6.d[0]
	fadd	v1.2d, v1.2d, v0.2d
	mov	v0.16b, v1.16b
	str	q1, [x0, 64]
	ldr	q4, [x16, 16]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v3.2d
	str	q4, [x0, 80]
	ldr	q3, [x16, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x0, 96]
	ldr	q2, [x16, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x0, 112]
	cmp	w2, 3
	bne	.L78
	add	x3, x5, 2
	ldr	q0, [x6]
	ldr	d5, [x19, x3, lsl 3]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [x0, 64]
	ldr	q1, [x6, 16]
	fmul	v1.2d, v1.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v4.2d
	str	q1, [x0, 80]
	ldr	q1, [x6, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [x0, 96]
	ldr	q1, [x6, 48]
	fmul	v1.2d, v1.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, 112]
.L78:
	ldr	d1, [x17, 8]
	ldp	q4, q3, [x1, 64]
	add	w2, w2, 1
	dup	v1.2d, v1.d[0]
	ldr	q2, [x1, 96]
	fsub	v4.2d, v4.2d, v0.2d
	ldr	q0, [x1, 112]
	fdiv	v4.2d, v4.2d, v1.2d
	str	q4, [x1, 64]
	ldr	q4, [x0, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v1.2d
	str	q3, [x1, 80]
	ldr	q3, [x0, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v1.2d
	str	q2, [x1, 96]
	ldr	q2, [x0, 112]
	fsub	v0.2d, v0.2d, v2.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 112]
	cmp	w14, w2
	bne	.L79
.L75:
	ldr	x0, [sp, 544]
	add	x9, x9, 4
	ldr	x1, [sp, 600]
	add	x10, x10, x0
	ldr	x0, [sp, 144]
	sub	w8, w8, #4
	add	x7, x7, 256
	add	w11, w11, 4
	add	x0, x0, x1
	str	x0, [sp, 144]
	ldr	x1, [sp, 120]
	ldr	x0, [sp, 448]
	add	x1, x1, x0
	add	x12, x12, x0
	ldr	w0, [sp, 112]
	str	x1, [sp, 120]
	cmp	w0, w9
	bgt	.L65
	ldr	x15, [sp, 216]
	ldr	x14, [sp, 240]
	ldr	w13, [sp, 224]
	cmp	w23, 0
	ble	.L38
	ldr	x0, [sp, 176]
	add	x1, x0, 1
	add	x0, x26, x24, lsl 3
	add	x1, x21, x1, lsl 6
.L62:
	ldr	d0, [x20]
	str	d0, [x0]
	cmp	w23, 1
	ble	.L60
	ldr	d0, [x20, 8]
	str	d0, [x0, 8]
	cmp	w23, 2
	ble	.L60
	ldr	d0, [x20, 16]
	str	d0, [x0, 16]
	cmp	w23, 3
	ble	.L60
	ldr	d0, [x20, 24]
	str	d0, [x0, 24]
	cmp	w23, 4
	ble	.L60
	ldr	d0, [x20, 32]
	str	d0, [x0, 32]
	cmp	w23, 5
	ble	.L60
	ldr	d0, [x20, 40]
	str	d0, [x0, 40]
	cmp	w23, 6
	ble	.L60
	ldr	d0, [x20, 48]
	str	d0, [x0, 48]
	cmp	w23, 7
	ble	.L60
	ldr	d0, [x20, 56]
	str	d0, [x0, 56]
.L60:
	add	x20, x20, 64
	add	x0, x0, x15
	cmp	x1, x20
	bne	.L62
.L38:
	ldr	w0, [sp, 540]
	add	w25, w25, 8
	sub	w23, w23, #8
	add	x27, x27, 8
	add	x24, x24, 8
	cmp	w0, w25
	bgt	.L37
.L366:
	ldp	x23, x24, [sp, 48]
	.cfi_remember_state
	.cfi_restore 24
	.cfi_restore 23
	mov	x20, x18
	mov	x21, x14
	b	.L33
.L58:
	.cfi_restore_state
	add	x0, x19, x24
	add	w20, w20, 1
	mov	x2, x22
	mov	w1, 0
	str	x3, [sp, 120]
	add	x19, x19, 64
	str	x4, [sp, 144]
	stp	x15, x5, [sp, 184]
	stp	x6, x18, [sp, 208]
	str	x14, [sp, 224]
	str	w7, [sp, 240]
	str	x8, [sp, 256]
	bl	memset
	ldr	x3, [sp, 120]
	cmp	w21, w20
	ldr	x4, [sp, 144]
	ldp	x15, x5, [sp, 184]
	ldp	x6, x18, [sp, 208]
	ldr	x14, [sp, 224]
	ldr	x8, [sp, 256]
	ldr	w7, [sp, 240]
	bne	.L85
	b	.L359
.L365:
	cbz	w9, .L84
	ldr	x6, [sp, 152]
	add	w1, w11, 1
	ldr	w2, [sp, 236]
	lsl	x0, x9, 3
	movi	v0.2d, 0
	mov	x3, x21
	mov	w16, 0
	mov	w17, 0
	mov	w30, 0
	mov	w15, 0
	smaddl	x5, w2, w11, x6
	mov	w14, 0
	smaddl	x1, w2, w1, x6
	mov	w13, 0
	mov	v6.16b, v0.16b
	mov	w6, 0
	mov	v24.16b, v0.16b
	add	x5, x19, x5, lsl 3
	mov	v23.16b, v0.16b
	add	x1, x19, x1, lsl 3
	mov	v22.16b, v0.16b
	mov	x2, 0
	mov	v21.16b, v0.16b
	str	x0, [sp, 192]
	mov	v20.16b, v0.16b
	mov	w0, 0
	mov	v19.16b, v0.16b
	str	x1, [sp, 256]
	mov	v18.16b, v0.16b
	mov	v17.16b, v0.16b
	mov	v16.16b, v0.16b
	mov	v7.16b, v0.16b
.L82:
	ldp	q5, q4, [x3]
	ldp	q3, q2, [x3, 32]
	ldr	d1, [x12, x2]
	fmul	v27.2d, v5.2d, v1.d[0]
	fmul	v26.2d, v4.2d, v1.d[0]
	fmul	v25.2d, v3.2d, v1.d[0]
	fmul	v1.2d, v2.2d, v1.d[0]
	fadd	v7.2d, v7.2d, v27.2d
	fadd	v16.2d, v16.2d, v26.2d
	fadd	v17.2d, v17.2d, v25.2d
	fadd	v18.2d, v18.2d, v1.2d
	cmp	w8, 1
	ble	.L80
	ldr	d1, [x5, x2]
	mov	w0, 1
	mov	w16, w0
	mov	w6, w0
	mov	w17, w0
	fmul	v27.2d, v5.2d, v1.d[0]
	fmul	v26.2d, v4.2d, v1.d[0]
	fmul	v25.2d, v3.2d, v1.d[0]
	fmul	v1.2d, v2.2d, v1.d[0]
	fadd	v23.2d, v23.2d, v27.2d
	fadd	v24.2d, v24.2d, v26.2d
	fadd	v6.2d, v6.2d, v25.2d
	fadd	v0.2d, v0.2d, v1.2d
	cmp	w8, 3
	bne	.L80
	ldr	x1, [sp, 256]
	mov	w30, w0
	mov	w15, w0
	mov	w14, w0
	mov	w13, w0
	ldr	d1, [x1, x2]
	fmul	v5.2d, v5.2d, v1.d[0]
	fmul	v4.2d, v4.2d, v1.d[0]
	fmul	v3.2d, v3.2d, v1.d[0]
	fmul	v2.2d, v2.2d, v1.d[0]
	fadd	v19.2d, v19.2d, v5.2d
	fadd	v20.2d, v20.2d, v4.2d
	fadd	v21.2d, v21.2d, v3.2d
	fadd	v22.2d, v22.2d, v2.2d
.L80:
	ldr	x1, [sp, 192]
	add	x2, x2, 8
	add	x3, x3, 64
	cmp	x2, x1
	bne	.L82
	stp	q7, q16, [sp, 752]
	stp	q17, q18, [sp, 784]
	cbz	w0, .L67
	str	q0, [sp, 864]
.L67:
	cbz	w16, .L68
	str	q6, [sp, 848]
.L68:
	cbz	w6, .L69
	str	q24, [sp, 832]
.L69:
	cbz	w17, .L70
	str	q23, [sp, 816]
.L70:
	cbz	w30, .L71
	str	q22, [sp, 928]
.L71:
	cbz	w15, .L72
	str	q21, [sp, 912]
.L72:
	cbz	w14, .L73
	str	q20, [sp, 896]
.L73:
	cbz	w13, .L84
	str	q19, [sp, 880]
	b	.L84
.L364:
	ldr	w1, [sp, 200]
	cmp	w13, w1
	ble	.L38
	ldr	w3, [sp, 252]
	sub	w6, w13, #1
	ldr	x7, [sp, 416]
	cmp	w6, w3
	csel	w6, w6, w3, le
	cmp	w23, 0
	csinc	w0, w0, wzr, gt
	add	x16, x26, x24, lsl 3
	mov	x1, x16
	mov	x4, x24
	and	w12, w0, -2
	and	w8, w0, 1
	lsr	w5, w0, 1
.L41:
	ldr	d1, [x7]
	cmp	w23, 0
	ble	.L55
	cmp	w23, 1
	beq	.L193
	ldr	q2, [x1]
	dup	v0.2d, v1.d[0]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x1]
	cmp	w5, 1
	bls	.L54
	ldr	q2, [x1, 16]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x1, 16]
	cmp	w5, 2
	beq	.L54
	ldr	q2, [x1, 32]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x1, 32]
	cmp	w5, 3
	beq	.L54
	ldr	q2, [x1, 48]
	fdiv	v0.2d, v2.2d, v0.2d
	str	q0, [x1, 48]
.L54:
	mov	w2, w12
	cbz	w8, .L55
.L53:
	add	x2, x4, w2, sxtw
	ldr	d0, [x26, x2, lsl 3]
	fdiv	d0, d0, d1
	str	d0, [x26, x2, lsl 3]
.L55:
	ldr	x2, [sp, 392]
	add	w3, w3, 1
	add	x1, x1, x15
	add	x7, x7, x2
	ldr	x2, [sp, 136]
	add	x4, x4, x2
	cmp	w3, w6
	ble	.L41
	cmp	w3, w13
	bge	.L38
	ldr	w1, [sp, 232]
	sbfiz	x6, x3, 3, 32
	movi	v1.4s, 0
	mov	x17, x2
	and	w0, w0, 1
	add	x4, sp, 752
	smaddl	x8, w1, w3, x27
	ldr	x1, [sp, 680]
	add	x2, x26, x8, lsl 3
	madd	x11, x1, x6, x19
	ldr	x1, [sp, 128]
	madd	x6, x1, x6, x19
.L51:
	stp	q1, q1, [x4]
	stp	q1, q1, [x4, 32]
	cmp	w23, 0
	ble	.L42
	ldr	x9, [sp, 152]
	mov	x7, x16
	mov	x10, x24
.L45:
	ldr	d0, [x6, x9, lsl 3]
	cmp	w23, 1
	beq	.L191
	ldr	q3, [x7]
	ldr	q2, [sp, 752]
	fmul	v3.2d, v3.2d, v0.d[0]
	dup	v4.2d, v0.d[0]
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [sp, 752]
	cmp	w5, 1
	bls	.L44
	ldr	q3, [x7, 16]
	ldr	q2, [sp, 768]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [sp, 768]
	cmp	w5, 2
	beq	.L44
	ldr	q3, [x7, 32]
	ldr	q2, [sp, 784]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [sp, 784]
	cmp	w5, 3
	beq	.L44
	ldr	q3, [x7, 48]
	ldr	q2, [sp, 800]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [sp, 800]
.L44:
	sxtw	x1, w12
	cbz	w0, .L47
.L43:
	add	x20, x1, x10
	ldr	d2, [x4, x1, lsl 3]
	ldr	d3, [x26, x20, lsl 3]
	fmul	d0, d0, d3
	fadd	d0, d0, d2
	str	d0, [x4, x1, lsl 3]
.L47:
	add	x9, x9, 1
	add	x10, x10, x17
	add	x7, x7, x15
	cmp	w3, w9
	bgt	.L45
	ldr	d3, [x11]
	cmp	w23, 1
	beq	.L192
	ldr	q0, [x2]
	ldr	q4, [sp, 752]
	dup	v2.2d, v3.d[0]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v2.2d
	str	q0, [x2]
	cmp	w5, 1
	bls	.L49
	ldr	q0, [x2, 16]
	ldr	q4, [sp, 768]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v2.2d
	str	q0, [x2, 16]
	cmp	w5, 2
	beq	.L49
	ldr	q0, [x2, 32]
	ldr	q4, [sp, 784]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v2.2d
	str	q0, [x2, 32]
	cmp	w5, 3
	beq	.L49
	ldr	q0, [x2, 48]
	ldr	q4, [sp, 800]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v2.2d
	str	q0, [x2, 48]
.L49:
	sxtw	x1, w12
	cbz	w0, .L42
.L48:
	add	x7, x1, x8
	ldr	d2, [x4, x1, lsl 3]
	ldr	d0, [x26, x7, lsl 3]
	fsub	d0, d0, d2
	fdiv	d0, d0, d3
	str	d0, [x26, x7, lsl 3]
.L42:
	ldr	x1, [sp, 392]
	add	w3, w3, 1
	add	x8, x8, x17
	add	x2, x2, x15
	add	x11, x11, x1
	ldr	x1, [sp, 160]
	add	x6, x6, x1
	cmp	w3, w13
	bne	.L51
	ldr	w0, [sp, 540]
	add	w25, w25, 8
	sub	w23, w23, #8
	add	x27, x27, 8
	add	x24, x24, 8
	cmp	w0, w25
	bgt	.L37
	b	.L366
.L192:
	mov	x1, 0
	b	.L48
.L191:
	mov	x1, 0
	b	.L43
.L193:
	mov	w2, 0
	b	.L53
.L361:
	.cfi_restore 23
	.cfi_restore 24
	ldr	w3, [sp, 460]
	sub	w1, w1, #1
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -952
	.cfi_offset 23, -960
	add	w27, w28, 1
	ldr	w23, [sp, 108]
	str	w1, [sp, 588]
	mov	w15, 0
	sub	w18, w23, w28
	sub	w25, w23, #1
	sub	w1, w18, #1
	str	x1, [sp, 552]
	ldr	x1, [sp, 152]
	str	w1, [sp, 240]
	udiv	w2, w0, w3
	mov	x28, x19
	str	w25, [sp, 120]
	mov	x25, x26
	neg	x4, x1, lsl 3
	ldr	w1, [sp, 248]
	str	x4, [sp, 112]
	msub	w0, w2, w3, w0
	add	w7, w23, w2, lsl 6
	sub	w1, w1, w7
	str	w1, [sp, 488]
	ldr	w1, [sp, 456]
	lsl	w4, w0, 6
	str	w27, [sp, 340]
	mov	w27, w4
	str	w15, [sp, 424]
	mov	w15, w7
	and	w1, w1, 1
	str	w1, [sp, 256]
	str	w18, [sp, 428]
	str	x20, [sp, 688]
	str	x21, [sp, 696]
.L93:
	ldr	w0, [sp, 488]
	add	w1, w15, 64
	ldr	w2, [sp, 336]
	ldr	w3, [sp, 248]
	cmp	w0, 63
	sub	w0, w2, w27
	csel	w4, w1, w3, gt
	cmp	w0, 63
	bgt	.L95
	ldr	w0, [sp, 256]
	mov	w26, w15
	str	w2, [sp, 108]
	cbnz	w0, .L184
.L96:
	cmp	w4, w26
	ble	.L152
	ldr	w0, [sp, 108]
	cmp	w27, w0
	bge	.L152
.L185:
	ldp	w1, w0, [sp, 232]
	sxtw	x13, w27
	mov	w12, w4
	mov	x18, x25
	mov	w4, w27
	mov	w19, w23
	smull	x2, w1, w26
	mov	x27, x28
	ldr	x1, [sp, 552]
	smull	x0, w0, w26
	str	x0, [sp, 304]
	add	x14, x1, 1
	str	w15, [sp, 704]
	ldr	x1, [sp, 152]
	add	x1, x0, x1
	ldr	x0, [sp, 296]
	add	x1, x28, x1, lsl 3
	sub	x3, x0, x2
	add	x0, x2, x13
	add	x24, x25, x0, lsl 3
	lsl	x3, x3, 3
	mov	x15, x24
	str	x3, [sp, 320]
.L160:
	sub	w0, w12, w26
	mov	w5, 4
	cmp	w0, 4
	add	x23, x1, x14, lsl 3
	ldr	x3, [sp, 568]
	csel	w5, w0, w5, le
	cmp	w0, 3
	mov	x25, x23
	cset	w0, gt
	str	w0, [sp, 200]
	ldr	x0, [sp, 112]
	add	x3, x3, x15
	ldr	x23, [sp, 128]
	str	w26, [sp, 732]
	ldr	x10, [sp, 288]
	mov	w21, w4
	ldr	x26, [sp, 560]
	mov	x9, x13
	mov	x20, x3
	add	x0, x1, x0
	str	x2, [sp, 432]
	str	x0, [sp, 472]
	str	w5, [sp, 480]
	str	w4, [sp, 716]
	str	x3, [sp, 720]
	str	w12, [sp, 728]
	str	x13, [sp, 736]
	str	x14, [sp, 744]
.L154:
	ldr	x0, [x10, 16]
	ldr	w2, [sp, 108]
	ldr	x3, [x0]
	sub	w8, w2, w21
	cbz	x3, .L367
	asr	w0, w21, 3
	mov	x6, 8
	mov	w4, w6
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 200]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	ble	.L368
.L158:
	ldr	w0, [sp, 256]
	cbnz	w0, .L180
	movi	v16.2d, 0
	ldr	w0, [sp, 428]
	cmp	w0, 0
	ble	.L210
	ldr	x28, [sp, 464]
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
.L182:
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
	bne	.L182
.L181:
	ldp	q3, q2, [x15]
	ldp	q1, q0, [x15, 32]
	ldr	x0, [sp, 96]
	fsub	v3.2d, v3.2d, v31.2d
	fsub	v2.2d, v2.2d, v30.2d
	fsub	v1.2d, v1.2d, v29.2d
	fsub	v0.2d, v0.2d, v28.2d
	stp	q3, q2, [x15]
	stp	q1, q0, [x15, 32]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v27.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 344]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v26.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 352]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v25.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 360]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v24.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 312]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v23.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 368]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v22.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 376]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v21.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 384]
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
.L164:
	ldr	w0, [sp, 108]
	add	w21, w21, 8
	add	x9, x9, 8
	add	x15, x15, 64
	add	x20, x20, 64
	cmp	w21, w0
	blt	.L154
	ldr	x0, [sp, 448]
	ldr	x5, [sp, 672]
	add	x1, x1, x0
	ldr	x0, [sp, 320]
	ldr	x3, [sp, 720]
	add	x0, x0, x5
	str	x0, [sp, 320]
	ldr	x0, [sp, 96]
	ldr	x2, [sp, 432]
	add	x15, x3, x0
	ldr	x0, [sp, 304]
	ldr	x3, [sp, 592]
	ldr	w26, [sp, 732]
	add	x0, x0, x3
	str	x0, [sp, 304]
	ldr	x0, [sp, 576]
	add	w26, w26, 4
	ldr	w12, [sp, 728]
	ldr	x13, [sp, 736]
	add	x2, x2, x0
	ldr	x14, [sp, 744]
	ldr	w4, [sp, 716]
	cmp	w12, w26
	bgt	.L160
	ldr	w15, [sp, 704]
	mov	x28, x27
	mov	x25, x18
	mov	w27, w4
	mov	w23, w19
.L152:
	ldr	w0, [sp, 424]
	ldr	w1, [sp, 588]
	cmp	w0, w1
	beq	.L356
.L375:
	ldr	w0, [sp, 336]
	add	w27, w27, 64
	cmp	w0, w27
	ble	.L369
.L155:
	ldr	w0, [sp, 424]
	add	w0, w0, 1
	str	w0, [sp, 424]
	b	.L93
.L180:
	ldp	w6, w2, [sp, 232]
	mov	x5, x15
	ldr	w0, [sp, 252]
	str	x1, [sp, 144]
	sub	w0, w19, w0
	stp	x9, x10, [sp, 168]
	bl	update4x8_sve
	ldr	x1, [sp, 144]
	ldp	x9, x10, [sp, 168]
	b	.L164
.L367:
	ldr	x0, [sp, 320]
	ldr	x6, [sp, 136]
	add	x3, x15, x0
	ldr	w0, [sp, 200]
	ldr	w4, [sp, 232]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	bgt	.L158
.L368:
	cmp	w8, 8
	mov	w14, 8
	csel	w14, w8, w14, le
	lsl	x5, x6, 3
	sub	w0, w14, #1
	str	w0, [sp, 192]
	lsr	w0, w14, 2
	str	w0, [sp, 216]
	add	x0, x3, x5
	str	x0, [sp, 208]
	ldr	x0, [sp, 432]
	and	w7, w14, -2
	ldr	x22, [sp, 304]
	lsr	w4, w14, 1
	ldr	x11, [sp, 472]
	lsl	x2, x6, 4
	add	x12, x9, x0
	ldr	w30, [sp, 340]
	lsl	x0, x6, 1
	str	w7, [sp, 224]
	movi	v4.4s, 0
	mov	x7, x10
	ldr	x10, [sp, 96]
	str	x5, [sp, 440]
	mov	x5, x20
	ldr	w20, [sp, 480]
	stp	x9, x1, [sp, 504]
	mov	x13, x15
	ldr	w9, [sp, 120]
	str	w4, [sp, 144]
	mov	x4, x26
	mov	x26, x2
	str	x6, [sp, 168]
	mov	x6, x25
	str	x0, [sp, 184]
	add	x0, sp, 752
	mov	w24, 0
	str	x15, [sp, 520]
	str	w21, [sp, 528]
.L163:
	ldr	w1, [sp, 240]
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w19, w1
	ble	.L162
	cmp	w9, w30
	ble	.L206
	ldr	x1, [sp, 112]
	mov	x25, x3
	ldr	x16, [sp, 168]
	sub	x28, x11, x1
	ldr	x21, [sp, 208]
	mov	w1, w30
	mov	x15, 0
	str	x12, [sp, 176]
	stp	x13, x18, [sp, 264]
	str	x23, [sp, 280]
	b	.L174
.L372:
	ldp	q0, q1, [x25, 32]
	ldp	q2, q5, [x21, 32]
	ldp	q6, q16, [sp, 784]
	fmul	v1.2d, v1.2d, v7.2d
	fmul	v0.2d, v0.2d, v7.2d
	fmul	v5.2d, v5.2d, v3.2d
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v16.2d
	fadd	v0.2d, v0.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q0, q1, [sp, 784]
	.p2align 3,,7
.L171:
	add	w2, w1, 2
	ldr	x12, [sp, 184]
	add	x28, x28, 16
	add	x25, x25, x26
	add	x21, x21, x26
	add	x15, x15, x12
	add	x16, x16, x12
	cmp	w2, w9
	bge	.L370
	mov	w1, w2
.L174:
	ldr	w2, [sp, 192]
	ldr	d0, [x28]
	cmp	w2, 2
	bls	.L371
	ldp	q1, q2, [x25]
	ldp	q5, q6, [x21]
	ldp	q16, q17, [sp, 752]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d3, [x28, 8]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w2, [sp, 216]
	dup	v7.2d, v0.d[0]
	fmul	v6.2d, v6.2d, v3.d[0]
	fmul	v5.2d, v5.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v17.2d
	fadd	v1.2d, v1.2d, v16.2d
	dup	v3.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	stp	q1, q2, [sp, 752]
	cmp	w2, 2
	beq	.L372
	cmp	w8, 4
	beq	.L171
	mov	x12, 4
	mov	w2, w12
.L169:
	sub	w23, w14, w12
	sxtw	x13, w1
	cmp	w23, 1
	beq	.L172
	add	x18, x15, x12
	add	x17, x16, x12
	lsl	x12, x12, 3
	lsl	x18, x18, 3
	lsl	x17, x17, 3
	ldr	q2, [x0, x12]
	ldr	q1, [x3, x18]
	add	x18, x13, x22
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x12]
	ldr	d3, [x27, x18, lsl 3]
	ldr	q2, [x3, x17]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x12]
	tbz	x23, 0, .L171
	and	w23, w23, -2
	add	w2, w2, w23
.L172:
	sxtw	x2, w2
	add	x13, x13, x22
	add	x17, x15, x2
	add	x12, x16, x2
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x17, lsl 3]
	ldr	d1, [x3, x12, lsl 3]
	ldr	d3, [x27, x13, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
	b	.L171
.L373:
	ldr	x12, [sp, 176]
.L162:
	cmp	w8, 1
	beq	.L205
	ldr	q0, [x13]
	ldr	q1, [sp, 752]
	ldr	w1, [sp, 144]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13]
	cmp	w1, 1
	bls	.L166
	ldr	q0, [x13, 16]
	ldr	q1, [sp, 768]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 16]
	cmp	w1, 2
	beq	.L166
	ldr	q0, [x13, 32]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 32]
	cmp	w1, 4
	bne	.L166
	ldr	q0, [x13, 48]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 48]
	.p2align 3,,7
.L167:
	add	w24, w24, 1
	ldr	x1, [sp, 136]
	add	x13, x13, x10
	add	x22, x22, x23
	add	x12, x12, x1
	ldr	x1, [sp, 160]
	add	x11, x11, x1
	cmp	w24, w20
	blt	.L163
	ldp	x9, x1, [sp, 504]
	mov	x26, x4
	ldr	x15, [sp, 520]
	mov	x20, x5
	ldr	w21, [sp, 528]
	mov	x25, x6
	mov	x10, x7
	b	.L164
.L166:
	ldr	w1, [sp, 224]
	cmp	w14, w1
	beq	.L167
.L165:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x18, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x18, x2, lsl 3]
	b	.L167
.L370:
	ldp	x13, x18, [sp, 264]
	add	w1, w1, 1
	ldr	x12, [sp, 176]
	ldr	x23, [sp, 280]
.L168:
	sxtw	x17, w1
	ldr	x1, [sp, 152]
	str	x12, [sp, 176]
	ldr	x28, [sp, 168]
	sub	x16, x17, x1
	ldr	x25, [sp, 440]
	mul	x15, x28, x16
	ldr	w21, [sp, 224]
	ldr	w12, [sp, 144]
	madd	x16, x25, x16, x3
	b	.L178
	.p2align 2,,3
.L374:
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w12, 2
	beq	.L176
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w12, 4
	bne	.L176
	ldr	q1, [x16, 48]
	ldr	q0, [sp, 800]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [sp, 800]
	.p2align 3,,7
.L177:
	add	x17, x17, 1
	add	x15, x15, x28
	add	x16, x16, x25
	cmp	w19, w17
	ble	.L373
.L178:
	ldr	d0, [x11, x17, lsl 3]
	cmp	w8, 1
	beq	.L209
	ldr	q2, [x16]
	sxtw	x1, w21
	ldr	q1, [sp, 752]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 752]
	cmp	w12, 1
	bhi	.L374
.L176:
	cmp	w14, w21
	beq	.L177
.L175:
	add	x2, x1, x15
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
	b	.L177
.L209:
	mov	x1, 0
	b	.L175
.L205:
	mov	w1, 0
	b	.L165
.L206:
	ldr	w1, [sp, 252]
	b	.L168
.L371:
	mov	x12, 0
	mov	w2, 0
	b	.L169
.L210:
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
	b	.L181
.L95:
	add	w0, w27, 64
	str	w0, [sp, 108]
	ldr	w0, [sp, 256]
	cbnz	w0, .L184
	mov	w26, w15
	cmp	w15, w4
	blt	.L185
	ldr	w0, [sp, 424]
	ldr	w1, [sp, 588]
	cmp	w0, w1
	bne	.L375
.L356:
	ldp	x23, x24, [sp, 48]
	.cfi_remember_state
	.cfi_restore 24
	.cfi_restore 23
	mov	x26, x25
	ldr	x20, [sp, 688]
	mov	x19, x28
	ldr	x21, [sp, 696]
	b	.L91
.L184:
	.cfi_restore_state
	sub	w0, w4, w15
	cmp	w0, 15
	ble	.L196
	ldp	w0, w1, [sp, 232]
	mov	w19, w15
	ldr	w24, [sp, 340]
	str	w15, [sp, 320]
	smull	x0, w0, w15
	smull	x10, w1, w15
	ldr	x1, [sp, 296]
	add	x22, x0, w27, sxtw
	mov	x15, x10
	sub	x1, x1, x0
	add	x2, x25, x22, lsl 3
	ldr	x0, [sp, 152]
	lsl	x13, x1, 3
	mov	x21, x2
	mov	x14, x13
	add	x0, x10, x0
	add	x1, x28, x0, lsl 3
.L127:
	ldr	w0, [sp, 108]
	cmp	w27, w0
	bge	.L99
	ldr	x0, [sp, 112]
	mov	x10, x22
	mov	w20, w27
	mov	x13, x21
	add	x0, x1, x0
	stp	x14, x15, [sp, 264]
	str	x1, [sp, 280]
	str	x0, [sp, 304]
	str	w27, [sp, 432]
	ldr	w27, [sp, 240]
	str	w4, [sp, 440]
	str	w19, [sp, 472]
	str	x21, [sp, 480]
	str	x22, [sp, 504]
	ldr	x22, [sp, 136]
	b	.L132
.L130:
	ldr	x1, [sp, 280]
	mov	x5, x13
	ldp	w6, w2, [sp, 232]
	str	x13, [sp, 144]
	ldr	w0, [sp, 252]
	add	w20, w20, 8
	str	x10, [sp, 168]
	sub	w0, w23, w0
	bl	update16x8_sve
	ldr	x13, [sp, 144]
	ldr	x10, [sp, 168]
	add	x13, x13, 64
	ldr	w0, [sp, 108]
	add	x10, x10, 8
	cmp	w20, w0
	bge	.L376
.L132:
	ldr	x0, [sp, 288]
	ldr	w1, [sp, 108]
	ldr	x0, [x0, 16]
	sub	w6, w1, w20
	ldr	x3, [x0]
	cbz	x3, .L377
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L151:
	cmp	w6, 7
	bgt	.L130
	lsl	x0, x8, 4
	str	x0, [sp, 224]
	lsl	x0, x8, 1
	lsl	x7, x8, 3
	ldr	x18, [sp, 160]
	str	x0, [sp, 216]
	ldr	x19, [sp, 272]
	sub	w0, w6, #1
	ldr	x5, [sp, 304]
	add	x17, x25, x10, lsl 3
	movi	v4.4s, 0
	add	x30, x7, 16
	and	w21, w6, -4
	lsr	w4, w6, 1
	and	w11, w6, -2
	mov	x12, x10
	and	w9, w6, 1
	str	w0, [sp, 208]
	add	x0, sp, 752
	and	w1, w6, 3
	mov	w26, 16
	str	w1, [sp, 144]
	str	w20, [sp, 512]
	str	x10, [sp, 520]
	str	x13, [sp, 528]
	.p2align 3,,7
.L135:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w23, w27
	ble	.L134
	ldr	w1, [sp, 120]
	cmp	w1, w24
	ble	.L202
	ldr	x1, [sp, 112]
	mov	x10, x3
	mov	x16, x8
	mov	x15, 0
	sub	x20, x5, x1
	mov	w1, w24
	stp	x25, x22, [sp, 168]
	str	w4, [sp, 184]
	str	w11, [sp, 192]
	str	w26, [sp, 200]
	b	.L144
	.p2align 2,,3
.L203:
	mov	w1, w2
.L144:
	ldr	w2, [sp, 208]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x11, x4, x19
	cmp	w2, 2
	bls	.L378
	ldp	q1, q2, [x10]
	mov	w13, w21
	ldr	q5, [x10, x30]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 752]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x28, x11, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w11, [sp, 144]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 752]
	cbz	w11, .L149
.L150:
	uxtw	x11, w13
	add	x25, x4, x19
	add	x22, x11, x15
	add	x14, x16, x11
	sub	w13, w6, w13
	lsl	x11, x11, 3
	mov	x4, x25
	lsl	x22, x22, 3
	lsl	x14, x14, 3
	and	w26, w13, -2
	cmp	w13, 1
	beq	.L142
	ldr	q1, [x3, x22]
	add	w2, w2, w26
	ldr	q2, [x0, x11]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x11]
	ldr	d3, [x28, x25, lsl 3]
	ldr	q2, [x3, x14]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x11]
	tbz	x13, 0, .L149
.L142:
	sxtw	x2, w2
	ldr	d1, [x28, x4, lsl 3]
	add	x11, x2, x15
	add	x4, x16, x2
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x11, lsl 3]
	ldr	d3, [x3, x4, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
.L149:
	ldr	x4, [sp, 224]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x10, x10, x4
	ldr	x4, [sp, 216]
	add	x15, x15, x4
	add	x16, x16, x4
	ldr	w4, [sp, 120]
	cmp	w2, w4
	blt	.L203
	ldp	x25, x22, [sp, 168]
	add	w1, w1, 1
	ldr	w4, [sp, 184]
	ldr	w11, [sp, 192]
	ldr	w26, [sp, 200]
.L140:
	sxtw	x13, w1
	ldr	x1, [sp, 152]
	sub	x14, x13, x1
	mul	x10, x8, x14
	madd	x14, x14, x7, x3
	.p2align 3,,7
.L148:
	ldr	d0, [x5, x13, lsl 3]
	cmp	w6, 1
	beq	.L204
	ldr	q2, [x14]
	sxtw	x1, w11
	ldr	q1, [sp, 752]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 752]
	cmp	w4, 1
	bls	.L146
	ldr	q2, [x14, 16]
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w4, 3
	bne	.L146
	ldr	q2, [x14, 32]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
.L146:
	cbz	w9, .L147
.L145:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L147:
	add	x13, x13, 1
	add	x10, x10, x8
	add	x14, x14, x7
	cmp	w23, w13
	bgt	.L148
.L134:
	cmp	w6, 1
	beq	.L201
	ldr	q0, [x17]
	ldr	q1, [sp, 752]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17]
	cmp	w4, 1
	bls	.L138
	ldr	q0, [x17, 16]
	ldr	q1, [sp, 768]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 16]
	cmp	w4, 3
	bne	.L138
	ldr	q0, [x17, 32]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 32]
.L138:
	sxtw	x1, w11
	cbz	w9, .L139
.L137:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x25, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x25, x2, lsl 3]
.L139:
	ldr	x1, [sp, 96]
	add	x12, x12, x22
	add	x5, x5, x18
	subs	w26, w26, #1
	add	x17, x17, x1
	ldr	x1, [sp, 128]
	add	x19, x19, x1
	bne	.L135
	ldr	x10, [sp, 520]
	ldr	x13, [sp, 528]
	add	x10, x10, 8
	ldr	w20, [sp, 512]
	ldr	w0, [sp, 108]
	add	x13, x13, 64
	add	w20, w20, 8
	cmp	w20, w0
	blt	.L132
.L376:
	ldp	x14, x15, [sp, 264]
	ldr	x1, [sp, 280]
	ldr	x21, [sp, 480]
	ldr	x22, [sp, 504]
	ldr	w27, [sp, 432]
	ldr	w4, [sp, 440]
	ldr	w19, [sp, 472]
.L99:
	ldr	x0, [sp, 624]
	add	w19, w19, 16
	sub	w3, w4, w19
	add	x1, x1, x0
	ldr	x0, [sp, 616]
	add	x15, x15, x0
	ldr	x0, [sp, 656]
	add	x14, x14, x0
	sub	x21, x21, x0
	ldr	x0, [sp, 312]
	add	x22, x22, x0
	cmp	w3, 15
	bgt	.L127
	ldr	w15, [sp, 320]
	mov	w26, w19
	b	.L97
	.p2align 2,,3
.L204:
	mov	x1, 0
	b	.L145
.L201:
	mov	x1, 0
	b	.L137
.L202:
	ldr	w1, [sp, 252]
	b	.L140
.L378:
	mov	w13, 0
	mov	w2, 0
	b	.L150
.L377:
	ldr	x0, [sp, 264]
	mov	x8, x22
	ldr	w4, [sp, 232]
	add	x3, x0, x13
	b	.L151
.L362:
	.cfi_restore 23
	.cfi_restore 24
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L29:
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	add	sp, sp, 1008
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
.L92:
	.cfi_def_cfa_offset 1008
	.cfi_offset 19, -992
	.cfi_offset 20, -984
	.cfi_offset 21, -976
	.cfi_offset 22, -968
	.cfi_offset 25, -944
	.cfi_offset 26, -936
	.cfi_offset 27, -928
	.cfi_offset 28, -920
	.cfi_offset 29, -1008
	.cfi_offset 30, -1000
	add	w1, w1, 1
	mov	w0, 0
	b	.L187
.L369:
	.cfi_offset 23, -960
	.cfi_offset 24, -952
	ldr	w0, [sp, 248]
	add	w15, w15, 64
	mov	w27, 0
	sub	w0, w0, w15
	str	w0, [sp, 488]
	b	.L155
.L196:
	mov	w26, w15
.L97:
	add	w0, w26, 7
	cmp	w4, w0
	ble	.L96
	ldp	w0, w1, [sp, 232]
	str	w15, [sp, 440]
	smull	x2, w0, w26
	sub	w0, w4, #8
	sub	w24, w0, w26
	smull	x10, w1, w26
	ldr	x0, [sp, 296]
	add	x22, x2, w27, sxtw
	and	w1, w24, -8
	str	w24, [sp, 472]
	sub	x0, x0, x2
	mov	w24, w23
	ldr	x2, [sp, 152]
	lsl	x8, x0, 3
	mov	x23, x25
	add	x0, x25, x22, lsl 3
	add	x3, x10, x2
	add	w2, w26, 8
	add	w19, w2, w1
	mov	x25, x28
	add	x1, x28, x3, lsl 3
	ldr	w28, [sp, 340]
	mov	w21, w19
	mov	x16, x1
	mov	x19, x0
	mov	x15, x8
.L101:
	ldr	w0, [sp, 108]
	cmp	w27, w0
	bge	.L107
	ldr	x0, [sp, 112]
	mov	w20, w27
	mov	x1, x16
	str	x10, [sp, 320]
	add	x0, x16, x0
	mov	x10, x15
	str	x0, [sp, 432]
	str	w27, [sp, 480]
	str	w4, [sp, 504]
	str	w26, [sp, 512]
	mov	x26, x22
	str	x19, [sp, 520]
	str	w21, [sp, 528]
	str	x22, [sp, 704]
	mov	x22, x19
	str	w2, [sp, 716]
	b	.L106
.L104:
	ldp	w6, w2, [sp, 232]
	mov	x5, x22
	ldr	w0, [sp, 252]
	add	w20, w20, 8
	str	x1, [sp, 144]
	add	x22, x22, 64
	sub	w0, w24, w0
	str	x10, [sp, 168]
	bl	update8x8_sve
	add	x26, x26, 8
	ldr	w0, [sp, 108]
	ldr	x1, [sp, 144]
	ldr	x10, [sp, 168]
	cmp	w20, w0
	bge	.L379
.L106:
	ldr	x0, [sp, 288]
	ldr	w2, [sp, 108]
	ldr	x0, [x0, 16]
	sub	w5, w2, w20
	ldr	x3, [x0]
	cbz	x3, .L380
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L126:
	cmp	w5, 7
	bgt	.L104
	lsl	x0, x8, 4
	lsl	x7, x8, 3
	ldr	x19, [sp, 320]
	and	w11, w5, -2
	ldr	x6, [sp, 432]
	and	w9, w5, 1
	add	x14, x23, x26, lsl 3
	lsl	x18, x8, 1
	mov	x12, x26
	and	w2, w5, 3
	movi	v4.4s, 0
	ldr	w13, [sp, 120]
	ldr	w30, [sp, 240]
	add	x27, x7, 16
	str	x8, [sp, 184]
	mov	x8, x26
	ldr	x26, [sp, 160]
	str	x0, [sp, 200]
	sub	w0, w5, #1
	and	w21, w5, -4
	str	x6, [sp, 144]
	mov	x6, x10
	str	w9, [sp, 176]
	mov	x9, x22
	mov	w22, w2
	str	w0, [sp, 192]
	add	x0, sp, 752
	str	w11, [sp, 304]
	mov	x11, x1
	lsr	w4, w5, 1
	mov	w17, 8
	str	w4, [sp, 168]
	str	w20, [sp, 728]
.L110:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w24, w30
	ble	.L109
	cmp	w13, w28
	ble	.L198
	ldr	x2, [sp, 112]
	mov	x10, x3
	ldr	x1, [sp, 144]
	mov	x15, 0
	ldr	x16, [sp, 184]
	sub	x20, x1, x2
	mov	w1, w28
	stp	x23, x6, [sp, 208]
	str	x12, [sp, 224]
	str	w17, [sp, 264]
	str	w24, [sp, 272]
	str	x14, [sp, 280]
	b	.L119
.L199:
	mov	w1, w2
.L119:
	ldr	w2, [sp, 192]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x6, x4, x19
	cmp	w2, 2
	bls	.L381
	ldp	q1, q2, [x10]
	mov	w12, w21
	ldr	q5, [x10, x27]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 752]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x25, x6, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 752]
	cbz	w22, .L124
.L125:
	uxtw	x6, w12
	add	x23, x4, x19
	add	x17, x6, x15
	add	x14, x6, x16
	sub	w12, w5, w12
	lsl	x6, x6, 3
	mov	x4, x23
	lsl	x17, x17, 3
	lsl	x14, x14, 3
	and	w24, w12, -2
	cmp	w12, 1
	beq	.L117
	ldr	q1, [x3, x17]
	add	w2, w2, w24
	ldr	q2, [x0, x6]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x6]
	ldr	d3, [x25, x23, lsl 3]
	ldr	q2, [x3, x14]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x6]
	tbz	x12, 0, .L124
.L117:
	sxtw	x2, w2
	ldr	d1, [x25, x4, lsl 3]
	add	x6, x2, x15
	add	x4, x2, x16
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x6, lsl 3]
	ldr	d3, [x3, x4, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
.L124:
	ldr	x4, [sp, 200]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x15, x15, x18
	add	x16, x16, x18
	add	x10, x10, x4
	cmp	w2, w13
	blt	.L199
	ldp	x23, x6, [sp, 208]
	add	w1, w1, 1
	ldr	x12, [sp, 224]
	ldr	x14, [sp, 280]
	ldr	w17, [sp, 264]
	ldr	w24, [sp, 272]
.L115:
	sxtw	x15, w1
	ldr	w4, [sp, 168]
	ldr	x1, [sp, 152]
	stp	x23, x25, [sp, 208]
	ldr	w25, [sp, 176]
	ldr	x20, [sp, 184]
	sub	x16, x15, x1
	ldr	w23, [sp, 304]
	str	x19, [sp, 224]
	ldr	x19, [sp, 144]
	mul	x10, x16, x20
	madd	x16, x16, x7, x3
	.p2align 3,,7
.L123:
	ldr	d0, [x19, x15, lsl 3]
	cmp	w5, 1
	beq	.L200
	ldr	q2, [x16]
	sxtw	x1, w23
	ldr	q1, [sp, 752]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 752]
	cmp	w4, 1
	bls	.L121
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w4, 3
	bne	.L121
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
.L121:
	cbz	w25, .L122
.L120:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L122:
	add	x15, x15, 1
	add	x10, x10, x20
	add	x16, x16, x7
	cmp	w24, w15
	bgt	.L123
	ldp	x23, x25, [sp, 208]
	ldr	x19, [sp, 224]
.L109:
	cmp	w5, 1
	beq	.L197
	ldr	q0, [x14]
	ldr	q1, [sp, 752]
	ldr	w1, [sp, 168]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14]
	cmp	w1, 1
	bls	.L113
	ldr	q0, [x14, 16]
	ldr	q1, [sp, 768]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 16]
	cmp	w1, 3
	bne	.L113
	ldr	q0, [x14, 32]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 32]
.L113:
	ldr	w1, [sp, 176]
	cbz	w1, .L114
	ldr	w1, [sp, 304]
.L112:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x23, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x23, x2, lsl 3]
.L114:
	ldr	x1, [sp, 136]
	subs	w17, w17, #1
	add	x12, x12, x1
	ldr	x1, [sp, 96]
	add	x14, x14, x1
	ldr	x1, [sp, 128]
	add	x19, x19, x1
	ldr	x1, [sp, 144]
	add	x1, x1, x26
	str	x1, [sp, 144]
	bne	.L110
	ldr	w20, [sp, 728]
	mov	x26, x8
	ldr	w0, [sp, 108]
	mov	x22, x9
	add	w20, w20, 8
	mov	x10, x6
	mov	x1, x11
	add	x22, x22, 64
	add	x26, x26, 8
	cmp	w20, w0
	blt	.L106
.L379:
	ldr	x19, [sp, 520]
	mov	x15, x10
	ldr	x10, [sp, 320]
	mov	x16, x1
	ldr	x22, [sp, 704]
	ldr	w27, [sp, 480]
	ldr	w4, [sp, 504]
	ldr	w26, [sp, 512]
	ldr	w21, [sp, 528]
	ldr	w2, [sp, 716]
.L107:
	ldr	x0, [sp, 608]
	add	w26, w26, 8
	add	x16, x16, x0
	ldr	x0, [sp, 160]
	add	x10, x10, x0
	ldr	x0, [sp, 664]
	add	x15, x15, x0
	sub	x19, x19, x0
	ldr	x0, [sp, 96]
	add	x22, x22, x0
	cmp	w26, w21
	bne	.L101
	mov	x28, x25
	mov	x25, x23
	mov	w23, w24
	ldr	w24, [sp, 472]
	ldr	w15, [sp, 440]
	and	w24, w24, -8
	add	w26, w24, w2
	b	.L96
.L200:
	mov	x1, 0
	b	.L120
.L197:
	mov	w1, 0
	b	.L112
.L198:
	ldr	w1, [sp, 252]
	b	.L115
.L380:
	ldr	x8, [sp, 136]
	add	x3, x10, x22
	ldr	w4, [sp, 232]
	b	.L126
.L381:
	mov	w12, 0
	mov	w2, 0
	b	.L125
.L360:
	.cfi_restore 23
	.cfi_restore 24
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -952
	.cfi_offset 23, -960
	b	.L190
.L194:
	mov	w3, 0
	b	.L77
	.p2align 2,,3
.L189:
	.cfi_restore 23
	.cfi_restore 24
	bl	GOMP_barrier
	b	.L91
	.cfi_endproc
.LFE4370:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4371:
	.cfi_startproc
	stp	x29, x30, [sp, -496]!
	.cfi_def_cfa_offset 496
	.cfi_offset 29, -496
	.cfi_offset 30, -488
	mov	x3, x0
	mov	x1, 64
	mov	x29, sp
	stp	x21, x22, [sp, 32]
	add	x0, sp, 232
	stp	x23, x24, [sp, 48]
	.cfi_offset 21, -464
	.cfi_offset 22, -456
	.cfi_offset 23, -448
	.cfi_offset 24, -440
	ldp	w21, w23, [x3, 16]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -480
	.cfi_offset 20, -472
	ldp	w4, w19, [x3, 24]
	stp	x25, x26, [sp, 64]
	.cfi_offset 25, -432
	.cfi_offset 26, -424
	sbfiz	x25, x21, 6, 32
	ldp	x24, x2, [x3]
	str	w4, [sp, 100]
	str	x2, [sp, 120]
	mov	x2, x25
	bl	posix_memalign
	ldr	x22, [sp, 232]
	cmp	w0, 0
	csel	x22, xzr, x22, ne
	bl	omp_get_num_threads
	mov	w20, w0
	bl	omp_get_thread_num
	mov	w3, w0
	add	w1, w23, 14
	adds	w2, w23, 7
	csel	w0, w1, w2, mi
	asr	w0, w0, 3
	sdiv	w1, w0, w20
	msub	w0, w1, w20, w0
	cmp	w3, w0
	blt	.L384
.L425:
	madd	w0, w1, w3, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L385
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -408
	.cfi_offset 27, -416
	lsl	w1, w1, 3
	ldrsw	x27, [sp, 100]
	lsl	w0, w0, 3
	stp	w0, w1, [sp, 168]
	add	x3, x27, 1
	add	x28, x25, x22
	lsl	x10, x27, 3
	sub	w23, w23, w0
	lsl	x1, x3, 2
	str	x1, [sp, 176]
	add	x1, x24, x10
	str	x1, [sp, 184]
	neg	x1, x10
	str	x1, [sp, 200]
	sxtw	x1, w0
	str	x1, [sp, 112]
	ldr	x1, [sp, 120]
	lsl	x30, x3, 5
	mov	x18, x22
	sub	x25, x30, #32
	add	x15, x10, 8
	mov	x13, x10
	add	x12, x1, w0, sxtw 3
	sxtw	x1, w19
	sbfiz	x19, x19, 3, 32
	str	x12, [sp, 104]
	str	x1, [sp, 192]
	stp	x3, x30, [sp, 208]
.L388:
	cmp	w23, 8
	mov	w0, 8
	csel	w5, w23, w0, le
	cbz	x18, .L471
	cmp	w21, 0
	ble	.L389
	sub	w20, w5, #1
	mov	w0, 7
	add	x20, x20, 1
	sub	w0, w0, w5
	add	x1, x0, 1
	cmp	w23, 0
	mov	x0, 8
	lsl	x20, x20, 3
	ldr	x26, [sp, 104]
	csel	x20, x20, x0, gt
	lsl	x1, x1, 3
	sbfiz	x0, x5, 3, 32
	mov	x22, x18
	str	x24, [sp, 128]
	mov	x24, x1
	str	w21, [sp, 136]
	mov	x21, x20
	mov	x20, x19
	mov	x19, x0
	stp	x18, x13, [sp, 144]
	str	x15, [sp, 160]
.L418:
	mov	x1, x26
	mov	x2, x21
	mov	x0, x22
	cmp	w23, 0
	ble	.L391
	bl	memcpy
	cmp	w23, 7
	bgt	.L472
.L391:
	add	x0, x19, x22
	mov	x2, x24
	mov	w1, 0
	add	x22, x22, 64
	bl	memset
	add	x26, x26, x20
	cmp	x28, x22
	bne	.L418
	ldp	x18, x13, [sp, 144]
	mov	x19, x20
	ldr	x24, [sp, 128]
	mov	x20, x21
	ldr	x15, [sp, 160]
	ldr	w21, [sp, 136]
.L416:
	ldp	x12, x14, [sp, 176]
	stp	x28, x19, [sp, 136]
	mov	w8, w21
	ldr	x19, [sp, 200]
	str	x13, [sp, 152]
	ldr	x13, [sp, 216]
	mov	x10, x24
	mov	x22, x24
	mov	x26, x27
	mov	x7, x18
	add	x11, x24, 8
	mov	x9, 0
	str	w23, [sp, 128]
.L396:
	movi	v0.4s, 0
	stp	q0, q0, [sp, 240]
	stp	q0, q0, [sp, 272]
	stp	q0, q0, [sp, 304]
	stp	q0, q0, [sp, 336]
	stp	q0, q0, [sp, 368]
	stp	q0, q0, [sp, 400]
	stp	q0, q0, [sp, 432]
	stp	q0, q0, [sp, 464]
	cmp	w8, 3
	ble	.L473
	ldr	w1, [sp, 100]
	add	x4, sp, 240
	mov	x3, x18
	mov	x2, x10
	mov	w0, w9
	bl	panel_sums
.L415:
	ldp	q4, q3, [x7]
	ldp	q2, q1, [x7, 32]
	ldp	q16, q7, [sp, 240]
	ldp	q6, q5, [sp, 272]
	fsub	v4.2d, v4.2d, v16.2d
	ldr	d0, [x14, x19]
	fsub	v3.2d, v3.2d, v7.2d
	fsub	v2.2d, v2.2d, v6.2d
	dup	v0.2d, v0.d[0]
	fsub	v1.2d, v1.2d, v5.2d
	fdiv	v4.2d, v4.2d, v0.2d
	fdiv	v3.2d, v3.2d, v0.2d
	fdiv	v2.2d, v2.2d, v0.2d
	fdiv	v0.2d, v1.2d, v0.2d
	stp	q4, q3, [x7]
	stp	q2, q0, [x7, 32]
	cmp	w8, 1
	beq	.L406
	add	x23, x9, 1
	add	x28, x9, 2
	cmp	w8, 4
	mov	w5, 4
	add	x23, x18, x23, lsl 6
	csel	w5, w8, w5, le
	add	x28, x18, x28, lsl 6
	add	x1, sp, 240
	mov	x3, x14
	mov	x4, x26
	mov	x0, x7
	mov	w2, 1
	mov	w6, 0
	b	.L407
	.p2align 2,,3
.L410:
	add	x1, x1, 64
	add	x4, x4, x27
	cmp	w2, 2
	beq	.L427
	ldp	q1, q0, [x7]
	mov	w6, 2
	ldr	d5, [x24, x4, lsl 3]
	ldp	q3, q2, [x1, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	ldr	d4, [x11, x4, lsl 3]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldp	q7, q6, [x1, 96]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q1, q0, [x1, 64]
	ldp	q3, q2, [x7, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x1, 64]
	ldp	q1, q0, [x7, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x1, 96]
	ldp	q3, q2, [x7, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x1, 96]
.L408:
	add	x3, x3, x15
	add	x0, x0, 64
.L407:
	sxtw	x17, w6
	add	w6, w6, 1
	add	x16, x17, x9
	add	x17, x4, x17
	ldp	q1, q2, [x1, 64]
	lsl	x16, x16, 6
	ldr	d4, [x24, x17, lsl 3]
	add	x17, x18, x16
	ldp	q6, q5, [x1, 96]
	ldr	q0, [x18, x16]
	fmul	v0.2d, v0.2d, v4.d[0]
	fadd	v1.2d, v0.2d, v1.2d
	str	q1, [x1, 64]
	ldr	q3, [x17, 16]
	fmul	v3.2d, v3.2d, v4.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x1, 80]
	ldr	q2, [x17, 32]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	str	q2, [x1, 96]
	ldr	q0, [x17, 48]
	fmul	v0.2d, v0.2d, v4.d[0]
	fadd	v0.2d, v0.2d, v5.2d
	str	q0, [x1, 112]
	cmp	w2, w6
	ble	.L409
	add	x6, x4, 1
	ldr	q4, [x23]
	ldr	d6, [x24, x6, lsl 3]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v1.2d
	mov	v1.16b, v4.16b
	str	q4, [x1, 64]
	ldr	q5, [x23, 16]
	fmul	v5.2d, v5.2d, v6.d[0]
	fadd	v5.2d, v5.2d, v3.2d
	str	q5, [x1, 80]
	ldr	q3, [x23, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x1, 96]
	ldr	q2, [x23, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v0.2d, v2.2d, v0.2d
	str	q0, [x1, 112]
	cmp	w2, 3
	bne	.L409
	add	x6, x4, 2
	ldr	q1, [x28]
	ldr	d6, [x24, x6, lsl 3]
	fmul	v1.2d, v1.2d, v6.d[0]
	fadd	v1.2d, v1.2d, v4.2d
	str	q1, [x1, 64]
	ldr	q2, [x28, 16]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x1, 80]
	ldr	q2, [x28, 32]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [x1, 96]
	ldr	q2, [x28, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v0.2d, v2.2d, v0.2d
	str	q0, [x1, 112]
.L409:
	ldr	d0, [x3, 8]
	ldp	q4, q3, [x0, 64]
	add	w2, w2, 1
	dup	v0.2d, v0.d[0]
	ldr	q2, [x0, 96]
	fsub	v4.2d, v4.2d, v1.2d
	ldr	q1, [x0, 112]
	fdiv	v4.2d, v4.2d, v0.2d
	str	q4, [x0, 64]
	ldr	q4, [x1, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v0.2d
	str	q3, [x0, 80]
	ldr	q3, [x1, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 96]
	ldr	q2, [x1, 112]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q0, [x0, 112]
	cmp	w5, w2
	bne	.L410
.L406:
	add	x9, x9, 4
	sub	w8, w8, #4
	add	x7, x7, 256
	add	x14, x14, x13
	add	x26, x26, x12
	add	x10, x10, x25
	add	x22, x22, x25
	cmp	w21, w9
	bgt	.L396
	ldr	w23, [sp, 128]
	ldp	x28, x19, [sp, 136]
	ldr	x13, [sp, 152]
	cmp	w23, 0
	ble	.L389
	ldr	x3, [sp, 104]
	mov	x26, x13
	mov	x22, x15
	str	w21, [sp, 128]
	mov	x21, x18
	str	x18, [sp, 136]
.L393:
	mov	x1, x21
	mov	x0, x3
	mov	x2, x20
	add	x21, x21, 64
	bl	memcpy
	add	x3, x0, x19
	cmp	x28, x21
	bne	.L393
	ldr	x18, [sp, 136]
	mov	x13, x26
	ldr	w21, [sp, 128]
	mov	x15, x22
.L389:
	ldr	x1, [sp, 112]
	sub	w23, w23, #8
	ldr	w0, [sp, 168]
	add	x1, x1, 8
	str	x1, [sp, 112]
	ldr	x1, [sp, 104]
	add	w0, w0, 8
	str	w0, [sp, 168]
	add	x1, x1, 64
	str	x1, [sp, 104]
	ldr	w1, [sp, 172]
	cmp	w1, w0
	bgt	.L388
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
	mov	x22, x18
.L385:
	bl	GOMP_barrier
	ldp	x19, x20, [sp, 16]
	mov	x0, x22
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 496
	.cfi_restore 30
	.cfi_restore 29
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
.L473:
	.cfi_def_cfa_offset 496
	.cfi_offset 19, -480
	.cfi_offset 20, -472
	.cfi_offset 21, -464
	.cfi_offset 22, -456
	.cfi_offset 23, -448
	.cfi_offset 24, -440
	.cfi_offset 25, -432
	.cfi_offset 26, -424
	.cfi_offset 27, -416
	.cfi_offset 28, -408
	.cfi_offset 29, -496
	.cfi_offset 30, -488
	cbz	w9, .L415
	movi	v5.2d, 0
	add	w5, w9, 1
	add	w6, w9, 2
	sub	x5, x5, x9
	sub	x6, x6, x9
	mov	x0, x18
	mov	x4, x22
	mov	w1, 0
	mul	x5, x5, x27
	mov	w2, 0
	mul	x6, x6, x27
	mov	w16, 0
	mov	v22.16b, v5.16b
	mov	w3, 0
	mov	v21.16b, v5.16b
	mov	w30, 0
	mov	v23.16b, v5.16b
	mov	w28, 0
	mov	v26.16b, v5.16b
	mov	w23, 0
	mov	v25.16b, v5.16b
	mov	w17, 0
	mov	v24.16b, v5.16b
	mov	v27.16b, v5.16b
	mov	v16.16b, v5.16b
	mov	v7.16b, v5.16b
	mov	v6.16b, v5.16b
	mov	v17.16b, v5.16b
	.p2align 3,,7
.L413:
	ldp	q4, q3, [x0]
	ldp	q2, q1, [x0, 32]
	ld1r	{v0.2d}, [x4]
	fmul	v20.2d, v0.2d, v4.2d
	fmul	v19.2d, v0.2d, v3.2d
	fmul	v18.2d, v0.2d, v2.2d
	fmul	v0.2d, v0.2d, v1.2d
	fadd	v17.2d, v17.2d, v20.2d
	fadd	v6.2d, v6.2d, v19.2d
	fadd	v7.2d, v7.2d, v18.2d
	fadd	v16.2d, v16.2d, v0.2d
	cmp	w8, 1
	ble	.L411
	ldr	d0, [x4, x5, lsl 3]
	mov	w1, 1
	mov	w2, w1
	mov	w16, w1
	mov	w3, w1
	fmul	v20.2d, v4.2d, v0.d[0]
	fmul	v19.2d, v3.2d, v0.d[0]
	fmul	v18.2d, v2.2d, v0.d[0]
	fmul	v0.2d, v1.2d, v0.d[0]
	fadd	v23.2d, v23.2d, v20.2d
	fadd	v21.2d, v21.2d, v19.2d
	fadd	v22.2d, v22.2d, v18.2d
	fadd	v5.2d, v5.2d, v0.2d
	cmp	w8, 3
	bne	.L411
	ldr	d0, [x4, x6, lsl 3]
	mov	w30, w1
	mov	w28, w1
	mov	w23, w1
	mov	w17, w1
	fmul	v4.2d, v4.2d, v0.d[0]
	fmul	v3.2d, v3.2d, v0.d[0]
	fmul	v2.2d, v2.2d, v0.d[0]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v27.2d, v27.2d, v4.2d
	fadd	v24.2d, v24.2d, v3.2d
	fadd	v25.2d, v25.2d, v2.2d
	fadd	v26.2d, v26.2d, v1.2d
.L411:
	add	x0, x0, 64
	add	x4, x4, 8
	cmp	x7, x0
	bne	.L413
	stp	q17, q6, [sp, 240]
	stp	q7, q16, [sp, 272]
	cbz	w1, .L398
	str	q5, [sp, 352]
.L398:
	cbz	w2, .L399
	str	q22, [sp, 336]
.L399:
	cbz	w16, .L400
	str	q21, [sp, 320]
.L400:
	cbz	w3, .L401
	str	q23, [sp, 304]
.L401:
	cbz	w30, .L402
	str	q26, [sp, 416]
.L402:
	cbz	w28, .L403
	str	q25, [sp, 400]
.L403:
	cbz	w23, .L404
	str	q24, [sp, 384]
.L404:
	cbz	w17, .L415
	str	q27, [sp, 368]
	b	.L415
.L471:
	cmp	w23, 0
	ble	.L389
	cmp	w21, 0
	ble	.L389
	ldp	x6, x7, [sp, 104]
	lsl	x8, x27, 3
	ldr	x0, [sp, 208]
	add	x5, x7, w5, uxtw
	lsl	x9, x0, 3
.L422:
	ldr	d0, [x6]
	ldr	d1, [x24]
	fdiv	d0, d0, d1
	str	d0, [x6]
	cmp	w21, 1
	beq	.L421
	ldr	x0, [sp, 192]
	add	x3, x24, x9
	ldr	x2, [sp, 120]
	add	x0, x0, x7
	add	x4, x24, x8
	mov	w1, 1
	add	x0, x2, x0, lsl 3
	.p2align 3,,7
.L424:
	movi	d1, #0
	mov	x10, x6
	mov	x2, 0
	.p2align 3,,7
.L423:
	ldr	d2, [x4, x2, lsl 3]
	add	x2, x2, 1
	ldr	d0, [x10]
	add	x10, x10, x19
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w1, w2
	bgt	.L423
	ldr	d0, [x0]
	add	w1, w1, 1
	ldr	d2, [x3]
	add	x4, x4, x13
	add	x3, x3, x15
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x0]
	add	x0, x0, x19
	cmp	w21, w1
	bne	.L424
.L421:
	add	x7, x7, 1
	add	x6, x6, 8
	cmp	x7, x5
	bne	.L422
	b	.L389
.L384:
	.cfi_restore 27
	.cfi_restore 28
	add	w1, w1, 1
	mov	w0, 0
	b	.L425
.L472:
	.cfi_offset 27, -416
	.cfi_offset 28, -408
	ldp	x18, x13, [sp, 144]
	mov	x19, x20
	ldr	x24, [sp, 128]
	mov	x20, x21
	ldr	x15, [sp, 160]
	ldr	w21, [sp, 136]
	stp	x25, x27, [sp, 128]
	mov	x25, x18
	mov	x27, x13
	b	.L417
	.p2align 2,,3
.L474:
	mov	x2, x20
	mov	x1, x26
	mov	x0, x22
	str	x15, [sp, 144]
	bl	memcpy
	ldr	x15, [sp, 144]
.L417:
	add	x22, x22, 64
	add	x26, x26, x19
	cmp	x22, x28
	bne	.L474
	mov	x18, x25
	mov	x13, x27
	ldp	x25, x27, [sp, 128]
	b	.L416
.L427:
	mov	w6, 0
	b	.L408
	.cfi_endproc
.LFE4371:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4369:
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
.LFE4369:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (gcc for openEuler 3.0.2) 12.3.1"
	.section	.note.GNU-stack,"",@progbits
