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
robot=SerialLink([SL1 SL2 SL3 SL4 SL5 SL6],'name','standard');

Q_zero = [0,0,0,0,90,0];%���� -> ץ��
Angle_Last = Q_zero + [0,90,0,0,0,0];
pose_start = Fkine_Final(Q_zero)%����

%ƽ��
trans = [1  0  0  0;
         0  1  0  0;
         0  0  1  -0.2;
         0  0  0  1;];
pose_end = trans*pose_start;

% x = linemove(pose_start(1,4),pose_end(1,4));
% y = linemove(pose_start(2,4),pose_end(2,4));
z = linemove(pose_start(3,4),pose_end(3,4));

for i = 1:50
    pose_end(3,4) = z(i);
    q(i,:) = Ikine_Step(pose_end,Q_zero);%����
end

for i = 1:50
    q(i,:) = q(i,:).*[pi/180,pi/180,pi/180,pi/180,pi/180,pi/180];
    figure(3);
    plot3(pose_end(1,4),pose_end(2,4),pose_end(3,4) + z(i));
    robot.plot(q(i,:));
end

