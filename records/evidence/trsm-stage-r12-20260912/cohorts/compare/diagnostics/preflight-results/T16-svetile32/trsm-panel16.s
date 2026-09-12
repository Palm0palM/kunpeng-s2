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
	.type	update4x32_sve, %function
update4x32_sve:
.LFB4369:
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
.LFE4369:
	.size	update4x32_sve, .-update4x32_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4372:
	.cfi_startproc
	sub	sp, sp, #1056
	.cfi_def_cfa_offset 1056
	stp	x29, x30, [sp]
	.cfi_offset 29, -1056
	.cfi_offset 30, -1048
	mov	x29, sp
	ldr	w2, [x0, 24]
	ldr	w1, [x0, 40]
	str	w2, [sp, 260]
	ldr	w2, [x0, 28]
	stp	x23, x24, [sp, 48]
	stp	x27, x28, [sp, 80]
	.cfi_offset 23, -1008
	.cfi_offset 24, -1000
	.cfi_offset 27, -976
	.cfi_offset 28, -968
	ldp	x23, x28, [x0]
	str	x0, [sp, 248]
	str	w2, [sp, 360]
	ldp	w2, w0, [x0, 32]
	stp	w0, w2, [sp, 160]
	str	w1, [sp, 488]
	cbz	w1, .L209
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 488]
.L209:
	ldr	w0, [sp, 260]
	cmp	w0, 0
	ble	.L28
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
	ldrsw	x20, [sp, 164]
	adds	w2, w7, 7
	add	w1, w7, 14
	csel	w0, w1, w2, mi
	ldr	w5, [sp, 160]
	add	w1, w7, 31
	add	x13, x20, 1
	asr	w0, w0, 3
	mov	w3, 24
	asr	w1, w1, 5
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
	str	x4, [sp, 144]
	mov	x27, x20
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
	mov	w22, w6
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
	b	.L90
.L395:
	add	w0, w1, 256
	str	w0, [sp, 128]
	cmp	w25, w21
	bgt	.L392
.L32:
	str	w15, [sp, 136]
	bl	GOMP_barrier
	ldr	w1, [sp, 128]
	ldr	w0, [sp, 260]
	ldr	w15, [sp, 136]
	cmp	w0, w1
	ble	.L92
	ldr	w0, [sp, 260]
	ldr	w1, [sp, 128]
	add	w0, w0, 31
	sub	w0, w0, w1
	ldr	w1, [sp, 360]
	asr	w0, w0, 5
	cmp	w1, 0
	ble	.L92
	ldr	w1, [sp, 492]
	ldr	w2, [sp, 560]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	ldr	w2, [sp, 524]
	cmp	w2, w0
	bcc	.L93
.L208:
	ldr	w2, [sp, 524]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L393
.L92:
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
	ldr	w0, [sp, 260]
	cmp	w0, w1
	ble	.L394
.L90:
	ldr	x1, [sp, 168]
	str	w1, [sp, 256]
	ldr	w0, [sp, 260]
	mov	w15, w1
	sub	w0, w0, w1
	cmp	w0, 255
	bgt	.L395
	cmp	w25, w21
	ble	.L210
	ldr	w0, [sp, 260]
	str	w0, [sp, 128]
	str	d8, [sp, 96]
	.cfi_offset 72, -960
.L211:
	ldr	x18, [sp, 664]
	mov	w10, w25
	ldr	w0, [sp, 128]
	mov	x6, x20
	ldr	x2, [sp, 112]
	sub	w30, w0, w15
	ldr	x1, [sp, 352]
	add	x16, x18, x20
	sub	w24, w30, #1
	ldr	w17, [sp, 168]
	ldr	w23, [sp, 624]
	sub	x1, x1, x2
	mov	w28, w22
	mov	w7, w22
	mov	x2, x24
	mov	x25, x16
	mov	w20, w21
	str	x18, [sp, 136]
	mov	w18, w0
	str	w30, [sp, 152]
	str	x1, [sp, 184]
.L36:
	ldr	x0, [sp, 248]
	cmp	w23, 8
	mov	w1, 8
	csel	w3, w23, w1, le
	ldr	x0, [x0, 16]
	ldr	x24, [x0]
	cbz	x24, .L396
	cmp	w28, 0
	add	w1, w28, 7
	csel	w1, w1, w28, lt
	ldr	w0, [sp, 152]
	asr	w1, w1, 3
	sbfiz	x22, x1, 14, 32
	sxtw	x1, w1
	add	x22, x24, x22
	cmp	w0, 0
	ble	.L37
	mov	w0, 7
	sub	w0, w0, w3
	add	x0, x0, 1
	sbfiz	x4, x3, 3, 32
	mov	x21, x22
	mov	x3, x22
	lsl	x0, x0, 3
	mov	x5, x22
	mov	x9, x21
	mov	w8, w20
	mov	x11, x25
	mov	x26, x0
	mov	x25, x19
	mov	w22, w18
	mov	x19, x3
	mov	w21, w7
	mov	x3, x24
	mov	w12, w17
	mov	x24, x4
	mov	x13, x1
	mov	x4, x27
	mov	w20, w15
	mov	w27, w10
	mov	x10, x2
.L86:
	cmp	w23, 0
	ble	.L57
	ldr	x2, [sp, 328]
.L56:
	ldr	x1, [sp, 136]
	ldr	w0, [sp, 160]
	smaddl	x1, w20, w0, x1
	lsl	x0, x1, 3
	ldr	d0, [x2, x1, lsl 3]
	add	x0, x2, x0
	str	d0, [x19]
	cmp	w23, 1
	ble	.L57
	ldr	d0, [x0, 8]
	str	d0, [x19, 8]
	cmp	w23, 2
	ble	.L57
	ldr	d0, [x0, 16]
	str	d0, [x19, 16]
	cmp	w23, 3
	ble	.L57
	ldr	d0, [x0, 24]
	str	d0, [x19, 24]
	cmp	w23, 4
	ble	.L57
	ldr	d0, [x0, 32]
	str	d0, [x19, 32]
	cmp	w23, 5
	ble	.L57
	ldr	d0, [x0, 40]
	str	d0, [x19, 40]
	cmp	w23, 6
	ble	.L57
	ldr	d0, [x0, 48]
	str	d0, [x19, 48]
	cmp	w23, 7
	ble	.L57
	ldr	d0, [x0, 56]
	add	w20, w20, 1
	add	x19, x19, 64
	str	d0, [x19, -8]
	cmp	w22, w20
	bne	.L56
.L386:
	lsl	x0, x13, 8
	mov	w18, w22
	mov	x1, x5
	mov	x22, x5
	ldp	x5, x13, [sp, 440]
	mov	x19, x25
	ldr	x14, [sp, 184]
	mov	w7, w21
	mov	x2, x10
	mov	x24, x3
	mov	w10, w27
	neg	x3, x4
	mov	x21, x9
	mov	x27, x4
	ldr	x9, [sp, 352]
	mov	x25, x11
	movi	v17.4s, 0
	ldr	w4, [sp, 152]
	add	w30, w15, 2
	mov	x20, x2
	str	x0, [sp, 176]
	add	x0, sp, 800
	str	x3, [sp, 192]
	add	x3, x19, 8
	str	x3, [sp, 200]
	mov	x3, 0
	str	w28, [sp, 208]
	str	w10, [sp, 216]
	str	w7, [sp, 224]
	str	w8, [sp, 232]
	str	w18, [sp, 240]
	str	x6, [sp, 264]
	str	w15, [sp, 280]
	str	w12, [sp, 288]
.L64:
	stp	q17, q17, [x0]
	stp	q17, q17, [x0, 32]
	stp	q17, q17, [x0, 64]
	stp	q17, q17, [x0, 96]
	stp	q17, q17, [x0, 128]
	stp	q17, q17, [x0, 160]
	stp	q17, q17, [x0, 192]
	stp	q17, q17, [x0, 224]
	cmp	w4, 3
	ble	.L397
	movi	v0.2d, 0
	cbz	w3, .L217
	ldr	x10, [sp, 368]
	add	x8, x22, x3, lsl 6
	ldr	x6, [sp, 496]
	mov	x7, x14
	mov	v18.16b, v0.16b
	mov	x2, x22
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
.L84:
	ldp	q5, q4, [x2]
	ldp	q3, q1, [x2, 32]
	add	x2, x2, 64
	ldr	d7, [x7, x27, lsl 3]
	ldr	d6, [x7, x6, lsl 3]
	ldr	d2, [x7, x10, lsl 3]
	fmla	v28.2d, v5.2d, v7.d[0]
	ld1r	{v16.2d}, [x7]
	fmla	v27.2d, v4.2d, v7.d[0]
	add	x7, x7, 8
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
	cmp	x2, x8
	bne	.L84
.L83:
	stp	q8, q31, [sp, 800]
	stp	q30, q29, [sp, 832]
	stp	q28, q27, [sp, 864]
	stp	q26, q25, [sp, 896]
	stp	q24, q23, [sp, 928]
	stp	q22, q21, [sp, 960]
	stp	q20, q19, [sp, 992]
	str	q18, [sp, 1024]
	str	q0, [sp, 1040]
.L85:
	ldr	x2, [sp, 192]
	ldp	q4, q3, [x1]
	ldp	q2, q1, [x1, 32]
	ldp	q8, q7, [sp, 800]
	ldp	q6, q5, [sp, 832]
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
	beq	.L74
	ldr	x2, [sp, 176]
	cmp	w4, 4
	mov	x16, x9
	mov	x10, x5
	add	x28, x2, x3
	mov	w2, 4
	add	x7, x28, 2
	add	x12, x28, 1
	csel	w6, w4, w2, le
	mov	w8, 1
	add	x18, x24, x7, lsl 6
	mov	x2, x0
	add	x12, x24, x12, lsl 6
	mov	x7, x1
	mov	w11, 0
	b	.L75
.L78:
	add	x2, x2, 64
	add	x10, x10, x27
	cmp	w8, 2
	beq	.L215
	ldp	q1, q0, [x1]
	mov	w11, 2
	ldr	d5, [x19, x10, lsl 3]
	ldp	q3, q2, [x2, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldr	x15, [sp, 200]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	ldr	d4, [x15, x10, lsl 3]
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
.L76:
	add	x7, x7, 64
	ldr	x15, [sp, 432]
	add	x16, x16, x15
.L75:
	sxtw	x15, w11
	add	w11, w11, 1
	add	x17, x28, x15
	add	x15, x15, x10
	ldp	q1, q6, [x2, 64]
	lsl	x17, x17, 6
	ldr	d0, [x19, x15, lsl 3]
	add	x15, x24, x17
	ldp	q5, q4, [x2, 96]
	ldr	q2, [x24, x17]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x2, 64]
	ldr	q3, [x15, 16]
	fmul	v3.2d, v3.2d, v0.d[0]
	fadd	v3.2d, v3.2d, v6.2d
	str	q3, [x2, 80]
	ldr	q2, [x15, 32]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x2, 96]
	ldr	q5, [x15, 48]
	fmul	v5.2d, v5.2d, v0.d[0]
	fadd	v5.2d, v5.2d, v4.2d
	str	q5, [x2, 112]
	cmp	w11, w8
	bge	.L77
	add	x11, x10, 1
	ldr	q0, [x12]
	ldr	d6, [x19, x11, lsl 3]
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
	cmp	w8, 3
	bne	.L77
	add	x11, x10, 2
	ldr	q1, [x18]
	ldr	d5, [x19, x11, lsl 3]
	fmul	v1.2d, v1.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v0.2d
	str	q1, [x2, 64]
	ldr	q0, [x18, 16]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v4.2d
	str	q0, [x2, 80]
	ldr	q0, [x18, 32]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v3.2d
	str	q0, [x2, 96]
	ldr	q0, [x18, 48]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x2, 112]
.L77:
	ldr	d0, [x16, 8]
	ldp	q4, q3, [x7, 64]
	add	w8, w8, 1
	dup	v0.2d, v0.d[0]
	ldr	q2, [x7, 96]
	fsub	v4.2d, v4.2d, v1.2d
	ldr	q1, [x7, 112]
	fdiv	v4.2d, v4.2d, v0.2d
	str	q4, [x7, 64]
	ldr	q4, [x2, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v0.2d
	str	q3, [x7, 80]
	ldr	q3, [x2, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x7, 96]
	ldr	q2, [x2, 112]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q0, [x7, 112]
	cmp	w6, w8
	bne	.L78
.L74:
	ldr	x2, [sp, 640]
	add	x3, x3, 4
	sub	w4, w4, #4
	add	x1, x1, 256
	add	x9, x9, x2
	add	w30, w30, 4
	ldr	x2, [sp, 648]
	add	x5, x5, x2
	ldr	x2, [sp, 512]
	add	x13, x13, x2
	add	x14, x14, x2
	ldr	w2, [sp, 152]
	cmp	w2, w3
	bgt	.L64
	ldr	x6, [sp, 264]
	mov	x2, x20
	ldr	w28, [sp, 208]
	ldr	w10, [sp, 216]
	ldr	w7, [sp, 224]
	ldr	w20, [sp, 232]
	ldr	w18, [sp, 240]
	ldr	w15, [sp, 280]
	ldr	w17, [sp, 288]
	cmp	w23, 0
	ble	.L37
	ldr	x0, [sp, 328]
	add	x1, x2, 1
	add	x1, x22, x1, lsl 6
	add	x0, x0, x25, lsl 3
.L61:
	ldr	d0, [x21]
	str	d0, [x0]
	cmp	w23, 1
	ble	.L59
	ldr	d0, [x21, 8]
	str	d0, [x0, 8]
	cmp	w23, 2
	ble	.L59
	ldr	d0, [x21, 16]
	str	d0, [x0, 16]
	cmp	w23, 3
	ble	.L59
	ldr	d0, [x21, 24]
	str	d0, [x0, 24]
	cmp	w23, 4
	ble	.L59
	ldr	d0, [x21, 32]
	str	d0, [x0, 32]
	cmp	w23, 5
	ble	.L59
	ldr	d0, [x21, 40]
	str	d0, [x0, 40]
	cmp	w23, 6
	ble	.L59
	ldr	d0, [x21, 48]
	str	d0, [x0, 48]
	cmp	w23, 7
	ble	.L59
	ldr	d0, [x21, 56]
	str	d0, [x0, 56]
.L59:
	ldr	x3, [sp, 120]
	add	x21, x21, 64
	add	x0, x0, x3
	cmp	x21, x1
	bne	.L61
.L37:
	ldr	x0, [sp, 136]
	add	w28, w28, 8
	sub	w23, w23, #8
	add	x25, x25, 8
	add	x0, x0, 8
	str	x0, [sp, 136]
	ldr	w0, [sp, 564]
	cmp	w0, w28
	bgt	.L36
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	w21, w20
	mov	w25, w10
	mov	w22, w7
	mov	x20, x6
	b	.L32
.L57:
	.cfi_restore_state
	add	x0, x19, x24
	add	w20, w20, 1
	mov	x2, x26
	mov	w1, 0
	str	x3, [sp, 176]
	add	x19, x19, 64
	stp	x4, x5, [sp, 192]
	str	w8, [sp, 208]
	stp	x9, x10, [sp, 216]
	stp	x11, x6, [sp, 232]
	str	w15, [sp, 264]
	str	w12, [sp, 280]
	str	x13, [sp, 288]
	bl	memset
	ldr	x3, [sp, 176]
	cmp	w22, w20
	ldp	x4, x5, [sp, 192]
	ldp	x9, x10, [sp, 216]
	ldp	x11, x6, [sp, 232]
	ldr	x13, [sp, 288]
	ldr	w8, [sp, 208]
	ldr	w15, [sp, 264]
	ldr	w12, [sp, 280]
	bne	.L86
	b	.L386
.L397:
	cbz	w3, .L85
	ldr	x11, [sp, 168]
	sub	w7, w30, #1
	ldr	w6, [sp, 164]
	lsl	x2, x3, 3
	movi	v0.2d, 0
	mov	x8, x22
	mov	x26, x2
	mov	w12, 0
	mov	w2, 0
	mov	w28, 0
	smaddl	x10, w6, w30, x11
	mov	w17, 0
	smaddl	x7, w6, w7, x11
	mov	w15, 0
	mov	v19.16b, v0.16b
	mov	w11, 0
	mov	v8.16b, v0.16b
	add	x16, x19, x10, lsl 3
	mov	v1.16b, v0.16b
	add	x18, x19, x7, lsl 3
	mov	v25.16b, v0.16b
	mov	w10, 0
	mov	v24.16b, v0.16b
	mov	w6, 0
	mov	v23.16b, v0.16b
	mov	x7, 0
	mov	v22.16b, v0.16b
	mov	v21.16b, v0.16b
	mov	v18.16b, v0.16b
	mov	v7.16b, v0.16b
	mov	v20.16b, v0.16b
.L81:
	ldp	q6, q5, [x8]
	ldp	q4, q3, [x8, 32]
	ldr	d2, [x13, x7]
	fmul	v16.2d, v6.2d, v2.d[0]
	fmul	v26.2d, v5.2d, v2.d[0]
	fmul	v27.2d, v4.2d, v2.d[0]
	fmul	v2.2d, v3.2d, v2.d[0]
	fadd	v20.2d, v16.2d, v20.2d
	fadd	v26.2d, v26.2d, v7.2d
	fadd	v27.2d, v27.2d, v18.2d
	fadd	v16.2d, v2.2d, v21.2d
	cmp	w4, 1
	ble	.L79
	ldr	d2, [x18, x7]
	mov	w2, 1
	mov	w12, w2
	mov	w11, w2
	mov	w10, w2
	fmul	v7.2d, v6.2d, v2.d[0]
	fmul	v18.2d, v5.2d, v2.d[0]
	fmul	v21.2d, v4.2d, v2.d[0]
	fmul	v2.2d, v3.2d, v2.d[0]
	fadd	v1.2d, v7.2d, v1.2d
	fadd	v8.2d, v18.2d, v8.2d
	fadd	v19.2d, v21.2d, v19.2d
	fadd	v0.2d, v2.2d, v0.2d
	cmp	w4, 3
	bne	.L79
	ldr	d2, [x16, x7]
	mov	w28, w2
	mov	w17, w2
	mov	w15, w2
	mov	w6, w2
	fmul	v6.2d, v6.2d, v2.d[0]
	fmul	v5.2d, v5.2d, v2.d[0]
	fmul	v4.2d, v4.2d, v2.d[0]
	fmul	v3.2d, v3.2d, v2.d[0]
	fadd	v22.2d, v6.2d, v22.2d
	fadd	v23.2d, v5.2d, v23.2d
	fadd	v24.2d, v4.2d, v24.2d
	fadd	v25.2d, v3.2d, v25.2d
.L79:
	add	x7, x7, 8
	add	x8, x8, 64
	mov	v7.16b, v26.16b
	mov	v18.16b, v27.16b
	mov	v21.16b, v16.16b
	cmp	x7, x26
	bne	.L81
	stp	q20, q26, [sp, 800]
	stp	q27, q16, [sp, 832]
	cbz	w2, .L66
	str	q0, [sp, 912]
.L66:
	cbz	w12, .L67
	str	q19, [sp, 896]
.L67:
	cbz	w11, .L68
	str	q8, [sp, 880]
.L68:
	cbz	w10, .L69
	str	q1, [sp, 864]
.L69:
	cbz	w28, .L70
	str	q25, [sp, 976]
.L70:
	cbz	w17, .L71
	str	q24, [sp, 960]
.L71:
	cbz	w15, .L72
	str	q23, [sp, 944]
.L72:
	cbz	w6, .L85
	str	q22, [sp, 928]
	b	.L85
.L396:
	cmp	w18, w17
	ble	.L37
	ldr	w4, [sp, 256]
	sub	w9, w18, #1
	ldr	x5, [sp, 328]
	cmp	w9, w4
	csel	w9, w9, w4, le
	cmp	w23, 0
	csinc	w3, w3, wzr, gt
	mov	x11, x25
	ldr	x12, [sp, 456]
	add	x22, x5, x25, lsl 3
	and	w21, w3, -2
	and	w13, w3, 1
	lsr	w8, w3, 1
	mov	x0, x22
.L40:
	ldr	d1, [x12]
	cmp	w23, 0
	ble	.L54
	cmp	w23, 1
	beq	.L214
	ldr	q2, [x0]
	dup	v0.2d, v1.d[0]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0]
	cmp	w8, 1
	bls	.L53
	ldr	q2, [x0, 16]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 16]
	cmp	w8, 2
	beq	.L53
	ldr	q2, [x0, 32]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 32]
	cmp	w8, 3
	beq	.L53
	ldr	q2, [x0, 48]
	fdiv	v0.2d, v2.2d, v0.2d
	str	q0, [x0, 48]
.L53:
	mov	w1, w21
	cbz	w13, .L54
.L52:
	add	x1, x11, w1, sxtw
	ldr	d0, [x5, x1, lsl 3]
	fdiv	d0, d0, d1
	str	d0, [x5, x1, lsl 3]
.L54:
	ldr	x1, [sp, 432]
	add	w4, w4, 1
	add	x12, x12, x1
	ldr	x1, [sp, 144]
	add	x11, x11, x1
	ldr	x1, [sp, 120]
	add	x0, x0, x1
	cmp	w4, w9
	ble	.L40
	cmp	w4, w18
	bge	.L37
	ldr	x1, [sp, 136]
	sbfiz	x9, x4, 3, 32
	ldr	w0, [sp, 160]
	and	w24, w3, 1
	ldr	x11, [sp, 328]
	movi	v2.4s, 0
	smaddl	x12, w0, w4, x1
	add	x0, sp, 800
	ldr	x1, [sp, 728]
	add	x3, x11, x12, lsl 3
	madd	x16, x1, x9, x19
	madd	x9, x27, x9, x19
.L50:
	stp	q2, q2, [x0]
	stp	q2, q2, [x0, 32]
	cmp	w23, 0
	ble	.L41
	ldr	x13, [sp, 168]
	mov	x5, x22
	mov	x14, x25
.L44:
	ldr	d0, [x9, x13, lsl 3]
	cmp	w23, 1
	beq	.L212
	ldr	q3, [x5]
	ldr	q1, [sp, 800]
	fmul	v3.2d, v3.2d, v0.d[0]
	dup	v4.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 800]
	cmp	w8, 1
	bls	.L43
	ldr	q3, [x5, 16]
	ldr	q1, [sp, 816]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 816]
	cmp	w8, 2
	beq	.L43
	ldr	q3, [x5, 32]
	ldr	q1, [sp, 832]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 832]
	cmp	w8, 3
	beq	.L43
	ldr	q3, [x5, 48]
	ldr	q1, [sp, 848]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 848]
.L43:
	sxtw	x1, w21
	cbz	w24, .L46
.L42:
	add	x30, x1, x14
	ldr	d1, [x0, x1, lsl 3]
	ldr	d3, [x11, x30, lsl 3]
	fmul	d0, d0, d3
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L46:
	ldr	x1, [sp, 144]
	add	x13, x13, 1
	add	x14, x14, x1
	ldr	x1, [sp, 120]
	add	x5, x5, x1
	cmp	w4, w13
	bgt	.L44
	ldr	d3, [x16]
	cmp	w23, 1
	beq	.L213
	ldr	q0, [x3]
	ldr	q4, [sp, 800]
	dup	v1.2d, v3.d[0]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3]
	cmp	w8, 1
	bls	.L48
	ldr	q0, [x3, 16]
	ldr	q4, [sp, 816]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 16]
	cmp	w8, 2
	beq	.L48
	ldr	q0, [x3, 32]
	ldr	q4, [sp, 832]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 32]
	cmp	w8, 3
	beq	.L48
	ldr	q0, [x3, 48]
	ldr	q4, [sp, 848]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 48]
.L48:
	sxtw	x1, w21
	cbz	w24, .L41
.L47:
	add	x5, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x11, x5, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d3
	str	d0, [x11, x5, lsl 3]
.L41:
	ldr	x1, [sp, 432]
	add	w4, w4, 1
	add	x16, x16, x1
	ldr	x1, [sp, 144]
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	add	x3, x3, x1
	ldr	x1, [sp, 112]
	add	x9, x9, x1
	cmp	w4, w18
	bne	.L50
	b	.L37
.L213:
	mov	x1, 0
	b	.L47
.L212:
	mov	x1, 0
	b	.L42
.L214:
	mov	w1, 0
	b	.L52
.L217:
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
	b	.L83
.L393:
	.cfi_restore 72
	ldr	w4, [sp, 492]
	sub	w1, w1, #1
	ldr	w3, [sp, 128]
	mov	x28, x19
	str	w1, [sp, 628]
	mov	x23, x27
	sub	w17, w3, w15
	sub	w13, w3, #1
	udiv	w2, w0, w4
	sub	w1, w17, #1
	str	x1, [sp, 608]
	add	w26, w15, 1
	ldr	x1, [sp, 168]
	str	w13, [sp, 136]
	add	w7, w3, w2, lsl 5
	msub	w0, w2, w4, w0
	ldr	w2, [sp, 260]
	ldr	x24, [sp, 328]
	sub	w2, w2, w7
	lsl	w30, w0, 5
	str	w2, [sp, 520]
	ldr	w2, [sp, 488]
	mov	w13, w30
	str	w25, [sp, 736]
	mov	w25, w3
	str	w21, [sp, 752]
	mov	w21, w7
	neg	x5, x1, lsl 3
	and	w2, w2, 1
	str	x5, [sp, 128]
	str	w1, [sp, 240]
	str	w2, [sp, 264]
	str	w26, [sp, 364]
	str	wzr, [sp, 464]
	str	w17, [sp, 468]
	str	w22, [sp, 740]
	str	x20, [sp, 744]
	str	d8, [sp, 96]
	.cfi_offset 72, -960
.L94:
	ldr	w2, [sp, 360]
	add	w4, w13, 32
	ldr	w0, [sp, 520]
	mov	w19, w21
	ldr	w3, [sp, 260]
	sub	w1, w2, w13
	cmp	w0, 31
	add	w0, w21, 32
	csel	w0, w0, w3, gt
	cmp	w1, 31
	ldr	w1, [sp, 264]
	csel	w10, w4, w2, gt
	cbnz	w1, .L398
.L97:
	cmp	w0, w19
	ble	.L171
	ldp	w3, w2, [sp, 160]
	sub	w1, w10, w13
	add	w5, w13, 31
	sub	w1, w1, #32
	and	w1, w1, -32
	cmp	w10, w5
	smull	x4, w3, w19
	csel	w1, w1, wzr, gt
	ldr	x3, [sp, 168]
	smull	x2, w2, w19
	ldr	x12, [sp, 248]
	add	x6, x2, x3
	ldr	x3, [sp, 272]
	sub	w20, w0, w19
	ldr	x27, [sp, 496]
	sub	x7, x3, x4
	add	x8, x3, w13, sxtw
	add	x26, x28, x6, lsl 3
	ldr	x3, [sp, 608]
	mov	x18, x24
	mov	w19, w25
	mov	x22, x23
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
	mov	x25, x4
	mov	w8, w10
	mov	w24, w20
	str	x1, [sp, 720]
	mov	x1, x26
	mov	w26, w13
	mov	w13, w21
	str	x4, [sp, 312]
	str	w0, [sp, 756]
	str	w5, [sp, 792]
.L170:
	ldr	w0, [sp, 264]
	mov	w21, w26
	cbz	w0, .L168
	cmp	w24, 3
	bgt	.L399
.L168:
	cmp	w8, w21
	ble	.L177
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
	str	w8, [sp, 152]
	add	x0, x1, x0
	str	x0, [sp, 480]
	ldr	x0, [sp, 720]
	str	x2, [sp, 424]
	str	w13, [sp, 768]
	add	x23, x0, x1
	str	w24, [sp, 776]
	mov	x25, x23
	mov	x23, x22
.L176:
	ldr	x0, [x9, 16]
	ldr	w2, [sp, 152]
	ldr	x3, [x0]
	sub	w8, w2, w21
	cbz	x3, .L400
	asr	w0, w21, 3
	mov	x6, 8
	mov	w4, w6
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 224]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	ble	.L401
.L174:
	ldr	w0, [sp, 264]
	cbnz	w0, .L197
	movi	v16.2d, 0
	ldr	w0, [sp, 468]
	cmp	w0, 0
	ble	.L234
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
.L199:
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
	bne	.L199
.L198:
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
.L181:
	ldr	w0, [sp, 152]
	add	w21, w21, 8
	add	x26, x26, 8
	add	x15, x15, 64
	add	x20, x20, 64
	cmp	w0, w21
	bgt	.L176
	ldr	x2, [sp, 424]
	mov	x8, x0
	ldr	x25, [sp, 784]
	mov	x22, x23
	ldr	w26, [sp, 760]
	mov	x12, x9
	ldr	w13, [sp, 768]
	ldr	w24, [sp, 776]
.L177:
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
	ble	.L402
	mov	w24, w3
	b	.L170
.L197:
	ldp	w6, w2, [sp, 160]
	mov	x5, x15
	ldr	w0, [sp, 256]
	stp	x1, x9, [sp, 176]
	sub	w0, w19, w0
	bl	update4x8_sve
	ldp	x1, x9, [sp, 176]
	b	.L181
.L400:
	ldr	x0, [sp, 320]
	ldr	x6, [sp, 144]
	add	x3, x0, x15
	ldr	w0, [sp, 224]
	ldr	w4, [sp, 160]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	bgt	.L174
.L401:
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
.L180:
	ldr	w1, [sp, 240]
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w19, w1
	ble	.L179
	cmp	w10, w30
	ble	.L230
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
	b	.L191
.L405:
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
.L188:
	add	w2, w1, 2
	ldr	x17, [sp, 208]
	add	x27, x27, 16
	add	x15, x15, x9
	add	x16, x16, x9
	add	x25, x25, x17
	add	x21, x21, x17
	cmp	w2, w10
	bge	.L403
	mov	w1, w2
.L191:
	ldr	w2, [sp, 216]
	ldr	d0, [x27]
	cmp	w2, 2
	bls	.L404
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
	beq	.L405
	cmp	w8, 4
	beq	.L188
	mov	x17, 4
	mov	w2, w17
.L186:
	sub	w24, w14, w17
	sxtw	x18, w1
	cmp	w24, 1
	beq	.L189
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
	tbz	x24, 0, .L188
	and	w24, w24, -2
	add	w2, w2, w24
.L189:
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
	b	.L188
.L406:
	ldr	x18, [sp, 192]
.L179:
	cmp	w8, 1
	beq	.L229
	ldr	q0, [x13]
	ldr	q1, [sp, 800]
	ldr	w1, [sp, 176]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13]
	cmp	w1, 1
	bls	.L183
	ldr	q0, [x13, 16]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 16]
	cmp	w1, 2
	beq	.L183
	ldr	q0, [x13, 32]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 32]
	cmp	w1, 4
	bne	.L183
	ldr	q0, [x13, 48]
	ldr	q1, [sp, 848]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 48]
	.p2align 3,,7
.L184:
	add	w24, w24, 1
	ldr	x1, [sp, 144]
	add	x13, x13, x20
	add	x22, x22, x23
	add	x12, x12, x1
	ldr	x1, [sp, 112]
	add	x11, x11, x1
	cmp	w24, w26
	blt	.L180
	ldr	x25, [sp, 528]
	mov	x1, x4
	ldr	x15, [sp, 536]
	mov	x20, x5
	ldr	x27, [sp, 552]
	mov	x26, x6
	ldr	w21, [sp, 544]
	mov	x9, x7
	b	.L181
.L183:
	ldr	w1, [sp, 280]
	cmp	w14, w1
	beq	.L184
.L182:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x18, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x18, x2, lsl 3]
	b	.L184
.L403:
	ldr	x18, [sp, 192]
	add	w1, w1, 1
	ldr	x23, [sp, 288]
	ldr	x20, [sp, 304]
	ldr	w24, [sp, 296]
.L185:
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
	b	.L195
	.p2align 2,,3
.L407:
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w18, 2
	beq	.L193
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 832]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 832]
	cmp	w18, 4
	bne	.L193
	ldr	q1, [x16, 48]
	ldr	q0, [sp, 848]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [sp, 848]
	.p2align 3,,7
.L194:
	add	x17, x17, 1
	add	x15, x15, x27
	add	x16, x16, x25
	cmp	w19, w17
	ble	.L406
.L195:
	ldr	d0, [x11, x17, lsl 3]
	cmp	w8, 1
	beq	.L233
	ldr	q2, [x16]
	sxtw	x1, w21
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w18, 1
	bhi	.L407
.L193:
	cmp	w14, w21
	beq	.L194
.L192:
	add	x2, x1, x15
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
	b	.L194
.L233:
	mov	x1, 0
	b	.L192
.L229:
	mov	w1, 0
	b	.L182
.L230:
	ldr	w1, [sp, 256]
	b	.L185
.L404:
	mov	x17, 0
	mov	w2, 0
	b	.L186
.L234:
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
	b	.L198
.L402:
	mov	w21, w13
	mov	x24, x18
	mov	w13, w26
	mov	x23, x22
	mov	w25, w19
.L171:
	ldr	w0, [sp, 464]
	ldr	w1, [sp, 628]
	cmp	w0, w1
	beq	.L383
	ldr	w0, [sp, 360]
	add	w13, w13, 32
	cmp	w0, w13
	ble	.L408
.L166:
	ldr	w0, [sp, 464]
	add	w0, w0, 1
	str	w0, [sp, 464]
	b	.L94
.L399:
	ldr	w0, [sp, 792]
	cmp	w8, w0
	ble	.L168
	ldr	x15, [sp, 592]
	mov	w23, w13
	ldr	w0, [sp, 256]
	mov	x21, x1
	mov	w14, w8
	str	x18, [sp, 152]
	sub	w20, w19, w0
	mov	x18, x15
	mov	w15, w26
	str	x2, [sp, 176]
	str	w19, [sp, 184]
	mov	x19, x12
	b	.L203
.L201:
	bl	update4x32_sve
	add	x18, x18, 256
	add	w0, w15, 63
	add	w9, w15, 32
	cmp	w14, w0
	ble	.L409
.L204:
	mov	w15, w9
.L203:
	ldr	x0, [x19, 16]
	asr	w3, w15, 3
	ldr	x1, [sp, 344]
	sbfiz	x3, x3, 14, 32
	ldr	x11, [x0]
	add	x6, x18, x1
	ldp	w7, w2, [sp, 160]
	mov	w0, w20
	add	x3, x11, x3
	mov	x1, x21
	mov	w5, 2048
	mov	w4, 8
	cbnz	x11, .L201
	ldp	w4, w2, [sp, 160]
	mov	x3, x18
	ldr	x0, [sp, 344]
	mov	w7, w4
	mov	w5, 8
	add	x6, x18, x0
	mov	w0, w20
	bl	update4x32_sve
	add	x18, x18, 256
	add	w0, w15, 63
	add	w9, w15, 32
	cmp	w14, w0
	bgt	.L204
.L409:
	ldr	x18, [sp, 152]
	mov	x1, x21
	ldr	x2, [sp, 176]
	mov	x12, x19
	ldr	w21, [sp, 576]
	mov	w13, w23
	ldr	w19, [sp, 184]
	mov	w8, w14
	b	.L168
.L398:
	sub	w1, w0, w21
	cmp	w1, 15
	ble	.L98
	sub	w1, w10, w13
	add	w8, w13, 31
	sub	w7, w1, #32
	cmp	w10, w8
	ldp	w1, w2, [sp, 160]
	mov	x26, x23
	ldr	x3, [sp, 272]
	str	w13, [sp, 312]
	smull	x14, w21, w1
	and	w1, w7, -32
	smull	x11, w2, w21
	add	w1, w1, w4
	ldr	x2, [sp, 168]
	csel	w18, w13, w1, le
	sub	x1, x3, x14
	add	x3, x3, w13, sxtw
	sxtw	x5, w18
	add	x2, x11, x2
	str	x5, [sp, 504]
	lsl	x5, x1, 3
	neg	x1, x1, lsl 3
	stp	x1, x5, [sp, 288]
	add	x1, x28, x2, lsl 3
	str	x1, [sp, 280]
	add	x1, x24, x3, lsl 3
	ldr	w23, [sp, 364]
	mov	x6, x14
	str	x1, [sp, 480]
	mov	x27, x14
	ldr	w1, [sp, 256]
	mov	x14, x11
	str	w0, [sp, 320]
	sub	w1, w25, w1
	str	w1, [sp, 304]
	str	w18, [sp, 344]
	str	w21, [sp, 528]
	str	w8, [sp, 536]
	str	w7, [sp, 544]
	str	w4, [sp, 552]
.L135:
	ldr	w0, [sp, 536]
	cmp	w10, w0
	ble	.L100
	ldr	x9, [sp, 168]
	add	w2, w21, 4
	ldp	w7, w18, [sp, 160]
	add	w1, w21, 8
	ldr	w3, [sp, 544]
	add	w0, w21, 12
	ldr	w4, [sp, 552]
	and	w3, w3, -32
	ldr	w22, [sp, 312]
	ldr	x8, [sp, 272]
	add	w3, w3, w4
	smull	x5, w0, w7
	str	w3, [sp, 192]
	smull	x4, w2, w7
	mov	w19, w22
	smull	x3, w1, w7
	sub	x5, x5, x8
	smaddl	x2, w18, w2, x9
	sub	x4, x4, x8
	smaddl	x1, w18, w1, x9
	sub	x3, x3, x8
	smaddl	x0, w18, w0, x9
	mov	x22, x14
	add	x2, x28, x2, lsl 3
	lsl	x4, x4, 3
	add	x1, x28, x1, lsl 3
	mov	w14, w7
	ldr	x15, [sp, 480]
	add	x0, x28, x0, lsl 3
	str	x2, [sp, 152]
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
	b	.L163
.L164:
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
	ldr	x1, [sp, 152]
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
	beq	.L410
.L163:
	ldr	x0, [sp, 248]
	asr	w20, w19, 3
	mov	w28, 8
	mov	w24, 2048
	sbfiz	x20, x20, 14, 32
	ldr	x0, [x0, 16]
	ldr	x0, [x0]
	add	x20, x0, x20
	cbnz	x0, .L164
	mov	x20, x15
	mov	w28, w14
	mov	w24, 8
	b	.L164
.L410:
	ldr	x24, [sp, 232]
	mov	x14, x22
	ldr	x28, [sp, 424]
	ldr	x6, [sp, 576]
	ldr	w10, [sp, 224]
	ldr	w21, [sp, 472]
.L100:
	ldr	w0, [sp, 344]
	cmp	w10, w0
	ble	.L141
	ldr	x1, [sp, 504]
	str	x14, [sp, 424]
	ldr	x2, [sp, 128]
	add	x0, x6, x1
	add	x13, x1, x27
	ldr	w20, [sp, 344]
	ldr	x1, [sp, 280]
	add	x15, x24, x0, lsl 3
	ldr	x22, [sp, 144]
	add	x1, x1, x2
	str	x1, [sp, 472]
	str	w21, [sp, 576]
	str	x6, [sp, 592]
	str	x27, [sp, 720]
	mov	x27, x26
	b	.L140
.L138:
	ldr	x1, [sp, 280]
	mov	x5, x15
	ldp	w6, w2, [sp, 160]
	str	x15, [sp, 152]
	ldr	w0, [sp, 304]
	add	w20, w20, 8
	str	w10, [sp, 176]
	str	x13, [sp, 184]
	bl	update16x8_sve
	ldr	x15, [sp, 152]
	ldr	x13, [sp, 184]
	add	x15, x15, 64
	ldr	w10, [sp, 176]
	add	x13, x13, 8
	cmp	w10, w20
	ble	.L411
.L140:
	ldr	x0, [sp, 248]
	sub	w6, w10, w20
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L412
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L160:
	cmp	w6, 7
	bgt	.L138
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
	str	w1, [sp, 152]
	str	w10, [sp, 756]
	str	x13, [sp, 760]
	str	x15, [sp, 768]
	str	w20, [sp, 792]
	.p2align 3,,7
.L144:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w25, w18
	ble	.L143
	ldr	w1, [sp, 136]
	cmp	w1, w23
	ble	.L225
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
	b	.L153
	.p2align 2,,3
.L226:
	mov	w1, w2
.L153:
	ldr	w2, [sp, 216]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x5, x4, x19
	cmp	w2, 2
	bls	.L413
	ldp	q1, q2, [x10]
	mov	w11, w21
	ldr	q5, [x10, x30]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 800]
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
	stp	q1, q2, [sp, 800]
	cbz	w5, .L158
.L159:
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
	beq	.L151
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
	tbz	x11, 0, .L158
.L151:
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
.L158:
	ldr	x4, [sp, 232]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x10, x10, x4
	ldr	x4, [sp, 224]
	add	x15, x15, x4
	add	x16, x16, x4
	ldr	w4, [sp, 136]
	cmp	w2, w4
	blt	.L226
	ldp	x24, x27, [sp, 176]
	add	w1, w1, 1
	ldr	x5, [sp, 208]
	ldr	w4, [sp, 192]
	ldr	w11, [sp, 200]
.L149:
	sxtw	x13, w1
	ldr	x1, [sp, 168]
	sub	x14, x13, x1
	mul	x10, x8, x14
	madd	x14, x14, x7, x3
	.p2align 3,,7
.L157:
	ldr	d0, [x5, x13, lsl 3]
	cmp	w6, 1
	beq	.L227
	ldr	q2, [x14]
	sxtw	x1, w11
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w4, 1
	bls	.L155
	ldr	q2, [x14, 16]
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w4, 3
	bne	.L155
	ldr	q2, [x14, 32]
	ldr	q1, [sp, 832]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 832]
.L155:
	cbz	w9, .L156
.L154:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L156:
	add	x13, x13, 1
	add	x10, x10, x8
	add	x14, x14, x7
	cmp	w25, w13
	bgt	.L157
.L143:
	cmp	w6, 1
	beq	.L224
	ldr	q0, [x17]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17]
	cmp	w4, 1
	bls	.L147
	ldr	q0, [x17, 16]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 16]
	cmp	w4, 3
	bne	.L147
	ldr	q0, [x17, 32]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 32]
.L147:
	sxtw	x1, w11
	cbz	w9, .L148
.L146:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x24, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x24, x2, lsl 3]
.L148:
	ldr	x1, [sp, 120]
	add	x12, x12, x22
	add	x19, x19, x27
	subs	w26, w26, #1
	add	x17, x17, x1
	ldr	x1, [sp, 112]
	add	x5, x5, x1
	bne	.L144
	ldr	x13, [sp, 760]
	ldr	x15, [sp, 768]
	add	x13, x13, 8
	ldr	w20, [sp, 792]
	ldr	w10, [sp, 756]
	add	x15, x15, 64
	add	w20, w20, 8
	cmp	w10, w20
	bgt	.L140
.L411:
	ldr	x14, [sp, 424]
	mov	x26, x27
	ldr	x6, [sp, 592]
	ldr	x27, [sp, 720]
	ldr	w21, [sp, 576]
.L141:
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
	bgt	.L135
	mov	w19, w21
	ldr	w13, [sp, 312]
	ldr	w0, [sp, 320]
	mov	x23, x26
	ldr	w21, [sp, 528]
.L98:
	add	w1, w19, 7
	cmp	w0, w1
	ble	.L97
	ldr	w3, [sp, 160]
	sub	w1, w10, w13
	ldr	x8, [sp, 168]
	sub	w2, w1, #32
	add	w5, w13, 32
	add	w6, w13, 31
	smull	x11, w3, w19
	ldr	w3, [sp, 164]
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
	ldr	w3, [sp, 256]
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
.L103:
	ldr	w0, [sp, 720]
	cmp	w15, w0
	ble	.L133
	ldr	w3, [sp, 756]
	and	w1, w14, -32
	ldr	x4, [sp, 168]
	add	w1, w1, w3
	ldr	w3, [sp, 164]
	add	w0, w26, 4
	str	w1, [sp, 184]
	ldr	w1, [sp, 160]
	ldr	x19, [sp, 536]
	ldr	w27, [sp, 472]
	smull	x1, w0, w1
	mov	x20, x19
	smaddl	x0, w3, w0, x4
	mov	x19, x2
	ldr	x3, [sp, 272]
	add	x0, x25, x0, lsl 3
	str	x0, [sp, 152]
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
	b	.L131
.L129:
	str	x8, [sp, 200]
	bl	update4x32_sve
	ldr	x0, [sp, 176]
	mov	w5, 2048
	ldr	x1, [sp, 152]
	add	x6, x0, x20
	ldr	x8, [sp, 200]
	mov	w4, 8
	ldr	w0, [sp, 224]
	add	w15, w15, 32
	ldr	w7, [sp, 160]
	mov	x3, x8
	ldr	w2, [sp, 164]
	add	x20, x20, 256
	bl	update4x32_sve
	ldr	w0, [sp, 184]
	cmp	w15, w0
	beq	.L414
.L131:
	ldr	x0, [sp, 248]
	asr	w8, w15, 3
	ldr	x1, [sp, 192]
	sbfiz	x8, x8, 14, 32
	ldr	x0, [x0, 16]
	add	x6, x20, x14
	ldp	w7, w2, [sp, 160]
	mov	w5, 2048
	ldr	x12, [x0]
	mov	w4, 8
	ldr	w0, [sp, 224]
	add	x8, x12, x8
	mov	x3, x8
	cbnz	x12, .L129
	mov	x4, x7
	mov	x3, x20
	mov	w5, 8
	str	w7, [sp, 160]
	bl	update4x32_sve
	add	w15, w15, 32
	ldr	x1, [sp, 176]
	mov	x3, x20
	ldr	w4, [sp, 160]
	mov	w5, 8
	add	x6, x1, x20
	ldr	w0, [sp, 224]
	ldr	x1, [sp, 152]
	mov	w7, w4
	ldr	w2, [sp, 164]
	add	x20, x20, 256
	bl	update4x32_sve
	ldr	w0, [sp, 184]
	cmp	w15, w0
	bne	.L131
.L414:
	mov	x0, x22
	mov	w15, w18
	mov	x22, x14
	mov	x2, x19
	mov	w14, w21
	mov	w18, w27
	mov	x21, x0
.L133:
	ldr	w0, [sp, 480]
	cmp	w15, w0
	ble	.L109
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
	b	.L108
.L106:
	ldr	x1, [sp, 192]
	mov	x5, x13
	ldp	w6, w2, [sp, 160]
	str	x13, [sp, 152]
	ldr	w0, [sp, 224]
	add	w20, w20, 8
	str	w15, [sp, 176]
	add	x26, x26, 8
	str	x10, [sp, 184]
	bl	update8x8_sve
	ldr	x13, [sp, 152]
	ldr	w15, [sp, 176]
	ldr	x10, [sp, 184]
	add	x13, x13, 64
	cmp	w15, w20
	ble	.L415
.L108:
	ldr	x0, [sp, 248]
	sub	w5, w15, w20
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L416
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L128:
	cmp	w5, 7
	bgt	.L106
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
	str	x6, [sp, 152]
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
.L112:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w23, w30
	ble	.L111
	cmp	w18, w28
	ble	.L221
	ldr	x2, [sp, 128]
	mov	x10, x3
	ldr	x1, [sp, 152]
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
	b	.L121
.L222:
	mov	w1, w2
.L121:
	ldr	w2, [sp, 208]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x6, x4, x19
	cmp	w2, 2
	bls	.L417
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
	cbz	w26, .L126
.L127:
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
	beq	.L119
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
	tbz	x8, 0, .L126
.L119:
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
.L126:
	ldr	x4, [sp, 216]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x15, x15, x13
	add	x16, x16, x13
	add	x10, x10, x4
	cmp	w2, w18
	blt	.L222
	ldp	x22, x14, [sp, 280]
	add	w1, w1, 1
	ldr	x24, [sp, 232]
	ldr	x6, [sp, 304]
	ldr	x8, [sp, 320]
	ldr	w4, [sp, 296]
	ldr	w11, [sp, 312]
.L117:
	sxtw	x15, w1
	ldr	w20, [sp, 176]
	ldr	x1, [sp, 168]
	str	w21, [sp, 232]
	ldr	x21, [sp, 152]
	sub	x16, x15, x1
	ldr	x1, [sp, 200]
	stp	x24, x25, [sp, 280]
	ldr	w25, [sp, 184]
	mov	x24, x1
	mul	x10, x16, x1
	madd	x16, x16, x7, x3
	.p2align 3,,7
.L125:
	ldr	d0, [x21, x15, lsl 3]
	cmp	w5, 1
	beq	.L223
	ldr	q2, [x16]
	sxtw	x1, w11
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w20, 1
	bls	.L123
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w20, 3
	bne	.L123
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 832]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 832]
.L123:
	cbz	w25, .L124
.L122:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L124:
	add	x15, x15, 1
	add	x10, x10, x24
	add	x16, x16, x7
	cmp	w23, w15
	bgt	.L125
	ldp	x24, x25, [sp, 280]
	ldr	w21, [sp, 232]
.L111:
	cmp	w5, 1
	beq	.L220
	ldr	q0, [x14]
	ldr	q1, [sp, 800]
	ldr	w1, [sp, 176]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14]
	cmp	w1, 1
	bls	.L115
	ldr	q0, [x14, 16]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 16]
	cmp	w1, 3
	bne	.L115
	ldr	q0, [x14, 32]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 32]
.L115:
	ldr	w1, [sp, 184]
	cbz	w1, .L116
	sxtw	x1, w11
.L114:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x24, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x24, x2, lsl 3]
.L116:
	ldr	x1, [sp, 144]
	add	x19, x19, x22
	ldr	x2, [sp, 112]
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	subs	w17, w17, #1
	add	x14, x14, x1
	ldr	x1, [sp, 152]
	add	x1, x1, x2
	str	x1, [sp, 152]
	bne	.L112
	mov	w20, w4
	ldr	w15, [sp, 796]
	mov	x13, x6
	mov	x26, x8
	add	w20, w20, 8
	mov	x10, x9
	add	x13, x13, 64
	add	x26, x26, 8
	cmp	w15, w20
	bgt	.L108
.L415:
	ldr	x2, [sp, 768]
	mov	w18, w28
	ldr	w26, [sp, 760]
	mov	x28, x22
	ldr	x22, [sp, 776]
	mov	x21, x10
	ldr	w14, [sp, 784]
.L109:
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
	bne	.L103
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
	b	.L97
	.p2align 2,,3
.L227:
	mov	x1, 0
	b	.L154
.L224:
	mov	x1, 0
	b	.L146
.L225:
	ldr	w1, [sp, 256]
	b	.L149
.L413:
	mov	w11, 0
	mov	w2, 0
	b	.L159
.L412:
	ldr	x0, [sp, 296]
	mov	x8, x22
	ldr	w4, [sp, 160]
	add	x3, x15, x0
	b	.L160
.L223:
	mov	x1, 0
	b	.L122
.L220:
	mov	x1, 0
	b	.L114
.L221:
	ldr	w1, [sp, 256]
	b	.L117
.L416:
	ldr	x0, [sp, 344]
	ldr	x8, [sp, 144]
	add	x3, x0, x13
	ldr	w4, [sp, 160]
	b	.L128
.L417:
	mov	w8, 0
	mov	w2, 0
	b	.L127
.L408:
	ldr	w0, [sp, 260]
	add	w21, w21, 32
	mov	w13, 0
	sub	w0, w0, w21
	str	w0, [sp, 520]
	b	.L166
.L383:
	ldr	d8, [sp, 96]
	.cfi_restore 72
	mov	x19, x28
	ldr	x20, [sp, 744]
	mov	x27, x23
	ldr	w25, [sp, 736]
	ldr	w22, [sp, 740]
	ldr	w21, [sp, 752]
	b	.L92
.L394:
	ldp	x19, x20, [sp, 16]
	.cfi_restore 20
	.cfi_restore 19
	ldp	x21, x22, [sp, 32]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
.L28:
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
.L93:
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
	b	.L208
.L392:
	str	d8, [sp, 96]
	.cfi_offset 72, -960
	b	.L211
.L215:
	mov	w11, 0
	b	.L76
	.p2align 2,,3
.L210:
	.cfi_restore 72
	bl	GOMP_barrier
	b	.L92
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
	cbz	w0, .L421
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
.L420:
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
	bne	.L420
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L419:
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
.L421:
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
	b	.L419
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
	cbz	w1, .L474
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 172]
.L474:
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
	blt	.L427
.L472:
	madd	w0, w1, w3, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L428
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
.L431:
	cmp	w24, 8
	mov	w0, 8
	csel	w6, w24, w0, le
	cbz	x21, .L524
	cmp	w27, 0
	ble	.L432
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
.L465:
	mov	x1, x26
	mov	x2, x22
	mov	x0, x19
	cmp	w24, 0
	ble	.L434
	bl	memcpy
	cmp	w24, 7
	bgt	.L525
.L434:
	add	x0, x19, x28
	mov	x2, x21
	mov	w1, 0
	add	x19, x19, 64
	bl	memset
	add	x26, x26, x20
	cmp	x19, x27
	bne	.L465
	ldp	x21, x22, [sp, 216]
	mov	x30, x25
	ldr	x28, [sp, 136]
	ldr	x19, [sp, 232]
	ldr	w27, [sp, 208]
.L463:
	ldr	w0, [sp, 172]
	mov	w13, w0
	tbnz	x0, 0, .L526
.L435:
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
.L441:
	stp	q17, q17, [x5]
	stp	q17, q17, [x5, 32]
	stp	q17, q17, [x5, 64]
	stp	q17, q17, [x5, 96]
	stp	q17, q17, [x5, 128]
	stp	q17, q17, [x5, 160]
	stp	q17, q17, [x5, 192]
	stp	q17, q17, [x5, 224]
	cmp	w7, 3
	ble	.L527
	movi	v16.2d, 0
	cmp	w8, 0
	ble	.L480
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
.L461:
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
	bne	.L461
.L460:
	stp	q8, q31, [sp, 288]
	stp	q30, q29, [sp, 320]
	stp	q28, q27, [sp, 352]
	stp	q26, q25, [sp, 384]
	stp	q24, q23, [sp, 416]
	stp	q22, q21, [sp, 448]
	stp	q20, q19, [sp, 480]
	stp	q18, q16, [sp, 512]
.L462:
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
	beq	.L451
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
	b	.L452
	.p2align 2,,3
.L455:
	add	x1, x1, 64
	add	x9, x9, x19
	cmp	w4, 2
	beq	.L478
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
.L453:
	add	x0, x0, 64
	ldr	x12, [sp, 136]
	add	x6, x6, x12
.L452:
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
	ble	.L454
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
	bne	.L454
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
.L454:
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
	bne	.L455
.L451:
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
	bgt	.L441
	ldr	x30, [sp, 136]
	ldr	x20, [sp, 224]
	ldr	w24, [sp, 232]
.L442:
	cmp	w24, 0
	ble	.L432
	ldr	x3, [sp, 144]
	str	x19, [sp, 208]
	ldr	x26, [sp, 160]
	mov	x25, x30
	ldr	x19, [sp, 184]
	str	x21, [sp, 136]
.L438:
	mov	x1, x21
	mov	x0, x3
	mov	x2, x19
	add	x21, x21, 64
	bl	memcpy
	add	x3, x0, x20
	cmp	x26, x21
	bne	.L438
	ldr	x21, [sp, 136]
	mov	x30, x25
	ldr	x19, [sp, 208]
.L432:
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
	bgt	.L431
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldr	d8, [sp, 96]
	.cfi_restore 72
.L428:
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
.L527:
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
	ble	.L462
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
.L458:
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
	ble	.L456
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
	bne	.L456
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
.L456:
	add	x0, x0, 64
	add	x4, x4, 8
	mov	v8.16b, v23.16b
	mov	v16.16b, v28.16b
	mov	v19.16b, v2.16b
	cmp	x0, x2
	bne	.L458
	stp	q3, q23, [sp, 288]
	stp	q28, q2, [sp, 320]
	cbz	w1, .L443
	str	q1, [sp, 400]
.L443:
	cbz	w10, .L444
	str	q20, [sp, 384]
.L444:
	cbz	w12, .L445
	str	q18, [sp, 368]
.L445:
	cbz	w11, .L446
	str	q4, [sp, 352]
.L446:
	cbz	w16, .L447
	str	q24, [sp, 464]
.L447:
	cbz	w20, .L448
	str	q27, [sp, 448]
.L448:
	cbz	w18, .L449
	str	q26, [sp, 432]
.L449:
	cbz	w17, .L462
	str	q25, [sp, 416]
	b	.L462
.L480:
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
	b	.L460
.L526:
	cmp	w27, 15
	ble	.L476
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
.L436:
	ldr	w1, [sp, 168]
	mov	w0, w26
	mov	x2, x21
	mov	x3, x19
	add	w26, w26, 16
	bl	solve16x8_panel_sve
	ldr	x0, [sp, 192]
	add	x21, x21, x0
	cmp	w26, w20
	bne	.L436
	ldr	w0, [sp, 264]
	mov	x21, x19
	ldr	x20, [sp, 136]
	mov	x30, x25
	ldr	x19, [sp, 208]
	mov	w13, w0
	cmp	w27, w0
	bgt	.L435
	b	.L442
	.p2align 2,,3
.L524:
	cmp	w24, 0
	ble	.L432
	cmp	w27, 0
	ble	.L432
	ldp	x7, x8, [sp, 144]
	lsl	x9, x19, 3
	ldr	x4, [sp, 200]
	add	x6, x8, w6, uxtw
.L469:
	ldr	d0, [x7]
	ldr	d1, [x28]
	fdiv	d0, d0, d1
	str	d0, [x7]
	cmp	w27, 1
	beq	.L468
	ldr	x0, [sp, 248]
	add	x3, x28, x30
	ldr	x2, [sp, 176]
	add	x0, x0, x8
	add	x5, x28, x9
	mov	w1, 1
	add	x0, x2, x0, lsl 3
	.p2align 3,,7
.L471:
	movi	d1, #0
	mov	x10, x7
	mov	x2, 0
	.p2align 3,,7
.L470:
	ldr	d2, [x5, x2, lsl 3]
	add	x2, x2, 1
	ldr	d0, [x10]
	add	x10, x10, x20
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w1, w2
	bgt	.L470
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
	bne	.L471
.L468:
	add	x8, x8, 1
	add	x7, x7, 8
	cmp	x6, x8
	bne	.L469
	b	.L432
.L427:
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 72
	add	w1, w1, 1
	mov	w0, 0
	b	.L472
.L525:
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
	b	.L464
	.p2align 2,,3
.L528:
	ldr	x2, [sp, 184]
	mov	x1, x26
	mov	x0, x25
	bl	memcpy
.L464:
	ldr	x0, [sp, 160]
	add	x25, x25, 64
	add	x26, x26, x20
	cmp	x25, x0
	bne	.L528
	ldr	x30, [sp, 136]
	b	.L463
.L476:
	mov	w13, 0
	b	.L435
.L478:
	mov	w11, 0
	b	.L453
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
	ble	.L534
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
	bls	.L531
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	str	xzr, [sp, 64]
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L532
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L532:
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
.L531:
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
.L534:
	ret
	.cfi_endproc
.LFE4371:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (gcc for openEuler 3.0.2) 12.3.1"
	.section	.note.GNU-stack,"",@progbits
