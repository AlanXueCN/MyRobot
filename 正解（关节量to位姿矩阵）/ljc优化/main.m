clear;
clc;
%����������ģ��
%       theta    d           a              alpha     offset
SL1=Link([0       0.28        0             -pi/2        0     ],'standard'); 
SL2=Link([0       0           0.34966093     0           0     ],'standard');
SL3=Link([0       0           0             -pi/2        0     ],'standard');
SL4=Link([0       0.35014205  0              pi/2        0     ],'standard');
SL5=Link([0       0           0             -pi/2        0     ],'standard');
SL6=Link([0       0.0745      0              0           0     ],'standard');
starobot=SerialLink([SL1 SL2 SL3 SL4 SL5 SL6],'name','standard');
% Q_zero = [0,-pi/2,0,0,0,0];
% starobot.plot(Q_zero);%zero
% stat06=starobot.fkine(Q_zero)%���������⺯��
Q_zero = [0,0,0,0,0,0];
stamyt06=Fkine_Step(Q_zero)%��д���⺯��
%teach(starobot);
% PS:�����д�ĺ�����������DHģ�͡�
% alpha:����Ť�ǣ� 
% a:���˳��ȣ� 
% theta:�ؽ�ת�ǣ� 
% d:�ؽ�ƫ�ƣ� 
% offset:ƫ��