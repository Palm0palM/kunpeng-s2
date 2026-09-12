	.arch armv8-a
	.file	"trsm.c"
	.text
	.align	2
	.p2align 4,,11
	.arch armv8-a+sve
	.type	trsm_sve_has_eight_doubles, %function
trsm_sve_has_eight_doubles:
.LFB4366:
	.cfi_startproc
	cntd	x0
	cmp	x0, 8
	cset	w0, eq
	ret
	.cfi_endproc
.LFE4366:
	.size	trsm_sve_has_eight_doubles, .-trsm_sve_has_eight_doubles
	.align	2
	.p2align 4,,11
	.type	update8x8_sve, %function
update8x8_sve:
.LFB4368:
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
.LFE4368:
	.size	update8x8_sve, .-update8x8_sve
	.align	2
	.p2align 4,,11
	.type	update16x8_sve, %function
update16x8_sve:
.LFB4369:
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
.LFE4369:
	.size	update16x8_sve, .-update16x8_sve
	.align	2
	.p2align 4,,11
	.type	update4x8_sve, %function
update4x8_sve:
.LFB4367:
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
.LFE4367:
	.size	update4x8_sve, .-update4x8_sve
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
	cbz	w0, .L26
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
.L25:
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
	bne	.L25
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L24:
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
.L26:
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
	b	.L24
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
	cbz	w0, .L32
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
.L31:
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
	bne	.L31
.L30:
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
.L32:
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
	b	.L30
	.cfi_endproc
.LFE4363:
	.size	solve16x8_panel_packedL_sve, .-solve16x8_panel_packedL_sve
	.align	2
	.p2align 4,,11
	.arch armv8-a
	.type	solve_panel._omp_fn.0, %function
solve_panel._omp_fn.0:
.LFB4373:
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
	cbz	x19, .L93
	bl	omp_get_num_threads
	mov	w21, w0
	bl	omp_get_thread_num
	ldr	x1, [sp, 176]
	ldr	w2, [x1, 44]
	sub	w2, w2, #1
	sdiv	w1, w2, w21
	msub	w2, w1, w21, w2
	cmp	w0, w2
	blt	.L91
.L99:
	madd	w0, w1, w0, w2
	add	w1, w1, w0
	cmp	w0, w1
	blt	.L92
.L96:
	bl	GOMP_barrier
.L93:
	ldr	w0, [sp, 216]
	cbz	w0, .L90
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 216]
.L90:
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
	blt	.L39
.L88:
	madd	w0, w1, w3, w0
	add	w1, w1, w0
	cmp	w0, w1
	bge	.L40
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
.L43:
	cmp	w24, 8
	mov	w0, 8
	csel	w6, w24, w0, le
	cbz	x21, .L155
	cmp	w28, 0
	ble	.L44
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
.L81:
	mov	x1, x26
	mov	x2, x23
	mov	x0, x19
	cmp	w24, 0
	ble	.L46
	bl	memcpy
	cmp	w24, 7
	bgt	.L156
.L46:
	add	x0, x21, x19
	mov	x2, x22
	mov	w1, 0
	add	x19, x19, 64
	bl	memset
	add	x26, x26, x20
	cmp	x27, x19
	bne	.L81
	ldp	x21, x22, [sp, 240]
	mov	x1, x28
	ldr	x27, [sp, 224]
	mov	x19, x25
	ldr	x23, [sp, 256]
	ldr	w28, [sp, 232]
.L79:
	ldr	w0, [sp, 216]
	mov	w14, w0
	tbnz	x0, 0, .L157
.L47:
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
.L57:
	stp	q17, q17, [x5]
	stp	q17, q17, [x5, 32]
	stp	q17, q17, [x5, 64]
	stp	q17, q17, [x5, 96]
	stp	q17, q17, [x5, 128]
	stp	q17, q17, [x5, 160]
	stp	q17, q17, [x5, 192]
	stp	q17, q17, [x5, 224]
	cmp	w7, 3
	ble	.L158
	movi	v16.2d, 0
	cmp	w8, 0
	ble	.L105
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
.L77:
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
	bne	.L77
.L76:
	stp	q8, q31, [sp, 304]
	stp	q30, q29, [sp, 336]
	stp	q28, q27, [sp, 368]
	stp	q26, q25, [sp, 400]
	stp	q24, q23, [sp, 432]
	stp	q22, q21, [sp, 464]
	stp	q20, q19, [sp, 496]
	stp	q18, q16, [sp, 528]
.L78:
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
	beq	.L67
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
	b	.L68
	.p2align 2,,3
.L71:
	add	x1, x1, 64
	add	x10, x10, x19
	cmp	w4, 2
	beq	.L103
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
.L69:
	add	x0, x0, 64
	ldr	x13, [sp, 120]
	add	x6, x6, x13
.L68:
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
	ble	.L70
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
	bne	.L70
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
.L70:
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
	bne	.L71
.L67:
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
	bgt	.L57
	ldp	x20, x1, [sp, 248]
	ldr	w24, [sp, 240]
.L58:
	cmp	w24, 0
	ble	.L44
	ldr	x3, [sp, 152]
	mov	x0, x19
	ldr	x26, [sp, 168]
	mov	x19, x21
	stp	x27, x21, [sp, 224]
	mov	x25, x0
	mov	x27, x1
	ldr	x21, [sp, 208]
.L54:
	mov	x1, x19
	mov	x0, x3
	mov	x2, x21
	add	x19, x19, 64
	bl	memcpy
	add	x3, x0, x20
	cmp	x26, x19
	bne	.L54
	mov	x1, x27
	mov	x19, x25
	ldp	x27, x21, [sp, 224]
.L44:
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
	bgt	.L43
	ldr	d8, [sp, 96]
	.cfi_restore 72
.L40:
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
.L158:
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
	ble	.L78
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
.L74:
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
	ble	.L72
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
	bne	.L72
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
.L72:
	add	x0, x0, 64
	add	x4, x4, 8
	mov	v8.16b, v28.16b
	mov	v18.16b, v23.16b
	mov	v19.16b, v2.16b
	cmp	x2, x0
	bne	.L74
	stp	q3, q28, [sp, 304]
	stp	q23, q2, [sp, 336]
	cbz	w1, .L59
	str	q1, [sp, 416]
.L59:
	cbz	w11, .L60
	str	q20, [sp, 400]
.L60:
	cbz	w12, .L61
	str	q4, [sp, 384]
.L61:
	cbz	w13, .L62
	str	q5, [sp, 368]
.L62:
	cbz	w18, .L63
	str	q26, [sp, 480]
.L63:
	cbz	w17, .L64
	str	q25, [sp, 464]
.L64:
	cbz	w16, .L65
	str	q24, [sp, 448]
.L65:
	cbz	w20, .L78
	str	q27, [sp, 432]
	b	.L78
.L105:
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
	b	.L76
.L157:
	cmp	w28, 15
	ble	.L101
	mov	x0, x19
	mov	x25, 0
	mov	x19, x21
	mov	x26, x0
	mov	x21, x27
	stp	x20, x1, [sp, 224]
	mov	x20, x25
	b	.L50
.L147:
	bl	solve16x8_panel_sve
	add	x20, x20, 16
	ldr	x0, [sp, 200]
	add	x21, x21, x0
	ldr	x0, [sp, 192]
	cmp	x0, x20
	beq	.L159
.L50:
	ldr	x0, [sp, 176]
	cmp	w20, 0
	ldr	w1, [sp, 148]
	mov	x3, x19
	mov	x2, x21
	ldr	x4, [x0, 16]
	mov	w0, w20
	ldr	x4, [x4]
	ccmp	x4, 0, 4, ne
	beq	.L147
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
	bne	.L50
.L159:
	ldr	w0, [sp, 268]
	mov	x21, x19
	ldp	x20, x1, [sp, 224]
	mov	x19, x26
	mov	w14, w0
	cmp	w28, w0
	bgt	.L47
	b	.L58
	.p2align 2,,3
.L155:
	cmp	w24, 0
	ble	.L44
	cmp	w28, 0
	ble	.L44
	ldp	x7, x8, [sp, 152]
	lsl	x9, x19, 3
	ldr	x30, [sp, 120]
	add	x6, x8, w6, uxtw
.L85:
	ldr	d0, [x7]
	ldr	d1, [x27]
	fdiv	d0, d0, d1
	str	d0, [x7]
	cmp	w28, 1
	beq	.L84
	ldr	x0, [sp, 280]
	add	x4, x27, x30
	ldr	x3, [sp, 184]
	add	x0, x0, x8
	add	x5, x27, x9
	mov	w2, 1
	add	x0, x3, x0, lsl 3
	.p2align 3,,7
.L87:
	movi	d1, #0
	mov	x10, x7
	mov	x3, 0
	.p2align 3,,7
.L86:
	ldr	d2, [x5, x3, lsl 3]
	add	x3, x3, 1
	ldr	d0, [x10]
	add	x10, x10, x20
	fmul	d0, d0, d2
	fadd	d1, d1, d0
	cmp	w2, w3
	bgt	.L86
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
	bne	.L87
.L84:
	add	x8, x8, 1
	add	x7, x7, 8
	cmp	x6, x8
	bne	.L85
	b	.L44
.L92:
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
.L95:
	sub	x0, x4, #1
	mul	x0, x0, x4
	lsl	x0, x0, 10
	cmp	w2, 0
	ble	.L98
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
.L97:
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
	bne	.L97
.L98:
	add	w2, w2, 16
	add	x4, x4, 1
	add	x24, x24, x26
	add	x3, x3, x30
	cmp	w2, w9
	bne	.L95
	ldr	w25, [sp, 120]
	b	.L96
.L39:
	add	w1, w1, 1
	mov	w0, 0
	b	.L88
.L91:
	add	w1, w1, 1
	mov	w2, 0
	b	.L99
.L156:
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
	b	.L80
	.p2align 2,,3
.L160:
	ldr	x2, [sp, 208]
	mov	x1, x26
	mov	x0, x25
	bl	memcpy
.L80:
	ldr	x0, [sp, 168]
	add	x25, x25, 64
	add	x26, x26, x20
	cmp	x0, x25
	bne	.L160
	mov	x1, x19
	ldr	x19, [sp, 224]
	b	.L79
.L103:
	mov	w12, 0
	b	.L69
	.p2align 2,,3
.L101:
	mov	w14, 0
	b	.L47
	.cfi_endproc
.LFE4373:
	.size	solve_panel._omp_fn.0, .-solve_panel._omp_fn.0
	.align	2
	.p2align 4,,11
	.type	solve_blocked._omp_fn.0, %function
solve_blocked._omp_fn.0:
.LFB4372:
	.cfi_startproc
	sub	sp, sp, #1024
	.cfi_def_cfa_offset 1024
	stp	x29, x30, [sp]
	.cfi_offset 29, -1024
	.cfi_offset 30, -1016
	mov	x29, sp
	ldr	w2, [x0, 24]
	ldr	w1, [x0, 40]
	str	w2, [sp, 264]
	ldr	w2, [x0, 28]
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	.cfi_offset 19, -1008
	.cfi_offset 20, -1000
	.cfi_offset 21, -992
	.cfi_offset 22, -984
	ldp	x20, x22, [x0]
	str	x0, [sp, 312]
	str	w2, [sp, 332]
	ldp	w2, w0, [x0, 32]
	str	w0, [sp, 256]
	str	w2, [sp, 260]
	str	w1, [sp, 484]
	cbz	w1, .L322
	bl	trsm_sve_has_eight_doubles
	cmp	w0, 0
	cset	w0, ne
	str	w0, [sp, 484]
.L322:
	ldr	w0, [sp, 264]
	cmp	w0, 0
	ble	.L161
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -968
	.cfi_offset 23, -976
	mov	x19, x20
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -952
	.cfi_offset 25, -960
	mov	x26, x22
	stp	x27, x28, [sp, 80]
	.cfi_offset 28, -936
	.cfi_offset 27, -944
	bl	omp_get_num_threads
	mov	w23, w0
	bl	omp_get_thread_num
	mov	w1, w0
	ldr	w10, [sp, 332]
	mov	w25, w0
	ldrsw	x5, [sp, 260]
	mov	w4, 24
	adds	w3, w10, 7
	add	w2, w10, 14
	ldr	w9, [sp, 256]
	csel	w0, w2, w3, mi
	add	x17, x5, 1
	lsl	x14, x5, 1
	asr	w0, w0, 3
	lsl	x8, x5, 3
	lsl	x12, x17, 5
	lsl	x13, x17, 2
	smull	x4, w9, w4
	add	w3, w10, 63
	sdiv	w2, w0, w23
	str	x4, [sp, 560]
	sub	x4, x12, #32
	str	x4, [sp, 512]
	sub	x4, x13, #4
	str	x4, [sp, 616]
	lsl	x4, x17, 11
	str	x4, [sp, 648]
	lsl	x4, x17, 8
	msub	w0, w2, w23, w0
	str	x4, [sp, 656]
	mov	x4, x5
	add	x5, x14, x5
	str	x5, [sp, 496]
	add	x5, x20, x8
	cmp	w1, w0
	str	x5, [sp, 360]
	add	x5, x8, 8
	cinc	w2, w2, lt
	str	x5, [sp, 424]
	lsl	x5, x4, 7
	sxtw	x6, w9
	str	x5, [sp, 600]
	lsl	x5, x4, 4
	asr	w3, w3, 6
	str	x5, [sp, 624]
	lsl	x5, x4, 6
	str	w3, [sp, 520]
	mul	w3, w2, w1
	str	x5, [sp, 608]
	neg	x5, x6, lsl 7
	str	x5, [sp, 664]
	neg	x5, x6, lsl 6
	add	w0, w0, w3
	str	x5, [sp, 672]
	lsl	x5, x6, 2
	sbfiz	x7, x9, 3, 32
	stp	x8, x6, [sp, 160]
	sbfiz	x11, x9, 4, 32
	str	x5, [sp, 576]
	neg	x5, x6, lsl 5
	csel	w6, w3, w0, lt
	mov	x0, x7
	add	x3, x7, 16
	str	x7, [sp, 120]
	add	w7, w2, w6
	add	x2, x0, 32
	add	x0, x0, 48
	lsl	w8, w6, 3
	str	x11, [sp, 336]
	mov	x22, x4
	str	x14, [sp, 368]
	mov	w27, w7
	stp	x3, x2, [sp, 376]
	mov	w21, w8
	str	x0, [sp, 392]
	lsl	w0, w7, 3
	str	x4, [sp, 432]
	str	x13, [sp, 552]
	str	x12, [sp, 592]
	str	x5, [sp, 680]
	str	w0, [sp, 584]
	sub	w0, w10, w8
	str	w0, [sp, 588]
	sxtw	x0, w8
	str	x0, [sp, 632]
	add	x0, x11, 16
	str	x0, [sp, 400]
	add	x0, x11, 32
	str	x0, [sp, 408]
	add	x0, x11, 48
	str	x0, [sp, 416]
	sbfiz	x0, x9, 8, 32
	str	xzr, [sp, 176]
	str	xzr, [sp, 320]
	stp	x20, x20, [sp, 440]
	str	w6, [sp, 544]
	str	x0, [sp, 640]
	mov	x0, 0
	mov	x20, x0
	str	w23, [sp, 692]
	str	x17, [sp, 696]
	b	.L223
.L500:
	add	w0, w1, 256
	str	w0, [sp, 328]
	ldr	w0, [sp, 544]
	cmp	w27, w0
	bgt	.L497
.L165:
	str	w7, [sp, 132]
	bl	GOMP_barrier
	ldr	w0, [sp, 264]
	ldr	w1, [sp, 328]
	ldr	w7, [sp, 132]
	cmp	w0, w1
	ble	.L225
	ldr	w0, [sp, 264]
	ldr	w1, [sp, 328]
	add	w0, w0, 63
	sub	w0, w0, w1
	ldr	w1, [sp, 332]
	asr	w0, w0, 6
	cmp	w1, 0
	ble	.L225
	ldr	w1, [sp, 520]
	ldr	w2, [sp, 692]
	mul	w0, w0, w1
	udiv	w1, w0, w2
	msub	w0, w1, w2, w0
	cmp	w25, w0
	bcc	.L226
.L321:
	madd	w0, w1, w25, w0
	add	w2, w1, w0
	cmp	w0, w2
	bcc	.L498
.L225:
	bl	GOMP_barrier
	ldr	x0, [sp, 176]
	ldr	x2, [sp, 640]
	add	x1, x0, 256
	ldr	x0, [sp, 320]
	add	x20, x20, x2
	ldr	x3, [sp, 360]
	add	x0, x0, x2
	str	x0, [sp, 320]
	ldr	x0, [sp, 648]
	str	x1, [sp, 176]
	ldr	x4, [sp, 656]
	add	x3, x3, x0
	str	x3, [sp, 360]
	ldr	x3, [sp, 432]
	ldr	x2, [sp, 448]
	add	x3, x3, x4
	str	x3, [sp, 432]
	ldr	x3, [sp, 440]
	add	x3, x3, x0
	add	x0, x2, x0
	stp	x3, x0, [sp, 440]
	ldr	w0, [sp, 264]
	cmp	w0, w1
	ble	.L499
.L223:
	ldr	x1, [sp, 176]
	str	w1, [sp, 268]
	ldr	w0, [sp, 264]
	mov	w7, w1
	sub	w0, w0, w1
	cmp	w0, 255
	bgt	.L500
	ldr	w0, [sp, 544]
	cmp	w27, w0
	ble	.L323
	ldr	w0, [sp, 264]
	str	w0, [sp, 328]
	str	d8, [sp, 96]
	.cfi_offset 72, -928
.L324:
	ldr	x15, [sp, 632]
	mov	w6, w27
	ldr	x2, [sp, 160]
	add	x24, x15, x20
	ldr	x1, [sp, 360]
	mov	w28, w21
	ldr	w0, [sp, 328]
	mov	w9, w25
	ldr	w23, [sp, 588]
	sub	x18, x1, x2
	sub	w30, w0, w7
	ldr	w17, [sp, 176]
	sub	w16, w30, #1
	mov	x27, x15
	mov	x2, x20
	str	w23, [sp, 132]
	mov	w23, w21
	str	x24, [sp, 136]
	mov	w24, w0
	str	w7, [sp, 144]
.L169:
	ldr	x0, [sp, 312]
	mov	w3, 8
	ldr	w1, [sp, 132]
	ldr	x0, [x0, 16]
	cmp	w1, 8
	csel	w3, w1, w3, le
	ldr	x25, [x0]
	cbz	x25, .L501
	cmp	w28, 0
	add	w1, w28, 7
	csel	w1, w1, w28, lt
	asr	w1, w1, 3
	sbfiz	x21, x1, 14, 32
	sxtw	x1, w1
	add	x21, x25, x21
	cmp	w30, 0
	ble	.L170
	ldr	w8, [sp, 144]
	mov	w0, 7
	sub	w0, w0, w3
	sbfiz	x4, x3, 3, 32
	mov	x7, x21
	add	x0, x0, 1
	ldr	w20, [sp, 132]
	mov	x5, x22
	mov	w3, w23
	mov	x22, x4
	mov	x23, x19
	mov	x4, x25
	mov	x10, x16
	mov	w25, w9
	mov	x11, x2
	mov	x9, x21
	mov	w12, w17
	mov	w21, w8
	mov	x13, x1
	mov	w8, w30
	mov	x19, x7
	lsl	x0, x0, 3
	str	x0, [sp, 152]
.L219:
	cmp	w20, 0
	ble	.L190
.L189:
	ldr	w0, [sp, 256]
	smaddl	x1, w21, w0, x27
	lsl	x0, x1, 3
	ldr	d0, [x26, x1, lsl 3]
	add	x0, x26, x0
	str	d0, [x19]
	cmp	w20, 1
	ble	.L190
	ldr	d0, [x0, 8]
	str	d0, [x19, 8]
	cmp	w20, 2
	ble	.L190
	ldr	d0, [x0, 16]
	str	d0, [x19, 16]
	cmp	w20, 3
	ble	.L190
	ldr	d0, [x0, 24]
	str	d0, [x19, 24]
	cmp	w20, 4
	ble	.L190
	ldr	d0, [x0, 32]
	str	d0, [x19, 32]
	cmp	w20, 5
	ble	.L190
	ldr	d0, [x0, 40]
	str	d0, [x19, 40]
	cmp	w20, 6
	ble	.L190
	ldr	d0, [x0, 48]
	str	d0, [x19, 48]
	cmp	w20, 7
	ble	.L190
	ldr	d0, [x0, 56]
	add	w21, w21, 1
	add	x19, x19, 64
	str	d0, [x19, -8]
	cmp	w24, w21
	bne	.L189
.L496:
	mov	x19, x23
	lsl	x0, x13, 8
	mov	w23, w3
	mov	x22, x5
	neg	x3, x5
	mov	x21, x7
	mov	x1, x7
	str	x0, [sp, 152]
	ldp	x7, x5, [sp, 432]
	mov	x16, x10
	ldr	w0, [sp, 144]
	mov	x20, x9
	ldr	x10, [sp, 360]
	mov	w9, w25
	movi	v17.4s, 0
	mov	x25, x4
	add	w15, w0, 2
	mov	w30, w8
	mov	x14, x18
	mov	w4, w8
	add	x0, sp, 768
	str	x3, [sp, 192]
	add	x3, x19, 8
	str	x26, [sp, 216]
	mov	x26, x18
	str	x3, [sp, 200]
	mov	x3, 0
	str	w28, [sp, 208]
	str	w9, [sp, 224]
	str	w6, [sp, 232]
	str	w23, [sp, 240]
	str	x16, [sp, 248]
	str	x11, [sp, 272]
	str	w12, [sp, 280]
.L197:
	stp	q17, q17, [x0]
	stp	q17, q17, [x0, 32]
	stp	q17, q17, [x0, 64]
	stp	q17, q17, [x0, 96]
	stp	q17, q17, [x0, 128]
	stp	q17, q17, [x0, 160]
	stp	q17, q17, [x0, 192]
	stp	q17, q17, [x0, 224]
	cmp	w4, 3
	ble	.L502
	movi	v0.2d, 0
	cbz	w3, .L330
	ldr	x2, [sp, 368]
	add	x9, x21, x3, lsl 6
	ldr	x11, [sp, 496]
	mov	x8, x14
	mov	v18.16b, v0.16b
	mov	x6, x21
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
.L217:
	ldp	q5, q4, [x6]
	ldp	q3, q1, [x6, 32]
	add	x6, x6, 64
	ldr	d7, [x8, x22, lsl 3]
	ldr	d6, [x8, x2, lsl 3]
	ldr	d2, [x8, x11, lsl 3]
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
	cmp	x6, x9
	bne	.L217
.L216:
	stp	q8, q31, [sp, 768]
	stp	q30, q29, [sp, 800]
	stp	q28, q27, [sp, 832]
	stp	q26, q25, [sp, 864]
	stp	q24, q23, [sp, 896]
	stp	q22, q21, [sp, 928]
	stp	q20, q19, [sp, 960]
	stp	q18, q0, [sp, 992]
.L218:
	ldr	x2, [sp, 192]
	ldp	q4, q3, [x1]
	ldp	q2, q1, [x1, 32]
	ldp	q8, q7, [sp, 768]
	ldp	q6, q5, [sp, 800]
	fsub	v4.2d, v4.2d, v8.2d
	ldr	d0, [x10, x2, lsl 3]
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
	beq	.L207
	ldr	x2, [sp, 152]
	cmp	w4, 4
	mov	x6, x0
	mov	x18, x10
	add	x28, x3, x2
	mov	x11, x7
	add	x8, x28, 2
	add	x13, x28, 1
	mov	w2, 4
	mov	w9, 1
	add	x23, x25, x8, lsl 6
	csel	w2, w4, w2, le
	add	x13, x25, x13, lsl 6
	mov	x8, x1
	mov	w12, 0
	b	.L208
.L211:
	add	x6, x6, 64
	add	x11, x11, x22
	cmp	w9, 2
	beq	.L328
	ldp	q1, q0, [x1]
	mov	w12, 2
	ldr	d5, [x19, x11, lsl 3]
	ldp	q3, q2, [x6, 64]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	ldr	x16, [sp, 200]
	fadd	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v2.2d
	ldr	d4, [x16, x11, lsl 3]
	ldp	q7, q6, [x6, 96]
	stp	q1, q0, [x6, 64]
	ldp	q3, q2, [x1, 64]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x6, 64]
	ldp	q1, q0, [x1, 32]
	fmul	v1.2d, v1.2d, v5.d[0]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v0.2d, v0.2d, v6.2d
	stp	q1, q0, [x6, 96]
	ldp	q3, q2, [x1, 96]
	fmul	v3.2d, v3.2d, v4.d[0]
	fmul	v2.2d, v2.2d, v4.d[0]
	fadd	v1.2d, v3.2d, v1.2d
	fadd	v0.2d, v2.2d, v0.2d
	stp	q1, q0, [x6, 96]
.L209:
	add	x8, x8, 64
	ldr	x16, [sp, 424]
	add	x18, x18, x16
.L208:
	sxtw	x16, w12
	add	w12, w12, 1
	add	x17, x28, x16
	add	x16, x16, x11
	ldp	q1, q6, [x6, 64]
	lsl	x17, x17, 6
	ldr	d0, [x19, x16, lsl 3]
	add	x16, x25, x17
	ldp	q5, q4, [x6, 96]
	ldr	q2, [x25, x17]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x6, 64]
	ldr	q3, [x16, 16]
	fmul	v3.2d, v3.2d, v0.d[0]
	fadd	v3.2d, v3.2d, v6.2d
	str	q3, [x6, 80]
	ldr	q2, [x16, 32]
	fmul	v2.2d, v2.2d, v0.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x6, 96]
	ldr	q5, [x16, 48]
	fmul	v5.2d, v5.2d, v0.d[0]
	fadd	v5.2d, v5.2d, v4.2d
	str	q5, [x6, 112]
	cmp	w12, w9
	bge	.L210
	add	x12, x11, 1
	ldr	q0, [x13]
	ldr	d6, [x19, x12, lsl 3]
	fmul	v0.2d, v0.2d, v6.d[0]
	fadd	v0.2d, v0.2d, v1.2d
	mov	v1.16b, v0.16b
	str	q0, [x6, 64]
	ldr	q4, [x13, 16]
	fmul	v4.2d, v4.2d, v6.d[0]
	fadd	v4.2d, v4.2d, v3.2d
	str	q4, [x6, 80]
	ldr	q3, [x13, 32]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v3.2d, v3.2d, v2.2d
	str	q3, [x6, 96]
	ldr	q2, [x13, 48]
	fmul	v2.2d, v2.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v5.2d
	str	q2, [x6, 112]
	cmp	w9, 3
	bne	.L210
	add	x12, x11, 2
	ldr	q1, [x23]
	ldr	d5, [x19, x12, lsl 3]
	fmul	v1.2d, v1.2d, v5.d[0]
	fadd	v1.2d, v1.2d, v0.2d
	str	q1, [x6, 64]
	ldr	q0, [x23, 16]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v4.2d
	str	q0, [x6, 80]
	ldr	q0, [x23, 32]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v3.2d
	str	q0, [x6, 96]
	ldr	q0, [x23, 48]
	fmul	v0.2d, v0.2d, v5.d[0]
	fadd	v0.2d, v0.2d, v2.2d
	str	q0, [x6, 112]
.L210:
	ldr	d0, [x18, 8]
	ldp	q4, q3, [x8, 64]
	add	w9, w9, 1
	dup	v0.2d, v0.d[0]
	ldr	q2, [x8, 96]
	fsub	v4.2d, v4.2d, v1.2d
	ldr	q1, [x8, 112]
	fdiv	v4.2d, v4.2d, v0.2d
	str	q4, [x8, 64]
	ldr	q4, [x6, 80]
	fsub	v3.2d, v3.2d, v4.2d
	fdiv	v3.2d, v3.2d, v0.2d
	str	q3, [x8, 80]
	ldr	q3, [x6, 96]
	fsub	v2.2d, v2.2d, v3.2d
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x8, 96]
	ldr	q2, [x6, 112]
	fsub	v1.2d, v1.2d, v2.2d
	fdiv	v0.2d, v1.2d, v0.2d
	str	q0, [x8, 112]
	cmp	w2, w9
	bne	.L211
.L207:
	ldr	x2, [sp, 592]
	add	x3, x3, 4
	sub	w4, w4, #4
	add	x1, x1, 256
	add	x10, x10, x2
	add	w15, w15, 4
	ldr	x2, [sp, 552]
	add	x7, x7, x2
	ldr	x2, [sp, 512]
	add	x5, x5, x2
	add	x14, x14, x2
	cmp	w30, w3
	bgt	.L197
	ldr	w3, [sp, 132]
	mov	x18, x26
	ldr	x26, [sp, 216]
	ldr	x16, [sp, 248]
	ldr	x2, [sp, 272]
	ldr	w28, [sp, 208]
	ldr	w9, [sp, 224]
	ldr	w6, [sp, 232]
	ldr	w23, [sp, 240]
	ldr	w17, [sp, 280]
	cmp	w3, 0
	ble	.L170
	ldr	x0, [sp, 136]
	add	x1, x16, 1
	add	x1, x21, x1, lsl 6
	add	x0, x26, x0, lsl 3
.L194:
	ldr	d0, [x20]
	str	d0, [x0]
	cmp	w3, 1
	ble	.L192
	ldr	d0, [x20, 8]
	str	d0, [x0, 8]
	cmp	w3, 2
	ble	.L192
	ldr	d0, [x20, 16]
	str	d0, [x0, 16]
	cmp	w3, 3
	ble	.L192
	ldr	d0, [x20, 24]
	str	d0, [x0, 24]
	cmp	w3, 4
	ble	.L192
	ldr	d0, [x20, 32]
	str	d0, [x0, 32]
	cmp	w3, 5
	ble	.L192
	ldr	d0, [x20, 40]
	str	d0, [x0, 40]
	cmp	w3, 6
	ble	.L192
	ldr	d0, [x20, 48]
	str	d0, [x0, 48]
	cmp	w3, 7
	ble	.L192
	ldr	d0, [x20, 56]
	str	d0, [x0, 56]
.L192:
	ldr	x4, [sp, 120]
	add	x20, x20, 64
	add	x0, x0, x4
	cmp	x20, x1
	bne	.L194
.L170:
	ldr	w0, [sp, 132]
	add	w28, w28, 8
	add	x27, x27, 8
	sub	w0, w0, #8
	str	w0, [sp, 132]
	ldr	x0, [sp, 136]
	add	x0, x0, 8
	str	x0, [sp, 136]
	ldr	w0, [sp, 584]
	cmp	w0, w28
	bgt	.L169
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	w25, w9
	ldr	w7, [sp, 144]
	mov	w27, w6
	mov	w21, w23
	mov	x20, x2
	b	.L165
.L190:
	.cfi_restore_state
	ldr	x2, [sp, 152]
	add	x0, x19, x22
	add	w21, w21, 1
	mov	w1, 0
	str	w6, [sp, 184]
	add	x19, x19, 64
	str	w3, [sp, 192]
	stp	x4, x5, [sp, 200]
	stp	x7, x18, [sp, 216]
	str	w8, [sp, 232]
	stp	x9, x10, [sp, 240]
	str	x11, [sp, 272]
	str	w12, [sp, 280]
	str	x13, [sp, 288]
	bl	memset
	ldp	x4, x5, [sp, 200]
	cmp	w24, w21
	ldp	x7, x18, [sp, 216]
	ldp	x9, x10, [sp, 240]
	ldr	x11, [sp, 272]
	ldr	x13, [sp, 288]
	ldr	w6, [sp, 184]
	ldr	w3, [sp, 192]
	ldr	w8, [sp, 232]
	ldr	w12, [sp, 280]
	bne	.L219
	b	.L496
.L502:
	cbz	w3, .L218
	ldr	x12, [sp, 176]
	sub	w8, w15, #1
	ldr	w2, [sp, 260]
	lsl	x6, x3, 3
	movi	v0.2d, 0
	mov	x9, x21
	mov	w13, 0
	mov	w28, 0
	mov	w17, 0
	mov	w16, 0
	smaddl	x11, w2, w15, x12
	str	x6, [sp, 184]
	smaddl	x8, w2, w8, x12
	mov	w6, 0
	mov	v1.16b, v0.16b
	mov	w12, 0
	mov	v16.16b, v0.16b
	add	x18, x19, x11, lsl 3
	mov	v2.16b, v0.16b
	add	x23, x19, x8, lsl 3
	mov	v25.16b, v0.16b
	mov	w11, 0
	mov	v24.16b, v0.16b
	mov	w2, 0
	mov	v23.16b, v0.16b
	mov	x8, 0
	mov	v22.16b, v0.16b
	str	x0, [sp, 288]
	mov	v21.16b, v0.16b
	mov	v19.16b, v0.16b
	mov	v8.16b, v0.16b
	mov	v20.16b, v0.16b
.L214:
	ldp	q7, q6, [x9]
	ldp	q5, q4, [x9, 32]
	ldr	d3, [x5, x8]
	fmul	v18.2d, v7.2d, v3.d[0]
	fmul	v26.2d, v6.2d, v3.d[0]
	fmul	v27.2d, v5.2d, v3.d[0]
	fmul	v3.2d, v4.2d, v3.d[0]
	fadd	v20.2d, v18.2d, v20.2d
	fadd	v26.2d, v26.2d, v8.2d
	fadd	v27.2d, v27.2d, v19.2d
	fadd	v18.2d, v3.2d, v21.2d
	cmp	w4, 1
	ble	.L212
	ldr	d3, [x23, x8]
	mov	w6, 1
	mov	w11, w6
	mov	w13, w6
	mov	w12, w6
	fmul	v8.2d, v7.2d, v3.d[0]
	fmul	v19.2d, v6.2d, v3.d[0]
	fmul	v21.2d, v5.2d, v3.d[0]
	fmul	v3.2d, v4.2d, v3.d[0]
	fadd	v2.2d, v8.2d, v2.2d
	fadd	v16.2d, v19.2d, v16.2d
	fadd	v1.2d, v21.2d, v1.2d
	fadd	v0.2d, v3.2d, v0.2d
	cmp	w4, 3
	bne	.L212
	ldr	d3, [x18, x8]
	mov	w28, w6
	mov	w17, w6
	mov	w16, w6
	mov	w2, w6
	fmul	v7.2d, v7.2d, v3.d[0]
	fmul	v6.2d, v6.2d, v3.d[0]
	fmul	v5.2d, v5.2d, v3.d[0]
	fmul	v4.2d, v4.2d, v3.d[0]
	fadd	v22.2d, v7.2d, v22.2d
	fadd	v23.2d, v6.2d, v23.2d
	fadd	v24.2d, v5.2d, v24.2d
	fadd	v25.2d, v4.2d, v25.2d
.L212:
	ldr	x0, [sp, 184]
	add	x8, x8, 8
	mov	v8.16b, v26.16b
	add	x9, x9, 64
	mov	v19.16b, v27.16b
	mov	v21.16b, v18.16b
	cmp	x8, x0
	bne	.L214
	stp	q20, q26, [sp, 768]
	stp	q27, q18, [sp, 800]
	ldr	x0, [sp, 288]
	cbz	w6, .L199
	str	q0, [sp, 880]
.L199:
	cbz	w11, .L200
	str	q1, [sp, 864]
.L200:
	cbz	w13, .L201
	str	q16, [sp, 848]
.L201:
	cbz	w12, .L202
	str	q2, [sp, 832]
.L202:
	cbz	w28, .L203
	str	q25, [sp, 944]
.L203:
	cbz	w17, .L204
	str	q24, [sp, 928]
.L204:
	cbz	w16, .L205
	str	q23, [sp, 912]
.L205:
	cbz	w2, .L218
	str	q22, [sp, 896]
	b	.L218
.L501:
	cmp	w24, w17
	ble	.L170
	ldr	w4, [sp, 268]
	sub	w10, w24, #1
	ldr	x11, [sp, 136]
	cmp	w10, w4
	ldr	w5, [sp, 132]
	csel	w10, w10, w4, le
	ldr	x12, [sp, 448]
	cmp	w5, 0
	csinc	w3, w3, wzr, gt
	add	x21, x26, x11, lsl 3
	and	w20, w3, -2
	and	w13, w3, 1
	lsr	w8, w3, 1
	mov	x0, x21
.L173:
	ldr	d1, [x12]
	cmp	w5, 0
	ble	.L187
	cmp	w5, 1
	beq	.L327
	ldr	q2, [x0]
	dup	v0.2d, v1.d[0]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0]
	cmp	w8, 1
	bls	.L186
	ldr	q2, [x0, 16]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 16]
	cmp	w8, 2
	beq	.L186
	ldr	q2, [x0, 32]
	fdiv	v2.2d, v2.2d, v0.2d
	str	q2, [x0, 32]
	cmp	w8, 3
	beq	.L186
	ldr	q2, [x0, 48]
	fdiv	v0.2d, v2.2d, v0.2d
	str	q0, [x0, 48]
.L186:
	mov	w1, w20
	cbz	w13, .L187
.L185:
	add	x1, x11, w1, sxtw
	ldr	d0, [x26, x1, lsl 3]
	fdiv	d0, d0, d1
	str	d0, [x26, x1, lsl 3]
.L187:
	ldr	x1, [sp, 424]
	add	w4, w4, 1
	add	x12, x12, x1
	ldr	x1, [sp, 168]
	add	x11, x11, x1
	ldr	x1, [sp, 120]
	add	x0, x0, x1
	cmp	w4, w10
	ble	.L173
	cmp	w4, w24
	bge	.L170
	ldr	w0, [sp, 256]
	sbfiz	x10, x4, 3, 32
	ldr	x1, [sp, 696]
	and	w25, w3, 1
	movi	v2.4s, 0
	ldr	w14, [sp, 132]
	smaddl	x12, w0, w4, x27
	add	x0, sp, 768
	madd	x15, x1, x10, x19
	madd	x10, x22, x10, x19
	add	x3, x26, x12, lsl 3
.L183:
	stp	q2, q2, [x0]
	stp	q2, q2, [x0, 32]
	cmp	w14, 0
	ble	.L174
	ldr	x11, [sp, 136]
	mov	x5, x21
	ldr	x7, [sp, 176]
.L177:
	ldr	d0, [x10, x7, lsl 3]
	cmp	w14, 1
	beq	.L325
	ldr	q3, [x5]
	ldr	q1, [sp, 768]
	fmul	v3.2d, v3.2d, v0.d[0]
	dup	v4.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 768]
	cmp	w8, 1
	bls	.L176
	ldr	q3, [x5, 16]
	ldr	q1, [sp, 784]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 784]
	cmp	w8, 2
	beq	.L176
	ldr	q3, [x5, 32]
	ldr	q1, [sp, 800]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 800]
	cmp	w8, 3
	beq	.L176
	ldr	q3, [x5, 48]
	ldr	q1, [sp, 816]
	fmul	v3.2d, v3.2d, v4.2d
	fadd	v1.2d, v1.2d, v3.2d
	str	q1, [sp, 816]
.L176:
	sxtw	x1, w20
	cbz	w25, .L179
.L175:
	add	x13, x1, x11
	ldr	d1, [x0, x1, lsl 3]
	ldr	d3, [x26, x13, lsl 3]
	fmul	d0, d0, d3
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L179:
	ldr	x1, [sp, 168]
	add	x7, x7, 1
	add	x11, x11, x1
	ldr	x1, [sp, 120]
	add	x5, x5, x1
	cmp	w4, w7
	bgt	.L177
	ldr	d3, [x15]
	cmp	w14, 1
	beq	.L326
	ldr	q0, [x3]
	ldr	q4, [sp, 768]
	dup	v1.2d, v3.d[0]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3]
	cmp	w8, 1
	bls	.L181
	ldr	q0, [x3, 16]
	ldr	q4, [sp, 784]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 16]
	cmp	w8, 2
	beq	.L181
	ldr	q0, [x3, 32]
	ldr	q4, [sp, 800]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 32]
	cmp	w8, 3
	beq	.L181
	ldr	q0, [x3, 48]
	ldr	q4, [sp, 816]
	fsub	v0.2d, v0.2d, v4.2d
	fdiv	v0.2d, v0.2d, v1.2d
	str	q0, [x3, 48]
.L181:
	sxtw	x1, w20
	cbz	w25, .L174
.L180:
	add	x5, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x26, x5, lsl 3]
	fsub	d0, d0, d1
	fdiv	d0, d0, d3
	str	d0, [x26, x5, lsl 3]
.L174:
	ldr	x1, [sp, 424]
	add	w4, w4, 1
	add	x15, x15, x1
	ldr	x1, [sp, 168]
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	add	x3, x3, x1
	ldr	x1, [sp, 160]
	add	x10, x10, x1
	cmp	w4, w24
	bne	.L183
	b	.L170
.L326:
	mov	x1, 0
	b	.L180
.L325:
	mov	x1, 0
	b	.L175
.L327:
	mov	w1, 0
	b	.L185
.L330:
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
	b	.L216
.L498:
	.cfi_restore 72
	ldr	w3, [sp, 328]
	sub	w1, w1, #1
	ldr	w4, [sp, 520]
	add	w18, w7, 1
	sub	w10, w3, w7
	str	w1, [sp, 688]
	sub	w1, w10, #1
	str	x1, [sp, 568]
	ldr	x1, [sp, 176]
	str	w1, [sp, 248]
	udiv	w2, w0, w4
	mov	w15, 0
	mov	w23, w18
	mov	x28, x19
	neg	x5, x1, lsl 3
	sub	w1, w3, #1
	str	w1, [sp, 132]
	mov	x18, x22
	msub	w0, w2, w4, w0
	ldr	w1, [sp, 264]
	str	x5, [sp, 144]
	add	w5, w3, w2, lsl 6
	sub	w1, w1, w5
	str	w1, [sp, 524]
	lsl	w4, w0, 6
	ldr	w1, [sp, 484]
	str	w15, [sp, 460]
	mov	w15, w5
	str	w25, [sp, 704]
	mov	x25, x26
	str	w27, [sp, 708]
	mov	w27, w4
	and	w1, w1, 1
	str	w1, [sp, 272]
	str	w10, [sp, 456]
	str	x20, [sp, 712]
	str	w21, [sp, 720]
	str	d8, [sp, 96]
	.cfi_offset 72, -928
.L227:
	ldr	w0, [sp, 524]
	add	w1, w15, 64
	ldr	w2, [sp, 332]
	ldr	w3, [sp, 264]
	cmp	w0, 63
	sub	w0, w2, w27
	csel	w4, w1, w3, gt
	cmp	w0, 63
	bgt	.L229
	ldr	w0, [sp, 272]
	mov	w26, w15
	str	w2, [sp, 136]
	cbnz	w0, .L318
.L230:
	cmp	w4, w26
	ble	.L286
	ldr	w0, [sp, 136]
	cmp	w27, w0
	bge	.L286
.L319:
	ldr	w1, [sp, 256]
	sxtw	x13, w27
	ldr	w0, [sp, 260]
	mov	w12, w4
	ldr	w19, [sp, 328]
	mov	w4, w27
	mov	x22, x18
	mov	x27, x28
	smull	x2, w1, w26
	mov	x18, x25
	ldr	x1, [sp, 568]
	smull	x0, w0, w26
	str	x0, [sp, 344]
	add	x14, x1, 1
	str	w15, [sp, 724]
	ldr	x1, [sp, 176]
	str	w23, [sp, 480]
	add	x1, x0, x1
	ldr	x0, [sp, 320]
	add	x1, x28, x1, lsl 3
	sub	x3, x0, x2
	add	x0, x13, x2
	add	x24, x25, x0, lsl 3
	lsl	x3, x3, 3
	mov	x15, x24
	str	x3, [sp, 352]
.L294:
	sub	w0, w12, w26
	mov	w5, 4
	cmp	w0, 4
	add	x23, x1, x14, lsl 3
	ldr	x3, [sp, 560]
	csel	w5, w0, w5, le
	cmp	w0, 3
	str	w26, [sp, 740]
	cset	w0, gt
	str	w0, [sp, 232]
	ldr	x0, [sp, 144]
	add	x3, x15, x3
	ldr	x10, [sp, 312]
	mov	x25, x23
	ldr	x26, [sp, 496]
	mov	w21, w4
	mov	x23, x22
	mov	x9, x13
	mov	x20, x3
	add	x0, x1, x0
	str	x2, [sp, 464]
	str	x0, [sp, 488]
	str	w5, [sp, 504]
	str	w4, [sp, 728]
	str	w12, [sp, 736]
	str	x13, [sp, 744]
	str	x3, [sp, 752]
	str	x14, [sp, 760]
.L288:
	ldr	x0, [x10, 16]
	ldr	w2, [sp, 136]
	ldr	x3, [x0]
	sub	w8, w2, w21
	cbz	x3, .L503
	asr	w0, w21, 3
	mov	x6, 8
	mov	w4, w6
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
	ldr	w0, [sp, 232]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	ble	.L504
.L292:
	ldr	w0, [sp, 272]
	cbnz	w0, .L314
	movi	v16.2d, 0
	ldr	w0, [sp, 456]
	cmp	w0, 0
	ble	.L346
	ldr	x28, [sp, 368]
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
.L316:
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
	bne	.L316
.L315:
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
.L298:
	ldr	w0, [sp, 136]
	add	w21, w21, 8
	add	x9, x9, 8
	add	x15, x15, 64
	add	x20, x20, 64
	cmp	w21, w0
	blt	.L288
	ldr	x0, [sp, 512]
	mov	x22, x23
	ldr	x5, [sp, 680]
	add	x1, x1, x0
	ldr	x0, [sp, 352]
	ldr	x3, [sp, 752]
	add	x0, x0, x5
	str	x0, [sp, 352]
	ldr	x0, [sp, 120]
	ldr	x2, [sp, 464]
	add	x15, x0, x3
	ldr	x0, [sp, 344]
	ldr	x3, [sp, 616]
	ldr	w26, [sp, 740]
	add	x0, x0, x3
	str	x0, [sp, 344]
	ldr	x0, [sp, 576]
	add	w26, w26, 4
	ldr	w12, [sp, 736]
	ldr	x13, [sp, 744]
	add	x2, x2, x0
	ldr	x14, [sp, 760]
	ldr	w4, [sp, 728]
	cmp	w12, w26
	bgt	.L294
	mov	x25, x18
	ldr	w15, [sp, 724]
	mov	x18, x23
	ldr	w23, [sp, 480]
	mov	x28, x27
	mov	w27, w4
.L286:
	ldr	w0, [sp, 460]
	ldr	w1, [sp, 688]
	cmp	w0, w1
	beq	.L492
.L511:
	ldr	w0, [sp, 332]
	add	w27, w27, 64
	cmp	w0, w27
	ble	.L505
.L289:
	ldr	w0, [sp, 460]
	add	w0, w0, 1
	str	w0, [sp, 460]
	b	.L227
.L314:
	ldr	w6, [sp, 256]
	mov	x5, x15
	ldr	w2, [sp, 260]
	ldr	w0, [sp, 268]
	str	x1, [sp, 152]
	sub	w0, w19, w0
	stp	x9, x10, [sp, 184]
	bl	update4x8_sve
	ldr	x1, [sp, 152]
	ldp	x9, x10, [sp, 184]
	b	.L298
.L503:
	ldr	x0, [sp, 352]
	ldr	x6, [sp, 168]
	add	x3, x15, x0
	ldr	w0, [sp, 232]
	ldr	w4, [sp, 256]
	cmp	w0, 0
	ccmp	w8, 7, 4, ne
	bgt	.L292
.L504:
	cmp	w8, 8
	mov	w14, 8
	csel	w14, w8, w14, le
	lsl	x5, x6, 3
	sub	w0, w14, #1
	str	w0, [sp, 224]
	lsr	w0, w14, 2
	str	w0, [sp, 280]
	add	x0, x3, x5
	str	x0, [sp, 240]
	ldr	x0, [sp, 464]
	lsr	w4, w14, 1
	and	w7, w14, -2
	lsl	x2, x6, 4
	ldr	x22, [sp, 344]
	lsl	x16, x6, 1
	ldr	x11, [sp, 488]
	add	x12, x0, x9
	movi	v4.4s, 0
	ldr	w30, [sp, 480]
	ldr	w17, [sp, 504]
	mov	x13, x15
	str	w4, [sp, 192]
	mov	x4, x26
	ldr	x26, [sp, 160]
	str	w7, [sp, 288]
	mov	x7, x9
	ldr	w9, [sp, 132]
	add	x0, sp, 768
	str	x11, [sp, 152]
	mov	x11, x10
	mov	x10, x16
	str	x6, [sp, 200]
	mov	x6, x25
	str	x5, [sp, 472]
	mov	x5, x1
	str	x20, [sp, 536]
	mov	x20, x2
	mov	w24, 0
	str	x23, [sp, 184]
	str	x15, [sp, 528]
	str	w21, [sp, 548]
.L297:
	ldr	w1, [sp, 248]
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w1, w19
	bge	.L296
	cmp	w9, w30
	ble	.L342
	ldp	x2, x1, [sp, 144]
	mov	x25, x3
	ldr	x16, [sp, 200]
	mov	x15, 0
	ldr	x21, [sp, 240]
	str	x18, [sp, 208]
	sub	x28, x1, x2
	mov	w1, w30
	str	w24, [sp, 216]
	stp	x13, x4, [sp, 296]
	b	.L308
.L508:
	ldp	q0, q1, [x25, 32]
	ldp	q2, q5, [x21, 32]
	ldp	q6, q8, [sp, 800]
	fmul	v1.2d, v1.2d, v7.2d
	fmul	v0.2d, v0.2d, v7.2d
	fmul	v5.2d, v5.2d, v3.2d
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v8.2d
	fadd	v0.2d, v0.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	fadd	v0.2d, v0.2d, v2.2d
	stp	q0, q1, [sp, 800]
.L305:
	add	w2, w1, 2
	add	x28, x28, 16
	add	x25, x25, x20
	add	x21, x21, x20
	add	x15, x15, x10
	add	x16, x16, x10
	cmp	w2, w9
	bge	.L506
	.p2align 3,,7
.L344:
	mov	w1, w2
.L308:
	ldr	w2, [sp, 224]
	ldr	d0, [x28]
	cmp	w2, 2
	bls	.L507
	ldp	q1, q2, [x25]
	ldp	q5, q6, [x21]
	ldp	q16, q17, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d3, [x28, 8]
	fmul	v1.2d, v1.2d, v0.d[0]
	ldr	w2, [sp, 280]
	dup	v7.2d, v0.d[0]
	fmul	v6.2d, v6.2d, v3.d[0]
	fmul	v5.2d, v5.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v17.2d
	fadd	v1.2d, v1.2d, v16.2d
	dup	v3.2d, v3.d[0]
	fadd	v2.2d, v2.2d, v6.2d
	fadd	v1.2d, v1.2d, v5.2d
	stp	q1, q2, [sp, 768]
	cmp	w2, 2
	beq	.L508
	cmp	w8, 4
	beq	.L305
	mov	x4, 4
	mov	w2, w4
.L303:
	sub	w24, w14, w4
	sxtw	x13, w1
	cmp	w24, 1
	beq	.L306
	add	x23, x4, x15
	add	x18, x4, x16
	lsl	x4, x4, 3
	lsl	x23, x23, 3
	lsl	x18, x18, 3
	ldr	q2, [x0, x4]
	ldr	q1, [x3, x23]
	add	x23, x13, x22
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x4]
	ldr	d3, [x27, x23, lsl 3]
	ldr	q2, [x3, x18]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x4]
	tbz	x24, 0, .L305
	and	w24, w24, -2
	add	w2, w2, w24
.L306:
	sxtw	x2, w2
	add	x13, x13, x22
	add	x18, x2, x15
	add	x4, x2, x16
	add	x28, x28, 16
	add	x25, x25, x20
	ldr	d2, [x0, x2, lsl 3]
	add	x21, x21, x20
	ldr	d5, [x3, x18, lsl 3]
	add	x15, x15, x10
	ldr	d1, [x3, x4, lsl 3]
	add	x16, x16, x10
	ldr	d3, [x27, x13, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
	add	w2, w1, 2
	cmp	w2, w9
	blt	.L344
.L506:
	ldp	x13, x4, [sp, 296]
	add	w1, w1, 1
	ldr	x18, [sp, 208]
	ldr	w24, [sp, 216]
.L302:
	sxtw	x21, w1
	ldr	w23, [sp, 288]
	ldr	x1, [sp, 176]
	stp	x18, x27, [sp, 208]
	ldr	w18, [sp, 192]
	ldr	x28, [sp, 472]
	sub	x16, x21, x1
	ldr	x1, [sp, 200]
	ldr	x25, [sp, 152]
	mov	x27, x1
	mul	x15, x1, x16
	madd	x16, x16, x28, x3
	b	.L312
	.p2align 2,,3
.L510:
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w18, 2
	beq	.L310
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
	cmp	w18, 4
	bne	.L310
	ldr	q1, [x16, 48]
	ldr	q0, [sp, 816]
	fmul	v1.2d, v1.2d, v3.2d
	fadd	v0.2d, v0.2d, v1.2d
	str	q0, [sp, 816]
.L311:
	add	x21, x21, 1
	add	x15, x15, x27
	add	x16, x16, x28
	cmp	w19, w21
	ble	.L509
	.p2align 3,,7
.L312:
	ldr	d0, [x25, x21, lsl 3]
	cmp	w8, 1
	beq	.L345
	ldr	q2, [x16]
	sxtw	x1, w23
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w18, 1
	bhi	.L510
.L310:
	cmp	w14, w23
	beq	.L311
.L309:
	add	x2, x1, x15
	ldr	d1, [x0, x1, lsl 3]
	add	x21, x21, 1
	add	x15, x15, x27
	add	x16, x16, x28
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
	cmp	w19, w21
	bgt	.L312
.L509:
	ldp	x18, x27, [sp, 208]
.L296:
	cmp	w8, 1
	beq	.L341
	ldr	q0, [x13]
	ldr	q1, [sp, 768]
	ldr	w1, [sp, 192]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13]
	cmp	w1, 1
	bls	.L300
	ldr	q0, [x13, 16]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 16]
	cmp	w1, 2
	beq	.L300
	ldr	q0, [x13, 32]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 32]
	cmp	w1, 4
	bne	.L300
	ldr	q0, [x13, 48]
	ldr	q1, [sp, 816]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x13, 48]
	.p2align 3,,7
.L301:
	add	w24, w24, 1
	ldr	x1, [sp, 168]
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	add	x13, x13, x1
	ldr	x1, [sp, 184]
	add	x22, x22, x1
	ldr	x1, [sp, 152]
	add	x1, x1, x26
	str	x1, [sp, 152]
	cmp	w24, w17
	blt	.L297
	ldr	x23, [sp, 184]
	mov	x26, x4
	ldr	x15, [sp, 528]
	mov	x1, x5
	ldr	x20, [sp, 536]
	mov	x25, x6
	ldr	w21, [sp, 548]
	mov	x9, x7
	mov	x10, x11
	b	.L298
.L300:
	ldr	w1, [sp, 288]
	cmp	w14, w1
	beq	.L301
.L299:
	sxtw	x1, w1
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x18, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x18, x2, lsl 3]
	b	.L301
.L345:
	mov	x1, 0
	b	.L309
.L341:
	mov	w1, 0
	b	.L299
.L342:
	ldr	w1, [sp, 268]
	b	.L302
.L507:
	mov	x4, 0
	mov	w2, 0
	b	.L303
.L346:
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
	b	.L315
.L229:
	add	w0, w27, 64
	str	w0, [sp, 136]
	ldr	w0, [sp, 272]
	cbnz	w0, .L318
	mov	w26, w15
	cmp	w15, w4
	blt	.L319
	ldr	w0, [sp, 460]
	ldr	w1, [sp, 688]
	cmp	w0, w1
	bne	.L511
.L492:
	ldr	d8, [sp, 96]
	.cfi_remember_state
	.cfi_restore 72
	mov	x26, x25
	ldr	x20, [sp, 712]
	mov	x19, x28
	ldr	w25, [sp, 704]
	mov	x22, x18
	ldr	w27, [sp, 708]
	ldr	w21, [sp, 720]
	b	.L225
.L318:
	.cfi_restore_state
	sub	w0, w4, w15
	cmp	w0, 15
	ble	.L332
	ldr	w1, [sp, 260]
	mov	w24, w23
	ldr	w0, [sp, 256]
	mov	w19, w15
	ldr	w23, [sp, 328]
	mov	x26, x18
	str	w15, [sp, 344]
	smull	x10, w1, w15
	ldr	x1, [sp, 320]
	smull	x0, w0, w15
	mov	x15, x10
	sub	x1, x1, x0
	add	x22, x0, w27, sxtw
	ldr	x0, [sp, 176]
	lsl	x13, x1, 3
	add	x2, x25, x22, lsl 3
	mov	x14, x13
	add	x0, x10, x0
	mov	x21, x2
	add	x1, x28, x0, lsl 3
.L261:
	ldr	w0, [sp, 136]
	cmp	w27, w0
	bge	.L233
	ldr	x0, [sp, 144]
	mov	x10, x22
	mov	w20, w27
	mov	x13, x21
	add	x0, x1, x0
	stp	x1, x14, [sp, 280]
	stp	x15, x0, [sp, 296]
	str	w27, [sp, 352]
	mov	x27, x26
	str	w19, [sp, 464]
	str	x21, [sp, 472]
	str	w4, [sp, 480]
	str	x22, [sp, 488]
	ldr	x22, [sp, 168]
	b	.L266
.L264:
	ldr	x1, [sp, 280]
	mov	x5, x13
	ldr	w6, [sp, 256]
	add	w20, w20, 8
	ldr	w2, [sp, 260]
	ldr	w0, [sp, 268]
	str	x13, [sp, 152]
	sub	w0, w23, w0
	str	x10, [sp, 184]
	bl	update16x8_sve
	ldr	x13, [sp, 152]
	ldr	x10, [sp, 184]
	add	x13, x13, 64
	ldr	w0, [sp, 136]
	add	x10, x10, 8
	cmp	w20, w0
	bge	.L512
.L266:
	ldr	x0, [sp, 312]
	ldr	w1, [sp, 136]
	ldr	x0, [x0, 16]
	sub	w6, w1, w20
	ldr	x3, [x0]
	cbz	x3, .L513
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L285:
	cmp	w6, 7
	bgt	.L264
	ldp	x19, x5, [sp, 296]
	lsl	x0, x8, 4
	str	x0, [sp, 240]
	lsl	x0, x8, 1
	lsl	x7, x8, 3
	ldr	w18, [sp, 248]
	movi	v4.4s, 0
	str	x0, [sp, 232]
	sub	w0, w6, #1
	add	x17, x25, x10, lsl 3
	add	x30, x7, 16
	and	w21, w6, -4
	lsr	w4, w6, 1
	and	w11, w6, -2
	mov	x12, x10
	and	w9, w6, 1
	str	w0, [sp, 224]
	add	x0, sp, 768
	and	w1, w6, 3
	mov	w26, 16
	str	w1, [sp, 152]
	str	w20, [sp, 504]
	str	x10, [sp, 528]
	str	x13, [sp, 536]
	.p2align 3,,7
.L269:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w18, w23
	bge	.L268
	ldr	w1, [sp, 132]
	cmp	w1, w24
	ble	.L338
	ldr	x1, [sp, 144]
	mov	x10, x3
	mov	x16, x8
	mov	x15, 0
	sub	x20, x5, x1
	mov	w1, w24
	stp	x25, x27, [sp, 184]
	stp	x5, x22, [sp, 200]
	str	w4, [sp, 216]
	b	.L278
	.p2align 2,,3
.L339:
	mov	w1, w2
.L278:
	ldr	w2, [sp, 224]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x5, x4, x19
	cmp	w2, 2
	bls	.L514
	ldp	q1, q2, [x10]
	mov	w13, w21
	ldr	q5, [x10, x30]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 768]
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
	stp	q1, q2, [sp, 768]
	cbz	w5, .L283
.L284:
	uxtw	x5, w13
	add	x25, x4, x19
	add	x22, x5, x15
	add	x14, x5, x16
	sub	w13, w6, w13
	lsl	x5, x5, 3
	mov	x4, x25
	lsl	x22, x22, 3
	lsl	x14, x14, 3
	and	w27, w13, -2
	cmp	w13, 1
	beq	.L276
	ldr	q1, [x3, x22]
	add	w2, w2, w27
	ldr	q2, [x0, x5]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x5]
	ldr	d3, [x28, x25, lsl 3]
	ldr	q2, [x3, x14]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x5]
	tbz	x13, 0, .L283
.L276:
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
.L283:
	ldr	x4, [sp, 240]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x10, x10, x4
	ldr	x4, [sp, 232]
	add	x15, x15, x4
	add	x16, x16, x4
	ldr	w4, [sp, 132]
	cmp	w2, w4
	blt	.L339
	ldp	x25, x27, [sp, 184]
	add	w1, w1, 1
	ldp	x5, x22, [sp, 200]
	ldr	w4, [sp, 216]
.L274:
	sxtw	x13, w1
	ldr	x1, [sp, 176]
	sub	x14, x13, x1
	mul	x10, x8, x14
	madd	x14, x14, x7, x3
	.p2align 3,,7
.L282:
	ldr	d0, [x5, x13, lsl 3]
	cmp	w6, 1
	beq	.L340
	ldr	q2, [x14]
	sxtw	x1, w11
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w4, 1
	bls	.L280
	ldr	q2, [x14, 16]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w4, 3
	bne	.L280
	ldr	q2, [x14, 32]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
.L280:
	cbz	w9, .L281
.L279:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L281:
	add	x13, x13, 1
	add	x10, x10, x8
	add	x14, x14, x7
	cmp	w23, w13
	bgt	.L282
.L268:
	cmp	w6, 1
	beq	.L337
	ldr	q0, [x17]
	ldr	q1, [sp, 768]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17]
	cmp	w4, 1
	bls	.L272
	ldr	q0, [x17, 16]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 16]
	cmp	w4, 3
	bne	.L272
	ldr	q0, [x17, 32]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x17, 32]
.L272:
	sxtw	x1, w11
	cbz	w9, .L273
.L271:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x25, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x25, x2, lsl 3]
.L273:
	ldr	x1, [sp, 120]
	add	x12, x12, x22
	add	x19, x19, x27
	subs	w26, w26, #1
	add	x17, x17, x1
	ldr	x1, [sp, 160]
	add	x5, x5, x1
	bne	.L269
	ldr	x10, [sp, 528]
	ldr	x13, [sp, 536]
	add	x10, x10, 8
	ldr	w20, [sp, 504]
	ldr	w0, [sp, 136]
	add	x13, x13, 64
	add	w20, w20, 8
	cmp	w20, w0
	blt	.L266
.L512:
	ldp	x1, x14, [sp, 280]
	mov	x26, x27
	ldr	x15, [sp, 296]
	ldr	x21, [sp, 472]
	ldr	x22, [sp, 488]
	ldr	w27, [sp, 352]
	ldr	w19, [sp, 464]
	ldr	w4, [sp, 480]
.L233:
	ldr	x0, [sp, 600]
	add	w19, w19, 16
	sub	w3, w4, w19
	add	x1, x1, x0
	ldr	x0, [sp, 624]
	add	x15, x15, x0
	ldr	x0, [sp, 664]
	add	x14, x14, x0
	sub	x21, x21, x0
	ldr	x0, [sp, 336]
	add	x22, x22, x0
	cmp	w3, 15
	bgt	.L261
	mov	x18, x26
	ldr	w15, [sp, 344]
	mov	w26, w19
	mov	w23, w24
	b	.L231
	.p2align 2,,3
.L340:
	mov	x1, 0
	b	.L279
.L337:
	mov	x1, 0
	b	.L271
.L338:
	ldr	w1, [sp, 268]
	b	.L274
.L514:
	mov	w13, 0
	mov	w2, 0
	b	.L284
.L513:
	ldr	x0, [sp, 288]
	mov	x8, x22
	ldr	w4, [sp, 256]
	add	x3, x13, x0
	b	.L285
.L499:
	.cfi_restore 72
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 80]
	.cfi_restore 28
	.cfi_restore 27
.L161:
	ldp	x29, x30, [sp]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	add	sp, sp, 1024
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
.L226:
	.cfi_def_cfa_offset 1024
	.cfi_offset 19, -1008
	.cfi_offset 20, -1000
	.cfi_offset 21, -992
	.cfi_offset 22, -984
	.cfi_offset 23, -976
	.cfi_offset 24, -968
	.cfi_offset 25, -960
	.cfi_offset 26, -952
	.cfi_offset 27, -944
	.cfi_offset 28, -936
	.cfi_offset 29, -1024
	.cfi_offset 30, -1016
	add	w1, w1, 1
	mov	w0, 0
	b	.L321
.L505:
	.cfi_offset 72, -928
	ldr	w0, [sp, 264]
	add	w15, w15, 64
	mov	w27, 0
	sub	w0, w0, w15
	str	w0, [sp, 524]
	b	.L289
.L332:
	mov	w26, w15
.L231:
	add	w0, w26, 7
	cmp	w4, w0
	ble	.L230
	ldr	w0, [sp, 256]
	ldr	w1, [sp, 260]
	str	w15, [sp, 352]
	smull	x2, w0, w26
	sub	w0, w4, #8
	sub	w24, w0, w26
	smull	x10, w1, w26
	ldr	x0, [sp, 320]
	add	x22, x2, w27, sxtw
	and	w1, w24, -8
	str	w24, [sp, 480]
	sub	x0, x0, x2
	ldr	w24, [sp, 328]
	ldr	x2, [sp, 176]
	lsl	x8, x0, 3
	add	x0, x25, x22, lsl 3
	mov	x15, x10
	add	x3, x10, x2
	add	w2, w26, 8
	add	w19, w1, w2
	str	w2, [sp, 464]
	mov	w21, w19
	mov	x19, x0
	mov	w0, w23
	add	x1, x28, x3, lsl 3
	mov	x23, x25
	mov	x2, x8
	mov	x25, x28
	mov	w28, w0
.L235:
	ldr	w0, [sp, 136]
	cmp	w27, w0
	bge	.L241
	ldr	x0, [sp, 144]
	mov	x10, x22
	mov	x13, x19
	mov	w20, w27
	add	x0, x1, x0
	str	x0, [sp, 344]
	str	w27, [sp, 472]
	str	w4, [sp, 488]
	str	x19, [sp, 504]
	str	x22, [sp, 528]
	mov	x22, x18
	str	w26, [sp, 536]
	mov	x26, x10
	mov	x10, x2
	str	w21, [sp, 548]
	b	.L240
.L238:
	ldr	w6, [sp, 256]
	mov	x5, x13
	ldr	w2, [sp, 260]
	add	w20, w20, 8
	ldr	w0, [sp, 268]
	add	x26, x26, 8
	str	x1, [sp, 152]
	sub	w0, w24, w0
	stp	x13, x10, [sp, 184]
	str	x15, [sp, 200]
	bl	update8x8_sve
	ldp	x13, x10, [sp, 184]
	ldr	w0, [sp, 136]
	ldr	x1, [sp, 152]
	ldr	x15, [sp, 200]
	add	x13, x13, 64
	cmp	w20, w0
	bge	.L515
.L240:
	ldr	x0, [sp, 312]
	ldr	w2, [sp, 136]
	ldr	x0, [x0, 16]
	sub	w5, w2, w20
	ldr	x3, [x0]
	cbz	x3, .L516
	asr	w0, w20, 3
	mov	x8, 8
	mov	w4, w8
	sbfiz	x0, x0, 14, 32
	add	x3, x3, x0
.L260:
	cmp	w5, 7
	bgt	.L238
	lsl	x0, x8, 4
	lsl	x7, x8, 3
	ldr	x6, [sp, 344]
	lsr	w4, w5, 1
	and	w9, w5, 1
	and	w2, w5, 3
	movi	v4.4s, 0
	ldr	w30, [sp, 248]
	str	x0, [sp, 216]
	sub	w0, w5, #1
	str	x13, [sp, 728]
	add	x14, x23, x26, lsl 3
	ldr	w13, [sp, 132]
	lsl	x18, x8, 1
	mov	x12, x26
	add	x27, x7, 16
	and	w21, w5, -4
	and	w11, w5, -2
	mov	x19, x15
	str	x6, [sp, 152]
	mov	x6, x1
	str	w4, [sp, 184]
	mov	x4, x26
	mov	w26, w2
	str	w9, [sp, 192]
	mov	x9, x15
	str	x8, [sp, 200]
	mov	x8, x10
	str	w0, [sp, 208]
	add	x0, sp, 768
	mov	w17, 8
	str	w20, [sp, 724]
.L244:
	stp	q4, q4, [x0]
	stp	q4, q4, [x0, 32]
	cmp	w30, w24
	bge	.L243
	cmp	w13, w28
	ble	.L334
	ldp	x2, x1, [sp, 144]
	mov	x10, x3
	ldr	x16, [sp, 200]
	mov	x15, 0
	stp	x23, x22, [sp, 224]
	sub	x20, x1, x2
	mov	w1, w28
	str	w11, [sp, 240]
	str	w17, [sp, 280]
	str	x4, [sp, 288]
	str	w24, [sp, 296]
	str	x12, [sp, 304]
	b	.L253
.L335:
	mov	w1, w2
.L253:
	ldr	w2, [sp, 208]
	sxtw	x4, w1
	ldr	d0, [x20]
	add	x11, x4, x19
	cmp	w2, 2
	bls	.L517
	ldp	q1, q2, [x10]
	mov	w12, w21
	ldr	q5, [x10, x27]
	mov	w2, w21
	ldr	q3, [x10, x7]
	ldp	q7, q16, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	ldr	d6, [x25, x11, lsl 3]
	fmul	v1.2d, v1.2d, v0.d[0]
	fmul	v5.2d, v5.2d, v6.d[0]
	fmul	v3.2d, v3.2d, v6.d[0]
	fadd	v2.2d, v2.2d, v16.2d
	fadd	v1.2d, v1.2d, v7.2d
	fadd	v2.2d, v2.2d, v5.2d
	fadd	v1.2d, v1.2d, v3.2d
	stp	q1, q2, [sp, 768]
	cbz	w26, .L258
.L259:
	uxtw	x11, w12
	add	x23, x4, x19
	add	x22, x11, x15
	add	x17, x11, x16
	sub	w12, w5, w12
	lsl	x11, x11, 3
	mov	x4, x23
	lsl	x22, x22, 3
	lsl	x17, x17, 3
	and	w24, w12, -2
	cmp	w12, 1
	beq	.L251
	ldr	q1, [x3, x22]
	add	w2, w2, w24
	ldr	q2, [x0, x11]
	fmul	v1.2d, v1.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [x0, x11]
	ldr	d3, [x25, x23, lsl 3]
	ldr	q2, [x3, x17]
	fmul	v2.2d, v2.2d, v3.d[0]
	fadd	v1.2d, v2.2d, v1.2d
	str	q1, [x0, x11]
	tbz	x12, 0, .L258
.L251:
	sxtw	x2, w2
	ldr	d1, [x25, x4, lsl 3]
	add	x11, x2, x15
	add	x4, x2, x16
	ldr	d2, [x0, x2, lsl 3]
	ldr	d5, [x3, x11, lsl 3]
	ldr	d3, [x3, x4, lsl 3]
	fmul	d0, d0, d5
	fmul	d1, d1, d3
	fadd	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [x0, x2, lsl 3]
.L258:
	ldr	x4, [sp, 216]
	add	w2, w1, 2
	add	x20, x20, 16
	add	x15, x15, x18
	add	x16, x16, x18
	add	x10, x10, x4
	cmp	w2, w13
	blt	.L335
	ldp	x23, x22, [sp, 224]
	add	w1, w1, 1
	ldr	x4, [sp, 288]
	ldr	x12, [sp, 304]
	ldr	w11, [sp, 240]
	ldr	w17, [sp, 280]
	ldr	w24, [sp, 296]
.L249:
	sxtw	x15, w1
	ldr	w20, [sp, 184]
	ldr	x1, [sp, 176]
	str	w21, [sp, 224]
	ldr	x21, [sp, 152]
	sub	x16, x15, x1
	ldr	x1, [sp, 200]
	stp	x23, x25, [sp, 232]
	ldr	w25, [sp, 192]
	mov	x23, x1
	mul	x10, x16, x1
	madd	x16, x16, x7, x3
	.p2align 3,,7
.L257:
	ldr	d0, [x21, x15, lsl 3]
	cmp	w5, 1
	beq	.L336
	ldr	q2, [x16]
	sxtw	x1, w11
	ldr	q1, [sp, 768]
	fmul	v2.2d, v2.2d, v0.d[0]
	dup	v3.2d, v0.d[0]
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 768]
	cmp	w20, 1
	bls	.L255
	ldr	q2, [x16, 16]
	ldr	q1, [sp, 784]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 784]
	cmp	w20, 3
	bne	.L255
	ldr	q2, [x16, 32]
	ldr	q1, [sp, 800]
	fmul	v2.2d, v2.2d, v3.2d
	fadd	v1.2d, v1.2d, v2.2d
	str	q1, [sp, 800]
.L255:
	cbz	w25, .L256
.L254:
	add	x2, x1, x10
	ldr	d1, [x0, x1, lsl 3]
	ldr	d2, [x3, x2, lsl 3]
	fmul	d0, d0, d2
	fadd	d0, d0, d1
	str	d0, [x0, x1, lsl 3]
.L256:
	add	x15, x15, 1
	add	x10, x10, x23
	add	x16, x16, x7
	cmp	w24, w15
	bgt	.L257
	ldp	x23, x25, [sp, 232]
	ldr	w21, [sp, 224]
.L243:
	cmp	w5, 1
	beq	.L333
	ldr	q0, [x14]
	ldr	q1, [sp, 768]
	ldr	w1, [sp, 184]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14]
	cmp	w1, 1
	bls	.L247
	ldr	q0, [x14, 16]
	ldr	q1, [sp, 784]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 16]
	cmp	w1, 3
	bne	.L247
	ldr	q0, [x14, 32]
	ldr	q1, [sp, 800]
	fsub	v0.2d, v0.2d, v1.2d
	str	q0, [x14, 32]
.L247:
	ldr	w1, [sp, 192]
	cbz	w1, .L248
	sxtw	x1, w11
.L246:
	add	x2, x1, x12
	ldr	d1, [x0, x1, lsl 3]
	ldr	d0, [x23, x2, lsl 3]
	fsub	d0, d0, d1
	str	d0, [x23, x2, lsl 3]
.L248:
	ldp	x2, x1, [sp, 160]
	add	x19, x19, x22
	subs	w17, w17, #1
	add	x12, x12, x1
	ldr	x1, [sp, 120]
	add	x14, x14, x1
	ldr	x1, [sp, 152]
	add	x1, x1, x2
	str	x1, [sp, 152]
	bne	.L244
	ldr	x13, [sp, 728]
	mov	x26, x4
	ldr	w20, [sp, 724]
	mov	x1, x6
	ldr	w0, [sp, 136]
	mov	x10, x8
	add	w20, w20, 8
	mov	x15, x9
	add	x13, x13, 64
	add	x26, x26, 8
	cmp	w20, w0
	blt	.L240
.L515:
	ldr	x19, [sp, 504]
	mov	x18, x22
	ldr	x22, [sp, 528]
	mov	x2, x10
	ldr	w27, [sp, 472]
	ldr	w4, [sp, 488]
	ldr	w26, [sp, 536]
	ldr	w21, [sp, 548]
.L241:
	ldr	x0, [sp, 608]
	add	w26, w26, 8
	add	x1, x1, x0
	ldr	x0, [sp, 160]
	add	x15, x15, x0
	ldr	x0, [sp, 672]
	add	x2, x2, x0
	sub	x19, x19, x0
	ldr	x0, [sp, 120]
	add	x22, x22, x0
	cmp	w26, w21
	bne	.L235
	ldr	w24, [sp, 480]
	mov	w0, w28
	ldr	w2, [sp, 464]
	mov	x28, x25
	and	w24, w24, -8
	mov	x25, x23
	ldr	w15, [sp, 352]
	mov	w23, w0
	add	w26, w24, w2
	b	.L230
.L336:
	mov	x1, 0
	b	.L254
.L333:
	mov	x1, 0
	b	.L246
.L334:
	ldr	w1, [sp, 268]
	b	.L249
.L516:
	ldr	x8, [sp, 168]
	add	x3, x13, x10
	ldr	w4, [sp, 256]
	b	.L260
.L517:
	mov	w12, 0
	mov	w2, 0
	b	.L259
.L497:
	.cfi_restore 72
	str	d8, [sp, 96]
	.cfi_offset 72, -928
	b	.L324
.L328:
	mov	w12, 0
	b	.L209
	.p2align 2,,3
.L323:
	.cfi_restore 72
	bl	GOMP_barrier
	b	.L225
	.cfi_endproc
.LFE4372:
	.size	solve_blocked._omp_fn.0, .-solve_blocked._omp_fn.0
	.align	2
	.p2align 4,,11
	.global	l_trsm
	.type	l_trsm, %function
l_trsm:
.LFB4371:
	.cfi_startproc
	cmp	w0, 0
	ccmp	w1, 0, 4, gt
	ble	.L526
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
	mov	x22, x4
	mov	x24, x2
	mov	w23, w3
	mov	w21, w5
	cmp	x0, x1
	bls	.L520
	sxtw	x2, w20
	add	x0, sp, 80
	add	x2, x2, 7
	mov	x1, 64
	str	xzr, [sp, 88]
	lsr	x2, x2, 3
	lsl	x2, x2, 14
	bl	posix_memalign
	cbnz	w0, .L521
	ldr	x0, [sp, 80]
	str	x0, [sp, 88]
.L521:
	mov	x0, 16
	bl	getauxval
	add	x5, sp, 88
	ubfx	w4, w0, 22, 1
	adrp	x1, solve_blocked._omp_fn.0
	mov	w3, 0
	add	x0, x1, :lo12:solve_blocked._omp_fn.0
	mov	w2, 0
	add	x1, sp, 96
	stp	x24, x22, [sp, 96]
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
.L526:
	ret
	.p2align 2,,3
.L520:
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
	ble	.L523
	sxtw	x3, w26
	add	x0, sp, 88
	sub	x2, x3, #1
	mov	x1, 64
	mul	x2, x2, x3
	lsl	x2, x2, 10
	bl	posix_memalign
	cbnz	w0, .L523
	ldr	x0, [sp, 88]
	str	x0, [sp, 80]
.L523:
	add	x4, sp, 80
	add	x1, sp, 96
	mov	w3, 0
	mov	w2, 0
	adrp	x0, solve_panel._omp_fn.0
	add	x0, x0, :lo12:solve_panel._omp_fn.0
	stp	x24, x22, [sp, 96]
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
.LFE4371:
	.size	l_trsm, .-l_trsm
	.ident	"GCC: (gcc for openEuler 3.0.2) 12.3.1"
	.section	.note.GNU-stack,"",@progbits
