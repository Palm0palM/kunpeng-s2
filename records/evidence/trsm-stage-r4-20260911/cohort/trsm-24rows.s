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
	.type	update24x8_sve, %function
update24x8_sve:
.LFB4284:
	.cfi_startproc
	stp	x29, x30, [sp, -144]!
	.cfi_def_cfa_offset 144
	.cfi_offset 29, -144
	.cfi_offset 30, -136
	mov	x29, sp
	stp	d8, d9, [sp, 96]
	str	w6, [sp, 140]
	cmp	w0, 0
	.cfi_offset 72, -48
	.cfi_offset 73, -40
	ble	.L21
	sxtw	x6, w2
	mov	w30, 6
	mov	w18, 10
	mov	w17, 11
	mov	w16, 12
	mov	w15, 13
	mov	w14, 14
	mov	w13, 18
	mov	w12, 19
	mov	w11, 20
	mov	w10, 21
	mov	w9, 22
	mov	w8, 23
	smull	x30, w2, w30
	smull	x18, w2, w18
	stp	x19, x20, [sp, 16]
	.cfi_offset 20, -120
	.cfi_offset 19, -128
	smull	x17, w2, w17
	mov	z1.d, #0
	add	x20, x6, x2, sxtw 1
	smull	x16, w2, w16
	smull	x15, w2, w15
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -72
	.cfi_offset 25, -80
	smull	x14, w2, w14
	ptrue	p0.b, all
	lsl	x26, x6, 3
	lsl	x25, x6, 4
	smull	x13, w2, w13
	add	x19, x6, x6, lsl 2
	smull	x12, w2, w12
	sub	w0, w0, #1
	smull	x11, w2, w11
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -104
	.cfi_offset 21, -112
	smull	x10, w2, w10
	mov	z2.d, z1.d
	smull	x9, w2, w9
	sub	x22, x25, x6
	smull	x2, w2, w8
	add	x21, x25, x6
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -88
	.cfi_offset 23, -96
	sub	x24, x26, x6
	add	x23, x26, x6
	mov	z3.d, z1.d
	add	x7, x1, 8
	sbfiz	x4, x4, 3, 32
	add	x0, x7, x0, uxtw 3
	lsl	x24, x24, 3
	lsl	x23, x23, 3
	lsl	x22, x22, 3
	lsl	x21, x21, 3
	lsl	x20, x20, 3
	lsl	x19, x19, 3
	lsl	x30, x30, 3
	lsl	x18, x18, 3
	lsl	x17, x17, 3
	lsl	x16, x16, 3
	lsl	x15, x15, 3
	lsl	x14, x14, 3
	lsl	x13, x13, 3
	lsl	x12, x12, 3
	lsl	x11, x11, 3
	lsl	x10, x10, 3
	lsl	x9, x9, 3
	lsl	x2, x2, 3
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -56
	.cfi_offset 27, -64
	lsl	x28, x6, 5
	mov	z4.d, z1.d
	lsl	x27, x6, 6
	lsl	x6, x6, 7
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
	mov	z25.d, z1.d
	mov	z26.d, z1.d
	mov	z27.d, z1.d
	mov	z28.d, z1.d
	mov	z29.d, z1.d
	mov	z30.d, z1.d
	mov	z31.d, z1.d
	mov	z8.d, z1.d
	stp	d10, d11, [sp, 112]
	.cfi_offset 75, -24
	.cfi_offset 74, -32
	.p2align 3,,7
.L20:
	add	x7, x1, x26
	ld1d	z0.d, p0/z, [x3]
	add	x8, x1, x25
	ld1rd	z9.d, p0/z, [x8]
	ld1rd	z11.d, p0/z, [x7]
	fmla	z30.d, p0/m, z0.d, z9.d
	add	x7, x1, x20
	ld1rd	z9.d, p0/z, [x7]
	add	x8, x1, x28
	fmla	z29.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x8]
	add	x7, x1, x19
	fmla	z28.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7]
	add	x8, x1, x30
	fmla	z27.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x8]
	add	x7, x1, x24
	fmla	z26.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7]
	add	x8, x1, x27
	fmla	z25.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x8]
	add	x7, x1, x23
	fmla	z24.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7]
	add	x8, x1, x18
	fmla	z23.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x8]
	add	x7, x1, x17
	fmla	z22.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7]
	add	x8, x1, x16
	fmla	z21.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x8]
	add	x7, x1, x15
	fmla	z20.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7]
	add	x8, x1, x14
	fmla	z19.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x8]
	add	x7, x1, x22
	fmla	z18.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7]
	add	x8, x1, x6
	fmla	z17.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x8]
	add	x7, x1, x21
	fmla	z16.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7]
	add	x8, x1, x13
	fmla	z7.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x8]
	add	x7, x1, x12
	fmla	z6.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7]
	add	x8, x1, x11
	add	x7, x1, x10
	fmla	z5.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x8]
	ld1rd	z10.d, p0/z, [x1]
	add	x8, x1, x9
	fmla	z4.d, p0/m, z0.d, z9.d
	ld1rd	z9.d, p0/z, [x7]
	add	x7, x1, x2
	add	x1, x1, 8
	fmla	z8.d, p0/m, z0.d, z10.d
	fmla	z3.d, p0/m, z0.d, z9.d
	ld1rd	z10.d, p0/z, [x8]
	ld1rd	z9.d, p0/z, [x7]
	add	x3, x3, x4
	fmla	z31.d, p0/m, z0.d, z11.d
	fmla	z2.d, p0/m, z0.d, z10.d
	fmla	z1.d, p0/m, z0.d, z9.d
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
	ldp	d10, d11, [sp, 112]
	.cfi_restore 75
	.cfi_restore 74
.L19:
	ptrue	p0.b, all
	ld1d	z0.d, p0/z, [x5]
	ldr	w0, [sp, 140]
	fsub	z0.d, z0.d, z8.d
	st1d	z0.d, p0, [x5]
	sbfiz	x1, x0, 3, 32
	add	x2, x5, x1
	ld1d	z0.d, p0/z, [x2]
	fsub	z0.d, z0.d, z31.d
	add	x0, x2, x1
	st1d	z0.d, p0, [x2]
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z30.d
	add	x2, x0, x1
	st1d	z0.d, p0, [x0]
	ld1d	z0.d, p0/z, [x2]
	fsub	z0.d, z0.d, z29.d
	add	x0, x2, x1
	st1d	z0.d, p0, [x2]
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z28.d
	add	x2, x0, x1
	st1d	z0.d, p0, [x0]
	ld1d	z0.d, p0/z, [x2]
	fsub	z0.d, z0.d, z27.d
	add	x0, x2, x1
	st1d	z0.d, p0, [x2]
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z26.d
	add	x2, x0, x1
	st1d	z0.d, p0, [x0]
	ld1d	z0.d, p0/z, [x2]
	fsub	z0.d, z0.d, z25.d
	add	x0, x2, x1
	st1d	z0.d, p0, [x2]
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z24.d
	add	x2, x0, x1
	st1d	z0.d, p0, [x0]
	ld1d	z0.d, p0/z, [x2]
	fsub	z0.d, z0.d, z23.d
	add	x0, x2, x1
	st1d	z0.d, p0, [x2]
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z22.d
	add	x2, x0, x1
	st1d	z0.d, p0, [x0]
	ld1d	z0.d, p0/z, [x2]
	fsub	z0.d, z0.d, z21.d
	add	x0, x2, x1
	st1d	z0.d, p0, [x2]
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z20.d
	add	x2, x0, x1
	st1d	z0.d, p0, [x0]
	ld1d	z0.d, p0/z, [x2]
	fsub	z0.d, z0.d, z19.d
	add	x0, x2, x1
	st1d	z0.d, p0, [x2]
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z18.d
	add	x2, x0, x1
	st1d	z0.d, p0, [x0]
	ld1d	z0.d, p0/z, [x2]
	fsub	z0.d, z0.d, z17.d
	add	x0, x2, x1
	st1d	z0.d, p0, [x2]
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z16.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z7.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z6.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z5.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z4.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z3.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z2.d
	st1d	z0.d, p0, [x0]
	add	x0, x0, x1
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z1.d
	st1d	z0.d, p0, [x0]
	ldp	d8, d9, [sp, 96]
	ldp	x29, x30, [sp], 144
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 72
	.cfi_restore 73
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
	mov	z25.d, z1.d
	mov	z26.d, z1.d
	mov	z27.d, z1.d
	mov	z28.d, z1.d
	mov	z29.d, z1.d
	mov	z30.d, z1.d
	mov	z31.d, z1.d
	mov	z8.d, z1.d
	b	.L19
	.cfi_endproc
.LFE4284:
	.size	update24x8_sve, .-update24x8_sve
	.align	2
	.p2align 4,,11
	.type	update4x8_sve, %function
update4x8_sve:
.LFB4281:
	.cfi_startproc
	cmp	w0, 0
	ble	.L27
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
.L26:
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
.LFE4281:
	.size	update4x8_sve, .-update4x8_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4287:
	.cfi_startproc
	sub	sp, sp, #656
	.cfi_def_cfa_offset 656
	stp	x29, x30, [sp]
	.cfi_offset 29, -656
	.cfi_offset 30, -648
	mov	x29, sp
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -624
	.cfi_offset 22, -616
	ldp	x2, x21, [x0]
	str	x2, [sp, 192]
	ldr	w2, [x0, 24]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -640
	.cfi_offset 20, -632
	ldp	w20, w1, [x0, 36]
	str	w2, [sp, 112]
	ldr	w2, [x0, 28]
	str	w2, [sp, 148]
	ldr	w2, [x0, 32]
	str	w2, [sp, 100]
	str	w1, [sp, 116]
	str	x0, [sp, 136]
	cbz	w1, .L169
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	csinc	w0, w0, wzr, eq
	str	w0, [sp, 116]
.L169:
	ldr	w0, [sp, 112]
	cmp	w0, 0
	ble	.L29
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -600
	.cfi_offset 23, -608
	mov	w22, w20
	add	x24, sp, 592
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -584
	.cfi_offset 25, -592
	mov	x25, 0
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -568
	.cfi_offset 27, -576
	bl	omp_get_num_threads
	mov	w19, w0
	str	w0, [sp, 384]
	bl	omp_get_thread_num
	ldr	w10, [sp, 148]
	mov	w15, w0
	ldr	w11, [sp, 100]
	sxtw	x8, w20
	adds	w2, w10, 7
	add	w1, w10, 14
	csel	w0, w1, w2, mi
	add	x4, x8, 1
	mov	w5, 192
	mov	w2, 24
	asr	w0, w0, 3
	sxtw	x9, w11
	lsl	x13, x4, 4
	sbfiz	x17, x11, 1, 32
	sub	x7, x8, x8, lsl 2
	smull	x11, w11, w5
	sdiv	w1, w0, w19
	smull	x5, w20, w5
	smull	x2, w20, w2
	stp	x11, x5, [sp, 472]
	add	x5, x13, 32
	str	x5, [sp, 328]
	lsl	x5, x7, 6
	msub	w0, w1, w19, w0
	add	x6, x9, 1
	ldr	x16, [sp, 192]
	cmp	w15, w0
	str	x5, [sp, 544]
	add	x5, x2, 16
	cinc	w1, w1, lt
	str	x5, [sp, 336]
	add	x5, x2, 32
	add	x2, x2, 48
	lsl	x14, x9, 3
	add	x4, x16, 8
	stp	x5, x2, [sp, 344]
	lsl	x2, x6, 11
	sbfiz	x11, x20, 3, 32
	str	x2, [sp, 520]
	add	x2, x4, x14
	str	x2, [sp, 248]
	mul	w2, w1, w15
	add	x4, x14, 8
	str	x4, [sp, 496]
	add	w0, w0, w2
	add	x4, x17, x9
	csel	w0, w2, w0, lt
	lsl	x2, x9, 7
	add	w1, w1, w0
	str	x2, [sp, 368]
	neg	x2, x8, lsl 7
	str	x4, [sp, 408]
	lsl	x4, x8, 8
	str	w0, [sp, 488]
	lsl	w0, w0, 3
	add	x12, x13, 16
	str	x8, [sp, 152]
	add	w3, w10, 63
	str	x11, [sp, 200]
	mov	x27, x21
	str	w15, [sp, 264]
	str	w0, [sp, 268]
	str	x9, [sp, 272]
	stp	x13, x12, [sp, 312]
	str	w1, [sp, 388]
	lsl	w1, w1, 3
	str	x17, [sp, 400]
	str	x4, [sp, 512]
	lsl	x4, x9, 8
	str	x14, [sp, 528]
	str	x4, [sp, 536]
	str	x2, [sp, 552]
	lsl	x2, x8, 7
	str	x2, [sp, 464]
	str	w1, [sp, 280]
	sub	w1, w10, w0
	sxtw	x0, w0
	str	x0, [sp, 504]
	lsl	x0, x9, 6
	str	x0, [sp, 440]
	neg	x0, x8, lsl 6
	str	x0, [sp, 560]
	lsl	x0, x8, 6
	str	x0, [sp, 456]
	lsl	x0, x9, 5
	str	x0, [sp, 392]
	neg	x0, x8, lsl 5
	str	x0, [sp, 568]
	lsl	x0, x8, 5
	str	x0, [sp, 424]
	asr	w0, w3, 6
	str	w0, [sp, 284]
	add	x0, x11, 16
	str	x0, [sp, 288]
	add	x0, x11, 32
	str	xzr, [sp, 128]
	stp	xzr, x16, [sp, 232]
	str	x9, [sp, 256]
	str	x0, [sp, 296]
	add	x0, x11, 48
	str	x0, [sp, 304]
	str	w1, [sp, 380]
.L52:
	ldr	w2, [sp, 112]
	add	w0, w25, 256
	str	w25, [sp, 96]
	sub	w1, w2, w25
	str	w25, [sp, 144]
	cmp	w1, 255
	ldr	w1, [sp, 488]
	csel	w26, w0, w2, gt
	ldr	w0, [sp, 388]
	cmp	w0, w1
	bgt	.L317
	bl	GOMP_barrier
	ldr	x0, [sp, 136]
	ldr	x0, [x0, 16]
	ldr	x0, [x0]
	cbz	x0, .L168
.L160:
	bl	GOMP_barrier
.L168:
	ldr	w0, [sp, 112]
	cmp	w26, w0
	bge	.L54
	ldr	w0, [sp, 112]
	add	w1, w0, 63
	subs	w1, w1, w26
	add	w0, w1, 63
	csel	w0, w0, w1, mi
	ldr	w1, [sp, 148]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L54
	ldr	w1, [sp, 284]
	ldr	w2, [sp, 384]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	ldr	w2, [sp, 264]
	cmp	w2, w0
	bcc	.L55
.L159:
	ldr	w2, [sp, 264]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L318
.L54:
	bl	GOMP_barrier
	add	x25, x25, 256
	ldr	x1, [sp, 128]
	ldr	x0, [sp, 512]
	add	x1, x1, x0
	str	x1, [sp, 128]
	ldr	x1, [sp, 232]
	add	x0, x1, x0
	str	x0, [sp, 232]
	ldr	x1, [sp, 240]
	ldr	x0, [sp, 520]
	add	x1, x1, x0
	str	x1, [sp, 240]
	ldr	x1, [sp, 248]
	add	x0, x1, x0
	str	x0, [sp, 248]
	ldr	x0, [sp, 256]
	ldr	x1, [sp, 536]
	add	x0, x0, x1
	str	x0, [sp, 256]
	ldr	w0, [sp, 112]
	cmp	w0, w25
	bgt	.L52
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
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
	add	sp, sp, 656
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L318:
	.cfi_def_cfa_offset 656
	.cfi_offset 19, -640
	.cfi_offset 20, -632
	.cfi_offset 21, -624
	.cfi_offset 22, -616
	.cfi_offset 23, -608
	.cfi_offset 24, -600
	.cfi_offset 25, -592
	.cfi_offset 26, -584
	.cfi_offset 27, -576
	.cfi_offset 28, -568
	.cfi_offset 29, -656
	.cfi_offset 30, -648
	ldr	w3, [sp, 284]
	sub	w1, w1, #1
	ldr	w4, [sp, 96]
	mov	w19, w25
	str	w1, [sp, 492]
	sub	w4, w26, w4
	str	wzr, [sp, 228]
	udiv	w2, w0, w3
	sub	w1, w4, #1
	str	x1, [sp, 416]
	ldr	x20, [sp, 192]
	str	w4, [sp, 360]
	msub	w0, w2, w3, w0
	add	w1, w26, w2, lsl 6
	ldr	w2, [sp, 112]
	ldr	x21, [sp, 528]
	lsl	w0, w0, 6
	str	w0, [sp, 96]
	str	w1, [sp, 224]
	sub	w1, w2, w1
	str	w1, [sp, 364]
.L56:
	ldr	w3, [sp, 96]
	ldr	w2, [sp, 148]
	ldr	w0, [sp, 364]
	add	w23, w3, 64
	ldr	w28, [sp, 224]
	ldr	w4, [sp, 112]
	cmp	w0, 63
	add	w1, w28, 64
	sub	w0, w2, w3
	csel	w1, w1, w4, gt
	cmp	w0, 63
	ldr	w0, [sp, 116]
	csel	w23, w23, w2, gt
	str	w1, [sp, 104]
	cbnz	w0, .L319
.L59:
	ldr	w0, [sp, 104]
	cmp	w0, w28
	ble	.L69
	ldr	w1, [sp, 96]
	cmp	w1, w23
	bge	.L69
	sxtw	x3, w1
	smull	x0, w22, w28
	ldp	w1, w2, [sp, 100]
	stp	x20, x25, [sp, 168]
	mov	w6, w22
	str	x3, [sp, 432]
	smaddl	x1, w1, w28, x25
	sub	w28, w2, w28
	ldr	x2, [sp, 128]
	str	x21, [sp, 184]
	ldr	x21, [sp, 200]
	sub	x2, x2, x0
	add	x0, x3, x0
	lsl	x2, x2, 3
	add	x0, x27, x0, lsl 3
	stp	x0, x2, [sp, 208]
	add	x0, x20, x1, lsl 3
	ldp	x20, x3, [sp, 408]
	str	x0, [sp, 120]
	ldr	x15, [sp, 272]
	ldr	x18, [sp, 400]
	add	x3, x3, 1
	str	x3, [sp, 576]
.L133:
	cmp	w28, 4
	mov	w0, 4
	csel	w0, w28, w0, le
	cmp	w28, 3
	str	w0, [sp, 448]
	cset	w0, gt
	str	w0, [sp, 160]
	ldr	x1, [sp, 120]
	str	w28, [sp, 376]
	ldr	x0, [sp, 576]
	ldr	w13, [sp, 96]
	ldr	x22, [sp, 136]
	add	x14, x1, x0, lsl 3
	ldr	x12, [sp, 208]
	ldr	x25, [sp, 432]
.L131:
	sub	w10, w23, w13
	ldr	x0, [x22, 16]
	ldr	x3, [x0]
	cbz	x3, .L320
	asr	w0, w13, 3
	mov	x9, 8
	mov	w4, w9
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 160]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	ble	.L321
.L136:
	ldr	w0, [sp, 116]
	cbnz	w0, .L152
	movi	v16.2d, 0
	ldr	w0, [sp, 360]
	cmp	w0, 0
	ble	.L186
	mov	v17.16b, v16.16b
	lsl	x9, x9, 3
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
.L154:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, x9
	ld1r	{v7.2d}, [x0]
	ldr	d6, [x0, x15, lsl 3]
	ldr	d5, [x0, x18, lsl 3]
	fmla	v31.2d, v4.2d, v7.2d
	ldr	d1, [x0, x20, lsl 3]
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
	bne	.L154
.L153:
	ldp	q3, q2, [x12]
	add	x0, x21, x12
	ldp	q1, q0, [x12, 32]
	add	x1, x0, x21
	fsub	v3.2d, v3.2d, v31.2d
	fsub	v2.2d, v2.2d, v30.2d
	fsub	v0.2d, v0.2d, v28.2d
	fsub	v1.2d, v1.2d, v29.2d
	stp	q3, q2, [x12]
	stp	q1, q0, [x12, 32]
	ldr	q0, [x21, x12]
	fsub	v0.2d, v0.2d, v27.2d
	str	q0, [x21, x12]
	ldr	x2, [sp, 288]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v26.2d
	str	q0, [x2, x12]
	ldr	x2, [sp, 296]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v25.2d
	str	q0, [x2, x12]
	ldr	x2, [sp, 304]
	ldr	q0, [x2, x12]
	fsub	v0.2d, v0.2d, v24.2d
	str	q0, [x2, x12]
	ldr	q0, [x0, x21]
	fsub	v0.2d, v0.2d, v23.2d
	str	q0, [x0, x21]
	ldr	x0, [sp, 312]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v22.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 320]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v21.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 328]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v20.2d
	str	q0, [x0, x12]
	ldr	q0, [x21, x1]
	fsub	v0.2d, v0.2d, v19.2d
	str	q0, [x21, x1]
	ldr	x0, [sp, 336]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v18.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 344]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v17.2d
	str	q0, [x0, x12]
	ldr	x0, [sp, 352]
	ldr	q0, [x0, x12]
	fsub	v0.2d, v0.2d, v16.2d
	str	q0, [x0, x12]
.L155:
	add	w13, w13, 8
	add	x12, x12, 64
	add	x25, x25, 8
	cmp	w23, w13
	bgt	.L131
	ldr	x2, [sp, 216]
	ldr	x3, [sp, 568]
	ldr	x0, [sp, 120]
	add	x2, x2, x3
	ldr	x1, [sp, 392]
	str	x2, [sp, 216]
	ldr	w28, [sp, 376]
	ldr	x2, [sp, 208]
	add	x0, x0, x1
	ldr	x3, [sp, 424]
	sub	w28, w28, #4
	ldr	w1, [sp, 104]
	add	x2, x2, x3
	str	x0, [sp, 120]
	sub	w0, w1, w28
	str	x2, [sp, 208]
	cmp	w1, w0
	bgt	.L133
	ldp	x20, x25, [sp, 168]
	mov	w22, w6
	ldr	x21, [sp, 184]
.L69:
	ldr	w0, [sp, 228]
	ldr	w1, [sp, 492]
	cmp	w0, w1
	beq	.L54
	ldr	w0, [sp, 96]
	ldr	w1, [sp, 148]
	add	w0, w0, 64
	str	w0, [sp, 96]
	cmp	w1, w0
	ble	.L322
.L132:
	ldr	w0, [sp, 228]
	add	w0, w0, 1
	str	w0, [sp, 228]
	b	.L56
.L152:
	ldr	w2, [sp, 100]
	mov	x5, x12
	ldr	x1, [sp, 120]
	ldr	w0, [sp, 144]
	sub	w0, w26, w0
	bl	update4x8_sve
	b	.L155
.L320:
	ldr	x0, [sp, 216]
	mov	w4, w6
	ldr	x9, [sp, 152]
	add	x3, x0, x12
	ldr	w0, [sp, 160]
	cmp	w0, 0
	ccmp	w10, 7, 4, ne
	bgt	.L136
.L321:
	ldr	w0, [sp, 376]
	cmp	w0, 0
	ble	.L155
	cmp	w10, 8
	mov	w16, 8
	csel	w16, w10, w16, le
	cmp	w10, 0
	csinc	w16, w16, wzr, gt
	ldr	w1, [sp, 104]
	str	x12, [sp, 584]
	and	w8, w16, -2
	ldr	w12, [sp, 448]
	lsl	x17, x9, 3
	lsr	w5, w16, 1
	sub	w28, w1, w0
	mov	w30, 0
.L142:
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w19
	ble	.L323
	sxtw	x11, w28
	cmp	w10, 0
	ble	.L145
	ldp	x1, x7, [sp, 168]
	mov	x4, x3
	ldr	x0, [sp, 184]
	mov	x2, 0
	madd	x11, x11, x0, x1
	.p2align 3,,7
.L149:
	ldr	d0, [x11, x7, lsl 3]
	cmp	w10, 1
	ble	.L324
	dup	v3.2d, v0.d[0]
	ldr	q2, [x4]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w5, 1
	bls	.L150
	ldr	q2, [x4, 16]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
	cmp	w5, 2
	beq	.L150
	ldr	q2, [x4, 32]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w5, 3
	beq	.L150
	ldr	q2, [x4, 48]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
.L150:
	sxtw	x0, w8
	cmp	w8, w16
	beq	.L151
.L147:
	add	x1, x0, x2
	ldr	d1, [x24, x0, lsl 3]
	ldr	d2, [x3, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x24, x0, lsl 3]
.L151:
	add	x7, x7, 1
	add	x2, x2, x9
	add	x4, x4, x17
	cmp	w26, w7
	bgt	.L149
	smaddl	x0, w28, w6, x25
	cmp	w10, 1
	ble	.L184
.L325:
	lsl	x2, x0, 3
	ldr	q1, [sp, 592]
	add	x1, x27, x2
	ldr	q0, [x27, x2]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x27, x2]
	cmp	w5, 1
	bls	.L144
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 608]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w5, 2
	beq	.L144
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 624]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w5, 3
	beq	.L144
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L144:
	sxtw	x1, w8
	cmp	w8, w16
	beq	.L145
.L143:
	add	x0, x1, x0
	ldr	d1, [x24, x1, lsl 3]
	ldr	d0, [x27, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x27, x0, lsl 3]
.L145:
	add	w30, w30, 1
	add	w28, w28, 1
	cmp	w30, w12
	blt	.L142
	ldr	x12, [sp, 584]
	b	.L155
.L324:
	mov	x0, 0
	b	.L147
.L323:
	cmp	w10, 0
	ble	.L145
	smaddl	x0, w28, w6, x25
	cmp	w10, 1
	bgt	.L325
.L184:
	mov	x1, 0
	b	.L143
.L186:
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
	b	.L153
.L322:
	ldr	w0, [sp, 224]
	ldr	w1, [sp, 112]
	add	w0, w0, 64
	str	wzr, [sp, 96]
	str	w0, [sp, 224]
	sub	w0, w1, w0
	str	w0, [sp, 364]
	b	.L132
.L319:
	uxtw	x0, w1
	mov	x1, x28
	sub	w0, w0, w28
	cmp	w0, 23
	ble	.L60
	ldr	w2, [sp, 100]
	smull	x0, w22, w28
	ldrsw	x3, [sp, 96]
	mov	w10, w28
	mov	x8, x21
	mov	x28, x25
	smaddl	x1, w2, w1, x25
	mov	x25, x20
	ldr	x2, [sp, 128]
	add	x18, x20, x1, lsl 3
	mov	w20, w23
	sub	x2, x2, x0
	add	x0, x0, x3
	mov	w23, w19
	lsl	x2, x2, 3
	add	x0, x27, x0, lsl 3
	str	x2, [sp, 120]
	stp	x0, x3, [sp, 160]
.L111:
	ldr	w0, [sp, 96]
	add	w19, w10, 24
	cmp	w0, w20
	bge	.L62
	mov	w7, w20
	ldr	w9, [sp, 96]
	add	w19, w10, 24
	mov	x20, x8
	ldp	x5, x21, [sp, 160]
	b	.L116
.L114:
	ldr	w2, [sp, 100]
	mov	x1, x18
	ldr	w0, [sp, 144]
	mov	w6, w22
	str	x18, [sp, 176]
	sub	w0, w26, w0
	str	w7, [sp, 184]
	str	w10, [sp, 208]
	str	w9, [sp, 216]
	bl	update24x8_sve
	ldr	w7, [sp, 184]
	ldr	w10, [sp, 208]
	ldr	w9, [sp, 216]
	ldr	x18, [sp, 176]
.L120:
	add	w9, w9, 8
	add	x5, x5, 64
	add	x21, x21, 8
	cmp	w7, w9
	ble	.L326
.L116:
	ldr	x0, [sp, 136]
	sub	w12, w7, w9
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L327
	asr	w0, w9, 3
	mov	x13, 8
	mov	w4, w13
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L130:
	cmp	w12, 7
	bgt	.L114
	add	x0, sp, 512
	cmp	w12, 0
	csinc	w14, w12, wzr, gt
	lsl	x15, x13, 3
	mov	w16, w10
	and	w8, w14, -2
	stp	xzr, xzr, [x0, 80]
	lsr	w6, w14, 1
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w23
	ble	.L328
	.p2align 3,,7
.L117:
	sxtw	x17, w16
	cmp	w12, 0
	ble	.L123
	madd	x17, x17, x20, x25
	mov	x4, x3
	mov	x11, x28
	mov	x2, 0
	.p2align 3,,7
.L127:
	ldr	d0, [x17, x11, lsl 3]
	cmp	w12, 1
	ble	.L329
	dup	v3.2d, v0.d[0]
	ldr	q2, [x4]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w6, 1
	bls	.L128
	ldr	q2, [x4, 16]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
	cmp	w6, 2
	beq	.L128
	ldr	q2, [x4, 32]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w6, 3
	beq	.L128
	ldr	q2, [x4, 48]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
.L128:
	sxtw	x0, w8
	cmp	w8, w14
	beq	.L129
.L125:
	add	x1, x0, x2
	ldr	d1, [x24, x0, lsl 3]
	ldr	d2, [x3, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x24, x0, lsl 3]
.L129:
	add	x11, x11, 1
	add	x2, x2, x13
	add	x4, x4, x15
	cmp	w26, w11
	bgt	.L127
	smaddl	x0, w16, w22, x21
	cmp	w12, 1
	ble	.L182
.L330:
	lsl	x2, x0, 3
	ldr	q1, [sp, 592]
	add	x1, x27, x2
	ldr	q0, [x27, x2]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x27, x2]
	cmp	w6, 1
	bls	.L122
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 608]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w6, 2
	beq	.L122
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 624]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w6, 3
	beq	.L122
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L122:
	sxtw	x1, w8
	cmp	w8, w14
	beq	.L123
.L121:
	add	x0, x1, x0
	ldr	d1, [x24, x1, lsl 3]
	ldr	d0, [x27, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x27, x0, lsl 3]
.L123:
	add	w16, w16, 1
	cmp	w16, w19
	beq	.L120
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w23
	bgt	.L117
.L328:
	cmp	w12, 0
	ble	.L123
	smaddl	x0, w16, w22, x21
	cmp	w12, 1
	bgt	.L330
.L182:
	mov	x1, 0
	b	.L121
	.p2align 2,,3
.L329:
	mov	x0, 0
	b	.L125
.L327:
	ldr	x0, [sp, 120]
	mov	w4, w22
	ldr	x13, [sp, 152]
	add	x3, x5, x0
	b	.L130
.L326:
	mov	x8, x20
	mov	w20, w7
.L62:
	ldr	x1, [sp, 120]
	mov	w10, w19
	ldr	x2, [sp, 544]
	ldr	x0, [sp, 472]
	add	x1, x1, x2
	str	x1, [sp, 120]
	ldr	x1, [sp, 160]
	add	x18, x18, x0
	ldr	x2, [sp, 480]
	ldr	w0, [sp, 104]
	add	x1, x1, x2
	str	x1, [sp, 160]
	sub	w0, w0, w19
	cmp	w0, 23
	bgt	.L111
	mov	w19, w23
	mov	x21, x8
	mov	w23, w20
	mov	x20, x25
	mov	x25, x28
	mov	w28, w10
.L60:
	cmp	w0, 15
	ble	.L63
	ldr	w1, [sp, 100]
	smull	x0, w22, w28
	ldr	x2, [sp, 128]
	mov	w10, w28
	ldrsw	x3, [sp, 96]
	mov	x8, x21
	smaddl	x1, w1, w28, x25
	sub	x2, x2, x0
	add	x0, x3, x0
	mov	x28, x25
	mov	x25, x20
	lsl	x2, x2, 3
	add	x18, x20, x1, lsl 3
	mov	w20, w23
	mov	w23, w19
	add	x0, x27, x0, lsl 3
	str	x2, [sp, 120]
	stp	x0, x3, [sp, 160]
.L91:
	ldr	w0, [sp, 96]
	add	w19, w10, 16
	cmp	w0, w20
	bge	.L65
	mov	w7, w20
	ldr	w9, [sp, 96]
	add	w19, w10, 16
	mov	x20, x8
	ldp	x5, x21, [sp, 160]
	b	.L96
.L94:
	ldr	w2, [sp, 100]
	mov	x1, x18
	ldr	w0, [sp, 144]
	mov	w6, w22
	str	x18, [sp, 176]
	sub	w0, w26, w0
	str	w7, [sp, 184]
	str	w9, [sp, 208]
	str	w10, [sp, 216]
	bl	update16x8_sve
	ldr	w7, [sp, 184]
	ldr	w9, [sp, 208]
	ldr	w10, [sp, 216]
	ldr	x18, [sp, 176]
.L100:
	add	w9, w9, 8
	add	x5, x5, 64
	add	x21, x21, 8
	cmp	w7, w9
	ble	.L331
.L96:
	ldr	x0, [sp, 136]
	sub	w12, w7, w9
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L332
	asr	w0, w9, 3
	mov	x13, 8
	mov	w4, w13
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L110:
	cmp	w12, 7
	bgt	.L94
	add	x0, sp, 512
	cmp	w12, 0
	csinc	w14, w12, wzr, gt
	lsl	x15, x13, 3
	mov	w16, w10
	and	w8, w14, -2
	stp	xzr, xzr, [x0, 80]
	lsr	w6, w14, 1
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w23
	ble	.L333
.L97:
	sxtw	x17, w16
	cmp	w12, 0
	ble	.L103
	madd	x17, x17, x20, x25
	mov	x4, x3
	mov	x11, x28
	mov	x2, 0
	.p2align 3,,7
.L107:
	ldr	d0, [x17, x11, lsl 3]
	cmp	w12, 1
	ble	.L334
	dup	v3.2d, v0.d[0]
	ldr	q2, [x4]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w6, 1
	bls	.L108
	ldr	q2, [x4, 16]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
	cmp	w6, 2
	beq	.L108
	ldr	q2, [x4, 32]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w6, 3
	beq	.L108
	ldr	q2, [x4, 48]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
.L108:
	sxtw	x0, w8
	cmp	w8, w14
	beq	.L109
.L105:
	add	x1, x0, x2
	ldr	d1, [x24, x0, lsl 3]
	ldr	d2, [x3, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x24, x0, lsl 3]
.L109:
	add	x11, x11, 1
	add	x2, x2, x13
	add	x4, x4, x15
	cmp	w26, w11
	bgt	.L107
	smaddl	x0, w16, w22, x21
	cmp	w12, 1
	ble	.L180
.L335:
	lsl	x2, x0, 3
	ldr	q1, [sp, 592]
	add	x1, x27, x2
	ldr	q0, [x27, x2]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x27, x2]
	cmp	w6, 1
	bls	.L102
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 608]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w6, 2
	beq	.L102
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 624]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w6, 3
	beq	.L102
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L102:
	sxtw	x1, w8
	cmp	w8, w14
	beq	.L103
.L101:
	add	x0, x1, x0
	ldr	d1, [x24, x1, lsl 3]
	ldr	d0, [x27, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x27, x0, lsl 3]
.L103:
	add	w16, w16, 1
	cmp	w19, w16
	beq	.L100
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w23
	bgt	.L97
.L333:
	cmp	w12, 0
	ble	.L103
	smaddl	x0, w16, w22, x21
	cmp	w12, 1
	bgt	.L335
.L180:
	mov	x1, 0
	b	.L101
.L334:
	mov	x0, 0
	b	.L105
.L332:
	ldr	x0, [sp, 120]
	mov	w4, w22
	ldr	x13, [sp, 152]
	add	x3, x5, x0
	b	.L110
.L331:
	mov	x8, x20
	mov	w20, w7
.L65:
	ldr	x1, [sp, 120]
	mov	w10, w19
	ldr	x2, [sp, 552]
	ldr	x0, [sp, 368]
	add	x1, x1, x2
	str	x1, [sp, 120]
	ldr	x1, [sp, 160]
	add	x18, x18, x0
	ldr	x2, [sp, 464]
	ldr	w0, [sp, 104]
	add	x1, x1, x2
	str	x1, [sp, 160]
	sub	w0, w0, w19
	cmp	w0, 15
	bgt	.L91
	mov	w19, w23
	mov	x21, x8
	mov	w23, w20
	mov	x20, x25
	mov	x25, x28
	mov	w28, w10
.L63:
	ldr	w1, [sp, 104]
	add	w0, w28, 7
	cmp	w1, w0
	ble	.L59
	ldr	w2, [sp, 100]
	smull	x0, w22, w28
	ldr	x3, [sp, 128]
	sub	w1, w1, #8
	ldrsw	x4, [sp, 96]
	sub	w1, w1, w28
	smaddl	x2, w2, w28, x25
	sub	x3, x3, x0
	add	x0, x0, x4
	mov	x10, x25
	mov	w8, w19
	mov	x11, x21
	add	x0, x27, x0, lsl 3
	mov	w19, w23
	mov	w25, w28
	str	x4, [sp, 184]
	add	w4, w28, 8
	str	w1, [sp, 208]
	and	w1, w1, -8
	lsl	x3, x3, 3
	add	w1, w4, w1
	str	x3, [sp, 120]
	str	x0, [sp, 168]
	add	x0, x20, x2, lsl 3
	str	x0, [sp, 160]
	str	w1, [sp, 176]
	str	w4, [sp, 216]
.L70:
	ldr	w0, [sp, 96]
	add	w28, w25, 8
	cmp	w0, w19
	bge	.L67
	add	w28, w25, 8
	mov	w7, w19
	ldr	w23, [sp, 96]
	mov	w19, w8
	mov	w8, w25
	mov	x25, x10
	ldr	x5, [sp, 168]
	ldr	x21, [sp, 184]
	b	.L76
.L74:
	ldr	w2, [sp, 100]
	mov	w6, w22
	ldr	x1, [sp, 160]
	str	w7, [sp, 376]
	ldr	w0, [sp, 144]
	str	w8, [sp, 432]
	sub	w0, w26, w0
	str	x11, [sp, 448]
	bl	update8x8_sve
	ldr	w7, [sp, 376]
	ldr	w8, [sp, 432]
	ldr	x11, [sp, 448]
.L80:
	add	w23, w23, 8
	add	x5, x5, 64
	add	x21, x21, 8
	cmp	w7, w23
	ble	.L336
.L76:
	ldr	x0, [sp, 136]
	sub	w12, w7, w23
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L337
	asr	w0, w23, 3
	mov	x13, 8
	mov	w4, w13
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L90:
	cmp	w12, 7
	bgt	.L74
	add	x0, sp, 512
	cmp	w12, 0
	csinc	w14, w12, wzr, gt
	lsl	x15, x13, 3
	mov	w16, w8
	and	w10, w14, -2
	stp	xzr, xzr, [x0, 80]
	lsr	w9, w14, 1
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w19
	ble	.L338
.L77:
	sxtw	x17, w16
	cmp	w12, 0
	ble	.L83
	madd	x17, x17, x11, x20
	mov	x4, x3
	mov	x6, x25
	mov	x2, 0
	.p2align 3,,7
.L87:
	ldr	d0, [x17, x6, lsl 3]
	cmp	w12, 1
	ble	.L339
	dup	v3.2d, v0.d[0]
	ldr	q2, [x4]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w9, 1
	bls	.L88
	ldr	q2, [x4, 16]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
	cmp	w9, 2
	beq	.L88
	ldr	q2, [x4, 32]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w9, 3
	beq	.L88
	ldr	q2, [x4, 48]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
.L88:
	sxtw	x0, w10
	cmp	w10, w14
	beq	.L89
.L85:
	add	x1, x0, x2
	ldr	d1, [x24, x0, lsl 3]
	ldr	d2, [x3, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x24, x0, lsl 3]
.L89:
	add	x6, x6, 1
	add	x2, x2, x13
	add	x4, x4, x15
	cmp	w26, w6
	bgt	.L87
	smaddl	x0, w16, w22, x21
	cmp	w12, 1
	ble	.L178
.L340:
	lsl	x2, x0, 3
	ldr	q1, [sp, 592]
	add	x1, x27, x2
	ldr	q0, [x27, x2]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x27, x2]
	cmp	w9, 1
	bls	.L82
	ldr	q0, [x1, 16]
	ldr	q1, [sp, 608]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 16]
	cmp	w9, 2
	beq	.L82
	ldr	q0, [x1, 32]
	ldr	q1, [sp, 624]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 32]
	cmp	w9, 3
	beq	.L82
	ldr	q0, [x1, 48]
	ldr	q1, [sp, 640]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x1, 48]
.L82:
	sxtw	x1, w10
	cmp	w10, w14
	beq	.L83
.L81:
	add	x0, x1, x0
	ldr	d1, [x24, x1, lsl 3]
	ldr	d0, [x27, x0, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x27, x0, lsl 3]
.L83:
	add	w16, w16, 1
	cmp	w28, w16
	beq	.L80
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w26, w19
	bgt	.L77
.L338:
	cmp	w12, 0
	ble	.L83
	smaddl	x0, w16, w22, x21
	cmp	w12, 1
	bgt	.L340
.L178:
	mov	x1, 0
	b	.L81
.L339:
	mov	x0, 0
	b	.L85
.L337:
	ldr	x0, [sp, 120]
	mov	w4, w22
	ldr	x13, [sp, 152]
	add	x3, x0, x5
	b	.L90
.L336:
	mov	w8, w19
	mov	x10, x25
	mov	w19, w7
.L67:
	ldr	x0, [sp, 160]
	mov	w25, w28
	ldr	x1, [sp, 440]
	add	x0, x0, x1
	str	x0, [sp, 160]
	ldr	x0, [sp, 120]
	ldr	x1, [sp, 560]
	add	x0, x0, x1
	str	x0, [sp, 120]
	ldr	x0, [sp, 168]
	ldr	x1, [sp, 456]
	add	x0, x0, x1
	str	x0, [sp, 168]
	ldr	w0, [sp, 176]
	cmp	w28, w0
	bne	.L70
	ldr	w0, [sp, 208]
	mov	w23, w19
	mov	x25, x10
	mov	x21, x11
	and	w28, w0, -8
	ldr	w0, [sp, 216]
	mov	w19, w8
	add	w28, w28, w0
	b	.L59
.L317:
	ldr	x1, [sp, 232]
	mov	w19, w25
	ldr	x0, [sp, 504]
	mov	w21, 8
	ldr	w17, [sp, 268]
	mov	w23, 1
	add	x20, x0, x1
	ldr	x0, [sp, 192]
	mov	x16, x20
	ldr	x12, [sp, 152]
	ldr	x13, [sp, 200]
	add	x18, x0, x25, lsl 3
.L35:
	ldr	w0, [sp, 148]
	sub	w7, w0, w17
	cmp	w7, 8
	csel	w8, w7, w21, le
	cmp	w26, w19
	ble	.L40
	cmp	w7, 0
	add	x0, sp, 512
	ldp	x15, x10, [sp, 240]
	csel	w8, w8, w23, gt
	add	x30, x27, x16, lsl 3
	ldr	w14, [sp, 144]
	ldr	x28, [sp, 256]
	mov	x6, x30
	and	w9, w8, -2
	mov	x11, x16
	lsr	w5, w8, 1
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
.L172:
	ldr	d2, [x15]
	cmp	w7, 0
	ble	.L43
	cmp	w7, 1
	ble	.L174
	ldr	q0, [x6]
	ldr	q3, [sp, 592]
	dup	v1.2d, v2.d[0]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x6]
	cmp	w5, 1
	bls	.L42
	ldr	q0, [x6, 16]
	ldr	q3, [sp, 608]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x6, 16]
	cmp	w5, 2
	beq	.L42
	ldr	q0, [x6, 32]
	ldr	q3, [sp, 624]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x6, 32]
	cmp	w5, 3
	beq	.L42
	ldr	q0, [x6, 48]
	ldr	q3, [sp, 640]
	fsub	v0.2d, v0.2d, v3.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x6, 48]
.L42:
	sxtw	x0, w9
	cmp	w9, w8
	beq	.L43
.L41:
	add	x1, x0, x11
	ldr	d1, [x24, x0, lsl 3]
	ldr	d0, [x27, x1, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x27, x1, lsl 3]
.L43:
	add	w14, w14, 1
	cmp	w26, w14
	beq	.L40
	add	x0, sp, 512
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	cmp	w14, w19
	ble	.L45
	cmp	w7, 0
	ble	.L45
	add	x4, x18, x28, lsl 3
	mov	x3, x30
	mov	x2, x16
.L48:
	ldr	d0, [x4]
	cmp	w7, 1
	ble	.L341
	dup	v3.2d, v0.d[0]
	ldr	q2, [x3]
	ldr	q1, [sp, 592]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 592]
	cmp	w5, 1
	bls	.L49
	ldr	q2, [x3, 16]
	ldr	q1, [sp, 608]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 608]
	cmp	w5, 2
	beq	.L49
	ldr	q2, [x3, 32]
	ldr	q1, [sp, 624]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 624]
	cmp	w5, 3
	beq	.L49
	ldr	q2, [x3, 48]
	ldr	q1, [sp, 640]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 640]
.L49:
	sxtw	x0, w9
	cmp	w9, w8
	beq	.L50
.L46:
	add	x1, x0, x2
	ldr	d1, [x24, x0, lsl 3]
	ldr	d2, [x27, x1, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x24, x0, lsl 3]
.L50:
	add	x4, x4, 8
	add	x2, x2, x12
	add	x3, x3, x13
	cmp	x4, x10
	bne	.L48
.L45:
	ldr	x0, [sp, 496]
	add	x11, x11, x12
	add	x6, x6, x13
	add	x15, x15, x0
	add	x10, x10, x0
	ldr	x0, [sp, 272]
	add	x28, x28, x0
	b	.L172
.L341:
	mov	x0, 0
	b	.L46
.L174:
	mov	x0, 0
	b	.L41
.L40:
	ldr	w0, [sp, 280]
	add	w17, w17, 8
	add	x16, x16, 8
	cmp	w0, w17
	bgt	.L35
	bl	GOMP_barrier
	ldr	x0, [sp, 136]
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L168
	cmp	w26, w19
	ble	.L160
	ldr	w0, [sp, 96]
	add	x5, x27, x20, lsl 3
	ldr	w4, [sp, 268]
	mov	w9, 8
	mvn	w0, w0
	ldr	w20, [sp, 380]
	add	w0, w0, w26
	mov	w28, w4
	add	x0, x0, 1
	mov	x4, x27
	mov	w27, w26
	mov	w8, 7
	lsl	x7, x0, 6
	mov	x0, x25
	mov	x26, x7
	mov	x25, x3
	mov	w3, w22
	mov	x22, x5
	mov	x5, x0
	mov	x6, 8
.L163:
	cmp	w20, 8
	add	w19, w28, 7
	csel	w0, w20, w9, le
	cmp	w28, 0
	csel	w19, w19, w28, lt
	sub	w23, w8, w0
	add	x23, x23, 1
	cmp	w20, 7
	asr	w19, w19, 3
	sbfiz	x7, x0, 3, 32
	lsl	x23, x23, 3
	mov	x21, x22
	sbfiz	x19, x19, 14, 32
	csel	x23, x23, x6, le
	add	x19, x25, x19
	str	x25, [sp, 104]
	add	x10, x26, x19
	mov	x25, x7
	str	x22, [sp, 120]
	mov	x22, x10
	str	x26, [sp, 160]
	mov	w26, w3
.L164:
	cmp	w20, 0
	ble	.L162
	ldr	d0, [x21]
	str	d0, [x19]
	cmp	w20, 1
	ble	.L167
	ldr	d0, [x21, 8]
	str	d0, [x19, 8]
	cmp	w20, 2
	beq	.L162
	ldr	d0, [x21, 16]
	str	d0, [x19, 16]
	cmp	w20, 3
	beq	.L162
	ldr	d0, [x21, 24]
	str	d0, [x19, 24]
	cmp	w20, 4
	beq	.L162
	ldr	d0, [x21, 32]
	str	d0, [x19, 32]
	cmp	w20, 5
	beq	.L162
	ldr	d0, [x21, 40]
	str	d0, [x19, 40]
	cmp	w20, 6
	beq	.L162
	ldr	d0, [x21, 48]
	str	d0, [x19, 48]
	cmp	w20, 7
	ble	.L162
	ldr	d0, [x21, 56]
	str	d0, [x19, 56]
.L167:
	cmp	w20, 7
	bgt	.L166
.L162:
	mov	x2, x23
	add	x0, x19, x25
	mov	w1, 0
	stp	x4, x5, [sp, 168]
	bl	memset
	ldp	x4, x5, [sp, 168]
	mov	w9, 8
	mov	w8, 7
	mov	x6, 8
.L166:
	ldr	x0, [sp, 200]
	add	x19, x19, 64
	add	x21, x21, x0
	cmp	x19, x22
	bne	.L164
	ldr	x22, [sp, 120]
	add	w28, w28, 8
	ldr	w0, [sp, 280]
	mov	w3, w26
	sub	w20, w20, #8
	add	x22, x22, 64
	ldr	x25, [sp, 104]
	ldr	x26, [sp, 160]
	cmp	w0, w28
	bgt	.L163
	mov	w26, w27
	mov	w22, w3
	mov	x27, x4
	mov	x25, x5
	bl	GOMP_barrier
	b	.L168
.L55:
	add	w1, w1, 1
	mov	w0, 0
	b	.L159
	.cfi_endproc
.LFE4287:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4288:
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
	blt	.L344
.L396:
	madd	w0, w1, w2, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L345
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
.L348:
	ldr	w0, [sp, 188]
	mov	w19, 8
	cmp	w0, 8
	csel	w19, w0, w19, le
	cbz	x25, .L459
	ldr	w0, [sp, 128]
	cmp	w0, 0
	ble	.L349
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
.L387:
	mov	x2, x19
	mov	x1, x25
	mov	x0, x24
	cmp	w28, 0
	ble	.L351
	bl	memcpy
	cmp	w28, 7
	bgt	.L389
.L351:
	mov	x2, x21
	add	x0, x24, x22
	mov	w1, 0
	bl	memset
.L389:
	add	x24, x24, 64
	add	x25, x25, x23
	cmp	x24, x20
	bne	.L387
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
	ble	.L355
	movi	v0.2d, 0
	stp	q0, q0, [sp, 336]
	stp	q0, q0, [sp, 368]
	stp	q0, q0, [sp, 400]
	stp	q0, q0, [sp, 432]
	stp	q0, q0, [sp, 464]
	stp	q0, q0, [sp, 496]
	stp	q0, q0, [sp, 528]
	stp	q0, q0, [sp, 560]
.L355:
	sub	w9, w19, #1
	mov	x3, x27
	add	x0, sp, 336
	mov	x1, x25
	mov	x6, x28
	mov	w2, 0
.L381:
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
	beq	.L460
	add	w7, w2, 1
	cmp	w7, 0
	ble	.L386
	cmp	w2, 1
	ble	.L401
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
.L385:
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
	bge	.L386
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
	ble	.L386
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
.L386:
	add	x6, x6, x26
	add	x1, x1, 64
	add	x0, x0, 64
	add	x3, x3, x27
	mov	w2, w7
	b	.L381
.L460:
	ldr	w1, [sp, 128]
	cmp	w1, 4
	ble	.L356
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
.L380:
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
	ble	.L461
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
.L374:
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
	bgt	.L374
	stp	q31, q30, [sp, 336]
	stp	q29, q28, [sp, 368]
	stp	q27, q26, [sp, 400]
	stp	q25, q24, [sp, 432]
	stp	q23, q22, [sp, 464]
	stp	q21, q20, [sp, 496]
	stp	q19, q18, [sp, 528]
	stp	q17, q16, [sp, 560]
.L359:
	ldr	w0, [sp, 184]
	ldp	x5, x4, [sp, 104]
	sub	w14, w0, #1
	mov	x1, x19
	add	x0, sp, 336
	mov	w3, 0
.L377:
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
	beq	.L375
	add	w7, w3, 1
	cmp	w7, 0
	ble	.L379
	cmp	w3, 1
	ble	.L400
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
.L378:
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
	bge	.L379
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
	bge	.L379
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
.L379:
	add	x5, x5, x10
	add	x1, x1, 64
	add	x0, x0, 64
	add	x4, x4, x27
	mov	w3, w7
	b	.L377
.L375:
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
	blt	.L380
	ldr	x23, [sp, 312]
	mov	x26, x10
	mov	x24, x13
.L356:
	ldr	w0, [sp, 188]
	cmp	w0, 0
	ble	.L349
	ldr	x3, [sp, 192]
	mov	x19, x25
	ldr	x21, [sp, 216]
	ldr	x20, [sp, 232]
.L353:
	mov	x1, x19
	mov	x0, x3
	mov	x2, x20
	add	x19, x19, 64
	bl	memcpy
	add	x3, x0, x23
	cmp	x19, x21
	bne	.L353
.L349:
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
	bgt	.L348
.L345:
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
.L461:
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
	b	.L361
	.p2align 2,,3
.L463:
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
	ble	.L399
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
.L360:
	add	x1, x1, 64
	add	x2, x2, 8
	cmp	x5, x1
	beq	.L462
.L361:
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
	beq	.L360
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
	bne	.L463
	add	x1, x1, 64
	mov	w3, 1
	add	x2, x2, 8
	mov	w8, w3
	mov	w14, w3
	mov	w15, w3
	cmp	x5, x1
	bne	.L361
.L462:
	stp	q16, q7, [sp, 336]
	stp	q6, q5, [sp, 368]
	cbz	w30, .L362
	str	q24, [sp, 528]
.L362:
	cbz	w12, .L363
	str	q27, [sp, 544]
.L363:
	cbz	w11, .L364
	str	q26, [sp, 560]
.L364:
	cbz	w9, .L365
	str	q25, [sp, 576]
.L365:
	cbz	w15, .L366
	str	q20, [sp, 400]
.L366:
	cbz	w14, .L367
	str	q19, [sp, 416]
.L367:
	cbz	w8, .L368
	str	q18, [sp, 432]
.L368:
	cbz	w3, .L369
	str	q17, [sp, 448]
.L369:
	cbz	w18, .L370
	str	q23, [sp, 464]
.L370:
	cbz	w17, .L371
	str	q22, [sp, 480]
.L371:
	cbz	w16, .L372
	str	q21, [sp, 496]
.L372:
	cbz	w0, .L359
	str	q4, [sp, 512]
	b	.L359
	.p2align 2,,3
.L399:
	mov	w0, 1
	mov	w16, w0
	mov	w17, w0
	mov	w18, w0
	mov	w3, w0
	mov	w8, w0
	mov	w14, w0
	mov	w15, w0
	b	.L360
.L401:
	mov	w4, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L385
.L400:
	mov	w2, 0
	ldp	q5, q4, [x0, 64]
	ldp	q3, q2, [x0, 96]
	b	.L378
.L459:
	ldr	w0, [sp, 224]
	add	w19, w0, w19
	cmp	w0, w19
	bge	.L349
	ldr	w7, [sp, 128]
	cmp	w7, 0
	ble	.L349
	ldr	x8, [sp, 192]
	ldr	x9, [sp, 208]
.L394:
	ldr	d0, [x8]
	ldr	d1, [x28]
	fdiv	d0, d0, d1
	str	d0, [x8]
	cmp	w7, 1
	beq	.L391
	ldp	x5, x2, [sp, 264]
	add	x3, x8, x23
	mov	x6, x27
	mov	w4, 1
	.p2align 3,,7
.L393:
	movi	d1, #0
	add	x1, x28, x6, lsl 3
	mov	x0, x8
	.p2align 3,,7
.L392:
	ldr	d2, [x0]
	add	x0, x0, x23
	ldr	d0, [x1], 8
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	x2, x1
	bne	.L392
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
	bne	.L393
.L391:
	add	x9, x9, 1
	add	x8, x8, 8
	cmp	w19, w9
	bgt	.L394
	b	.L349
.L344:
	add	w1, w1, 1
	mov	w0, 0
	b	.L396
	.cfi_endproc
.LFE4288:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4286:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L470
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
	bls	.L466
	sxtw	x2, w20
	add	x0, sp, 72
	add	x2, x2, 7
	mov	x1, 64
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L467
	ldr	x0, [sp, 72]
	str	x0, [sp, 64]
.L468:
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
.L466:
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
.L470:
	ret
	.p2align 2,,3
.L467:
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
	b	.L468
	.cfi_endproc
.LFE4286:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (GNU) 10.3.1"
	.section	.note.GNU-stack,"",@progbits
