// TI File $Revision: /main/8 $
// Checkin $Date: June 25, 2008   15:19:07 $
//###########################################################################
//
// FILE:	DSP2833x_ECan.c
//
// TITLE:	DSP2833x Enhanced CAN Initialization & Support Functions.
//
//###########################################################################
// $TI Release: DSP2833x/DSP2823x Header Files V1.20 $
// $Release Date: August 1, 2008 $
//###########################################################################

#include "DSP2833x_Device.h"     // DSP2833x Headerfile Include File
#include "DSP2833x_Examples.h"   // DSP2833x Examples Include File


//---------------------------------------------------------------------------
// InitECan:
//---------------------------------------------------------------------------
// This function initializes the eCAN module to a known state.
//
void InitECan(void)
{
   InitECana();
#if DSP28_ECANB
   InitECanb();
#endif // if DSP28_ECANB
}


void InitECana(void)		// Initialize eCAN-A module
{
	struct ECAN_REGS ECanaShadow; //�ݴ����
//	Uint32  datatemp = 0;


	EALLOW;
/* Configure eCAN pins for CAN operation using GPIO regs*/

    ECanaShadow.CANTIOC.all = ECanaRegs.CANTIOC.all;
    ECanaShadow.CANTIOC.bit.TXFUNC = 1;
    ECanaRegs.CANTIOC.all = ECanaShadow.CANTIOC.all;

    ECanaShadow.CANRIOC.all = ECanaRegs.CANRIOC.all;
    ECanaShadow.CANRIOC.bit.RXFUNC = 1;
    ECanaRegs.CANRIOC.all = ECanaShadow.CANRIOC.all;
	EDIS;

/* Configure eCAN for HECC mode - (reqd to access mailboxes 16 thru 31) */
//	HECC mode also enables time-stamping feature
	EALLOW;
	ECanaShadow.CANMC.all = ECanaRegs.CANMC.all;
	ECanaShadow.CANMC.bit.STM = 0;   //1--*****�Բ���ģʽ,0 normal mode
	ECanaShadow.CANMC.bit.SCB = 1;   //CANMC��SCBΪ1��������eCANģʽ
	ECanaRegs.CANMC.all = ECanaShadow.CANMC.all;
	EDIS;
	
	ECanaMboxes.MBOX0.MSGCTRL.all = 0x00000000;
	ECanaMboxes.MBOX3.MSGCTRL.all = 0x00000000;
	ECanaMboxes.MBOX4.MSGCTRL.all = 0x00000000;	

// TAn, RMPn, GIFn bits are all zero upon reset and are cleared again
// as a matter of precaution.

/* Clear all TAn bits */

	ECanaRegs.CANTA.all	= 0xFFFFFFFF;

/* Clear all RMPn bits */

	ECanaRegs.CANRMP.all = 0xFFFFFFFF;

/* Clear all interrupt flag bits */

	ECanaRegs.CANGIF0.all = 0xFFFFFFFF;
	ECanaRegs.CANGIF1.all = 0xFFFFFFFF;

/* Configure bit timing parameters */
	EALLOW;
	ECanaShadow.CANMC.all = ECanaRegs.CANMC.all; //CANMC--Master control 
	//Programming CCR (CANMC.12) = 1 sets the initialization mode.
	ECanaShadow.CANMC.bit.CCR = 1;  //���øı�����CCR, reset mode
	ECanaShadow.CANMC.bit.DBO = 1; 	// 1 for LSB, 0 for MSB
	ECanaRegs.CANMC.all = ECanaShadow.CANMC.all;
	EDIS;
	
	do
	{
		ECanaShadow.CANES.all = ECanaRegs.CANES.all; //Error and Status Register
	}while(ECanaShadow.CANES.bit.CCE != 1);  //CCE--Change configuration enable.

	EALLOW;
	ECanaShadow.CANBTC.all = 0;
    ECanaShadow.CANBTC.bit.BRPREG =5;//39;			   //brp=9, (BRP + 1) = 10 feeds a 15 MHz CAN clock
    ECanaShadow.CANBTC.bit.TSEG2REG = 3;//5 ;         // to the CAN module. (150 / 10 = 15)
    ECanaShadow.CANBTC.bit.TSEG1REG = 4;//7;          // Bit time = 15,,250Kbps
	ECanaShadow.CANBTC.bit.SJWREG = 0;//4			//add by moyang
//    ECanaShadow.CANBTC.bit.SAM = 1;					//add by moyang
    ECanaRegs.CANBTC.all = ECanaShadow.CANBTC.all;
	EDIS;

	// -----@@--------
	//eCANÿ�����䶼���Լ��ľֲ��������μĴ���LAM0-LAM31
	//�ڱ�׼CANģʽ�£��ֲ��������μĴ���LAM0��Ϊ����0-2ʹ��
	//�ڱ�׼CANģʽ�£��ֲ��������μĴ���LAM1��Ϊ����3-5ʹ��
   	//�ڱ�׼CANģʽ�£�����6-15��ʹ��"ȫ��"���μĴ��CANGAM����ƥ�����Ϣ��������������������
	//ʹ��"ȫ��"���μĴ���CANGAM����ƥ�����Ϣ��������������������
   // There is no global-acceptance mask in the eCAN.
   //The selection of the mask to be used for the comparison depends on which mode (SCC or eCAN) is used.
	EALLOW;										  
	ECanaLAMRegs.LAM0.all=0xffffffff; //yzg, �ֲ��������μĴ���,receive remote 
	ECanaLAMRegs.LAM3.all=0xffffffff; //receive box,need id match
	ECanaLAMRegs.LAM4.all=0xffffffff;	//transmit box

 	ECanaShadow.CANMC.all = ECanaRegs.CANMC.all;
	ECanaShadow.CANMC.bit.SUSP = 1;  // emulation will not affect DSP
    ECanaShadow.CANMC.bit.CCR = 0 ;            // Set CCR = 0
    ECanaRegs.CANMC.all = ECanaShadow.CANMC.all;
	EDIS;

	do
	{
		ECanaShadow.CANES.all = ECanaRegs.CANES.all;
	}while(ECanaShadow.CANES.bit.CCE != 0);

EALLOW;
 	ECanaRegs.CANME.all = 0;		// Required before writing the MSGIDs
EDIS;

// ��������
/*�����ID��,mailbox0 receives romote frame,mailbox3 receives data frame, mailbox4 sends data frame */ 
 	ECanaMboxes.MBOX0.MSGID.bit.AME = 1;//AME=1, DSP node =0
	ECanaMboxes.MBOX0.MSGID.bit.STDMSGID = 0x0;

 	ECanaMboxes.MBOX3.MSGID.bit.IDE = 0;	// CAN2.0A
 	ECanaMboxes.MBOX3.MSGID.bit.AME=1; 
	ECanaMboxes.MBOX3.MSGID.bit.STDMSGID =0x007;

// ��������
	ECanaMboxes.MBOX4.MSGID.bit.STDMSGID = 0x307;
	ECanaMboxes.MBOX4.MSGID.bit.IDE=0;
	ECanaMboxes.MBOX4.MSGID.bit.AAM=0;//����Ӧ��Զ������	

//	ECanaRegs.CANMD.all = 0xFFFF0000; //CANMD--���䷽��Ĵ��� /*0~15 is TX,16~31 is RX*/
	ECanaShadow.CANMD.all = ECanaRegs.CANMD.all;
	ECanaShadow.CANMD.bit.MD0 = 1;
	ECanaShadow.CANMD.bit.MD3 = 1;
	ECanaShadow.CANMD.bit.MD4 = 0;
	ECanaRegs.CANMD.all = ECanaShadow.CANMD.all; //CANMD--���䷽��Ĵ���,R: box0,box3,T:box4


	/*���ݳ��� 8��BYTE*/
	ECanaMboxes.MBOX0.MSGCTRL.bit.DLC = 0;
	ECanaMboxes.MBOX3.MSGCTRL.bit.DLC = 8;
	ECanaMboxes.MBOX4.MSGCTRL.bit.DLC = 8;

			
	/*û��Զ��Ӧ��֡������*/
	ECanaMboxes.MBOX0.MSGCTRL.bit.RTR = 0;  //MSGCTRL--MSGCTRL��Ϣ���ƼĴ���
	ECanaMboxes.MBOX3.MSGCTRL.bit.RTR = 0;
	ECanaMboxes.MBOX4.MSGCTRL.bit.RTR = 0;
	
	EALLOW;
	/*32������ʹ��*/
	ECanaRegs.CANGAM.all= 0x80000000; //AMI=1;
	ECanaRegs.CANME.bit.ME0 = 1;
	ECanaRegs.CANME.bit.ME3 = 1;
	ECanaRegs.CANME.bit.ME4 = 1; //Enable box0,3,4,-����ʹ�ܼĴ���
	EDIS;

	EALLOW;
	/*�����ж�ʹ��*/
	ECanaShadow.CANMIM.bit.MIM0 = 1; //0xFFFFffff; mail box interrupt enabled
	ECanaShadow.CANMIM.bit.MIM3 = 1;
	ECanaShadow.CANMIM.bit.MIM4 = 1;
	ECanaRegs.CANMIM.all = ECanaShadow.CANMIM.all;
	 // receiving box 0,3 can generate interrupt, box 4 is prohibited
	ECanaShadow.CANMIL.all = 0xFFFFFFFF;  //Generate to ECAN0INT, Mailbox Interrupt Level Register
	ECanaShadow.CANMIL.bit.MIL0=0;
	ECanaShadow.CANMIL.bit.MIL3=0;
	ECanaRegs.CANMIL.all=ECanaShadow.CANMIL.all;
	ECanaRegs.CANGIF0.all = 0xFFFFFFFF; //Global Interrupt Flag 0 Register\
	ECanaRegs.CANGIM.all = 0;
	ECanaRegs.CANGIM.bit.I0EN = 1; //Global Interrupt Mask Register,�ж�0ʹ��
//	ECanaRegs.CANGIM.bit.I1EN = 1; //�ж�1ʹ��
//	ECanaRegs.CANGIM.all = 0x3ff07; //����TCOF,WDIF,WUIF,BOIF,EPIF,WLIFȫ���ж�ӳ�䵽ECAN1INT��
	EDIS;
//	PieVectTable.ECAN0INTA=&ISR_ECAN0INTA;
//	PieVectTable.ECAN1INTA=&ISR_ECAN1INTA;
//	PieCtrl.PIEIER9.bit.INTx6 = 1; //PIE,INT9��ʹ�ܼĴ�����ECAN1INT
//	PieCtrl.PIEIER9.bit.INTx5 = 1; //PIE,INT9��ʹ�ܼĴ�����ECAN0INT
//	IER |=M_INT9;

	
}


#if (DSP28_ECANB)
void InitECanb(void)		// Initialize eCAN-B module
{
/* Create a shadow register structure for the CAN control registers. This is
 needed, since only 32-bit access is allowed to these registers. 16-bit access
 to these registers could potentially corrupt the register contents or return
 false data. This is especially true while writing to/reading from a bit
 (or group of bits) among bits 16 - 31 */

struct ECAN_REGS ECanbShadow;

   EALLOW;		// EALLOW enables access to protected bits

/* Configure eCAN RX and TX pins for CAN operation using eCAN regs*/

    ECanbShadow.CANTIOC.all = ECanbRegs.CANTIOC.all;
    ECanbShadow.CANTIOC.bit.TXFUNC = 1;
    ECanbRegs.CANTIOC.all = ECanbShadow.CANTIOC.all;

    ECanbShadow.CANRIOC.all = ECanbRegs.CANRIOC.all;
    ECanbShadow.CANRIOC.bit.RXFUNC = 1;
    ECanbRegs.CANRIOC.all = ECanbShadow.CANRIOC.all;

/* Configure eCAN for HECC mode - (reqd to access mailboxes 16 thru 31) */

	ECanbShadow.CANMC.all = ECanbRegs.CANMC.all;
	ECanbShadow.CANMC.bit.SCB = 1;
	ECanbRegs.CANMC.all = ECanbShadow.CANMC.all;

/* Initialize all bits of 'Master Control Field' to zero */
// Some bits of MSGCTRL register come up in an unknown state. For proper operation,
// all bits (including reserved bits) of MSGCTRL must be initialized to zero

    ECanbMboxes.MBOX0.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX1.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX2.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX3.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX4.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX5.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX6.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX7.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX8.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX9.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX10.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX11.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX12.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX13.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX14.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX15.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX16.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX17.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX18.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX19.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX20.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX21.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX22.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX23.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX24.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX25.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX26.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX27.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX28.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX29.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX30.MSGCTRL.all = 0x00000000;
    ECanbMboxes.MBOX31.MSGCTRL.all = 0x00000000;

// TAn, RMPn, GIFn bits are all zero upon reset and are cleared again
//	as a matter of precaution.

	ECanbRegs.CANTA.all	= 0xFFFFFFFF;	/* Clear all TAn bits */

	ECanbRegs.CANRMP.all = 0xFFFFFFFF;	/* Clear all RMPn bits */

	ECanbRegs.CANGIF0.all = 0xFFFFFFFF;	/* Clear all interrupt flag bits */
	ECanbRegs.CANGIF1.all = 0xFFFFFFFF;


/* Configure bit timing parameters for eCANB*/

	ECanbShadow.CANMC.all = ECanbRegs.CANMC.all;
	ECanbShadow.CANMC.bit.CCR = 1 ;            // Set CCR = 1
    ECanbRegs.CANMC.all = ECanbShadow.CANMC.all;

    ECanbShadow.CANES.all = ECanbRegs.CANES.all;

    do
	{
	    ECanbShadow.CANES.all = ECanbRegs.CANES.all;
	} while(ECanbShadow.CANES.bit.CCE != 1 ); 		// Wait for CCE bit to be  cleared..


    ECanbShadow.CANBTC.all = 0;

 //   #if (CPU_FRQ_150MHZ)                       // CPU_FRQ_150MHz is defined in DSP2833x_Examples.h
	/* The following block for all 150 MHz SYSCLKOUT (75 MHz CAN clock) - default. Bit rate = 1 Mbps
	   See Note at end of file */
//		ECanbShadow.CANBTC.bit.BRPREG = 4;
//		ECanbShadow.CANBTC.bit.TSEG2REG = 2;
//		ECanbShadow.CANBTC.bit.TSEG1REG = 10;
//	#endif
//	#if (CPU_FRQ_100MHZ)                       // CPU_FRQ_100MHz is defined in DSP2833x_Examples.h
	/* The following block is only for 100 MHz SYSCLKOUT (50 MHz CAN clock). Bit rate = 1 Mbps
	   See Note at end of file */
//	    ECanbShadow.CANBTC.bit.BRPREG = 4;
//		ECanbShadow.CANBTC.bit.TSEG2REG = 1;
//		ECanbShadow.CANBTC.bit.TSEG1REG = 6;
//	#endif
	
	 //120M
 	EALLOW;
	ECanbShadow.CANBTC.all = ECanbRegs.CANBTC.all;
	ECanbShadow.CANBTC.bit.BRPREG = 3;		// (BRPREG + 1) = 10 feeds a 15 MHz CAN clock��500k
	ECanbShadow.CANBTC.bit.TSEG2REG = 5;	// to the CAN module. (150 / 10 = 15)
	ECanbShadow.CANBTC.bit.TSEG1REG = 7;	// Bit time = 15
	ECanbShadow.CANBTC.bit.SJWREG = 0;
	ECanbRegs.CANBTC.all = ECanbShadow.CANBTC.all;
	

    ECanbShadow.CANBTC.bit.SAM = 1;
    ECanbRegs.CANBTC.all = ECanbShadow.CANBTC.all;

    ECanbShadow.CANMC.all = ECanbRegs.CANMC.all;
	ECanbShadow.CANMC.bit.CCR = 0 ;            // Set CCR = 0
    ECanbRegs.CANMC.all = ECanbShadow.CANMC.all;

    ECanbShadow.CANES.all = ECanbRegs.CANES.all;

    do
    {
        ECanbShadow.CANES.all = ECanbRegs.CANES.all;
    } while(ECanbShadow.CANES.bit.CCE != 0 ); 		// Wait for CCE bit to be  cleared..


/* Disable all Mailboxes  */
 	ECanbRegs.CANME.all = 0;		// Required before writing the MSGIDs

    EDIS;
}
#endif // if DSP28_ECANB


//---------------------------------------------------------------------------
// Example: InitECanGpio:
//---------------------------------------------------------------------------
// This function initializes GPIO pins to function as eCAN pins
//
// Each GPIO pin can be configured as a GPIO pin or up to 3 different
// peripheral functional pins. By default all pins come up as GPIO
// inputs after reset.
//
// Caution:
// Only one GPIO pin should be enabled for CANTXA/B operation.
// Only one GPIO pin shoudl be enabled for CANRXA/B operation.
// Comment out other unwanted lines.



void InitECanGpio(void)
{
   InitECanaGpio();
#if (DSP28_ECANB)
   InitECanbGpio();
#endif // if DSP28_ECANB
}

void InitECanaGpio(void)//���ݿ������޸�IO
{
   EALLOW;

/* Enable internal pull-up for the selected CAN pins */
// Pull-ups can be enabled or disabled by the user.
// This will enable the pullups for the specified pins.
// Comment out other unwanted lines.

	GpioCtrlRegs.GPAPUD.bit.GPIO30 = 0;	    // Enable pull-up for GPIO30 (CANRXA)

	GpioCtrlRegs.GPAPUD.bit.GPIO31 = 0;	    // Enable pull-up for GPIO31 (CANTXA)

/* Set qualification for selected CAN pins to asynch only */
// Inputs are synchronized to SYSCLKOUT by default.
// This will select asynch (no qualification) for the selected pins.

    GpioCtrlRegs.GPAQSEL2.bit.GPIO30 = 3;   // Asynch qual for GPIO30 (CANRXA)

/* Configure eCAN-A pins using GPIO regs*/
// This specifies which of the possible GPIO pins will be eCAN functional pins.

	GpioCtrlRegs.GPAMUX2.bit.GPIO30 = 1;	// Configure GPIO30 for CANRXA operation
	GpioCtrlRegs.GPAMUX2.bit.GPIO31 = 1;	// Configure GPIO31 for CANTXA operation

    EDIS;
}

#if (DSP28_ECANB)
void InitECanbGpio(void)
{
   EALLOW;

/* Enable internal pull-up for the selected CAN pins */
// Pull-ups can be enabled or disabled by the user.
// This will enable the pullups for the specified pins.
// Comment out other unwanted lines.

	GpioCtrlRegs.GPAPUD.bit.GPIO8 = 0;	  // Enable pull-up for GPIO8  (CANTXB)
//  GpioCtrlRegs.GPAPUD.bit.GPIO12 = 0;   // Enable pull-up for GPIO12 (CANTXB)
//  GpioCtrlRegs.GPAPUD.bit.GPIO16 = 0;   // Enable pull-up for GPIO16 (CANTXB)
//  GpioCtrlRegs.GPAPUD.bit.GPIO20 = 0;   // Enable pull-up for GPIO20 (CANTXB)

	GpioCtrlRegs.GPAPUD.bit.GPIO10 = 0;	  // Enable pull-up for GPIO10 (CANRXB)
//  GpioCtrlRegs.GPAPUD.bit.GPIO13 = 0;   // Enable pull-up for GPIO13 (CANRXB)
//  GpioCtrlRegs.GPAPUD.bit.GPIO17 = 0;   // Enable pull-up for GPIO17 (CANRXB)
//  GpioCtrlRegs.GPAPUD.bit.GPIO21 = 0;   // Enable pull-up for GPIO21 (CANRXB)

/* Set qualification for selected CAN pins to asynch only */
// Inputs are synchronized to SYSCLKOUT by default.
// This will select asynch (no qualification) for the selected pins.
// Comment out other unwanted lines.

    GpioCtrlRegs.GPAQSEL1.bit.GPIO10 = 3; // Asynch qual for GPIO10 (CANRXB)
//  GpioCtrlRegs.GPAQSEL1.bit.GPIO13 = 3; // Asynch qual for GPIO13 (CANRXB)
//  GpioCtrlRegs.GPAQSEL2.bit.GPIO17 = 3; // Asynch qual for GPIO17 (CANRXB)
//  GpioCtrlRegs.GPAQSEL2.bit.GPIO21 = 3; // Asynch qual for GPIO21 (CANRXB)

/* Configure eCAN-B pins using GPIO regs*/
// This specifies which of the possible GPIO pins will be eCAN functional pins.

	GpioCtrlRegs.GPAMUX1.bit.GPIO8 = 2;   // Configure GPIO8 for CANTXB operation
//  GpioCtrlRegs.GPAMUX1.bit.GPIO12 = 2;  // Configure GPIO12 for CANTXB operation
//  GpioCtrlRegs.GPAMUX2.bit.GPIO16 = 2;  // Configure GPIO16 for CANTXB operation
//  GpioCtrlRegs.GPAMUX2.bit.GPIO20 = 3;  // Configure GPIO20 for CANTXB operation

	GpioCtrlRegs.GPAMUX1.bit.GPIO10 = 2;  // Configure GPIO10 for CANRXB operation
//  GpioCtrlRegs.GPAMUX1.bit.GPIO13 = 2;  // Configure GPIO13 for CANRXB operation
//  GpioCtrlRegs.GPAMUX2.bit.GPIO17 = 2;  // Configure GPIO17 for CANRXB operation
//  GpioCtrlRegs.GPAMUX2.bit.GPIO21 = 3;  // Configure GPIO21 for CANRXB operation

    EDIS;
}
#endif // if DSP28_ECANB

/*
Note: Bit timing parameters must be chosen based on the network parameters such
as the sampling point desired and the propagation delay of the network.
The propagation delay is a function of length of the cable, delay introduced by
the transceivers and opto/galvanic-isolators (if any).

The parameters used in this file must be changed taking into account the above
mentioned factors in order to arrive at the bit-timing parameters suitable
for a network.

*/
