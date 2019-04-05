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
SL2.offset = -pi/2;
robot = SerialLink([SL1 SL2 SL3 SL4 SL5 SL6],'name','SD700');
robot1 = SerialLink([SL1 SL2 SL3 SL4 SL5 SL6],'name','standard');
% robot = importrobot('Test_Link6.urdf');%���������������ʽ
% robot.DataFormat='column';%���ݸ�ʽΪ�У�rowΪ�У�Ϊ��row'ʱq0Ҫת��-->q0��
% robot.Gravity = [0 0 -9.80];%������������
% 
% q1 = [0; 0; 0; 0; 0; 0; 0; 0];%λ��-->���ؽ�Ϊ����ֵ,8�������ؽ��˶�.
% show(robot,q1,'PreservePlot',false);

% view([150 6]);%figure��С����
% axis([-0.6 0.6 -0.6 0.6 0 1.35]);%���귶Χ
% camva('auto');%��������ӽ�
% daspect([1 1 1]);%������ÿ��������ݵ�λ����,Ҫ�����з����ϲ�����ͬ�����ݵ�λ���ȣ�ʹ�� [1 1 1] 


Q_zero1 = [0,0,0,0,90,0];%���� -> ץ��
Angle_Last = Q_zero1 + [0,90,0,0,0,0];
p1 = Fkine_Final(Q_zero1)%����
%ƽ��
trans = [1  0  0  0.1;
         0  1  0 -0.2;
         0  0  1 -0.3;
         0  0  0  1;];
pose_end = trans*p1;
% pose_end = p1;

q1 = Ikine_Step(pose_end,Q_zero1)%����
q2 = q1.*[pi/180,pi/180,pi/180,pi/180,pi/180,pi/180];
figure(1),robot.plot(q2);


% ת����
Q_zero = Q_zero1.* [pi/180,pi/180,pi/180,pi/180,pi/180,pi/180];
p = robot1.fkine(Q_zero);
%ƽ��
p.t = [0.45014205;-0.2;0.25516093];

q = robot1.ikine(pose_end);
figure(2),robot1.plot(q);
q3 = q.*[180/pi,180/pi,180/pi,180/pi,180/pi,180/pi]