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
	sbfiz	x11, x5, 3, 32
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	add	x13, x3, x11
	mov	x29, sp
	add	x12, x13, x11
	add	x11, x12, x11
	cmp	w0, 1
	ble	.L28
	stp	x19, x20, [sp, 16]
	.cfi_offset 20, -8
	.cfi_offset 19, -16
	sub	w19, w0, #2
	add	x20, x1, 16
	mov	z24.d, #0
	lsr	w19, w19, 1
	sxtw	x14, w2
	sbfiz	x15, x2, 1, 32
	mov	x5, x1
	add	x17, x15, x14
	sbfiz	x16, x4, 4, 32
	add	x20, x20, w19, uxtw 4
	sbfiz	x9, x4, 3, 32
	mov	x8, 0
	ptrue	p0.b, all
	mov	z26.d, z24.d
	mov	z29.d, z24.d
	mov	z30.d, z24.d
	mov	z27.d, z24.d
	mov	z1.d, z24.d
	mov	z2.d, z24.d
	mov	z3.d, z24.d
	mov	z28.d, z24.d
	mov	z17.d, z24.d
	mov	z21.d, z24.d
	mov	z22.d, z24.d
	mov	z25.d, z24.d
	mov	z23.d, z24.d
	mov	z20.d, z24.d
	mov	z18.d, z24.d
	.p2align 3,,7
.L25:
	add	x10, x3, x8
	ld1d	z16.d, p0/z, [x10]
	add	x10, x13, x8
	ldr	d4, [x5, x14, lsl 3]
	ldr	d0, [x5, x15, lsl 3]
	ld1d	z7.d, p0/z, [x10]
	ldr	d31, [x5, x17, lsl 3]
	mov	z4.d, d4
	mov	z31.d, d31
	mov	z0.d, d0
	fmla	z22.d, p0/m, z16.d, z4.d
	fmla	z21.d, p0/m, z7.d, z4.d
	fmla	z3.d, p0/m, z16.d, z0.d
	fmla	z2.d, p0/m, z7.d, z0.d
	add	x18, x12, x8
	add	x10, x11, x8
	ld1d	z6.d, p0/z, [x18]
	ld1d	z5.d, p0/z, [x10]
	fmla	z17.d, p0/m, z6.d, z4.d
	fmla	z1.d, p0/m, z6.d, z0.d
	ptrue	p1.b, all
	fmad	z4.d, p0/m, z5.d, z28.d
	ld1rd	z19.d, p1/z, [x5]
	fmad	z0.d, p0/m, z5.d, z27.d
	fmla	z18.d, p0/m, z16.d, z19.d
	fmla	z20.d, p0/m, z7.d, z19.d
	fmla	z23.d, p0/m, z6.d, z19.d
	fmad	z16.d, p0/m, z31.d, z30.d
	fmad	z19.d, p0/m, z5.d, z25.d
	fmad	z7.d, p0/m, z31.d, z29.d
	fmad	z6.d, p0/m, z31.d, z26.d
	fmad	z5.d, p0/m, z31.d, z24.d
	mov	x10, x5
	add	x18, x13, x9
	add	x5, x5, 16
	ld1d	z29.d, p0/z, [x18]
	add	x30, x3, x9
	add	x18, x12, x9
	ldr	d25, [x10, 8]!
	ld1d	z30.d, p0/z, [x30]
	mov	z25.d, d25
	ld1d	z26.d, p0/z, [x18]
	fmla	z18.d, p0/m, z30.d, z25.d
	fmla	z20.d, p0/m, z29.d, z25.d
	ldr	d24, [x10, x17, lsl 3]
	fmla	z23.d, p0/m, z26.d, z25.d
	ldr	d28, [x10, x14, lsl 3]
	add	x8, x8, x16
	ldr	d27, [x10, x15, lsl 3]
	mov	z28.d, d28
	mov	z27.d, d27
	add	x10, x11, x9
	fmla	z22.d, p0/m, z30.d, z28.d
	ld1d	z31.d, p0/z, [x10]
	fmla	z21.d, p0/m, z29.d, z28.d
	fmla	z17.d, p0/m, z26.d, z28.d
	fmla	z3.d, p0/m, z30.d, z27.d
	fmla	z2.d, p0/m, z29.d, z27.d
	fmla	z1.d, p0/m, z26.d, z27.d
	fmad	z28.d, p0/m, z31.d, z4.d
	add	x9, x9, x16
	mov	z4.d, d24
	fmad	z25.d, p0/m, z31.d, z19.d
	fmad	z27.d, p0/m, z31.d, z0.d
	fmad	z30.d, p0/m, z4.d, z16.d
	fmad	z29.d, p0/m, z4.d, z7.d
	fmad	z26.d, p0/m, z4.d, z6.d
	movprfx	z24, z5
	fmla	z24.d, p0/m, z31.d, z4.d
	cmp	x20, x5
	bne	.L25
	add	w5, w19, 1
	ldp	x19, x20, [sp, 16]
	.cfi_restore 20
	.cfi_restore 19
	lsl	w5, w5, 1
.L24:
	cmp	w0, w5
	ble	.L26
	sxtw	x8, w5
	sxtw	x2, w2
	sbfiz	x4, x4, 3, 32
	add	x14, x2, x8
	add	x10, x2, x14
	ptrue	p0.b, all
	add	x15, x2, x10
	add	w5, w5, 1
	mul	x9, x8, x4
	ldr	d4, [x1, x8, lsl 3]
	ldr	d5, [x1, x10, lsl 3]
	mov	z4.d, d4
	add	x10, x3, x9
	ld1d	z31.d, p0/z, [x10]
	add	x10, x13, x9
	ldr	d0, [x1, x14, lsl 3]
	ldr	d6, [x1, x15, lsl 3]
	ld1d	z19.d, p0/z, [x10]
	mov	z6.d, d6
	mov	z5.d, d5
	mov	z0.d, d0
	add	x10, x12, x9
	lsl	x8, x8, 3
	ld1d	z16.d, p0/z, [x10]
	add	x9, x11, x9
	fmla	z30.d, p0/m, z31.d, z6.d
	ld1d	z7.d, p0/z, [x9]
	fmla	z29.d, p0/m, z19.d, z6.d
	fmla	z26.d, p0/m, z16.d, z6.d
	fmla	z24.d, p0/m, z7.d, z6.d
	fmla	z3.d, p0/m, z31.d, z5.d
	fmla	z2.d, p0/m, z19.d, z5.d
	fmla	z1.d, p0/m, z16.d, z5.d
	fmla	z27.d, p0/m, z7.d, z5.d
	fmla	z18.d, p0/m, z31.d, z4.d
	fmla	z20.d, p0/m, z19.d, z4.d
	fmla	z23.d, p0/m, z16.d, z4.d
	fmla	z25.d, p0/m, z7.d, z4.d
	fmla	z22.d, p0/m, z31.d, z0.d
	fmla	z21.d, p0/m, z19.d, z0.d
	fmla	z17.d, p0/m, z16.d, z0.d
	fmla	z28.d, p0/m, z7.d, z0.d
	cmp	w0, w5
	ble	.L26
	sxtw	x5, w5
	add	x8, x1, x8
	add	x10, x5, x2
	ld1rd	z31.d, p0/z, [x8, 8]
	add	x9, x2, x10
	add	x0, x2, x9
	mul	x2, x5, x4
	ldr	d0, [x1, x10, lsl 3]
	mov	z0.d, d0
	ldr	d4, [x1, x9, lsl 3]
	add	x3, x3, x2
	ldr	d5, [x1, x0, lsl 3]
	ld1d	z19.d, p0/z, [x3]
	mov	z5.d, d5
	mov	z4.d, d4
	add	x0, x13, x2
	add	x12, x12, x2
	ld1d	z16.d, p0/z, [x0]
	ld1d	z7.d, p0/z, [x12]
	add	x11, x11, x2
	fmla	z30.d, p0/m, z19.d, z5.d
	ld1d	z6.d, p0/z, [x11]
	fmla	z29.d, p0/m, z16.d, z5.d
	fmla	z26.d, p0/m, z7.d, z5.d
	fmla	z24.d, p0/m, z6.d, z5.d
	fmla	z18.d, p0/m, z19.d, z31.d
	fmla	z3.d, p0/m, z19.d, z4.d
	fmla	z2.d, p0/m, z16.d, z4.d
	fmla	z1.d, p0/m, z7.d, z4.d
	fmla	z27.d, p0/m, z6.d, z4.d
	fmla	z20.d, p0/m, z16.d, z31.d
	fmla	z23.d, p0/m, z7.d, z31.d
	fmla	z25.d, p0/m, z6.d, z31.d
	fmla	z22.d, p0/m, z19.d, z0.d
	fmla	z21.d, p0/m, z16.d, z0.d
	fmla	z17.d, p0/m, z7.d, z0.d
	fmla	z28.d, p0/m, z6.d, z0.d
.L26:
	ptrue	p0.b, all
	ld1d	z0.d, p0/z, [x6]
	fsub	z0.d, z0.d, z18.d
	st1d	z0.d, p0, [x6]
	add	x0, x6, 64
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z20.d
	st1d	z0.d, p0, [x0]
	add	x0, x6, 128
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z23.d
	st1d	z0.d, p0, [x0]
	sbfiz	x2, x7, 3, 32
	add	x0, x6, 192
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z25.d
	st1d	z0.d, p0, [x0]
	add	x3, x2, 64
	add	x0, x6, x2
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z22.d
	st1d	z0.d, p0, [x0]
	add	x3, x6, x3
	add	x1, x2, 128
	ld1d	z0.d, p0/z, [x3]
	fsub	z0.d, z0.d, z21.d
	st1d	z0.d, p0, [x3]
	add	x1, x6, x1
	add	x3, x2, 192
	ld1d	z0.d, p0/z, [x1]
	fsub	z0.d, z0.d, z17.d
	st1d	z0.d, p0, [x1]
	add	x3, x6, x3
	sbfiz	x1, x7, 4, 32
	ld1d	z0.d, p0/z, [x3]
	fsub	z0.d, z0.d, z28.d
	st1d	z0.d, p0, [x3]
	add	x0, x0, x2
	add	x4, x1, 64
	ld1d	z0.d, p0/z, [x0]
	mov	w5, 24
	fsub	z0.d, z0.d, z3.d
	st1d	z0.d, p0, [x0]
	add	x4, x6, x4
	add	x3, x1, 128
	ld1d	z0.d, p0/z, [x4]
	fsub	z0.d, z0.d, z2.d
	st1d	z0.d, p0, [x4]
	smull	x7, w7, w5
	add	x3, x6, x3
	add	x1, x1, 192
	ld1d	z0.d, p0/z, [x3]
	fsub	z0.d, z0.d, z1.d
	st1d	z0.d, p0, [x3]
	add	x1, x6, x1
	ld1d	z0.d, p0/z, [x1]
	fsub	z0.d, z0.d, z27.d
	st1d	z0.d, p0, [x1]
	add	x0, x0, x2
	add	x1, x7, 64
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z30.d
	st1d	z0.d, p0, [x0]
	add	x1, x6, x1
	add	x0, x7, 128
	ld1d	z0.d, p0/z, [x1]
	fsub	z0.d, z0.d, z29.d
	st1d	z0.d, p0, [x1]
	add	x0, x6, x0
	add	x7, x7, 192
	ld1d	z0.d, p0/z, [x0]
	fsub	z0.d, z0.d, z26.d
	st1d	z0.d, p0, [x0]
	add	x6, x6, x7
	ld1d	z0.d, p0/z, [x6]
	fsub	z0.d, z0.d, z24.d
	st1d	z0.d, p0, [x6]
	ldp	x29, x30, [sp], 32
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L28:
	.cfi_restore_state
	mov	z24.d, #0
	mov	w5, 0
	mov	z26.d, z24.d
	mov	z29.d, z24.d
	mov	z30.d, z24.d
	mov	z27.d, z24.d
	mov	z1.d, z24.d
	mov	z2.d, z24.d
	mov	z3.d, z24.d
	mov	z28.d, z24.d
	mov	z17.d, z24.d
	mov	z21.d, z24.d
	mov	z22.d, z24.d
	mov	z25.d, z24.d
	mov	z23.d, z24.d
	mov	z20.d, z24.d
	mov	z18.d, z24.d
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
	cbz	w0, .L34
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
.L33:
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
	bne	.L33
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L32:
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
.L34:
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
	b	.L32
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
	cbz	w0, .L40
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
.L39:
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
	bne	.L39
.L38:
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
.L40:
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
	b	.L38
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
	cbz	x19, .L101
	bl	omp_get_num_threads
	mov	w21, w0
	bl	omp_get_thread_num
	ldr	x1, [sp, 176]
	ldr	w2, [x1, 44]
	sub	w2, w2, #1
	sdiv	w1, w2, w21
	msub	w2, w1, w21, w2
	cmp	w0, w2
	blt	.L99
.L107:
	madd	w0, w1, w0, w2
	add	w1, w1, w0
	cmp	w0, w1
	blt	.L100
.L104:
	bl	GOMP_barrier
.L101:
	ldr	w0, [sp, 216]
	cbz	w0, .L98
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 216]
.L98:
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
	blt	.L47
.L96:
	madd	w0, w1, w3, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L48
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
.L51:
	cmp	w24, 8
	mov	w0, 8
	csel	w6, w24, w0, le
	cbz	x21, .L163
	cmp	w28, 0
	ble	.L52
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
.L89:
	mov	x1, x26
	mov	x2, x23
	mov	x0, x19
	cmp	w24, 0
	ble	.L54
	bl	memcpy
	cmp	w24, 7
	bgt	.L164
.L54:
	add	x0, x21, x19
	mov	x2, x22
	mov	w1, 0
	add	x19, x19, 64
	bl	memset
	add	x26, x26, x20
	cmp	x27, x19
	bne	.L89
	ldp	x21, x22, [sp, 240]
	mov	x1, x28
	ldr	x27, [sp, 224]
	mov	x19, x25
	ldr	x23, [sp, 256]
	ldr	w28, [sp, 232]
.L87:
	ldr	w0, [sp, 216]
	mov	w14, w0
	tbnz	x0, 0, .L165
.L55:
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
.L65:
	stp	q17, q17, [x5]
	stp	q17, q17, [x5, 32]
	stp	q17, q17, [x5, 64]
	stp	q17, q17, [x5, 96]
	stp	q17, q17, [x5, 128]
	stp	q17, q17, [x5, 160]
	stp	q17, q17, [x5, 192]
	stp	q17, q17, [x5, 224]
	cmp	w7, 3
	ble	.L166
	movi	v16.2d, 0
	cmp	w8, 0
	ble	.L113
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
.L85:
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
	bne	.L85
.L84:
	stp	q8, q31, [sp, 304]
	stp	q30, q29, [sp, 336]
	stp	q28, q27, [sp, 368]
	stp	q26, q25, [sp, 400]
	stp	q24, q23, [sp, 432]
	stp	q22, q21, [sp, 464]
	stp	q20, q19, [sp, 496]
	stp	q18, q16, [sp, 528]
.L86:
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
	beq	.L75
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
	b	.L76
	.p2align 2,,3
.L79:
	add	x1, x1, 64
	add	x10, x10, x19
	cmp	w4, 2
	beq	.L111
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
.L77:
	add	x0, x0, 64
	ldr	x13, [sp, 120]
	add	x6, x6, x13
.L76:
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
	ble	.L78
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
	bne	.L78
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
.L78:
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
	bne	.L79
.L75:
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
	bgt	.L65
	ldp	x20, x1, [sp, 248]
	ldr	w24, [sp, 240]
.L66:
	cmp	w24, 0
	ble	.L52
	ldr	x3, [sp, 152]
	mov	x0, x19
	ldr	x26, [sp, 168]
	mov	x19, x21
	stp	x27, x21, [sp, 224]
	mov	x25, x0
	mov	x27, x1
	ldr	x21, [sp, 208]
.L62:
	mov	x1, x19
	mov	x0, x3
	mov	x2, x21
	add	x19, x19, 64
	bl	memcpy
	add	x3, x0, x20
	cmp	x26, x19
	bne	.L62
	mov	x1, x27
	mov	x19, x25
	ldp	x27, x21, [sp, 224]
.L52:
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
	bgt	.L51
	ldr	d8, [sp, 96]
	.cfi_restore 72
.L48:
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
.L166:
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
	ble	.L86
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
.L82:
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
	ble	.L80
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
	bne	.L80
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
.L80:
	add	x0, x0, 64
	add	x4, x4, 8
	mov	v8.16b, v28.16b
	mov	v18.16b, v23.16b
	mov	v19.16b, v2.16b
	cmp	x2, x0
	bne	.L82
	stp	q3, q28, [sp, 304]
	stp	q23, q2, [sp, 336]
	cbz	w1, .L67
	str	q1, [sp, 416]
.L67:
	cbz	w11, .L68
	str	q20, [sp, 400]
.L68:
	cbz	w12, .L69
	str	q4, [sp, 384]
.L69:
	cbz	w13, .L70
	str	q5, [sp, 368]
.L70:
	cbz	w18, .L71
	str	q26, [sp, 480]
.L71:
	cbz	w17, .L72
	str	q25, [sp, 464]
.L72:
	cbz	w16, .L73
	str	q24, [sp, 448]
.L73:
	cbz	w20, .L86
	str	q27, [sp, 432]
	b	.L86
.L113:
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
	b	.L84
.L165:
	cmp	w28, 15
	ble	.L109
	mov	x0, x19
	mov	x25, 0
	mov	x19, x21
	mov	x26, x0
	mov	x21, x27
	stp	x20, x1, [sp, 224]
	mov	x20, x25
	b	.L58
.L155:
	bl	solve16x8_panel_sve
	add	x20, x20, 16
	ldr	x0, [sp, 200]
	add	x21, x21, x0
	ldr	x0, [sp, 192]
	cmp	x0, x20
	beq	.L167
.L58:
	ldr	x0, [sp, 176]
	cmp	w20, 0
	ldr	w1, [sp, 148]
	mov	x3, x19
	mov	x2, x21
	ldr	x4, [x0, 16]
	mov	w0, w20
	ldr	x4, [x4]
	ccmp	x4, 0, 4, ne
	beq	.L155
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
	bne	.L58
.L167:
	ldr	w0, [sp, 268]
	mov	x21, x19
	ldp	x20, x1, [sp, 224]
	mov	x19, x26
	mov	w14, w0
	cmp	w28, w0
	bgt	.L55
	b	.L66
	.p2align 2,,3
.L163:
	cmp	w24, 0
	ble	.L52
	cmp	w28, 0
	ble	.L52
	ldp	x7, x8, [sp, 152]
	lsl	x9, x19, 3
	ldr	x30, [sp, 120]
	add	x6, x8, w6, uxtw
.L93:
	ldr	d0, [x7]
	ldr	d1, [x27]
	fdiv	d0, d0, d1
	str	d0, [x7]
	cmp	w28, 1
	beq	.L92
	ldr	x0, [sp, 280]
	add	x4, x27, x30
	ldr	x3, [sp, 184]
	add	x0, x0, x8
	add	x5, x27, x9
	mov	w2, 1
	add	x0, x3, x0, lsl 3
	.p2align 3,,7
.L95:
	movi	d1, #0
	mov	x10, x7
	mov	x3, 0
	.p2align 3,,7
.L94:
	ldr	d2, [x5, x3, lsl 3]
	add	x3, x3, 1
	ldr	d0, [x10]
	add	x10, x10, x20
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w2, w3
	bgt	.L94
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
	bne	.L95
.L92:
	add	x8, x8, 1
	add	x7, x7, 8
	cmp	x6, x8
	bne	.L93
	b	.L52
.L100:
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
.L103:
	sub	x0, x4, #1
	mul	x0, x0, x4
	lsl	x0, x0, 10
	cmp	w2, 0
	ble	.L106
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
.L105:
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
	bne	.L105
.L106:
	add	w2, w2, 16
	add	x4, x4, 1
	add	x24, x24, x26
	add	x3, x3, x30
	cmp	w2, w9
	bne	.L103
	ldr	w25, [sp, 120]
	b	.L104
.L47:
	add	w1, w1, 1
	mov	w0, 0
	b	.L96
.L99:
	add	w1, w1, 1
	mov	w2, 0
	b	.L107
.L164:
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
	b	.L88
	.p2align 2,,3
.L168:
	ldr	x2, [sp, 208]
	mov	x1, x26
	mov	x0, x25
	bl	memcpy
.L88:
	ldr	x0, [sp, 168]
	add	x25, x25, 64
	add	x26, x26, x20
	cmp	x0, x25
	bne	.L168
	mov	x1, x19
	ldr	x19, [sp, 224]
	b	.L87
.L111:
	mov	w12, 0
	b	.L77
	.p2align 2,,3
.L109:
	mov	w14, 0
	b	.L55
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
	sxtw	x1, w1
	stp	d10, d11, [sp, 16]
	.cfi_offset 74, -16
	.cfi_offset 75, -8
	cbz	w0, .L172
	lsl	x5, x1, 3
	sxtw	x13, w0
	add	x12, x2, x5
	sbfiz	x6, x0, 3, 32
	add	x11, x12, x5
	mov	x0, 0
	add	x10, x11, x5
	mov	z17.d, #0
	add	x9, x10, x5
	mov	z24.d, z17.d
	add	x8, x9, x5
	mov	z25.d, z17.d
	add	x7, x8, x5
	mov	z18.d, z17.d
	add	x5, x7, x5
	mov	z26.d, z17.d
	mov	z19.d, z17.d
	mov	z27.d, z17.d
	mov	z20.d, z17.d
	mov	z28.d, z17.d
	mov	z21.d, z17.d
	mov	z29.d, z17.d
	mov	z22.d, z17.d
	mov	z30.d, z17.d
	mov	z23.d, z17.d
	mov	z31.d, z17.d
	mov	z8.d, z17.d
	ptrue	p0.b, all
	.p2align 3,,7
.L171:
	ldr	d2, [x2, x0]
	mov	z2.d, d2
	ldr	d16, [x12, x0]
	ld1d	z1.d, p0/z, [x3, x0, lsl 3]
	ldr	d7, [x11, x0]
	ld1d	z0.d, p0/z, [x4, x0, lsl 3]
	ldr	d6, [x10, x0]
	fmla	z8.d, p0/m, z1.d, z2.d
	ldr	d5, [x9, x0]
	fmla	z31.d, p0/m, z0.d, z2.d
	ldr	d4, [x8, x0]
	mov	z16.d, d16
	ldr	d3, [x7, x0]
	mov	z7.d, d7
	ldr	d2, [x5, x0]
	add	x0, x0, 8
	mov	z6.d, d6
	mov	z5.d, d5
	mov	z4.d, d4
	mov	z3.d, d3
	mov	z2.d, d2
	fmla	z23.d, p0/m, z1.d, z16.d
	fmla	z30.d, p0/m, z0.d, z16.d
	fmla	z22.d, p0/m, z1.d, z7.d
	fmla	z29.d, p0/m, z0.d, z7.d
	fmla	z21.d, p0/m, z1.d, z6.d
	fmla	z28.d, p0/m, z0.d, z6.d
	fmla	z20.d, p0/m, z1.d, z5.d
	fmla	z27.d, p0/m, z0.d, z5.d
	fmla	z19.d, p0/m, z1.d, z4.d
	fmla	z26.d, p0/m, z0.d, z4.d
	fmla	z18.d, p0/m, z1.d, z3.d
	fmla	z25.d, p0/m, z0.d, z3.d
	fmla	z24.d, p0/m, z1.d, z2.d
	fmla	z17.d, p0/m, z0.d, z2.d
	cmp	x6, x0
	bne	.L171
.L170:
	add	x10, x13, x1
	lsl	x0, x13, 6
	add	x9, x10, x1
	ldr	d0, [x2, x13, lsl 3]
	add	x8, x9, x1
	ptrue	p0.b, all
	add	x7, x8, x1
	add	x11, x3, x0
	add	x6, x7, x1
	ld1d	z2.d, p0/z, [x11]
	add	x5, x6, x1
	mov	z0.d, d0
	add	x1, x5, x1
	fsub	z2.d, z2.d, z8.d
	fdiv	z2.d, p0/m, z2.d, z0.d
	st1d	z2.d, p0, [x11]
	add	x12, x4, x0
	add	x11, x0, 64
	ld1d	z1.d, p0/z, [x12]
	fsub	z1.d, z1.d, z31.d
	fdiv	z1.d, p0/m, z1.d, z0.d
	st1d	z1.d, p0, [x12]
	ldr	d0, [x2, x5, lsl 3]
	add	x12, x3, x11
	ldr	d5, [x2, x10, lsl 3]
	ld1d	z3.d, p0/z, [x12]
	ldr	d6, [x2, x9, lsl 3]
	add	x10, x2, x10, lsl 3
	ldr	d10, [x2, x8, lsl 3]
	ld1rd	z9.d, p0/z, [x10, 8]
	ldr	d31, [x2, x7, lsl 3]
	mov	z5.d, d5
	ldr	d8, [x2, x6, lsl 3]
	fmla	z23.d, p0/m, z2.d, z5.d
	ldr	d4, [x2, x1, lsl 3]
	fsub	z3.d, z3.d, z23.d
	fdiv	z3.d, p0/m, z3.d, z9.d
	st1d	z3.d, p0, [x12]
	add	x8, x2, x8, lsl 3
	add	x11, x4, x11
	add	x9, x2, x9, lsl 3
	ld1d	z7.d, p0/z, [x11]
	fmad	z5.d, p0/m, z1.d, z30.d
	add	x10, x0, 128
	fsub	z5.d, z7.d, z5.d
	mov	z6.d, d6
	fdiv	z5.d, p0/m, z5.d, z9.d
	fmla	z22.d, p0/m, z2.d, z6.d
	st1d	z5.d, p0, [x11]
	ld1rd	z23.d, p0/z, [x9, 8]
	ld1rd	z16.d, p0/z, [x8, 8]
	fmla	z22.d, p0/m, z3.d, z23.d
	add	x1, x2, x1, lsl 3
	add	x5, x2, x5, lsl 3
	ld1rd	z30.d, p0/z, [x9, 16]
	add	x6, x2, x6, lsl 3
	add	x7, x2, x7, lsl 3
	fmad	z6.d, p0/m, z1.d, z29.d
	ld1rd	z9.d, p0/z, [x7, 8]
	movprfx	z29, z6
	fmla	z29.d, p0/m, z5.d, z23.d
	add	x2, x3, x10
	ld1rd	z23.d, p0/z, [x6, 8]
	ld1d	z7.d, p0/z, [x2]
	mov	z10.d, d10
	fsub	z7.d, z7.d, z22.d
	fmla	z21.d, p0/m, z2.d, z10.d
	fdiv	z7.d, p0/m, z7.d, z30.d
	ld1rd	z22.d, p0/z, [x5, 8]
	fmla	z21.d, p0/m, z3.d, z16.d
	fmad	z10.d, p0/m, z1.d, z28.d
	movprfx	z28, z10
	fmla	z28.d, p0/m, z5.d, z16.d
	ld1rd	z16.d, p0/z, [x1, 8]
	st1d	z7.d, p0, [x2]
	add	x10, x4, x10
	add	x9, x0, 192
	ld1d	z6.d, p0/z, [x10]
	fsub	z6.d, z6.d, z29.d
	fdiv	z6.d, p0/m, z6.d, z30.d
	st1d	z6.d, p0, [x10]
	ld1rd	z30.d, p0/z, [x7, 16]
	add	x11, x3, x9
	ld1rd	z10.d, p0/z, [x8, 16]
	add	x2, x0, 256
	fmla	z21.d, p0/m, z7.d, z10.d
	mov	z31.d, d31
	fmad	z10.d, p0/m, z6.d, z28.d
	fmla	z20.d, p0/m, z2.d, z31.d
	ld1rd	z28.d, p0/z, [x6, 16]
	fmad	z31.d, p0/m, z1.d, z27.d
	fmla	z20.d, p0/m, z3.d, z9.d
	ld1rd	z27.d, p0/z, [x5, 16]
	fmla	z20.d, p0/m, z7.d, z30.d
	ld1rd	z29.d, p0/z, [x1, 16]
	fmad	z9.d, p0/m, z5.d, z31.d
	ld1rd	z11.d, p0/z, [x8, 24]
	fmla	z9.d, p0/m, z6.d, z30.d
	ld1d	z30.d, p0/z, [x11]
	fsub	z30.d, z30.d, z21.d
	fdiv	z30.d, p0/m, z30.d, z11.d
	st1d	z30.d, p0, [x11]
	add	x10, x3, x2
	add	x9, x4, x9
	ld1d	z21.d, p0/z, [x9]
	fsub	z21.d, z21.d, z10.d
	fdiv	z21.d, p0/m, z21.d, z11.d
	st1d	z21.d, p0, [x9]
	ld1rd	z11.d, p0/z, [x7, 24]
	ld1d	z10.d, p0/z, [x10]
	ld1rd	z31.d, p0/z, [x5, 24]
	add	x8, x4, x2
	fmla	z9.d, p0/m, z21.d, z11.d
	add	x2, x0, 320
	fmla	z20.d, p0/m, z30.d, z11.d
	mov	z8.d, d8
	ld1rd	z11.d, p0/z, [x7, 32]
	fmla	z19.d, p0/m, z2.d, z8.d
	fsub	z20.d, z10.d, z20.d
	fmad	z8.d, p0/m, z1.d, z26.d
	ld1rd	z10.d, p0/z, [x6, 24]
	ld1rd	z26.d, p0/z, [x1, 24]
	fdiv	z20.d, p0/m, z20.d, z11.d
	st1d	z20.d, p0, [x10]
	add	x9, x3, x2
	fmla	z19.d, p0/m, z3.d, z23.d
	fmad	z23.d, p0/m, z5.d, z8.d
	fmla	z19.d, p0/m, z7.d, z28.d
	ld1d	z8.d, p0/z, [x8]
	fmad	z28.d, p0/m, z6.d, z23.d
	fmla	z19.d, p0/m, z30.d, z10.d
	fsub	z8.d, z8.d, z9.d
	fmad	z10.d, p0/m, z21.d, z28.d
	fdiv	z8.d, p0/m, z8.d, z11.d
	st1d	z8.d, p0, [x8]
	ld1d	z9.d, p0/z, [x9]
	ld1rd	z28.d, p0/z, [x6, 32]
	ld1rd	z23.d, p0/z, [x5, 32]
	fmla	z19.d, p0/m, z20.d, z28.d
	fmad	z28.d, p0/m, z8.d, z10.d
	fsub	z19.d, z9.d, z19.d
	mov	z10.d, d0
	ld1rd	z9.d, p0/z, [x6, 40]
	movprfx	z0, z18
	fmla	z0.d, p0/m, z2.d, z10.d
	fdiv	z19.d, p0/m, z19.d, z9.d
	fmad	z10.d, p0/m, z1.d, z25.d
	ld1rd	z25.d, p0/z, [x1, 32]
	st1d	z19.d, p0, [x9]
	add	x7, x4, x2
	mov	z4.d, d4
	ld1d	z18.d, p0/z, [x7]
	fmad	z2.d, p0/m, z4.d, z24.d
	add	x2, x0, 384
	fsub	z18.d, z18.d, z28.d
	fdiv	z18.d, p0/m, z18.d, z9.d
	st1d	z18.d, p0, [x7]
	add	x6, x3, x2
	ld1rd	z9.d, p0/z, [x5, 40]
	ld1rd	z24.d, p0/z, [x5, 48]
	fmla	z10.d, p0/m, z5.d, z22.d
	fmla	z0.d, p0/m, z3.d, z22.d
	add	x0, x0, 448
	ld1d	z22.d, p0/z, [x6]
	fmla	z0.d, p0/m, z7.d, z27.d
	fmad	z3.d, p0/m, z16.d, z2.d
	fmla	z0.d, p0/m, z30.d, z31.d
	ld1rd	z2.d, p0/z, [x1, 40]
	fmla	z0.d, p0/m, z20.d, z23.d
	fmad	z27.d, p0/m, z6.d, z10.d
	fmla	z0.d, p0/m, z19.d, z9.d
	fmad	z7.d, p0/m, z29.d, z3.d
	fmad	z31.d, p0/m, z21.d, z27.d
	fsub	z22.d, z22.d, z0.d
	fmad	z23.d, p0/m, z8.d, z31.d
	fdiv	z22.d, p0/m, z22.d, z24.d
	fmad	z9.d, p0/m, z18.d, z23.d
	st1d	z22.d, p0, [x6]
	add	x2, x4, x2
	add	x3, x3, x0
	ld1d	z0.d, p0/z, [x2]
	fmad	z30.d, p0/m, z26.d, z7.d
	fmad	z1.d, p0/m, z4.d, z17.d
	fmad	z20.d, p0/m, z25.d, z30.d
	fmad	z5.d, p0/m, z16.d, z1.d
	fmad	z19.d, p0/m, z2.d, z20.d
	fsub	z0.d, z0.d, z9.d
	fmad	z6.d, p0/m, z29.d, z5.d
	fdiv	z0.d, p0/m, z0.d, z24.d
	fmad	z21.d, p0/m, z26.d, z6.d
	fmad	z8.d, p0/m, z25.d, z21.d
	st1d	z0.d, p0, [x2]
	ld1rd	z9.d, p0/z, [x1, 48]
	ld1d	z3.d, p0/z, [x3]
	fmad	z22.d, p0/m, z9.d, z19.d
	ld1rd	z7.d, p0/z, [x1, 56]
	fsub	z3.d, z3.d, z22.d
	fdiv	z3.d, p0/m, z3.d, z7.d
	st1d	z3.d, p0, [x3]
	ldp	d10, d11, [sp, 16]
	fmad	z18.d, p0/m, z2.d, z8.d
	add	x4, x4, x0
	fmad	z0.d, p0/m, z9.d, z18.d
	ld1d	z1.d, p0/z, [x4]
	fsub	z0.d, z1.d, z0.d
	fdiv	z0.d, p0/m, z0.d, z7.d
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
.L172:
	.cfi_restore_state
	mov	z17.d, #0
	mov	x13, 0
	mov	z24.d, z17.d
	mov	z25.d, z17.d
	mov	z18.d, z17.d
	mov	z26.d, z17.d
	mov	z19.d, z17.d
	mov	z27.d, z17.d
	mov	z20.d, z17.d
	mov	z28.d, z17.d
	mov	z21.d, z17.d
	mov	z29.d, z17.d
	mov	z22.d, z17.d
	mov	z30.d, z17.d
	mov	z23.d, z17.d
	mov	z31.d, z17.d
	mov	z8.d, z17.d
	b	.L170
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
	cbnz	w1, .L176
	mov	w22, 0
	tbz	w26, #31, .L177
.L233:
	bl	omp_get_num_threads
	mov	w21, w0
	bl	omp_get_thread_num
	mov	x23, 0
	sdiv	w1, w20, w21
	msub	w2, w1, w21, w20
	cmp	w0, w2
	blt	.L178
.L232:
	madd	w0, w1, w0, w2
	add	w2, w1, w0
	cmp	w0, w2
	bge	.L179
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
	sxtw	x14, w0
	mov	w0, 8
	csel	w0, w3, w0, gt
	str	w0, [sp, 244]
	lsl	x0, x4, 2
	str	x0, [sp, 144]
	lsl	x0, x4, 3
	sbfiz	x7, x5, 1, 32
	sbfiz	x5, x26, 6, 32
	str	x0, [sp, 136]
	lsl	x0, x6, 6
	str	x0, [sp, 224]
	add	x0, x23, x5
	sbfiz	x12, x19, 3, 32
	str	x0, [sp, 192]
	sxtw	x0, w26
	lsl	x1, x4, 5
	mov	w20, w22
	mov	w17, w26
	mov	x22, x28
	mov	x25, x12
	mov	w3, w27
	mov	x18, x14
	add	x21, x7, x6
	str	x0, [sp, 232]
	sxtw	x0, w19
	mov	x19, x6
	lsl	x2, x2, 4
	str	x23, [sp, 128]
	str	x1, [sp, 152]
	sub	x1, x1, #32
	str	x5, [sp, 216]
	str	x7, [sp, 248]
	str	x1, [sp, 256]
	str	x0, [sp, 264]
	str	x2, [sp, 272]
	str	d8, [sp, 96]
	.cfi_offset 72, -512
.L182:
	ldr	x0, [sp, 128]
	cmp	w3, 16
	mov	w24, 16
	csel	w24, w3, w24, le
	cbz	x0, .L295
	adds	w1, w24, 7
	add	w0, w24, 14
	csel	w0, w0, w1, mi
	cmp	w3, 15
	cset	w23, gt
	asr	w0, w0, 3
	str	w0, [sp, 240]
	and	w23, w20, w23
	cmp	w3, 0
	ble	.L296
	ldr	x1, [sp, 128]
	str	x21, [sp, 200]
	ldr	x28, [sp, 192]
	mov	x21, x1
	str	w23, [sp, 280]
	mov	x23, x18
	mov	x27, x28
	str	wzr, [sp, 120]
	str	w17, [sp, 160]
	str	x22, [sp, 168]
	str	w24, [sp, 184]
	str	w20, [sp, 212]
	str	w3, [sp, 284]
	stp	x18, x19, [sp, 288]
.L222:
	mov	w0, 8
	cmp	w24, 8
	csel	w19, w24, w0, le
	ldr	w0, [sp, 160]
	cmp	w0, 0
	ble	.L219
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
.L225:
	mov	x1, x28
	mov	x2, x22
	mov	x0, x20
	cmp	w24, 0
	ble	.L221
	bl	memcpy
	cmp	w24, 7
	bgt	.L224
.L221:
	add	x0, x20, x19
	mov	x2, x26
	mov	w1, 0
	add	x20, x20, 64
	bl	memset
	add	x28, x28, x25
	cmp	x20, x27
	bne	.L225
.L219:
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
	bgt	.L222
	ldr	w23, [sp, 280]
	ldr	x22, [sp, 168]
	ldr	x21, [sp, 200]
	ldp	x18, x19, [sp, 288]
	ldr	w17, [sp, 160]
	ldr	w24, [sp, 184]
	ldr	w20, [sp, 212]
	ldr	w3, [sp, 284]
	tbnz	x23, 0, .L297
	mov	w23, w20
.L294:
	mov	w26, 0
.L186:
	mov	w7, w24
	cmp	w3, 15
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
	str	x18, [sp, 200]
	str	wzr, [sp, 212]
	str	w20, [sp, 284]
	str	w3, [sp, 288]
	str	x18, [sp, 296]
.L195:
	mov	w0, 8
	cmp	w7, 8
	csel	w1, w7, w0, le
	ldr	w0, [sp, 280]
	cbnz	w0, .L298
.L188:
	ldr	x0, [sp, 136]
	mov	w27, w26
	sub	w5, w23, w26
	sub	x13, x0, #8
	cmp	w23, w26
	ble	.L299
.L190:
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
.L198:
	stp	q17, q17, [x3]
	stp	q17, q17, [x3, 32]
	stp	q17, q17, [x3, 64]
	stp	q17, q17, [x3, 96]
	stp	q17, q17, [x3, 128]
	stp	q17, q17, [x3, 160]
	stp	q17, q17, [x3, 192]
	stp	q17, q17, [x3, 224]
	cmp	w5, 3
	ble	.L300
	movi	v16.2d, 0
	cmp	w8, 0
	ble	.L240
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
.L217:
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
	bne	.L217
.L216:
	stp	q8, q31, [sp, 352]
	stp	q30, q29, [sp, 384]
	stp	q28, q27, [sp, 416]
	stp	q26, q25, [sp, 448]
	stp	q24, q23, [sp, 480]
	stp	q22, q21, [sp, 512]
	stp	q20, q19, [sp, 544]
	stp	q18, q16, [sp, 576]
.L218:
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
	beq	.L207
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
	b	.L208
	.p2align 2,,3
.L211:
	add	x1, x1, 64
	add	x9, x9, x19
	cmp	w4, 2
	beq	.L238
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
.L209:
	add	x0, x0, 64
	ldr	x25, [sp, 136]
	add	x7, x7, x25
.L208:
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
	ble	.L210
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
	bne	.L210
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
.L210:
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
	bne	.L211
.L207:
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
	bgt	.L198
	ldp	x9, x25, [sp, 320]
	ldr	w7, [sp, 304]
	ldr	w1, [sp, 312]
	ldr	w26, [sp, 316]
.L191:
	cmp	w7, 0
	ble	.L192
	ldr	x0, [sp, 200]
	ubfiz	x28, x1, 3, 32
	ldr	x1, [sp, 176]
	str	w7, [sp, 160]
	ldr	x27, [sp, 120]
	add	x5, x1, x0, lsl 3
	mov	x20, x27
	mov	x27, x19
	mov	x19, x9
.L194:
	mov	x1, x20
	mov	x0, x5
	mov	x2, x28
	add	x20, x20, 64
	bl	memcpy
	add	x5, x0, x25
	cmp	x19, x20
	bne	.L194
	ldr	w7, [sp, 160]
	mov	x9, x19
	mov	x19, x27
.L192:
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
	bgt	.L195
	ldr	x18, [sp, 296]
	mov	w17, w23
	ldr	w20, [sp, 284]
	ldr	w3, [sp, 288]
.L184:
	ldr	x0, [sp, 272]
	add	x18, x18, 16
	sub	w3, w3, #16
	cmp	x18, x0
	bne	.L182
	ldr	x23, [sp, 128]
	ldr	d8, [sp, 96]
	.cfi_restore 72
.L179:
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
.L301:
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
.L224:
	add	x20, x20, 64
	add	x28, x28, x25
	cmp	x20, x27
	bne	.L301
	b	.L219
.L300:
	cmp	w8, 0
	ble	.L218
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
.L214:
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
	ble	.L212
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
	bne	.L212
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
.L212:
	add	x0, x0, 64
	add	x4, x4, 8
	mov	v8.16b, v23.16b
	mov	v16.16b, v28.16b
	mov	v19.16b, v2.16b
	cmp	x0, x2
	bne	.L214
	stp	q3, q23, [sp, 352]
	stp	q28, q2, [sp, 384]
	cbz	w1, .L199
	str	q1, [sp, 464]
.L199:
	cbz	w11, .L200
	str	q20, [sp, 448]
.L200:
	cbz	w25, .L201
	str	q18, [sp, 432]
.L201:
	cbz	w18, .L202
	str	q4, [sp, 416]
.L202:
	cbz	w27, .L203
	str	q24, [sp, 528]
.L203:
	cbz	w26, .L204
	str	q27, [sp, 512]
.L204:
	cbz	w30, .L205
	str	q26, [sp, 496]
.L205:
	cbz	w28, .L218
	str	q25, [sp, 480]
	b	.L218
.L240:
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
	b	.L216
.L298:
	sub	w0, w23, w26
	cmp	w0, 15
	ble	.L188
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
.L189:
	ldr	x3, [sp, 120]
	mov	w0, w20
	ldr	w1, [sp, 208]
	mov	x2, x21
	add	w20, w20, 16
	add	x21, x21, x22
	bl	solve16x8_panel_sve
	sub	w5, w19, w20
	cmp	w5, 15
	bgt	.L189
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
	bgt	.L190
	b	.L191
.L296:
	cbz	w23, .L184
	cmp	w17, 7
	bgt	.L187
	b	.L184
	.p2align 2,,3
.L299:
	cmp	w23, 0
	ble	.L192
	b	.L191
	.p2align 2,,3
.L297:
	cmp	w17, 7
	ble	.L294
.L187:
	mov	x15, x22
	mov	w23, w17
	mov	w26, w3
	mov	w14, 0
.L185:
	ldr	x3, [sp, 128]
	mov	w0, w14
	ldr	x4, [sp, 192]
	mov	x2, x15
	ldr	w1, [sp, 208]
	add	w14, w14, 8
	bl	solve8x16_panel_sve
	ldr	x1, [sp, 224]
	sub	w0, w23, w14
	add	x15, x15, x1
	cmp	w0, 7
	bgt	.L185
	mov	w17, w23
	mov	w3, w26
	cmp	w26, 0
	ble	.L184
	ldr	w26, [sp, 244]
	mov	w23, 1
	b	.L186
.L295:
	cmp	w3, 0
	ble	.L184
	cmp	w17, 0
	ble	.L184
	ldr	x0, [sp, 176]
	add	x24, x18, w24, uxtw
	ldr	x9, [sp, 136]
	mov	x5, x18
	add	x7, x0, x18, lsl 3
.L229:
	ldr	d0, [x7]
	ldr	d1, [x22]
	fdiv	d0, d0, d1
	str	d0, [x7]
	cmp	w17, 1
	beq	.L228
	ldr	x0, [sp, 264]
	add	x4, x22, x9
	ldr	x1, [sp, 176]
	add	x0, x5, x0
	sub	x10, x9, #8
	add	x6, x22, x19, lsl 3
	add	x0, x1, x0, lsl 3
	mov	w1, 1
.L231:
	movi	d1, #0
	mov	x8, x7
	mov	x2, 0
.L230:
	ldr	d2, [x6, x2, lsl 3]
	add	x2, x2, 1
	ldr	d0, [x8]
	add	x8, x8, x25
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w1, w2
	bgt	.L230
	ldr	d0, [x0]
	add	w1, w1, 1
	ldr	d2, [x4]
	add	x6, x6, x10
	add	x4, x4, x9
	fsub	d0, d0, d1
	fdiv	d0, d0, d2
	str	d0, [x0]
	add	x0, x0, x25
	cmp	w17, w1
	bne	.L231
.L228:
	add	x5, x5, 1
	add	x7, x7, 8
	cmp	x5, x24
	bne	.L229
	b	.L184
.L176:
	.cfi_restore 72
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w22, ne
	tbnz	w26, #31, .L233
.L177:
	sbfiz	x2, x26, 7, 32
	add	x0, sp, 344
	mov	x1, 64
	bl	posix_memalign
	cbnz	w0, .L233
	bl	omp_get_num_threads
	mov	w21, w0
	bl	omp_get_thread_num
	ldr	x23, [sp, 344]
	sdiv	w1, w20, w21
	msub	w2, w1, w21, w20
	cmp	w0, w2
	bge	.L232
.L178:
	add	w1, w1, 1
	mov	w2, 0
	b	.L232
.L238:
	.cfi_offset 72, -512
	mov	w18, 0
	b	.L209
	.cfi_endproc
.LFE4377:
	.size	solve_panel_wide8x16._omp_fn.0, .-solve_panel_wide8x16._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4375:
	.cfi_startproc
	sub	sp, sp, #1072
	.cfi_def_cfa_offset 1072
	stp	x29, x30, [sp]
	.cfi_offset 29, -1072
	.cfi_offset 30, -1064
	mov	x29, sp
	ldr	w2, [x0, 24]
	ldr	w1, [x0, 40]
	str	w2, [sp, 268]
	ldr	w2, [x0, 28]
	stp	x23, x24, [sp, 48]
	stp	x27, x28, [sp, 80]
	.cfi_offset 23, -1024
	.cfi_offset 24, -1016
	.cfi_offset 27, -992
	.cfi_offset 28, -984
	ldp	x23, x28, [x0]
	str	x0, [sp, 184]
	str	w2, [sp, 368]
	ldp	w2, w0, [x0, 32]
	stp	w0, w2, [sp, 168]
	str	w1, [sp, 496]
	cbz	w1, .L483
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 496]
.L483:
	ldr	w0, [sp, 268]
	cmp	w0, 0
	ble	.L302
	stp	x19, x20, [sp, 16]
	.cfi_offset 20, -1048
	.cfi_offset 19, -1056
	mov	x19, 0
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -1032
	.cfi_offset 21, -1040
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -1000
	.cfi_offset 25, -1008
	bl	omp_get_num_threads
	mov	w20, w0
	bl	omp_get_thread_num
	mov	w26, w0
	ldr	w7, [sp, 368]
	mov	w3, 24
	ldrsw	x4, [sp, 172]
	adds	w2, w7, 7
	add	w1, w7, 14
	csel	w0, w1, w2, mi
	add	x13, x4, 1
	ldr	w6, [sp, 168]
	lsl	x12, x4, 1
	asr	w0, w0, 3
	lsl	x10, x13, 5
	lsl	x11, x13, 2
	str	x10, [sp, 656]
	sub	x10, x10, #32
	str	x10, [sp, 528]
	sdiv	w2, w0, w20
	sub	x10, x11, #4
	str	x10, [sp, 672]
	lsl	x10, x13, 11
	add	w1, w7, 63
	str	x10, [sp, 696]
	lsl	x10, x13, 8
	lsl	x9, x4, 3
	msub	w0, w2, w20, w0
	str	x10, [sp, 704]
	add	x10, x12, x4
	asr	w1, w1, 6
	cmp	w26, w0
	str	x9, [sp, 288]
	cinc	w2, w2, lt
	str	x10, [sp, 512]
	add	x10, x23, x9
	add	x9, x9, 8
	sxtw	x5, w6
	str	x9, [sp, 448]
	lsl	x9, x4, 7
	str	w1, [sp, 500]
	mul	w1, w2, w26
	str	x9, [sp, 632]
	lsl	x9, x4, 4
	smull	x3, w6, w3
	add	w0, w0, w1
	str	x4, [sp, 120]
	str	x4, [sp, 456]
	csel	w1, w1, w0, lt
	str	x9, [sp, 648]
	lsl	x9, x4, 6
	neg	x4, x5, lsl 7
	str	x3, [sp, 584]
	mov	w3, w6
	sbfiz	x6, x6, 3, 32
	str	x4, [sp, 712]
	neg	x4, x5, lsl 6
	add	x0, x6, 16
	add	w2, w2, w1
	str	x4, [sp, 720]
	lsl	x4, x5, 2
	sbfiz	x8, x3, 4, 32
	str	x6, [sp, 128]
	str	x5, [sp, 160]
	mov	w25, w1
	str	x8, [sp, 352]
	str	x10, [sp, 360]
	str	x0, [sp, 392]
	add	x0, x6, 48
	str	x12, [sp, 504]
	str	x4, [sp, 600]
	neg	x4, x5, lsl 5
	str	x9, [sp, 616]
	str	x11, [sp, 664]
	str	x4, [sp, 728]
	add	x4, x6, 32
	lsl	w6, w1, 3
	stp	x4, x0, [sp, 400]
	lsl	w0, w2, 3
	str	w0, [sp, 580]
	sub	w0, w7, w6
	str	w0, [sp, 640]
	sxtw	x0, w6
	str	x0, [sp, 680]
	add	x0, x8, 16
	str	x0, [sp, 416]
	add	x0, x8, 32
	str	x0, [sp, 424]
	add	x0, x8, 48
	mov	w22, w6
	str	xzr, [sp, 176]
	str	xzr, [sp, 280]
	str	x28, [sp, 336]
	str	x0, [sp, 432]
	sbfiz	x0, x3, 8, 32
	stp	x23, x23, [sp, 464]
	str	x23, [sp, 536]
	str	w26, [sp, 548]
	str	x0, [sp, 688]
	str	x13, [sp, 744]
	str	w20, [sp, 752]
	mov	w20, w2
	b	.L364
.L669:
	add	w26, w1, 256
	cmp	w20, w25
	bgt	.L666
.L306:
	str	w15, [sp, 136]
	bl	GOMP_barrier
	ldr	w0, [sp, 268]
	ldr	w15, [sp, 136]
	cmp	w0, w26
	ble	.L366
	ldr	w0, [sp, 268]
	ldr	w1, [sp, 368]
	add	w0, w0, 63
	sub	w0, w0, w26
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L366
	ldr	w1, [sp, 500]
	ldr	w2, [sp, 752]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	ldr	w2, [sp, 548]
	cmp	w2, w0
	bcc	.L367
.L482:
	ldr	w2, [sp, 548]
	madd	w0, w1, w2, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L667
.L366:
	bl	GOMP_barrier
	ldr	x0, [sp, 176]
	ldr	x2, [sp, 688]
	add	x1, x0, 256
	ldr	x0, [sp, 280]
	add	x19, x19, x2
	ldr	x3, [sp, 360]
	add	x0, x0, x2
	str	x0, [sp, 280]
	ldr	x0, [sp, 696]
	str	x1, [sp, 176]
	ldr	x4, [sp, 704]
	add	x3, x3, x0
	str	x3, [sp, 360]
	ldr	x3, [sp, 456]
	ldr	x2, [sp, 472]
	add	x3, x3, x4
	str	x3, [sp, 456]
	ldr	x3, [sp, 464]
	add	x3, x3, x0
	add	x0, x2, x0
	stp	x3, x0, [sp, 464]
	ldr	w0, [sp, 268]
	cmp	w0, w1
	ble	.L668
.L364:
	ldr	x1, [sp, 176]
	str	w1, [sp, 264]
	ldr	w0, [sp, 268]
	mov	w15, w1
	sub	w0, w0, w1
	cmp	w0, 255
	bgt	.L669
	cmp	w20, w25
	ble	.L484
	ldr	w26, [sp, 268]
	str	d8, [sp, 96]
	.cfi_offset 72, -976
.L485:
	ldr	x18, [sp, 680]
	sub	w0, w26, w15
	ldr	x1, [sp, 288]
	sub	w24, w0, #1
	str	w0, [sp, 136]
	add	x16, x18, x19
	ldr	x0, [sp, 360]
	mov	x6, x19
	ldr	x21, [sp, 120]
	str	w15, [sp, 148]
	ldr	x19, [sp, 128]
	mov	w7, w25
	ldr	x15, [sp, 536]
	mov	x25, x16
	ldr	w17, [sp, 176]
	mov	w28, w22
	ldr	w23, [sp, 640]
	mov	w8, w20
	mov	x2, x24
	mov	x27, x18
	mov	w16, w22
	sub	x0, x0, x1
	str	x0, [sp, 192]
.L310:
	ldr	x0, [sp, 184]
	cmp	w23, 8
	mov	w1, 8
	csel	w1, w23, w1, le
	ldr	x0, [x0, 16]
	ldr	x24, [x0]
	cbz	x24, .L670
	cmp	w28, 0
	add	w10, w28, 7
	csel	w10, w10, w28, lt
	ldr	w0, [sp, 136]
	asr	w10, w10, 3
	sbfiz	x22, x10, 14, 32
	sxtw	x10, w10
	add	x22, x24, x22
	cmp	w0, 0
	ble	.L311
	ldr	w9, [sp, 148]
	mov	w0, 7
	sub	w0, w0, w1
	sbfiz	x4, x1, 3, 32
	mov	x3, x22
	add	x0, x0, 1
	mov	x5, x21
	mov	x11, x22
	mov	x13, x25
	mov	w20, w9
	mov	w25, w8
	mov	x9, x19
	mov	x8, x22
	mov	w21, w16
	mov	x22, x4
	mov	x12, x2
	mov	x4, x24
	mov	w14, w17
	mov	x24, x15
	mov	x19, x3
	lsl	x0, x0, 3
	str	x0, [sp, 152]
.L360:
	cmp	w23, 0
	ble	.L331
	ldr	x2, [sp, 336]
.L330:
	ldr	w0, [sp, 168]
	smaddl	x1, w20, w0, x27
	lsl	x0, x1, 3
	ldr	d0, [x2, x1, lsl 3]
	add	x0, x2, x0
	str	d0, [x19]
	cmp	w23, 1
	ble	.L331
	ldr	d0, [x0, 8]
	str	d0, [x19, 8]
	cmp	w23, 2
	ble	.L331
	ldr	d0, [x0, 16]
	str	d0, [x19, 16]
	cmp	w23, 3
	ble	.L331
	ldr	d0, [x0, 24]
	str	d0, [x19, 24]
	cmp	w23, 4
	ble	.L331
	ldr	d0, [x0, 32]
	str	d0, [x19, 32]
	cmp	w23, 5
	ble	.L331
	ldr	d0, [x0, 40]
	str	d0, [x19, 40]
	cmp	w23, 6
	ble	.L331
	ldr	d0, [x0, 48]
	str	d0, [x19, 48]
	cmp	w23, 7
	ble	.L331
	ldr	d0, [x0, 56]
	add	w20, w20, 1
	add	x19, x19, 64
	str	d0, [x19, -8]
	cmp	w26, w20
	bne	.L330
.L661:
	lsl	x0, x10, 8
	neg	x3, x5
	mov	w16, w21
	mov	x21, x5
	ldp	x30, x5, [sp, 456]
	str	x0, [sp, 152]
	ldr	w0, [sp, 148]
	mov	x15, x24
	mov	x22, x8
	mov	x19, x9
	ldr	x9, [sp, 360]
	mov	w17, w14
	ldr	x14, [sp, 192]
	mov	x24, x4
	movi	v17.4s, 0
	ldr	w4, [sp, 136]
	mov	w8, w25
	add	w10, w0, 2
	mov	x20, x11
	mov	x25, x13
	mov	x1, x22
	add	x0, sp, 816
	str	x3, [sp, 208]
	add	x3, x15, 8
	str	x3, [sp, 216]
	mov	x3, 0
	str	w28, [sp, 224]
	str	w8, [sp, 232]
	str	w16, [sp, 240]
	str	x19, [sp, 248]
	str	w7, [sp, 256]
	str	x12, [sp, 272]
	str	x6, [sp, 296]
	str	w17, [sp, 304]
.L338:
	stp	q17, q17, [x0]
	stp	q17, q17, [x0, 32]
	stp	q17, q17, [x0, 64]
	stp	q17, q17, [x0, 96]
	stp	q17, q17, [x0, 128]
	stp	q17, q17, [x0, 160]
	stp	q17, q17, [x0, 192]
	stp	q17, q17, [x0, 224]
	cmp	w4, 3
	ble	.L671
	movi	v0.2d, 0
	cbz	w3, .L491
	ldp	x2, x6, [sp, 504]
	add	x11, x22, x3, lsl 6
	mov	v18.16b, v0.16b
	mov	x8, x14
	mov	v19.16b, v0.16b
	mov	x7, x22
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
.L358:
	ldp	q5, q4, [x7]
	ldp	q3, q1, [x7, 32]
	add	x7, x7, 64
	ldr	d7, [x8, x21, lsl 3]
	ldr	d6, [x8, x2, lsl 3]
	ldr	d2, [x8, x6, lsl 3]
	fmla	v28.2d, v5.2d, v7.d[0]
	ld1r	{v16.2d}, [x8]
	fmla	v27.2d, v4.2d, v7.d[0]
	add	x8, x8, 8
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
	cmp	x7, x11
	bne	.L358
.L357:
	stp	q8, q31, [sp, 816]
	stp	q30, q29, [sp, 848]
	stp	q28, q27, [sp, 880]
	stp	q26, q25, [sp, 912]
	stp	q24, q23, [sp, 944]
	stp	q22, q21, [sp, 976]
	stp	q20, q19, [sp, 1008]
	str	q18, [sp, 1040]
	str	q0, [sp, 1056]
.L359:
	ldr	x2, [sp, 208]
	ldp	q4, q3, [x1]
	ldp	q2, q1, [x1, 32]
	ldp	q8, q7, [sp, 816]
	ldp	q6, q5, [sp, 848]
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
	beq	.L348
	ldr	x2, [sp, 152]
	cmp	w4, 4
	mov	x7, x0
	mov	x18, x9
	add	x28, x2, x3
	mov	x12, x30
	add	x8, x28, 2
	add	x16, x28, 1
	mov	w2, 4
	mov	w11, 1
	add	x19, x24, x8, lsl 6
	csel	w2, w4, w2, le
	add	x16, x24, x16, lsl 6
	mov	x8, x1
	mov	w13, 0
	b	.L349
.L352:
	add	x7, x7, 64
	add	x12, x12, x21
	cmp	w11, 2
	beq	.L489
	ldp	q1, q0, [x1]
	mov	w13, 2
	ldr	d5, [x15, x12, lsl 3]
	ldp	q3, q2, [x7, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldr	x6, [sp, 216]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	ldr	d4, [x6, x12, lsl 3]
	ldp	q7, q6, [x7, 96]
	stp	q1, q0, [x7, 64]
	ldp	q3, q2, [x1, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x7, 64]
	ldp	q1, q0, [x1, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x7, 96]
	ldp	q3, q2, [x1, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x7, 96]
.L350:
	add	x8, x8, 64
	ldr	x6, [sp, 448]
	add	x18, x18, x6
.L349:
	sxtw	x6, w13
	add	w13, w13, 1
	add	x17, x28, x6
	add	x6, x6, x12
	ldp	q1, q6, [x7, 64]
	lsl	x17, x17, 6
	ldr	d0, [x15, x6, lsl 3]
	add	x6, x24, x17
	ldp	q5, q4, [x7, 96]
	ldr	q2, [x24, x17]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x7, 64]
	ldr	q3, [x6, 16]
	fmul	v3.2d, v3.2d, v0.d[0]
	fadd	v3.2d, v3.2d, v6.2d
	str	q3, [x7, 80]
	ldr	q2, [x6, 32]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x7, 96]
	ldr	q5, [x6, 48]
	fmul	v5.2d, v5.2d, v0.d[0]
	fadd	v5.2d, v5.2d, v4.2d
	str	q5, [x7, 112]
	cmp	w13, w11
	bge	.L351
	add	x6, x12, 1
	ldr	q0, [x16]
	ldr	d6, [x15, x6, lsl 3]
	fmul	v0.2d, v0.2d, v6.d[0]
	fadd	v0.2d, v0.2d, v1.2d
	mov	v1.16b, v0.16b
	str	q0, [x7, 64]
	ldr	q4, [x16, 16]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v3.2d
	str	q4, [x7, 80]
	ldr	q3, [x16, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x7, 96]
	ldr	q2, [x16, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x7, 112]
	cmp	w11, 3
	bne	.L351
	add	x6, x12, 2
	ldr	q1, [x19]
	ldr	d5, [x15, x6, lsl 3]
	fmul	v1.2d, v1.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v0.2d
	str	q1, [x7, 64]
	ldr	q0, [x19, 16]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v4.2d
	str	q0, [x7, 80]
	ldr	q0, [x19, 32]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v3.2d
	str	q0, [x7, 96]
	ldr	q0, [x19, 48]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x7, 112]
.L351:
	ldr	d0, [x18, 8]
	ldp	q4, q3, [x8, 64]
	add	w11, w11, 1
	dup	v0.2d, v0.d[0]
	ldr	q2, [x8, 96]
	fsub	v4.2d, v4.2d, v1.2d
	ldr	q1, [x8, 112]
	fdiv	v4.2d, v4.2d, v0.2d
	str	q4, [x8, 64]
	ldr	q4, [x7, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v0.2d
	str	q3, [x8, 80]
	ldr	q3, [x7, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x8, 96]
	ldr	q2, [x7, 112]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q0, [x8, 112]
	cmp	w2, w11
	bne	.L352
.L348:
	ldr	x2, [sp, 656]
	add	x3, x3, 4
	sub	w4, w4, #4
	add	x1, x1, 256
	add	x9, x9, x2
	add	w10, w10, 4
	ldr	x2, [sp, 664]
	add	x30, x30, x2
	ldr	x2, [sp, 528]
	add	x5, x5, x2
	add	x14, x14, x2
	ldr	w2, [sp, 136]
	cmp	w2, w3
	bgt	.L338
	ldr	x19, [sp, 248]
	ldr	x2, [sp, 272]
	ldr	x6, [sp, 296]
	ldr	w28, [sp, 224]
	ldr	w8, [sp, 232]
	ldr	w16, [sp, 240]
	ldr	w7, [sp, 256]
	ldr	w17, [sp, 304]
	cmp	w23, 0
	ble	.L311
	ldr	x0, [sp, 336]
	add	x1, x2, 1
	add	x1, x22, x1, lsl 6
	add	x0, x0, x25, lsl 3
.L335:
	ldr	d0, [x20]
	str	d0, [x0]
	cmp	w23, 1
	ble	.L333
	ldr	d0, [x20, 8]
	str	d0, [x0, 8]
	cmp	w23, 2
	ble	.L333
	ldr	d0, [x20, 16]
	str	d0, [x0, 16]
	cmp	w23, 3
	ble	.L333
	ldr	d0, [x20, 24]
	str	d0, [x0, 24]
	cmp	w23, 4
	ble	.L333
	ldr	d0, [x20, 32]
	str	d0, [x0, 32]
	cmp	w23, 5
	ble	.L333
	ldr	d0, [x20, 40]
	str	d0, [x0, 40]
	cmp	w23, 6
	ble	.L333
	ldr	d0, [x20, 48]
	str	d0, [x0, 48]
	cmp	w23, 7
	ble	.L333
	ldr	d0, [x20, 56]
	str	d0, [x0, 56]
.L333:
	add	x20, x20, 64
	add	x0, x0, x19
	cmp	x20, x1
	bne	.L335
.L311:
	ldr	w0, [sp, 580]
	add	w28, w28, 8
	sub	w23, w23, #8
	add	x27, x27, 8
	add	x25, x25, 8
	cmp	w0, w28
	bgt	.L310
.L672:
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	w20, w8
	ldr	w15, [sp, 148]
	mov	w22, w16
	mov	w25, w7
	mov	x19, x6
	b	.L306
.L331:
	.cfi_restore_state
	ldr	x2, [sp, 152]
	add	x0, x19, x22
	add	w20, w20, 1
	mov	w1, 0
	stp	x4, x5, [sp, 200]
	add	x19, x19, 64
	stp	x8, x9, [sp, 216]
	str	w7, [sp, 232]
	stp	x11, x12, [sp, 240]
	str	x13, [sp, 256]
	str	x6, [sp, 272]
	str	w14, [sp, 296]
	str	x10, [sp, 304]
	bl	memset
	ldp	x4, x5, [sp, 200]
	cmp	w26, w20
	ldp	x8, x9, [sp, 216]
	ldp	x11, x12, [sp, 240]
	ldr	x13, [sp, 256]
	ldr	x6, [sp, 272]
	ldr	x10, [sp, 304]
	ldr	w7, [sp, 232]
	ldr	w14, [sp, 296]
	bne	.L360
	b	.L661
.L671:
	cbz	w3, .L359
	ldr	x6, [sp, 176]
	sub	w8, w10, #1
	ldr	w2, [sp, 172]
	lsl	x7, x3, 3
	movi	v0.2d, 0
	mov	x11, x22
	mov	w16, 0
	mov	w13, 0
	mov	w28, 0
	mov	w17, 0
	smaddl	x12, w2, w10, x6
	str	x7, [sp, 200]
	smaddl	x8, w2, w8, x6
	mov	w7, 0
	mov	v19.16b, v0.16b
	mov	w6, 0
	mov	v8.16b, v0.16b
	add	x18, x15, x12, lsl 3
	mov	v1.16b, v0.16b
	add	x19, x15, x8, lsl 3
	mov	v25.16b, v0.16b
	mov	w12, 0
	mov	v24.16b, v0.16b
	mov	w2, 0
	mov	v23.16b, v0.16b
	mov	x8, 0
	mov	v22.16b, v0.16b
	str	x0, [sp, 312]
	mov	v21.16b, v0.16b
	mov	v18.16b, v0.16b
	mov	v7.16b, v0.16b
	mov	v20.16b, v0.16b
.L355:
	ldp	q6, q5, [x11]
	ldp	q4, q3, [x11, 32]
	ldr	d2, [x5, x8]
	fmul	v16.2d, v6.2d, v2.d[0]
	fmul	v26.2d, v5.2d, v2.d[0]
	fmul	v27.2d, v4.2d, v2.d[0]
	fmul	v2.2d, v3.2d, v2.d[0]
	fadd	v20.2d, v16.2d, v20.2d
	fadd	v26.2d, v26.2d, v7.2d
	fadd	v27.2d, v27.2d, v18.2d
	fadd	v16.2d, v2.2d, v21.2d
	cmp	w4, 1
	ble	.L353
	ldr	d2, [x19, x8]
	mov	w7, 1
	mov	w16, w7
	mov	w13, w7
	mov	w12, w7
	fmul	v7.2d, v6.2d, v2.d[0]
	fmul	v18.2d, v5.2d, v2.d[0]
	fmul	v21.2d, v4.2d, v2.d[0]
	fmul	v2.2d, v3.2d, v2.d[0]
	fadd	v1.2d, v7.2d, v1.2d
	fadd	v8.2d, v18.2d, v8.2d
	fadd	v19.2d, v21.2d, v19.2d
	fadd	v0.2d, v2.2d, v0.2d
	cmp	w4, 3
	bne	.L353
	ldr	d2, [x18, x8]
	mov	w28, w7
	mov	w17, w7
	mov	w6, w7
	mov	w2, w7
	fmul	v6.2d, v6.2d, v2.d[0]
	fmul	v5.2d, v5.2d, v2.d[0]
	fmul	v4.2d, v4.2d, v2.d[0]
	fmul	v3.2d, v3.2d, v2.d[0]
	fadd	v22.2d, v6.2d, v22.2d
	fadd	v23.2d, v5.2d, v23.2d
	fadd	v24.2d, v4.2d, v24.2d
	fadd	v25.2d, v3.2d, v25.2d
.L353:
	ldr	x0, [sp, 200]
	add	x8, x8, 8
	mov	v7.16b, v26.16b
	add	x11, x11, 64
	mov	v18.16b, v27.16b
	mov	v21.16b, v16.16b
	cmp	x8, x0
	bne	.L355
	stp	q20, q26, [sp, 816]
	stp	q27, q16, [sp, 848]
	ldr	x0, [sp, 312]
	cbz	w7, .L340
	str	q0, [sp, 928]
.L340:
	cbz	w16, .L341
	str	q19, [sp, 912]
.L341:
	cbz	w13, .L342
	str	q8, [sp, 896]
.L342:
	cbz	w12, .L343
	str	q1, [sp, 880]
.L343:
	cbz	w28, .L344
	str	q25, [sp, 992]
.L344:
	cbz	w17, .L345
	str	q24, [sp, 976]
.L345:
	cbz	w6, .L346
	str	q23, [sp, 960]
.L346:
	cbz	w2, .L359
	str	q22, [sp, 944]
	b	.L359
.L670:
	cmp	w26, w17
	ble	.L311
	ldr	w9, [sp, 264]
	sub	w11, w26, #1
	ldr	x5, [sp, 336]
	cmp	w11, w9
	csel	w11, w11, w9, le
	cmp	w23, 0
	csinc	w1, w1, wzr, gt
	mov	x4, x25
	ldr	x12, [sp, 472]
	add	x22, x5, x25, lsl 3
	and	w20, w1, -2
	and	w13, w1, 1
	lsr	w10, w1, 1
	mov	x0, x22
.L314:
	ldr	d1, [x12]
	cmp	w23, 0
	ble	.L328
	cmp	w23, 1
	beq	.L488
	ldr	q2, [x0]
	dup	v0.2d, v1.d[0]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0]
	cmp	w10, 1
	bls	.L327
	ldr	q2, [x0, 16]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 16]
	cmp	w10, 2
	beq	.L327
	ldr	q2, [x0, 32]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 32]
	cmp	w10, 3
	beq	.L327
	ldr	q2, [x0, 48]
	fdiv	v0.2d, v2.2d, v0.2d
	str	q0, [x0, 48]
.L327:
	mov	w3, w20
	cbz	w13, .L328
.L326:
	add	x3, x4, w3, sxtw
	ldr	d0, [x5, x3, lsl 3]
	fdiv	d0, d0, d1
	str	d0, [x5, x3, lsl 3]
.L328:
	ldr	x3, [sp, 448]
	add	w9, w9, 1
	add	x0, x0, x19
	add	x12, x12, x3
	ldr	x3, [sp, 160]
	add	x4, x4, x3
	cmp	w9, w11
	ble	.L314
	cmp	w9, w26
	bge	.L311
	ldr	w0, [sp, 168]
	sbfiz	x11, x9, 3, 32
	ldr	x3, [sp, 744]
	and	w1, w1, 1
	ldr	x12, [sp, 336]
	smaddl	x13, w0, w9, x27
	madd	x18, x3, x11, x15
	add	x0, sp, 816
	movi	v2.4s, 0
	madd	x11, x21, x11, x15
	add	x4, x12, x13, lsl 3
.L324:
	stp	q2, q2, [x0]
	stp	q2, q2, [x0, 32]
	cmp	w23, 0
	ble	.L315
	ldr	x14, [sp, 176]
	mov	x5, x22
	mov	x24, x25
.L318:
	ldr	d0, [x11, x14, lsl 3]
	cmp	w23, 1
	beq	.L486
	ldr	q3, [x5]
	ldr	q1, [sp, 816]
	fmul	v3.2d, v3.2d, v0.d[0]
	dup	v4.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 816]
	cmp	w10, 1
	bls	.L317
	ldr	q3, [x5, 16]
	ldr	q1, [sp, 832]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 832]
	cmp	w10, 2
	beq	.L317
	ldr	q3, [x5, 32]
	ldr	q1, [sp, 848]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 848]
	cmp	w10, 3
	beq	.L317
	ldr	q3, [x5, 48]
	ldr	q1, [sp, 864]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 864]
.L317:
	sxtw	x3, w20
	cbz	w1, .L320
.L316:
	add	x30, x3, x24
	ldr	d1, [x0, x3, lsl 3]
	ldr	d3, [x12, x30, lsl 3]
	fmul	d0, d0, d3
	fadd	d0, d0, d1
	str	d0, [x0, x3, lsl 3]
.L320:
	ldr	x3, [sp, 160]
	add	x14, x14, 1
	add	x5, x5, x19
	add	x24, x24, x3
	cmp	w9, w14
	bgt	.L318
	ldr	d3, [x18]
	cmp	w23, 1
	beq	.L487
	ldr	q0, [x4]
	ldr	q4, [sp, 816]
	dup	v1.2d, v3.d[0]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4]
	cmp	w10, 1
	bls	.L322
	ldr	q0, [x4, 16]
	ldr	q4, [sp, 832]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4, 16]
	cmp	w10, 2
	beq	.L322
	ldr	q0, [x4, 32]
	ldr	q4, [sp, 848]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4, 32]
	cmp	w10, 3
	beq	.L322
	ldr	q0, [x4, 48]
	ldr	q4, [sp, 864]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x4, 48]
.L322:
	sxtw	x3, w20
	cbz	w1, .L315
.L321:
	add	x5, x3, x13
	ldr	d1, [x0, x3, lsl 3]
	ldr	d0, [x12, x5, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d3
	str	d0, [x12, x5, lsl 3]
.L315:
	ldr	x3, [sp, 448]
	add	w9, w9, 1
	add	x4, x4, x19
	add	x18, x18, x3
	ldr	x3, [sp, 160]
	add	x13, x13, x3
	ldr	x3, [sp, 288]
	add	x11, x11, x3
	cmp	w9, w26
	bne	.L324
	ldr	w0, [sp, 580]
	add	w28, w28, 8
	sub	w23, w23, #8
	add	x27, x27, 8
	add	x25, x25, 8
	cmp	w0, w28
	bgt	.L310
	b	.L672
.L487:
	mov	x3, 0
	b	.L321
.L486:
	mov	x3, 0
	b	.L316
.L488:
	mov	w3, 0
	b	.L326
.L491:
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
	b	.L357
.L667:
	.cfi_restore 72
	ldr	w3, [sp, 500]
	sub	w17, w26, w15
	sub	w1, w1, #1
	str	w1, [sp, 644]
	sub	w1, w17, #1
	str	x1, [sp, 624]
	ldr	x1, [sp, 176]
	str	w1, [sp, 256]
	udiv	w2, w0, w3
	mov	w23, w26
	ldr	x24, [sp, 336]
	neg	x4, x1, lsl 3
	ldr	w1, [sp, 268]
	add	w27, w15, 1
	msub	w0, w2, w3, w0
	add	w9, w26, w2, lsl 6
	sub	w1, w1, w9
	str	w1, [sp, 544]
	ldr	x28, [sp, 536]
	lsl	w30, w0, 6
	ldr	w1, [sp, 496]
	mov	w13, w30
	mov	w21, w9
	sub	w15, w26, #1
	and	w1, w1, 1
	str	x4, [sp, 136]
	str	w15, [sp, 148]
	str	w1, [sp, 272]
	str	w27, [sp, 372]
	str	wzr, [sp, 480]
	str	w17, [sp, 484]
	str	w20, [sp, 756]
	str	w22, [sp, 760]
	str	w25, [sp, 764]
	str	x19, [sp, 768]
	str	d8, [sp, 96]
	.cfi_offset 72, -976
.L368:
	ldr	w2, [sp, 368]
	mov	w22, w21
	ldr	w0, [sp, 544]
	ldr	w3, [sp, 268]
	sub	w1, w2, w13
	cmp	w0, 63
	add	w0, w21, 64
	csel	w14, w0, w3, gt
	add	w0, w13, 64
	cmp	w1, 63
	csel	w10, w0, w2, gt
	ldr	w0, [sp, 272]
	cbnz	w0, .L673
.L371:
	cmp	w14, w22
	ble	.L445
	ldp	w2, w1, [sp, 168]
	sub	w0, w10, w13
	ldr	x3, [sp, 176]
	add	w4, w13, 31
	smull	x1, w1, w22
	sub	w0, w0, #32
	smull	x2, w2, w22
	and	w0, w0, -32
	add	x5, x1, x3
	cmp	w10, w4
	ldr	x3, [sp, 280]
	csel	w0, w0, wzr, gt
	ldp	x27, x25, [sp, 504]
	sub	x6, x3, x2
	add	x7, x3, w13, sxtw
	sub	w15, w14, w22
	ldr	x3, [sp, 624]
	add	x17, x28, x5, lsl 3
	mov	x19, x24
	mov	w26, w13
	add	x8, x3, 1
	add	w3, w13, 32
	add	w0, w0, w3
	str	w0, [sp, 592]
	lsl	x0, x6, 3
	str	x0, [sp, 328]
	neg	x0, x6, lsl 3
	mov	x5, x2
	mov	w22, w23
	str	x0, [sp, 344]
	add	x0, x24, x7, lsl 3
	mov	w24, w15
	stp	x2, x1, [sp, 376]
	mov	x1, x17
	str	w21, [sp, 776]
	mov	w21, w10
	str	x0, [sp, 608]
	lsl	x0, x8, 3
	str	x0, [sp, 736]
	str	w14, [sp, 780]
	str	w4, [sp, 784]
.L444:
	ldr	w0, [sp, 272]
	mov	w20, w26
	cbz	w0, .L442
	cmp	w24, 3
	bgt	.L674
.L442:
	cmp	w21, w20
	ble	.L451
	cmp	w24, 4
	mov	w0, 4
	csel	w0, w24, w0, le
	cmp	w24, 3
	sxtw	x9, w20
	str	w0, [sp, 520]
	cset	w0, gt
	add	x3, x5, x9
	str	w0, [sp, 248]
	mov	w10, w21
	ldr	x0, [sp, 584]
	lsl	x3, x3, 3
	add	x15, x19, x3
	str	w26, [sp, 792]
	add	x0, x0, x3
	str	x5, [sp, 800]
	add	x18, x19, x0
	str	w24, [sp, 808]
	ldr	x0, [sp, 136]
	add	x0, x1, x0
	str	x0, [sp, 488]
	ldr	x0, [sp, 736]
	add	x23, x0, x1
	mov	x26, x23
.L450:
	ldr	x0, [sp, 184]
	sub	w8, w10, w20
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L675
	asr	w0, w20, 3
	mov	x6, 8
	mov	w4, w6
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 248]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	ble	.L676
.L448:
	ldr	w0, [sp, 272]
	cbnz	w0, .L471
	movi	v16.2d, 0
	ldr	w0, [sp, 484]
	cmp	w0, 0
	ble	.L508
	ldr	x23, [sp, 120]
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
.L473:
	ldp	q4, q3, [x3]
	ldp	q2, q0, [x3, 32]
	add	x3, x3, x6
	ldr	d6, [x0, x23, lsl 3]
	ldr	d5, [x0, x27, lsl 3]
	ldr	d1, [x0, x25, lsl 3]
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
	cmp	x26, x0
	bne	.L473
.L472:
	ldp	q3, q2, [x15]
	ldp	q1, q0, [x15, 32]
	ldr	x0, [sp, 128]
	fsub	v3.2d, v3.2d, v31.2d
	fsub	v2.2d, v2.2d, v30.2d
	fsub	v1.2d, v1.2d, v29.2d
	fsub	v0.2d, v0.2d, v28.2d
	stp	q3, q2, [x15]
	stp	q1, q0, [x15, 32]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v27.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 392]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v26.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 400]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v25.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 408]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v24.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 352]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v23.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 416]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v22.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 424]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v21.2d
	str	q0, [x15, x0]
	ldr	x0, [sp, 432]
	ldr	q0, [x15, x0]
	fsub	v0.2d, v0.2d, v20.2d
	str	q0, [x15, x0]
	ldp	q3, q2, [x18]
	ldp	q1, q0, [x18, 32]
	fsub	v3.2d, v3.2d, v19.2d
	fsub	v2.2d, v2.2d, v18.2d
	fsub	v1.2d, v1.2d, v17.2d
	fsub	v0.2d, v0.2d, v16.2d
	stp	q3, q2, [x18]
	stp	q1, q0, [x18, 32]
.L455:
	add	w20, w20, 8
	add	x9, x9, 8
	add	x15, x15, 64
	add	x18, x18, 64
	cmp	w10, w20
	bgt	.L450
	ldr	x5, [sp, 800]
	mov	w21, w10
	ldr	w26, [sp, 792]
	ldr	w24, [sp, 808]
.L451:
	ldr	x6, [sp, 328]
	ldr	x4, [sp, 728]
	ldr	x7, [sp, 672]
	add	x6, x6, x4
	str	x6, [sp, 328]
	ldr	x6, [sp, 384]
	ldr	x3, [sp, 528]
	add	x6, x6, x7
	str	x6, [sp, 384]
	ldr	x6, [sp, 376]
	add	x1, x1, x3
	ldr	x3, [sp, 600]
	ldr	w2, [sp, 780]
	add	x5, x5, x3
	add	x3, x6, x3
	str	x3, [sp, 376]
	sub	w0, w2, w24
	ldr	x3, [sp, 344]
	add	w0, w0, 4
	sub	x3, x3, x4
	str	x3, [sp, 344]
	sub	w3, w24, #4
	cmp	w2, w0
	ble	.L677
	mov	w24, w3
	b	.L444
.L471:
	ldp	w6, w2, [sp, 168]
	mov	x5, x15
	ldr	w0, [sp, 264]
	str	x1, [sp, 152]
	sub	w0, w22, w0
	str	w10, [sp, 192]
	str	x9, [sp, 200]
	bl	update4x8_sve
	ldr	x1, [sp, 152]
	ldr	x9, [sp, 200]
	ldr	w10, [sp, 192]
	b	.L455
.L675:
	ldr	x0, [sp, 328]
	ldr	x6, [sp, 160]
	add	x3, x0, x15
	ldr	w0, [sp, 248]
	ldr	w4, [sp, 168]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	bgt	.L448
.L676:
	cmp	w8, 8
	mov	w14, 8
	csel	w14, w8, w14, le
	lsl	x5, x6, 3
	sub	w0, w14, #1
	str	w0, [sp, 240]
	lsr	w0, w14, 2
	str	w0, [sp, 296]
	add	x0, x3, x5
	str	x0, [sp, 224]
	ldr	x0, [sp, 376]
	and	w7, w14, -2
	ldr	x17, [sp, 128]
	lsr	w4, w14, 1
	ldr	x21, [sp, 384]
	lsl	x2, x6, 1
	ldr	x11, [sp, 488]
	add	x12, x0, x9
	movi	v4.4s, 0
	lsl	x0, x6, 4
	ldr	w30, [sp, 372]
	mov	x13, x15
	str	w7, [sp, 304]
	mov	x7, x18
	ldr	w18, [sp, 520]
	mov	w24, 0
	str	x26, [sp, 552]
	ldr	x26, [sp, 288]
	str	w10, [sp, 576]
	ldr	w10, [sp, 148]
	str	x11, [sp, 152]
	mov	x11, x9
	mov	x9, x2
	str	w4, [sp, 192]
	mov	x4, x27
	str	x6, [sp, 200]
	mov	x6, x1
	str	x0, [sp, 232]
	add	x0, sp, 816
	str	x5, [sp, 440]
	mov	x5, x25
	str	x15, [sp, 560]
	str	w20, [sp, 568]
.L454:
	ldr	w1, [sp, 256]
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w22, w1
	ble	.L453
	cmp	w10, w30
	ble	.L504
	ldr	x2, [sp, 136]
	mov	x25, x3
	ldr	x1, [sp, 152]
	mov	x15, 0
	ldr	x16, [sp, 200]
	sub	x27, x1, x2
	ldr	x20, [sp, 224]
	mov	w1, w30
	str	x19, [sp, 208]
	str	w24, [sp, 216]
	stp	x4, x5, [sp, 312]
	b	.L465
.L680:
	ldp	q0, q1, [x25, 32]
	ldp	q2, q5, [x20, 32]
	ldp	q6, q8, [sp, 848]
	fmul	v1.2d, v1.2d, v7.2d
	fmul	v0.2d, v0.2d, v7.2d
	fmul	v5.2d, v5.2d, v3.2d
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v8.2d
	fadd	v0.2d, v0.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q0, q1, [sp, 848]
	.p2align 3,,7
.L462:
	add	w2, w1, 2
	ldr	x4, [sp, 232]
	add	x27, x27, 16
	add	x15, x15, x9
	add	x16, x16, x9
	add	x25, x25, x4
	add	x20, x20, x4
	cmp	w2, w10
	bge	.L678
	mov	w1, w2
.L465:
	ldr	w2, [sp, 240]
	ldr	d0, [x27]
	cmp	w2, 2
	bls	.L679
	ldp	q1, q2, [x25]
	ldp	q5, q6, [x20]
	ldp	q16, q17, [sp, 816]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d3, [x27, 8]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w2, [sp, 296]
	dup	v7.2d, v0.d[0]
	fmul	v6.2d, v6.2d, v3.d[0]
	fmul	v5.2d, v5.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v17.2d
	fadd	v1.2d, v1.2d, v16.2d
	dup	v3.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	stp	q1, q2, [sp, 816]
	cmp	w2, 2
	beq	.L680
	cmp	w8, 4
	beq	.L462
	mov	x4, 4
	mov	w2, w4
.L460:
	sub	w24, w14, w4
	sxtw	x5, w1
	cmp	w24, 1
	beq	.L463
	add	x23, x15, x4
	add	x19, x4, x16
	lsl	x4, x4, 3
	lsl	x23, x23, 3
	lsl	x19, x19, 3
	ldr	q2, [x0, x4]
	ldr	q1, [x3, x23]
	add	x23, x5, x21
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x4]
	ldr	d3, [x28, x23, lsl 3]
	ldr	q2, [x3, x19]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x4]
	tbz	x24, 0, .L462
	and	w24, w24, -2
	add	w2, w2, w24
.L463:
	sxtw	x2, w2
	add	x5, x5, x21
	add	x19, x15, x2
	add	x4, x2, x16
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x19, lsl 3]
	ldr	d1, [x3, x4, lsl 3]
	ldr	d3, [x28, x5, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
	b	.L462
.L681:
	ldp	x19, x28, [sp, 208]
.L453:
	cmp	w8, 1
	beq	.L503
	ldr	q0, [x13]
	ldr	q1, [sp, 816]
	ldr	w1, [sp, 192]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13]
	cmp	w1, 1
	bls	.L457
	ldr	q0, [x13, 16]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 16]
	cmp	w1, 2
	beq	.L457
	ldr	q0, [x13, 32]
	ldr	q1, [sp, 848]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 32]
	cmp	w1, 4
	bne	.L457
	ldr	q0, [x13, 48]
	ldr	q1, [sp, 864]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 48]
	.p2align 3,,7
.L458:
	add	w24, w24, 1
	ldr	x1, [sp, 160]
	add	x13, x13, x17
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	add	x21, x21, x1
	ldr	x1, [sp, 152]
	add	x1, x1, x26
	str	x1, [sp, 152]
	cmp	w24, w18
	blt	.L454
	ldr	x26, [sp, 552]
	mov	x27, x4
	ldr	x15, [sp, 560]
	mov	x25, x5
	ldr	w20, [sp, 568]
	mov	x1, x6
	ldr	w10, [sp, 576]
	mov	x18, x7
	mov	x9, x11
	b	.L455
.L457:
	ldr	w1, [sp, 304]
	cmp	w14, w1
	beq	.L458
.L456:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x19, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x19, x2, lsl 3]
	b	.L458
.L678:
	ldp	x4, x5, [sp, 312]
	add	w1, w1, 1
	ldr	x19, [sp, 208]
	ldr	w24, [sp, 216]
.L459:
	sxtw	x20, w1
	ldr	w23, [sp, 304]
	ldr	x1, [sp, 176]
	stp	x19, x28, [sp, 208]
	ldr	w19, [sp, 192]
	ldr	x27, [sp, 200]
	sub	x16, x20, x1
	ldr	x25, [sp, 440]
	ldr	x28, [sp, 152]
	mul	x15, x16, x27
	madd	x16, x16, x25, x3
	b	.L469
	.p2align 2,,3
.L682:
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 832]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 832]
	cmp	w19, 2
	beq	.L467
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 848]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 848]
	cmp	w19, 4
	bne	.L467
	ldr	q1, [x16, 48]
	ldr	q0, [sp, 864]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [sp, 864]
	.p2align 3,,7
.L468:
	add	x20, x20, 1
	add	x15, x15, x27
	add	x16, x16, x25
	cmp	w22, w20
	ble	.L681
.L469:
	ldr	d0, [x28, x20, lsl 3]
	cmp	w8, 1
	beq	.L507
	ldr	q2, [x16]
	sxtw	x1, w23
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w19, 1
	bhi	.L682
.L467:
	cmp	w14, w23
	beq	.L468
.L466:
	add	x2, x1, x15
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
	b	.L468
.L507:
	mov	x1, 0
	b	.L466
.L503:
	mov	w1, 0
	b	.L456
.L504:
	ldr	w1, [sp, 264]
	b	.L459
.L679:
	mov	x4, 0
	mov	w2, 0
	b	.L460
.L508:
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
	b	.L472
.L677:
	ldr	w21, [sp, 776]
	mov	w13, w26
	mov	x24, x19
	mov	w23, w22
.L445:
	ldr	w0, [sp, 480]
	ldr	w1, [sp, 644]
	cmp	w0, w1
	beq	.L657
	ldr	w0, [sp, 368]
	add	w13, w13, 64
	cmp	w0, w13
	ble	.L683
.L440:
	ldr	w0, [sp, 480]
	add	w0, w0, 1
	str	w0, [sp, 480]
	b	.L368
.L674:
	ldr	w0, [sp, 784]
	cmp	w21, w0
	ble	.L442
	ldr	x23, [sp, 608]
	str	w26, [sp, 192]
	ldr	w0, [sp, 264]
	mov	x26, x1
	str	x19, [sp, 200]
	mov	w19, w21
	sub	w0, w22, w0
	mov	x21, x23
	mov	w23, w22
	mov	x22, x5
	str	w0, [sp, 152]
	b	.L477
.L475:
	bl	update4x32_sve
	add	x21, x21, 256
	add	w0, w20, 63
	add	w8, w20, 32
	cmp	w19, w0
	ble	.L684
.L478:
	mov	w20, w8
.L477:
	ldr	x0, [sp, 184]
	asr	w3, w20, 3
	ldr	x1, [sp, 344]
	sbfiz	x3, x3, 14, 32
	ldr	x0, [x0, 16]
	add	x6, x21, x1
	ldp	w7, w2, [sp, 168]
	mov	x1, x26
	ldr	x10, [x0]
	mov	w5, 2048
	ldr	w0, [sp, 152]
	mov	w4, 8
	add	x3, x10, x3
	cbnz	x10, .L475
	ldr	x0, [sp, 344]
	mov	x3, x21
	ldp	w4, w2, [sp, 168]
	add	x6, x21, x0
	ldr	w0, [sp, 152]
	mov	w5, 8
	mov	w7, w4
	add	x21, x21, 256
	bl	update4x32_sve
	add	w0, w20, 63
	add	w8, w20, 32
	cmp	w19, w0
	bgt	.L478
.L684:
	mov	w21, w19
	mov	x1, x26
	ldr	x19, [sp, 200]
	mov	x5, x22
	ldr	w26, [sp, 192]
	mov	w22, w23
	ldr	w20, [sp, 592]
	b	.L442
.L673:
	sub	w0, w14, w21
	cmp	w0, 15
	ble	.L372
	ldr	w1, [sp, 168]
	sub	w0, w10, w13
	sub	w6, w0, #32
	add	w7, w13, 32
	add	w9, w13, 31
	and	w0, w6, -32
	ldr	x2, [sp, 280]
	smull	x19, w21, w1
	ldr	w1, [sp, 172]
	add	w0, w0, w7
	cmp	w10, w9
	ldr	w25, [sp, 372]
	csel	w8, w13, w0, le
	str	w6, [sp, 568]
	ldr	x0, [sp, 176]
	smull	x18, w1, w21
	sub	x1, x2, x19
	add	x2, x2, w13, sxtw
	add	x0, x18, x0
	mov	x6, x19
	lsl	x3, x1, 3
	neg	x1, x1, lsl 3
	add	x15, x28, x0, lsl 3
	add	x0, x24, x2, lsl 3
	str	x0, [sp, 488]
	ldr	w0, [sp, 264]
	stp	x1, x3, [sp, 296]
	sxtw	x3, w8
	sub	w0, w23, w0
	str	x18, [sp, 312]
	str	w0, [sp, 320]
	str	w13, [sp, 328]
	str	w14, [sp, 344]
	str	w8, [sp, 376]
	str	x3, [sp, 520]
	str	w9, [sp, 552]
	str	w7, [sp, 560]
	str	w21, [sp, 576]
.L409:
	ldr	w0, [sp, 552]
	cmp	w10, w0
	ble	.L374
	ldr	x9, [sp, 176]
	add	w2, w22, 4
	ldp	w7, w21, [sp, 168]
	add	w1, w22, 8
	ldr	w3, [sp, 568]
	add	w0, w22, 12
	ldr	w4, [sp, 560]
	and	w3, w3, -32
	ldr	w27, [sp, 328]
	ldr	x8, [sp, 280]
	add	w3, w3, w4
	smull	x5, w0, w7
	str	w3, [sp, 208]
	smull	x4, w1, w7
	ldr	w26, [sp, 320]
	smull	x3, w2, w7
	sub	x5, x5, x8
	smaddl	x1, w21, w1, x9
	sub	x4, x4, x8
	smaddl	x2, w21, w2, x9
	sub	x3, x3, x8
	smaddl	x0, w21, w0, x9
	str	w10, [sp, 240]
	add	x1, x28, x1, lsl 3
	lsl	x3, x3, 3
	add	x2, x28, x2, lsl 3
	str	x2, [sp, 152]
	ldr	x20, [sp, 488]
	add	x0, x28, x0, lsl 3
	lsl	x2, x4, 3
	stp	x1, x0, [sp, 192]
	lsl	x1, x5, 3
	str	x1, [sp, 216]
	str	x2, [sp, 224]
	str	x3, [sp, 232]
	str	x24, [sp, 248]
	str	x28, [sp, 384]
	str	w22, [sp, 440]
	str	x19, [sp, 592]
	mov	w19, w7
	str	w23, [sp, 608]
	mov	w23, w27
	mov	w27, w25
	mov	x25, x15
	str	x6, [sp, 736]
	b	.L437
.L438:
	ldr	x0, [sp, 296]
	mov	w7, w19
	mov	w5, w24
	mov	w4, w28
	add	x6, x20, x0
	mov	x3, x22
	mov	w2, w21
	mov	x1, x25
	mov	w0, w26
	bl	update4x32_sve
	ldr	x1, [sp, 152]
	mov	w7, w19
	ldr	x0, [sp, 232]
	mov	w5, w24
	mov	w4, w28
	mov	x3, x22
	add	x6, x20, x0
	mov	w2, w21
	mov	w0, w26
	bl	update4x32_sve
	ldr	x1, [sp, 192]
	mov	w7, w19
	ldr	x0, [sp, 224]
	mov	w5, w24
	mov	w4, w28
	mov	x3, x22
	add	x6, x20, x0
	mov	w2, w21
	mov	w0, w26
	bl	update4x32_sve
	ldr	x1, [sp, 200]
	mov	w7, w19
	ldr	x0, [sp, 216]
	mov	w5, w24
	mov	w4, w28
	mov	x3, x22
	add	x6, x20, x0
	mov	w2, w21
	mov	w0, w26
	bl	update4x32_sve
	ldr	w0, [sp, 208]
	add	w23, w23, 32
	add	x20, x20, 256
	cmp	w23, w0
	beq	.L685
.L437:
	ldr	x0, [sp, 184]
	asr	w22, w23, 3
	mov	w28, 8
	mov	w24, 2048
	sbfiz	x22, x22, 14, 32
	ldr	x0, [x0, 16]
	ldr	x0, [x0]
	add	x22, x0, x22
	cbnz	x0, .L438
	mov	x22, x20
	mov	w28, w19
	mov	w24, 8
	b	.L438
.L685:
	ldr	x24, [sp, 248]
	mov	x15, x25
	ldr	x28, [sp, 384]
	mov	w25, w27
	ldr	x19, [sp, 592]
	ldr	x6, [sp, 736]
	ldr	w10, [sp, 240]
	ldr	w22, [sp, 440]
	ldr	w23, [sp, 608]
.L374:
	ldr	w0, [sp, 376]
	cmp	w10, w0
	ble	.L415
	ldr	x1, [sp, 520]
	str	x15, [sp, 384]
	ldr	w27, [sp, 256]
	add	x0, x19, x1
	add	x13, x1, x6
	ldr	x1, [sp, 136]
	add	x14, x24, x0, lsl 3
	ldr	w20, [sp, 376]
	add	x1, x15, x1
	mov	w15, w10
	mov	x10, x14
	str	x1, [sp, 440]
	str	w22, [sp, 592]
	ldr	x22, [sp, 160]
	str	x19, [sp, 608]
	str	x6, [sp, 736]
	b	.L414
.L412:
	ldr	x1, [sp, 384]
	mov	x5, x10
	ldp	w6, w2, [sp, 168]
	str	x10, [sp, 152]
	ldr	w0, [sp, 320]
	add	w20, w20, 8
	str	w15, [sp, 192]
	str	x13, [sp, 200]
	bl	update16x8_sve
	ldr	x10, [sp, 152]
	ldr	x13, [sp, 200]
	add	x10, x10, 64
	ldr	w15, [sp, 192]
	add	x13, x13, 8
	cmp	w15, w20
	ble	.L686
.L414:
	ldr	x0, [sp, 184]
	sub	w6, w15, w20
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L687
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L434:
	cmp	w6, 7
	bgt	.L412
	lsl	x0, x8, 4
	str	x0, [sp, 248]
	lsl	x0, x8, 1
	lsl	x7, x8, 3
	ldr	x18, [sp, 288]
	str	x0, [sp, 240]
	ldr	x19, [sp, 312]
	sub	w0, w6, #1
	ldr	x5, [sp, 440]
	add	x17, x24, x13, lsl 3
	movi	v4.4s, 0
	add	x30, x7, 16
	and	w21, w6, -4
	lsr	w4, w6, 1
	and	w11, w6, -2
	mov	x12, x13
	and	w9, w6, 1
	str	w0, [sp, 232]
	add	x0, sp, 816
	and	w1, w6, 3
	mov	w26, 16
	str	w1, [sp, 152]
	str	w15, [sp, 776]
	str	w20, [sp, 780]
	str	x13, [sp, 784]
	str	x10, [sp, 792]
	.p2align 3,,7
.L418:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w23, w27
	ble	.L417
	ldr	w1, [sp, 148]
	cmp	w1, w25
	ble	.L499
	ldr	x1, [sp, 136]
	mov	x10, x3
	mov	x16, x8
	mov	x15, 0
	sub	x20, x5, x1
	mov	w1, w25
	str	x24, [sp, 192]
	str	w4, [sp, 200]
	str	w11, [sp, 208]
	stp	x5, x17, [sp, 216]
	b	.L427
	.p2align 2,,3
.L500:
	mov	w1, w2
.L427:
	ldr	w2, [sp, 232]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x5, x4, x19
	cmp	w2, 2
	bls	.L688
	ldp	q1, q2, [x10]
	mov	w11, w21
	ldr	q5, [x10, x30]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 816]
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
	stp	q1, q2, [sp, 816]
	cbz	w5, .L432
.L433:
	uxtw	x5, w11
	add	x17, x4, x19
	add	x14, x5, x15
	add	x13, x5, x16
	sub	w11, w6, w11
	lsl	x5, x5, 3
	mov	x4, x17
	lsl	x14, x14, 3
	lsl	x13, x13, 3
	and	w24, w11, -2
	cmp	w11, 1
	beq	.L425
	ldr	q1, [x3, x14]
	add	w2, w2, w24
	ldr	q2, [x0, x5]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x5]
	ldr	d3, [x28, x17, lsl 3]
	ldr	q2, [x3, x13]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x5]
	tbz	x11, 0, .L432
.L425:
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
.L432:
	ldr	x4, [sp, 248]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x10, x10, x4
	ldr	x4, [sp, 240]
	add	x15, x15, x4
	add	x16, x16, x4
	ldr	w4, [sp, 148]
	cmp	w2, w4
	blt	.L500
	ldp	x5, x17, [sp, 216]
	add	w1, w1, 1
	ldr	x24, [sp, 192]
	ldr	w4, [sp, 200]
	ldr	w11, [sp, 208]
.L423:
	sxtw	x13, w1
	ldr	x1, [sp, 176]
	sub	x14, x13, x1
	mul	x10, x8, x14
	madd	x14, x14, x7, x3
	.p2align 3,,7
.L431:
	ldr	d0, [x5, x13, lsl 3]
	cmp	w6, 1
	beq	.L501
	ldr	q2, [x14]
	sxtw	x1, w11
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w4, 1
	bls	.L429
	ldr	q2, [x14, 16]
	ldr	q1, [sp, 832]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 832]
	cmp	w4, 3
	bne	.L429
	ldr	q2, [x14, 32]
	ldr	q1, [sp, 848]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 848]
.L429:
	cbz	w9, .L430
.L428:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L430:
	add	x13, x13, 1
	add	x10, x10, x8
	add	x14, x14, x7
	cmp	w23, w13
	bgt	.L431
.L417:
	cmp	w6, 1
	beq	.L498
	ldr	q0, [x17]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17]
	cmp	w4, 1
	bls	.L421
	ldr	q0, [x17, 16]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 16]
	cmp	w4, 3
	bne	.L421
	ldr	q0, [x17, 32]
	ldr	q1, [sp, 848]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 32]
.L421:
	sxtw	x1, w11
	cbz	w9, .L422
.L420:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x24, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x24, x2, lsl 3]
.L422:
	ldr	x1, [sp, 128]
	add	x12, x12, x22
	add	x5, x5, x18
	subs	w26, w26, #1
	add	x17, x17, x1
	ldr	x1, [sp, 120]
	add	x19, x19, x1
	bne	.L418
	ldr	x13, [sp, 784]
	ldr	x10, [sp, 792]
	add	x13, x13, 8
	ldr	w20, [sp, 780]
	ldr	w15, [sp, 776]
	add	x10, x10, 64
	add	w20, w20, 8
	cmp	w15, w20
	bgt	.L414
.L686:
	ldr	x19, [sp, 608]
	mov	w10, w15
	ldr	x15, [sp, 384]
	ldr	x6, [sp, 736]
	ldr	w22, [sp, 592]
.L415:
	ldr	x2, [sp, 632]
	add	w22, w22, 16
	ldr	x3, [sp, 648]
	add	x15, x15, x2
	ldr	x2, [sp, 312]
	ldr	x1, [sp, 352]
	add	x2, x2, x3
	ldr	x3, [sp, 304]
	add	x19, x19, x1
	add	x6, x6, x1
	str	x2, [sp, 312]
	ldr	x1, [sp, 296]
	ldr	x2, [sp, 712]
	ldr	w0, [sp, 344]
	add	x3, x3, x2
	sub	x1, x1, x2
	sub	w0, w0, w22
	stp	x1, x3, [sp, 296]
	cmp	w0, 15
	bgt	.L409
	ldr	w13, [sp, 328]
	ldr	w14, [sp, 344]
	ldr	w21, [sp, 576]
.L372:
	add	w0, w22, 7
	cmp	w14, w0
	ble	.L371
	sub	w0, w10, w13
	sub	w3, w14, #8
	sub	w9, w0, #32
	sub	w19, w3, w22
	ldp	w0, w2, [sp, 168]
	add	w5, w13, 32
	ldr	x3, [sp, 280]
	add	w6, w13, 31
	ldr	x7, [sp, 176]
	smull	x0, w0, w22
	smull	x2, w2, w22
	and	w1, w9, -32
	sub	x4, x3, x0
	add	x8, x3, w13, sxtw
	add	x7, x2, x7
	and	w3, w19, -8
	add	w1, w1, w5
	cmp	w10, w6
	str	x2, [sp, 440]
	add	w2, w22, 8
	csel	w1, w13, w1, le
	add	w3, w3, w2
	str	w3, [sp, 576]
	lsl	x3, x4, 3
	sxtw	x11, w1
	str	x3, [sp, 376]
	add	x3, x24, x8, lsl 3
	ldr	w18, [sp, 372]
	str	x11, [sp, 552]
	add	x11, x28, x7, lsl 3
	str	x3, [sp, 560]
	mov	x26, x28
	ldr	w3, [sp, 264]
	neg	x25, x4, lsl 3
	mov	x28, x11
	str	w19, [sp, 736]
	mov	x19, x0
	sub	w3, w23, w3
	str	w3, [sp, 232]
	str	x0, [sp, 384]
	str	w13, [sp, 488]
	str	w1, [sp, 520]
	str	w21, [sp, 592]
	str	w14, [sp, 608]
	str	w6, [sp, 776]
	str	w9, [sp, 780]
	str	w5, [sp, 784]
	str	w2, [sp, 792]
.L377:
	ldr	w0, [sp, 776]
	cmp	w10, w0
	ble	.L407
	ldr	w1, [sp, 780]
	add	w0, w22, 4
	ldr	w2, [sp, 784]
	and	w1, w1, -32
	ldr	w27, [sp, 488]
	add	w1, w1, w2
	ldr	w2, [sp, 172]
	ldr	x3, [sp, 176]
	str	w1, [sp, 200]
	ldr	w1, [sp, 168]
	ldr	x21, [sp, 560]
	str	w10, [sp, 208]
	smull	x1, w0, w1
	mov	x20, x21
	smaddl	x0, w2, w0, x3
	mov	w21, w27
	ldr	x2, [sp, 280]
	mov	x27, x19
	add	x0, x26, x0, lsl 3
	mov	x19, x25
	sub	x1, x1, x2
	mov	w25, w23
	mov	w23, w22
	mov	x22, x28
	mov	w28, w18
	str	x0, [sp, 152]
	lsl	x0, x1, 3
	str	x0, [sp, 192]
	b	.L405
.L403:
	str	x8, [sp, 216]
	bl	update4x32_sve
	ldr	x0, [sp, 192]
	mov	w5, 2048
	ldr	x1, [sp, 152]
	add	x6, x0, x20
	ldr	x8, [sp, 216]
	mov	w4, 8
	ldr	w0, [sp, 232]
	add	w21, w21, 32
	ldr	w7, [sp, 168]
	mov	x3, x8
	ldr	w2, [sp, 172]
	add	x20, x20, 256
	bl	update4x32_sve
	ldr	w0, [sp, 200]
	cmp	w21, w0
	beq	.L689
.L405:
	ldr	x0, [sp, 184]
	asr	w8, w21, 3
	ldp	w7, w2, [sp, 168]
	sbfiz	x8, x8, 14, 32
	ldr	x0, [x0, 16]
	add	x6, x20, x19
	mov	x1, x22
	mov	w5, 2048
	mov	w4, 8
	ldr	x11, [x0]
	ldr	w0, [sp, 232]
	add	x8, x11, x8
	mov	x3, x8
	cbnz	x11, .L403
	mov	x4, x7
	mov	x3, x20
	mov	w5, 8
	str	w7, [sp, 168]
	bl	update4x32_sve
	add	w21, w21, 32
	ldr	x1, [sp, 192]
	mov	x3, x20
	ldr	w4, [sp, 168]
	mov	w5, 8
	add	x6, x1, x20
	ldr	w0, [sp, 232]
	ldr	x1, [sp, 152]
	mov	w7, w4
	ldr	w2, [sp, 172]
	add	x20, x20, 256
	bl	update4x32_sve
	ldr	w0, [sp, 200]
	cmp	w21, w0
	bne	.L405
.L689:
	ldr	w10, [sp, 208]
	mov	w18, w28
	mov	x28, x22
	mov	w22, w23
	mov	w23, w25
	mov	x25, x19
	mov	x19, x27
.L407:
	ldr	w0, [sp, 520]
	cmp	w10, w0
	ble	.L383
	ldr	x2, [sp, 384]
	str	x25, [sp, 800]
	ldr	x1, [sp, 552]
	str	w22, [sp, 808]
	ldr	w20, [sp, 520]
	add	x13, x1, x2
	add	x0, x1, x19
	ldr	x1, [sp, 136]
	add	x15, x24, x0, lsl 3
	mov	x22, x13
	mov	x25, x15
	add	x1, x28, x1
	mov	x13, x19
	str	x1, [sp, 568]
	mov	x1, x28
	mov	w28, w18
	b	.L382
.L380:
	ldp	w6, w2, [sp, 168]
	mov	x5, x25
	ldr	w0, [sp, 232]
	add	w20, w20, 8
	str	x1, [sp, 152]
	add	x25, x25, 64
	str	w10, [sp, 192]
	add	x22, x22, 8
	str	x13, [sp, 200]
	bl	update8x8_sve
	ldr	w10, [sp, 192]
	ldr	x1, [sp, 152]
	ldr	x13, [sp, 200]
	cmp	w10, w20
	ble	.L690
.L382:
	ldr	x0, [sp, 184]
	sub	w5, w10, w20
	ldr	x0, [x0, 16]
	ldr	x3, [x0]
	cbz	x3, .L691
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L402:
	cmp	w5, 7
	bgt	.L380
	ldr	x6, [sp, 568]
	lsl	x0, x8, 4
	lsl	x18, x8, 1
	and	w9, w5, 1
	ldr	x19, [sp, 440]
	lsl	x7, x8, 3
	lsr	w4, w5, 1
	and	w11, w5, -2
	and	w2, w5, 3
	ldr	w30, [sp, 256]
	movi	v4.4s, 0
	str	x6, [sp, 152]
	mov	x6, x25
	str	w9, [sp, 200]
	ldr	x25, [sp, 288]
	mov	x9, x13
	mov	x13, x18
	ldr	w18, [sp, 148]
	str	x0, [sp, 224]
	sub	w0, w5, #1
	add	x14, x24, x22, lsl 3
	mov	x12, x22
	add	x27, x7, 16
	and	w21, w5, -4
	str	w4, [sp, 192]
	mov	w4, w20
	str	x8, [sp, 208]
	mov	x8, x22
	mov	w22, w2
	str	w0, [sp, 216]
	add	x0, sp, 816
	str	w11, [sp, 344]
	mov	x11, x1
	mov	w17, 8
	str	w10, [sp, 812]
.L386:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w23, w30
	ble	.L385
	cmp	w18, w28
	ble	.L495
	ldr	x2, [sp, 136]
	mov	x10, x3
	ldr	x1, [sp, 152]
	mov	x15, 0
	ldr	x16, [sp, 208]
	sub	x20, x1, x2
	mov	w1, w28
	stp	x24, x14, [sp, 240]
	str	w4, [sp, 296]
	stp	x6, x8, [sp, 304]
	str	w17, [sp, 320]
	str	x12, [sp, 328]
	b	.L395
.L496:
	mov	w1, w2
.L395:
	ldr	w2, [sp, 216]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x6, x4, x19
	cmp	w2, 2
	bls	.L692
	ldp	q1, q2, [x10]
	mov	w8, w21
	ldr	q5, [x10, x27]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 816]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x26, x6, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 816]
	cbz	w22, .L400
.L401:
	uxtw	x6, w8
	add	x17, x4, x19
	add	x14, x15, x6
	add	x12, x16, x6
	sub	w8, w5, w8
	lsl	x6, x6, 3
	mov	x4, x17
	lsl	x14, x14, 3
	lsl	x12, x12, 3
	and	w24, w8, -2
	cmp	w8, 1
	beq	.L393
	ldr	q1, [x3, x14]
	add	w2, w2, w24
	ldr	q2, [x0, x6]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x6]
	ldr	d3, [x26, x17, lsl 3]
	ldr	q2, [x3, x12]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x6]
	tbz	x8, 0, .L400
.L393:
	sxtw	x2, w2
	ldr	d3, [x26, x4, lsl 3]
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
.L400:
	ldr	x4, [sp, 224]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x15, x15, x13
	add	x16, x16, x13
	add	x10, x10, x4
	cmp	w2, w18
	blt	.L496
	ldp	x24, x14, [sp, 240]
	add	w1, w1, 1
	ldp	x6, x8, [sp, 304]
	ldr	x12, [sp, 328]
	ldr	w4, [sp, 296]
	ldr	w17, [sp, 320]
.L391:
	sxtw	x15, w1
	str	x24, [sp, 248]
	ldr	x1, [sp, 176]
	stp	x26, x14, [sp, 296]
	ldr	w24, [sp, 344]
	sub	x16, x15, x1
	ldr	w14, [sp, 192]
	ldr	x1, [sp, 208]
	str	w21, [sp, 240]
	ldr	x20, [sp, 152]
	mov	x21, x1
	mul	x10, x16, x1
	ldr	w26, [sp, 200]
	madd	x16, x16, x7, x3
	.p2align 3,,7
.L399:
	ldr	d0, [x20, x15, lsl 3]
	cmp	w5, 1
	beq	.L497
	ldr	q2, [x16]
	sxtw	x1, w24
	ldr	q1, [sp, 816]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 816]
	cmp	w14, 1
	bls	.L397
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 832]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 832]
	cmp	w14, 3
	bne	.L397
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 848]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 848]
.L397:
	cbz	w26, .L398
.L396:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L398:
	add	x15, x15, 1
	add	x10, x10, x21
	add	x16, x16, x7
	cmp	w23, w15
	bgt	.L399
	ldp	x26, x14, [sp, 296]
	ldr	x24, [sp, 248]
	ldr	w21, [sp, 240]
.L385:
	cmp	w5, 1
	beq	.L494
	ldr	q0, [x14]
	ldr	q1, [sp, 816]
	ldr	w1, [sp, 192]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14]
	cmp	w1, 1
	bls	.L389
	ldr	q0, [x14, 16]
	ldr	q1, [sp, 832]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 16]
	cmp	w1, 3
	bne	.L389
	ldr	q0, [x14, 32]
	ldr	q1, [sp, 848]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 32]
.L389:
	ldr	w1, [sp, 200]
	cbz	w1, .L390
	ldr	w1, [sp, 344]
.L388:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x24, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x24, x2, lsl 3]
.L390:
	ldr	x1, [sp, 160]
	subs	w17, w17, #1
	add	x12, x12, x1
	ldr	x1, [sp, 128]
	add	x14, x14, x1
	ldr	x1, [sp, 120]
	add	x19, x19, x1
	ldr	x1, [sp, 152]
	add	x1, x1, x25
	str	x1, [sp, 152]
	bne	.L386
	mov	w20, w4
	ldr	w10, [sp, 812]
	mov	x25, x6
	mov	x22, x8
	add	w20, w20, 8
	mov	x13, x9
	mov	x1, x11
	add	x25, x25, 64
	add	x22, x22, 8
	cmp	w10, w20
	bgt	.L382
.L690:
	ldr	x25, [sp, 800]
	mov	w18, w28
	ldr	w22, [sp, 808]
	mov	x19, x13
	mov	x28, x1
.L383:
	ldr	x1, [sp, 616]
	add	w22, w22, 8
	ldr	x2, [sp, 288]
	add	x28, x28, x1
	ldr	x1, [sp, 440]
	ldr	x0, [sp, 128]
	add	x1, x1, x2
	ldr	x2, [sp, 376]
	str	x1, [sp, 440]
	ldr	x1, [sp, 720]
	add	x19, x19, x0
	add	x2, x2, x1
	str	x2, [sp, 376]
	ldr	x2, [sp, 384]
	sub	x25, x25, x1
	add	x0, x2, x0
	str	x0, [sp, 384]
	ldr	w0, [sp, 576]
	cmp	w22, w0
	bne	.L377
	ldr	w19, [sp, 736]
	mov	x28, x26
	ldr	w2, [sp, 792]
	and	w19, w19, -8
	ldr	w13, [sp, 488]
	ldr	w21, [sp, 592]
	add	w22, w19, w2
	ldr	w14, [sp, 608]
	b	.L371
	.p2align 2,,3
.L501:
	mov	x1, 0
	b	.L428
.L498:
	mov	x1, 0
	b	.L420
.L499:
	ldr	w1, [sp, 264]
	b	.L423
.L688:
	mov	w11, 0
	mov	w2, 0
	b	.L433
.L687:
	ldr	x0, [sp, 304]
	mov	x8, x22
	ldr	w4, [sp, 168]
	add	x3, x10, x0
	b	.L434
.L497:
	mov	x1, 0
	b	.L396
.L494:
	mov	w1, 0
	b	.L388
.L495:
	ldr	w1, [sp, 264]
	b	.L391
.L691:
	ldr	x0, [sp, 376]
	ldr	x8, [sp, 160]
	add	x3, x0, x25
	ldr	w4, [sp, 168]
	b	.L402
.L692:
	mov	w8, 0
	mov	w2, 0
	b	.L401
.L683:
	ldr	w0, [sp, 268]
	add	w21, w21, 64
	mov	w13, 0
	sub	w0, w0, w21
	str	w0, [sp, 544]
	b	.L440
.L657:
	ldr	d8, [sp, 96]
	.cfi_restore 72
	ldr	x19, [sp, 768]
	ldr	w20, [sp, 756]
	ldr	w22, [sp, 760]
	ldr	w25, [sp, 764]
	b	.L366
.L668:
	ldp	x19, x20, [sp, 16]
	.cfi_restore 20
	.cfi_restore 19
	ldp	x21, x22, [sp, 32]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
.L302:
	ldp	x29, x30, [sp]
	ldp	x23, x24, [sp, 48]
	ldp	x27, x28, [sp, 80]
	add	sp, sp, 1072
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
.L367:
	.cfi_def_cfa_offset 1072
	.cfi_offset 19, -1056
	.cfi_offset 20, -1048
	.cfi_offset 21, -1040
	.cfi_offset 22, -1032
	.cfi_offset 23, -1024
	.cfi_offset 24, -1016
	.cfi_offset 25, -1008
	.cfi_offset 26, -1000
	.cfi_offset 27, -992
	.cfi_offset 28, -984
	.cfi_offset 29, -1072
	.cfi_offset 30, -1064
	add	w1, w1, 1
	mov	w0, 0
	b	.L482
.L666:
	str	d8, [sp, 96]
	.cfi_offset 72, -976
	b	.L485
.L489:
	mov	w13, 0
	b	.L350
	.p2align 2,,3
.L484:
	.cfi_restore 72
	bl	GOMP_barrier
	b	.L366
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
	ble	.L702
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
	bls	.L695
	sxtw	x2, w20
	add	x0, sp, 80
	add	x2, x2, 7
	mov	x1, 64
	str	xzr, [sp, 88]
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L696
	ldr	x0, [sp, 80]
	str	x0, [sp, 88]
.L696:
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
.L702:
	ret
	.p2align 2,,3
.L695:
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
	ble	.L698
	sxtw	x0, w26
	sub	x2, x0, #1
	mul	x2, x2, x0
	lsl	x2, x2, 10
	cmp	x2, 4194304
	bhi	.L705
	add	x0, sp, 88
	mov	x1, 64
	bl	posix_memalign
	cbnz	w0, .L698
	ldr	x0, [sp, 88]
	str	x0, [sp, 80]
.L698:
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
.L705:
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
