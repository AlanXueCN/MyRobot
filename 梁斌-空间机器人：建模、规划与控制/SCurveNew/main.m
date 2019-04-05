clear;
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
robot=SerialLink([SL1 SL2 SL3 SL4 SL5 SL6],'name','SD700E');

% robot = importrobot('Test_Link6.urdf');%���������������ʽ
% robot.DataFormat='column';%���ݸ�ʽΪ�У�rowΪ�У�Ϊ��row'ʱq0Ҫת��-->q0��
% robot.Gravity = [0 0 -9.80];%������������


Q_zero = [0,0,0,0,90,0];%���� -> ץ��
% robot.jacob0(Q_zero)

Angle_Last = Q_zero + [0,90,0,0,0,0];
pose_start = Fkine_Final(Q_zero)%����

%ƽ��
trans = [1  0  0  0.2;
         0  1  0  0.2;
         0  0  1 -0.4;
         0  0  0  1;];
pose_end = trans*pose_start;

%�ѿ���ƽ���˶�Լ��
% Cv = 1;
% Ca = 5;
% Cj = 50;
Cv = 0.8;
Ca = 2;
Cj = 20;
%�ѿ�����ת�˶�Լ��
% Cvr = 90 ;
% Car = 270 ;
% Cjr = 2700 ;
%��������
StepT = 0.02; 

Vs = 0;
Ve = 0;
Vset = Cv;

[T1, Td1, Time1] = MoveLine(Cv, Ca, Cj, pose_start, pose_end, Vs, Ve, Vset, StepT);

for i = 1:3
    for j = 1:length(T1)
    s(j) = T1(i,4,j); 
    end
    v = diff(s);
    a = diff(v);
    aa = diff(a);
    subplot(2,2,1);
    plot(s);
    hold on;
    subplot(2,2,2);
    plot(v);
    hold on;
    subplot(2,2,3);
    plot(a);
    hold on;
    subplot(2,2,4);
    plot(aa);
    hold on;
end

x = T1(1,4,:);
y = T1(2,4,:);
z = T1(3,4,:);
% x = linemove(pose_start(1,4),pose_end(1,4),0.2,0.3);
% y = linemove(pose_start(2,4),pose_end(2,4),0.2,0.3);
% z = linemove(pose_start(3,4),pose_end(3,4),0.2,0.3);

for i = 1:length(T1)
    pose_end(1,4) = x(i);
    pose_end(2,4) = y(i);
    pose_end(3,4) = z(i);
    q(i,:) = Ikine_Step(pose_end,Q_zero);%����
end

figure(2);
for i = 1:6
    v = diff(q(:,i));
    a = diff(v);
    aa = diff(a);
    subplot(2,2,1);
    plot(q(:,i));
    hold on;
    subplot(2,2,2);
    plot(v);
    hold on;
    subplot(2,2,3);
    plot(a);
    hold on;
    subplot(2,2,4);
    plot(aa);
    hold on;
end

figure(3);
plot3(x(1,:),y(1,:),z(1,:),'color',[1,0,0],'LineWidth',2);
% hold on;
% plot3(x(1,:),y(1,:),z(1,:),'o','color','g'),grid on;

q1 = zeros(length(q),8);%λ��-->���ؽ�Ϊ����ֵ,8�������ؽ��˶�.

for i = 1:length(q)
    q(i,:) = q(i,:).*[pi/180,pi/180,pi/180,pi/180,pi/180,pi/180];
    robot.plot(q(i,:));
%     q(i,:) = q(i,:).*[-pi/180,-pi/180,-pi/180,pi/180,pi/180,pi/180];
%     q1(i,1:6) = q(i,:);
%     frame = getframe(figure(3)); 
%     im = frame2im(frame); 
%     [imind,cm] = rgb2ind(im,256);
%     if i == 1
%         imwrite(imind,cm,'robot1.gif','gif','WriteMode','overwrite', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,'robot1.gif','gif','WriteMode','append','DelayTime',0.2);
%     end
end

% for i = 1:length(q)   
%     drawnow
%     show(robot,q1(i,:)','PreservePlot',false);
%     view([150 6]);%figure��С����
% %     axis([-0.6 0.6 -0.6 0.6 0 1.35]);%���귶Χ
%     camva('auto');%��������ӽ�
%     daspect([1 1 1]);%������ÿ��������ݵ�λ����,Ҫ�����з����ϲ�����ͬ�����ݵ�λ���ȣ�ʹ�� [1 1 1]
%     
% %     frame = getframe(figure(3)); 
% %     im = frame2im(frame); 
% %     [imind,cm] = rgb2ind(im,256);
% %     if i == 1
% %         imwrite(imind,cm,'robot.gif','gif','WriteMode','overwrite', 'Loopcount',inf);
% %     else
% %         imwrite(imind,cm,'robot.gif','gif','WriteMode','append','DelayTime',0.2);
% %     end
% end


