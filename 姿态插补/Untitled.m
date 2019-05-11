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
trans = [1  0  0  0;
         0  1  0  0;
         0  0  1  -0.4;
         0  0  0  1;];
pose_end = trans*pose_start

v = 0.2;%�˶��ٶ�0.1m/s
a = 0.2;%���ٶ� 0.01�ӽ����Ǻ���
t = 0.001;%�岹����10ms��plc���ڣ�
L = sqrt(trans(1,4)^2 + trans(2,4)^2 + trans(3,4)^2);%distance
N = ceil(L/(v*t));%�岹����

s = trilinemove(v,a,N,t);

for i = 1:N
x(i) = pose_start(1,4) + trans(1,4)*s(i);
y(i) = pose_start(2,4) + trans(2,4)*s(i);
z(i) = pose_start(3,4) + trans(3,4)*s(i);
end

stepNum = N;

%�ж�·��,ȡ·���̵ģ���Ӱ�췽��
%ŷ����ת��Ԫ��
EulerAngleStart = [0,0,0];
EulerAngleEnd = [0/180*pi,90/180*pi,0/180*pi];
p1_Q =  angle2quat(EulerAngleStart(1),EulerAngleStart(2),EulerAngleStart(3));
p3_Q =  angle2quat(EulerAngleEnd(1),EulerAngleEnd(2),EulerAngleEnd(3));

cosa = p1_Q(1)*p3_Q(1)+p1_Q(2)*p3_Q(2)+p1_Q(3)*p3_Q(3)+p1_Q(4)*p3_Q(4);
if cosa < 0
    p3_Q = -p3_Q;
end

pt_Q = zeros(4,stepNum+1);
AngleOut = zeros(3,stepNum+1);
sina = sqrt(1 - cosa*cosa);
angle = atan2( sina, cosa );

for step = 0:1: stepNum-1
%     k0 = sin((1-step/stepNum)*angle)/sina;
%     k1 = sin(step/stepNum*angle)/sina;
    k0 = sin((1-s(step+1))*angle)/sina;
    k1 = sin(s(step+1)*angle)/sina;
    pt_Q(:,step+1) = (p1_Q*k0 +p3_Q*k1)/norm(p1_Q*k0 + p3_Q*k1);
    q = pt_Q(:,step+1)';
    [AngleOut(1,step+1),AngleOut(2,step+1),AngleOut(3,step+1)] = quat2angle(q);
    AngleOut(:,step+1) = AngleOut(:,step+1)*180/pi;
end

T = zeros(4,4,stepNum);
qout = zeros(1,6,stepNum);
for i = 1:stepNum
    q1 = [0,0,0,AngleOut(1,i),AngleOut(2,i),AngleOut(3,i)];
    T(:,:,i) = Fkine_Step(q1); 
    T(1,4,i) = x(i);
    T(2,4,i) = y(i);
    T(3,4,i) = z(i);
    qout(:,:,i) = Ikine_Step(T(:,:,i),Angle_Last);
end


figure(1);
qplot(:,:) = qout(1,:,:);
for i = 1:6 
    plot(diff(qplot(i,:)));
    hold on;
end

figure(2);
qplot(:,:) = qout(1,:,:);
for i = 1:6 
    plot(qplot(i,:));    
    hold on;
end

figure(3);
for i = 1:stepNum 

end
% for i = 1:stepNum 
%     qout(:,:,i) = qout(:,:,i).*[pi/180,pi/180,pi/180,pi/180,pi/180,pi/180];
%     robot.plot(qout(:,:,i));
% end


