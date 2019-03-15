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

%zero
Q_zero = [0,-90,0,0,0,0];%ץ��- > ����

Q_zero = Q_zero(end:-1:1);
%�����Ƕ�
Q_bias = [1,-1,-1,1,1,-1];
Q_zero = Q_zero .* Q_bias;
%����
RobotPose=Fkine_Step(Q_zero);%��д���⺯��

% RobotPose(3,4) = 0.4297;%z
% %�趨��
%RobotPose(1,4) = 0.5246;%z
%�趨��
% RobotPose(2,4) = 0.2;%z
%�趨��

Q_last = [0,0,0,0,0,0];
%����
Q_Ikine = Ikine_Step(RobotPose,Q_last);
RobotPose = Fkine_Step(Q_Ikine)%��д���⺯��

%�����Ƕ�
Q_bias = [1,-1,-1,1,1,-1];
Q_Ikine = Q_Ikine .* Q_bias
% 
% %��ʾ
Q_plot= Q_Ikine .* [pi/180,pi/180,pi/180,pi/180,-pi/180,pi/180] + [0,-pi/2,0,0,0,0];
starobot.plot(Q_plot);


%teach(starobot);
% PS:�����д�ĺ�����������DHģ�͡�
% alpha:����Ť�ǣ� 
% a:���˳��ȣ� 
% theta:�ؽ�ת�ǣ� 
% d:�ؽ�ƫ�ƣ� 
% offset:ƫ��