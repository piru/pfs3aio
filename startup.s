	
#include <exec/exec_lib.i>

	.globl _AfsDie
	.globl _rawdofmt

		sub.l a3,a3
		move.l	4.w,a6

	/* stack large enough? */

		sub.l a1,a1
		jsr _LVOFindTask(a6)
		move.l d0,a0
		move.l 62(a0),d0
		sub.l	58(a0),d0
		cmp.l #6000,d0
		bcc.b 3f

	/* allocate stackswap memory */

		move.l #6000+12,d0
		moveq #1,d1
		jsr	_LVOAllocMem(a6)
		move.l	d0,a3
		tst.l d0
		beq end
		add.l	#12,d0
		move.l	d0,(a3)
		add.l	#6000,d0
		move.l	d0,4(a3)
		move.l	d0,8(a3)
		move.l	a3,a0

	/* check exec revision */

		cmp.w #37,0x14(a6)	/* SysBase->LibNode.lib_Version */
		bcc.b 1f

	/* stackswap V36 and older */

		bsr	myStackSwap
		bra.b	2f

	/* stackswap V37 */

1:
		jsr	_LVOStackSwap(a6)
2:

	/* remember sss address and enter filesystem */
3:
		move.l	a3,-(a7)
		bra	_EntryPoint

myStackSwap:

		jsr	_LVODisable(a6)

		move.l 276(a6),a1

		move.l	62(a1),d0
		move.l	4(a0),62(a1)
		move.l	d0,4(a0)

		move.l	58(a1),d0
		move.l	(a0),58(a1)
		move.l	d0,(a0)

		move.l	8(a0),54(a1)

		move.l	(a0),a1
		move.l	8(a0),a1
		move.l	(sp)+,d0
		move.l	sp,8(a0)
		move.l	d0,-(a1)
		move.l	a1,sp

		jmp	_LVOEnable(a6)

_AfsDie:

	/* find my task structure */

		move.l	4.w,a6
		suba.l	a1,a1
		jsr	_LVOFindTask(a6)
		move.l	d0,a0

	/* clear stack and get StackSwapStruct */

		move.l	62(a0),a7 /* TC_SPUPPER */
		move.l	58(a0),a3 /* TC_SPLOWER */
		lea	-4(a7),a7
		move.l	(a7)+,a0
		move.l a0,d0
		beq.b 3f

		cmp.w #37,20(a6)
		bcc.b 1f

		bsr myStackSwap
		bra.b 2f

1:
		jsr	_LVOStackSwap(a6)
2:

	/* free stack */

		move.l a3,a1
		move.l	#6000+12,d0
		jsr	_LVOFreeMem(a6)	

3:
	/* exit AFS */
end:
		moveq	#0,d0	
		rts

putproc:
	move.b d0,(a3)+
	rts

_rawdofmt:
	movem.l a2/a3/a6,-(sp)
	move.l 4.w,a6
	move.l 8+16(sp),a1
	move.l 4+16(sp),a0
	move.l 0+16(sp),a3
	lea putproc(pc),a2
	jsr -0x20a(a6)
	movem.l (sp)+,a2/a3/a6
	rts
	