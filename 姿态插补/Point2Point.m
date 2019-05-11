clear all;
clc;
% ����������ģ��
%       theta    d           a              alpha     offset
SL1=Link([0       0.28        0             -pi/2        0     ],'standard');
SL2=Link([0       0           0.34966093     0           0     ],'standard');
SL3=Link([0       0           0             -pi/2        0     ],'standard');
SL4=Link([0       0.35014205  0              pi/2        0     ],'standard');
SL5=Link([0       0           0             -pi/2        0     ],'standard');
SL6=Link([0       0.0745      0              0           0     ],'standard');
SL2.offset = -pi/2;
robot=SerialLink([SL1 SL2 SL3 SL4 SL5 SL6],'name','standard');
% ����岹����
Q_zero = [0,0,0,0,0,0];%���� -> ץ��
Angle_Last = Q_zero;
pose_start = Fkine_Step(Q_zero)%����
%ƽ��
trans = [1  0  0  -0.2;
         0  1  0  0.3;
         0  0  1  -0.5;
         0  0  0  1;];
Q_rotate = [0,0,0,0,90,0];
rotate = Fkine_Step(Q_rotate);

pose_end = trans*pose_start;
pose_end(1:3,1:3) = rotate(1:3,1:3);

Q_End = Ikine_Step(pose_end,Angle_Last);

v = 0.1;%�˶��ٶ�0.1m/s
a = 0.03;%���ٶ� 0.01�ӽ����Ǻ���
t = 0.1;%�岹����10ms��plc���ڣ�
L = sqrt(trans(1,4)^2 + trans(2,4)^2 + trans(3,4)^2);%distance
N = ceil(L/(v*t)) + 1;%�岹����

s = linemove(0,1,v,a,N);
for i = 1:N
    for j = 1:6
        qout(j,i) = Q_zero(j) + Q_End(j)*s(i);
    end
end

figure(1);
subplot(4,2,1);
for i = 1:6 
    plot(qout(i,:));
    hold on;
end
subplot(4,2,2);
for i = 1:6 
    plot(diff(qout(i,:)));
    hold on;
end
subplot(4,2,3);
for i = 1:6 
    plot(diff(diff(qout(i,:))));
    hold on;
end
subplot(4,2,4);
for i = 1:6 
    plot(diff(diff(diff(qout(i,:)))));
    hold on;
end

figure(2);
for i = 1:N
    qplot = qout(:,i).*[pi/180,pi/180,pi/180,pi/180,pi/180,pi/180]';
    robot.plot(qplot');
end
