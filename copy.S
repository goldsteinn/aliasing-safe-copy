	/* Build: gcc -static -nostartfiles -nodefaultlibs -nostdlib
	   -Wl,--build-id=none <file>.S -o <executable>.  */

	/* Keep dst / src aligned 128. This is not a sophisticated
	   memcpy. Note to abuse false 4k aliasing src = dst - 128 usually
	   works best.  */
#define ALIGN_SRC	(2048 - 128)
#define ALIGN_DST	2048
#define DISABLE_LSD	0

	/* Set to 1 for 4k aliasing "safe" version, set to 0 for normal
	   memcpy.  */
#define ALIAS_SAFE	1
	.global	_start

	.text
_start:
	movl	$20000000, %ecx
	leaq	(src_start + ALIGN_SRC)(%rip), %rsi
	leaq	(dst_start + ALIGN_DST)(%rip), %rdi

	leaq	(dst_end)(%rip), %rdx
	movq	%rdi, %r8
	addq	$127, %r8
	andq	$-128, %r8
	subq	%r8, %rdx
	addq	%rsi, %rdx

	movq	%rdi, %rax
	movq	%rsi, %r11
#if DISABLE_LSD
	movq	%rsp, %r8
#endif

	.p2align 6
loop:
#if DISABLE_LSD
	pop	%r9
	movq	%r8, %rsp
#endif

#if ALIAS_SAFE == 1
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vmovdqu	64(%rsi), %ymm2
	vmovdqu	96(%rsi), %ymm3
	subq	$-128, %rsi
	addq	$32, %rdi
	vmovdqu	%ymm0, -32(%rdi)
	addq	$32, %rdi
	vmovdqu	%ymm1, -32(%rdi)
	addq	$32, %rdi
	addq	$32, %rdi
	vmovdqu	%ymm2, -64(%rdi)
	andq	%rdi, %rdi
	andq	%rdi, %rdi
	vmovdqu	%ymm3, -32(%rdi)

#else

	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vmovdqu	64(%rsi), %ymm2
	vmovdqu	96(%rsi), %ymm3
	subq	$-128, %rsi
	vmovdqu	%ymm0, (%rdi)
	vmovdqu	%ymm1, 32(%rdi)
	vmovdqu	%ymm2, 64(%rdi)
	vmovdqu	%ymm3, 96(%rdi)
	subq	$-128, %rdi
#endif
	cmpq	%rdx, %rsi
	jb	loop

	movq	%rax, %rdi
	movq	%r11, %rsi
	decl	%ecx
	jnz	loop

end:
	movl	$60, %eax
	xorl	%edi, %edi
	syscall

	.section .data
	.balign	4096
src_start:.space 4096
src_end:
	.balign	4096
dst_start:.space 4096
dst_end:
