// ============================================================================
//        __
//   \\__/ o\    (C) 2012-2015  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================
//






// message types

enum {
     E_Ok = 0,
     E_BadTCBHandle,
     E_BadPriority,
     E_BadCallno,
     E_Arg,
     E_BadMbx,
     E_QueFull,
     E_NoThread,
     E_NotAlloc,
     E_NoMsg,
     E_Timeout,
     E_BadAlarm,
     E_NotOwner,
     E_QueStrategy,
     E_DCBInUse,
     //; Device driver errors
     E_BadDevNum =	0x20,
     E_NoDev,
     E_BadDevOp,
     E_ReadError,
     E_WriteError,
     E_BadBlockNum,
     E_TooManyBlocks,

     // resource errors
     E_NoMoreMbx =	0x40,
     E_NoMoreMsgBlks,
     E_NoMoreAlarmBlks,
     E_NoMoreTCBs,
     E_NoMem,
     E_TooManyTasks
};


typedef unsigned int uint;
typedef __int16 hTCB;
typedef __int8 hJCB;
typedef __int16 hMBX;
typedef __int16 hMSG;

typedef struct tagMSG align(32) {
	unsigned __int16 link;
	unsigned __int16 retadr;    // return address
	unsigned __int16 tgtadr;    // target address
	unsigned __int16 type;
	unsigned int d1;            // payload data 1
	unsigned int d2;            // payload data 2
	unsigned int d3;            // payload data 3
} MSG;

typedef struct _tagJCB align(2048)
{
    struct _tagJCB *iof_next;
    struct _tagJCB *iof_prev;
    char UserName[32];
    char path[256];
    char exitRunFile[256];
    char commandLine[256];
    unsigned __int32 *pVidMem;
    unsigned __int32 *pVirtVidMem;
    unsigned __int16 VideoRows;
    unsigned __int16 VideoCols;
    unsigned __int16 CursorRow;
    unsigned __int16 CursorCol;
    unsigned __int32 NormAttr;
    __int8 KeyState1;
    __int8 KeyState2;
    __int8 KeybdWaitFlag;
    __int8 KeybdHead;
    __int8 KeybdTail;
    unsigned __int8 KeybdBuffer[32];
    hJCB number;
    hTCB tasks[8];
    hJCB next;
} JCB;

struct tagMBX;

typedef struct _tagTCB align(1024) {
    // exception storage area
	int regs[32];
	int isp;
	int dsp;
	int esp;
	int ipc;
	int dpc;
	int epc;
	int cr0;
	// interrupt storage
	int iregs[32];
	int iisp;
	int idsp;
	int iesp;
	int iipc;
	int idpc;
	int iepc;
	int icr0;
	hTCB next;
	hTCB prev;
	hTCB mbq_next;
	hTCB mbq_prev;
	int *sys_stack;
	int *bios_stack;
	int *stack;
	__int64 timeout;
	MSG msg;
	hMBX hMailboxes[4]; // handles of mailboxes owned by task
	hMBX hWaitMbx;      // handle of mailbox task is waiting at
	hTCB number;
	__int8 priority;
	__int8 status;
	__int8 affinity;
	hJCB hJob;
	__int64 startTick;
	__int64 endTick;
	__int64 ticks;
	int exception;
} TCB;

typedef struct tagMBX align(64) {
    hMBX link;
	hJCB owner;		// hJcb of owner
	hTCB tq_head;
	hTCB tq_tail;
	hMSG mq_head;
	hMSG mq_tail;
	char mq_strategy;
	byte resv[2];
	uint tq_count;
	uint mq_size;
	uint mq_count;
	uint mq_missed;
} MBX;

typedef struct tagALARM {
	struct tagALARM *next;
	struct tagALARM *prev;
	MBX *mbx;
	MSG *msg;
	uint BaseTimeout;
	uint timeout;
	uint repeat;
	byte resv[8];		// padding to 64 bytes
} ALARM;


// ============================================================================
//        __
//   \\__/ o\    (C) 2012-2015  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
// TCB.c
// Task Control Block related functions.
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================
//
// JCB functions
JCB *GetJCBPtr();                   // get the JCB pointer of the running task

// TCB functions
TCB *GetRunningTCBPtr();
hTCB GetRunningTCB();
pascal void SetRunningTCB(hTCB ht);
pascal int chkTCB(TCB *p);
pascal int InsertIntoReadyList(hTCB ht);
pascal int RemoveFromReadyList(hTCB ht);
pascal int InsertIntoTimeoutList(hTCB ht, int to);
pascal int RemoveFromTimeoutList(hTCB ht);
void DumpTaskList();

pascal void SetBound48(TCB *ps, TCB *pe, int algn);
pascal void SetBound49(JCB *ps, JCB *pe, int algn);
pascal void SetBound50(MBX *ps, MBX *pe, int algn);
pascal void SetBound51(MSG *ps, MSG *pe, int algn);

pascal void set_vector(unsigned int, unsigned int);
int getCPU();
int GetVecno();          // get the last interrupt vector number
void outb(unsigned int, int);
void outc(unsigned int, int);
void outh(unsigned int, int);
void outw(unsigned int, int);
pascal int LockSemaphore(int *sema, int retries);
pascal void UnlockSemaphore(int *sema);

// The following causes a privilege violation if called from user mode


extern int irq_stack[];
extern int FMTK_Inited;
extern JCB jcbs[];
extern TCB tcbs[];
extern hTCB readyQ[];
extern hTCB freeTCB;
extern int sysstack[];
extern int stacks[][];
extern int sys_stacks[][];
extern int bios_stacks[][];
extern int fmtk_irq_stack[];
extern int fmtk_sys_stack[];
extern MBX mailbox[];
extern MSG message[];
extern int nMsgBlk;
extern int nMailbox;
extern hMSG freeMSG;
extern hMBX freeMBX;
extern JCB *IOFocusNdx;
extern int IOFocusTbl[];
extern int iof_switch;
extern int BIOS1_sema;
extern int iof_sema;
extern int sys_sema;
extern int kbd_sema;
extern int BIOS_RespMbx;
extern char hasUltraHighPriorityTasks;
extern int missed_ticks;
extern short int video_bufs[][];
extern hTCB TimeoutList;


extern int shell();

int irq_stack[512];
int sp_tmp;
int FMTK_Inited;
JCB jcbs[51];
extern TCB tcbs[256];
extern hTCB readyQ[8];
int sysstack[1024];
int stacks[256][1024];
int sys_stacks[256][512];
int bios_stacks[256][512];
int fmtk_irq_stack[512];
int fmtk_sys_stack[512];
MBX mailbox[1024];
MSG message[16384];
int nMsgBlk;
int nMailbox;
hJCB freeJCB;
hMSG freeMSG;
hMBX freeMBX;
JCB *IOFocusNdx;
int IOFocusTbl[4];
int iof_switch;
int BIOS1_sema;
int iof_sema;
int sys_sema;
int BIOS_RespMbx;
char hasUltraHighPriorityTasks;
int missed_ticks;

short int video_bufs[51][4096];
extern hTCB TimeoutList;

// This table needed in case we want to call the OS routines directly.
// It is also used by the system call interrupt as a vector table.

naked void FMTK_BrTbl()
{
      asm {
          bra  FMTKInitialize_
          bra  FMTK_StartTask_
          bra  FMTK_ExitTask_
          bra  FMTK_KillTask_
          bra  FMTK_SetTaskPriority_
          bra  FMTK_Sleep_
          bra  FMTK_AllocMbx_
          bra  FMTK_FreeMbx_
          bra  FMTK_PostMsg_
          bra  FMTK_SendMsg_
          bra  FMTK_WaitMsg_
          bra  FMTK_CheckMsg_
      }
}

naked int GetVecno()
{
    asm {
        mfspr  r1,12
        rtl
    }
}

naked void DisplayIRQLive()
{
     asm {
         lh       r1,$FFD00000+220
         addui    r1,r1,#1
         sh       r1,$FFD00000+220
         rtl
     }
}

JCB *GetJCBPtr()
{
    return &jcbs[tcbs[GetRunningTCB()].hJob];
}


// ----------------------------------------------------------------------------
// Select a task to run.
// ----------------------------------------------------------------------------

private __int8 startQ[32] = { 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 1, 0, 4, 0, 0, 0, 5, 0, 0, 0, 6, 0, 1, 0, 7, 0, 0, 0, 0 };
private __int8 startQNdx;

private hTCB SelectTaskToRun()
{
	int nn,kk;
	TCB *p, *q;
	int qToCheck;
    hTCB h;
 
	startQNdx++;
	startQNdx &= 31;
	qToCheck = startQ[startQNdx];
	qToCheck &= 7;
	for (nn = 0; nn < 8; nn++) {
		h = readyQ[qToCheck];
		if (h >= 0 && h < 256) {
    		p = &tcbs[h];
            kk = 0;
            // Can run the head of a lower Q level if it's not the running
            // task, otherwise look to the next task.
            if (h != GetRunningTCB())
           		q = p;
    		else
           		q = &tcbs[p->next];
            do {  
                if (!(q->status & 8)) {
                    if (q->affinity == getCPU()) {
        			   readyQ[qToCheck] = q - tcbs;
        			   return q - tcbs;
                    }
                }
                q = &tcbs[q->next];
                kk = kk + 1;
            } while (q != p && kk < 256);
        }
		qToCheck++;
		qToCheck &= 7;
	}
	return GetRunningTCB();
	panic("No entries in ready queue.");
}

// ----------------------------------------------------------------------------
// There isn't any 'C' code in the SystemCall() function. If there were it
// would have to be arranged like the TimerIRQ() or RescheduleIRQ() functions.
// ----------------------------------------------------------------------------

naked FMTK_SystemCall()
{
    asm {
         lea   sp,sys_stacks_[tr]
         sw    r1,8[tr]
         sw    r2,16[tr]
         sw    r3,24[tr]
         sw    r4,32[tr]
         sw    r5,40[tr]
         sw    r6,48[tr]
         sw    r7,56[tr]
         sw    r8,64[tr]
         sw    r9,72[tr]
         sw    r10,80[tr]
         sw    r11,88[tr]
         sw    r12,96[tr]
         sw    r13,104[tr]
         sw    r14,112[tr]
         sw    r15,120[tr]
         sw    r16,128[tr]
         sw    r17,136[tr]
         sw    r18,144[tr]
         sw    r19,152[tr]
         sw    r20,160[tr]
         sw    r21,168[tr]
         sw    r22,176[tr]
         sw    r23,184[tr]
         sw    r24,192[tr]
         sw    r25,200[tr]
         sw    r26,208[tr]
         sw    r27,216[tr]
         sw    r28,224[tr]
         sw    r29,232[tr]
         sw    r30,240[tr]
         sw    r31,248[tr]
         mfspr r1,isp
         sw    r1,256[tr]
         mfspr r1,dsp
         sw    r1,264[tr]
         mfspr r1,esp
         sw    r1,272[tr]
         mfspr r1,ipc
         sw    r1,280[tr]
         mfspr r1,dpc
         sw    r1,288[tr]
         mfspr r1,epc
         sw    r1,296[tr]
         mfspr r1,cr0
         sw    r1,304[tr]

    	 mfspr r6,epc           ; get return address into r6
    	 and   r7,r6,#-4        ; clear LSB's
    	 lh	   r7,4[r7]			; get static call number parameter into r7
    	 addui r6,r6,#8		    ; update return address
    	 sw    r6,296[tr]
    	 cmpu  r6,r7,#20
    	 bgt   r6,.bad_callno
    	 asl   r7,r7,#2
    	 lw    r1,8[tr]         ; get back r1, we trashed it above
    	 push  r5
    	 push  r4
    	 push  r3
    	 push  r2
    	 push  r1
    	 jsr   FMTK_BrTbl_[r7]	; do the system function
    	 addui sp,sp,#40
    	 sw    r1,8[tr]
.0001:
         lw    r1,256[tr]
         mtspr isp,r1
         lw    r1,264[tr]
         mtspr dsp,r1
         lw    r1,272[tr]
         mtspr esp,r1
         lw    r1,280[tr]
         mtspr ipc,r1
         lw    r1,288[tr]
         mtspr dpc,r1
         lw    r1,296[tr]
         mtspr epc,r1
         lw    r1,304[tr]
         mtspr cr0,r1
         lw    r1,8[tr]
         lw    r2,16[tr]
         lw    r3,24[tr]
         lw    r4,32[tr]
         lw    r5,40[tr]
         lw    r6,48[tr]
         lw    r7,56[tr]
         lw    r8,64[tr]
         lw    r9,72[tr]
         lw    r10,80[tr]
         lw    r11,88[tr]
         lw    r12,96[tr]
         lw    r13,104[tr]
         lw    r14,112[tr]
         lw    r15,120[tr]
         lw    r16,128[tr]
         lw    r17,136[tr]
         lw    r18,144[tr]
         lw    r19,152[tr]
         lw    r20,160[tr]
         lw    r21,168[tr]
         lw    r22,176[tr]
         lw    r23,184[tr]
         lw    r25,200[tr]
         lw    r26,208[tr]
         lw    r27,216[tr]
         lw    r28,224[tr]
         lw    r29,232[tr]
         lw    r31,248[tr]
         rte
.bad_callno:
         ldi   r1,#E_BadFuncno
         sw    r1,8[tr]
         bra   .0001   
    }
}

// ----------------------------------------------------------------------------
// If timer interrupts are enabled during a priority #0 task, this routine
// only updates the missed ticks and remains in the same task. No timeouts
// are updated and no task switches will occur. The timer tick routine
// basically has a fixed latency when priority #0 is present.
// ----------------------------------------------------------------------------

void FMTK_SchedulerIRQ()
{
     TCB *t;

     prolog asm {
         lea   sp,fmtk_irq_stack_+4088
         sw    r1,8+312[tr]
         sw    r2,16+312[tr]
         sw    r3,24+312[tr]
         sw    r4,32+312[tr]
         sw    r5,40+312[tr]
         sw    r6,48+312[tr]
         sw    r7,56+312[tr]
         sw    r8,64+312[tr]
         sw    r9,72+312[tr]
         sw    r10,80+312[tr]
         sw    r11,88+312[tr]
         sw    r12,96+312[tr]
         sw    r13,104+312[tr]
         sw    r14,112+312[tr]
         sw    r15,120+312[tr]
         sw    r16,128+312[tr]
         sw    r17,136+312[tr]
         sw    r18,144+312[tr]
         sw    r19,152+312[tr]
         sw    r20,160+312[tr]
         sw    r21,168+312[tr]
         sw    r22,176+312[tr]
         sw    r23,184+312[tr]
         sw    r24,192+312[tr]
         sw    r25,200+312[tr]
         sw    r26,208+312[tr]
         sw    r27,216+312[tr]
         sw    r28,224+312[tr]
         sw    r29,232+312[tr]
         sw    r30,240+312[tr]
         sw    r31,248+312[tr]
         mfspr r1,isp
         sw    r1,256+312[tr]
         mfspr r1,dsp
         sw    r1,264+312[tr]
         mfspr r1,esp
         sw    r1,272+312[tr]
         mfspr r1,ipc
         sw    r1,280+312[tr]
         mfspr r1,dpc
         sw    r1,288+312[tr]
         mfspr r1,epc
         sw    r1,296+312[tr]
         mfspr r1,cr0
         sw    r1,304+312[tr]
         mfspr r1,tick
         sw    r1,$2D8[tr]
     }
     switch(GetVecno()) {
     // Timer tick interrupt
     case 451:
          asm {
             ldi   r1,#3				; reset the edge sense circuit
             sh	   r1,PIC_RSTE
         }
         if (getCPU()==0) DisplayIRQLive();
         if (ILockSemaphore(&sys_sema,10)) {
             t = GetRunningTCBPtr();
             t->ticks = t->ticks + (t->endTick - t->startTick);
             if (t->priority != 000) {
                 t->status = 4;
                 while (TimeoutList >= 0 && TimeoutList < 256) {
                     if (tcbs[TimeoutList].timeout<=0)
                         InsertIntoReadyList(PopTimeoutList());
                     else {
                          tcbs[TimeoutList].timeout = tcbs[TimeoutList].timeout - missed_ticks - 1;
                          missed_ticks = 0;
                          break;
                     }
                 }
                 if (t->priority > 002)
                    SetRunningTCB(SelectTaskToRun());
                 GetRunningTCBPtr()->status = 8;
             }
             else
                 missed_ticks++;
             UnlockSemaphore(&sys_sema);
         }
         else {
             missed_ticks++;
         }
         break;
     // Explicit rescheduling request.
     case 2:
         t = GetRunningTCBPtr();
         t->ticks = t->ticks + (t->endTick - t->startTick);
         t->status = 4;
         t->iipc = t->iipc + 4;  // advance the return address
         SetRunningTCB(SelectTaskToRun());
         GetRunningTCBPtr()->status = 8;
         break;
     default:  ;
     }
     // If an exception was flagged (eg CTRL-C) return to the catch handler
     // not the interrupted code.
     t = GetRunningTCBPtr();
     if (t->exception) {
         t->iregs[31] = t->iregs[28];   // set link register to catch handler
         t->iipc = t->iregs[28];        // and the PC register
         t->iregs[1] = t->exception;    // r1 = exception value
         t->exception = 0;
         t->iregs[2] = 24;              // r2 = exception type
     }
     // Restore the processor registers and return using an RTI.
     epilog asm {
RestoreContext:
         mfspr r1,tick
         sw    r1,$2d0[tr]
         lw    r1,256+312[tr]
         mtspr isp,r1
         lw    r1,264+312[tr]
         mtspr dsp,r1
         lw    r1,272+312[tr]
         mtspr esp,r1
         lw    r1,280+312[tr]
         mtspr ipc,r1
         lw    r1,288+312[tr]
         mtspr dpc,r1
         lw    r1,296+312[tr]
         mtspr epc,r1
         lw    r1,304+312[tr]
         mtspr cr0,r1
         lw    r1,8+312[tr]
         lw    r2,16+312[tr]
         lw    r3,24+312[tr]
         lw    r4,32+312[tr]
         lw    r5,40+312[tr]
         lw    r6,48+312[tr]
         lw    r7,56+312[tr]
         lw    r8,64+312[tr]
         lw    r9,72+312[tr]
         lw    r10,80+312[tr]
         lw    r11,88+312[tr]
         lw    r12,96+312[tr]
         lw    r13,104+312[tr]
         lw    r14,112+312[tr]
         lw    r15,120+312[tr]
         lw    r16,128+312[tr]
         lw    r17,136+312[tr]
         lw    r18,144+312[tr]
         lw    r19,152+312[tr]
         lw    r20,160+312[tr]
         lw    r21,168+312[tr]
         lw    r22,176+312[tr]
         lw    r23,184+312[tr]
         lw    r25,200+312[tr]
         lw    r26,208+312[tr]
         lw    r27,216+312[tr]
         lw    r28,224+312[tr]
         lw    r29,232+312[tr]
         lw    r31,248+312[tr]
         rti
     }
}

void panic(char *msg)
{
     putstr(msg);
j1:  goto j1;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

void IdleTask()
{
     int ii;
     __int32 *screen = (__int32 *)0xFFD00000;

//     try {
j1:  ;
         forever {
             try {
                 ii++;
                 if (getCPU()==0)
                     screen[57] = ii;
             }
             catch(static __exception ex=0) {
                 if (ex&0xFFFFFFFFL==515) {
                     printf("IdleTask: CTRL-C pressed.\r\n");
                 }
                 else
                     throw ex;
             }
         }
/*
     }
     catch (static __exception ex1=0) {
         printf("IdleTask: exception %d.\r\n", ex1);
         goto j1;
     }
*/
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

int FMTK_KillTask(int taskno)
{
    hTCB ht;
    int nn;
    JCB *j;

    asm { mfspr r1,ivno };
    ht = taskno;
    if (LockSemaphore(&sys_sema,-1)) {
        RemoveFromReadyList(ht);
        RemoveFromTimeoutList(ht);
        for (nn = 0; nn < 4; nn++)
            if (tcbs[ht].hMailboxes[nn] >= 0 && tcbs[ht].hMailboxes[nn] < 1024) {
                FMTK_FreeMbx(tcbs[ht].hMailboxes[nn]);
                tcbs[ht].hMailboxes[nn] = -1;
            }
        // remove task from job's task list
        j = &jcbs[tcbs[ht].hJob];
        for (nn = 0; nn < 8; nn++) {
            if (j->tasks[nn]==ht)
                j->tasks[nn] = -1;
        }
        // If the job no longer has any tasks associated with it, it is 
        // finished.
        for (nn = 0; nn < 8; nn++)
            if (j->tasks[nn]!=-1)
                break;
        if (nn == 8) {
            j->next = freeJCB;
            freeJCB = j - jcbs;
        }
        UnlockSemaphore(&sys_sema);
    }
}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

int FMTK_ExitTask()
{
    asm { mfspr r1,ivno };
    KillTask(GetRunningTCB());
    asm { int #2 }     // reschedule
j1: goto j1;
}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

int FMTK_StartTask(int priority, int affinity, int adr, int parm, hJCB job)
{
    hTCB ht;
    TCB *t;
    int nn;

    asm { mfspr r1,ivno };
    if (LockSemaphore(&sys_sema,-1)) {
        ht = freeTCB;
        freeTCB = tcbs[ht].next;
        UnlockSemaphore(&sys_sema);
    }
    t = &tcbs[ht];
    t->affinity = affinity;
    t->priority = priority;
    t->hJob = job;
    // Insert into the job's list of tasks.
    for (nn = 0; nn < 8; nn++) {
        if (jcbs[job].tasks[nn]<0) {
            jcbs[job].tasks[nn] = ht;
            break;
        }
    }
    if (nn == 8) {
        if (LockSemaphore(&sys_sema,-1)) {
            tcbs[ht].next = freeTCB;
            freeTCB = ht;
            UnlockSemaphore(&sys_sema);
        }
        return E_TooManyTasks;
    }
    t->iregs[1] = parm;
    t->iregs[28] = FMTK_ExitTask;
    t->iregs[31] = FMTK_ExitTask;
    t->iisp = t->stack + 1023;
    t->iipc = adr|1;   // stay in kernel mode for now
    t->icr0 = 0x140000000L;
    t->startTick = 0;
    t->endTick = 0;
    t->ticks = 0;
    t->exception = 0;
    if (LockSemaphore(&sys_sema,-1)) {
        InsertIntoReadyList(ht); }
        UnlockSemaphore(&sys_sema);
    }
    return E_Ok;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

int FMTK_Sleep(int timeout)
{
    hTCB ht;
    
    asm { mfspr r1,ivno };
    if (LockSemaphore(&sys_sema,-1)) {
        ht = GetRunningTCB();
        RemoveFromReadyList(ht);
        InsertIntoTimeoutList(ht, timeout);
        UnlockSemaphore(&sys_sema);
    }
    asm { int #2 }      // reschedule
    return E_Ok;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

int FMTK_SetTaskPriority(hTCB ht, int priority)
{
    TCB *t;

    asm { mfspr r1,ivno };
    if (priority > 077 || priority < 000)
       return E_Arg;
    if (LockSemaphore(&sys_sema,-1)) {
        t = &tcbs[ht];
        if (t->status & (8 | 16)) {
            RemoveFromReadyList(ht);
            t->priority = priority;
            InsertIntoReadyList(ht);
        }
        else
            t->priority = priority;
        UnlockSemaphore(&sys_sema);
    }
    return E_Ok;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

void FMTKInitialize()
{
	int nn,jj;

    asm { mfspr r1,ivno };
//    firstcall
    {
        asm {
            ldi   r1,#20
            sc    r1,LEDS
        }
        hasUltraHighPriorityTasks = 0;
        missed_ticks = 0;

        IOFocusTbl[0] = 0;
        IOFocusNdx = (void *)0;
        iof_switch = 0;

        UnlockSemaphore(&sys_sema);
        UnlockSemaphore(&iof_sema);
        UnlockSemaphore(&kbd_sema);

        for (nn = 0; nn < 16384; nn++) {
            message[nn].link = nn+1;
        }
        message[16384-1].link = -1;
        freeMSG = 0;

        asm {
            ldi   r1,#30
            sc    r1,LEDS
        }

        for (nn = 0; nn < 51; nn++) {
            jcbs[nn].number = nn;
            for (jj = 0; jj < 8; jj++)
                jcbs[nn].tasks[jj] = -1;
            if (nn == 0 ) {
                jcbs[nn].pVidMem = 0xFFD00000;
                jcbs[nn].pVirtVidMem = video_bufs[nn];
                jcbs[nn].NormAttr = 0x0026B800;
                RequestIOFocus(&jcbs[0]);
           }
            else {
                 jcbs[nn].pVidMem = video_bufs[nn];
                 jcbs[nn].pVirtVidMem = video_bufs[nn];
                 jcbs[nn].NormAttr = 0x0026B800;
            }
            jcbs[nn].VideoRows = 31;
            jcbs[nn].VideoCols = 84;
            jcbs[nn].CursorRow = 0;
            jcbs[nn].CursorCol = 0;
            jcbs[nn].KeybdHead = 0;
            jcbs[nn].KeybdTail = 0;
            jcbs[nn].KeyState1 = 0;
            jcbs[nn].KeyState2 = 0;
        }

        asm {
            ldi   r1,#40
            sc    r1,LEDS
        }

    	for (nn = 0; nn < 8; nn++)
    		readyQ[nn] = -1;
    	for (nn = 0; nn < 256; nn++) {
            tcbs[nn].number = nn;
    		tcbs[nn].next = nn+1;
    		tcbs[nn].prev = -1;
    		tcbs[nn].status = 0;
    		tcbs[nn].priority = 070;
    		tcbs[nn].affinity = 0;
    		tcbs[nn].sys_stack = &sys_stacks[nn] + 511;
    		tcbs[nn].bios_stack = &bios_stacks[nn] + 511;
    		tcbs[nn].stack = &stacks[nn] + 1023;
    		tcbs[nn].hJob = 0;
    		tcbs[nn].timeout = 0;
    		tcbs[nn].hMailboxes[0] = -1;
    		tcbs[nn].hMailboxes[1] = -1;
    		tcbs[nn].hMailboxes[2] = -1;
    		tcbs[nn].hMailboxes[3] = -1;
    		if (nn<2) {
                tcbs[nn].affinity = nn;
                tcbs[nn].priority = 030;
            }
            tcbs[nn].exception = 0;
    	}
    	tcbs[256-1].next = -1;
    	freeTCB = 2;
        asm {
            ldi   r1,#42
            sc    r1,LEDS
        }
    	InsertIntoReadyList(0);
    	InsertIntoReadyList(1);
    	tcbs[0].status = 8;
    	tcbs[1].status = 8;
        asm {
            ldi   r1,#44
            sc    r1,LEDS
        }
    	SetRunningTCB(0);
    	TimeoutList = -1;
    	set_vector(4,FMTK_SystemCall);
    	set_vector(2,FMTK_SchedulerIRQ);
    	set_vector(451,FMTK_SchedulerIRQ);
    	FMTK_StartTask(030, 0, shell, 0, 0);
        FMTK_StartTask(077, 0, IdleTask, 0, 0);
        FMTK_StartTask(077, 1, IdleTask, 0, 0);
    	FMTK_Inited = 0x12345678;
        asm {
            ldi   r1,#50
            sc    r1,LEDS
        }
    }
}

