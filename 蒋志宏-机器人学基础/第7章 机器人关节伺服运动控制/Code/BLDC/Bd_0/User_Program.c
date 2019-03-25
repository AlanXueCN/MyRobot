#include "DSP28x_Project.h"     // Device Headerfile and Examples Include File
#include "math.h"  


#define sqrt3				1.732050808
#define pi                  3.141592654

//	used in ADC
float Sensor_Coeff[2] = {9.41, 9.41};//����������ϵ��
float Voltage_Offset[2] = {1.31, 1.308};//������������ѹƫ��

float Ia_Current = 0.0;//a�����
float Ib_Current = 0.0;//b�����
float Ia_average = 0.0;//a�����ƽ��
float Ib_average = 0.0;//b�����ƽ��
float Ia_Buffer[5] = {0.0,0.0,0.0,0.0,0.0};//�ɼ����ȡƽ��
float Ib_Buffer[5] = {0.0,0.0,0.0,0.0,0.0};
float min_a, max_a,min_b, max_b,s_a,s_b;//�����˲��м����
float Is_a = 0;
float Is_b = 0;
float Is_c = 0;
float Is=0;
float AdcResult[2];//AD�����������
float AD_Out[2] = {0.0, 0.0};

// used in Control_process
int position_times = 0;//λ�û�����Ƶ��
int velocity_times = 0;//�ٶȻ�����Ƶ��
int current_times = 0;//����������Ƶ��
int mode_choose = 0;//����ģʽѡ��

float iREF;//��������
float iFB;//�������� 
extern float pREF;//λ������
extern float pFB;//λ�÷���
extern float sREF;//�ٶ�����
extern float sFB;//�ٶȷ���


Uint16 i_var = 0;

float pCONTROLLER(void);//λ��PID���ƺ���
float sCONTROLLER(void);//�ٶ�PID���ƺ���
float iCONTROLLER(float iREF,float iFB);//����PID���ƺ���

float Present_Motor_Position = 0.0;//�����ǰλ��
float Position_TEMP = 0.0;


//	used in sCalculation�ٶȼ������ñ���
long Position_Rota[2];
long Position_Rota_joint[2];
int icounter = 0;
float Speed_Current_temp = 0.0;
float Speed_Current_temp_joint = 0.0;
float Speed_Current_joint = 0.0;
int i=0;

int direction;//�����ת����
Uint16 motor_data;//������̶���
float motor_position = 0;//���λ��

int H1_COMMUTATION = 0;   //����
int	H2_COMMUTATION = 0;   
int	H3_COMMUTATION = 0; 
int SP=610;//ռ�ձ�

void RESOLVER_DATCON(void)//���λ�ý���
{

		direction=EQep1Regs.QEPSTS.bit.QDF;
	if(direction==0&&EQep1Regs.QPOSCNT>4000)
		{
			EQep1Regs.QPOSCNT=4000;
		}
	
	motor_data =EQep1Regs.QPOSCNT;

	motor_position = ((float)motor_data*360/4000);


	
}

void DelayForDataReading(void)
{
	asm(" RPT #5 || NOP");   //110 ns
}

void DelayUs(volatile Uint16 Usec)
{
	while(Usec--)
	{
		asm(" RPT #5 || NOP");   //1 us loop at 150 MHz CPUCLK
	}
} 



void ADC(void)//��������
{
	// Start SEQ1 
	AdcRegs.ADCTRL2.all = 0x06000; 
	while (AdcRegs.ADCST.bit.SEQ1_BSY == 1); // Wait for AD Sampling.

 	AdcResult[0] = (float)(AdcRegs.ADCRESULT0>>4);	
    AdcResult[1] = (float)(AdcRegs.ADCRESULT1>>4);

	AD_Out[0] = AdcResult[0]*3.0/4095.0;			//Reference Voltage is 3.0V; 12bit ADC.
	AD_Out[1] = AdcResult[1]*3.0/4095.0;     		
	AdcRegs.ADCTRL2.bit.RST_SEQ1 = 1;	 //Reset SEQ1
    
	Ia_Current = Sensor_Coeff[0] * (AD_Out[0] - Voltage_Offset[0]);		
    Ib_Current = Sensor_Coeff[1] * (AD_Out[1] - Voltage_Offset[1]);	
  

      Ia_Buffer[4] =  Ia_Buffer[3];
      Ia_Buffer[3] =  Ia_Buffer[2];		
      Ia_Buffer[2] =  Ia_Buffer[1];
      Ia_Buffer[1] =  Ia_Buffer[0];
      Ia_Buffer[0] =  Ia_Current;
      
      Ib_Buffer[4] =  Ib_Buffer[3];
      Ib_Buffer[3] =  Ib_Buffer[2];
      Ib_Buffer[2] =  Ib_Buffer[1];
      Ib_Buffer[1] =  Ib_Buffer[0];
      Ib_Buffer[0] =  Ib_Current;


    s_a = min_a = max_a = Ia_Buffer[0];
    for(i = 0; i <5;i++)
    {
        s_a+=Ia_Buffer[i];//��͡�
        if(min_a > Ia_Buffer[i]) min_a = Ia_Buffer[i];//��Сֵ��
        if(max_a < Ia_Buffer[i]) max_a = Ia_Buffer[i];//���ֵ��
    }
    s_a -= min_a+max_a;//ȥ�������С����ֵ��
	Ia_average= s_a/3;   
    
        s_b = min_b = max_b = Ib_Buffer[0];
    for(i = 0; i <5;i++)
    {
        s_b+=Ib_Buffer[i];//��͡�
        if(min_b > Ib_Buffer[i]) min_b = Ib_Buffer[i];//��Сֵ��
        if(max_b < Ib_Buffer[i]) max_b = Ib_Buffer[i];//���ֵ��
    }
    s_b -= min_b+max_b;//ȥ�������С����ֵ��
    Ib_average=s_b/3;
         
	Is_a = Ia_average;
	Is_b = Ib_average;

		
}

void BLDCM_PWM_DRIVER(void)//ֱ����ˢ��������
{
 	EALLOW;
	EPwm1Regs.CMPA.half.CMPA =SP;//����ռ�ձ�
	EPwm2Regs.CMPA.half.CMPA =SP;
	EPwm3Regs.CMPA.half.CMPA =SP;
	EDIS;



	if(H1_COMMUTATION == 0 && H2_COMMUTATION == 1 && H3_COMMUTATION == 0 )//SECTION-1,30~90��:A+,B-
	{
			
	EPwm2Regs.AQCTLA.all= 0x90;      //����PWM2�������        
	EPwm2Regs.AQCSFRC.all=0x00;	
	EPwm2Regs.DBCTL.all=0x0b;

	EPwm1Regs.AQCTLA.all= 0x60;       //����PWM1�������        
	EPwm1Regs.AQCSFRC.all=0x00;	
	EPwm1Regs.DBCTL.all=0x0b;  
   


	EPwm3Regs.AQCTLA.all= 0x00;      //����PWM3�������         
	EPwm3Regs.AQSFRC.all=0x05;	
	EPwm3Regs.DBCTL.all=0x03; 
	
	Is=-Is_a;
	
	}

	else if(H1_COMMUTATION == 0 && H2_COMMUTATION == 1 && H3_COMMUTATION == 1 )//SECTION-1,30~90��:A+,B-
	{
	
	EPwm3Regs.AQCTLA.all= 0x90;             
	EPwm3Regs.AQCSFRC.all=0x00;	
	EPwm3Regs.DBCTL.all=0x0b;

	EPwm1Regs.AQCTLA.all= 0x60;            
	EPwm1Regs.AQCSFRC.all=0x00;	
	EPwm1Regs.DBCTL.all=0x0b;  
   


	EPwm2Regs.AQCTLA.all= 0x00;             
	EPwm2Regs.AQSFRC.all=0x05;	
	EPwm2Regs.DBCTL.all=0x03; 
	
	Is=-Is_a;
	}

	else if(H1_COMMUTATION == 0 && H2_COMMUTATION == 0 && H3_COMMUTATION == 1 )//SECTION-2,90~150��:A+,C-
	{

	
	EPwm3Regs.AQCTLA.all= 0x90;             
	EPwm3Regs.AQCSFRC.all=0x00;	
	EPwm3Regs.DBCTL.all=0x0b;

	EPwm2Regs.AQCTLA.all= 0x60;             
	EPwm2Regs.AQCSFRC.all=0x00;	
	EPwm2Regs.DBCTL.all=0x0b;  
   


	EPwm1Regs.AQCTLA.all= 0x00;             
	EPwm1Regs.AQSFRC.all=0x05;	
	EPwm1Regs.DBCTL.all=0x03; 
	
	Is=-Is_b;
	}


	else if(H1_COMMUTATION == 1 && H2_COMMUTATION == 0 && H3_COMMUTATION == 1 )//SECTION-3,150~210��:B+,C-
	{

	EPwm1Regs.AQCTLA.all= 0x90;             
	EPwm1Regs.AQCSFRC.all=0x00;	
	EPwm1Regs.DBCTL.all=0x0b;

	EPwm2Regs.AQCTLA.all= 0x60;            
	EPwm2Regs.AQCSFRC.all=0x00;	
	EPwm2Regs.DBCTL.all=0x0b;  
   


	EPwm3Regs.AQCTLA.all= 0x00;             
	EPwm3Regs.AQSFRC.all=0x05;	
	EPwm3Regs.DBCTL.all=0x03; 
	
	Is=-Is_b;
	
	
	}

	else if(H1_COMMUTATION == 1 && H2_COMMUTATION == 0 && H3_COMMUTATION == 0 )//SECTION-4,210~270��:A-,B+
	{
	
	EPwm1Regs.AQCTLA.all= 0x90;             
	EPwm1Regs.AQCSFRC.all=0x00;	
	EPwm1Regs.DBCTL.all=0x0b;

	EPwm3Regs.AQCTLA.all= 0x60;             
	EPwm3Regs.AQCSFRC.all=0x00;	
	EPwm3Regs.DBCTL.all=0x0b;  
   


	EPwm2Regs.AQCTLA.all= 0x00;             
	EPwm2Regs.AQSFRC.all=0x05;	
	EPwm2Regs.DBCTL.all=0x03;
	
	Is=Is_a; 
	}

	else if(H1_COMMUTATION == 1 && H2_COMMUTATION == 1 && H3_COMMUTATION == 0 )//SECTION-5,270~330��:A-,C+
	{
		
	EPwm2Regs.AQCTLA.all= 0x90;             
	EPwm2Regs.AQCSFRC.all=0x00;	
	EPwm2Regs.DBCTL.all=0x0b;

	EPwm3Regs.AQCTLA.all= 0x60;             
	EPwm3Regs.AQCSFRC.all=0x00;	
	EPwm3Regs.DBCTL.all=0x0b;  
   


	EPwm1Regs.AQCTLA.all= 0x00;             
	EPwm1Regs.AQSFRC.all=0x05;	
	EPwm1Regs.DBCTL.all=0x03; 
	
	Is=Is_b;
	}

	else;
}


float sCalculation(void)//����ٶȼ���
{
    
    float Speed_Current = 0.0;
    
	Position_Rota[icounter] = motor_data;

	
	icounter++;
	if(icounter == 2)
	{

		Speed_Current_temp = (float)(Position_Rota[1] - Position_Rota[0]);
		if(Speed_Current_temp > 3000) Speed_Current_temp -= 4000;
	    else if(Speed_Current_temp < -3000) Speed_Current_temp += 4000; 

		Position_Rota[0] = Position_Rota[1];
		
	
		icounter = 1;
		
	}
	Speed_Current = (Speed_Current_temp /4000)*5000*2*3.1415;

	return Speed_Current;
}

void Control_process(void)
{
	EALLOW;
 	H1_COMMUTATION = GpioDataRegs.GPADAT.bit.GPIO27;   //�������ź�
	H2_COMMUTATION = GpioDataRegs.GPBDAT.bit.GPIO48;   
	H3_COMMUTATION = GpioDataRegs.GPBDAT.bit.GPIO49;  
	EDIS;

	
	for(i_var=0; i_var<50; i_var++)
   	{
      DelayForDataReading();
   	}	
   	
 	ADC();

pFB = motor_position;
sFB = sCalculation();
iFB=Is;
if(mode_choose==1)	//λ�û�ģʽ����
{
	if(position_times==40)	
	{
	sREF=pCONTROLLER();		

 	position_times=0;
	}	
	position_times++	;	
	
	if(velocity_times==8)	// �ٶȻ�
	{
		
	iREF=sCONTROLLER();

 	velocity_times=0;
	}	
	velocity_times++	;
	
		if(current_times==4)//������	
	{

	SP=iCONTROLLER(iREF,iFB);
	
 	current_times=0;
	}	
	current_times++	;		
		
}
else if(mode_choose==2)	//�ٶȻ�ģʽ����
{

	if(velocity_times==8)	
	{

	iREF=sCONTROLLER();
	
 	velocity_times=0;
	}	
	velocity_times++	;
	
	if(current_times==4)	
	{

	SP=iCONTROLLER(iREF,iFB);
	
 	current_times=0;
	}	
	current_times++	;	
}

else if(mode_choose==3)	//������ģʽ����
{

	if(current_times==4)	
	{

	SP=iCONTROLLER(iREF,iFB);
	
 	current_times=0;
	}	
	current_times++	;	

}
	RESOLVER_DATCON();		
}



