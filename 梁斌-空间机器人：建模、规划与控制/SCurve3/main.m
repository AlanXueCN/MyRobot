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
robot=SerialLink([SL1 SL2 SL3 SL4 SL5 SL6],'name','standard');

% robot = importrobot('Test_Link6.urdf');%���������������ʽ
% robot.DataFormat='column';%���ݸ�ʽΪ�У�rowΪ�У�Ϊ��row'ʱq0Ҫת��-->q0��
% robot.Gravity = [0 0 -9.80];%������������


Q_zero = [0,0,0,0,90,0];%���� -> ץ��
% robot.jacob0(Q_zero)

Angle_Last = Q_zero + [0,90,0,0,0,0];
pose_start = Fkine_Final(Q_zero)%����

%ƽ��
trans = [1  0  0  0.1;
         0  1  0 -0.2;
         0  0  1 -0.3;
         0  0  0  1;];
pose_end = trans*pose_start

%�⺯��
% N = 50;
% T=ctraj(pose_start,pose_end,50);
% x(1,:) = T(1,4,:);
% y(1,:) = T(2,4,:);
% z(1,:) = T(3,4,:);
% plot3(x,y,z,'r'),xlabel('x'),ylabel('y'),zlabel('z'),hold on,plot3(x,y,z,'o','color','g'),grid on;


v = 0.1;%�˶��ٶ�0.1m/s
a = 0.03;%���ٶ� 0.01�ӽ����Ǻ���
t = 0.1;%�岹����10ms��plc���ڣ�
L = sqrt(trans(1,4)^2 + trans(2,4)^2 + trans(3,4)^2);%distance
N = ceil(L/(v*t)) + 1;%�岹����

s = linemove(0,1,v,a,N);

for i = 1:N
x(i) = pose_start(1,4) + trans(1,4)*s(i);
y(i) = pose_start(2,4) + trans(2,4)*s(i);
z(i) = pose_start(3,4) + trans(3,4)*s(i);
end


figure(2);
% plot3(x,y,z,'r'),xlabel('x'),ylabel('y'),zlabel('z'),hold on,plot3(x,y,z,'o','color','g'),grid on;

for i = 1:N
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

subplot(2,2,1),plot(q(:,i));
hold on;
subplot(2,2,2),plot(v);
hold on;
subplot(2,2,3),plot(a);
hold on;
subplot(2,2,4),plot(aa);
hold on;
end

figure(3);
% plot3(x(1,:),y(1,:),z(1,:),'color',[1,0,0],'LineWidth',2);
plot3(x,y,z,'r'),xlabel('x'),ylabel('y'),zlabel('z'),hold on,plot3(x,y,z,'o','color','g'),grid on;
q1 = zeros(N,8);%λ��-->���ؽ�Ϊ����ֵ,8�������ؽ��˶�.

for i = 1:N
%     q(i,:) = q(i,:).*[-pi/180,-pi/180,-pi/180,pi/180,pi/180,pi/180];
    q(i,:) = q(i,:).*[pi/180,pi/180,pi/180,pi/180,pi/180,pi/180];
    robot.plot(q(i,:));
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

% for i = 1:50   
%     drawnow
%     show(robot,q1(i,:)','PreservePlot',false);
%     view([150 6]);%figure��С����
% %     axis([-0.6 0.6 -0.6 0.6 0 1.35]);%���귶Χ
%     camva('auto');%��������ӽ�
%     daspect([1 1 1]);%������ÿ��������ݵ�λ����,Ҫ�����з����ϲ�����ͬ�����ݵ�λ���ȣ�ʹ�� [1 1 1]
%     
%     frame = getframe(figure(3)); 
%     im = frame2im(frame); 
%     [imind,cm] = rgb2ind(im,256);
%     if i == 1
%         imwrite(imind,cm,'robot.gif','gif','WriteMode','overwrite', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,'robot.gif','gif','WriteMode','append','DelayTime',0.2);
%     end
% end


