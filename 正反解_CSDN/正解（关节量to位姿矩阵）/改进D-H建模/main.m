clear;
clc;
%����������ģ��
%       theta    d           a        alpha     offset
ML1=Link([0       0.28        0           0          0     ],'modified'); 
ML2=Link([0       0           0.34966093 -pi/2       0     ],'modified');
ML3=Link([0       0           0           0          0     ],'modified');
ML4=Link([0       0.35014205  0          -pi/2       0     ],'modified');
ML5=Link([0       0           0           pi/2       0     ],'modified');
ML6=Link([0       0.0745      0          -pi/2       0     ],'modified');
modrobot=SerialLink([ML1 ML2 ML3 ML4 ML5 ML6],'name','PUMA 560');
modt06=modrobot.fkine([0,0,0,0,pi/2,0]) %���������⺯��
modmyt06=myfkine(0,0,0,0,pi/2,0)        %��д�����⺯��
modrobot.plot([0,0,0,0,pi/2,0]);
%PS:�����д�ĺ����������ڸĽ�DHģ�͡�
% alpha:����Ť�ǣ� 
% a:���˳��ȣ� 
% theta:�ؽ�ת�ǣ� 
% d:�ؽ�ƫ�ƣ� 
% offset:ƫ��