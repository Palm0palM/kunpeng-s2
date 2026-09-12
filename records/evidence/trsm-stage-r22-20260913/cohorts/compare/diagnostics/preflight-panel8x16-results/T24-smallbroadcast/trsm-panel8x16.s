	.arch armv8-a
	.file	"trsm.c"
	.text
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
	.type	trsm_sve_has_eight_doubles, %function
trsm_sve_has_eight_doubles:
.LFB4368:
	.cfi_startproc
	cntd	x0
	cmp	x0, 8
	cset	w0, eq
	ret
	.cfi_endproc
.LFE4368:
	.size	trsm_sve_has_eight_doubles, .-trsm_sve_has_eight_doubles
	.align	2
	.p2align 4,,11
	.type	update8x8_sve, %function
update8x8_sve:
.LFB4370:
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
.LFE4370:
	.size	update8x8_sve, .-update8x8_sve
	.align	2
	.p2align 4,,11
	.type	update16x8_sve, %function
update16x8_sve:
.LFB4371:
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
.LFE4371:
	.size	update16x8_sve, .-update16x8_sve
	.align	2
	.p2align 4,,11
	.type	update4x8_sve, %function
update4x8_sve:
.LFB4369:
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
.LFE4369:
	.size	update4x8_sve, .-update4x8_sve
	.align	2
	.p2align 4,,11
	.type	update4x32_sve, %function
update4x32_sve:
.LFB4372:
	.cfi_startproc
	mov	w8, 24
	sxtw	x11, w5
	sbfiz	x12, x5, 4, 32
	smull	x5, w5, w8
	cmp	w0, 0
	ble	.L26
	sxtw	x10, w2
	sbfiz	x8, x2, 1, 32
	add	x9, x1, w0, sxtw 3
	sbfiz	x4, x4, 3, 32
	add	x13, x8, x10
	mov	z16.d, #0
	ptrue	p0.b, all
	mov	z17.d, z16.d
	mov	z18.d, z16.d
	mov	z19.d, z16.d
	mov	z20.d, z16.d
	mov	z21.d, z16.d
	mov	z22.d, z16.d
	mov	z23.d, z16.d
	mov	z24.d, z16.d
	mov	z25.d, z16.d
	mov	z26.d, z16.d
	mov	z27.d, z16.d
	mov	z28.d, z16.d
	mov	z29.d, z16.d
	mov	z30.d, z16.d
	mov	z31.d, z16.d
	.p2align 3,,7
.L25:
	ldr	d2, [x1, x10, lsl 3]
	ptrue	p1.b, all
	ldr	d1, [x1, x8, lsl 3]
	ld1rd	z7.d, p1/z, [x1]
	ldr	d0, [x1, x13, lsl 3]
	add	x1, x1, 8
	ld1d	z5.d, p0/z, [x3]
	ld1d	z4.d, p0/z, [x3, x11, lsl 3]
	mov	z2.d, d2
	mov	z1.d, d1
	mov	z0.d, d0
	add	x2, x3, x12
	add	x0, x3, x5
	ld1d	z6.d, p0/z, [x2]
	ld1d	z3.d, p0/z, [x0]
	add	x3, x3, x4
	fmla	z31.d, p0/m, z5.d, z7.d
	fmla	z30.d, p0/m, z4.d, z7.d
	fmla	z29.d, p0/m, z6.d, z7.d
	fmla	z28.d, p0/m, z3.d, z7.d
	fmla	z25.d, p0/m, z6.d, z2.d
	fmla	z27.d, p0/m, z5.d, z2.d
	fmla	z26.d, p0/m, z4.d, z2.d
	fmla	z24.d, p0/m, z3.d, z2.d
	fmla	z21.d, p0/m, z6.d, z1.d
	fmla	z23.d, p0/m, z5.d, z1.d
	fmla	z22.d, p0/m, z4.d, z1.d
	fmla	z20.d, p0/m, z3.d, z1.d
	fmla	z17.d, p0/m, z6.d, z0.d
	fmla	z19.d, p0/m, z5.d, z0.d
	fmla	z18.d, p0/m, z4.d, z0.d
	fmla	z16.d, p0/m, z3.d, z0.d
	cmp	x9, x1
	bne	.L25
.L24:
	ptrue	p0.b, all
	ld1d	z0.d, p0/z, [x6]
	fsub	z0.d, z0.d, z31.d
	st1d	z0.d, p0, [x6]
	add	x0, x6, 64
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z30.d
	st1d	z0.d, p0, [x0]
	add	x0, x6, 128
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z29.d
	st1d	z0.d, p0, [x0]
	sbfiz	x2, x7, 3, 32
	add	x0, x6, 192
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z28.d
	st1d	z0.d, p0, [x0]
	add	x3, x2, 64
	add	x0, x6, x2
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z27.d
	st1d	z0.d, p0, [x0]
	add	x3, x6, x3
	add	x1, x2, 128
	ld1d	z0.d, p0/z, [x3]
	fsub	z0.d, z0.d, z26.d
	st1d	z0.d, p0, [x3]
	add	x1, x6, x1
	add	x3, x2, 192
	ld1d	z0.d, p0/z, [x1]
	fsub	z0.d, z0.d, z25.d
	st1d	z0.d, p0, [x1]
	add	x3, x6, x3
	sbfiz	x1, x7, 4, 32
	ld1d	z0.d, p0/z, [x3]
	fsub	z0.d, z0.d, z24.d
	st1d	z0.d, p0, [x3]
	add	x0, x0, x2
	add	x4, x1, 64
	ld1d	z0.d, p0/z, [x0]
	mov	w5, 24
	fsub	z0.d, z0.d, z23.d
	st1d	z0.d, p0, [x0]
	add	x4, x6, x4
	add	x3, x1, 128
	ld1d	z0.d, p0/z, [x4]
	fsub	z0.d, z0.d, z22.d
	st1d	z0.d, p0, [x4]
	smull	x7, w7, w5
	add	x3, x6, x3
	add	x1, x1, 192
	ld1d	z0.d, p0/z, [x3]
	fsub	z0.d, z0.d, z21.d
	st1d	z0.d, p0, [x3]
	add	x1, x6, x1
	ld1d	z0.d, p0/z, [x1]
	fsub	z0.d, z0.d, z20.d
	st1d	z0.d, p0, [x1]
	add	x0, x0, x2
	add	x1, x7, 64
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z19.d
	st1d	z0.d, p0, [x0]
	add	x1, x6, x1
	add	x0, x7, 128
	ld1d	z0.d, p0/z, [x1]
	fsub	z0.d, z0.d, z18.d
	st1d	z0.d, p0, [x1]
	add	x0, x6, x0
	add	x7, x7, 192
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z17.d
	st1d	z0.d, p0, [x0]
	add	x6, x6, x7
	ld1d	z0.d, p0/z, [x6]
	fsub	z0.d, z0.d, z16.d
	st1d	z0.d, p0, [x6]
	ret
	.p2align 2,,3
.L26:
	mov	z16.d, #0
	mov	z17.d, z16.d
	mov	z18.d, z16.d
	mov	z19.d, z16.d
	mov	z20.d, z16.d
	mov	z21.d, z16.d
	mov	z22.d, z16.d
	mov	z23.d, z16.d
	mov	z24.d, z16.d
	mov	z25.d, z16.d
	mov	z26.d, z16.d
	mov	z27.d, z16.d
	mov	z28.d, z16.d
	mov	z29.d, z16.d
	mov	z30.d, z16.d
	mov	z31.d, z16.d
	b	.L24
	.cfi_endproc
.LFE4372:
	.size	update4x32_sve, .-update4x32_sve
	.align	2
	.p2align 4,,11
	.type	solve16x8_panel_sve, %function
solve16x8_panel_sve:
.LFB4362:
	.cfi_startproc
	stp	x29, x30, [sp, -160]!
	.cfi_def_cfa_offset 160
	.cfi_offset 29, -160
	.cfi_offset 30, -152
	sxtw	x4, w1
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x25, x26, [sp, 64]
	stp	d8, d9, [sp, 96]
	stp	d10, d11, [sp, 112]
	stp	d12, d13, [sp, 128]
	stp	d14, d15, [sp, 144]
	.cfi_offset 19, -144
	.cfi_offset 20, -136
	.cfi_offset 21, -128
	.cfi_offset 22, -120
	.cfi_offset 25, -96
	.cfi_offset 26, -88
	.cfi_offset 72, -64
	.cfi_offset 73, -56
	.cfi_offset 74, -48
	.cfi_offset 75, -40
	.cfi_offset 76, -32
	.cfi_offset 77, -24
	.cfi_offset 78, -16
	.cfi_offset 79, -8
	cbz	w0, .L31
	sbfiz	x1, x1, 3, 32
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -72
	.cfi_offset 27, -80
	add	x27, x2, x1
	mov	z1.d, #0
	add	x25, x27, x1
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -104
	.cfi_offset 23, -112
	add	x24, x25, x1
	mov	z5.d, z1.d
	add	x23, x24, x1
	sxtw	x26, w0
	add	x22, x23, x1
	sbfiz	x13, x0, 3, 32
	add	x21, x22, x1
	mov	x0, 0
	add	x20, x21, x1
	mov	z6.d, z1.d
	add	x19, x20, x1
	mov	z7.d, z1.d
	add	x30, x19, x1
	mov	z4.d, z1.d
	add	x18, x30, x1
	mov	z16.d, z1.d
	add	x17, x18, x1
	mov	z3.d, z1.d
	add	x16, x17, x1
	mov	z17.d, z1.d
	add	x15, x16, x1
	mov	z23.d, z1.d
	add	x14, x15, x1
	mov	z18.d, z1.d
	add	x1, x14, x1
	mov	z19.d, z1.d
	mov	z20.d, z1.d
	mov	z21.d, z1.d
	mov	z22.d, z1.d
	mov	z24.d, z1.d
	mov	z25.d, z1.d
	ptrue	p0.b, all
	.p2align 3,,7
.L30:
	add	x11, x2, x0
	ld1rd	z2.d, p0/z, [x11]
	ld1d	z0.d, p0/z, [x3, x0, lsl 3]
	add	x10, x27, x0
	fmla	z25.d, p0/m, z0.d, z2.d
	ld1rd	z2.d, p0/z, [x10]
	add	x9, x25, x0
	fmla	z24.d, p0/m, z0.d, z2.d
	ld1rd	z2.d, p0/z, [x9]
	add	x8, x24, x0
	fmla	z22.d, p0/m, z0.d, z2.d
	ld1rd	z2.d, p0/z, [x8]
	add	x7, x23, x0
	fmla	z21.d, p0/m, z0.d, z2.d
	ld1rd	z2.d, p0/z, [x7]
	add	x6, x22, x0
	fmla	z20.d, p0/m, z0.d, z2.d
	ld1rd	z2.d, p0/z, [x6]
	add	x5, x21, x0
	fmla	z19.d, p0/m, z0.d, z2.d
	ld1rd	z2.d, p0/z, [x5]
	add	x12, x19, x0
	fmla	z18.d, p0/m, z0.d, z2.d
	ld1rd	z2.d, p0/z, [x12]
	add	x28, x20, x0
	add	x10, x18, x0
	ld1rd	z26.d, p0/z, [x28]
	fmla	z17.d, p0/m, z0.d, z2.d
	ld1rd	z2.d, p0/z, [x10]
	add	x11, x30, x0
	add	x8, x16, x0
	fmla	z23.d, p0/m, z0.d, z26.d
	fmla	z16.d, p0/m, z0.d, z2.d
	ld1rd	z26.d, p0/z, [x11]
	ld1rd	z2.d, p0/z, [x8]
	add	x9, x17, x0
	add	x7, x15, x0
	add	x6, x14, x0
	add	x5, x1, x0
	fmla	z3.d, p0/m, z0.d, z26.d
	fmla	z7.d, p0/m, z0.d, z2.d
	ld1rd	z26.d, p0/z, [x9]
	ld1rd	z2.d, p0/z, [x6]
	add	x0, x0, 8
	fmla	z4.d, p0/m, z0.d, z26.d
	fmla	z5.d, p0/m, z0.d, z2.d
	ld1rd	z26.d, p0/z, [x7]
	ld1rd	z2.d, p0/z, [x5]
	fmla	z6.d, p0/m, z0.d, z26.d
	fmla	z1.d, p0/m, z0.d, z2.d
	cmp	x13, x0
	bne	.L30
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L29:
	add	x16, x26, x4
	ptrue	p0.b, all
	add	x11, x16, x4
	lsl	x1, x26, 6
	add	x10, x11, x4
	add	x0, x3, x1
	add	x15, x10, x4
	ld1d	z2.d, p0/z, [x0]
	add	x14, x15, x4
	add	x11, x2, x11, lsl 3
	add	x13, x14, x4
	add	x26, x2, x26, lsl 3
	add	x12, x13, x4
	ld1rd	z0.d, p0/z, [x26]
	add	x9, x12, x4
	fsub	z2.d, z2.d, z25.d
	add	x8, x9, x4
	fdiv	z2.d, p0/m, z2.d, z0.d
	add	x7, x8, x4
	st1d	z2.d, p0, [x0]
	add	x6, x7, x4
	ld1rd	z11.d, p0/z, [x11]
	add	x5, x6, x4
	add	x10, x2, x10, lsl 3
	add	x19, x5, x4
	fmla	z22.d, p0/m, z2.d, z11.d
	add	x20, x19, x4
	ld1rd	z11.d, p0/z, [x10]
	add	x0, x20, x4
	add	x16, x2, x16, lsl 3
	add	x18, x1, 64
	ld1rd	z8.d, p0/z, [x16, 8]
	ld1rd	z0.d, p0/z, [x16]
	fmad	z0.d, p0/m, z2.d, z24.d
	add	x0, x2, x0, lsl 3
	add	x4, x2, x20, lsl 3
	add	x5, x2, x5, lsl 3
	add	x6, x2, x6, lsl 3
	add	x7, x2, x7, lsl 3
	add	x8, x2, x8, lsl 3
	add	x9, x2, x9, lsl 3
	add	x12, x2, x12, lsl 3
	add	x13, x2, x13, lsl 3
	add	x14, x2, x14, lsl 3
	add	x15, x2, x15, lsl 3
	ld1rd	z13.d, p0/z, [x7]
	add	x2, x2, x19, lsl 3
	ld1rd	z14.d, p0/z, [x8]
	ld1rd	z26.d, p0/z, [x4]
	fmla	z21.d, p0/m, z2.d, z11.d
	ld1rd	z15.d, p0/z, [x15]
	ld1rd	z11.d, p0/z, [x14]
	fmad	z15.d, p0/m, z2.d, z20.d
	fmad	z11.d, p0/m, z2.d, z19.d
	add	x18, x3, x18
	ld1rd	z25.d, p0/z, [x0]
	ld1d	z24.d, p0/z, [x18]
	ld1rd	z27.d, p0/z, [x2]
	ld1rd	z12.d, p0/z, [x6]
	ld1rd	z9.d, p0/z, [x12]
	ld1rd	z10.d, p0/z, [x13]
	fmad	z9.d, p0/m, z2.d, z23.d
	fmad	z10.d, p0/m, z2.d, z18.d
	add	x17, x1, 128
	fsub	z24.d, z24.d, z0.d
	ld1rd	z0.d, p0/z, [x9]
	fdiv	z24.d, p0/m, z24.d, z8.d
	fmad	z0.d, p0/m, z2.d, z17.d
	ld1rd	z8.d, p0/z, [x5]
	st1d	z24.d, p0, [x18]
	ld1rd	z19.d, p0/z, [x11, 8]
	fmad	z19.d, p0/m, z24.d, z22.d
	ld1rd	z17.d, p0/z, [x7, 8]
	fmla	z3.d, p0/m, z2.d, z14.d
	add	x17, x3, x17
	ld1rd	z23.d, p0/z, [x10, 8]
	ld1rd	z22.d, p0/z, [x14, 8]
	fmad	z23.d, p0/m, z24.d, z21.d
	fmad	z22.d, p0/m, z24.d, z11.d
	ld1rd	z21.d, p0/z, [x15, 8]
	fmla	z16.d, p0/m, z2.d, z13.d
	fmad	z21.d, p0/m, z24.d, z15.d
	ld1rd	z29.d, p0/z, [x5, 8]
	ld1rd	z20.d, p0/z, [x6, 8]
	ld1rd	z15.d, p0/z, [x13, 8]
	ld1rd	z11.d, p0/z, [x12, 8]
	fmad	z15.d, p0/m, z24.d, z10.d
	fmad	z11.d, p0/m, z24.d, z9.d
	ld1rd	z10.d, p0/z, [x9, 8]
	ld1rd	z9.d, p0/z, [x8, 8]
	fmad	z10.d, p0/m, z24.d, z0.d
	ld1rd	z18.d, p0/z, [x2, 8]
	add	x16, x1, 192
	ld1rd	z28.d, p0/z, [x11, 16]
	ld1d	z0.d, p0/z, [x17]
	ld1rd	z13.d, p0/z, [x4, 8]
	fsub	z0.d, z0.d, z19.d
	ld1rd	z19.d, p0/z, [x0, 8]
	fdiv	z0.d, p0/m, z0.d, z28.d
	st1d	z0.d, p0, [x17]
	ld1rd	z14.d, p0/z, [x10, 16]
	fmad	z14.d, p0/m, z0.d, z23.d
	fmad	z9.d, p0/m, z24.d, z3.d
	add	x16, x3, x16
	ld1d	z3.d, p0/z, [x16]
	fsub	z3.d, z3.d, z14.d
	ld1rd	z14.d, p0/z, [x10, 24]
	fmla	z16.d, p0/m, z24.d, z17.d
	fdiv	z3.d, p0/m, z3.d, z14.d
	fmad	z12.d, p0/m, z2.d, z4.d
	ld1rd	z14.d, p0/z, [x15, 16]
	fmad	z20.d, p0/m, z24.d, z12.d
	fmad	z14.d, p0/m, z0.d, z21.d
	fmad	z8.d, p0/m, z2.d, z7.d
	ld1rd	z21.d, p0/z, [x14, 16]
	fmad	z29.d, p0/m, z24.d, z8.d
	fmad	z21.d, p0/m, z0.d, z22.d
	ld1rd	z17.d, p0/z, [x13, 16]
	ld1rd	z22.d, p0/z, [x6, 16]
	fmad	z17.d, p0/m, z0.d, z15.d
	movprfx	z4, z20
	fmla	z4.d, p0/m, z0.d, z22.d
	ld1rd	z15.d, p0/z, [x12, 16]
	ld1rd	z31.d, p0/z, [x5, 16]
	fmad	z15.d, p0/m, z0.d, z11.d
	fmad	z31.d, p0/m, z0.d, z29.d
	ld1rd	z11.d, p0/z, [x9, 16]
	add	x22, x1, 256
	fmad	z11.d, p0/m, z0.d, z10.d
	ld1rd	z10.d, p0/z, [x8, 16]
	fmad	z10.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7, 16]
	fmad	z9.d, p0/m, z0.d, z16.d
	ld1rd	z20.d, p0/z, [x0, 16]
	ld1rd	z16.d, p0/z, [x2, 16]
	add	x22, x3, x22
	ld1rd	z12.d, p0/z, [x4, 16]
	add	x21, x1, 320
	st1d	z3.d, p0, [x16]
	ld1rd	z30.d, p0/z, [x15, 24]
	ld1rd	z28.d, p0/z, [x13, 24]
	fmad	z30.d, p0/m, z3.d, z14.d
	fmad	z28.d, p0/m, z3.d, z17.d
	ld1rd	z14.d, p0/z, [x14, 24]
	ld1rd	z23.d, p0/z, [x12, 24]
	fmad	z14.d, p0/m, z3.d, z21.d
	fmad	z23.d, p0/m, z3.d, z15.d
	ld1rd	z21.d, p0/z, [x8, 24]
	ld1rd	z15.d, p0/z, [x7, 24]
	fmad	z21.d, p0/m, z3.d, z10.d
	fmad	z15.d, p0/m, z3.d, z9.d
	ld1rd	z22.d, p0/z, [x9, 24]
	ld1rd	z10.d, p0/z, [x6, 24]
	fmad	z22.d, p0/m, z3.d, z11.d
	fmad	z10.d, p0/m, z3.d, z4.d
	ld1rd	z11.d, p0/z, [x2, 24]
	ld1rd	z9.d, p0/z, [x5, 24]
	ld1rd	z17.d, p0/z, [x4, 24]
	fmad	z9.d, p0/m, z3.d, z31.d
	ld1rd	z7.d, p0/z, [x15, 32]
	ld1d	z4.d, p0/z, [x22]
	ld1rd	z31.d, p0/z, [x0, 24]
	fsub	z4.d, z4.d, z30.d
	fdiv	z4.d, p0/m, z4.d, z7.d
	st1d	z4.d, p0, [x22]
	ld1rd	z8.d, p0/z, [x14, 32]
	fmad	z8.d, p0/m, z4.d, z14.d
	add	x21, x3, x21
	ld1d	z7.d, p0/z, [x21]
	fsub	z7.d, z7.d, z8.d
	ld1rd	z8.d, p0/z, [x14, 40]
	fdiv	z7.d, p0/m, z7.d, z8.d
	ld1rd	z8.d, p0/z, [x12, 32]
	fmad	z8.d, p0/m, z4.d, z23.d
	ld1rd	z14.d, p0/z, [x13, 32]
	ld1rd	z23.d, p0/z, [x7, 32]
	fmad	z14.d, p0/m, z4.d, z28.d
	ld1rd	z29.d, p0/z, [x9, 32]
	ld1rd	z28.d, p0/z, [x8, 32]
	fmad	z29.d, p0/m, z4.d, z22.d
	fmad	z28.d, p0/m, z4.d, z21.d
	ld1rd	z22.d, p0/z, [x6, 32]
	ld1rd	z21.d, p0/z, [x5, 32]
	ld1rd	z30.d, p0/z, [x0, 32]
	fmad	z22.d, p0/m, z4.d, z10.d
	fmad	z21.d, p0/m, z4.d, z9.d
	ld1rd	z10.d, p0/z, [x2, 32]
	ld1rd	z9.d, p0/z, [x4, 32]
	fmad	z27.d, p0/m, z2.d, z6.d
	movprfx	z6, z5
	fmla	z6.d, p0/m, z2.d, z26.d
	st1d	z7.d, p0, [x21]
	ld1rd	z26.d, p0/z, [x12, 40]
	fmad	z26.d, p0/m, z7.d, z8.d
	ld1rd	z8.d, p0/z, [x7, 40]
	fmla	z6.d, p0/m, z24.d, z13.d
	fmad	z23.d, p0/m, z4.d, z15.d
	ld1rd	z13.d, p0/z, [x13, 40]
	fmla	z23.d, p0/m, z7.d, z8.d
	fmad	z13.d, p0/m, z7.d, z14.d
	ld1rd	z8.d, p0/z, [x6, 40]
	add	x20, x1, 384
	fmad	z12.d, p0/m, z0.d, z6.d
	add	x20, x3, x20
	fmla	z22.d, p0/m, z7.d, z8.d
	ld1d	z5.d, p0/z, [x20]
	ld1rd	z8.d, p0/z, [x5, 40]
	add	x19, x1, 448
	fsub	z5.d, z5.d, z13.d
	ld1rd	z13.d, p0/z, [x13, 48]
	ld1rd	z14.d, p0/z, [x8, 40]
	fdiv	z5.d, p0/m, z5.d, z13.d
	fmla	z21.d, p0/m, z7.d, z8.d
	ld1rd	z15.d, p0/z, [x2, 40]
	add	x19, x3, x19
	fmla	z27.d, p0/m, z24.d, z18.d
	ld1rd	z13.d, p0/z, [x9, 40]
	movprfx	z18, z27
	fmla	z18.d, p0/m, z0.d, z16.d
	fmad	z13.d, p0/m, z7.d, z29.d
	ld1rd	z8.d, p0/z, [x4, 40]
	ld1rd	z29.d, p0/z, [x0, 40]
	fmla	z18.d, p0/m, z3.d, z11.d
	fmad	z17.d, p0/m, z3.d, z12.d
	st1d	z5.d, p0, [x20]
	ld1rd	z6.d, p0/z, [x12, 48]
	ld1d	z11.d, p0/z, [x19]
	ld1rd	z12.d, p0/z, [x6, 48]
	fmad	z14.d, p0/m, z7.d, z28.d
	fmla	z22.d, p0/m, z5.d, z12.d
	fmad	z6.d, p0/m, z5.d, z26.d
	ld1rd	z12.d, p0/z, [x7, 48]
	fsub	z6.d, z11.d, z6.d
	ld1rd	z11.d, p0/z, [x12, 56]
	ld1rd	z28.d, p0/z, [x0, 48]
	fdiv	z6.d, p0/m, z6.d, z11.d
	fmla	z17.d, p0/m, z4.d, z9.d
	ld1rd	z11.d, p0/z, [x4, 48]
	ld1rd	z9.d, p0/z, [x5, 48]
	fmla	z23.d, p0/m, z5.d, z12.d
	fmad	z9.d, p0/m, z5.d, z21.d
	ld1rd	z12.d, p0/z, [x8, 48]
	fmla	z18.d, p0/m, z4.d, z10.d
	fmad	z12.d, p0/m, z5.d, z14.d
	ld1rd	z10.d, p0/z, [x2, 48]
	ld1rd	z14.d, p0/z, [x9, 48]
	add	x18, x1, 512
	fmad	z14.d, p0/m, z5.d, z13.d
	st1d	z6.d, p0, [x19]
	ld1rd	z13.d, p0/z, [x9, 56]
	fmad	z13.d, p0/m, z6.d, z14.d
	fmad	z8.d, p0/m, z7.d, z17.d
	add	x18, x3, x18
	fmla	z18.d, p0/m, z7.d, z15.d
	ld1d	z16.d, p0/z, [x18]
	ld1rd	z15.d, p0/z, [x5, 56]
	fsub	z16.d, z16.d, z13.d
	fmad	z15.d, p0/m, z6.d, z9.d
	ld1rd	z13.d, p0/z, [x9, 64]
	ld1rd	z9.d, p0/z, [x4, 56]
	fdiv	z16.d, p0/m, z16.d, z13.d
	ld1rd	z21.d, p0/z, [x8, 56]
	ld1rd	z13.d, p0/z, [x6, 56]
	fmad	z21.d, p0/m, z6.d, z12.d
	ld1rd	z14.d, p0/z, [x2, 56]
	ld1rd	z12.d, p0/z, [x7, 56]
	fmad	z11.d, p0/m, z5.d, z8.d
	ld1rd	z27.d, p0/z, [x0, 56]
	movprfx	z8, z11
	fmla	z8.d, p0/m, z6.d, z9.d
	add	x17, x1, 576
	st1d	z16.d, p0, [x18]
	ld1rd	z9.d, p0/z, [x8, 64]
	fmad	z9.d, p0/m, z16.d, z21.d
	fmad	z12.d, p0/m, z6.d, z23.d
	fmad	z13.d, p0/m, z6.d, z22.d
	add	x17, x3, x17
	ld1d	z17.d, p0/z, [x17]
	fsub	z17.d, z17.d, z9.d
	ld1rd	z9.d, p0/z, [x8, 72]
	fmla	z18.d, p0/m, z5.d, z10.d
	fdiv	z17.d, p0/m, z17.d, z9.d
	ld1rd	z11.d, p0/z, [x2, 64]
	ld1rd	z9.d, p0/z, [x7, 64]
	ld1rd	z10.d, p0/z, [x4, 64]
	fmad	z9.d, p0/m, z16.d, z12.d
	fmad	z10.d, p0/m, z16.d, z8.d
	ld1rd	z12.d, p0/z, [x6, 64]
	ld1rd	z26.d, p0/z, [x0, 64]
	fmad	z12.d, p0/m, z16.d, z13.d
	add	x16, x1, 640
	ld1rd	z13.d, p0/z, [x5, 64]
	st1d	z17.d, p0, [x17]
	ld1rd	z8.d, p0/z, [x7, 72]
	fmad	z8.d, p0/m, z17.d, z9.d
	fmad	z14.d, p0/m, z6.d, z18.d
	add	x16, x3, x16
	ld1d	z18.d, p0/z, [x16]
	fsub	z18.d, z18.d, z8.d
	ld1rd	z8.d, p0/z, [x7, 80]
	ld1rd	z23.d, p0/z, [x0, 72]
	fdiv	z18.d, p0/m, z18.d, z8.d
	ld1rd	z9.d, p0/z, [x2, 72]
	ld1rd	z8.d, p0/z, [x4, 72]
	fmad	z25.d, p0/m, z2.d, z1.d
	fmad	z8.d, p0/m, z17.d, z10.d
	ld1rd	z1.d, p0/z, [x6, 72]
	ld1rd	z10.d, p0/z, [x5, 72]
	fmad	z1.d, p0/m, z17.d, z12.d
	add	x15, x1, 704
	st1d	z18.d, p0, [x16]
	ld1rd	z2.d, p0/z, [x6, 80]
	fmad	z2.d, p0/m, z18.d, z1.d
	fmad	z11.d, p0/m, z16.d, z14.d
	add	x15, x3, x15
	fmad	z9.d, p0/m, z17.d, z11.d
	ld1d	z1.d, p0/z, [x15]
	fsub	z1.d, z1.d, z2.d
	ld1rd	z2.d, p0/z, [x6, 88]
	ld1rd	z11.d, p0/z, [x2, 80]
	fdiv	z1.d, p0/m, z1.d, z2.d
	ld1rd	z22.d, p0/z, [x0, 80]
	ld1rd	z2.d, p0/z, [x5, 80]
	fmad	z13.d, p0/m, z16.d, z15.d
	fmad	z11.d, p0/m, z18.d, z9.d
	fmad	z10.d, p0/m, z17.d, z13.d
	ld1rd	z9.d, p0/z, [x4, 80]
	fmad	z2.d, p0/m, z18.d, z10.d
	fmad	z9.d, p0/m, z18.d, z8.d
	add	x14, x1, 768
	st1d	z1.d, p0, [x15]
	ld1rd	z8.d, p0/z, [x5, 88]
	fmad	z8.d, p0/m, z1.d, z2.d
	add	x14, x3, x14
	ld1d	z2.d, p0/z, [x14]
	fsub	z2.d, z2.d, z8.d
	ld1rd	z8.d, p0/z, [x5, 96]
	fmla	z25.d, p0/m, z24.d, z19.d
	fdiv	z2.d, p0/m, z2.d, z8.d
	ld1rd	z10.d, p0/z, [x2, 88]
	ld1rd	z8.d, p0/z, [x4, 88]
	ld1rd	z24.d, p0/z, [x0, 88]
	fmad	z8.d, p0/m, z1.d, z9.d
	fmad	z10.d, p0/m, z1.d, z11.d
	add	x11, x1, 832
	st1d	z2.d, p0, [x14]
	ld1rd	z9.d, p0/z, [x2, 96]
	fmad	z9.d, p0/m, z2.d, z10.d
	add	x8, x3, x11
	ld1d	z19.d, p0/z, [x8]
	fsub	z19.d, z19.d, z9.d
	ld1rd	z9.d, p0/z, [x2, 104]
	ld1rd	z21.d, p0/z, [x0, 96]
	fdiv	z19.d, p0/m, z19.d, z9.d
	add	x10, x1, 896
	ld1rd	z9.d, p0/z, [x4, 96]
	fmad	z9.d, p0/m, z2.d, z8.d
	st1d	z19.d, p0, [x8]
	ld1rd	z8.d, p0/z, [x4, 104]
	fmad	z8.d, p0/m, z19.d, z9.d
	fmad	z0.d, p0/m, z20.d, z25.d
	add	x7, x3, x10
	ld1rd	z25.d, p0/z, [x0, 104]
	ld1d	z20.d, p0/z, [x7]
	fsub	z20.d, z20.d, z8.d
	ld1rd	z8.d, p0/z, [x4, 112]
	fmad	z3.d, p0/m, z31.d, z0.d
	fdiv	z20.d, p0/m, z20.d, z8.d
	add	x1, x1, 960
	st1d	z20.d, p0, [x7]
	ld1rd	z8.d, p0/z, [x0, 112]
	ldp	x19, x20, [sp, 16]
	add	x3, x3, x1
	fmad	z4.d, p0/m, z30.d, z3.d
	ldp	x21, x22, [sp, 32]
	ld1d	z0.d, p0/z, [x3]
	ld1rd	z3.d, p0/z, [x0, 120]
	fmad	z7.d, p0/m, z29.d, z4.d
	ldp	x25, x26, [sp, 64]
	fmad	z5.d, p0/m, z28.d, z7.d
	fmad	z6.d, p0/m, z27.d, z5.d
	fmad	z16.d, p0/m, z26.d, z6.d
	ldp	d10, d11, [sp, 112]
	fmad	z17.d, p0/m, z23.d, z16.d
	fmad	z18.d, p0/m, z22.d, z17.d
	fmad	z1.d, p0/m, z24.d, z18.d
	ldp	d12, d13, [sp, 128]
	fmad	z2.d, p0/m, z21.d, z1.d
	fmad	z19.d, p0/m, z25.d, z2.d
	fmad	z20.d, p0/m, z8.d, z19.d
	ldp	d8, d9, [sp, 96]
	fsub	z0.d, z0.d, z20.d
	fdiv	z0.d, p0/m, z0.d, z3.d
	st1d	z0.d, p0, [x3]
	ldp	d14, d15, [sp, 144]
	ldp	x29, x30, [sp], 160
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 78
	.cfi_restore 79
	.cfi_restore 76
	.cfi_restore 77
	.cfi_restore 74
	.cfi_restore 75
	.cfi_restore 72
	.cfi_restore 73
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L31:
	.cfi_restore_state
	mov	z1.d, #0
	mov	x26, 0
	mov	z5.d, z1.d
	mov	z6.d, z1.d
	mov	z7.d, z1.d
	mov	z4.d, z1.d
	mov	z16.d, z1.d
	mov	z3.d, z1.d
	mov	z17.d, z1.d
	mov	z23.d, z1.d
	mov	z18.d, z1.d
	mov	z19.d, z1.d
	mov	z20.d, z1.d
	mov	z21.d, z1.d
	mov	z22.d, z1.d
	mov	z24.d, z1.d
	mov	z25.d, z1.d
	b	.L29
	.cfi_endproc
.LFE4362:
	.size	solve16x8_panel_sve, .-solve16x8_panel_sve
	.align	2
	.p2align 4,,11
	.type	solve16x8_panel_packedL_sve, %function
solve16x8_panel_packedL_sve:
.LFB4363:
	.cfi_startproc
	stp	x29, x30, [sp, -112]!
	.cfi_def_cfa_offset 112
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	str	x21, [sp, 32]
	stp	d8, d9, [sp, 48]
	stp	d10, d11, [sp, 64]
	stp	d12, d13, [sp, 80]
	stp	d14, d15, [sp, 96]
	.cfi_offset 19, -96
	.cfi_offset 20, -88
	.cfi_offset 21, -80
	.cfi_offset 72, -64
	.cfi_offset 73, -56
	.cfi_offset 74, -48
	.cfi_offset 75, -40
	.cfi_offset 76, -32
	.cfi_offset 77, -24
	.cfi_offset 78, -16
	.cfi_offset 79, -8
	cbz	w0, .L37
	mov	w6, 128
	mov	x5, x3
	mov	z21.d, #0
	ptrue	p0.b, all
	smaddl	x6, w0, w6, x4
	mov	z22.d, z21.d
	mov	z23.d, z21.d
	mov	z24.d, z21.d
	mov	z1.d, z21.d
	mov	z2.d, z21.d
	mov	z3.d, z21.d
	mov	z4.d, z21.d
	mov	z5.d, z21.d
	mov	z6.d, z21.d
	mov	z7.d, z21.d
	mov	z16.d, z21.d
	mov	z17.d, z21.d
	mov	z18.d, z21.d
	mov	z19.d, z21.d
	mov	z20.d, z21.d
	.p2align 3,,7
.L36:
	ld1rd	z26.d, p0/z, [x4]
	ld1rd	z25.d, p0/z, [x4, 8]
	ld1d	z0.d, p0/z, [x5]
	fmla	z20.d, p0/m, z0.d, z26.d
	fmla	z19.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x4, 16]
	ld1rd	z25.d, p0/z, [x4, 24]
	fmla	z18.d, p0/m, z0.d, z26.d
	fmla	z17.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x4, 32]
	ld1rd	z25.d, p0/z, [x4, 40]
	fmla	z16.d, p0/m, z0.d, z26.d
	fmla	z7.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x4, 48]
	ld1rd	z25.d, p0/z, [x4, 56]
	fmla	z6.d, p0/m, z0.d, z26.d
	fmla	z5.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x4, 64]
	ld1rd	z25.d, p0/z, [x4, 72]
	fmla	z4.d, p0/m, z0.d, z26.d
	fmla	z3.d, p0/m, z0.d, z25.d
	ld1rd	z26.d, p0/z, [x4, 80]
	ld1rd	z25.d, p0/z, [x4, 88]
	fmla	z2.d, p0/m, z0.d, z26.d
	fmla	z1.d, p0/m, z0.d, z25.d
	ld1rd	z28.d, p0/z, [x4, 96]
	ld1rd	z27.d, p0/z, [x4, 104]
	ld1rd	z26.d, p0/z, [x4, 112]
	ld1rd	z25.d, p0/z, [x4, 120]
	add	x4, x4, 128
	add	x5, x5, 64
	fmla	z24.d, p0/m, z0.d, z28.d
	fmla	z23.d, p0/m, z0.d, z27.d
	fmla	z22.d, p0/m, z0.d, z26.d
	fmla	z21.d, p0/m, z0.d, z25.d
	cmp	x6, x4
	bne	.L36
.L35:
	sxtw	x1, w1
	sbfiz	x4, x0, 6, 32
	add	x16, x1, w0, sxtw
	ptrue	p0.b, all
	add	x11, x1, x16
	add	x5, x3, x4
	add	x10, x1, x11
	ld1d	z0.d, p0/z, [x5]
	add	x15, x1, x10
	add	x0, x2, w0, sxtw 3
	add	x14, x1, x15
	fsub	z20.d, z0.d, z20.d
	add	x13, x1, x14
	ld1rd	z0.d, p0/z, [x0]
	add	x12, x1, x13
	fdiv	z20.d, p0/m, z20.d, z0.d
	add	x9, x1, x12
	st1d	z20.d, p0, [x5]
	add	x8, x1, x9
	add	x12, x2, x12, lsl 3
	add	x7, x1, x8
	add	x14, x2, x14, lsl 3
	add	x6, x1, x7
	ld1rd	z11.d, p0/z, [x12]
	add	x5, x1, x6
	fmad	z11.d, p0/m, z20.d, z5.d
	add	x19, x1, x5
	ld1rd	z5.d, p0/z, [x14]
	add	x20, x1, x19
	add	x13, x2, x13, lsl 3
	add	x0, x1, x20
	add	x15, x2, x15, lsl 3
	add	x10, x2, x10, lsl 3
	add	x11, x2, x11, lsl 3
	ld1rd	z13.d, p0/z, [x10]
	fmla	z7.d, p0/m, z20.d, z5.d
	fmla	z17.d, p0/m, z20.d, z13.d
	ld1rd	z5.d, p0/z, [x11]
	ld1rd	z15.d, p0/z, [x15]
	fmad	z5.d, p0/m, z20.d, z18.d
	fmad	z15.d, p0/m, z20.d, z16.d
	add	x16, x2, x16, lsl 3
	ld1rd	z12.d, p0/z, [x13]
	ld1rd	z8.d, p0/z, [x16, 8]
	ld1rd	z0.d, p0/z, [x16]
	fmad	z12.d, p0/m, z20.d, z6.d
	fmad	z0.d, p0/m, z20.d, z19.d
	add	x18, x4, 64
	add	x0, x2, x0, lsl 3
	add	x1, x2, x20, lsl 3
	add	x5, x2, x5, lsl 3
	add	x6, x2, x6, lsl 3
	add	x7, x2, x7, lsl 3
	add	x8, x2, x8, lsl 3
	add	x9, x2, x9, lsl 3
	ld1rd	z26.d, p0/z, [x1]
	add	x2, x2, x19, lsl 3
	ld1rd	z28.d, p0/z, [x7]
	add	x18, x3, x18
	ld1rd	z25.d, p0/z, [x0]
	ld1d	z19.d, p0/z, [x18]
	ld1rd	z27.d, p0/z, [x2]
	ld1rd	z9.d, p0/z, [x5]
	ld1rd	z10.d, p0/z, [x6]
	add	x17, x4, 128
	fsub	z19.d, z19.d, z0.d
	ld1rd	z0.d, p0/z, [x9]
	fdiv	z19.d, p0/m, z19.d, z8.d
	fmad	z0.d, p0/m, z20.d, z4.d
	ld1rd	z8.d, p0/z, [x8]
	st1d	z19.d, p0, [x18]
	ld1rd	z29.d, p0/z, [x11, 8]
	ld1rd	z13.d, p0/z, [x6, 8]
	fmad	z29.d, p0/m, z19.d, z5.d
	ld1rd	z18.d, p0/z, [x10, 8]
	ld1rd	z5.d, p0/z, [x7, 8]
	fmad	z18.d, p0/m, z19.d, z17.d
	ld1rd	z16.d, p0/z, [x14, 8]
	ld1rd	z17.d, p0/z, [x15, 8]
	fmad	z16.d, p0/m, z19.d, z7.d
	fmad	z17.d, p0/m, z19.d, z15.d
	ld1rd	z7.d, p0/z, [x8, 8]
	ld1rd	z14.d, p0/z, [x5, 8]
	ld1rd	z15.d, p0/z, [x13, 8]
	fmad	z15.d, p0/m, z19.d, z12.d
	ld1rd	z12.d, p0/z, [x12, 8]
	fmad	z12.d, p0/m, z19.d, z11.d
	ld1rd	z11.d, p0/z, [x9, 8]
	ld1rd	z6.d, p0/z, [x2, 8]
	ld1rd	z4.d, p0/z, [x11, 16]
	fmad	z11.d, p0/m, z19.d, z0.d
	fmad	z28.d, p0/m, z20.d, z2.d
	add	x17, x3, x17
	movprfx	z2, z3
	fmla	z2.d, p0/m, z20.d, z8.d
	ld1d	z0.d, p0/z, [x17]
	ld1rd	z8.d, p0/z, [x0, 8]
	ld1rd	z3.d, p0/z, [x1, 8]
	add	x16, x4, 192
	fsub	z0.d, z0.d, z29.d
	fdiv	z0.d, p0/m, z0.d, z4.d
	movprfx	z4, z28
	fmla	z4.d, p0/m, z19.d, z5.d
	st1d	z0.d, p0, [x17]
	ld1rd	z5.d, p0/z, [x10, 16]
	fmad	z5.d, p0/m, z0.d, z18.d
	fmad	z7.d, p0/m, z19.d, z2.d
	add	x16, x3, x16
	ld1d	z2.d, p0/z, [x16]
	fsub	z2.d, z2.d, z5.d
	ld1rd	z5.d, p0/z, [x10, 24]
	ld1rd	z18.d, p0/z, [x14, 16]
	fdiv	z2.d, p0/m, z2.d, z5.d
	fmad	z18.d, p0/m, z0.d, z16.d
	ld1rd	z5.d, p0/z, [x15, 16]
	fmad	z9.d, p0/m, z20.d, z24.d
	fmad	z5.d, p0/m, z0.d, z17.d
	ld1rd	z30.d, p0/z, [x0, 16]
	ld1rd	z17.d, p0/z, [x13, 16]
	ld1rd	z16.d, p0/z, [x12, 16]
	fmad	z17.d, p0/m, z0.d, z15.d
	fmad	z16.d, p0/m, z0.d, z12.d
	ld1rd	z15.d, p0/z, [x9, 16]
	ld1rd	z12.d, p0/z, [x8, 16]
	fmad	z15.d, p0/m, z0.d, z11.d
	fmad	z12.d, p0/m, z0.d, z7.d
	ld1rd	z11.d, p0/z, [x7, 16]
	ld1rd	z7.d, p0/z, [x6, 16]
	fmad	z11.d, p0/m, z0.d, z4.d
	fmad	z10.d, p0/m, z20.d, z1.d
	ld1rd	z4.d, p0/z, [x2, 16]
	ld1rd	z1.d, p0/z, [x5, 16]
	fmla	z10.d, p0/m, z19.d, z13.d
	add	x21, x4, 256
	fmad	z7.d, p0/m, z0.d, z10.d
	ld1rd	z13.d, p0/z, [x1, 16]
	st1d	z2.d, p0, [x16]
	ld1rd	z29.d, p0/z, [x15, 24]
	fmad	z29.d, p0/m, z2.d, z5.d
	add	x21, x3, x21
	ld1rd	z5.d, p0/z, [x14, 24]
	fmad	z14.d, p0/m, z19.d, z9.d
	fmad	z5.d, p0/m, z2.d, z18.d
	fmla	z14.d, p0/m, z0.d, z1.d
	ld1rd	z10.d, p0/z, [x13, 24]
	ld1rd	z28.d, p0/z, [x12, 24]
	fmad	z10.d, p0/m, z2.d, z17.d
	fmad	z28.d, p0/m, z2.d, z16.d
	ld1rd	z17.d, p0/z, [x8, 24]
	ld1rd	z18.d, p0/z, [x9, 24]
	fmad	z17.d, p0/m, z2.d, z12.d
	fmad	z18.d, p0/m, z2.d, z15.d
	ld1rd	z12.d, p0/z, [x2, 24]
	ld1rd	z15.d, p0/z, [x7, 24]
	add	x20, x4, 320
	fmad	z15.d, p0/m, z2.d, z11.d
	ld1rd	z11.d, p0/z, [x6, 24]
	fmad	z11.d, p0/m, z2.d, z7.d
	ld1rd	z7.d, p0/z, [x5, 24]
	ld1rd	z16.d, p0/z, [x1, 24]
	ld1rd	z24.d, p0/z, [x15, 32]
	ld1d	z1.d, p0/z, [x21]
	fsub	z1.d, z1.d, z29.d
	ld1rd	z29.d, p0/z, [x0, 24]
	fdiv	z1.d, p0/m, z1.d, z24.d
	st1d	z1.d, p0, [x21]
	ld1rd	z9.d, p0/z, [x14, 32]
	fmad	z9.d, p0/m, z1.d, z5.d
	add	x20, x3, x20
	ld1d	z5.d, p0/z, [x20]
	fsub	z5.d, z5.d, z9.d
	ld1rd	z9.d, p0/z, [x14, 40]
	ld1rd	z24.d, p0/z, [x7, 32]
	fdiv	z5.d, p0/m, z5.d, z9.d
	fmad	z7.d, p0/m, z2.d, z14.d
	ld1rd	z9.d, p0/z, [x9, 32]
	ld1rd	z14.d, p0/z, [x13, 32]
	fmad	z9.d, p0/m, z1.d, z18.d
	fmad	z14.d, p0/m, z1.d, z10.d
	ld1rd	z18.d, p0/z, [x6, 32]
	ld1rd	z10.d, p0/z, [x12, 32]
	ld1rd	z31.d, p0/z, [x0, 32]
	fmad	z10.d, p0/m, z1.d, z28.d
	fmad	z18.d, p0/m, z1.d, z11.d
	ld1rd	z28.d, p0/z, [x8, 32]
	ld1rd	z11.d, p0/z, [x2, 32]
	fmad	z28.d, p0/m, z1.d, z17.d
	fmad	z27.d, p0/m, z20.d, z23.d
	ld1rd	z17.d, p0/z, [x5, 32]
	ld1rd	z23.d, p0/z, [x1, 32]
	fmla	z27.d, p0/m, z19.d, z6.d
	add	x19, x4, 384
	st1d	z5.d, p0, [x20]
	ld1rd	z6.d, p0/z, [x13, 40]
	fmad	z6.d, p0/m, z5.d, z14.d
	add	x19, x3, x19
	fmad	z17.d, p0/m, z1.d, z7.d
	movprfx	z7, z22
	fmla	z7.d, p0/m, z20.d, z26.d
	fmla	z7.d, p0/m, z19.d, z3.d
	ld1d	z3.d, p0/z, [x19]
	fsub	z3.d, z3.d, z6.d
	ld1rd	z6.d, p0/z, [x13, 48]
	fdiv	z3.d, p0/m, z3.d, z6.d
	ld1rd	z6.d, p0/z, [x6, 40]
	fmad	z24.d, p0/m, z1.d, z15.d
	fmla	z18.d, p0/m, z5.d, z6.d
	ld1rd	z6.d, p0/z, [x5, 40]
	ld1rd	z14.d, p0/z, [x8, 40]
	ld1rd	z22.d, p0/z, [x7, 40]
	fmla	z17.d, p0/m, z5.d, z6.d
	fmad	z22.d, p0/m, z5.d, z24.d
	movprfx	z6, z27
	fmla	z6.d, p0/m, z0.d, z4.d
	ld1rd	z24.d, p0/z, [x2, 40]
	fmla	z7.d, p0/m, z0.d, z13.d
	ld1rd	z26.d, p0/z, [x12, 40]
	fmad	z14.d, p0/m, z5.d, z28.d
	fmad	z26.d, p0/m, z5.d, z10.d
	ld1rd	z28.d, p0/z, [x0, 40]
	ld1rd	z10.d, p0/z, [x9, 40]
	fmla	z6.d, p0/m, z2.d, z12.d
	fmad	z10.d, p0/m, z5.d, z9.d
	add	x30, x4, 448
	ld1rd	z9.d, p0/z, [x1, 40]
	st1d	z3.d, p0, [x19]
	ld1rd	z12.d, p0/z, [x12, 48]
	fmad	z12.d, p0/m, z3.d, z26.d
	add	x30, x3, x30
	fmad	z16.d, p0/m, z2.d, z7.d
	ld1d	z4.d, p0/z, [x30]
	ld1rd	z7.d, p0/z, [x8, 48]
	fsub	z4.d, z4.d, z12.d
	ld1rd	z12.d, p0/z, [x12, 56]
	ld1rd	z15.d, p0/z, [x2, 48]
	fdiv	z4.d, p0/m, z4.d, z12.d
	ld1rd	z27.d, p0/z, [x0, 48]
	ld1rd	z13.d, p0/z, [x1, 48]
	ld1rd	z12.d, p0/z, [x6, 48]
	fmla	z14.d, p0/m, z3.d, z7.d
	fmla	z6.d, p0/m, z1.d, z11.d
	ld1rd	z7.d, p0/z, [x9, 48]
	ld1rd	z11.d, p0/z, [x5, 48]
	fmad	z7.d, p0/m, z3.d, z10.d
	fmad	z11.d, p0/m, z3.d, z17.d
	add	x18, x4, 512
	ld1rd	z17.d, p0/z, [x7, 48]
	st1d	z4.d, p0, [x30]
	ld1rd	z10.d, p0/z, [x9, 56]
	fmad	z10.d, p0/m, z4.d, z7.d
	fmla	z16.d, p0/m, z1.d, z23.d
	fmad	z12.d, p0/m, z3.d, z18.d
	fmad	z17.d, p0/m, z3.d, z22.d
	fmad	z9.d, p0/m, z5.d, z16.d
	add	x18, x3, x18
	ld1d	z7.d, p0/z, [x18]
	fsub	z7.d, z7.d, z10.d
	ld1rd	z10.d, p0/z, [x9, 64]
	fmad	z13.d, p0/m, z3.d, z9.d
	fdiv	z7.d, p0/m, z7.d, z10.d
	ld1rd	z18.d, p0/z, [x6, 56]
	ld1rd	z10.d, p0/z, [x8, 56]
	fmad	z18.d, p0/m, z4.d, z12.d
	fmad	z10.d, p0/m, z4.d, z14.d
	ld1rd	z12.d, p0/z, [x2, 56]
	ld1rd	z14.d, p0/z, [x7, 56]
	ld1rd	z26.d, p0/z, [x0, 56]
	fmad	z14.d, p0/m, z4.d, z17.d
	add	x17, x4, 576
	ld1rd	z17.d, p0/z, [x5, 56]
	fmad	z17.d, p0/m, z4.d, z11.d
	ld1rd	z11.d, p0/z, [x1, 56]
	st1d	z7.d, p0, [x18]
	ld1rd	z9.d, p0/z, [x8, 64]
	fmad	z9.d, p0/m, z7.d, z10.d
	add	x17, x3, x17
	fmla	z6.d, p0/m, z5.d, z24.d
	ld1d	z16.d, p0/z, [x17]
	fmla	z6.d, p0/m, z3.d, z15.d
	fsub	z16.d, z16.d, z9.d
	fmla	z6.d, p0/m, z4.d, z12.d
	ld1rd	z9.d, p0/z, [x8, 72]
	fmad	z11.d, p0/m, z4.d, z13.d
	fdiv	z16.d, p0/m, z16.d, z9.d
	ld1rd	z10.d, p0/z, [x7, 64]
	ld1rd	z13.d, p0/z, [x2, 64]
	fmad	z10.d, p0/m, z7.d, z14.d
	fmad	z13.d, p0/m, z7.d, z6.d
	ld1rd	z14.d, p0/z, [x6, 64]
	ld1rd	z9.d, p0/z, [x1, 64]
	fmad	z14.d, p0/m, z7.d, z18.d
	ld1rd	z24.d, p0/z, [x0, 64]
	ld1rd	z18.d, p0/z, [x5, 64]
	add	x16, x4, 640
	st1d	z16.d, p0, [x17]
	ld1rd	z6.d, p0/z, [x7, 72]
	fmad	z6.d, p0/m, z16.d, z10.d
	fmad	z18.d, p0/m, z7.d, z17.d
	fmad	z9.d, p0/m, z7.d, z11.d
	add	x16, x3, x16
	ld1d	z17.d, p0/z, [x16]
	fsub	z17.d, z17.d, z6.d
	ld1rd	z6.d, p0/z, [x7, 80]
	ld1rd	z23.d, p0/z, [x0, 72]
	fdiv	z17.d, p0/m, z17.d, z6.d
	ld1rd	z11.d, p0/z, [x1, 72]
	ld1rd	z10.d, p0/z, [x2, 72]
	ld1rd	z12.d, p0/z, [x5, 72]
	ld1rd	z6.d, p0/z, [x6, 72]
	fmad	z11.d, p0/m, z16.d, z9.d
	fmad	z6.d, p0/m, z16.d, z14.d
	add	x15, x4, 704
	st1d	z17.d, p0, [x16]
	ld1rd	z9.d, p0/z, [x6, 80]
	fmad	z9.d, p0/m, z17.d, z6.d
	fmad	z12.d, p0/m, z16.d, z18.d
	fmad	z10.d, p0/m, z16.d, z13.d
	add	x15, x3, x15
	ld1d	z6.d, p0/z, [x15]
	fsub	z6.d, z6.d, z9.d
	ld1rd	z9.d, p0/z, [x6, 88]
	ld1rd	z22.d, p0/z, [x0, 80]
	fdiv	z6.d, p0/m, z6.d, z9.d
	fmad	z25.d, p0/m, z20.d, z21.d
	ld1rd	z9.d, p0/z, [x5, 80]
	fmla	z25.d, p0/m, z19.d, z8.d
	fmad	z9.d, p0/m, z17.d, z12.d
	add	x14, x4, 768
	ld1rd	z12.d, p0/z, [x2, 80]
	fmad	z12.d, p0/m, z17.d, z10.d
	ld1rd	z10.d, p0/z, [x1, 80]
	st1d	z6.d, p0, [x15]
	ld1rd	z8.d, p0/z, [x5, 88]
	fmad	z8.d, p0/m, z6.d, z9.d
	fmad	z10.d, p0/m, z17.d, z11.d
	add	x14, x3, x14
	ld1d	z18.d, p0/z, [x14]
	fsub	z18.d, z18.d, z8.d
	ld1rd	z8.d, p0/z, [x5, 96]
	ld1rd	z11.d, p0/z, [x2, 88]
	fdiv	z18.d, p0/m, z18.d, z8.d
	ld1rd	z9.d, p0/z, [x1, 88]
	ld1rd	z8.d, p0/z, [x0, 88]
	fmad	z11.d, p0/m, z6.d, z12.d
	fmad	z9.d, p0/m, z6.d, z10.d
	add	x11, x4, 832
	st1d	z18.d, p0, [x14]
	ld1rd	z10.d, p0/z, [x2, 96]
	fmad	z10.d, p0/m, z18.d, z11.d
	add	x8, x3, x11
	ld1d	z19.d, p0/z, [x8]
	fsub	z19.d, z19.d, z10.d
	ld1rd	z10.d, p0/z, [x2, 104]
	ld1rd	z21.d, p0/z, [x0, 96]
	fdiv	z19.d, p0/m, z19.d, z10.d
	add	x10, x4, 896
	ld1rd	z10.d, p0/z, [x1, 96]
	fmad	z10.d, p0/m, z18.d, z9.d
	st1d	z19.d, p0, [x8]
	ld1rd	z9.d, p0/z, [x1, 104]
	fmad	z9.d, p0/m, z19.d, z10.d
	add	x7, x3, x10
	fmad	z0.d, p0/m, z30.d, z25.d
	add	x4, x4, 960
	fmad	z2.d, p0/m, z29.d, z0.d
	ld1rd	z25.d, p0/z, [x0, 104]
	fmad	z1.d, p0/m, z31.d, z2.d
	ld1d	z20.d, p0/z, [x7]
	fsub	z20.d, z20.d, z9.d
	ld1rd	z9.d, p0/z, [x1, 112]
	fdiv	z20.d, p0/m, z20.d, z9.d
	st1d	z20.d, p0, [x7]
	ldp	x19, x20, [sp, 16]
	ld1rd	z2.d, p0/z, [x0, 112]
	add	x3, x3, x4
	fmad	z5.d, p0/m, z28.d, z1.d
	ldr	x21, [sp, 32]
	ld1d	z0.d, p0/z, [x3]
	ld1rd	z1.d, p0/z, [x0, 120]
	fmad	z3.d, p0/m, z27.d, z5.d
	ldp	d10, d11, [sp, 64]
	fmad	z4.d, p0/m, z26.d, z3.d
	fmad	z7.d, p0/m, z24.d, z4.d
	fmad	z16.d, p0/m, z23.d, z7.d
	ldp	d12, d13, [sp, 80]
	fmad	z17.d, p0/m, z22.d, z16.d
	fmad	z6.d, p0/m, z8.d, z17.d
	fmad	z18.d, p0/m, z21.d, z6.d
	ldp	d8, d9, [sp, 48]
	fmad	z19.d, p0/m, z25.d, z18.d
	fmad	z20.d, p0/m, z2.d, z19.d
	fsub	z0.d, z0.d, z20.d
	ldp	d14, d15, [sp, 96]
	fdiv	z0.d, p0/m, z0.d, z1.d
	st1d	z0.d, p0, [x3]
	ldp	x29, x30, [sp], 112
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 21
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 78
	.cfi_restore 79
	.cfi_restore 76
	.cfi_restore 77
	.cfi_restore 74
	.cfi_restore 75
	.cfi_restore 72
	.cfi_restore 73
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L37:
	.cfi_restore_state
	mov	z21.d, #0
	mov	z22.d, z21.d
	mov	z23.d, z21.d
	mov	z24.d, z21.d
	mov	z1.d, z21.d
	mov	z2.d, z21.d
	mov	z3.d, z21.d
	mov	z4.d, z21.d
	mov	z5.d, z21.d
	mov	z6.d, z21.d
	mov	z7.d, z21.d
	mov	z16.d, z21.d
	mov	z17.d, z21.d
	mov	z18.d, z21.d
	mov	z19.d, z21.d
	mov	z20.d, z21.d
	b	.L35
	.cfi_endproc
.LFE4363:
	.size	solve16x8_panel_packedL_sve, .-solve16x8_panel_packedL_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4376:
	.cfi_startproc
	sub	sp, sp, #560
	.cfi_def_cfa_offset 560
	mov	x1, x0
	stp	x29, x30, [sp]
	.cfi_offset 29, -560
	.cfi_offset 30, -552
	mov	x29, sp
	stp	x27, x28, [sp, 80]
	.cfi_offset 27, -480
	.cfi_offset 28, -472
	ldr	x27, [x0]
	str	x0, [sp, 176]
	ldr	x0, [x0, 16]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -544
	.cfi_offset 20, -536
	ldp	w28, w20, [x1, 24]
	stp	x25, x26, [sp, 64]
	.cfi_offset 25, -496
	.cfi_offset 26, -488
	ldr	w25, [x1, 36]
	ldr	x19, [x0]
	mov	x0, x1
	ldr	x1, [x1, 8]
	str	x1, [sp, 184]
	ldr	w1, [x0, 32]
	ldr	w0, [x0, 40]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	str	w1, [sp, 148]
	str	w0, [sp, 216]
	.cfi_offset 21, -528
	.cfi_offset 22, -520
	.cfi_offset 23, -512
	.cfi_offset 24, -504
	cbz	x19, .L98
	bl	omp_get_num_threads
	mov	w21, w0
	bl	omp_get_thread_num
	ldr	x1, [sp, 176]
	ldr	w2, [x1, 44]
	sub	w2, w2, #1
	sdiv	w1, w2, w21
	msub	w2, w1, w21, w2
	cmp	w0, w2
	blt	.L96
.L104:
	madd	w0, w1, w0, w2
	add	w1, w1, w0
	cmp	w0, w1
	blt	.L97
.L101:
	bl	GOMP_barrier
.L98:
	ldr	w0, [sp, 216]
	cbz	w0, .L95
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 216]
.L95:
	sbfiz	x23, x28, 6, 32
	mov	x1, 64
	mov	x2, x23
	add	x0, sp, 296
	bl	posix_memalign
	cmp	w0, 0
	ldr	x1, [sp, 296]
	csel	x21, xzr, x1, ne
	bl	omp_get_num_threads
	mov	w19, w0
	bl	omp_get_thread_num
	mov	w3, w0
	add	w1, w20, 14
	adds	w2, w20, 7
	csel	w0, w1, w2, mi
	asr	w0, w0, 3
	sdiv	w1, w0, w19
	msub	w0, w1, w19, w0
	cmp	w3, w0
	blt	.L44
.L93:
	madd	w0, w1, w3, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L45
	sub	w2, w28, #16
	ldr	w5, [sp, 148]
	lsl	w1, w1, 3
	str	w1, [sp, 264]
	lsr	w2, w2, 4
	add	x1, x23, x21
	add	w2, w2, 1
	sxtw	x19, w5
	add	x3, x19, 1
	str	x1, [sp, 168]
	ubfiz	x1, x2, 4, 29
	lsl	w7, w0, 3
	str	x1, [sp, 192]
	lsl	w1, w2, 4
	str	w1, [sp, 268]
	lsl	x1, x3, 2
	str	x1, [sp, 128]
	sxtw	x1, w7
	str	x1, [sp, 160]
	lsl	x0, x19, 5
	ldr	x1, [sp, 184]
	lsl	x4, x3, 3
	sbfiz	x22, x5, 1, 32
	str	x0, [sp, 272]
	add	x0, x0, 32
	sub	w9, w20, w7
	add	x1, x1, w7, sxtw 3
	str	x1, [sp, 152]
	lsl	x1, x19, 7
	sbfiz	x15, x25, 3, 32
	sub	x2, x4, #8
	str	x0, [sp, 136]
	add	x0, x22, x19
	str	x1, [sp, 200]
	sxtw	x1, w25
	mov	w24, w9
	mov	x20, x15
	mov	x23, x0
	str	x1, [sp, 280]
	mov	x1, x2
	str	x4, [sp, 120]
	str	w7, [sp, 220]
	str	d8, [sp, 96]
	.cfi_offset 72, -464
.L48:
	cmp	w24, 8
	mov	w0, 8
	csel	w6, w24, w0, le
	cbz	x21, .L160
	cmp	w28, 0
	ble	.L49
	sub	w0, w6, #1
	mov	w2, 7
	add	x0, x0, 1
	sub	w2, w2, w6
	add	x2, x2, 1
	cmp	w24, 0
	lsl	x0, x0, 3
	mov	x3, 8
	csel	x0, x0, x3, gt
	mov	x25, x21
	ldr	x26, [sp, 152]
	lsl	x2, x2, 3
	sbfiz	x3, x6, 3, 32
	str	x0, [sp, 208]
	str	x27, [sp, 224]
	ldr	x27, [sp, 168]
	str	x23, [sp, 256]
	mov	x23, x0
	mov	x0, x19
	mov	x19, x25
	mov	x25, x0
	str	w28, [sp, 232]
	mov	x28, x1
	stp	x21, x22, [sp, 240]
	mov	x21, x3
	mov	x22, x2
.L86:
	mov	x1, x26
	mov	x2, x23
	mov	x0, x19
	cmp	w24, 0
	ble	.L51
	bl	memcpy
	cmp	w24, 7
	bgt	.L161
.L51:
	add	x0, x21, x19
	mov	x2, x22
	mov	w1, 0
	add	x19, x19, 64
	bl	memset
	add	x26, x26, x20
	cmp	x27, x19
	bne	.L86
	ldp	x21, x22, [sp, 240]
	mov	x1, x28
	ldr	x27, [sp, 224]
	mov	x19, x25
	ldr	x23, [sp, 256]
	ldr	w28, [sp, 232]
.L84:
	ldr	w0, [sp, 216]
	mov	w14, w0
	tbnz	x0, 0, .L162
.L52:
	sxtw	x8, w14
	sbfiz	x2, x14, 6, 32
	ldr	x0, [sp, 120]
	str	w24, [sp, 240]
	madd	x25, x8, x19, x19
	sub	w7, w28, w14
	madd	x3, x1, x8, x27
	add	w26, w14, 2
	ldr	x24, [sp, 272]
	add	x25, x25, x8
	movi	v17.4s, 0
	madd	x30, x0, x8, x27
	add	x2, x21, x2
	add	x0, x27, 8
	add	w14, w14, 1
	add	x5, sp, 304
	mov	x9, x3
	mov	x15, 0
	str	x0, [sp, 232]
	add	x0, x27, x25, lsl 3
	str	x0, [sp, 224]
	stp	x20, x1, [sp, 248]
.L62:
	stp	q17, q17, [x5]
	stp	q17, q17, [x5, 32]
	stp	q17, q17, [x5, 64]
	stp	q17, q17, [x5, 96]
	stp	q17, q17, [x5, 128]
	stp	q17, q17, [x5, 160]
	stp	q17, q17, [x5, 192]
	stp	q17, q17, [x5, 224]
	cmp	w7, 3
	ble	.L163
	movi	v16.2d, 0
	cmp	w8, 0
	ble	.L110
	mov	v18.16b, v16.16b
	mov	x1, x3
	mov	v19.16b, v16.16b
	mov	x0, x21
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
.L82:
	ldp	q4, q3, [x0]
	ldp	q2, q0, [x0, 32]
	add	x0, x0, 64
	ldr	d6, [x1, x19, lsl 3]
	ldr	d5, [x1, x22, lsl 3]
	ldr	d1, [x1, x23, lsl 3]
	fmla	v28.2d, v4.2d, v6.d[0]
	ld1r	{v7.2d}, [x1]
	fmla	v27.2d, v3.2d, v6.d[0]
	add	x1, x1, 8
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
	cmp	x2, x0
	bne	.L82
.L81:
	stp	q8, q31, [sp, 304]
	stp	q30, q29, [sp, 336]
	stp	q28, q27, [sp, 368]
	stp	q26, q25, [sp, 400]
	stp	q24, q23, [sp, 432]
	stp	q22, q21, [sp, 464]
	stp	q20, q19, [sp, 496]
	stp	q18, q16, [sp, 528]
.L83:
	ldr	d0, [x30, x15]
	ldp	q4, q3, [x2]
	ldp	q2, q1, [x2, 32]
	ldp	q8, q7, [sp, 304]
	ldp	q6, q5, [sp, 336]
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
	cmp	w7, 1
	beq	.L72
	ldp	x0, x20, [sp, 224]
	add	x17, x8, 1
	add	x18, x8, 2
	cmp	w7, 4
	add	x17, x21, x17, lsl 6
	mov	x1, x5
	add	x18, x21, x18, lsl 6
	mov	x10, x25
	mov	w4, 1
	mov	w12, 0
	add	x6, x0, x15
	mov	w0, 4
	csel	w11, w7, w0, le
	mov	x0, x2
	b	.L73
	.p2align 2,,3
.L76:
	add	x1, x1, 64
	add	x10, x10, x19
	cmp	w4, 2
	beq	.L108
	ldp	q1, q0, [x2]
	mov	w12, 2
	ldr	d5, [x27, x10, lsl 3]
	ldp	q3, q2, [x1, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	ldr	d4, [x20, x10, lsl 3]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldp	q7, q6, [x1, 96]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q1, q0, [x1, 64]
	ldp	q3, q2, [x2, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x1, 64]
	ldp	q1, q0, [x2, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x1, 96]
	ldp	q3, q2, [x2, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x1, 96]
.L74:
	add	x0, x0, 64
	ldr	x13, [sp, 120]
	add	x6, x6, x13
.L73:
	sxtw	x16, w12
	add	w12, w12, 1
	add	x13, x16, x8
	add	x16, x16, x10
	ldp	q1, q2, [x1, 64]
	lsl	x13, x13, 6
	ldr	d4, [x27, x16, lsl 3]
	add	x16, x21, x13
	ldp	q6, q5, [x1, 96]
	ldr	q0, [x21, x13]
	fmul	v0.2d, v0.2d, v4.d[0]
	fadd	v1.2d, v0.2d, v1.2d
	str	q1, [x1, 64]
	ldr	q3, [x16, 16]
	fmul	v3.2d, v3.2d, v4.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x1, 80]
	ldr	q2, [x16, 32]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	str	q2, [x1, 96]
	ldr	q0, [x16, 48]
	fmul	v0.2d, v0.2d, v4.d[0]
	fadd	v0.2d, v0.2d, v5.2d
	str	q0, [x1, 112]
	cmp	w4, w12
	ble	.L75
	add	x12, x10, 1
	ldr	q4, [x17]
	ldr	d6, [x27, x12, lsl 3]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v1.2d
	mov	v1.16b, v4.16b
	str	q4, [x1, 64]
	ldr	q5, [x17, 16]
	fmul	v5.2d, v5.2d, v6.d[0]
	fadd	v5.2d, v5.2d, v3.2d
	str	q5, [x1, 80]
	ldr	q3, [x17, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x1, 96]
	ldr	q2, [x17, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v0.2d, v2.2d, v0.2d
	str	q0, [x1, 112]
	cmp	w4, 3
	bne	.L75
	add	x12, x10, 2
	ldr	q1, [x18]
	ldr	d6, [x27, x12, lsl 3]
	fmul	v1.2d, v1.2d, v6.d[0]
	fadd	v1.2d, v1.2d, v4.2d
	str	q1, [x1, 64]
	ldr	q2, [x18, 16]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x1, 80]
	ldr	q2, [x18, 32]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v3.2d
	str	q2, [x1, 96]
	ldr	q2, [x18, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v0.2d, v2.2d, v0.2d
	str	q0, [x1, 112]
.L75:
	ldr	d0, [x6, 8]
	ldp	q4, q3, [x0, 64]
	add	w4, w4, 1
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
	cmp	w11, w4
	bne	.L76
.L72:
	ldr	x0, [sp, 128]
	add	x8, x8, 4
	sub	w7, w7, #4
	add	x2, x2, 256
	add	x25, x25, x0
	add	x3, x3, x24
	ldr	x0, [sp, 136]
	add	w26, w26, 4
	add	x9, x9, x24
	add	w14, w14, 4
	add	x15, x15, x0
	cmp	w28, w8
	bgt	.L62
	ldp	x20, x1, [sp, 248]
	ldr	w24, [sp, 240]
.L63:
	cmp	w24, 0
	ble	.L49
	ldr	x3, [sp, 152]
	mov	x0, x19
	ldr	x26, [sp, 168]
	mov	x19, x21
	stp	x27, x21, [sp, 224]
	mov	x25, x0
	mov	x27, x1
	ldr	x21, [sp, 208]
.L59:
	mov	x1, x19
	mov	x0, x3
	mov	x2, x21
	add	x19, x19, 64
	bl	memcpy
	add	x3, x0, x20
	cmp	x26, x19
	bne	.L59
	mov	x1, x27
	mov	x19, x25
	ldp	x27, x21, [sp, 224]
.L49:
	sub	w24, w24, #8
	ldr	x2, [sp, 160]
	ldr	w0, [sp, 220]
	add	x2, x2, 8
	str	x2, [sp, 160]
	ldr	x2, [sp, 152]
	add	w0, w0, 8
	str	w0, [sp, 220]
	add	x2, x2, 64
	str	x2, [sp, 152]
	ldr	w2, [sp, 264]
	cmp	w2, w0
	bgt	.L48
	ldr	d8, [sp, 96]
	.cfi_restore 72
.L45:
	bl	GOMP_barrier
	ldp	x29, x30, [sp]
	mov	x0, x21
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 560
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
.L163:
	.cfi_def_cfa_offset 560
	.cfi_offset 19, -544
	.cfi_offset 20, -536
	.cfi_offset 21, -528
	.cfi_offset 22, -520
	.cfi_offset 23, -512
	.cfi_offset 24, -504
	.cfi_offset 25, -496
	.cfi_offset 26, -488
	.cfi_offset 27, -480
	.cfi_offset 28, -472
	.cfi_offset 29, -560
	.cfi_offset 30, -552
	.cfi_offset 72, -464
	cmp	w8, 0
	ble	.L83
	movi	v1.2d, 0
	sxtw	x6, w14
	sxtw	x10, w26
	sub	x6, x6, x8
	sub	x10, x10, x8
	mov	x0, x21
	mov	x4, x9
	mov	w1, 0
	mul	x6, x6, x19
	mov	w11, 0
	mul	x10, x10, x19
	mov	w12, 0
	mov	v20.16b, v1.16b
	mov	w13, 0
	mov	v4.16b, v1.16b
	mov	w18, 0
	mov	v5.16b, v1.16b
	mov	w17, 0
	mov	v26.16b, v1.16b
	mov	w16, 0
	mov	v25.16b, v1.16b
	mov	w20, 0
	mov	v24.16b, v1.16b
	mov	v27.16b, v1.16b
	mov	v19.16b, v1.16b
	mov	v18.16b, v1.16b
	mov	v8.16b, v1.16b
	mov	v3.16b, v1.16b
	.p2align 3,,7
.L79:
	ldp	q16, q7, [x0]
	ldp	q6, q22, [x0, 32]
	ld1r	{v0.2d}, [x4]
	fmul	v2.2d, v16.2d, v0.2d
	fmul	v28.2d, v7.2d, v0.2d
	fmul	v23.2d, v6.2d, v0.2d
	fmul	v0.2d, v22.2d, v0.2d
	fadd	v3.2d, v2.2d, v3.2d
	fadd	v28.2d, v28.2d, v8.2d
	fadd	v23.2d, v23.2d, v18.2d
	fadd	v2.2d, v0.2d, v19.2d
	cmp	w7, 1
	ble	.L77
	ldr	d0, [x4, x6, lsl 3]
	mov	w1, 1
	mov	w11, w1
	mov	w12, w1
	mov	w13, w1
	fmul	v18.2d, v16.2d, v0.d[0]
	fmul	v19.2d, v7.2d, v0.d[0]
	fmul	v21.2d, v6.2d, v0.d[0]
	fmul	v0.2d, v22.2d, v0.d[0]
	fadd	v5.2d, v18.2d, v5.2d
	fadd	v4.2d, v19.2d, v4.2d
	fadd	v20.2d, v21.2d, v20.2d
	fadd	v1.2d, v0.2d, v1.2d
	cmp	w7, 3
	bne	.L77
	ldr	d18, [x4, x10, lsl 3]
	mov	w18, w1
	mov	w17, w1
	mov	w16, w1
	mov	w20, w1
	fmul	v16.2d, v16.2d, v18.d[0]
	fmul	v7.2d, v7.2d, v18.d[0]
	fmul	v6.2d, v6.2d, v18.d[0]
	fmul	v0.2d, v22.2d, v18.d[0]
	fadd	v27.2d, v16.2d, v27.2d
	fadd	v24.2d, v7.2d, v24.2d
	fadd	v25.2d, v6.2d, v25.2d
	fadd	v26.2d, v0.2d, v26.2d
.L77:
	add	x0, x0, 64
	add	x4, x4, 8
	mov	v8.16b, v28.16b
	mov	v18.16b, v23.16b
	mov	v19.16b, v2.16b
	cmp	x2, x0
	bne	.L79
	stp	q3, q28, [sp, 304]
	stp	q23, q2, [sp, 336]
	cbz	w1, .L64
	str	q1, [sp, 416]
.L64:
	cbz	w11, .L65
	str	q20, [sp, 400]
.L65:
	cbz	w12, .L66
	str	q4, [sp, 384]
.L66:
	cbz	w13, .L67
	str	q5, [sp, 368]
.L67:
	cbz	w18, .L68
	str	q26, [sp, 480]
.L68:
	cbz	w17, .L69
	str	q25, [sp, 464]
.L69:
	cbz	w16, .L70
	str	q24, [sp, 448]
.L70:
	cbz	w20, .L83
	str	q27, [sp, 432]
	b	.L83
.L110:
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
	b	.L81
.L162:
	cmp	w28, 15
	ble	.L106
	mov	x0, x19
	mov	x25, 0
	mov	x19, x21
	mov	x26, x0
	mov	x21, x27
	stp	x20, x1, [sp, 224]
	mov	x20, x25
	b	.L55
.L152:
	bl	solve16x8_panel_sve
	add	x20, x20, 16
	ldr	x0, [sp, 200]
	add	x21, x21, x0
	ldr	x0, [sp, 192]
	cmp	x0, x20
	beq	.L164
.L55:
	ldr	x0, [sp, 176]
	cmp	w20, 0
	ldr	w1, [sp, 148]
	mov	x3, x19
	mov	x2, x21
	ldr	x4, [x0, 16]
	mov	w0, w20
	ldr	x4, [x4]
	ccmp	x4, 0, 4, ne
	beq	.L152
	lsr	x7, x20, 4
	ldr	w1, [sp, 148]
	sub	x8, x7, #1
	add	x20, x20, 16
	mul	x7, x8, x7
	add	x4, x4, x7, lsl 10
	bl	solve16x8_panel_packedL_sve
	ldr	x0, [sp, 200]
	add	x21, x21, x0
	ldr	x0, [sp, 192]
	cmp	x0, x20
	bne	.L55
.L164:
	ldr	w0, [sp, 268]
	mov	x21, x19
	ldp	x20, x1, [sp, 224]
	mov	x19, x26
	mov	w14, w0
	cmp	w28, w0
	bgt	.L52
	b	.L63
	.p2align 2,,3
.L160:
	cmp	w24, 0
	ble	.L49
	cmp	w28, 0
	ble	.L49
	ldp	x7, x8, [sp, 152]
	lsl	x9, x19, 3
	ldr	x30, [sp, 120]
	add	x6, x8, w6, uxtw
.L90:
	ldr	d0, [x7]
	ldr	d1, [x27]
	fdiv	d0, d0, d1
	str	d0, [x7]
	cmp	w28, 1
	beq	.L89
	ldr	x0, [sp, 280]
	add	x4, x27, x30
	ldr	x3, [sp, 184]
	add	x0, x0, x8
	add	x5, x27, x9
	mov	w2, 1
	add	x0, x3, x0, lsl 3
	.p2align 3,,7
.L92:
	movi	d1, #0
	mov	x10, x7
	mov	x3, 0
	.p2align 3,,7
.L91:
	ldr	d2, [x5, x3, lsl 3]
	add	x3, x3, 1
	ldr	d0, [x10]
	add	x10, x10, x20
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w2, w3
	bgt	.L91
	ldr	d0, [x0]
	add	w2, w2, 1
	ldr	d2, [x4]
	add	x5, x5, x1
	add	x4, x4, x30
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x0]
	add	x0, x0, x20
	cmp	w28, w2
	bne	.L92
.L89:
	add	x8, x8, 1
	add	x7, x7, 8
	cmp	x6, x8
	bne	.L90
	b	.L49
.L97:
	.cfi_restore 72
	add	w0, w0, 1
	ldr	w5, [sp, 148]
	add	w1, w1, 1
	str	w25, [sp, 120]
	lsl	w2, w0, 4
	sxtw	x4, w0
	lsl	w9, w1, 4
	sbfiz	x26, x5, 7, 32
	sbfiz	x30, x5, 4, 32
	smull	x24, w2, w5
	mov	x3, x24
	add	x24, x27, x24, lsl 3
.L100:
	sub	x0, x4, #1
	mul	x0, x0, x4
	lsl	x0, x0, 10
	cmp	w2, 0
	ble	.L103
	add	w23, w2, 1
	add	w22, w2, 2
	add	w21, w2, 3
	add	w18, w2, 4
	add	w17, w2, 5
	add	w16, w2, 6
	add	w15, w2, 7
	add	w14, w2, 8
	add	w13, w2, 9
	add	w12, w2, 10
	add	w11, w2, 11
	add	w10, w2, 12
	add	w8, w2, 13
	add	w7, w2, 14
	add	w6, w2, 15
	smull	x23, w23, w5
	smull	x22, w22, w5
	add	x1, x19, x4, lsl 11
	smull	x21, w21, w5
	add	x25, x1, x0
	smull	x18, w18, w5
	sub	x23, x23, x3
	smull	x17, w17, w5
	sub	x22, x22, x3
	smull	x16, w16, w5
	sub	x21, x21, x3
	smull	x15, w15, w5
	sub	x18, x18, x3
	smull	x14, w14, w5
	sub	x17, x17, x3
	smull	x13, w13, w5
	sub	x16, x16, x3
	smull	x12, w12, w5
	sub	x15, x15, x3
	smull	x11, w11, w5
	sub	x14, x14, x3
	smull	x10, w10, w5
	sub	x13, x13, x3
	smull	x8, w8, w5
	sub	x12, x12, x3
	smull	x7, w7, w5
	sub	x11, x11, x3
	smull	x6, w6, w5
	sub	x10, x10, x3
	sub	x8, x8, x3
	sub	x7, x7, x3
	sub	x6, x6, x3
	add	x0, x19, x0
	mov	x1, x24
.L102:
	ldr	d0, [x1]
	add	x0, x0, 128
	str	d0, [x0, -128]
	ldr	d0, [x1, x23, lsl 3]
	str	d0, [x0, -120]
	ldr	d0, [x1, x22, lsl 3]
	str	d0, [x0, -112]
	ldr	d0, [x1, x21, lsl 3]
	str	d0, [x0, -104]
	ldr	d0, [x1, x18, lsl 3]
	str	d0, [x0, -96]
	ldr	d0, [x1, x17, lsl 3]
	str	d0, [x0, -88]
	ldr	d0, [x1, x16, lsl 3]
	str	d0, [x0, -80]
	ldr	d0, [x1, x15, lsl 3]
	str	d0, [x0, -72]
	ldr	d0, [x1, x14, lsl 3]
	str	d0, [x0, -64]
	ldr	d0, [x1, x13, lsl 3]
	str	d0, [x0, -56]
	ldr	d0, [x1, x12, lsl 3]
	str	d0, [x0, -48]
	ldr	d0, [x1, x11, lsl 3]
	str	d0, [x0, -40]
	ldr	d0, [x1, x10, lsl 3]
	str	d0, [x0, -32]
	ldr	d0, [x1, x8, lsl 3]
	str	d0, [x0, -24]
	ldr	d0, [x1, x7, lsl 3]
	str	d0, [x0, -16]
	ldr	d0, [x1, x6, lsl 3]
	add	x1, x1, 8
	str	d0, [x0, -8]
	cmp	x25, x0
	bne	.L102
.L103:
	add	w2, w2, 16
	add	x4, x4, 1
	add	x24, x24, x26
	add	x3, x3, x30
	cmp	w2, w9
	bne	.L100
	ldr	w25, [sp, 120]
	b	.L101
.L44:
	add	w1, w1, 1
	mov	w0, 0
	b	.L93
.L96:
	add	w1, w1, 1
	mov	w2, 0
	b	.L104
.L161:
	.cfi_offset 72, -464
	mov	x1, x28
	mov	x0, x25
	ldr	x27, [sp, 224]
	mov	x25, x19
	ldp	x21, x22, [sp, 240]
	mov	x19, x1
	ldr	x23, [sp, 256]
	str	x0, [sp, 224]
	ldr	w28, [sp, 232]
	b	.L85
	.p2align 2,,3
.L165:
	ldr	x2, [sp, 208]
	mov	x1, x26
	mov	x0, x25
	bl	memcpy
.L85:
	ldr	x0, [sp, 168]
	add	x25, x25, 64
	add	x26, x26, x20
	cmp	x0, x25
	bne	.L165
	mov	x1, x19
	ldr	x19, [sp, 224]
	b	.L84
.L108:
	mov	w12, 0
	b	.L74
	.p2align 2,,3
.L106:
	mov	w14, 0
	b	.L52
	.cfi_endproc
.LFE4376:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
	.type	solve8x16_panel_sve, %function
solve8x16_panel_sve:
.LFB4364:
	.cfi_startproc
	stp	d8, d9, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 72, -32
	.cfi_offset 73, -24
	sxtw	x5, w1
	stp	d10, d11, [sp, 16]
	.cfi_offset 74, -16
	.cfi_offset 75, -8
	cbz	w0, .L169
	mov	w11, 24
	mov	w10, 32
	mov	w9, 40
	mov	w8, 48
	mov	w7, 56
	smaddl	x11, w1, w11, x2
	smaddl	x10, w1, w10, x2
	add	x12, x2, w1, sxtw 3
	smaddl	x9, w1, w9, x2
	sxtw	x13, w0
	smaddl	x8, w1, w8, x2
	sbfiz	x6, x0, 3, 32
	smaddl	x7, w1, w7, x2
	add	x1, x2, w1, sxtw 4
	mov	x0, 0
	mov	z2.d, #0
	ptrue	p0.b, all
	mov	z23.d, z2.d
	mov	z24.d, z2.d
	mov	z3.d, z2.d
	mov	z27.d, z2.d
	mov	z4.d, z2.d
	mov	z28.d, z2.d
	mov	z21.d, z2.d
	mov	z29.d, z2.d
	mov	z22.d, z2.d
	mov	z30.d, z2.d
	mov	z25.d, z2.d
	mov	z31.d, z2.d
	mov	z26.d, z2.d
	mov	z8.d, z2.d
	mov	z9.d, z2.d
	ptrue	p1.d, all
	.p2align 3,,7
.L168:
	add	x14, x2, x0
	ld1d	z1.d, p0/z, [x3, x0, lsl 3]
#APP
// 588 "/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f478c9adbe2b/T24-smallbroadcast/source/trsm.c" 1
	ld1rd z20.d, p1/z, [x14]
// 0 "" 2
#NO_APP
	add	x14, x12, x0
	ld1d	z0.d, p0/z, [x4, x0, lsl 3]
#APP
// 596 "/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f478c9adbe2b/T24-smallbroadcast/source/trsm.c" 1
	ld1rd z19.d, p1/z, [x14]
// 0 "" 2
#NO_APP
	add	x14, x1, x0
	fmla	z9.d, p0/m, z1.d, z20.d
#APP
// 604 "/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f478c9adbe2b/T24-smallbroadcast/source/trsm.c" 1
	ld1rd z18.d, p1/z, [x14]
// 0 "" 2
#NO_APP
	add	x14, x11, x0
	fmla	z8.d, p0/m, z0.d, z20.d
#APP
// 612 "/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f478c9adbe2b/T24-smallbroadcast/source/trsm.c" 1
	ld1rd z17.d, p1/z, [x14]
// 0 "" 2
#NO_APP
	add	x14, x10, x0
	fmla	z26.d, p0/m, z1.d, z19.d
#APP
// 620 "/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f478c9adbe2b/T24-smallbroadcast/source/trsm.c" 1
	ld1rd z16.d, p1/z, [x14]
// 0 "" 2
#NO_APP
	add	x14, x9, x0
	fmla	z31.d, p0/m, z0.d, z19.d
#APP
// 628 "/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f478c9adbe2b/T24-smallbroadcast/source/trsm.c" 1
	ld1rd z7.d, p1/z, [x14]
// 0 "" 2
#NO_APP
	add	x14, x8, x0
	fmla	z25.d, p0/m, z1.d, z18.d
#APP
// 636 "/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f478c9adbe2b/T24-smallbroadcast/source/trsm.c" 1
	ld1rd z6.d, p1/z, [x14]
// 0 "" 2
#NO_APP
	add	x14, x7, x0
	add	x0, x0, 8
#APP
// 644 "/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f478c9adbe2b/T24-smallbroadcast/source/trsm.c" 1
	ld1rd z5.d, p1/z, [x14]
// 0 "" 2
#NO_APP
	fmla	z30.d, p0/m, z0.d, z18.d
	fmla	z22.d, p0/m, z1.d, z17.d
	fmla	z29.d, p0/m, z0.d, z17.d
	fmla	z21.d, p0/m, z1.d, z16.d
	fmla	z28.d, p0/m, z0.d, z16.d
	fmla	z4.d, p0/m, z1.d, z7.d
	fmla	z27.d, p0/m, z0.d, z7.d
	fmla	z3.d, p0/m, z1.d, z6.d
	fmla	z24.d, p0/m, z0.d, z6.d
	fmla	z23.d, p0/m, z1.d, z5.d
	fmla	z2.d, p0/m, z0.d, z5.d
	cmp	x6, x0
	bne	.L168
.L167:
	add	x11, x13, x5
	lsl	x1, x13, 6
	add	x10, x11, x5
	ldr	d0, [x2, x13, lsl 3]
	add	x9, x10, x5
	ptrue	p0.b, all
	add	x8, x9, x5
	add	x12, x3, x1
	add	x7, x8, x5
	ld1d	z5.d, p0/z, [x12]
	add	x6, x7, x5
	mov	z0.d, d0
	add	x0, x6, x5
	fsub	z5.d, z5.d, z9.d
	fdiv	z5.d, p0/m, z5.d, z0.d
	st1d	z5.d, p0, [x12]
	add	x5, x1, 64
	add	x12, x4, x1
	ld1d	z1.d, p0/z, [x12]
	fsub	z1.d, z1.d, z8.d
	fdiv	z1.d, p0/m, z1.d, z0.d
	st1d	z1.d, p0, [x12]
	ldr	d0, [x2, x11, lsl 3]
	add	x12, x3, x5
	ldr	d8, [x2, x10, lsl 3]
	ld1d	z7.d, p0/z, [x12]
	ldr	d19, [x2, x9, lsl 3]
	add	x11, x2, x11, lsl 3
	ldr	d10, [x2, x8, lsl 3]
	ld1rd	z9.d, p0/z, [x11, 8]
	ldr	d18, [x2, x7, lsl 3]
	mov	z0.d, d0
	ldr	d17, [x2, x6, lsl 3]
	fmla	z26.d, p0/m, z5.d, z0.d
	ldr	d16, [x2, x0, lsl 3]
	fmad	z0.d, p0/m, z1.d, z31.d
	fsub	z7.d, z7.d, z26.d
	fdiv	z7.d, p0/m, z7.d, z9.d
	st1d	z7.d, p0, [x12]
	add	x5, x4, x5
	add	x11, x1, 128
	ld1d	z6.d, p0/z, [x5]
	add	x10, x2, x10, lsl 3
	fsub	z6.d, z6.d, z0.d
	mov	z8.d, d8
	fdiv	z6.d, p0/m, z6.d, z9.d
	movprfx	z0, z25
	fmla	z0.d, p0/m, z5.d, z8.d
	st1d	z6.d, p0, [x5]
	ld1rd	z20.d, p0/z, [x10, 8]
	fmla	z0.d, p0/m, z7.d, z20.d
	add	x5, x2, x6, lsl 3
	add	x0, x2, x0, lsl 3
	add	x7, x2, x7, lsl 3
	add	x8, x2, x8, lsl 3
	add	x9, x2, x9, lsl 3
	mov	z19.d, d19
	add	x2, x3, x11
	ld1d	z9.d, p0/z, [x2]
	fsub	z9.d, z9.d, z0.d
	movprfx	z0, z22
	fmla	z0.d, p0/m, z5.d, z19.d
	fmad	z19.d, p0/m, z1.d, z29.d
	ld1rd	z26.d, p0/z, [x10, 16]
	ld1rd	z31.d, p0/z, [x9, 8]
	fdiv	z9.d, p0/m, z9.d, z26.d
	ld1rd	z25.d, p0/z, [x7, 8]
	movprfx	z22, z19
	fmla	z22.d, p0/m, z6.d, z31.d
	fmad	z8.d, p0/m, z1.d, z30.d
	ld1rd	z19.d, p0/z, [x0, 8]
	ld1rd	z30.d, p0/z, [x8, 8]
	fmla	z8.d, p0/m, z6.d, z20.d
	ld1rd	z20.d, p0/z, [x5, 8]
	st1d	z9.d, p0, [x2]
	add	x6, x4, x11
	fmla	z0.d, p0/m, z7.d, z31.d
	ld1d	z11.d, p0/z, [x6]
	add	x10, x1, 192
	fsub	z8.d, z11.d, z8.d
	mov	z10.d, d10
	fdiv	z8.d, p0/m, z8.d, z26.d
	fmla	z21.d, p0/m, z5.d, z10.d
	fmad	z10.d, p0/m, z1.d, z28.d
	fmla	z21.d, p0/m, z7.d, z30.d
	fmad	z30.d, p0/m, z6.d, z10.d
	st1d	z8.d, p0, [x6]
	ld1rd	z31.d, p0/z, [x9, 16]
	fmla	z0.d, p0/m, z9.d, z31.d
	add	x12, x3, x10
	fmad	z31.d, p0/m, z8.d, z22.d
	ld1rd	z29.d, p0/z, [x7, 16]
	ld1rd	z22.d, p0/z, [x8, 16]
	ld1rd	z26.d, p0/z, [x5, 16]
	movprfx	z10, z30
	fmla	z10.d, p0/m, z8.d, z22.d
	ld1rd	z28.d, p0/z, [x0, 16]
	add	x2, x1, 256
	ld1d	z30.d, p0/z, [x12]
	fsub	z30.d, z30.d, z0.d
	ld1rd	z0.d, p0/z, [x9, 24]
	fdiv	z30.d, p0/m, z30.d, z0.d
	st1d	z30.d, p0, [x12]
	add	x11, x3, x2
	add	x10, x4, x10
	fmla	z21.d, p0/m, z9.d, z22.d
	mov	z18.d, d18
	ld1d	z22.d, p0/z, [x10]
	fmla	z4.d, p0/m, z5.d, z18.d
	fsub	z22.d, z22.d, z31.d
	fmad	z18.d, p0/m, z1.d, z27.d
	fdiv	z22.d, p0/m, z22.d, z0.d
	st1d	z22.d, p0, [x10]
	ld1rd	z11.d, p0/z, [x8, 24]
	ld1d	z0.d, p0/z, [x11]
	ld1rd	z31.d, p0/z, [x5, 24]
	ld1rd	z27.d, p0/z, [x0, 24]
	add	x2, x4, x2
	fmla	z4.d, p0/m, z7.d, z25.d
	fmla	z21.d, p0/m, z30.d, z11.d
	fmad	z25.d, p0/m, z6.d, z18.d
	fmla	z10.d, p0/m, z22.d, z11.d
	add	x6, x1, 320
	ld1rd	z11.d, p0/z, [x8, 32]
	fsub	z21.d, z0.d, z21.d
	ld1rd	z0.d, p0/z, [x7, 24]
	fdiv	z21.d, p0/m, z21.d, z11.d
	st1d	z21.d, p0, [x11]
	ld1d	z18.d, p0/z, [x2]
	add	x9, x3, x6
	fmla	z4.d, p0/m, z9.d, z29.d
	fsub	z10.d, z18.d, z10.d
	fmad	z29.d, p0/m, z8.d, z25.d
	fdiv	z10.d, p0/m, z10.d, z11.d
	fmla	z4.d, p0/m, z30.d, z0.d
	fmad	z0.d, p0/m, z22.d, z29.d
	st1d	z10.d, p0, [x2]
	ld1d	z18.d, p0/z, [x9]
	ld1rd	z29.d, p0/z, [x7, 32]
	ld1rd	z25.d, p0/z, [x5, 32]
	fmla	z4.d, p0/m, z21.d, z29.d
	mov	z17.d, d17
	fmad	z29.d, p0/m, z10.d, z0.d
	fsub	z4.d, z18.d, z4.d
	movprfx	z0, z3
	fmla	z0.d, p0/m, z5.d, z17.d
	ld1rd	z18.d, p0/z, [x7, 40]
	fmad	z17.d, p0/m, z1.d, z24.d
	fdiv	z4.d, p0/m, z4.d, z18.d
	ld1rd	z24.d, p0/z, [x0, 32]
	st1d	z4.d, p0, [x9]
	add	x6, x4, x6
	add	x2, x1, 384
	ld1d	z3.d, p0/z, [x6]
	mov	z16.d, d16
	fsub	z3.d, z3.d, z29.d
	fmad	z5.d, p0/m, z16.d, z23.d
	fdiv	z3.d, p0/m, z3.d, z18.d
	st1d	z3.d, p0, [x6]
	add	x7, x3, x2
	ld1rd	z23.d, p0/z, [x5, 48]
	ld1d	z18.d, p0/z, [x7]
	fmla	z0.d, p0/m, z7.d, z20.d
	fmla	z17.d, p0/m, z6.d, z20.d
	fmla	z0.d, p0/m, z9.d, z26.d
	ld1rd	z20.d, p0/z, [x5, 40]
	fmla	z0.d, p0/m, z30.d, z31.d
	fmad	z7.d, p0/m, z19.d, z5.d
	fmla	z0.d, p0/m, z21.d, z25.d
	ld1rd	z5.d, p0/z, [x0, 40]
	fmla	z0.d, p0/m, z4.d, z20.d
	fmad	z9.d, p0/m, z28.d, z7.d
	add	x1, x1, 448
	fmad	z30.d, p0/m, z27.d, z9.d
	fsub	z18.d, z18.d, z0.d
	fmad	z21.d, p0/m, z24.d, z30.d
	fdiv	z18.d, p0/m, z18.d, z23.d
	fmad	z4.d, p0/m, z5.d, z21.d
	st1d	z18.d, p0, [x7]
	add	x2, x4, x2
	add	x3, x3, x1
	ld1d	z0.d, p0/z, [x2]
	fmad	z26.d, p0/m, z8.d, z17.d
	fmad	z1.d, p0/m, z16.d, z2.d
	fmad	z31.d, p0/m, z22.d, z26.d
	fmad	z6.d, p0/m, z19.d, z1.d
	fmad	z25.d, p0/m, z10.d, z31.d
	fmad	z8.d, p0/m, z28.d, z6.d
	fmad	z20.d, p0/m, z3.d, z25.d
	fmad	z22.d, p0/m, z27.d, z8.d
	fsub	z0.d, z0.d, z20.d
	fmad	z10.d, p0/m, z24.d, z22.d
	fdiv	z0.d, p0/m, z0.d, z23.d
	st1d	z0.d, p0, [x2]
	ld1rd	z11.d, p0/z, [x0, 48]
	ld1d	z7.d, p0/z, [x3]
	fmad	z18.d, p0/m, z11.d, z4.d
	ld1rd	z9.d, p0/z, [x0, 56]
	fsub	z4.d, z7.d, z18.d
	fdiv	z4.d, p0/m, z4.d, z9.d
	st1d	z4.d, p0, [x3]
	add	x4, x4, x1
	fmad	z3.d, p0/m, z5.d, z10.d
	ld1d	z1.d, p0/z, [x4]
	fmad	z0.d, p0/m, z11.d, z3.d
	ldp	d10, d11, [sp, 16]
	fsub	z0.d, z1.d, z0.d
	fdiv	z0.d, p0/m, z0.d, z9.d
	st1d	z0.d, p0, [x4]
	ldp	d8, d9, [sp], 32
	.cfi_remember_state
	.cfi_restore 73
	.cfi_restore 72
	.cfi_restore 74
	.cfi_restore 75
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L169:
	.cfi_restore_state
	mov	z2.d, #0
	mov	x13, 0
	mov	z23.d, z2.d
	mov	z24.d, z2.d
	mov	z3.d, z2.d
	mov	z27.d, z2.d
	mov	z4.d, z2.d
	mov	z28.d, z2.d
	mov	z21.d, z2.d
	mov	z29.d, z2.d
	mov	z22.d, z2.d
	mov	z30.d, z2.d
	mov	z25.d, z2.d
	mov	z31.d, z2.d
	mov	z26.d, z2.d
	mov	z8.d, z2.d
	mov	z9.d, z2.d
	b	.L167
	.cfi_endproc
.LFE4364:
	.size	solve8x16_panel_sve, .-solve8x16_panel_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_panel_wide8x16._omp_fn.0, %function
solve_panel_wide8x16._omp_fn.0:
.LFB4377:
	.cfi_startproc
	sub	sp, sp, #608
	.cfi_def_cfa_offset 608
	stp	x29, x30, [sp]
	.cfi_offset 29, -608
	.cfi_offset 30, -600
	mov	x29, sp
	stp	x27, x28, [sp, 80]
	.cfi_offset 27, -528
	.cfi_offset 28, -520
	ldp	x28, x2, [x0]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -592
	.cfi_offset 20, -584
	ldr	w20, [x0, 36]
	ldp	w19, w1, [x0, 28]
	str	x2, [sp, 176]
	ldr	w2, [x0, 24]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	str	w2, [sp, 208]
	.cfi_offset 21, -576
	.cfi_offset 22, -568
	.cfi_offset 23, -560
	.cfi_offset 24, -552
	.cfi_offset 25, -544
	.cfi_offset 26, -536
	ldp	w26, w27, [x0, 16]
	cbnz	w1, .L173
	mov	w22, 0
	tbz	w26, #31, .L174
.L230:
	bl	omp_get_num_threads
	mov	w21, w0
	bl	omp_get_thread_num
	mov	x23, 0
	sdiv	w1, w20, w21
	msub	w2, w1, w21, w20
	cmp	w0, w2
	blt	.L175
.L229:
	madd	w0, w1, w0, w2
	add	w2, w1, w0
	cmp	w0, w2
	bge	.L176
	ldr	w5, [sp, 208]
	sub	w3, w26, #8
	add	x2, x1, w0, sxtw
	and	w3, w3, -8
	lsl	w0, w0, 4
	add	w3, w3, 8
	sxtw	x6, w5
	cmp	w26, 7
	add	x4, x6, 1
	sub	w27, w27, w0
	sxtw	x15, w0
	mov	w0, 8
	lsl	x1, x4, 5
	csel	w0, w3, w0, gt
	str	x1, [sp, 152]
	sub	x1, x1, #32
	sbfiz	x7, x5, 1, 32
	sbfiz	x5, x26, 6, 32
	str	w0, [sp, 244]
	lsl	x0, x4, 2
	str	x1, [sp, 256]
	lsl	x1, x6, 6
	str	x0, [sp, 144]
	lsl	x0, x4, 3
	str	x1, [sp, 224]
	add	x1, x23, x5
	sbfiz	x12, x19, 3, 32
	str	x0, [sp, 136]
	mov	x0, x6
	str	x1, [sp, 192]
	sxtw	x1, w26
	mov	w20, w22
	add	x21, x7, x6
	mov	w17, w26
	mov	x22, x28
	mov	x25, x12
	mov	x3, x15
	mov	w6, w27
	str	x1, [sp, 232]
	sxtw	x1, w19
	mov	x19, x0
	lsl	x2, x2, 4
	str	x23, [sp, 128]
	str	x5, [sp, 216]
	str	x7, [sp, 248]
	str	x1, [sp, 264]
	str	x2, [sp, 272]
	str	d8, [sp, 96]
	.cfi_offset 72, -512
.L179:
	ldr	x0, [sp, 128]
	cmp	w6, 16
	mov	w24, 16
	csel	w24, w6, w24, le
	cbz	x0, .L292
	adds	w1, w24, 7
	add	w0, w24, 14
	csel	w0, w0, w1, mi
	cmp	w6, 15
	cset	w23, gt
	asr	w0, w0, 3
	str	w0, [sp, 240]
	and	w23, w20, w23
	cmp	w6, 0
	ble	.L293
	ldr	x1, [sp, 128]
	str	x21, [sp, 200]
	ldr	x28, [sp, 192]
	mov	x21, x1
	str	w23, [sp, 280]
	mov	x23, x3
	mov	x27, x28
	str	wzr, [sp, 120]
	str	w17, [sp, 160]
	str	x22, [sp, 168]
	str	w24, [sp, 184]
	str	w20, [sp, 212]
	str	w6, [sp, 284]
	stp	x3, x19, [sp, 288]
.L219:
	mov	w0, 8
	cmp	w24, 8
	csel	w19, w24, w0, le
	ldr	w0, [sp, 160]
	cmp	w0, 0
	ble	.L216
	sub	w22, w19, #1
	mov	w0, 7
	add	x22, x22, 1
	sub	w26, w0, w19
	cmp	w24, 0
	mov	x0, 8
	lsl	x22, x22, 3
	add	x26, x26, 1
	csel	x22, x22, x0, gt
	sbfiz	x19, x19, 3, 32
	ldr	x0, [sp, 176]
	lsl	x26, x26, 3
	mov	x20, x21
	add	x28, x0, x23, lsl 3
.L222:
	mov	x1, x28
	mov	x2, x22
	mov	x0, x20
	cmp	w24, 0
	ble	.L218
	bl	memcpy
	cmp	w24, 7
	bgt	.L221
.L218:
	add	x0, x20, x19
	mov	x2, x26
	mov	w1, 0
	add	x20, x20, 64
	bl	memset
	add	x28, x28, x25
	cmp	x20, x27
	bne	.L222
.L216:
	ldr	w0, [sp, 120]
	mov	w3, 2
	sub	w24, w24, #8
	add	x23, x23, 8
	cmp	w0, 0
	ldr	x0, [sp, 216]
	csinc	w3, w3, wzr, ne
	add	x27, x27, x0
	add	x21, x21, x0
	mov	w0, 1
	str	w0, [sp, 120]
	ldr	w0, [sp, 240]
	cmp	w0, w3
	bgt	.L219
	ldr	w23, [sp, 280]
	ldr	x22, [sp, 168]
	ldr	x21, [sp, 200]
	ldp	x3, x19, [sp, 288]
	ldr	w17, [sp, 160]
	ldr	w24, [sp, 184]
	ldr	w20, [sp, 212]
	ldr	w6, [sp, 284]
	tbnz	x23, 0, .L294
	mov	w23, w20
.L291:
	mov	w26, 0
.L183:
	mov	w7, w24
	cmp	w6, 15
	ldr	x24, [sp, 192]
	cset	w0, le
	and	w0, w23, w0
	mov	w23, w17
	mov	x9, x24
	str	w0, [sp, 280]
	ldr	x24, [sp, 256]
	str	xzr, [sp, 184]
	ldr	x0, [sp, 128]
	str	x0, [sp, 120]
	str	x3, [sp, 200]
	str	wzr, [sp, 212]
	str	w20, [sp, 284]
	str	w6, [sp, 288]
	str	x3, [sp, 296]
.L192:
	mov	w0, 8
	cmp	w7, 8
	csel	w1, w7, w0, le
	ldr	w0, [sp, 280]
	cbnz	w0, .L295
.L185:
	ldr	x0, [sp, 136]
	mov	w27, w26
	sub	w5, w23, w26
	sub	x13, x0, #8
	cmp	w23, w26
	ble	.L296
.L187:
	ldr	x0, [sp, 184]
	sxtw	x8, w27
	mov	w6, 64
	add	w16, w27, 2
	add	x2, x0, x8
	add	w10, w27, 1
	ldr	x0, [sp, 120]
	madd	x14, x8, x19, x19
	madd	x13, x13, x8, x22
	add	x3, sp, 352
	add	x14, x14, x8
	neg	x17, x19
	smaddl	x6, w27, w6, x0
	mov	x15, x13
	ldr	x0, [sp, 128]
	add	x12, x22, x14, lsl 3
	ldr	x20, [sp, 248]
	str	w7, [sp, 304]
	movi	v17.4s, 0
	add	x2, x0, x2, lsl 6
	add	x0, x22, 8
	str	x0, [sp, 160]
	str	w1, [sp, 312]
	str	w26, [sp, 316]
	stp	x9, x25, [sp, 320]
.L195:
	stp	q17, q17, [x3]
	stp	q17, q17, [x3, 32]
	stp	q17, q17, [x3, 64]
	stp	q17, q17, [x3, 96]
	stp	q17, q17, [x3, 128]
	stp	q17, q17, [x3, 160]
	stp	q17, q17, [x3, 192]
	stp	q17, q17, [x3, 224]
	cmp	w5, 3
	ble	.L297
	movi	v16.2d, 0
	cmp	w8, 0
	ble	.L237
	ldr	x0, [sp, 120]
	mov	x1, x15
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
	.p2align 3,,7
.L214:
	ldp	q4, q3, [x0]
	ldp	q2, q0, [x0, 32]
	add	x0, x0, 64
	ldr	d6, [x1, x19, lsl 3]
	ldr	d5, [x1, x20, lsl 3]
	ldr	d1, [x1, x21, lsl 3]
	fmla	v28.2d, v4.2d, v6.d[0]
	ld1r	{v7.2d}, [x1]
	fmla	v27.2d, v3.2d, v6.d[0]
	add	x1, x1, 8
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
	cmp	x0, x6
	bne	.L214
.L213:
	stp	q8, q31, [sp, 352]
	stp	q30, q29, [sp, 384]
	stp	q28, q27, [sp, 416]
	stp	q26, q25, [sp, 448]
	stp	q24, q23, [sp, 480]
	stp	q22, q21, [sp, 512]
	stp	q20, q19, [sp, 544]
	stp	q18, q16, [sp, 576]
.L215:
	ldr	d0, [x12, x17, lsl 3]
	ldp	q4, q3, [x2]
	ldp	q2, q1, [x2, 32]
	ldp	q8, q7, [sp, 352]
	ldp	q6, q5, [sp, 384]
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
	cmp	w5, 1
	beq	.L204
	ldr	x0, [sp, 184]
	mov	w1, 4
	ldr	x4, [sp, 128]
	add	x30, x0, x8
	add	x0, x30, 2
	add	x27, x30, 1
	cmp	w5, 4
	mov	x7, x12
	add	x28, x4, x0, lsl 6
	csel	w11, w5, w1, le
	add	x27, x4, x27, lsl 6
	mov	x1, x3
	mov	x9, x14
	mov	x0, x2
	mov	w18, 0
	mov	w4, 1
	str	x30, [sp, 168]
	b	.L205
	.p2align 2,,3
.L208:
	add	x1, x1, 64
	add	x9, x9, x19
	cmp	w4, 2
	beq	.L235
	ldp	q1, q0, [x2]
	mov	w18, 2
	ldr	d5, [x22, x9, lsl 3]
	ldp	q3, q2, [x1, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldr	x25, [sp, 160]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	ldr	d4, [x25, x9, lsl 3]
	ldp	q7, q6, [x1, 96]
	stp	q1, q0, [x1, 64]
	ldp	q3, q2, [x2, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x1, 64]
	ldp	q1, q0, [x2, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x1, 96]
	ldp	q3, q2, [x2, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x1, 96]
.L206:
	add	x0, x0, 64
	ldr	x25, [sp, 136]
	add	x7, x7, x25
.L205:
	ldr	x25, [sp, 168]
	sxtw	x26, w18
	ldr	x30, [sp, 128]
	add	x25, x25, x26
	add	x26, x9, x26
	add	w18, w18, 1
	lsl	x25, x25, 6
	ldp	q1, q2, [x1, 64]
	ldr	q0, [x30, x25]
	ldr	d4, [x22, x26, lsl 3]
	add	x26, x30, x25
	ldp	q6, q5, [x1, 96]
	fmul	v0.2d, v0.2d, v4.d[0]
	fadd	v1.2d, v0.2d, v1.2d
	str	q1, [x1, 64]
	ldr	q3, [x26, 16]
	fmul	v3.2d, v3.2d, v4.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x1, 80]
	ldr	q2, [x26, 32]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	str	q2, [x1, 96]
	ldr	q0, [x26, 48]
	fmul	v0.2d, v0.2d, v4.d[0]
	fadd	v0.2d, v0.2d, v5.2d
	str	q0, [x1, 112]
	cmp	w4, w18
	ble	.L207
	add	x18, x9, 1
	ldr	q4, [x27]
	ldr	d6, [x22, x18, lsl 3]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v1.2d
	mov	v1.16b, v4.16b
	str	q4, [x1, 64]
	ldr	q5, [x27, 16]
	fmul	v5.2d, v5.2d, v6.d[0]
	fadd	v5.2d, v5.2d, v3.2d
	str	q5, [x1, 80]
	ldr	q3, [x27, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x1, 96]
	ldr	q2, [x27, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v0.2d, v2.2d, v0.2d
	str	q0, [x1, 112]
	cmp	w4, 3
	bne	.L207
	add	x18, x9, 2
	ldr	q1, [x28]
	ldr	d6, [x22, x18, lsl 3]
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
.L207:
	ldr	d0, [x7, 8]
	ldp	q4, q3, [x0, 64]
	add	w4, w4, 1
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
	cmp	w11, w4
	bne	.L208
.L204:
	ldr	x0, [sp, 152]
	add	x8, x8, 4
	sub	w5, w5, #4
	add	x2, x2, 256
	add	x12, x12, x0
	add	w16, w16, 4
	ldr	x0, [sp, 144]
	add	x13, x13, x24
	add	w10, w10, 4
	add	x15, x15, x24
	add	x6, x6, 256
	add	x14, x14, x0
	cmp	w23, w8
	bgt	.L195
	ldp	x9, x25, [sp, 320]
	ldr	w7, [sp, 304]
	ldr	w1, [sp, 312]
	ldr	w26, [sp, 316]
.L188:
	cmp	w7, 0
	ble	.L189
	ldr	x0, [sp, 200]
	ubfiz	x28, x1, 3, 32
	ldr	x1, [sp, 176]
	str	w7, [sp, 160]
	ldr	x27, [sp, 120]
	add	x5, x1, x0, lsl 3
	mov	x20, x27
	mov	x27, x19
	mov	x19, x9
.L191:
	mov	x1, x20
	mov	x0, x5
	mov	x2, x28
	add	x20, x20, 64
	bl	memcpy
	add	x5, x0, x25
	cmp	x19, x20
	bne	.L191
	ldr	w7, [sp, 160]
	mov	x9, x19
	mov	x19, x27
.L189:
	ldr	x2, [sp, 120]
	sub	w7, w7, #8
	ldr	x1, [sp, 216]
	ldr	w0, [sp, 212]
	add	x2, x2, x1
	str	x2, [sp, 120]
	ldr	x2, [sp, 200]
	add	x9, x9, x1
	ldr	x1, [sp, 184]
	add	x2, x2, 8
	str	x2, [sp, 200]
	cmp	w0, 0
	ldr	x2, [sp, 232]
	mov	w0, 2
	csinc	w0, w0, wzr, ne
	add	x1, x1, x2
	str	x1, [sp, 184]
	mov	w1, 1
	str	w1, [sp, 212]
	ldr	w1, [sp, 240]
	cmp	w1, w0
	bgt	.L192
	ldr	x3, [sp, 296]
	mov	w17, w23
	ldr	w20, [sp, 284]
	ldr	w6, [sp, 288]
.L181:
	ldr	x0, [sp, 272]
	add	x3, x3, 16
	sub	w6, w6, #16
	cmp	x3, x0
	bne	.L179
	ldr	x23, [sp, 128]
	ldr	d8, [sp, 96]
	.cfi_restore 72
.L176:
	bl	GOMP_barrier
	ldp	x29, x30, [sp]
	mov	x0, x23
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 608
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
.L298:
	.cfi_def_cfa_offset 608
	.cfi_offset 19, -592
	.cfi_offset 20, -584
	.cfi_offset 21, -576
	.cfi_offset 22, -568
	.cfi_offset 23, -560
	.cfi_offset 24, -552
	.cfi_offset 25, -544
	.cfi_offset 26, -536
	.cfi_offset 27, -528
	.cfi_offset 28, -520
	.cfi_offset 29, -608
	.cfi_offset 30, -600
	.cfi_offset 72, -512
	mov	x2, x22
	mov	x1, x28
	mov	x0, x20
	bl	memcpy
.L221:
	add	x20, x20, 64
	add	x28, x28, x25
	cmp	x20, x27
	bne	.L298
	b	.L216
.L297:
	cmp	w8, 0
	ble	.L215
	movi	v1.2d, 0
	sxtw	x7, w10
	sxtw	x9, w16
	sub	x7, x7, x8
	sub	x9, x9, x8
	mov	x4, x13
	ldr	x0, [sp, 120]
	mul	x7, x7, x19
	mul	x9, x9, x19
	mov	w1, 0
	mov	v20.16b, v1.16b
	mov	w11, 0
	mov	v18.16b, v1.16b
	mov	w25, 0
	mov	v4.16b, v1.16b
	mov	w18, 0
	mov	v24.16b, v1.16b
	mov	w27, 0
	mov	v27.16b, v1.16b
	mov	w26, 0
	mov	v26.16b, v1.16b
	mov	w30, 0
	mov	v25.16b, v1.16b
	mov	w28, 0
	mov	v19.16b, v1.16b
	mov	v16.16b, v1.16b
	mov	v8.16b, v1.16b
	mov	v3.16b, v1.16b
	.p2align 3,,7
.L211:
	ldp	q7, q6, [x0]
	ldp	q5, q22, [x0, 32]
	ld1r	{v0.2d}, [x4]
	fmul	v2.2d, v0.2d, v7.2d
	fmul	v23.2d, v0.2d, v6.2d
	fmul	v28.2d, v0.2d, v5.2d
	fmul	v0.2d, v0.2d, v22.2d
	fadd	v3.2d, v2.2d, v3.2d
	fadd	v23.2d, v23.2d, v8.2d
	fadd	v28.2d, v28.2d, v16.2d
	fadd	v2.2d, v0.2d, v19.2d
	cmp	w5, 1
	ble	.L209
	ldr	d0, [x4, x7, lsl 3]
	mov	w1, 1
	mov	w11, w1
	mov	w25, w1
	mov	w18, w1
	fmul	v16.2d, v7.2d, v0.d[0]
	fmul	v19.2d, v6.2d, v0.d[0]
	fmul	v21.2d, v5.2d, v0.d[0]
	fmul	v0.2d, v22.2d, v0.d[0]
	fadd	v4.2d, v16.2d, v4.2d
	fadd	v18.2d, v19.2d, v18.2d
	fadd	v20.2d, v21.2d, v20.2d
	fadd	v1.2d, v0.2d, v1.2d
	cmp	w5, 3
	bne	.L209
	ldr	d16, [x4, x9, lsl 3]
	mov	w27, w1
	mov	w26, w1
	mov	w30, w1
	mov	w28, w1
	fmul	v7.2d, v7.2d, v16.d[0]
	fmul	v6.2d, v6.2d, v16.d[0]
	fmul	v5.2d, v5.2d, v16.d[0]
	fmul	v0.2d, v22.2d, v16.d[0]
	fadd	v25.2d, v7.2d, v25.2d
	fadd	v26.2d, v6.2d, v26.2d
	fadd	v27.2d, v5.2d, v27.2d
	fadd	v24.2d, v0.2d, v24.2d
.L209:
	add	x0, x0, 64
	add	x4, x4, 8
	mov	v8.16b, v23.16b
	mov	v16.16b, v28.16b
	mov	v19.16b, v2.16b
	cmp	x0, x2
	bne	.L211
	stp	q3, q23, [sp, 352]
	stp	q28, q2, [sp, 384]
	cbz	w1, .L196
	str	q1, [sp, 464]
.L196:
	cbz	w11, .L197
	str	q20, [sp, 448]
.L197:
	cbz	w25, .L198
	str	q18, [sp, 432]
.L198:
	cbz	w18, .L199
	str	q4, [sp, 416]
.L199:
	cbz	w27, .L200
	str	q24, [sp, 528]
.L200:
	cbz	w26, .L201
	str	q27, [sp, 512]
.L201:
	cbz	w30, .L202
	str	q26, [sp, 496]
.L202:
	cbz	w28, .L215
	str	q25, [sp, 480]
	b	.L215
.L237:
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
	b	.L213
.L295:
	sub	w0, w23, w26
	cmp	w0, 15
	ble	.L185
	ldr	x0, [sp, 136]
	sxtw	x2, w26
	lsl	x28, x19, 7
	mov	x27, x19
	sub	x13, x0, #8
	mov	w19, w23
	mov	w20, w26
	mov	x23, x9
	str	x22, [sp, 160]
	madd	x2, x13, x2, x22
	mov	x22, x28
	mov	x28, x13
	str	x21, [sp, 304]
	mov	x21, x2
	str	w1, [sp, 168]
	str	w7, [sp, 312]
.L186:
	ldr	x3, [sp, 120]
	mov	w0, w20
	ldr	w1, [sp, 208]
	mov	x2, x21
	add	w20, w20, 16
	add	x21, x21, x22
	bl	solve16x8_panel_sve
	sub	w5, w19, w20
	cmp	w5, 15
	bgt	.L186
	mov	x9, x23
	mov	w23, w19
	ldr	x22, [sp, 160]
	mov	x19, x27
	ldr	x21, [sp, 304]
	mov	w27, w20
	ldr	w1, [sp, 168]
	mov	x13, x28
	ldr	w7, [sp, 312]
	cmp	w23, w20
	bgt	.L187
	b	.L188
.L293:
	cbz	w23, .L181
	cmp	w17, 7
	bgt	.L184
	b	.L181
	.p2align 2,,3
.L296:
	cmp	w23, 0
	ble	.L189
	b	.L188
	.p2align 2,,3
.L294:
	cmp	w17, 7
	ble	.L291
.L184:
	mov	x18, x22
	mov	w23, w17
	mov	w26, w6
	mov	x27, x3
	mov	w15, 0
.L182:
	ldr	x3, [sp, 128]
	mov	w0, w15
	ldr	x4, [sp, 192]
	mov	x2, x18
	ldr	w1, [sp, 208]
	add	w15, w15, 8
	bl	solve8x16_panel_sve
	ldr	x1, [sp, 224]
	sub	w0, w23, w15
	add	x18, x18, x1
	cmp	w0, 7
	bgt	.L182
	mov	w17, w23
	mov	w6, w26
	mov	x3, x27
	cmp	w26, 0
	ble	.L181
	ldr	w26, [sp, 244]
	mov	w23, 1
	b	.L183
.L292:
	cmp	w6, 0
	ble	.L181
	cmp	w17, 0
	ble	.L181
	ldr	x0, [sp, 176]
	add	x24, x3, w24, uxtw
	ldr	x10, [sp, 136]
	mov	x5, x3
	add	x7, x0, x3, lsl 3
.L226:
	ldr	d0, [x7]
	ldr	d1, [x22]
	fdiv	d0, d0, d1
	str	d0, [x7]
	cmp	w17, 1
	beq	.L225
	ldr	x0, [sp, 264]
	add	x4, x22, x10
	ldr	x1, [sp, 176]
	add	x0, x5, x0
	sub	x11, x10, #8
	add	x8, x22, x19, lsl 3
	add	x0, x1, x0, lsl 3
	mov	w1, 1
.L228:
	movi	d1, #0
	mov	x9, x7
	mov	x2, 0
.L227:
	ldr	d2, [x8, x2, lsl 3]
	add	x2, x2, 1
	ldr	d0, [x9]
	add	x9, x9, x25
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w1, w2
	bgt	.L227
	ldr	d0, [x0]
	add	w1, w1, 1
	ldr	d2, [x4]
	add	x8, x8, x11
	add	x4, x4, x10
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x0]
	add	x0, x0, x25
	cmp	w17, w1
	bne	.L228
.L225:
	add	x5, x5, 1
	add	x7, x7, 8
	cmp	x5, x24
	bne	.L226
	b	.L181
.L173:
	.cfi_restore 72
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w22, ne
	tbnz	w26, #31, .L230
.L174:
	sbfiz	x2, x26, 7, 32
	add	x0, sp, 344
	mov	x1, 64
	bl	posix_memalign
	cbnz	w0, .L230
	bl	omp_get_num_threads
	mov	w21, w0
	bl	omp_get_thread_num
	ldr	x23, [sp, 344]
	sdiv	w1, w20, w21
	msub	w2, w1, w21, w20
	cmp	w0, w2
	bge	.L229
.L175:
	add	w1, w1, 1
	mov	w2, 0
	b	.L229
.L235:
	.cfi_offset 72, -512
	mov	w18, 0
	b	.L206
	.cfi_endproc
.LFE4377:
	.size	solve_panel_wide8x16._omp_fn.0, .-solve_panel_wide8x16._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4375:
	.cfi_startproc
	sub	sp, sp, #1056
	.cfi_def_cfa_offset 1056
	stp	x29, x30, [sp]
	.cfi_offset 29, -1056
	.cfi_offset 30, -1048
	mov	x29, sp
	ldr	w2, [x0, 24]
	ldr	w1, [x0, 40]
	str	w2, [sp, 264]
	ldr	w2, [x0, 28]
	stp	x23, x24, [sp, 48]
	stp	x27, x28, [sp, 80]
	.cfi_offset 23, -1008
	.cfi_offset 24, -1000
	.cfi_offset 27, -976
	.cfi_offset 28, -968
	ldp	x23, x28, [x0]
	str	x0, [sp, 256]
	str	w2, [sp, 360]
	ldp	w2, w0, [x0, 32]
	str	w0, [sp, 148]
	str	w2, [sp, 248]
	str	w1, [sp, 488]
	cbz	w1, .L480
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 488]
.L480:
	ldr	w0, [sp, 264]
	cmp	w0, 0
	ble	.L299
	stp	x19, x20, [sp, 16]
	.cfi_offset 20, -1032
	.cfi_offset 19, -1040
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -1016
	.cfi_offset 21, -1024
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -984
	.cfi_offset 25, -992
	bl	omp_get_num_threads
	mov	w19, w0
	str	w0, [sp, 560]
	bl	omp_get_thread_num
	ldr	w7, [sp, 360]
	mov	w26, w0
	mov	w6, w19
	ldrsw	x20, [sp, 248]
	adds	w2, w7, 7
	add	w1, w7, 14
	csel	w0, w1, w2, mi
	ldr	w5, [sp, 148]
	add	w1, w7, 63
	add	x13, x20, 1
	asr	w0, w0, 3
	mov	w3, 24
	asr	w1, w1, 6
	str	w1, [sp, 492]
	smull	x3, w5, w3
	lsl	x12, x20, 1
	sdiv	w2, w0, w6
	sxtw	x4, w5
	lsl	x9, x20, 3
	str	x3, [sp, 568]
	mov	w3, w5
	sbfiz	x5, x5, 3, 32
	lsl	x10, x13, 5
	lsl	x11, x13, 2
	msub	w0, w2, w6, w0
	lsl	x6, x13, 8
	str	x6, [sp, 688]
	add	x6, x12, x20
	cmp	w26, w0
	str	x10, [sp, 640]
	cinc	w2, w2, lt
	sub	x10, x10, #32
	str	x10, [sp, 512]
	sub	x10, x11, #4
	sbfiz	x8, x3, 4, 32
	str	x9, [sp, 112]
	mul	w1, w2, w26
	str	x5, [sp, 120]
	str	x4, [sp, 152]
	mov	x22, x20
	add	w0, w0, w1
	str	x8, [sp, 336]
	csel	w1, w1, w0, lt
	add	x0, x5, 16
	stp	x6, x0, [sp, 368]
	add	x6, x23, x9
	add	w2, w2, w1
	str	x6, [sp, 352]
	add	x6, x9, 8
	str	x6, [sp, 432]
	lsl	x6, x20, 7
	str	x6, [sp, 616]
	lsl	x6, x20, 4
	str	x6, [sp, 632]
	lsl	x6, x20, 6
	str	x6, [sp, 600]
	neg	x6, x4, lsl 7
	add	x0, x5, 32
	str	x6, [sp, 696]
	neg	x6, x4, lsl 6
	str	x0, [sp, 384]
	add	x0, x5, 48
	str	x6, [sp, 704]
	lsl	x6, x4, 2
	neg	x4, x4, lsl 5
	str	x0, [sp, 392]
	lsl	w0, w2, 3
	str	x20, [sp, 440]
	mov	x19, x23
	str	x12, [sp, 496]
	mov	w25, w2
	str	x6, [sp, 584]
	lsl	w6, w1, 3
	str	x11, [sp, 648]
	mov	w21, w1
	str	x10, [sp, 656]
	lsl	x10, x13, 11
	str	x10, [sp, 680]
	mov	w24, w6
	str	x4, [sp, 712]
	str	w0, [sp, 564]
	sub	w0, w7, w6
	str	w0, [sp, 624]
	sxtw	x0, w6
	str	x0, [sp, 664]
	add	x0, x8, 16
	str	x0, [sp, 400]
	add	x0, x8, 32
	str	x0, [sp, 408]
	add	x0, x8, 48
	str	x0, [sp, 416]
	sbfiz	x0, x3, 8, 32
	str	xzr, [sp, 168]
	str	xzr, [sp, 272]
	str	x28, [sp, 328]
	stp	x23, x23, [sp, 448]
	str	w26, [sp, 524]
	str	x0, [sp, 672]
	mov	x0, 0
	mov	x20, x0
	str	x13, [sp, 728]
	b	.L361
.L666:
	add	w26, w1, 256
	cmp	w25, w21
	bgt	.L663
.L303:
	str	w15, [sp, 128]
	bl	GOMP_barrier
	ldr	w0, [sp, 264]
	ldr	w15, [sp, 128]
	cmp	w0, w26
	ble	.L363
	ldr	w0, [sp, 264]
	ldr	w1, [sp, 360]
	add	w0, w0, 63
	sub	w0, w0, w26
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L363
	ldr	w1, [sp, 492]
	ldr	w2, [sp, 560]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	ldr	w2, [sp, 524]
	cmp	w2, w0
	bcc	.L364
.L479:
	ldr	w2, [sp, 524]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L664
.L363:
	bl	GOMP_barrier
	ldr	x0, [sp, 168]
	ldr	x2, [sp, 672]
	add	x1, x0, 256
	ldr	x0, [sp, 272]
	add	x20, x20, x2
	ldr	x3, [sp, 352]
	add	x0, x0, x2
	str	x0, [sp, 272]
	ldr	x0, [sp, 680]
	str	x1, [sp, 168]
	ldr	x4, [sp, 688]
	add	x3, x3, x0
	str	x3, [sp, 352]
	ldr	x3, [sp, 440]
	ldr	x2, [sp, 456]
	add	x3, x3, x4
	str	x3, [sp, 440]
	ldr	x3, [sp, 448]
	add	x3, x3, x0
	add	x0, x2, x0
	stp	x3, x0, [sp, 448]
	ldr	w0, [sp, 264]
	cmp	w0, w1
	ble	.L665
.L361:
	ldr	x1, [sp, 168]
	str	w1, [sp, 252]
	ldr	w0, [sp, 264]
	mov	w15, w1
	sub	w0, w0, w1
	cmp	w0, 255
	bgt	.L666
	cmp	w25, w21
	ble	.L481
	ldr	w26, [sp, 264]
	str	d8, [sp, 96]
	.cfi_offset 72, -960
.L482:
	ldr	x18, [sp, 664]
	sub	w30, w26, w15
	ldr	x1, [sp, 112]
	add	x0, x18, x20
	str	x0, [sp, 128]
	sub	w16, w30, #1
	ldr	x0, [sp, 352]
	mov	w28, w24
	ldr	w17, [sp, 168]
	mov	w7, w25
	ldr	w23, [sp, 624]
	mov	w5, w24
	mov	w6, w21
	mov	w14, w15
	mov	x27, x18
	sub	x0, x0, x1
	str	x0, [sp, 160]
.L307:
	ldr	x0, [sp, 256]
	cmp	w23, 8
	mov	w1, 8
	csel	w1, w23, w1, le
	ldr	x0, [x0, 16]
	ldr	x25, [x0]
	cbz	x25, .L667
	cmp	w28, 0
	add	w9, w28, 7
	csel	w9, w9, w28, lt
	asr	w9, w9, 3
	sbfiz	x24, x9, 14, 32
	sxtw	x9, w9
	add	x24, x25, x24
	cmp	w30, 0
	ble	.L308
	mov	w0, 7
	sub	w0, w0, w1
	add	x0, x0, 1
	sbfiz	x4, x1, 3, 32
	mov	x10, x24
	mov	x3, x25
	lsl	x0, x0, 3
	str	x0, [sp, 136]
	mov	x0, x4
	mov	w25, w7
	mov	x12, x20
	mov	x7, x24
	mov	x4, x22
	mov	x24, x19
	mov	w21, w5
	mov	x11, x16
	mov	w20, w14
	mov	w8, w30
	mov	w13, w17
	mov	x19, x10
	mov	x22, x0
.L357:
	cmp	w23, 0
	ble	.L328
	ldr	x2, [sp, 328]
.L327:
	ldr	w0, [sp, 148]
	smaddl	x1, w20, w0, x27
	lsl	x0, x1, 3
	ldr	d0, [x2, x1, lsl 3]
	add	x0, x2, x0
	str	d0, [x19]
	cmp	w23, 1
	ble	.L328
	ldr	d0, [x0, 8]
	str	d0, [x19, 8]
	cmp	w23, 2
	ble	.L328
	ldr	d0, [x0, 16]
	str	d0, [x19, 16]
	cmp	w23, 3
	ble	.L328
	ldr	d0, [x0, 24]
	str	d0, [x19, 24]
	cmp	w23, 4
	ble	.L328
	ldr	d0, [x0, 32]
	str	d0, [x19, 32]
	cmp	w23, 5
	ble	.L328
	ldr	d0, [x0, 40]
	str	d0, [x19, 40]
	cmp	w23, 6
	ble	.L328
	ldr	d0, [x0, 48]
	str	d0, [x19, 48]
	cmp	w23, 7
	ble	.L328
	ldr	d0, [x0, 56]
	add	w20, w20, 1
	add	x19, x19, 64
	str	d0, [x19, -8]
	cmp	w26, w20
	bne	.L327
.L658:
	ldp	x15, x18, [sp, 440]
	mov	x22, x4
	ldr	x2, [sp, 160]
	lsl	x0, x9, 8
	ldr	x9, [sp, 352]
	mov	x19, x24
	movi	v17.4s, 0
	mov	x24, x7
	mov	w7, w25
	mov	x25, x3
	neg	x3, x22
	mov	w17, w13
	mov	w30, w8
	add	w13, w14, 2
	mov	x1, x24
	mov	w4, w8
	str	x0, [sp, 136]
	add	x0, sp, 800
	str	x3, [sp, 184]
	add	x3, x19, 8
	str	w21, [sp, 216]
	mov	x21, x11
	str	w26, [sp, 232]
	mov	x26, x10
	str	x3, [sp, 192]
	mov	x3, 0
	str	w28, [sp, 200]
	str	w7, [sp, 208]
	str	w6, [sp, 224]
	str	x12, [sp, 240]
	str	w14, [sp, 268]
	str	w17, [sp, 280]
.L335:
	stp	q17, q17, [x0]
	stp	q17, q17, [x0, 32]
	stp	q17, q17, [x0, 64]
	stp	q17, q17, [x0, 96]
	stp	q17, q17, [x0, 128]
	stp	q17, q17, [x0, 160]
	stp	q17, q17, [x0, 192]
	stp	q17, q17, [x0, 224]
	cmp	w4, 3
	ble	.L668
	movi	v0.2d, 0
	cbz	w3, .L488
	ldr	x10, [sp, 368]
	add	x7, x24, x3, lsl 6
	ldr	x8, [sp, 496]
	mov	x6, x2
	mov	v18.16b, v0.16b
	mov	x5, x24
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
.L355:
	ldp	q5, q4, [x5]
	ldp	q3, q1, [x5, 32]
	add	x5, x5, 64
	ldr	d7, [x6, x22, lsl 3]
	ldr	d6, [x6, x8, lsl 3]
	ldr	d2, [x6, x10, lsl 3]
	fmla	v28.2d, v5.2d, v7.d[0]
	ld1r	{v16.2d}, [x6]
	fmla	v27.2d, v4.2d, v7.d[0]
	add	x6, x6, 8
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
	cmp	x5, x7
	bne	.L355
.L354:
	stp	q8, q31, [sp, 800]
	stp	q30, q29, [sp, 832]
	stp	q28, q27, [sp, 864]
	stp	q26, q25, [sp, 896]
	stp	q24, q23, [sp, 928]
	stp	q22, q21, [sp, 960]
	stp	q20, q19, [sp, 992]
	str	q18, [sp, 1024]
	str	q0, [sp, 1040]
.L356:
	ldr	x5, [sp, 184]
	ldp	q4, q3, [x1]
	ldp	q2, q1, [x1, 32]
	ldp	q8, q7, [sp, 800]
	ldp	q6, q5, [sp, 832]
	fsub	v4.2d, v4.2d, v8.2d
	ldr	d0, [x9, x5, lsl 3]
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
	beq	.L345
	ldr	x5, [sp, 136]
	cmp	w4, 4
	mov	x12, x9
	mov	x8, x15
	add	x28, x5, x3
	mov	w5, 4
	add	x6, x28, 2
	add	x11, x28, 1
	csel	w14, w4, w5, le
	mov	w7, 1
	add	x16, x25, x6, lsl 6
	mov	x5, x0
	add	x11, x25, x11, lsl 6
	mov	x6, x1
	mov	w10, 0
	b	.L346
.L349:
	add	x5, x5, 64
	add	x8, x8, x22
	cmp	w7, 2
	beq	.L486
	ldp	q1, q0, [x1]
	mov	w10, 2
	ldr	d5, [x19, x8, lsl 3]
	ldp	q3, q2, [x5, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldr	x17, [sp, 192]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	ldr	d4, [x17, x8, lsl 3]
	ldp	q7, q6, [x5, 96]
	stp	q1, q0, [x5, 64]
	ldp	q3, q2, [x1, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x5, 64]
	ldp	q1, q0, [x1, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x5, 96]
	ldp	q3, q2, [x1, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x5, 96]
.L347:
	add	x6, x6, 64
	ldr	x17, [sp, 432]
	add	x12, x12, x17
.L346:
	sxtw	x17, w10
	add	w10, w10, 1
	add	x20, x28, x17
	add	x17, x17, x8
	ldp	q1, q6, [x5, 64]
	lsl	x20, x20, 6
	ldr	d0, [x19, x17, lsl 3]
	add	x17, x25, x20
	ldp	q5, q4, [x5, 96]
	ldr	q2, [x25, x20]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x5, 64]
	ldr	q3, [x17, 16]
	fmul	v3.2d, v3.2d, v0.d[0]
	fadd	v3.2d, v3.2d, v6.2d
	str	q3, [x5, 80]
	ldr	q2, [x17, 32]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x5, 96]
	ldr	q5, [x17, 48]
	fmul	v5.2d, v5.2d, v0.d[0]
	fadd	v5.2d, v5.2d, v4.2d
	str	q5, [x5, 112]
	cmp	w10, w7
	bge	.L348
	add	x10, x8, 1
	ldr	q0, [x11]
	ldr	d6, [x19, x10, lsl 3]
	fmul	v0.2d, v0.2d, v6.d[0]
	fadd	v0.2d, v0.2d, v1.2d
	mov	v1.16b, v0.16b
	str	q0, [x5, 64]
	ldr	q4, [x11, 16]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v3.2d
	str	q4, [x5, 80]
	ldr	q3, [x11, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x5, 96]
	ldr	q2, [x11, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x5, 112]
	cmp	w7, 3
	bne	.L348
	add	x10, x8, 2
	ldr	q1, [x16]
	ldr	d5, [x19, x10, lsl 3]
	fmul	v1.2d, v1.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v0.2d
	str	q1, [x5, 64]
	ldr	q0, [x16, 16]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v4.2d
	str	q0, [x5, 80]
	ldr	q0, [x16, 32]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v3.2d
	str	q0, [x5, 96]
	ldr	q0, [x16, 48]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x5, 112]
.L348:
	ldr	d0, [x12, 8]
	ldp	q4, q3, [x6, 64]
	add	w7, w7, 1
	dup	v0.2d, v0.d[0]
	ldr	q2, [x6, 96]
	fsub	v4.2d, v4.2d, v1.2d
	ldr	q1, [x6, 112]
	fdiv	v4.2d, v4.2d, v0.2d
	str	q4, [x6, 64]
	ldr	q4, [x5, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v0.2d
	str	q3, [x6, 80]
	ldr	q3, [x5, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x6, 96]
	ldr	q2, [x5, 112]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q0, [x6, 112]
	cmp	w14, w7
	bne	.L349
.L345:
	ldr	x5, [sp, 640]
	add	x3, x3, 4
	sub	w4, w4, #4
	add	x1, x1, 256
	add	x9, x9, x5
	add	w13, w13, 4
	ldr	x5, [sp, 648]
	add	x15, x15, x5
	ldr	x5, [sp, 512]
	add	x18, x18, x5
	add	x2, x2, x5
	cmp	w30, w3
	bgt	.L335
	ldr	x20, [sp, 240]
	mov	x16, x21
	ldr	w28, [sp, 200]
	mov	x21, x26
	ldr	w7, [sp, 208]
	ldr	w5, [sp, 216]
	ldr	w6, [sp, 224]
	ldr	w26, [sp, 232]
	ldr	w14, [sp, 268]
	ldr	w17, [sp, 280]
	cmp	w23, 0
	ble	.L308
	ldr	x0, [sp, 128]
	add	x1, x16, 1
	ldr	x2, [sp, 328]
	add	x1, x24, x1, lsl 6
	add	x0, x2, x0, lsl 3
.L332:
	ldr	d0, [x21]
	str	d0, [x0]
	cmp	w23, 1
	ble	.L330
	ldr	d0, [x21, 8]
	str	d0, [x0, 8]
	cmp	w23, 2
	ble	.L330
	ldr	d0, [x21, 16]
	str	d0, [x0, 16]
	cmp	w23, 3
	ble	.L330
	ldr	d0, [x21, 24]
	str	d0, [x0, 24]
	cmp	w23, 4
	ble	.L330
	ldr	d0, [x21, 32]
	str	d0, [x0, 32]
	cmp	w23, 5
	ble	.L330
	ldr	d0, [x21, 40]
	str	d0, [x0, 40]
	cmp	w23, 6
	ble	.L330
	ldr	d0, [x21, 48]
	str	d0, [x0, 48]
	cmp	w23, 7
	ble	.L330
	ldr	d0, [x21, 56]
	str	d0, [x0, 56]
.L330:
	ldr	x2, [sp, 120]
	add	x21, x21, 64
	add	x0, x0, x2
	cmp	x21, x1
	bne	.L332
.L308:
	ldr	x0, [sp, 128]
	add	w28, w28, 8
	sub	w23, w23, #8
	add	x27, x27, 8
	add	x0, x0, 8
	str	x0, [sp, 128]
	ldr	w0, [sp, 564]
	cmp	w0, w28
	bgt	.L307
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	w25, w7
	mov	w24, w5
	mov	w21, w6
	mov	w15, w14
	b	.L303
.L328:
	.cfi_restore_state
	ldr	x2, [sp, 136]
	add	x0, x19, x22
	add	w20, w20, 1
	mov	w1, 0
	stp	x3, x4, [sp, 176]
	add	x19, x19, 64
	str	x7, [sp, 192]
	str	w8, [sp, 200]
	str	w6, [sp, 208]
	stp	x10, x11, [sp, 216]
	str	x12, [sp, 232]
	str	w14, [sp, 240]
	str	w13, [sp, 268]
	str	x9, [sp, 280]
	bl	memset
	ldp	x3, x4, [sp, 176]
	cmp	w26, w20
	ldr	x7, [sp, 192]
	ldp	x10, x11, [sp, 216]
	ldr	x12, [sp, 232]
	ldr	x9, [sp, 280]
	ldr	w8, [sp, 200]
	ldr	w6, [sp, 208]
	ldr	w14, [sp, 240]
	ldr	w13, [sp, 268]
	bne	.L357
	b	.L658
.L668:
	cbz	w3, .L356
	ldr	x11, [sp, 168]
	sub	w6, w13, #1
	ldr	w10, [sp, 248]
	lsl	x5, x3, 3
	movi	v0.2d, 0
	mov	x7, x24
	mov	w28, 0
	mov	w20, 0
	mov	w17, 0
	mov	w14, 0
	smaddl	x8, w10, w13, x11
	str	x5, [sp, 176]
	smaddl	x6, w10, w6, x11
	mov	w5, 0
	mov	v19.16b, v0.16b
	mov	w11, 0
	mov	v8.16b, v0.16b
	add	x12, x19, x8, lsl 3
	mov	v1.16b, v0.16b
	add	x16, x19, x6, lsl 3
	mov	v25.16b, v0.16b
	mov	w10, 0
	mov	v24.16b, v0.16b
	mov	w8, 0
	mov	v23.16b, v0.16b
	mov	x6, 0
	mov	v22.16b, v0.16b
	str	x0, [sp, 288]
	mov	v21.16b, v0.16b
	mov	v18.16b, v0.16b
	mov	v7.16b, v0.16b
	mov	v20.16b, v0.16b
.L352:
	ldp	q6, q5, [x7]
	ldp	q4, q3, [x7, 32]
	ldr	d2, [x18, x6]
	fmul	v16.2d, v6.2d, v2.d[0]
	fmul	v26.2d, v5.2d, v2.d[0]
	fmul	v27.2d, v4.2d, v2.d[0]
	fmul	v2.2d, v3.2d, v2.d[0]
	fadd	v20.2d, v16.2d, v20.2d
	fadd	v26.2d, v26.2d, v7.2d
	fadd	v27.2d, v27.2d, v18.2d
	fadd	v16.2d, v2.2d, v21.2d
	cmp	w4, 1
	ble	.L350
	ldr	d2, [x16, x6]
	mov	w5, 1
	mov	w11, w5
	mov	w10, w5
	mov	w8, w5
	fmul	v7.2d, v6.2d, v2.d[0]
	fmul	v18.2d, v5.2d, v2.d[0]
	fmul	v21.2d, v4.2d, v2.d[0]
	fmul	v2.2d, v3.2d, v2.d[0]
	fadd	v1.2d, v7.2d, v1.2d
	fadd	v8.2d, v18.2d, v8.2d
	fadd	v19.2d, v21.2d, v19.2d
	fadd	v0.2d, v2.2d, v0.2d
	cmp	w4, 3
	bne	.L350
	ldr	d2, [x12, x6]
	mov	w28, w5
	mov	w20, w5
	mov	w17, w5
	mov	w14, w5
	fmul	v6.2d, v6.2d, v2.d[0]
	fmul	v5.2d, v5.2d, v2.d[0]
	fmul	v4.2d, v4.2d, v2.d[0]
	fmul	v3.2d, v3.2d, v2.d[0]
	fadd	v22.2d, v6.2d, v22.2d
	fadd	v23.2d, v5.2d, v23.2d
	fadd	v24.2d, v4.2d, v24.2d
	fadd	v25.2d, v3.2d, v25.2d
.L350:
	ldr	x0, [sp, 176]
	add	x6, x6, 8
	mov	v7.16b, v26.16b
	add	x7, x7, 64
	mov	v18.16b, v27.16b
	mov	v21.16b, v16.16b
	cmp	x6, x0
	bne	.L352
	stp	q20, q26, [sp, 800]
	stp	q27, q16, [sp, 832]
	ldr	x0, [sp, 288]
	cbz	w5, .L337
	str	q0, [sp, 912]
.L337:
	cbz	w11, .L338
	str	q19, [sp, 896]
.L338:
	cbz	w10, .L339
	str	q8, [sp, 880]
.L339:
	cbz	w8, .L340
	str	q1, [sp, 864]
.L340:
	cbz	w28, .L341
	str	q25, [sp, 976]
.L341:
	cbz	w20, .L342
	str	q24, [sp, 960]
.L342:
	cbz	w17, .L343
	str	q23, [sp, 944]
.L343:
	cbz	w14, .L356
	str	q22, [sp, 928]
	b	.L356
.L667:
	cmp	w26, w17
	ble	.L308
	ldr	w8, [sp, 252]
	sub	w10, w26, #1
	ldr	x4, [sp, 128]
	cmp	w10, w8
	ldr	x3, [sp, 328]
	csel	w10, w10, w8, le
	cmp	w23, 0
	csinc	w1, w1, wzr, gt
	ldr	x11, [sp, 456]
	add	x24, x3, x4, lsl 3
	and	w21, w1, -2
	and	w12, w1, 1
	lsr	w9, w1, 1
	mov	x0, x24
.L311:
	ldr	d1, [x11]
	cmp	w23, 0
	ble	.L325
	cmp	w23, 1
	beq	.L485
	ldr	q2, [x0]
	dup	v0.2d, v1.d[0]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0]
	cmp	w9, 1
	bls	.L324
	ldr	q2, [x0, 16]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 16]
	cmp	w9, 2
	beq	.L324
	ldr	q2, [x0, 32]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 32]
	cmp	w9, 3
	beq	.L324
	ldr	q2, [x0, 48]
	fdiv	v0.2d, v2.2d, v0.2d
	str	q0, [x0, 48]
.L324:
	mov	w2, w21
	cbz	w12, .L325
.L323:
	add	x2, x4, w2, sxtw
	ldr	d0, [x3, x2, lsl 3]
	fdiv	d0, d0, d1
	str	d0, [x3, x2, lsl 3]
.L325:
	ldr	x2, [sp, 432]
	add	w8, w8, 1
	add	x11, x11, x2
	ldr	x2, [sp, 152]
	add	x4, x4, x2
	ldr	x2, [sp, 120]
	add	x0, x0, x2
	cmp	w8, w10
	ble	.L311
	cmp	w8, w26
	bge	.L308
	ldr	w0, [sp, 148]
	sbfiz	x10, x8, 3, 32
	ldr	x2, [sp, 728]
	and	w1, w1, 1
	ldr	x11, [sp, 328]
	smaddl	x12, w0, w8, x27
	madd	x18, x2, x10, x19
	add	x0, sp, 800
	movi	v2.4s, 0
	madd	x10, x22, x10, x19
	add	x4, x11, x12, lsl 3
.L321:
	stp	q2, q2, [x0]
	stp	q2, q2, [x0, 32]
	cmp	w23, 0
	ble	.L312
	ldr	x15, [sp, 128]
	mov	x3, x24
	ldr	x13, [sp, 168]
.L315:
	ldr	d0, [x10, x13, lsl 3]
	cmp	w23, 1
	beq	.L483
	ldr	q3, [x3]
	ldr	q1, [sp, 800]
	fmul	v3.2d, v3.2d, v0.d[0]
	dup	v4.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 800]
	cmp	w9, 1
	bls	.L314
	ldr	q3, [x3, 16]
	ldr	q1, [sp, 816]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 816]
	cmp	w9, 2
	beq	.L314
	ldr	q3, [x3, 32]
	ldr	q1, [sp, 832]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 832]
	cmp	w9, 3
	beq	.L314
	ldr	q3, [x3, 48]
	ldr	q1, [sp, 848]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 848]
.L314:
	sxtw	x2, w21
	cbz	w1, .L317
.L313:
	add	x25, x2, x15
	ldr	d1, [x0, x2, lsl 3]
	ldr	d3, [x11, x25, lsl 3]
	fmul	d0, d0, d3
	fadd	d0, d0, d1
	str	d0, [x0, x2, lsl 3]
.L317:
	ldr	x2, [sp, 152]
	add	x13, x13, 1
	add	x15, x15, x2
	ldr	x2, [sp, 120]
	add	x3, x3, x2
	cmp	w8, w13
	bgt	.L315
	ldr	d3, [x18]
	cmp	w23, 1
	beq	.L484
	ldr	q0, [x4]
	ldr	q4, [sp, 800]
	dup	v1.2d, v3.d[0]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4]
	cmp	w9, 1
	bls	.L319
	ldr	q0, [x4, 16]
	ldr	q4, [sp, 816]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4, 16]
	cmp	w9, 2
	beq	.L319
	ldr	q0, [x4, 32]
	ldr	q4, [sp, 832]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4, 32]
	cmp	w9, 3
	beq	.L319
	ldr	q0, [x4, 48]
	ldr	q4, [sp, 848]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4, 48]
.L319:
	sxtw	x2, w21
	cbz	w1, .L312
.L318:
	add	x3, x2, x12
	ldr	d1, [x0, x2, lsl 3]
	ldr	d0, [x11, x3, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d3
	str	d0, [x11, x3, lsl 3]
.L312:
	ldr	x2, [sp, 432]
	add	w8, w8, 1
	add	x18, x18, x2
	ldr	x2, [sp, 152]
	add	x12, x12, x2
	ldr	x2, [sp, 120]
	add	x4, x4, x2
	ldr	x2, [sp, 112]
	add	x10, x10, x2
	cmp	w8, w26
	bne	.L321
	b	.L308
.L484:
	mov	x2, 0
	b	.L318
.L483:
	mov	x2, 0
	b	.L313
.L485:
	mov	w2, 0
	b	.L323
.L488:
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
	b	.L354
.L664:
	.cfi_restore 72
	ldr	w3, [sp, 492]
	sub	w17, w26, w15
	sub	w1, w1, #1
	str	w1, [sp, 628]
	sub	w1, w17, #1
	str	x1, [sp, 608]
	ldr	x1, [sp, 168]
	str	w1, [sp, 240]
	udiv	w2, w0, w3
	sub	w13, w26, #1
	str	w24, [sp, 740]
	mov	x28, x19
	neg	x4, x1, lsl 3
	ldr	w1, [sp, 264]
	ldr	x24, [sp, 328]
	msub	w0, w2, w3, w0
	add	w9, w26, w2, lsl 6
	mov	x23, x22
	sub	w1, w1, w9
	str	w1, [sp, 520]
	lsl	w30, w0, 6
	ldr	w1, [sp, 488]
	str	w13, [sp, 136]
	mov	w13, w30
	str	w25, [sp, 736]
	mov	w25, w26
	str	w21, [sp, 752]
	mov	w21, w9
	add	w27, w15, 1
	and	w1, w1, 1
	str	x4, [sp, 128]
	str	w1, [sp, 268]
	str	w27, [sp, 364]
	str	wzr, [sp, 464]
	str	w17, [sp, 468]
	str	x20, [sp, 744]
	str	d8, [sp, 96]
	.cfi_offset 72, -960
.L365:
	ldr	w3, [sp, 360]
	mov	w19, w21
	ldr	w0, [sp, 520]
	ldr	w1, [sp, 264]
	sub	w2, w3, w13
	cmp	w0, 63
	add	w0, w21, 64
	csel	w0, w0, w1, gt
	add	w1, w13, 64
	cmp	w2, 63
	csel	w10, w1, w3, gt
	ldr	w1, [sp, 268]
	cbnz	w1, .L669
.L368:
	cmp	w0, w19
	ble	.L442
	ldr	w3, [sp, 148]
	sub	w1, w10, w13
	ldr	w2, [sp, 248]
	add	w5, w13, 31
	sub	w1, w1, #32
	cmp	w10, w5
	and	w1, w1, -32
	sub	w20, w0, w19
	smull	x4, w3, w19
	csel	w1, w1, wzr, gt
	ldr	x3, [sp, 168]
	smull	x2, w2, w19
	ldr	x12, [sp, 256]
	add	x6, x2, x3
	ldr	x3, [sp, 272]
	add	x26, x28, x6, lsl 3
	ldr	x27, [sp, 496]
	sub	x7, x3, x4
	add	x8, x3, w13, sxtw
	mov	x18, x24
	ldr	x3, [sp, 608]
	mov	w19, w25
	mov	x22, x23
	mov	x25, x4
	add	x9, x3, 1
	add	w3, w13, 32
	add	w1, w1, w3
	str	w1, [sp, 576]
	lsl	x1, x7, 3
	str	x1, [sp, 320]
	neg	x1, x7, lsl 3
	str	x1, [sp, 344]
	add	x1, x24, x8, lsl 3
	str	x1, [sp, 592]
	lsl	x1, x9, 3
	mov	w8, w10
	mov	w24, w20
	str	x1, [sp, 720]
	mov	x1, x26
	mov	w26, w13
	mov	w13, w21
	str	x4, [sp, 312]
	str	w0, [sp, 756]
	str	w5, [sp, 792]
.L441:
	ldr	w0, [sp, 268]
	mov	w21, w26
	cbz	w0, .L439
	cmp	w24, 3
	bgt	.L670
.L439:
	cmp	w8, w21
	ble	.L448
	cmp	w24, 4
	mov	w0, 4
	csel	w0, w24, w0, le
	cmp	w24, 3
	sxtw	x9, w21
	str	w0, [sp, 504]
	cset	w0, gt
	add	x3, x25, x9
	str	w0, [sp, 224]
	ldr	x0, [sp, 568]
	lsl	x3, x3, 3
	add	x15, x18, x3
	str	w26, [sp, 760]
	add	x0, x0, x3
	mov	x26, x9
	add	x20, x18, x0
	mov	x9, x12
	ldr	x0, [sp, 128]
	str	x25, [sp, 784]
	str	w8, [sp, 160]
	add	x0, x1, x0
	str	x0, [sp, 480]
	ldr	x0, [sp, 720]
	str	x2, [sp, 424]
	str	w13, [sp, 768]
	add	x23, x0, x1
	str	w24, [sp, 776]
	mov	x25, x23
	mov	x23, x22
.L447:
	ldr	x0, [x9, 16]
	ldr	w2, [sp, 160]
	ldr	x3, [x0]
	sub	w8, w2, w21
	cbz	x3, .L671
	asr	w0, w21, 3
	mov	x6, 8
	mov	w4, w6
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 224]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	ble	.L672
.L445:
	ldr	w0, [sp, 268]
	cbnz	w0, .L468
	movi	v16.2d, 0
	ldr	w0, [sp, 468]
	cmp	w0, 0
	ble	.L505
	ldr	x10, [sp, 368]
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
.L470:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, x6
	ldr	d6, [x0, x23, lsl 3]
	ldr	d5, [x0, x27, lsl 3]
	ldr	d1, [x0, x10, lsl 3]
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
	cmp	x25, x0
	bne	.L470
.L469:
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
.L452:
	ldr	w0, [sp, 160]
	add	w21, w21, 8
	add	x26, x26, 8
	add	x15, x15, 64
	add	x20, x20, 64
	cmp	w0, w21
	bgt	.L447
	ldr	x2, [sp, 424]
	mov	x8, x0
	ldr	x25, [sp, 784]
	mov	x22, x23
	ldr	w26, [sp, 760]
	mov	x12, x9
	ldr	w13, [sp, 768]
	ldr	w24, [sp, 776]
.L448:
	ldr	x6, [sp, 320]
	ldr	x5, [sp, 712]
	ldr	x3, [sp, 512]
	add	x6, x6, x5
	str	x6, [sp, 320]
	ldr	x6, [sp, 656]
	add	x1, x1, x3
	ldr	x3, [sp, 584]
	add	x2, x2, x6
	ldr	x6, [sp, 312]
	add	x25, x25, x3
	ldr	w4, [sp, 756]
	add	x3, x6, x3
	str	x3, [sp, 312]
	ldr	x3, [sp, 344]
	sub	w0, w4, w24
	add	w0, w0, 4
	sub	x3, x3, x5
	str	x3, [sp, 344]
	sub	w3, w24, #4
	cmp	w4, w0
	ble	.L673
	mov	w24, w3
	b	.L441
.L468:
	ldp	w2, w0, [sp, 248]
	mov	x5, x15
	ldr	w6, [sp, 148]
	sub	w0, w19, w0
	stp	x1, x9, [sp, 176]
	bl	update4x8_sve
	ldp	x1, x9, [sp, 176]
	b	.L452
.L671:
	ldr	x0, [sp, 320]
	ldr	x6, [sp, 152]
	add	x3, x0, x15
	ldr	w0, [sp, 224]
	ldr	w4, [sp, 148]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	bgt	.L445
.L672:
	cmp	w8, 8
	mov	w14, 8
	csel	w14, w8, w14, le
	lsl	x5, x6, 3
	sub	w0, w14, #1
	str	w0, [sp, 216]
	lsr	w0, w14, 2
	str	w0, [sp, 232]
	add	x0, x3, x5
	str	x0, [sp, 200]
	ldr	x0, [sp, 312]
	lsr	w4, w14, 1
	ldr	x22, [sp, 424]
	and	w7, w14, -2
	ldr	x11, [sp, 480]
	lsl	x2, x6, 1
	add	x12, x0, x26
	ldr	w10, [sp, 136]
	lsl	x0, x6, 4
	ldr	w30, [sp, 364]
	movi	v4.4s, 0
	str	x6, [sp, 184]
	mov	x6, x26
	ldr	w26, [sp, 504]
	str	x5, [sp, 472]
	mov	x5, x20
	ldr	x20, [sp, 120]
	mov	x13, x15
	str	w4, [sp, 176]
	mov	x4, x1
	str	x0, [sp, 208]
	add	x0, sp, 800
	str	w7, [sp, 280]
	mov	x7, x9
	mov	x9, x2
	mov	w24, 0
	str	x25, [sp, 528]
	str	x15, [sp, 536]
	str	w21, [sp, 544]
	str	x27, [sp, 552]
.L451:
	ldr	w1, [sp, 240]
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w19, w1
	ble	.L450
	cmp	w10, w30
	ble	.L501
	ldr	x1, [sp, 128]
	mov	x25, x3
	ldr	x16, [sp, 184]
	sub	x27, x11, x1
	ldr	x21, [sp, 200]
	mov	w1, w30
	mov	x15, 0
	str	x18, [sp, 192]
	str	x23, [sp, 288]
	str	w24, [sp, 296]
	str	x20, [sp, 304]
	b	.L462
.L676:
	ldp	q0, q1, [x25, 32]
	ldp	q2, q5, [x21, 32]
	ldp	q6, q8, [sp, 832]
	fmul	v1.2d, v1.2d, v7.2d
	fmul	v0.2d, v0.2d, v7.2d
	fmul	v5.2d, v5.2d, v3.2d
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v8.2d
	fadd	v0.2d, v0.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q0, q1, [sp, 832]
	.p2align 3,,7
.L459:
	add	w2, w1, 2
	ldr	x17, [sp, 208]
	add	x27, x27, 16
	add	x15, x15, x9
	add	x16, x16, x9
	add	x25, x25, x17
	add	x21, x21, x17
	cmp	w2, w10
	bge	.L674
	mov	w1, w2
.L462:
	ldr	w2, [sp, 216]
	ldr	d0, [x27]
	cmp	w2, 2
	bls	.L675
	ldp	q1, q2, [x25]
	ldp	q5, q6, [x21]
	ldp	q16, q17, [sp, 800]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d3, [x27, 8]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w2, [sp, 232]
	dup	v7.2d, v0.d[0]
	fmul	v6.2d, v6.2d, v3.d[0]
	fmul	v5.2d, v5.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v17.2d
	fadd	v1.2d, v1.2d, v16.2d
	dup	v3.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	stp	q1, q2, [sp, 800]
	cmp	w2, 2
	beq	.L676
	cmp	w8, 4
	beq	.L459
	mov	x17, 4
	mov	w2, w17
.L457:
	sub	w24, w14, w17
	sxtw	x18, w1
	cmp	w24, 1
	beq	.L460
	add	x23, x15, x17
	add	x20, x17, x16
	lsl	x17, x17, 3
	lsl	x23, x23, 3
	lsl	x20, x20, 3
	ldr	q2, [x0, x17]
	ldr	q1, [x3, x23]
	add	x23, x18, x22
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x17]
	ldr	d3, [x28, x23, lsl 3]
	ldr	q2, [x3, x20]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x17]
	tbz	x24, 0, .L459
	and	w24, w24, -2
	add	w2, w2, w24
.L460:
	sxtw	x2, w2
	add	x18, x18, x22
	add	x20, x15, x2
	add	x17, x2, x16
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x20, lsl 3]
	ldr	d1, [x3, x17, lsl 3]
	ldr	d3, [x28, x18, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
	b	.L459
.L677:
	ldr	x18, [sp, 192]
.L450:
	cmp	w8, 1
	beq	.L500
	ldr	q0, [x13]
	ldr	q1, [sp, 800]
	ldr	w1, [sp, 176]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13]
	cmp	w1, 1
	bls	.L454
	ldr	q0, [x13, 16]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 16]
	cmp	w1, 2
	beq	.L454
	ldr	q0, [x13, 32]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 32]
	cmp	w1, 4
	bne	.L454
	ldr	q0, [x13, 48]
	ldr	q1, [sp, 848]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 48]
	.p2align 3,,7
.L455:
	add	w24, w24, 1
	ldr	x1, [sp, 152]
	add	x13, x13, x20
	add	x22, x22, x23
	add	x12, x12, x1
	ldr	x1, [sp, 112]
	add	x11, x11, x1
	cmp	w24, w26
	blt	.L451
	ldr	x25, [sp, 528]
	mov	x1, x4
	ldr	x15, [sp, 536]
	mov	x20, x5
	ldr	x27, [sp, 552]
	mov	x26, x6
	ldr	w21, [sp, 544]
	mov	x9, x7
	b	.L452
.L454:
	ldr	w1, [sp, 280]
	cmp	w14, w1
	beq	.L455
.L453:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x18, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x18, x2, lsl 3]
	b	.L455
.L674:
	ldr	x18, [sp, 192]
	add	w1, w1, 1
	ldr	x23, [sp, 288]
	ldr	x20, [sp, 304]
	ldr	w24, [sp, 296]
.L456:
	sxtw	x17, w1
	ldr	w21, [sp, 280]
	ldr	x1, [sp, 168]
	str	x18, [sp, 192]
	ldr	x27, [sp, 184]
	sub	x16, x17, x1
	ldr	x25, [sp, 472]
	mul	x15, x16, x27
	ldr	w18, [sp, 176]
	madd	x16, x16, x25, x3
	b	.L466
	.p2align 2,,3
.L678:
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w18, 2
	beq	.L464
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 832]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 832]
	cmp	w18, 4
	bne	.L464
	ldr	q1, [x16, 48]
	ldr	q0, [sp, 848]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [sp, 848]
	.p2align 3,,7
.L465:
	add	x17, x17, 1
	add	x15, x15, x27
	add	x16, x16, x25
	cmp	w19, w17
	ble	.L677
.L466:
	ldr	d0, [x11, x17, lsl 3]
	cmp	w8, 1
	beq	.L504
	ldr	q2, [x16]
	sxtw	x1, w21
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w18, 1
	bhi	.L678
.L464:
	cmp	w14, w21
	beq	.L465
.L463:
	add	x2, x1, x15
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
	b	.L465
.L504:
	mov	x1, 0
	b	.L463
.L500:
	mov	w1, 0
	b	.L453
.L501:
	ldr	w1, [sp, 252]
	b	.L456
.L675:
	mov	x17, 0
	mov	w2, 0
	b	.L457
.L505:
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
	b	.L469
.L673:
	mov	w21, w13
	mov	x24, x18
	mov	w13, w26
	mov	x23, x22
	mov	w25, w19
.L442:
	ldr	w0, [sp, 464]
	ldr	w1, [sp, 628]
	cmp	w0, w1
	beq	.L654
	ldr	w0, [sp, 360]
	add	w13, w13, 64
	cmp	w0, w13
	ble	.L679
.L437:
	ldr	w0, [sp, 464]
	add	w0, w0, 1
	str	w0, [sp, 464]
	b	.L365
.L670:
	ldr	w0, [sp, 792]
	cmp	w8, w0
	ble	.L439
	ldr	x15, [sp, 592]
	mov	w23, w13
	ldr	w0, [sp, 252]
	mov	x21, x1
	mov	w14, w8
	str	x18, [sp, 160]
	sub	w20, w19, w0
	mov	x18, x15
	mov	w15, w26
	str	x2, [sp, 176]
	str	w19, [sp, 184]
	mov	x19, x12
	b	.L474
.L472:
	bl	update4x32_sve
	add	x18, x18, 256
	add	w0, w15, 63
	add	w9, w15, 32
	cmp	w14, w0
	ble	.L680
.L475:
	mov	w15, w9
.L474:
	ldr	x0, [x19, 16]
	asr	w3, w15, 3
	ldr	x1, [sp, 344]
	sbfiz	x3, x3, 14, 32
	ldr	x11, [x0]
	add	x6, x18, x1
	ldr	w7, [sp, 148]
	mov	w0, w20
	ldr	w2, [sp, 248]
	add	x3, x11, x3
	mov	x1, x21
	mov	w5, 2048
	mov	w4, 8
	cbnz	x11, .L472
	ldr	w4, [sp, 148]
	mov	x3, x18
	ldr	w2, [sp, 248]
	mov	w5, 8
	ldr	x0, [sp, 344]
	mov	w7, w4
	add	x6, x18, x0
	mov	w0, w20
	bl	update4x32_sve
	add	x18, x18, 256
	add	w0, w15, 63
	add	w9, w15, 32
	cmp	w14, w0
	bgt	.L475
.L680:
	ldr	x18, [sp, 160]
	mov	x1, x21
	ldr	x2, [sp, 176]
	mov	x12, x19
	ldr	w21, [sp, 576]
	mov	w13, w23
	ldr	w19, [sp, 184]
	mov	w8, w14
	b	.L439
.L669:
	sub	w1, w0, w21
	cmp	w1, 15
	ble	.L369
	ldr	w2, [sp, 148]
	sub	w1, w10, w13
	sub	w6, w1, #32
	add	w7, w13, 32
	add	w8, w13, 31
	and	w1, w6, -32
	add	w1, w1, w7
	cmp	w10, w8
	smull	x14, w21, w2
	ldr	w2, [sp, 248]
	ldr	x3, [sp, 272]
	csel	w18, w13, w1, le
	ldr	x1, [sp, 168]
	smull	x11, w2, w21
	sub	x2, x3, x14
	add	x3, x3, w13, sxtw
	add	x1, x11, x1
	mov	x26, x23
	lsl	x4, x2, 3
	neg	x2, x2, lsl 3
	add	x1, x28, x1, lsl 3
	stp	x1, x2, [sp, 280]
	add	x1, x24, x3, lsl 3
	ldr	w23, [sp, 364]
	mov	x27, x14
	str	x1, [sp, 480]
	ldr	w1, [sp, 252]
	str	w6, [sp, 552]
	mov	x6, x14
	mov	x14, x11
	sub	w1, w25, w1
	str	x4, [sp, 296]
	sxtw	x4, w18
	str	w1, [sp, 304]
	str	w13, [sp, 312]
	str	w0, [sp, 320]
	str	w18, [sp, 344]
	str	x4, [sp, 504]
	str	w21, [sp, 528]
	str	w8, [sp, 536]
	str	w7, [sp, 544]
.L406:
	ldr	w0, [sp, 536]
	cmp	w10, w0
	ble	.L371
	ldr	x9, [sp, 168]
	add	w2, w21, 4
	ldr	w7, [sp, 148]
	add	w1, w21, 8
	ldr	w18, [sp, 248]
	add	w0, w21, 12
	ldr	w3, [sp, 552]
	ldr	w4, [sp, 544]
	and	w3, w3, -32
	smull	x5, w0, w7
	ldr	x8, [sp, 272]
	add	w3, w3, w4
	smull	x4, w2, w7
	str	w3, [sp, 192]
	smaddl	x2, w18, w2, x9
	ldr	w22, [sp, 312]
	smull	x3, w1, w7
	sub	x4, x4, x8
	smaddl	x1, w18, w1, x9
	sub	x5, x5, x8
	smaddl	x0, w18, w0, x9
	sub	x3, x3, x8
	add	x2, x28, x2, lsl 3
	mov	w19, w22
	add	x1, x28, x1, lsl 3
	mov	x22, x14
	ldr	x15, [sp, 480]
	lsl	x4, x4, 3
	add	x0, x28, x0, lsl 3
	mov	w14, w7
	str	x2, [sp, 160]
	lsl	x2, x3, 3
	str	x1, [sp, 176]
	lsl	x1, x5, 3
	str	x0, [sp, 184]
	str	x1, [sp, 200]
	str	x2, [sp, 208]
	str	x4, [sp, 216]
	str	w10, [sp, 224]
	str	x24, [sp, 232]
	str	x28, [sp, 424]
	str	w21, [sp, 472]
	ldr	w21, [sp, 304]
	str	x6, [sp, 576]
	b	.L434
.L435:
	ldp	x1, x0, [sp, 280]
	mov	w7, w14
	mov	w5, w24
	mov	w4, w28
	mov	x3, x20
	mov	w2, w18
	add	w19, w19, 32
	add	x6, x15, x0
	mov	w0, w21
	bl	update4x32_sve
	ldr	x1, [sp, 160]
	mov	w7, w14
	ldr	x0, [sp, 216]
	mov	w5, w24
	mov	w4, w28
	mov	x3, x20
	add	x6, x15, x0
	mov	w2, w18
	mov	w0, w21
	bl	update4x32_sve
	ldr	x1, [sp, 176]
	mov	w7, w14
	ldr	x0, [sp, 208]
	mov	w5, w24
	mov	w4, w28
	mov	x3, x20
	add	x6, x15, x0
	mov	w2, w18
	mov	w0, w21
	bl	update4x32_sve
	ldr	x1, [sp, 184]
	mov	w7, w14
	ldr	x0, [sp, 200]
	mov	w5, w24
	mov	w4, w28
	mov	x3, x20
	add	x6, x15, x0
	mov	w2, w18
	mov	w0, w21
	bl	update4x32_sve
	ldr	w0, [sp, 192]
	add	x15, x15, 256
	cmp	w19, w0
	beq	.L681
.L434:
	ldr	x0, [sp, 256]
	asr	w20, w19, 3
	mov	w28, 8
	mov	w24, 2048
	sbfiz	x20, x20, 14, 32
	ldr	x0, [x0, 16]
	ldr	x0, [x0]
	add	x20, x0, x20
	cbnz	x0, .L435
	mov	x20, x15
	mov	w28, w14
	mov	w24, 8
	b	.L435
.L681:
	ldr	x24, [sp, 232]
	mov	x14, x22
	ldr	x28, [sp, 424]
	ldr	x6, [sp, 576]
	ldr	w10, [sp, 224]
	ldr	w21, [sp, 472]
.L371:
	ldr	w0, [sp, 344]
	cmp	w10, w0
	ble	.L412
	ldr	x1, [sp, 504]
	str	x14, [sp, 424]
	ldr	x2, [sp, 128]
	add	x0, x6, x1
	add	x13, x1, x27
	ldr	w20, [sp, 344]
	ldr	x1, [sp, 280]
	add	x15, x24, x0, lsl 3
	ldr	x22, [sp, 152]
	add	x1, x1, x2
	str	x1, [sp, 472]
	str	w21, [sp, 576]
	str	x6, [sp, 592]
	str	x27, [sp, 720]
	mov	x27, x26
	b	.L411
.L409:
	ldr	x1, [sp, 280]
	mov	x5, x15
	ldr	w6, [sp, 148]
	add	w20, w20, 8
	ldr	w2, [sp, 248]
	ldr	w0, [sp, 304]
	str	x15, [sp, 160]
	str	w10, [sp, 176]
	str	x13, [sp, 184]
	bl	update16x8_sve
	ldr	x15, [sp, 160]
	ldr	x13, [sp, 184]
	add	x15, x15, 64
	ldr	w10, [sp, 176]
	add	x13, x13, 8
	cmp	w10, w20
	ble	.L682
.L411:
	ldr	x0, [sp, 256]
	sub	w6, w10, w20
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L683
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L431:
	cmp	w6, 7
	bgt	.L409
	lsl	x0, x8, 4
	str	x0, [sp, 232]
	lsl	x0, x8, 1
	lsl	x7, x8, 3
	ldr	x19, [sp, 424]
	str	x0, [sp, 224]
	ldr	x5, [sp, 472]
	sub	w0, w6, #1
	movi	v4.4s, 0
	ldr	w18, [sp, 240]
	add	x17, x24, x13, lsl 3
	add	x30, x7, 16
	and	w21, w6, -4
	lsr	w4, w6, 1
	and	w11, w6, -2
	mov	x12, x13
	and	w9, w6, 1
	str	w0, [sp, 216]
	add	x0, sp, 800
	and	w1, w6, 3
	mov	w26, 16
	str	w1, [sp, 160]
	str	w10, [sp, 756]
	str	x13, [sp, 760]
	str	x15, [sp, 768]
	str	w20, [sp, 792]
	.p2align 3,,7
.L415:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w25, w18
	ble	.L414
	ldr	w1, [sp, 136]
	cmp	w1, w23
	ble	.L496
	ldr	x1, [sp, 128]
	mov	x10, x3
	mov	x16, x8
	mov	x15, 0
	sub	x20, x5, x1
	mov	w1, w23
	stp	x24, x27, [sp, 176]
	str	w4, [sp, 192]
	str	w11, [sp, 200]
	str	x5, [sp, 208]
	b	.L424
	.p2align 2,,3
.L497:
	mov	w1, w2
.L424:
	ldr	w2, [sp, 216]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x5, x4, x19
	cmp	w2, 2
	bls	.L684
	ldp	q1, q2, [x10]
	mov	w11, w21
	ldr	q5, [x10, x30]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 800]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x28, x5, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w5, [sp, 160]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 800]
	cbz	w5, .L429
.L430:
	uxtw	x5, w11
	add	x24, x4, x19
	add	x14, x5, x15
	add	x13, x5, x16
	sub	w11, w6, w11
	lsl	x5, x5, 3
	mov	x4, x24
	lsl	x14, x14, 3
	lsl	x13, x13, 3
	and	w27, w11, -2
	cmp	w11, 1
	beq	.L422
	ldr	q1, [x3, x14]
	add	w2, w2, w27
	ldr	q2, [x0, x5]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x5]
	ldr	d3, [x28, x24, lsl 3]
	ldr	q2, [x3, x13]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x5]
	tbz	x11, 0, .L429
.L422:
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
.L429:
	ldr	x4, [sp, 232]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x10, x10, x4
	ldr	x4, [sp, 224]
	add	x15, x15, x4
	add	x16, x16, x4
	ldr	w4, [sp, 136]
	cmp	w2, w4
	blt	.L497
	ldp	x24, x27, [sp, 176]
	add	w1, w1, 1
	ldr	x5, [sp, 208]
	ldr	w4, [sp, 192]
	ldr	w11, [sp, 200]
.L420:
	sxtw	x13, w1
	ldr	x1, [sp, 168]
	sub	x14, x13, x1
	mul	x10, x8, x14
	madd	x14, x14, x7, x3
	.p2align 3,,7
.L428:
	ldr	d0, [x5, x13, lsl 3]
	cmp	w6, 1
	beq	.L498
	ldr	q2, [x14]
	sxtw	x1, w11
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w4, 1
	bls	.L426
	ldr	q2, [x14, 16]
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w4, 3
	bne	.L426
	ldr	q2, [x14, 32]
	ldr	q1, [sp, 832]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 832]
.L426:
	cbz	w9, .L427
.L425:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L427:
	add	x13, x13, 1
	add	x10, x10, x8
	add	x14, x14, x7
	cmp	w25, w13
	bgt	.L428
.L414:
	cmp	w6, 1
	beq	.L495
	ldr	q0, [x17]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17]
	cmp	w4, 1
	bls	.L418
	ldr	q0, [x17, 16]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 16]
	cmp	w4, 3
	bne	.L418
	ldr	q0, [x17, 32]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 32]
.L418:
	sxtw	x1, w11
	cbz	w9, .L419
.L417:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x24, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x24, x2, lsl 3]
.L419:
	ldr	x1, [sp, 120]
	add	x12, x12, x22
	add	x19, x19, x27
	subs	w26, w26, #1
	add	x17, x17, x1
	ldr	x1, [sp, 112]
	add	x5, x5, x1
	bne	.L415
	ldr	x13, [sp, 760]
	ldr	x15, [sp, 768]
	add	x13, x13, 8
	ldr	w20, [sp, 792]
	ldr	w10, [sp, 756]
	add	x15, x15, 64
	add	w20, w20, 8
	cmp	w10, w20
	bgt	.L411
.L682:
	ldr	x14, [sp, 424]
	mov	x26, x27
	ldr	x6, [sp, 592]
	ldr	x27, [sp, 720]
	ldr	w21, [sp, 576]
.L412:
	ldr	x2, [sp, 280]
	add	w21, w21, 16
	ldr	x3, [sp, 616]
	ldr	x1, [sp, 336]
	add	x2, x2, x3
	str	x2, [sp, 280]
	ldr	x2, [sp, 632]
	add	x6, x6, x1
	add	x27, x27, x1
	ldr	w0, [sp, 320]
	ldp	x1, x3, [sp, 288]
	add	x14, x14, x2
	ldr	x2, [sp, 696]
	sub	w0, w0, w21
	add	x3, x3, x2
	sub	x1, x1, x2
	stp	x1, x3, [sp, 288]
	cmp	w0, 15
	bgt	.L406
	mov	w19, w21
	ldr	w13, [sp, 312]
	ldr	w0, [sp, 320]
	mov	x23, x26
	ldr	w21, [sp, 528]
.L369:
	add	w1, w19, 7
	cmp	w0, w1
	ble	.L368
	ldr	w3, [sp, 148]
	sub	w1, w10, w13
	ldr	x8, [sp, 168]
	sub	w2, w1, #32
	add	w5, w13, 32
	add	w6, w13, 31
	smull	x11, w3, w19
	ldr	w3, [sp, 248]
	and	w1, w2, -32
	cmp	w10, w6
	add	w1, w1, w5
	ldr	w18, [sp, 364]
	csel	w1, w13, w1, le
	str	w0, [sp, 576]
	smull	x7, w3, w19
	sub	w3, w0, #8
	sub	w20, w3, w19
	str	x7, [sp, 424]
	ldr	x3, [sp, 272]
	add	x8, x7, x8
	add	w7, w19, 8
	mov	w0, w25
	sub	x4, x3, x11
	mov	w14, w2
	add	x9, x3, w13, sxtw
	and	w3, w20, -8
	add	w3, w3, w7
	str	w3, [sp, 504]
	lsl	x3, x4, 3
	str	x3, [sp, 344]
	add	x3, x28, x8, lsl 3
	str	x3, [sp, 192]
	add	x3, x24, x9, lsl 3
	str	x3, [sp, 536]
	ldr	w3, [sp, 252]
	mov	w26, w19
	mov	w15, w10
	neg	x22, x4, lsl 3
	sub	w3, w25, w3
	mov	x2, x11
	mov	x25, x28
	mov	x28, x23
	mov	w23, w0
	str	w21, [sp, 552]
	mov	x21, x11
	sxtw	x12, w1
	str	w3, [sp, 224]
	str	w13, [sp, 472]
	str	w1, [sp, 480]
	str	x12, [sp, 528]
	str	w20, [sp, 592]
	str	w6, [sp, 720]
	str	w5, [sp, 756]
	str	w7, [sp, 792]
.L374:
	ldr	w0, [sp, 720]
	cmp	w15, w0
	ble	.L404
	ldr	w3, [sp, 756]
	and	w1, w14, -32
	ldr	x4, [sp, 168]
	add	w1, w1, w3
	ldr	w3, [sp, 248]
	add	w0, w26, 4
	str	w1, [sp, 184]
	ldr	w1, [sp, 148]
	ldr	x19, [sp, 536]
	ldr	w27, [sp, 472]
	smull	x1, w0, w1
	mov	x20, x19
	smaddl	x0, w3, w0, x4
	mov	x19, x2
	ldr	x3, [sp, 272]
	add	x0, x25, x0, lsl 3
	str	x0, [sp, 160]
	sub	x1, x1, x3
	lsl	x0, x1, 3
	mov	x1, x21
	str	x0, [sp, 176]
	mov	w0, w18
	mov	w21, w14
	mov	w18, w15
	mov	x14, x22
	mov	w15, w27
	mov	x22, x1
	mov	w27, w0
	b	.L402
.L400:
	str	x8, [sp, 200]
	bl	update4x32_sve
	ldr	x0, [sp, 176]
	mov	w5, 2048
	ldr	x1, [sp, 160]
	add	x6, x0, x20
	ldr	x8, [sp, 200]
	mov	w4, 8
	ldr	w0, [sp, 224]
	add	w15, w15, 32
	ldr	w7, [sp, 148]
	mov	x3, x8
	ldr	w2, [sp, 248]
	add	x20, x20, 256
	bl	update4x32_sve
	ldr	w0, [sp, 184]
	cmp	w15, w0
	beq	.L685
.L402:
	ldr	x0, [sp, 256]
	asr	w8, w15, 3
	ldr	x1, [sp, 192]
	sbfiz	x8, x8, 14, 32
	ldr	x0, [x0, 16]
	add	x6, x20, x14
	ldr	w7, [sp, 148]
	mov	w5, 2048
	ldr	w2, [sp, 248]
	mov	w4, 8
	ldr	x12, [x0]
	ldr	w0, [sp, 224]
	add	x8, x12, x8
	mov	x3, x8
	cbnz	x12, .L400
	mov	x4, x7
	mov	x3, x20
	mov	w5, 8
	str	w7, [sp, 148]
	bl	update4x32_sve
	add	w15, w15, 32
	ldr	x1, [sp, 176]
	mov	x3, x20
	ldr	w4, [sp, 148]
	mov	w5, 8
	add	x6, x1, x20
	ldr	w0, [sp, 224]
	ldr	x1, [sp, 160]
	mov	w7, w4
	ldr	w2, [sp, 248]
	add	x20, x20, 256
	bl	update4x32_sve
	ldr	w0, [sp, 184]
	cmp	w15, w0
	bne	.L402
.L685:
	mov	x0, x22
	mov	w15, w18
	mov	x22, x14
	mov	x2, x19
	mov	w14, w21
	mov	w18, w27
	mov	x21, x0
.L404:
	ldr	w0, [sp, 480]
	cmp	w15, w0
	ble	.L380
	ldr	x1, [sp, 528]
	str	w26, [sp, 760]
	ldr	x3, [sp, 128]
	add	x10, x1, x2
	add	x0, x1, x21
	mov	x26, x10
	ldr	x1, [sp, 192]
	add	x13, x24, x0, lsl 3
	ldr	w20, [sp, 480]
	mov	x10, x21
	add	x1, x1, x3
	str	x1, [sp, 544]
	str	x2, [sp, 768]
	str	x22, [sp, 776]
	mov	x22, x28
	mov	w28, w18
	str	w14, [sp, 784]
	b	.L379
.L377:
	ldr	x1, [sp, 192]
	mov	x5, x13
	ldr	w6, [sp, 148]
	add	w20, w20, 8
	ldr	w0, [sp, 224]
	add	x26, x26, 8
	ldr	w2, [sp, 248]
	str	x13, [sp, 160]
	str	w15, [sp, 176]
	str	x10, [sp, 184]
	bl	update8x8_sve
	ldr	x13, [sp, 160]
	ldr	w15, [sp, 176]
	ldr	x10, [sp, 184]
	add	x13, x13, 64
	cmp	w15, w20
	ble	.L686
.L379:
	ldr	x0, [sp, 256]
	sub	w5, w15, w20
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L687
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L399:
	cmp	w5, 7
	bgt	.L377
	ldr	x6, [sp, 544]
	lsl	x0, x8, 4
	lsl	x18, x8, 1
	lsl	x7, x8, 3
	ldr	x19, [sp, 424]
	lsr	w4, w5, 1
	and	w9, w5, 1
	and	w1, w5, 3
	movi	v4.4s, 0
	ldr	w30, [sp, 240]
	str	x6, [sp, 160]
	mov	x6, x13
	mov	x13, x18
	ldr	w18, [sp, 136]
	str	x0, [sp, 216]
	sub	w0, w5, #1
	add	x14, x24, x26, lsl 3
	mov	x12, x26
	add	x27, x7, 16
	and	w21, w5, -4
	and	w11, w5, -2
	str	w4, [sp, 176]
	mov	w4, w20
	str	w9, [sp, 184]
	mov	x9, x10
	str	x8, [sp, 200]
	mov	x8, x26
	mov	w26, w1
	str	w0, [sp, 208]
	add	x0, sp, 800
	mov	w17, 8
	str	w15, [sp, 796]
.L383:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w23, w30
	ble	.L382
	cmp	w18, w28
	ble	.L492
	ldr	x2, [sp, 128]
	mov	x10, x3
	ldr	x1, [sp, 160]
	mov	x15, 0
	ldr	x16, [sp, 200]
	sub	x20, x1, x2
	mov	w1, w28
	str	x24, [sp, 232]
	stp	x22, x14, [sp, 280]
	str	w4, [sp, 296]
	str	x6, [sp, 304]
	str	w11, [sp, 312]
	str	x8, [sp, 320]
	b	.L392
.L493:
	mov	w1, w2
.L392:
	ldr	w2, [sp, 208]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x6, x4, x19
	cmp	w2, 2
	bls	.L688
	ldp	q1, q2, [x10]
	mov	w8, w21
	ldr	q5, [x10, x27]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 800]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x25, x6, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 800]
	cbz	w26, .L397
.L398:
	uxtw	x6, w8
	add	x22, x4, x19
	add	x14, x15, x6
	add	x11, x16, x6
	sub	w8, w5, w8
	lsl	x6, x6, 3
	mov	x4, x22
	lsl	x14, x14, 3
	lsl	x11, x11, 3
	and	w24, w8, -2
	cmp	w8, 1
	beq	.L390
	ldr	q1, [x3, x14]
	add	w2, w2, w24
	ldr	q2, [x0, x6]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x6]
	ldr	d3, [x25, x22, lsl 3]
	ldr	q2, [x3, x11]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x6]
	tbz	x8, 0, .L397
.L390:
	sxtw	x2, w2
	ldr	d3, [x25, x4, lsl 3]
	add	x6, x2, x15
	add	x4, x2, x16
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x6, lsl 3]
	ldr	d1, [x3, x4, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
.L397:
	ldr	x4, [sp, 216]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x15, x15, x13
	add	x16, x16, x13
	add	x10, x10, x4
	cmp	w2, w18
	blt	.L493
	ldp	x22, x14, [sp, 280]
	add	w1, w1, 1
	ldr	x24, [sp, 232]
	ldr	x6, [sp, 304]
	ldr	x8, [sp, 320]
	ldr	w4, [sp, 296]
	ldr	w11, [sp, 312]
.L388:
	sxtw	x15, w1
	ldr	w20, [sp, 176]
	ldr	x1, [sp, 168]
	str	w21, [sp, 232]
	ldr	x21, [sp, 160]
	sub	x16, x15, x1
	ldr	x1, [sp, 200]
	stp	x24, x25, [sp, 280]
	ldr	w25, [sp, 184]
	mov	x24, x1
	mul	x10, x16, x1
	madd	x16, x16, x7, x3
	.p2align 3,,7
.L396:
	ldr	d0, [x21, x15, lsl 3]
	cmp	w5, 1
	beq	.L494
	ldr	q2, [x16]
	sxtw	x1, w11
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w20, 1
	bls	.L394
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w20, 3
	bne	.L394
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 832]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 832]
.L394:
	cbz	w25, .L395
.L393:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L395:
	add	x15, x15, 1
	add	x10, x10, x24
	add	x16, x16, x7
	cmp	w23, w15
	bgt	.L396
	ldp	x24, x25, [sp, 280]
	ldr	w21, [sp, 232]
.L382:
	cmp	w5, 1
	beq	.L491
	ldr	q0, [x14]
	ldr	q1, [sp, 800]
	ldr	w1, [sp, 176]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14]
	cmp	w1, 1
	bls	.L386
	ldr	q0, [x14, 16]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 16]
	cmp	w1, 3
	bne	.L386
	ldr	q0, [x14, 32]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 32]
.L386:
	ldr	w1, [sp, 184]
	cbz	w1, .L387
	sxtw	x1, w11
.L385:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x24, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x24, x2, lsl 3]
.L387:
	ldr	x1, [sp, 152]
	add	x19, x19, x22
	ldr	x2, [sp, 112]
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	subs	w17, w17, #1
	add	x14, x14, x1
	ldr	x1, [sp, 160]
	add	x1, x1, x2
	str	x1, [sp, 160]
	bne	.L383
	mov	w20, w4
	ldr	w15, [sp, 796]
	mov	x13, x6
	mov	x26, x8
	add	w20, w20, 8
	mov	x10, x9
	add	x13, x13, 64
	add	x26, x26, 8
	cmp	w15, w20
	bgt	.L379
.L686:
	ldr	x2, [sp, 768]
	mov	w18, w28
	ldr	w26, [sp, 760]
	mov	x28, x22
	ldr	x22, [sp, 776]
	mov	x21, x10
	ldr	w14, [sp, 784]
.L380:
	ldr	x1, [sp, 192]
	add	w26, w26, 8
	ldr	x3, [sp, 600]
	ldr	x0, [sp, 120]
	add	x1, x1, x3
	ldr	x3, [sp, 112]
	str	x1, [sp, 192]
	ldr	x1, [sp, 424]
	add	x21, x21, x0
	add	x2, x2, x0
	ldr	w0, [sp, 504]
	add	x1, x1, x3
	str	x1, [sp, 424]
	ldr	x3, [sp, 344]
	ldr	x1, [sp, 704]
	add	x3, x3, x1
	str	x3, [sp, 344]
	sub	x22, x22, x1
	cmp	w26, w0
	bne	.L374
	ldr	w20, [sp, 592]
	mov	w1, w23
	ldr	w7, [sp, 792]
	mov	x23, x28
	and	w20, w20, -8
	mov	x28, x25
	ldr	w13, [sp, 472]
	mov	w10, w15
	ldr	w21, [sp, 552]
	mov	w25, w1
	ldr	w0, [sp, 576]
	add	w19, w20, w7
	b	.L368
	.p2align 2,,3
.L498:
	mov	x1, 0
	b	.L425
.L495:
	mov	x1, 0
	b	.L417
.L496:
	ldr	w1, [sp, 252]
	b	.L420
.L684:
	mov	w11, 0
	mov	w2, 0
	b	.L430
.L683:
	ldr	x0, [sp, 296]
	mov	x8, x22
	ldr	w4, [sp, 148]
	add	x3, x15, x0
	b	.L431
.L494:
	mov	x1, 0
	b	.L393
.L491:
	mov	x1, 0
	b	.L385
.L492:
	ldr	w1, [sp, 252]
	b	.L388
.L687:
	ldr	x0, [sp, 344]
	ldr	x8, [sp, 152]
	add	x3, x0, x13
	ldr	w4, [sp, 148]
	b	.L399
.L688:
	mov	w8, 0
	mov	w2, 0
	b	.L398
.L679:
	ldr	w0, [sp, 264]
	add	w21, w21, 64
	mov	w13, 0
	sub	w0, w0, w21
	str	w0, [sp, 520]
	b	.L437
.L654:
	ldr	d8, [sp, 96]
	.cfi_restore 72
	mov	x19, x28
	ldr	x20, [sp, 744]
	mov	x22, x23
	ldr	w25, [sp, 736]
	ldr	w24, [sp, 740]
	ldr	w21, [sp, 752]
	b	.L363
.L665:
	ldp	x19, x20, [sp, 16]
	.cfi_restore 20
	.cfi_restore 19
	ldp	x21, x22, [sp, 32]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
.L299:
	ldp	x29, x30, [sp]
	ldp	x23, x24, [sp, 48]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 1056
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
.L364:
	.cfi_def_cfa_offset 1056
	.cfi_offset 19, -1040
	.cfi_offset 20, -1032
	.cfi_offset 21, -1024
	.cfi_offset 22, -1016
	.cfi_offset 23, -1008
	.cfi_offset 24, -1000
	.cfi_offset 25, -992
	.cfi_offset 26, -984
	.cfi_offset 27, -976
	.cfi_offset 28, -968
	.cfi_offset 29, -1056
	.cfi_offset 30, -1048
	add	w1, w1, 1
	mov	w0, 0
	b	.L479
.L663:
	str	d8, [sp, 96]
	.cfi_offset 72, -960
	b	.L482
.L486:
	mov	w10, 0
	b	.L347
	.p2align 2,,3
.L481:
	.cfi_restore 72
	bl	GOMP_barrier
	b	.L363
	.cfi_endproc
.LFE4375:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4374:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L698
	stp	x29, x30, [sp, -144]!
	.cfi_def_cfa_offset 144
	.cfi_offset 29, -144
	.cfi_offset 30, -136
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -128
	.cfi_offset 20, -120
	mov	w19, w0
	sxtw	x0, w0
	mov	w20, w1
	mov	x1, 1
	stp	x21, x22, [sp, 32]
	movk	x1, 0x100, lsl 16
	madd	x0, x0, x0, x0
	stp	x23, x24, [sp, 48]
	.cfi_offset 21, -112
	.cfi_offset 22, -104
	.cfi_offset 23, -96
	.cfi_offset 24, -88
	mov	x22, x2
	mov	w23, w3
	mov	x24, x4
	mov	w21, w5
	cmp	x0, x1
	bls	.L691
	sxtw	x2, w20
	add	x0, sp, 80
	add	x2, x2, 7
	mov	x1, 64
	str	xzr, [sp, 88]
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L692
	ldr	x0, [sp, 80]
	str	x0, [sp, 88]
.L692:
	mov	x0, 16
	bl	getauxval
	add	x5, sp, 88
	ubfx	w4, w0, 22, 1
	adrp	x1, solve_blocked._omp_fn.0
	mov	w3, 0
	add	x0, x1, :lo12:solve_blocked._omp_fn.0
	mov	w2, 0
	add	x1, sp, 96
	stp	x22, x24, [sp, 96]
	str	x5, [sp, 112]
	stp	w19, w20, [sp, 120]
	stp	w23, w21, [sp, 128]
	str	w4, [sp, 136]
	bl	GOMP_parallel
	ldr	x0, [sp, 88]
	bl	free
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 144
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
.L698:
	ret
	.p2align 2,,3
.L691:
	.cfi_def_cfa_offset 144
	.cfi_offset 19, -128
	.cfi_offset 20, -120
	.cfi_offset 21, -112
	.cfi_offset 22, -104
	.cfi_offset 23, -96
	.cfi_offset 24, -88
	.cfi_offset 29, -144
	.cfi_offset 30, -136
	mov	x0, 16
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -72
	.cfi_offset 25, -80
	bl	getauxval
	str	xzr, [sp, 80]
	tst	w0, 4194304
	asr	w26, w19, 4
	ubfx	w25, w0, 22, 1
	ccmp	w19, 31, 4, ne
	ble	.L694
	sxtw	x0, w26
	sub	x2, x0, #1
	mul	x2, x2, x0
	lsl	x2, x2, 10
	cmp	x2, 4194304
	bhi	.L701
	add	x0, sp, 88
	mov	x1, 64
	bl	posix_memalign
	cbnz	w0, .L694
	ldr	x0, [sp, 88]
	str	x0, [sp, 80]
.L694:
	add	x4, sp, 80
	add	x1, sp, 96
	mov	w3, 0
	mov	w2, 0
	adrp	x0, solve_panel._omp_fn.0
	add	x0, x0, :lo12:solve_panel._omp_fn.0
	stp	x22, x24, [sp, 96]
	str	x4, [sp, 112]
	stp	w19, w20, [sp, 120]
	stp	w23, w21, [sp, 128]
	stp	w25, w26, [sp, 136]
	bl	GOMP_parallel
	ldr	x0, [sp, 80]
	bl	free
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	.cfi_remember_state
	.cfi_restore 26
	.cfi_restore 25
	ldp	x29, x30, [sp], 144
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
.L701:
	.cfi_restore_state
	mov	x0, 16
	bl	getauxval
	tst	x20, 15
	asr	w4, w20, 4
	ubfx	w5, w0, 22, 1
	cinc	w4, w4, ne
	adrp	x1, solve_panel_wide8x16._omp_fn.0
	mov	w3, 0
	add	x0, x1, :lo12:solve_panel_wide8x16._omp_fn.0
	mov	w2, 0
	add	x1, sp, 96
	stp	x22, x24, [sp, 96]
	stp	w19, w20, [sp, 112]
	stp	w23, w21, [sp, 120]
	stp	w5, w4, [sp, 128]
	bl	GOMP_parallel
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x29, x30, [sp], 144
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
	.cfi_endproc
.LFE4374:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (gcc for openEuler 3.0.2) 12.3.1"
	.section	.note.GNU-stack,"",@progbits
