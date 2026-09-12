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
	.type	update8x16_sve, %function
update8x16_sve:
.LFB4369:
	.cfi_startproc
	stp	d8, d9, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 72, -16
	.cfi_offset 73, -8
	cmp	w0, 0
	ble	.L21
	sxtw	x9, w2
	mov	w8, 6
	sbfiz	x11, x2, 1, 32
	mov	z17.d, #0
	lsl	x10, x9, 3
	lsl	x12, x9, 2
	smull	x2, w2, w8
	add	x13, x12, x9
	add	x8, x1, w0, sxtw 3
	sbfiz	x0, x5, 3, 32
	sub	x5, x10, x9
	add	x10, x11, x9
	ptrue	p0.b, all
	mov	z18.d, z17.d
	mov	z19.d, z17.d
	mov	z20.d, z17.d
	mov	z21.d, z17.d
	mov	z22.d, z17.d
	mov	z23.d, z17.d
	mov	z24.d, z17.d
	mov	z25.d, z17.d
	mov	z26.d, z17.d
	mov	z27.d, z17.d
	mov	z28.d, z17.d
	mov	z29.d, z17.d
	mov	z30.d, z17.d
	mov	z31.d, z17.d
	mov	z8.d, z17.d
	.p2align 3,,7
.L20:
	ldr	d16, [x1, x9, lsl 3]
	ptrue	p1.b, all
	ldr	d7, [x1, x11, lsl 3]
	ld1rd	z9.d, p1/z, [x1]
	ldr	d6, [x1, x10, lsl 3]
	ld1d	z1.d, p0/z, [x3]
	ldr	d5, [x1, x12, lsl 3]
	ld1d	z0.d, p0/z, [x4]
	ldr	d4, [x1, x13, lsl 3]
	mov	z16.d, d16
	ldr	d3, [x1, x2, lsl 3]
	mov	z7.d, d7
	ldr	d2, [x1, x5, lsl 3]
	add	x1, x1, 8
	mov	z6.d, d6
	mov	z5.d, d5
	mov	z4.d, d4
	mov	z3.d, d3
	mov	z2.d, d2
	add	x3, x3, x0
	add	x4, x4, x0
	fmla	z8.d, p0/m, z1.d, z9.d
	fmla	z31.d, p0/m, z0.d, z9.d
	fmla	z30.d, p0/m, z1.d, z16.d
	fmla	z29.d, p0/m, z0.d, z16.d
	fmla	z28.d, p0/m, z1.d, z7.d
	fmla	z27.d, p0/m, z0.d, z7.d
	fmla	z26.d, p0/m, z1.d, z6.d
	fmla	z25.d, p0/m, z0.d, z6.d
	fmla	z24.d, p0/m, z1.d, z5.d
	fmla	z23.d, p0/m, z0.d, z5.d
	fmla	z22.d, p0/m, z1.d, z4.d
	fmla	z21.d, p0/m, z0.d, z4.d
	fmla	z20.d, p0/m, z1.d, z3.d
	fmla	z19.d, p0/m, z0.d, z3.d
	fmla	z18.d, p0/m, z1.d, z2.d
	fmla	z17.d, p0/m, z0.d, z2.d
	cmp	x8, x1
	bne	.L20
.L19:
	ptrue	p0.b, all
	ld1d	z0.d, p0/z, [x6]
	fsub	z0.d, z0.d, z8.d
	st1d	z0.d, p0, [x6]
	sbfiz	x1, x7, 3, 32
	add	x0, x6, 64
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z31.d
	st1d	z0.d, p0, [x0]
	add	x4, x1, 64
	add	x0, x6, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z30.d
	st1d	z0.d, p0, [x0]
	mov	x3, 64
	add	x4, x6, x4
	mov	w2, 24
	ld1d	z0.d, p0/z, [x4]
	fsub	z0.d, z0.d, z29.d
	st1d	z0.d, p0, [x4]
	add	x0, x0, x1
	add	x4, x3, w7, sxtw 4
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z28.d
	st1d	z0.d, p0, [x0]
	add	x4, x6, x4
	smaddl	x2, w7, w2, x3
	ld1d	z0.d, p0/z, [x4]
	mov	w5, 32
	fsub	z0.d, z0.d, z27.d
	st1d	z0.d, p0, [x4]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z26.d
	st1d	z0.d, p0, [x0]
	add	x2, x6, x2
	smaddl	x5, w7, w5, x3
	ld1d	z0.d, p0/z, [x2]
	mov	w4, 40
	fsub	z0.d, z0.d, z25.d
	st1d	z0.d, p0, [x2]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z24.d
	st1d	z0.d, p0, [x0]
	add	x5, x6, x5
	smaddl	x4, w7, w4, x3
	ld1d	z0.d, p0/z, [x5]
	mov	w2, 48
	fsub	z0.d, z0.d, z23.d
	st1d	z0.d, p0, [x5]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z22.d
	st1d	z0.d, p0, [x0]
	add	x4, x6, x4
	smaddl	x2, w7, w2, x3
	ld1d	z0.d, p0/z, [x4]
	mov	w5, 56
	fsub	z0.d, z0.d, z21.d
	st1d	z0.d, p0, [x4]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z20.d
	st1d	z0.d, p0, [x0]
	add	x2, x6, x2
	smaddl	x7, w7, w5, x3
	ld1d	z0.d, p0/z, [x2]
	fsub	z0.d, z0.d, z19.d
	st1d	z0.d, p0, [x2]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z18.d
	st1d	z0.d, p0, [x0]
	add	x6, x6, x7
	ld1d	z0.d, p0/z, [x6]
	fsub	z0.d, z0.d, z17.d
	st1d	z0.d, p0, [x6]
	ldp	d8, d9, [sp], 16
	.cfi_remember_state
	.cfi_restore 73
	.cfi_restore 72
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L21:
	.cfi_restore_state
	mov	z17.d, #0
	mov	z18.d, z17.d
	mov	z19.d, z17.d
	mov	z20.d, z17.d
	mov	z21.d, z17.d
	mov	z22.d, z17.d
	mov	z23.d, z17.d
	mov	z24.d, z17.d
	mov	z25.d, z17.d
	mov	z26.d, z17.d
	mov	z27.d, z17.d
	mov	z28.d, z17.d
	mov	z29.d, z17.d
	mov	z30.d, z17.d
	mov	z31.d, z17.d
	mov	z8.d, z17.d
	b	.L19
	.cfi_endproc
.LFE4369:
	.size	update8x16_sve, .-update8x16_sve
	.align	2
	.p2align 4,,11
	.type	update4x8_sve, %function
update4x8_sve:
.LFB4366:
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
.LFE4366:
	.size	update4x8_sve, .-update4x8_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4372:
	.cfi_startproc
	sub	sp, sp, #1040
	.cfi_def_cfa_offset 1040
	stp	x29, x30, [sp]
	.cfi_offset 29, -1040
	.cfi_offset 30, -1032
	mov	x29, sp
	ldr	w2, [x0, 24]
	ldr	w1, [x0, 40]
	str	w2, [sp, 268]
	ldr	w2, [x0, 28]
	stp	x23, x24, [sp, 48]
	stp	x27, x28, [sp, 80]
	.cfi_offset 23, -992
	.cfi_offset 24, -984
	.cfi_offset 27, -960
	.cfi_offset 28, -952
	ldp	x23, x28, [x0]
	str	x0, [sp, 256]
	str	w2, [sp, 360]
	ldp	w2, w0, [x0, 32]
	str	w0, [sp, 156]
	str	w2, [sp, 264]
	str	w1, [sp, 488]
	cbz	w1, .L202
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 488]
.L202:
	ldr	w0, [sp, 268]
	cmp	w0, 0
	ble	.L29
	stp	x19, x20, [sp, 16]
	.cfi_offset 20, -1016
	.cfi_offset 19, -1024
	mov	x19, x23
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -1000
	.cfi_offset 21, -1008
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -968
	.cfi_offset 25, -976
	bl	omp_get_num_threads
	mov	w22, w0
	bl	omp_get_thread_num
	mov	w26, w0
	ldr	w8, [sp, 360]
	mov	w3, 24
	ldrsw	x25, [sp, 264]
	adds	w2, w8, 7
	add	w1, w8, 14
	csel	w0, w1, w2, mi
	add	x17, x25, 1
	lsl	x11, x25, 1
	ldr	w5, [sp, 156]
	asr	w0, w0, 3
	lsl	x7, x17, 5
	lsl	x10, x17, 2
	str	x7, [sp, 608]
	sub	x7, x7, #32
	str	x7, [sp, 520]
	sdiv	w2, w0, w22
	sub	x7, x10, #4
	str	x7, [sp, 640]
	lsl	x7, x17, 11
	str	x7, [sp, 664]
	lsl	x7, x17, 8
	lsl	x6, x25, 3
	str	x7, [sp, 672]
	msub	w0, w2, w22, w0
	add	x7, x11, x25
	add	w1, w8, 63
	str	x6, [sp, 280]
	cmp	w26, w0
	str	x7, [sp, 496]
	cinc	w2, w2, lt
	add	x7, x23, x6
	add	x6, x6, 8
	str	x6, [sp, 440]
	lsl	x6, x25, 7
	sxtw	x4, w5
	asr	w1, w1, 6
	str	x6, [sp, 616]
	lsl	x6, x25, 4
	str	w1, [sp, 492]
	mul	w1, w2, w26
	str	x6, [sp, 600]
	lsl	x6, x25, 6
	smull	x3, w5, w3
	str	x6, [sp, 576]
	neg	x6, x4, lsl 7
	add	w0, w1, w0
	str	x3, [sp, 584]
	mov	w3, w5
	sbfiz	x5, x5, 3, 32
	str	x6, [sp, 680]
	neg	x6, x4, lsl 6
	csel	w1, w1, w0, lt
	add	x0, x5, 16
	str	x6, [sp, 688]
	lsl	x6, x4, 2
	str	x0, [sp, 376]
	add	x0, x5, 32
	str	x6, [sp, 560]
	add	w6, w2, w1
	str	x0, [sp, 384]
	add	x0, x5, 48
	sbfiz	x9, x3, 4, 32
	str	x5, [sp, 112]
	str	x4, [sp, 160]
	neg	x4, x4, lsl 5
	str	x9, [sp, 336]
	str	x7, [sp, 352]
	lsl	w7, w1, 3
	str	x11, [sp, 368]
	mov	w27, w7
	str	x0, [sp, 392]
	lsl	w0, w6, 3
	str	x25, [sp, 448]
	str	x10, [sp, 632]
	str	x4, [sp, 696]
	str	w0, [sp, 572]
	sub	w0, w8, w7
	str	w0, [sp, 624]
	sxtw	x0, w7
	str	x0, [sp, 648]
	add	x0, x9, 16
	str	x0, [sp, 400]
	add	x0, x9, 32
	str	x0, [sp, 408]
	add	x0, x9, 48
	str	xzr, [sp, 176]
	str	xzr, [sp, 320]
	str	x0, [sp, 416]
	sbfiz	x0, x3, 8, 32
	str	x23, [sp, 456]
	stp	xzr, x23, [sp, 464]
	str	w26, [sp, 532]
	mov	x26, x28
	str	w6, [sp, 536]
	str	w1, [sp, 540]
	str	x0, [sp, 656]
	str	x17, [sp, 704]
	b	.L91
.L384:
	add	w20, w1, 256
	ldr	w0, [sp, 536]
	ldr	w1, [sp, 540]
	cmp	w0, w1
	bgt	.L381
.L33:
	str	w7, [sp, 120]
	bl	GOMP_barrier
	ldr	w0, [sp, 268]
	ldr	w7, [sp, 120]
	cmp	w0, w20
	ble	.L93
	ldr	w0, [sp, 268]
	ldr	w1, [sp, 360]
	add	w0, w0, 63
	sub	w0, w0, w20
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L93
	ldr	w1, [sp, 492]
	ldr	w2, [sp, 532]
	mul	w0, w0, w1
	udiv	w1, w0, w22
	msub	w0, w1, w22, w0
	cmp	w2, w0
	bcc	.L94
.L201:
	ldr	w2, [sp, 532]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L382
.L93:
	bl	GOMP_barrier
	ldr	x0, [sp, 176]
	ldr	x2, [sp, 656]
	add	x1, x0, 256
	ldr	x0, [sp, 320]
	str	x1, [sp, 176]
	ldr	x3, [sp, 352]
	add	x0, x0, x2
	str	x0, [sp, 320]
	ldr	x0, [sp, 664]
	ldr	x4, [sp, 672]
	add	x3, x3, x0
	str	x3, [sp, 352]
	ldr	x3, [sp, 448]
	add	x3, x3, x4
	str	x3, [sp, 448]
	ldr	x3, [sp, 456]
	add	x3, x3, x0
	str	x3, [sp, 456]
	ldr	x3, [sp, 464]
	add	x2, x3, x2
	str	x2, [sp, 464]
	ldr	x2, [sp, 472]
	add	x0, x2, x0
	str	x0, [sp, 472]
	ldr	w0, [sp, 268]
	cmp	w0, w1
	ble	.L383
.L91:
	ldr	x1, [sp, 176]
	str	w1, [sp, 272]
	ldr	w0, [sp, 268]
	mov	w7, w1
	sub	w0, w0, w1
	cmp	w0, 255
	bgt	.L384
	ldr	w0, [sp, 536]
	ldr	w1, [sp, 540]
	cmp	w0, w1
	ble	.L203
	ldr	w20, [sp, 268]
	str	d8, [sp, 96]
	.cfi_offset 72, -944
.L204:
	ldr	x0, [sp, 464]
	sub	w30, w20, w7
	ldr	x15, [sp, 648]
	sub	w16, w30, #1
	ldr	x1, [sp, 280]
	add	x24, x15, x0
	ldr	x0, [sp, 352]
	mov	w28, w27
	ldr	w17, [sp, 176]
	mov	w5, w22
	ldr	w23, [sp, 624]
	mov	w2, w27
	mov	x13, x15
	sub	x18, x0, x1
	str	w30, [sp, 136]
.L37:
	ldr	x0, [sp, 256]
	cmp	w23, 8
	mov	w1, 8
	csel	w1, w23, w1, le
	ldr	x0, [x0, 16]
	ldr	x27, [x0]
	cbz	x27, .L385
	cmp	w28, 0
	add	w8, w28, 7
	csel	w8, w8, w28, lt
	ldr	w0, [sp, 136]
	asr	w8, w8, 3
	sbfiz	x22, x8, 14, 32
	sxtw	x8, w8
	add	x22, x27, x22
	cmp	w0, 0
	ble	.L38
	mov	w0, 7
	sub	w0, w0, w1
	mov	x3, x22
	sbfiz	x4, x1, 3, 32
	add	x0, x0, 1
	mov	x10, x22
	mov	w21, w20
	mov	x6, x22
	mov	x11, x24
	mov	x22, x4
	mov	x9, x16
	mov	x4, x27
	mov	w20, w7
	mov	w27, w5
	mov	x24, x13
	mov	x5, x25
	mov	w12, w17
	mov	x25, x19
	mov	x19, x3
	mov	w3, w2
	lsl	x0, x0, 3
	str	x0, [sp, 120]
.L87:
	cmp	w23, 0
	ble	.L58
.L57:
	ldr	w0, [sp, 156]
	smaddl	x1, w20, w0, x24
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
.L376:
	mov	x19, x25
	lsl	x0, x8, 8
	mov	x25, x5
	mov	w2, w3
	ldr	x30, [sp, 456]
	mov	w5, w27
	mov	x16, x9
	neg	x3, x25
	ldr	x9, [sp, 352]
	mov	x27, x4
	movi	v17.4s, 0
	ldr	w4, [sp, 136]
	str	x0, [sp, 144]
	mov	x13, x24
	ldr	x0, [sp, 448]
	mov	w20, w21
	mov	x22, x6
	mov	x21, x10
	mov	x24, x11
	mov	w17, w12
	add	w14, w7, 2
	mov	x1, x6
	str	x0, [sp, 120]
	add	x0, sp, 784
	str	x3, [sp, 184]
	add	x3, x19, 8
	str	x26, [sp, 208]
	mov	w26, w2
	str	x18, [sp, 128]
	str	x3, [sp, 192]
	mov	x3, 0
	str	w28, [sp, 200]
	str	w5, [sp, 216]
	stp	x16, x13, [sp, 224]
	str	w7, [sp, 240]
.L65:
	stp	q17, q17, [x0]
	stp	q17, q17, [x0, 32]
	stp	q17, q17, [x0, 64]
	stp	q17, q17, [x0, 96]
	stp	q17, q17, [x0, 128]
	stp	q17, q17, [x0, 160]
	stp	q17, q17, [x0, 192]
	stp	q17, q17, [x0, 224]
	cmp	w4, 3
	ble	.L386
	movi	v0.2d, 0
	cbz	w3, .L210
	ldr	x5, [sp, 128]
	add	x6, x22, x3, lsl 6
	ldr	x7, [sp, 368]
	mov	x2, x22
	ldr	x8, [sp, 496]
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
.L85:
	ldp	q5, q4, [x2]
	ldp	q3, q1, [x2, 32]
	add	x2, x2, 64
	ldr	d7, [x5, x25, lsl 3]
	ldr	d6, [x5, x7, lsl 3]
	ldr	d2, [x5, x8, lsl 3]
	fmla	v28.2d, v5.2d, v7.d[0]
	ld1r	{v16.2d}, [x5]
	fmla	v27.2d, v4.2d, v7.d[0]
	add	x5, x5, 8
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
	cmp	x2, x6
	bne	.L85
.L84:
	stp	q8, q31, [sp, 784]
	stp	q30, q29, [sp, 816]
	stp	q28, q27, [sp, 848]
	stp	q26, q25, [sp, 880]
	stp	q24, q23, [sp, 912]
	stp	q22, q21, [sp, 944]
	stp	q20, q19, [sp, 976]
	stp	q18, q0, [sp, 1008]
.L86:
	ldr	x2, [sp, 184]
	ldp	q4, q3, [x1]
	ldp	q2, q1, [x1, 32]
	ldp	q8, q7, [sp, 784]
	ldp	q6, q5, [sp, 816]
	fsub	v4.2d, v4.2d, v8.2d
	ldr	d0, [x9, x2, lsl 3]
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
	beq	.L75
	ldr	x2, [sp, 144]
	cmp	w4, 4
	ldr	x8, [sp, 120]
	add	x28, x3, x2
	add	x12, x28, 1
	add	x11, x28, 2
	mov	w2, 4
	mov	x5, x1
	csel	w7, w4, w2, le
	mov	x15, x9
	mov	x2, x0
	add	x12, x27, x12, lsl 6
	add	x11, x27, x11, lsl 6
	mov	w6, 1
	mov	w10, 0
	b	.L76
.L79:
	add	x2, x2, 64
	add	x8, x8, x25
	cmp	w6, 2
	beq	.L208
	ldp	q1, q0, [x1]
	mov	w10, 2
	ldr	d5, [x19, x8, lsl 3]
	ldp	q3, q2, [x2, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldr	x13, [sp, 192]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	ldr	d4, [x13, x8, lsl 3]
	ldp	q7, q6, [x2, 96]
	stp	q1, q0, [x2, 64]
	ldp	q3, q2, [x1, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x2, 64]
	ldp	q1, q0, [x1, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x2, 96]
	ldp	q3, q2, [x1, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x2, 96]
.L77:
	add	x5, x5, 64
	ldr	x13, [sp, 440]
	add	x15, x15, x13
.L76:
	sxtw	x13, w10
	add	w10, w10, 1
	add	x16, x28, x13
	add	x13, x8, x13
	ldp	q1, q6, [x2, 64]
	lsl	x16, x16, 6
	ldr	d0, [x19, x13, lsl 3]
	add	x13, x27, x16
	ldp	q5, q4, [x2, 96]
	ldr	q2, [x27, x16]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x2, 64]
	ldr	q3, [x13, 16]
	fmul	v3.2d, v3.2d, v0.d[0]
	fadd	v3.2d, v3.2d, v6.2d
	str	q3, [x2, 80]
	ldr	q2, [x13, 32]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x2, 96]
	ldr	q5, [x13, 48]
	fmul	v5.2d, v5.2d, v0.d[0]
	fadd	v5.2d, v5.2d, v4.2d
	str	q5, [x2, 112]
	cmp	w10, w6
	bge	.L78
	add	x10, x8, 1
	ldr	q0, [x12]
	ldr	d6, [x19, x10, lsl 3]
	fmul	v0.2d, v0.2d, v6.d[0]
	fadd	v0.2d, v0.2d, v1.2d
	mov	v1.16b, v0.16b
	str	q0, [x2, 64]
	ldr	q4, [x12, 16]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v3.2d
	str	q4, [x2, 80]
	ldr	q3, [x12, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x2, 96]
	ldr	q2, [x12, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x2, 112]
	cmp	w6, 3
	bne	.L78
	add	x10, x8, 2
	ldr	q1, [x11]
	ldr	d5, [x19, x10, lsl 3]
	fmul	v1.2d, v1.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v0.2d
	str	q1, [x2, 64]
	ldr	q0, [x11, 16]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v4.2d
	str	q0, [x2, 80]
	ldr	q0, [x11, 32]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v3.2d
	str	q0, [x2, 96]
	ldr	q0, [x11, 48]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x2, 112]
.L78:
	ldr	d0, [x15, 8]
	ldp	q4, q3, [x5, 64]
	add	w6, w6, 1
	dup	v0.2d, v0.d[0]
	ldr	q2, [x5, 96]
	fsub	v4.2d, v4.2d, v1.2d
	ldr	q1, [x5, 112]
	fdiv	v4.2d, v4.2d, v0.2d
	str	q4, [x5, 64]
	ldr	q4, [x2, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v0.2d
	str	q3, [x5, 80]
	ldr	q3, [x2, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x5, 96]
	ldr	q2, [x2, 112]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q0, [x5, 112]
	cmp	w7, w6
	bne	.L79
.L75:
	ldr	x2, [sp, 608]
	add	x3, x3, 4
	ldr	x5, [sp, 632]
	add	x9, x9, x2
	ldr	x2, [sp, 120]
	sub	w4, w4, #4
	add	x1, x1, 256
	add	w14, w14, 4
	add	x2, x2, x5
	str	x2, [sp, 120]
	ldr	x5, [sp, 128]
	ldr	x2, [sp, 520]
	add	x30, x30, x2
	add	x2, x5, x2
	str	x2, [sp, 128]
	ldr	w2, [sp, 136]
	cmp	w2, w3
	bgt	.L65
	ldp	x16, x13, [sp, 224]
	mov	w2, w26
	ldr	x26, [sp, 208]
	ldr	w28, [sp, 200]
	ldr	w5, [sp, 216]
	ldr	w7, [sp, 240]
	cmp	w23, 0
	ble	.L38
	add	x1, x16, 1
	add	x0, x26, x24, lsl 3
	add	x1, x22, x1, lsl 6
.L62:
	ldr	d0, [x21]
	str	d0, [x0]
	cmp	w23, 1
	ble	.L60
	ldr	d0, [x21, 8]
	str	d0, [x0, 8]
	cmp	w23, 2
	ble	.L60
	ldr	d0, [x21, 16]
	str	d0, [x0, 16]
	cmp	w23, 3
	ble	.L60
	ldr	d0, [x21, 24]
	str	d0, [x0, 24]
	cmp	w23, 4
	ble	.L60
	ldr	d0, [x21, 32]
	str	d0, [x0, 32]
	cmp	w23, 5
	ble	.L60
	ldr	d0, [x21, 40]
	str	d0, [x0, 40]
	cmp	w23, 6
	ble	.L60
	ldr	d0, [x21, 48]
	str	d0, [x0, 48]
	cmp	w23, 7
	ble	.L60
	ldr	d0, [x21, 56]
	str	d0, [x0, 56]
.L60:
	ldr	x3, [sp, 112]
	add	x21, x21, 64
	add	x0, x0, x3
	cmp	x1, x21
	bne	.L62
.L38:
	ldr	w0, [sp, 572]
	add	w28, w28, 8
	sub	w23, w23, #8
	add	x13, x13, 8
	add	x24, x24, 8
	cmp	w0, w28
	bgt	.L37
.L387:
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	w22, w5
	mov	w27, w2
	b	.L33
.L58:
	.cfi_restore_state
	ldr	x2, [sp, 120]
	add	x0, x19, x22
	add	w20, w20, 1
	mov	w1, 0
	str	w3, [sp, 128]
	add	x19, x19, 64
	str	x4, [sp, 144]
	str	x5, [sp, 168]
	stp	x6, x18, [sp, 184]
	stp	x9, x10, [sp, 200]
	str	x11, [sp, 216]
	str	w7, [sp, 224]
	str	w12, [sp, 232]
	str	x8, [sp, 240]
	bl	memset
	ldr	x4, [sp, 144]
	cmp	w21, w20
	ldr	x5, [sp, 168]
	ldp	x6, x18, [sp, 184]
	ldp	x9, x10, [sp, 200]
	ldr	x11, [sp, 216]
	ldr	x8, [sp, 240]
	ldr	w3, [sp, 128]
	ldr	w7, [sp, 224]
	ldr	w12, [sp, 232]
	bne	.L87
	b	.L376
.L386:
	cbz	w3, .L86
	ldr	x10, [sp, 176]
	sub	w5, w14, #1
	ldr	w7, [sp, 264]
	lsl	x2, x3, 3
	movi	v0.2d, 0
	mov	x6, x22
	mov	w11, 0
	mov	w13, 0
	mov	w28, 0
	mov	w16, 0
	smaddl	x8, w7, w14, x10
	str	x2, [sp, 168]
	smaddl	x5, w7, w5, x10
	mov	w2, 0
	mov	v19.16b, v0.16b
	mov	w10, 0
	mov	v8.16b, v0.16b
	add	x12, x19, x8, lsl 3
	mov	v1.16b, v0.16b
	add	x15, x19, x5, lsl 3
	mov	v23.16b, v0.16b
	mov	w8, 0
	mov	v22.16b, v0.16b
	mov	w7, 0
	mov	v25.16b, v0.16b
	mov	x5, 0
	mov	v24.16b, v0.16b
	str	x0, [sp, 248]
	mov	v21.16b, v0.16b
	mov	v18.16b, v0.16b
	mov	v7.16b, v0.16b
	mov	v20.16b, v0.16b
.L82:
	ldp	q6, q5, [x6]
	ldp	q4, q3, [x6, 32]
	ldr	d2, [x30, x5]
	fmul	v16.2d, v6.2d, v2.d[0]
	fmul	v26.2d, v5.2d, v2.d[0]
	fmul	v27.2d, v4.2d, v2.d[0]
	fmul	v2.2d, v3.2d, v2.d[0]
	fadd	v20.2d, v16.2d, v20.2d
	fadd	v26.2d, v26.2d, v7.2d
	fadd	v27.2d, v27.2d, v18.2d
	fadd	v16.2d, v2.2d, v21.2d
	cmp	w4, 1
	ble	.L80
	ldr	d2, [x15, x5]
	mov	w2, 1
	mov	w11, w2
	mov	w10, w2
	mov	w8, w2
	fmul	v7.2d, v6.2d, v2.d[0]
	fmul	v18.2d, v5.2d, v2.d[0]
	fmul	v21.2d, v4.2d, v2.d[0]
	fmul	v2.2d, v3.2d, v2.d[0]
	fadd	v1.2d, v7.2d, v1.2d
	fadd	v8.2d, v18.2d, v8.2d
	fadd	v19.2d, v21.2d, v19.2d
	fadd	v0.2d, v2.2d, v0.2d
	cmp	w4, 3
	bne	.L80
	ldr	d2, [x12, x5]
	mov	w13, w2
	mov	w7, w2
	mov	w28, w2
	mov	w16, w2
	fmul	v6.2d, v6.2d, v2.d[0]
	fmul	v5.2d, v5.2d, v2.d[0]
	fmul	v4.2d, v4.2d, v2.d[0]
	fmul	v3.2d, v3.2d, v2.d[0]
	fadd	v24.2d, v6.2d, v24.2d
	fadd	v25.2d, v5.2d, v25.2d
	fadd	v22.2d, v4.2d, v22.2d
	fadd	v23.2d, v3.2d, v23.2d
.L80:
	ldr	x0, [sp, 168]
	add	x5, x5, 8
	mov	v7.16b, v26.16b
	add	x6, x6, 64
	mov	v18.16b, v27.16b
	mov	v21.16b, v16.16b
	cmp	x5, x0
	bne	.L82
	stp	q20, q26, [sp, 784]
	stp	q27, q16, [sp, 816]
	ldr	x0, [sp, 248]
	cbz	w2, .L67
	str	q0, [sp, 896]
.L67:
	cbz	w11, .L68
	str	q19, [sp, 880]
.L68:
	cbz	w10, .L69
	str	q8, [sp, 864]
.L69:
	cbz	w8, .L70
	str	q1, [sp, 848]
.L70:
	cbz	w13, .L71
	str	q23, [sp, 960]
.L71:
	cbz	w7, .L72
	str	q22, [sp, 944]
.L72:
	cbz	w28, .L73
	str	q25, [sp, 928]
.L73:
	cbz	w16, .L86
	str	q24, [sp, 912]
	b	.L86
.L385:
	cmp	w20, w17
	ble	.L38
	ldr	w6, [sp, 272]
	sub	w9, w20, #1
	ldr	x10, [sp, 472]
	cmp	w9, w6
	csel	w9, w9, w6, le
	cmp	w23, 0
	csinc	w1, w1, wzr, gt
	add	x22, x26, x24, lsl 3
	mov	x0, x22
	mov	x4, x24
	and	w21, w1, -2
	and	w11, w1, 1
	lsr	w8, w1, 1
.L41:
	ldr	d1, [x10]
	cmp	w23, 0
	ble	.L55
	cmp	w23, 1
	beq	.L207
	ldr	q2, [x0]
	dup	v0.2d, v1.d[0]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0]
	cmp	w8, 1
	bls	.L54
	ldr	q2, [x0, 16]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 16]
	cmp	w8, 2
	beq	.L54
	ldr	q2, [x0, 32]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 32]
	cmp	w8, 3
	beq	.L54
	ldr	q2, [x0, 48]
	fdiv	v0.2d, v2.2d, v0.2d
	str	q0, [x0, 48]
.L54:
	mov	w3, w21
	cbz	w11, .L55
.L53:
	add	x3, x4, w3, sxtw
	ldr	d0, [x26, x3, lsl 3]
	fdiv	d0, d0, d1
	str	d0, [x26, x3, lsl 3]
.L55:
	ldr	x3, [sp, 440]
	add	w6, w6, 1
	add	x10, x10, x3
	ldr	x3, [sp, 160]
	add	x4, x4, x3
	ldr	x3, [sp, 112]
	add	x0, x0, x3
	cmp	w6, w9
	ble	.L41
	cmp	w6, w20
	bge	.L38
	ldr	w0, [sp, 156]
	mov	x30, x3
	ldr	x3, [sp, 704]
	sbfiz	x9, x6, 3, 32
	movi	v2.4s, 0
	and	w1, w1, 1
	smaddl	x11, w0, w6, x13
	add	x0, sp, 784
	madd	x14, x3, x9, x19
	madd	x9, x25, x9, x19
	add	x4, x26, x11, lsl 3
.L51:
	stp	q2, q2, [x0]
	stp	q2, q2, [x0, 32]
	cmp	w23, 0
	ble	.L42
	ldr	x12, [sp, 176]
	mov	x10, x22
	mov	x15, x24
.L45:
	ldr	d0, [x9, x12, lsl 3]
	cmp	w23, 1
	beq	.L205
	ldr	q3, [x10]
	ldr	q1, [sp, 784]
	fmul	v3.2d, v3.2d, v0.d[0]
	dup	v4.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 784]
	cmp	w8, 1
	bls	.L44
	ldr	q3, [x10, 16]
	ldr	q1, [sp, 800]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 800]
	cmp	w8, 2
	beq	.L44
	ldr	q3, [x10, 32]
	ldr	q1, [sp, 816]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 816]
	cmp	w8, 3
	beq	.L44
	ldr	q3, [x10, 48]
	ldr	q1, [sp, 832]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 832]
.L44:
	sxtw	x3, w21
	cbz	w1, .L47
.L43:
	add	x27, x3, x15
	ldr	d1, [x0, x3, lsl 3]
	ldr	d3, [x26, x27, lsl 3]
	fmul	d0, d0, d3
	fadd	d0, d0, d1
	str	d0, [x0, x3, lsl 3]
.L47:
	ldr	x3, [sp, 160]
	add	x12, x12, 1
	add	x10, x10, x30
	add	x15, x15, x3
	cmp	w6, w12
	bgt	.L45
	ldr	d3, [x14]
	cmp	w23, 1
	beq	.L206
	ldr	q0, [x4]
	ldr	q4, [sp, 784]
	dup	v1.2d, v3.d[0]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4]
	cmp	w8, 1
	bls	.L49
	ldr	q0, [x4, 16]
	ldr	q4, [sp, 800]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4, 16]
	cmp	w8, 2
	beq	.L49
	ldr	q0, [x4, 32]
	ldr	q4, [sp, 816]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4, 32]
	cmp	w8, 3
	beq	.L49
	ldr	q0, [x4, 48]
	ldr	q4, [sp, 832]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4, 48]
.L49:
	sxtw	x3, w21
	cbz	w1, .L42
.L48:
	add	x10, x3, x11
	ldr	d1, [x0, x3, lsl 3]
	ldr	d0, [x26, x10, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d3
	str	d0, [x26, x10, lsl 3]
.L42:
	ldr	x3, [sp, 440]
	add	w6, w6, 1
	add	x4, x4, x30
	add	x14, x14, x3
	ldr	x3, [sp, 160]
	add	x11, x11, x3
	ldr	x3, [sp, 280]
	add	x9, x9, x3
	cmp	w6, w20
	bne	.L51
	ldr	w0, [sp, 572]
	add	w28, w28, 8
	sub	w23, w23, #8
	add	x13, x13, 8
	add	x24, x24, 8
	cmp	w0, w28
	bgt	.L37
	b	.L387
.L206:
	mov	x3, 0
	b	.L48
.L205:
	mov	x3, 0
	b	.L43
.L207:
	mov	w3, 0
	b	.L53
.L210:
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
	b	.L84
.L382:
	.cfi_restore 72
	ldr	w3, [sp, 492]
	sub	w1, w1, #1
	sub	w9, w20, w7
	str	w1, [sp, 628]
	add	w1, w7, 1
	str	w1, [sp, 364]
	sub	w1, w9, #1
	str	x1, [sp, 592]
	ldr	x1, [sp, 176]
	str	w1, [sp, 248]
	udiv	w2, w0, w3
	mov	x28, x19
	mov	w23, w20
	str	x25, [sp, 144]
	neg	x4, x1, lsl 3
	sub	w1, w20, #1
	str	w1, [sp, 128]
	mov	x25, x26
	msub	w0, w2, w3, w0
	ldr	w1, [sp, 268]
	add	w21, w20, w2, lsl 6
	str	x4, [sp, 136]
	sub	w1, w1, w21
	str	w1, [sp, 528]
	lsl	w5, w0, 6
	ldr	w1, [sp, 488]
	mov	w17, w5
	str	wzr, [sp, 480]
	and	w1, w1, 1
	str	w1, [sp, 276]
	str	w9, [sp, 484]
	str	w22, [sp, 712]
	str	w27, [sp, 716]
	str	d8, [sp, 96]
	.cfi_offset 72, -944
.L95:
	ldr	w0, [sp, 528]
	add	w1, w21, 64
	ldr	w2, [sp, 360]
	ldr	w3, [sp, 268]
	cmp	w0, 63
	sub	w0, w2, w17
	csel	w16, w1, w3, gt
	cmp	w0, 63
	bgt	.L97
	ldr	w0, [sp, 276]
	mov	w27, w21
	str	w2, [sp, 120]
	cbnz	w0, .L198
.L98:
	cmp	w16, w27
	ble	.L166
	ldr	w0, [sp, 120]
	cmp	w17, w0
	bge	.L166
.L199:
	ldr	w1, [sp, 156]
	sxtw	x13, w17
	ldr	w0, [sp, 264]
	mov	w12, w16
	mov	x18, x25
	mov	w5, w27
	mov	w19, w23
	str	w21, [sp, 720]
	smull	x2, w27, w1
	ldr	x1, [sp, 592]
	smull	x0, w27, w0
	str	x0, [sp, 344]
	add	x14, x1, 1
	ldr	x1, [sp, 176]
	add	x1, x0, x1
	ldr	x0, [sp, 320]
	add	x1, x28, x1, lsl 3
	sub	x3, x0, x2
	add	x0, x13, x2
	add	x24, x25, x0, lsl 3
	lsl	x3, x3, 3
	mov	x15, x24
	mov	w24, w17
	str	x3, [sp, 328]
.L174:
	sub	w0, w12, w5
	mov	w4, 4
	cmp	w0, 4
	add	x23, x1, x14, lsl 3
	ldr	x3, [sp, 584]
	csel	w4, w0, w4, le
	cmp	w0, 3
	mov	x25, x23
	cset	w0, gt
	str	w0, [sp, 232]
	ldr	x0, [sp, 136]
	add	x3, x3, x15
	ldr	x23, [sp, 144]
	mov	w21, w24
	ldr	x10, [sp, 256]
	mov	x9, x13
	ldr	x26, [sp, 496]
	mov	x20, x3
	add	x0, x1, x0
	str	x2, [sp, 424]
	str	x0, [sp, 504]
	str	w4, [sp, 512]
	str	w24, [sp, 724]
	str	w5, [sp, 728]
	str	x3, [sp, 736]
	str	x13, [sp, 744]
	str	x14, [sp, 752]
	str	w12, [sp, 768]
.L168:
	ldr	x0, [x10, 16]
	ldr	w2, [sp, 120]
	ldr	x3, [x0]
	sub	w8, w2, w21
	cbz	x3, .L388
	asr	w0, w21, 3
	mov	x6, 8
	mov	w4, w6
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 232]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	ble	.L389
.L172:
	ldr	w0, [sp, 276]
	cbnz	w0, .L194
	movi	v16.2d, 0
	ldr	w0, [sp, 484]
	cmp	w0, 0
	ble	.L226
	ldr	x27, [sp, 368]
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
.L196:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, x6
	ldr	d6, [x0, x23, lsl 3]
	ldr	d5, [x0, x27, lsl 3]
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
	bne	.L196
.L195:
	ldp	q3, q2, [x15]
	ldp	q1, q0, [x15, 32]
	ldr	x0, [sp, 112]
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
.L178:
	ldr	w0, [sp, 120]
	add	w21, w21, 8
	add	x9, x9, 8
	add	x15, x15, 64
	add	x20, x20, 64
	cmp	w21, w0
	blt	.L168
	ldr	x0, [sp, 520]
	ldr	x4, [sp, 696]
	add	x1, x1, x0
	ldr	x0, [sp, 328]
	ldr	x3, [sp, 736]
	add	x0, x0, x4
	str	x0, [sp, 328]
	ldr	x0, [sp, 112]
	ldr	x2, [sp, 424]
	add	x15, x0, x3
	ldr	x0, [sp, 344]
	ldr	x3, [sp, 640]
	ldr	w5, [sp, 728]
	add	x0, x0, x3
	str	x0, [sp, 344]
	ldr	x0, [sp, 560]
	add	w5, w5, 4
	ldr	w12, [sp, 768]
	ldr	x13, [sp, 744]
	add	x2, x2, x0
	ldr	x14, [sp, 752]
	ldr	w24, [sp, 724]
	cmp	w12, w5
	bgt	.L174
	ldr	w21, [sp, 720]
	mov	w17, w24
	mov	x25, x18
	mov	w23, w19
.L166:
	ldr	w1, [sp, 480]
	ldr	w0, [sp, 628]
	cmp	w0, w1
	beq	.L372
.L396:
	ldr	w0, [sp, 360]
	add	w17, w17, 64
	cmp	w0, w17
	ble	.L390
.L169:
	ldr	w0, [sp, 480]
	add	w0, w0, 1
	str	w0, [sp, 480]
	b	.L95
.L194:
	ldr	w6, [sp, 156]
	mov	x5, x15
	ldr	w2, [sp, 264]
	ldr	w0, [sp, 272]
	str	x1, [sp, 168]
	sub	w0, w19, w0
	stp	x9, x10, [sp, 184]
	bl	update4x8_sve
	ldr	x1, [sp, 168]
	ldp	x9, x10, [sp, 184]
	b	.L178
.L388:
	ldr	x0, [sp, 328]
	ldr	x6, [sp, 160]
	add	x3, x0, x15
	ldr	w0, [sp, 232]
	ldr	w4, [sp, 156]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	bgt	.L172
.L389:
	cmp	w8, 8
	mov	w14, 8
	csel	w14, w8, w14, le
	lsl	x5, x6, 3
	sub	w0, w14, #1
	str	w0, [sp, 216]
	lsr	w0, w14, 2
	str	w0, [sp, 240]
	add	x0, x3, x5
	str	x0, [sp, 224]
	ldr	x0, [sp, 424]
	lsr	w4, w14, 1
	ldr	x22, [sp, 344]
	and	w7, w14, -2
	ldr	x11, [sp, 504]
	lsl	x2, x6, 4
	add	x12, x0, x9
	ldr	w17, [sp, 128]
	lsl	x0, x6, 1
	ldr	w30, [sp, 364]
	movi	v4.4s, 0
	str	w4, [sp, 168]
	mov	x4, x26
	str	x20, [sp, 544]
	ldr	x26, [sp, 280]
	mov	x13, x15
	ldr	w20, [sp, 512]
	mov	w24, 0
	str	x6, [sp, 184]
	mov	x6, x1
	str	x0, [sp, 208]
	add	x0, sp, 784
	str	w7, [sp, 288]
	mov	x7, x25
	str	x5, [sp, 432]
	mov	x5, x15
	str	x9, [sp, 552]
	mov	x9, x2
	str	w21, [sp, 568]
.L177:
	ldr	w1, [sp, 248]
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w19, w1
	ble	.L176
	cmp	w17, w30
	ble	.L222
	ldr	x1, [sp, 136]
	mov	x25, x3
	ldr	x16, [sp, 184]
	sub	x27, x11, x1
	ldr	x21, [sp, 224]
	mov	w1, w30
	mov	x15, 0
	stp	x18, x23, [sp, 192]
	str	x12, [sp, 296]
	str	w24, [sp, 304]
	str	x4, [sp, 312]
	b	.L188
.L393:
	ldp	q0, q1, [x25, 32]
	ldp	q2, q5, [x21, 32]
	ldp	q6, q8, [sp, 816]
	fmul	v1.2d, v1.2d, v7.2d
	fmul	v0.2d, v0.2d, v7.2d
	fmul	v5.2d, v5.2d, v3.2d
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v8.2d
	fadd	v0.2d, v0.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q0, q1, [sp, 816]
	.p2align 3,,7
.L185:
	add	w2, w1, 2
	ldr	x4, [sp, 208]
	add	x27, x27, 16
	add	x25, x25, x9
	add	x21, x21, x9
	add	x15, x15, x4
	add	x16, x16, x4
	cmp	w2, w17
	bge	.L391
	mov	w1, w2
.L188:
	ldr	w2, [sp, 216]
	ldr	d0, [x27]
	cmp	w2, 2
	bls	.L392
	ldp	q1, q2, [x25]
	ldp	q5, q6, [x21]
	ldp	q16, q17, [sp, 784]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d3, [x27, 8]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w2, [sp, 240]
	dup	v7.2d, v0.d[0]
	fmul	v6.2d, v6.2d, v3.d[0]
	fmul	v5.2d, v5.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v17.2d
	fadd	v1.2d, v1.2d, v16.2d
	dup	v3.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	stp	q1, q2, [sp, 784]
	cmp	w2, 2
	beq	.L393
	cmp	w8, 4
	beq	.L185
	mov	x4, 4
	mov	w2, w4
.L183:
	sub	w24, w14, w4
	sxtw	x12, w1
	cmp	w24, 1
	beq	.L186
	add	x23, x15, x4
	add	x18, x16, x4
	lsl	x4, x4, 3
	lsl	x23, x23, 3
	lsl	x18, x18, 3
	ldr	q2, [x0, x4]
	ldr	q1, [x3, x23]
	add	x23, x12, x22
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x4]
	ldr	d3, [x28, x23, lsl 3]
	ldr	q2, [x3, x18]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x4]
	tbz	x24, 0, .L185
	and	w24, w24, -2
	add	w2, w2, w24
.L186:
	sxtw	x2, w2
	add	x12, x12, x22
	add	x18, x15, x2
	add	x4, x16, x2
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x18, lsl 3]
	ldr	d1, [x3, x4, lsl 3]
	ldr	d3, [x28, x12, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
	b	.L185
.L394:
	ldp	x18, x28, [sp, 192]
.L176:
	cmp	w8, 1
	beq	.L221
	ldr	q0, [x13]
	ldr	q1, [sp, 784]
	ldr	w1, [sp, 168]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13]
	cmp	w1, 1
	bls	.L180
	ldr	q0, [x13, 16]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 16]
	cmp	w1, 2
	beq	.L180
	ldr	q0, [x13, 32]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 32]
	cmp	w1, 4
	bne	.L180
	ldr	q0, [x13, 48]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 48]
	.p2align 3,,7
.L181:
	add	w24, w24, 1
	ldr	x1, [sp, 160]
	add	x22, x22, x23
	add	x11, x11, x26
	add	x12, x12, x1
	ldr	x1, [sp, 112]
	add	x13, x13, x1
	cmp	w24, w20
	blt	.L177
	ldr	x20, [sp, 544]
	mov	x26, x4
	ldr	x9, [sp, 552]
	mov	x15, x5
	ldr	w21, [sp, 568]
	mov	x1, x6
	mov	x25, x7
	b	.L178
.L180:
	ldr	w1, [sp, 288]
	cmp	w14, w1
	beq	.L181
.L179:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x18, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x18, x2, lsl 3]
	b	.L181
.L391:
	ldp	x18, x23, [sp, 192]
	add	w1, w1, 1
	ldr	x12, [sp, 296]
	ldr	x4, [sp, 312]
	ldr	w24, [sp, 304]
.L182:
	sxtw	x21, w1
	ldr	w25, [sp, 288]
	ldr	x1, [sp, 176]
	stp	x18, x28, [sp, 192]
	ldr	w18, [sp, 168]
	ldr	x27, [sp, 432]
	sub	x16, x21, x1
	ldr	x1, [sp, 184]
	mov	x28, x1
	mul	x15, x1, x16
	madd	x16, x27, x16, x3
	b	.L192
	.p2align 2,,3
.L395:
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w18, 2
	beq	.L190
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w18, 4
	bne	.L190
	ldr	q1, [x16, 48]
	ldr	q0, [sp, 832]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [sp, 832]
	.p2align 3,,7
.L191:
	add	x21, x21, 1
	add	x15, x15, x28
	add	x16, x16, x27
	cmp	w19, w21
	ble	.L394
.L192:
	ldr	d0, [x11, x21, lsl 3]
	cmp	w8, 1
	beq	.L225
	ldr	q2, [x16]
	sxtw	x1, w25
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w18, 1
	bhi	.L395
.L190:
	cmp	w14, w25
	beq	.L191
.L189:
	add	x2, x1, x15
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
	b	.L191
.L225:
	mov	x1, 0
	b	.L189
.L221:
	mov	w1, 0
	b	.L179
.L222:
	ldr	w1, [sp, 272]
	b	.L182
.L392:
	mov	x4, 0
	mov	w2, 0
	b	.L183
.L226:
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
	b	.L195
.L97:
	add	w0, w17, 64
	str	w0, [sp, 120]
	ldr	w0, [sp, 276]
	cbnz	w0, .L198
	mov	w27, w21
	cmp	w21, w16
	blt	.L199
	ldr	w1, [sp, 480]
	ldr	w0, [sp, 628]
	cmp	w0, w1
	bne	.L396
.L372:
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	x26, x25
	ldr	x25, [sp, 144]
	mov	x19, x28
	ldr	w22, [sp, 712]
	ldr	w27, [sp, 716]
	b	.L93
.L198:
	.cfi_restore_state
	sub	w0, w16, w21
	cmp	w0, 15
	ble	.L212
	ldr	w3, [sp, 156]
	add	w14, w17, 16
	ldr	w1, [sp, 120]
	add	w5, w17, 15
	ldr	x26, [sp, 160]
	sub	w0, w1, w17
	smull	x22, w3, w21
	ldr	w3, [sp, 264]
	sub	w0, w0, #16
	cmp	w5, w1
	and	w2, w0, -16
	ldr	w18, [sp, 248]
	add	w2, w2, w14
	ldr	w24, [sp, 364]
	smull	x11, w3, w21
	csel	w19, w17, w2, ge
	ldr	x3, [sp, 320]
	mov	w27, w21
	ldr	x2, [sp, 176]
	sub	x1, x3, x22
	add	x3, x3, w17, sxtw
	str	w21, [sp, 544]
	lsl	x4, x1, 3
	neg	x12, x1, lsl 3
	add	x2, x11, x2
	add	x1, x25, x3, lsl 3
	str	x1, [sp, 504]
	mov	w21, w19
	ldr	w1, [sp, 272]
	add	x10, x28, x2, lsl 3
	stp	x4, x22, [sp, 296]
	sxtw	x4, w19
	mov	x19, x12
	str	w14, [sp, 568]
	mov	x14, x28
	sub	w1, w23, w1
	str	w1, [sp, 288]
	str	x11, [sp, 312]
	str	w17, [sp, 328]
	str	w16, [sp, 344]
	str	x4, [sp, 432]
	str	w5, [sp, 552]
	str	w0, [sp, 720]
.L136:
	ldr	w1, [sp, 120]
	ldr	w0, [sp, 552]
	cmp	w0, w1
	bge	.L101
	ldr	w1, [sp, 720]
	add	w0, w27, 8
	ldr	w2, [sp, 568]
	and	w1, w1, -16
	ldr	w20, [sp, 328]
	add	w1, w1, w2
	ldr	w2, [sp, 264]
	ldr	x3, [sp, 176]
	str	w1, [sp, 184]
	ldr	w1, [sp, 156]
	ldr	x15, [sp, 504]
	str	x14, [sp, 200]
	smull	x1, w0, w1
	smaddl	x0, w2, w0, x3
	ldr	x2, [sp, 320]
	add	x0, x14, x0, lsl 3
	str	x0, [sp, 168]
	sub	x1, x1, x2
	mov	x14, x19
	mov	x19, x10
	lsl	x0, x1, 3
	str	x0, [sp, 192]
	mov	w0, w18
	mov	x18, x15
	mov	w15, w20
	mov	w20, w0
	b	.L164
.L162:
	stp	x8, x13, [sp, 208]
	bl	update8x16_sve
	ldr	w7, [sp, 156]
	ldr	x0, [sp, 192]
	mov	w5, 8
	ldp	x8, x13, [sp, 208]
	add	x6, x0, x18
	ldr	x1, [sp, 168]
	add	w15, w15, 16
	ldr	w0, [sp, 288]
	add	x18, x18, 128
	ldr	w2, [sp, 264]
	mov	x4, x13
	mov	x3, x8
	bl	update8x16_sve
	ldr	w0, [sp, 184]
	cmp	w15, w0
	beq	.L397
.L164:
	ldr	x0, [sp, 256]
	asr	w8, w15, 3
	ldr	w7, [sp, 156]
	add	x6, x18, x14
	sbfiz	x8, x8, 14, 32
	ldr	w2, [sp, 264]
	ldr	x0, [x0, 16]
	mov	x1, x19
	mov	w5, 8
	ldr	x16, [x0]
	ldr	w0, [sp, 288]
	add	x8, x16, x8
	add	x13, x8, 16384
	mov	x3, x8
	mov	x4, x13
	cbnz	x16, .L162
	add	x4, x18, 64
	mov	x28, x7
	mov	w5, w7
	mov	x3, x18
	str	x4, [sp, 208]
	bl	update8x16_sve
	ldr	x1, [sp, 192]
	mov	x3, x18
	ldr	x4, [sp, 208]
	add	x6, x1, x18
	ldr	x1, [sp, 168]
	mov	w7, w28
	ldr	w0, [sp, 288]
	mov	w5, w28
	ldr	w2, [sp, 264]
	add	w15, w15, 16
	add	x18, x18, 128
	bl	update8x16_sve
	ldr	w0, [sp, 184]
	cmp	w15, w0
	bne	.L164
.L397:
	mov	x10, x19
	mov	x19, x14
	ldr	x14, [sp, 200]
	mov	w18, w20
.L101:
	ldr	w0, [sp, 120]
	cmp	w21, w0
	bge	.L142
	ldr	x2, [sp, 304]
	mov	w28, w18
	ldr	x1, [sp, 432]
	str	x10, [sp, 424]
	str	w27, [sp, 724]
	add	x0, x1, x22
	add	x13, x1, x2
	ldr	x1, [sp, 136]
	add	x15, x25, x0, lsl 3
	str	x19, [sp, 728]
	mov	x19, x14
	add	x1, x10, x1
	mov	x10, x15
	str	x1, [sp, 512]
	str	x22, [sp, 736]
	str	w21, [sp, 768]
	b	.L141
.L139:
	ldr	x1, [sp, 424]
	mov	x5, x10
	ldr	w0, [sp, 288]
	add	w21, w21, 8
	ldr	w6, [sp, 156]
	ldr	w2, [sp, 264]
	str	x10, [sp, 168]
	str	x13, [sp, 184]
	bl	update16x8_sve
	ldr	x10, [sp, 168]
	ldr	x13, [sp, 184]
	add	x10, x10, 64
	ldr	w0, [sp, 120]
	add	x13, x13, 8
	cmp	w21, w0
	bge	.L398
.L141:
	ldr	x0, [sp, 256]
	ldr	w1, [sp, 120]
	ldr	x0, [x0, 16]
	sub	w6, w1, w21
	ldr	x3, [x0]
	cbz	x3, .L399
	asr	w0, w21, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L161:
	cmp	w6, 7
	bgt	.L139
	lsl	x0, x8, 4
	str	x0, [sp, 232]
	lsl	x0, x8, 1
	lsl	x7, x8, 3
	ldr	x18, [sp, 280]
	str	x0, [sp, 240]
	ldr	x20, [sp, 312]
	sub	w0, w6, #1
	ldr	x5, [sp, 512]
	add	x14, x25, x13, lsl 3
	movi	v4.4s, 0
	add	x30, x7, 16
	and	w22, w6, -4
	lsr	w4, w6, 1
	and	w11, w6, -2
	mov	x12, x13
	and	w9, w6, 1
	str	w0, [sp, 224]
	add	x0, sp, 784
	and	w1, w6, 3
	mov	w27, 16
	str	w1, [sp, 168]
	str	w21, [sp, 744]
	str	x13, [sp, 752]
	str	x10, [sp, 760]
	.p2align 3,,7
.L145:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w23, w28
	ble	.L144
	ldr	w1, [sp, 128]
	cmp	w1, w24
	ble	.L218
	ldr	x1, [sp, 136]
	mov	x10, x3
	mov	x17, x8
	mov	x16, 0
	sub	x21, x5, x1
	mov	w1, w24
	str	x25, [sp, 184]
	str	w4, [sp, 192]
	str	w11, [sp, 200]
	stp	x26, x12, [sp, 208]
	b	.L154
	.p2align 2,,3
.L219:
	mov	w1, w2
.L154:
	ldr	w2, [sp, 224]
	sxtw	x4, w1
	ldr	d0, [x21]
	add	x11, x4, x20
	cmp	w2, 2
	bls	.L400
	ldp	q1, q2, [x10]
	mov	w12, w22
	ldr	q5, [x10, x30]
	mov	w2, w22
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 784]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x19, x11, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w11, [sp, 168]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 784]
	cbz	w11, .L159
.L160:
	uxtw	x11, w12
	add	x25, x4, x20
	add	x15, x16, x11
	add	x13, x17, x11
	sub	w12, w6, w12
	lsl	x11, x11, 3
	mov	x4, x25
	lsl	x15, x15, 3
	lsl	x13, x13, 3
	and	w26, w12, -2
	cmp	w12, 1
	beq	.L152
	ldr	q1, [x3, x15]
	add	w2, w2, w26
	ldr	q2, [x0, x11]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x11]
	ldr	d3, [x19, x25, lsl 3]
	ldr	q2, [x3, x13]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x11]
	tbz	x12, 0, .L159
.L152:
	sxtw	x2, w2
	ldr	d1, [x19, x4, lsl 3]
	add	x11, x16, x2
	add	x4, x17, x2
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x11, lsl 3]
	ldr	d3, [x3, x4, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
.L159:
	ldr	x4, [sp, 232]
	add	w2, w1, 2
	add	x21, x21, 16
	add	x10, x10, x4
	ldr	x4, [sp, 240]
	add	x16, x16, x4
	add	x17, x17, x4
	ldr	w4, [sp, 128]
	cmp	w2, w4
	blt	.L219
	ldp	x26, x12, [sp, 208]
	add	w1, w1, 1
	ldr	x25, [sp, 184]
	ldr	w4, [sp, 192]
	ldr	w11, [sp, 200]
.L150:
	sxtw	x13, w1
	ldr	x1, [sp, 176]
	sub	x15, x13, x1
	mul	x10, x8, x15
	madd	x15, x7, x15, x3
	.p2align 3,,7
.L158:
	ldr	d0, [x5, x13, lsl 3]
	cmp	w6, 1
	beq	.L220
	ldr	q2, [x15]
	sxtw	x1, w11
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w4, 1
	bls	.L156
	ldr	q2, [x15, 16]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w4, 3
	bne	.L156
	ldr	q2, [x15, 32]
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
.L156:
	cbz	w9, .L157
.L155:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L157:
	add	x13, x13, 1
	add	x10, x10, x8
	add	x15, x15, x7
	cmp	w23, w13
	bgt	.L158
.L144:
	cmp	w6, 1
	beq	.L217
	ldr	q0, [x14]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14]
	cmp	w4, 1
	bls	.L148
	ldr	q0, [x14, 16]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 16]
	cmp	w4, 3
	bne	.L148
	ldr	q0, [x14, 32]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 32]
.L148:
	sxtw	x1, w11
	cbz	w9, .L149
.L147:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x25, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x25, x2, lsl 3]
.L149:
	ldr	x1, [sp, 112]
	add	x12, x12, x26
	add	x5, x5, x18
	subs	w27, w27, #1
	add	x14, x14, x1
	ldr	x1, [sp, 144]
	add	x20, x20, x1
	bne	.L145
	ldr	x13, [sp, 752]
	ldr	x10, [sp, 760]
	add	x13, x13, 8
	ldr	w21, [sp, 744]
	ldr	w0, [sp, 120]
	add	x10, x10, 64
	add	w21, w21, 8
	cmp	w21, w0
	blt	.L141
.L398:
	ldr	x10, [sp, 424]
	mov	x14, x19
	ldr	x19, [sp, 728]
	mov	w18, w28
	ldr	x22, [sp, 736]
	ldr	w27, [sp, 724]
	ldr	w21, [sp, 768]
.L142:
	ldr	x2, [sp, 616]
	add	w27, w27, 16
	ldr	x3, [sp, 600]
	add	x10, x10, x2
	ldr	x2, [sp, 312]
	ldr	x1, [sp, 336]
	add	x2, x2, x3
	ldr	x3, [sp, 296]
	str	x2, [sp, 312]
	ldr	x2, [sp, 680]
	add	x22, x22, x1
	ldr	w0, [sp, 344]
	add	x3, x3, x2
	str	x3, [sp, 296]
	ldr	x3, [sp, 304]
	sub	w0, w0, w27
	sub	x19, x19, x2
	add	x1, x3, x1
	str	x1, [sp, 304]
	cmp	w0, 15
	bgt	.L136
	ldr	w17, [sp, 328]
	mov	x28, x14
	ldr	w16, [sp, 344]
	ldr	w21, [sp, 544]
.L99:
	add	w0, w27, 7
	cmp	w16, w0
	ble	.L98
	ldr	w5, [sp, 156]
	add	w4, w17, 15
	ldr	w3, [sp, 120]
	add	w2, w17, 16
	ldr	x6, [sp, 176]
	sub	w0, w3, w17
	smull	x22, w5, w27
	ldr	w5, [sp, 264]
	cmp	w4, w3
	sub	w3, w16, #8
	sub	w24, w3, w27
	sub	w1, w0, #16
	ldr	x3, [sp, 320]
	smull	x11, w5, w27
	and	w0, w1, -16
	ldr	w18, [sp, 364]
	sub	x5, x3, x22
	add	x7, x11, x6
	add	x8, x3, w17, sxtw
	add	w6, w27, 8
	and	w3, w24, -8
	add	w0, w0, w2
	add	w3, w6, w3
	str	w3, [sp, 568]
	lsl	x3, x5, 3
	str	x3, [sp, 432]
	add	x3, x25, x8, lsl 3
	str	x3, [sp, 544]
	ldr	w3, [sp, 272]
	csel	w0, w17, w0, ge
	add	x10, x28, x7, lsl 3
	mov	x26, x28
	sub	w3, w23, w3
	mov	x15, x11
	neg	x19, x5, lsl 3
	mov	x28, x10
	str	w21, [sp, 724]
	mov	w21, w0
	str	w24, [sp, 736]
	mov	w24, w23
	mov	x23, x25
	mov	w25, w1
	sxtw	x9, w0
	str	w3, [sp, 344]
	str	x22, [sp, 424]
	str	w17, [sp, 504]
	str	x9, [sp, 512]
	str	w2, [sp, 720]
	str	w4, [sp, 728]
	str	w6, [sp, 744]
	str	w16, [sp, 768]
.L104:
	ldr	w1, [sp, 120]
	ldr	w0, [sp, 728]
	cmp	w0, w1
	bge	.L134
	ldr	w1, [sp, 720]
	and	w0, w25, -16
	ldr	w14, [sp, 504]
	add	w0, w0, w1
	str	w0, [sp, 168]
	ldr	x20, [sp, 544]
	mov	x0, x19
	mov	w19, w14
	mov	x14, x0
.L132:
	ldr	x0, [sp, 256]
	asr	w3, w19, 3
	ldr	w7, [sp, 156]
	add	x6, x20, x14
	sbfiz	x3, x3, 14, 32
	ldr	w2, [sp, 264]
	ldr	x0, [x0, 16]
	mov	x1, x28
	mov	w5, 8
	ldr	x9, [x0]
	ldr	w0, [sp, 344]
	add	x3, x9, x3
	add	x4, x3, 16384
	cbz	x9, .L401
	bl	update8x16_sve
	add	w19, w19, 16
	ldr	w0, [sp, 168]
	add	x20, x20, 128
	cmp	w19, w0
	bne	.L132
.L377:
	mov	x19, x14
.L134:
	ldr	w0, [sp, 120]
	cmp	w21, w0
	bge	.L110
	ldr	x2, [sp, 424]
	mov	w20, w21
	ldr	x1, [sp, 512]
	str	x22, [sp, 752]
	str	w27, [sp, 760]
	add	x0, x22, x1
	add	x10, x1, x2
	ldr	x1, [sp, 136]
	add	x13, x23, x0, lsl 3
	mov	x22, x10
	mov	x10, x15
	add	x1, x28, x1
	str	x1, [sp, 552]
	mov	x1, x28
	mov	w28, w18
	str	w21, [sp, 772]
	str	w25, [sp, 776]
	mov	x25, x13
	mov	x13, x19
	b	.L109
.L107:
	ldr	w0, [sp, 344]
	mov	x5, x25
	ldr	w6, [sp, 156]
	add	w20, w20, 8
	ldr	w2, [sp, 264]
	add	x25, x25, 64
	str	x1, [sp, 168]
	add	x22, x22, 8
	stp	x13, x10, [sp, 184]
	bl	update8x8_sve
	ldr	w0, [sp, 120]
	ldr	x1, [sp, 168]
	ldp	x13, x10, [sp, 184]
	cmp	w20, w0
	bge	.L402
.L109:
	ldr	x0, [sp, 256]
	ldr	w2, [sp, 120]
	ldr	x0, [x0, 16]
	sub	w5, w2, w20
	ldr	x3, [x0]
	cbz	x3, .L403
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L129:
	cmp	w5, 7
	bgt	.L107
	ldr	x6, [sp, 552]
	lsl	x0, x8, 4
	lsl	x18, x8, 1
	and	w9, w5, 1
	lsl	x7, x8, 3
	lsr	w4, w5, 1
	and	w11, w5, -2
	and	w2, w5, 3
	movi	v4.4s, 0
	ldr	w30, [sp, 248]
	str	x6, [sp, 168]
	mov	x6, x25
	ldr	x25, [sp, 280]
	str	w9, [sp, 192]
	mov	x9, x13
	mov	x13, x18
	ldr	w18, [sp, 128]
	add	x14, x23, x22, lsl 3
	str	x0, [sp, 216]
	sub	w0, w5, #1
	mov	x12, x22
	add	x27, x7, 16
	and	w21, w5, -4
	mov	x19, x10
	str	w4, [sp, 184]
	mov	x4, x1
	str	x8, [sp, 200]
	mov	x8, x22
	mov	w22, w2
	str	w0, [sp, 208]
	add	x0, sp, 784
	str	w11, [sp, 328]
	mov	x11, x10
	mov	w17, 8
	str	w20, [sp, 780]
.L113:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w24, w30
	ble	.L112
	cmp	w18, w28
	ble	.L214
	ldr	x2, [sp, 136]
	mov	x10, x3
	ldr	x1, [sp, 168]
	mov	x15, 0
	ldr	x16, [sp, 200]
	sub	x20, x1, x2
	mov	w1, w28
	stp	x23, x12, [sp, 224]
	str	x4, [sp, 240]
	stp	x14, x6, [sp, 288]
	str	w17, [sp, 304]
	str	w24, [sp, 312]
	b	.L122
.L215:
	mov	w1, w2
.L122:
	ldr	w2, [sp, 208]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x6, x4, x19
	cmp	w2, 2
	bls	.L404
	ldp	q1, q2, [x10]
	mov	w12, w21
	ldr	q5, [x10, x27]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 784]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x26, x6, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 784]
	cbz	w22, .L127
.L128:
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
	beq	.L120
	ldr	q1, [x3, x17]
	add	w2, w2, w24
	ldr	q2, [x0, x6]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x6]
	ldr	d3, [x26, x23, lsl 3]
	ldr	q2, [x3, x14]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x6]
	tbz	x12, 0, .L127
.L120:
	sxtw	x2, w2
	ldr	d3, [x26, x4, lsl 3]
	add	x6, x15, x2
	add	x4, x16, x2
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x6, lsl 3]
	ldr	d1, [x3, x4, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
.L127:
	ldr	x4, [sp, 216]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x15, x15, x13
	add	x16, x16, x13
	add	x10, x10, x4
	cmp	w2, w18
	blt	.L215
	ldp	x23, x12, [sp, 224]
	add	w1, w1, 1
	ldp	x14, x6, [sp, 288]
	ldr	x4, [sp, 240]
	ldr	w17, [sp, 304]
	ldr	w24, [sp, 312]
.L118:
	sxtw	x15, w1
	str	w21, [sp, 224]
	ldr	x1, [sp, 176]
	stp	x23, x26, [sp, 232]
	ldr	w26, [sp, 192]
	ldr	x20, [sp, 200]
	sub	x16, x15, x1
	ldr	x21, [sp, 168]
	str	x12, [sp, 288]
	mul	x10, x20, x16
	ldr	w12, [sp, 184]
	madd	x16, x7, x16, x3
	ldr	w23, [sp, 328]
	.p2align 3,,7
.L126:
	ldr	d0, [x21, x15, lsl 3]
	cmp	w5, 1
	beq	.L216
	ldr	q2, [x16]
	sxtw	x1, w23
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w12, 1
	bls	.L124
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w12, 3
	bne	.L124
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
.L124:
	cbz	w26, .L125
.L123:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L125:
	add	x15, x15, 1
	add	x10, x10, x20
	add	x16, x16, x7
	cmp	w24, w15
	bgt	.L126
	ldp	x23, x26, [sp, 232]
	ldr	x12, [sp, 288]
	ldr	w21, [sp, 224]
.L112:
	cmp	w5, 1
	beq	.L213
	ldr	q0, [x14]
	ldr	q1, [sp, 784]
	ldr	w1, [sp, 184]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14]
	cmp	w1, 1
	bls	.L116
	ldr	q0, [x14, 16]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 16]
	cmp	w1, 3
	bne	.L116
	ldr	q0, [x14, 32]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 32]
.L116:
	ldr	w1, [sp, 192]
	cbz	w1, .L117
	ldr	w1, [sp, 328]
.L115:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x23, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x23, x2, lsl 3]
.L117:
	ldr	x1, [sp, 160]
	subs	w17, w17, #1
	add	x12, x12, x1
	ldr	x1, [sp, 112]
	add	x14, x14, x1
	ldr	x1, [sp, 144]
	add	x19, x19, x1
	ldr	x1, [sp, 168]
	add	x1, x1, x25
	str	x1, [sp, 168]
	bne	.L113
	ldr	w20, [sp, 780]
	mov	x25, x6
	ldr	w0, [sp, 120]
	mov	x22, x8
	add	w20, w20, 8
	mov	x1, x4
	mov	x13, x9
	mov	x10, x11
	add	x25, x25, 64
	add	x22, x22, 8
	cmp	w20, w0
	blt	.L109
.L402:
	ldr	x22, [sp, 752]
	mov	w18, w28
	ldr	w27, [sp, 760]
	mov	x19, x13
	ldr	w21, [sp, 772]
	mov	x15, x10
	ldr	w25, [sp, 776]
	mov	x28, x1
.L110:
	ldr	x1, [sp, 576]
	add	w27, w27, 8
	ldr	x2, [sp, 432]
	add	x28, x28, x1
	ldr	x1, [sp, 280]
	ldr	x0, [sp, 112]
	add	x15, x15, x1
	ldr	x1, [sp, 688]
	add	x22, x22, x0
	add	x2, x2, x1
	str	x2, [sp, 432]
	ldr	x2, [sp, 424]
	sub	x19, x19, x1
	add	x0, x2, x0
	str	x0, [sp, 424]
	ldr	w0, [sp, 568]
	cmp	w27, w0
	bne	.L104
	mov	x25, x23
	mov	w23, w24
	ldr	w24, [sp, 736]
	mov	x28, x26
	ldr	w6, [sp, 744]
	and	w24, w24, -8
	ldr	w17, [sp, 504]
	ldr	w21, [sp, 724]
	add	w27, w24, w6
	ldr	w16, [sp, 768]
	b	.L98
	.p2align 2,,3
.L220:
	mov	x1, 0
	b	.L155
.L217:
	mov	x1, 0
	b	.L147
.L218:
	ldr	w1, [sp, 272]
	b	.L150
.L400:
	mov	w12, 0
	mov	w2, 0
	b	.L160
.L399:
	ldr	x0, [sp, 296]
	mov	x8, x26
	ldr	w4, [sp, 156]
	add	x3, x0, x10
	b	.L161
.L216:
	mov	x1, 0
	b	.L123
.L213:
	mov	w1, 0
	b	.L115
.L403:
	ldr	x0, [sp, 432]
	ldr	x8, [sp, 160]
	add	x3, x25, x0
	ldr	w4, [sp, 156]
	b	.L129
.L214:
	ldr	w1, [sp, 272]
	b	.L118
.L401:
	add	x4, x20, 64
	mov	x3, x20
	mov	x5, x7
	bl	update8x16_sve
	ldr	w0, [sp, 168]
	add	w19, w19, 16
	add	x20, x20, 128
	cmp	w19, w0
	bne	.L132
	b	.L377
.L404:
	mov	w12, 0
	mov	w2, 0
	b	.L128
.L383:
	.cfi_restore 72
	ldp	x19, x20, [sp, 16]
	.cfi_restore 20
	.cfi_restore 19
	ldp	x21, x22, [sp, 32]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
.L29:
	ldp	x29, x30, [sp]
	ldp	x23, x24, [sp, 48]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 1040
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
.L94:
	.cfi_def_cfa_offset 1040
	.cfi_offset 19, -1024
	.cfi_offset 20, -1016
	.cfi_offset 21, -1008
	.cfi_offset 22, -1000
	.cfi_offset 23, -992
	.cfi_offset 24, -984
	.cfi_offset 25, -976
	.cfi_offset 26, -968
	.cfi_offset 27, -960
	.cfi_offset 28, -952
	.cfi_offset 29, -1040
	.cfi_offset 30, -1032
	add	w1, w1, 1
	mov	w0, 0
	b	.L201
.L390:
	.cfi_offset 72, -944
	ldr	w0, [sp, 268]
	add	w21, w21, 64
	mov	w17, 0
	sub	w0, w0, w21
	str	w0, [sp, 528]
	b	.L169
.L212:
	mov	w27, w21
	b	.L99
.L381:
	.cfi_restore 72
	str	d8, [sp, 96]
	.cfi_offset 72, -944
	b	.L204
.L208:
	mov	w10, 0
	b	.L77
	.p2align 2,,3
.L203:
	.cfi_restore 72
	bl	GOMP_barrier
	b	.L93
	.cfi_endproc
.LFE4372:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
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
	cbz	w0, .L408
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
.L407:
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
	bne	.L407
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L406:
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
.L408:
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
	b	.L406
	.cfi_endproc
.LFE4362:
	.size	solve16x8_panel_sve, .-solve16x8_panel_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4373:
	.cfi_startproc
	sub	sp, sp, #544
	.cfi_def_cfa_offset 544
	stp	x29, x30, [sp]
	.cfi_offset 29, -544
	.cfi_offset 30, -536
	mov	x29, sp
	stp	x27, x28, [sp, 80]
	.cfi_offset 27, -464
	.cfi_offset 28, -456
	ldp	x28, x2, [x0]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -528
	.cfi_offset 20, -520
	ldp	w20, w1, [x0, 28]
	str	x2, [sp, 176]
	ldr	w2, [x0, 24]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	str	w2, [sp, 168]
	str	w1, [sp, 172]
	.cfi_offset 21, -512
	.cfi_offset 22, -504
	.cfi_offset 23, -496
	.cfi_offset 24, -488
	ldp	w27, w24, [x0, 16]
	cbz	w1, .L461
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 172]
.L461:
	sbfiz	x23, x27, 6, 32
	mov	x1, 64
	mov	x2, x23
	add	x0, sp, 280
	bl	posix_memalign
	cmp	w0, 0
	ldr	x1, [sp, 280]
	csel	x21, xzr, x1, ne
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
	blt	.L414
.L459:
	madd	w0, w1, w3, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L415
	ldr	w4, [sp, 168]
	lsl	w1, w1, 3
	lsl	w7, w0, 3
	stp	w7, w1, [sp, 240]
	add	x1, x23, x21
	str	x1, [sp, 160]
	sxtw	x19, w4
	sub	w8, w27, #16
	add	x2, x19, 1
	and	w3, w8, -16
	lsl	x0, x19, 5
	str	x0, [sp, 256]
	lsl	x1, x2, 2
	str	x1, [sp, 128]
	sxtw	x1, w7
	str	x1, [sp, 152]
	ldr	x1, [sp, 176]
	add	x0, x0, 32
	sbfiz	x22, x4, 1, 32
	str	x0, [sp, 120]
	add	w0, w3, 16
	sub	w15, w24, w7
	add	x1, x1, w7, sxtw 3
	sbfiz	x18, x20, 3, 32
	str	x1, [sp, 144]
	lsl	x1, x19, 7
	str	w0, [sp, 264]
	add	x0, x22, x19
	lsl	x30, x2, 3
	mov	w24, w15
	mov	x23, x0
	str	x1, [sp, 192]
	sxtw	x1, w20
	mov	x20, x18
	sub	x4, x30, #8
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -472
	.cfi_offset 25, -480
	str	x4, [sp, 200]
	str	x1, [sp, 248]
	str	w8, [sp, 268]
	str	d8, [sp, 96]
	.cfi_offset 72, -448
.L418:
	cmp	w24, 8
	mov	w0, 8
	csel	w6, w24, w0, le
	cbz	x21, .L511
	cmp	w27, 0
	ble	.L419
	sub	w0, w6, #1
	mov	w1, 7
	add	x0, x0, 1
	sub	w1, w1, w6
	add	x1, x1, 1
	mov	x2, 8
	cmp	w24, 0
	lsl	x0, x0, 3
	ldr	x26, [sp, 144]
	csel	x0, x0, x2, gt
	mov	x25, x21
	lsl	x1, x1, 3
	sbfiz	x2, x6, 3, 32
	str	w27, [sp, 208]
	ldr	x27, [sp, 160]
	str	x28, [sp, 136]
	mov	x28, x2
	stp	x21, x22, [sp, 216]
	mov	x21, x1
	mov	x22, x0
	str	x19, [sp, 232]
	mov	x19, x25
	mov	x25, x30
	str	x0, [sp, 184]
.L452:
	mov	x1, x26
	mov	x2, x22
	mov	x0, x19
	cmp	w24, 0
	ble	.L421
	bl	memcpy
	cmp	w24, 7
	bgt	.L512
.L421:
	add	x0, x19, x28
	mov	x2, x21
	mov	w1, 0
	add	x19, x19, 64
	bl	memset
	add	x26, x26, x20
	cmp	x19, x27
	bne	.L452
	ldp	x21, x22, [sp, 216]
	mov	x30, x25
	ldr	x28, [sp, 136]
	ldr	x19, [sp, 232]
	ldr	w27, [sp, 208]
.L450:
	ldr	w0, [sp, 172]
	mov	w13, w0
	tbnz	x0, 0, .L513
.L422:
	ldr	x0, [sp, 200]
	sxtw	x8, w13
	sbfiz	x2, x13, 6, 32
	str	w24, [sp, 232]
	ldr	x24, [sp, 256]
	madd	x25, x8, x19, x19
	madd	x3, x0, x8, x28
	add	x1, x28, 8
	madd	x0, x30, x8, x28
	add	x25, x25, x8
	movi	v17.4s, 0
	sub	w7, w27, w13
	add	w26, w13, 2
	add	x2, x21, x2
	add	w13, w13, 1
	add	x5, sp, 288
	mov	x15, x3
	str	x30, [sp, 136]
	mov	x30, x0
	mov	x14, 0
	stp	x1, x20, [sp, 216]
	add	x1, x28, x25, lsl 3
	str	x1, [sp, 208]
.L428:
	stp	q17, q17, [x5]
	stp	q17, q17, [x5, 32]
	stp	q17, q17, [x5, 64]
	stp	q17, q17, [x5, 96]
	stp	q17, q17, [x5, 128]
	stp	q17, q17, [x5, 160]
	stp	q17, q17, [x5, 192]
	stp	q17, q17, [x5, 224]
	cmp	w7, 3
	ble	.L514
	movi	v16.2d, 0
	cmp	w8, 0
	ble	.L467
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
.L448:
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
	cmp	x0, x2
	bne	.L448
.L447:
	stp	q8, q31, [sp, 288]
	stp	q30, q29, [sp, 320]
	stp	q28, q27, [sp, 352]
	stp	q26, q25, [sp, 384]
	stp	q24, q23, [sp, 416]
	stp	q22, q21, [sp, 448]
	stp	q20, q19, [sp, 480]
	stp	q18, q16, [sp, 512]
.L449:
	ldr	d0, [x30, x14]
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
	cmp	w7, 1
	beq	.L438
	ldp	x0, x20, [sp, 208]
	add	x17, x8, 1
	add	x18, x8, 2
	cmp	w7, 4
	add	x17, x21, x17, lsl 6
	mov	x1, x5
	add	x18, x21, x18, lsl 6
	mov	x9, x25
	mov	w4, 1
	mov	w11, 0
	add	x6, x0, x14
	mov	w0, 4
	csel	w10, w7, w0, le
	mov	x0, x2
	b	.L439
	.p2align 2,,3
.L442:
	add	x1, x1, 64
	add	x9, x9, x19
	cmp	w4, 2
	beq	.L465
	ldp	q1, q0, [x2]
	mov	w11, 2
	ldr	d5, [x28, x9, lsl 3]
	ldp	q3, q2, [x1, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	ldr	d4, [x20, x9, lsl 3]
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
.L440:
	add	x0, x0, 64
	ldr	x12, [sp, 136]
	add	x6, x6, x12
.L439:
	sxtw	x16, w11
	add	w11, w11, 1
	add	x12, x16, x8
	add	x16, x9, x16
	ldp	q1, q2, [x1, 64]
	lsl	x12, x12, 6
	ldr	d4, [x28, x16, lsl 3]
	add	x16, x21, x12
	ldp	q6, q5, [x1, 96]
	ldr	q0, [x21, x12]
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
	cmp	w4, w11
	ble	.L441
	add	x11, x9, 1
	ldr	q4, [x17]
	ldr	d6, [x28, x11, lsl 3]
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
	bne	.L441
	add	x11, x9, 2
	ldr	q1, [x18]
	ldr	d6, [x28, x11, lsl 3]
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
.L441:
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
	cmp	w10, w4
	bne	.L442
.L438:
	ldr	x0, [sp, 128]
	add	x8, x8, 4
	sub	w7, w7, #4
	add	x2, x2, 256
	add	x25, x25, x0
	add	x3, x3, x24
	ldr	x0, [sp, 120]
	add	w26, w26, 4
	add	x15, x15, x24
	add	w13, w13, 4
	add	x14, x14, x0
	cmp	w27, w8
	bgt	.L428
	ldr	x30, [sp, 136]
	ldr	x20, [sp, 224]
	ldr	w24, [sp, 232]
.L429:
	cmp	w24, 0
	ble	.L419
	ldr	x3, [sp, 144]
	str	x19, [sp, 208]
	ldr	x26, [sp, 160]
	mov	x25, x30
	ldr	x19, [sp, 184]
	str	x21, [sp, 136]
.L425:
	mov	x1, x21
	mov	x0, x3
	mov	x2, x19
	add	x21, x21, 64
	bl	memcpy
	add	x3, x0, x20
	cmp	x26, x21
	bne	.L425
	ldr	x21, [sp, 136]
	mov	x30, x25
	ldr	x19, [sp, 208]
.L419:
	sub	w24, w24, #8
	ldr	x1, [sp, 152]
	ldr	w0, [sp, 240]
	add	x1, x1, 8
	str	x1, [sp, 152]
	ldr	x1, [sp, 144]
	add	w0, w0, 8
	str	w0, [sp, 240]
	add	x1, x1, 64
	str	x1, [sp, 144]
	ldr	w1, [sp, 244]
	cmp	w1, w0
	bgt	.L418
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldr	d8, [sp, 96]
	.cfi_restore 72
.L415:
	bl	GOMP_barrier
	ldp	x29, x30, [sp]
	mov	x0, x21
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 544
	.cfi_restore 27
	.cfi_restore 28
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
.L514:
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
	cmp	w8, 0
	ble	.L449
	movi	v1.2d, 0
	sxtw	x6, w13
	sxtw	x9, w26
	sub	x6, x6, x8
	sub	x9, x9, x8
	mov	x0, x21
	mov	x4, x15
	mov	w1, 0
	mul	x6, x6, x19
	mov	w10, 0
	mul	x9, x9, x19
	mov	w12, 0
	mov	v20.16b, v1.16b
	mov	w11, 0
	mov	v18.16b, v1.16b
	mov	w16, 0
	mov	v4.16b, v1.16b
	mov	w20, 0
	mov	v24.16b, v1.16b
	mov	w18, 0
	mov	v27.16b, v1.16b
	mov	w17, 0
	mov	v26.16b, v1.16b
	mov	v25.16b, v1.16b
	mov	v19.16b, v1.16b
	mov	v16.16b, v1.16b
	mov	v8.16b, v1.16b
	mov	v3.16b, v1.16b
	.p2align 3,,7
.L445:
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
	cmp	w7, 1
	ble	.L443
	ldr	d0, [x4, x6, lsl 3]
	mov	w1, 1
	mov	w10, w1
	mov	w12, w1
	mov	w11, w1
	fmul	v16.2d, v7.2d, v0.d[0]
	fmul	v19.2d, v6.2d, v0.d[0]
	fmul	v21.2d, v5.2d, v0.d[0]
	fmul	v0.2d, v22.2d, v0.d[0]
	fadd	v4.2d, v16.2d, v4.2d
	fadd	v18.2d, v19.2d, v18.2d
	fadd	v20.2d, v21.2d, v20.2d
	fadd	v1.2d, v0.2d, v1.2d
	cmp	w7, 3
	bne	.L443
	ldr	d16, [x4, x9, lsl 3]
	mov	w16, w1
	mov	w20, w1
	mov	w18, w1
	mov	w17, w1
	fmul	v7.2d, v7.2d, v16.d[0]
	fmul	v6.2d, v6.2d, v16.d[0]
	fmul	v5.2d, v5.2d, v16.d[0]
	fmul	v0.2d, v22.2d, v16.d[0]
	fadd	v25.2d, v7.2d, v25.2d
	fadd	v26.2d, v6.2d, v26.2d
	fadd	v27.2d, v5.2d, v27.2d
	fadd	v24.2d, v0.2d, v24.2d
.L443:
	add	x0, x0, 64
	add	x4, x4, 8
	mov	v8.16b, v23.16b
	mov	v16.16b, v28.16b
	mov	v19.16b, v2.16b
	cmp	x0, x2
	bne	.L445
	stp	q3, q23, [sp, 288]
	stp	q28, q2, [sp, 320]
	cbz	w1, .L430
	str	q1, [sp, 400]
.L430:
	cbz	w10, .L431
	str	q20, [sp, 384]
.L431:
	cbz	w12, .L432
	str	q18, [sp, 368]
.L432:
	cbz	w11, .L433
	str	q4, [sp, 352]
.L433:
	cbz	w16, .L434
	str	q24, [sp, 464]
.L434:
	cbz	w20, .L435
	str	q27, [sp, 448]
.L435:
	cbz	w18, .L436
	str	q26, [sp, 432]
.L436:
	cbz	w17, .L449
	str	q25, [sp, 416]
	b	.L449
.L467:
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
	b	.L447
.L513:
	cmp	w27, 15
	ble	.L463
	ldr	w0, [sp, 268]
	mov	w26, 0
	str	x20, [sp, 136]
	and	w25, w0, -16
	str	x19, [sp, 208]
	add	w25, w25, 16
	mov	x19, x21
	mov	w20, w25
	mov	x21, x28
	mov	x25, x30
.L423:
	ldr	w1, [sp, 168]
	mov	w0, w26
	mov	x2, x21
	mov	x3, x19
	add	w26, w26, 16
	bl	solve16x8_panel_sve
	ldr	x0, [sp, 192]
	add	x21, x21, x0
	cmp	w26, w20
	bne	.L423
	ldr	w0, [sp, 264]
	mov	x21, x19
	ldr	x20, [sp, 136]
	mov	x30, x25
	ldr	x19, [sp, 208]
	mov	w13, w0
	cmp	w27, w0
	bgt	.L422
	b	.L429
	.p2align 2,,3
.L511:
	cmp	w24, 0
	ble	.L419
	cmp	w27, 0
	ble	.L419
	ldp	x7, x8, [sp, 144]
	lsl	x9, x19, 3
	ldr	x4, [sp, 200]
	add	x6, x8, w6, uxtw
.L456:
	ldr	d0, [x7]
	ldr	d1, [x28]
	fdiv	d0, d0, d1
	str	d0, [x7]
	cmp	w27, 1
	beq	.L455
	ldr	x0, [sp, 248]
	add	x3, x28, x30
	ldr	x2, [sp, 176]
	add	x0, x0, x8
	add	x5, x28, x9
	mov	w1, 1
	add	x0, x2, x0, lsl 3
	.p2align 3,,7
.L458:
	movi	d1, #0
	mov	x10, x7
	mov	x2, 0
	.p2align 3,,7
.L457:
	ldr	d2, [x5, x2, lsl 3]
	add	x2, x2, 1
	ldr	d0, [x10]
	add	x10, x10, x20
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w1, w2
	bgt	.L457
	ldr	d0, [x0]
	add	w1, w1, 1
	ldr	d2, [x3]
	add	x5, x5, x4
	add	x3, x3, x30
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x0]
	add	x0, x0, x20
	cmp	w27, w1
	bne	.L458
.L455:
	add	x8, x8, 1
	add	x7, x7, 8
	cmp	x6, x8
	bne	.L456
	b	.L419
.L414:
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 72
	add	w1, w1, 1
	mov	w0, 0
	b	.L459
.L512:
	.cfi_offset 25, -480
	.cfi_offset 26, -472
	.cfi_offset 72, -448
	ldr	x28, [sp, 136]
	mov	x30, x25
	ldp	x21, x22, [sp, 216]
	mov	x25, x19
	ldr	x19, [sp, 232]
	str	x30, [sp, 136]
	ldr	w27, [sp, 208]
	b	.L451
	.p2align 2,,3
.L515:
	ldr	x2, [sp, 184]
	mov	x1, x26
	mov	x0, x25
	bl	memcpy
.L451:
	ldr	x0, [sp, 160]
	add	x25, x25, 64
	add	x26, x26, x20
	cmp	x25, x0
	bne	.L515
	ldr	x30, [sp, 136]
	b	.L450
.L463:
	mov	w13, 0
	b	.L422
.L465:
	mov	w11, 0
	b	.L440
	.cfi_endproc
.LFE4373:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4371:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L521
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
	mov	x22, x4
	mov	x24, x2
	mov	w23, w3
	mov	w21, w5
	cmp	x0, x1
	bls	.L518
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	str	xzr, [sp, 64]
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L519
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L519:
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
	stp	w23, w21, [sp, 112]
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
.L518:
	.cfi_restore_state
	mov	x0, 16
	bl	getauxval
	mov	x4, x0
	add	x1, sp, 80
	mov	w3, 0
	mov	w2, 0
	ubfx	w4, w4, 22, 1
	adrp	x0, solve_panel._omp_fn.0
	add	x0, x0, :lo12:solve_panel._omp_fn.0
	stp	x24, x22, [sp, 80]
	stp	w19, w20, [sp, 96]
	stp	w23, w21, [sp, 104]
	str	w4, [sp, 112]
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
.L521:
	ret
	.cfi_endproc
.LFE4371:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (gcc for openEuler 3.0.2) 12.3.1"
	.section	.note.GNU-stack,"",@progbits
