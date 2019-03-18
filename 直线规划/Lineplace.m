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
SL2.offset = -pi/2;%��ʵ�ʻ�����ԭʼλ�ñ���һ��
starobot=SerialLink([SL1 SL2 SL3 SL4 SL5 SL6],'name','standard');

Q_zero = [0,0,0,0,-90,0];%����- > ץ��
Q_last = [0,0,0,0,0,0];
%�����ԭʼλ��
RobotPose = Fkine_Step(Q_zero);

%ԭʼλ����Ϊ���
T1 = RobotPose;
Q_Start = Ikine_Step(T1,Q_last);%����
%ƽ��
trans = [
    1  0  0   0.1;
    0  1  0  -0.3;
    0  0  1  -0.4;
    0  0  0     1 ];
%�յ�
T2 = trans*RobotPose;
Q_Mid = Ikine_Step(T2,Q_last);%����
%ƽ��
trans = [
    1  0  0   -0.1;
    0  1  0   0.3;
    0  0  1   0.4;
    0  0  0     1 ];
%�յ�
T3 = trans*T2;

%%��ζ���ʽ�滮
%���߶�
for i = 1:6
    q(:,i) = moveL5(Q_Start(i),Q_Mid(i));
end
%ֱ�߶�
for i = 1:3
    Tj2(:,i) = moveL5(T2(i,4),T3(i,4));
end

%����ֱ�߶ιؽ���
for i = 1:length(Tj2)
    T3(1,4) = Tj2(i,1);
    T3(2,4) = Tj2(i,2);
    T3(3,4) = Tj2(i,3);
    q1(i,:) = Ikine_Step(T3,Q_last);
end

%ƴ�����ι켣
qmove = [q;q1];
%��ʾ�岹·��
figure(2);
qplot = qmove;

% for i = 1:length(qplot)
%     qplot(i,5) = qplot(i,5) + 90;
% end 

for i = 1:6     
    plot(qplot(:,i));
    hold on;
end

%�����λ�˱仯�����ڻ�ͼ
for i = 1:length(q)
    T(:,:,i) = Fkine_Step(q(i,:));
    Tj(i,1) = T(1,4,i);
    Tj(i,2) = T(2,4,i);
    Tj(i,3) = T(3,4,i);
end

figure(3);
plot3(Tj(:,1),Tj(:,2),Tj(:,3),'color',[1,0,0],'LineWidth',2);%���ĩ�˹켣
hold on;
plot3(Tj2(:,1),Tj2(:,2),Tj2(:,3),'color',[0,1,0],'LineWidth',2);%���ĩ�˹켣


for i = 1:length(qmove)
    Q_plot = qmove(i,:) .* [pi/180,pi/180,pi/180,pi/180,pi/180,pi/180];%ת����
    starobot.plot(Q_plot);%������ʾ
end

