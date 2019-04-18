clear;
clc;
% ����������ģ��
%       theta    d           a              alpha     offset
% SL1=Link([0       0.28        0             -pi/2        0     ],'standard');
% SL2=Link([0       0           0.34966093     0           0     ],'standard');
% SL3=Link([0       0           0             -pi/2        0     ],'standard');
% SL4=Link([0       0.35014205  0              pi/2        0     ],'standard');
% SL5=Link([0       0           0             -pi/2        0     ],'standard');
% SL6=Link([0       0.0745      0              0           0     ],'standard');
% SL2.offset = -pi/2;
% robot=SerialLink([SL1 SL2 SL3 SL4 SL5 SL6],'name','standard');

robot = importrobot('Test_Link6.urdf');%���������������ʽ
robot.DataFormat='column';%���ݸ�ʽΪ�У�rowΪ�У�Ϊ��row'ʱq0Ҫת��-->q0��
robot.Gravity = [0 0 -9.80];%������������


Q_zero = [0,0,0,0,90,0];%���� -> ץ��
% robot.jacob0(Q_zero)

Angle_Last = Q_zero + [0,90,0,0,0,0];
pose_start = Fkine_Final(Q_zero)%����

%ƽ��
trans = [1  0  0  0.2;
         0  1  0  0.2;
         0  0  1 -0.4;
         0  0  0  1;];
pose_end = trans*pose_start


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

%Բ���滮
p1 = [pose_end(1,4),pose_end(2,4),pose_end(3,4)];
p2 = [pose_end(1,4)+0.1,pose_end(2,4)-0.1,pose_end(3,4)];
p3 = [pose_end(1,4),pose_end(2,4)-0.2,pose_end(3,4)];
qCircle = CircleMain(p1,p2,p3,v,a,t);

%����켣Ϊ�뾶Ϊ0.1��Բ
center = [0.45014205,5.55111512312578e-17,0.15516093];
radius = 0.1;
N = ceil(2*pi*radius/(v*t)) + 1;%�岹����
s = linemove(0,1,v,a,N);
theta = s*(2*pi/s(end));
qCircle2 =(center + radius*[cos(theta') sin(theta') zeros(size(theta'))])';



figure(1);
line = [x;y;z];
trajectory = [line,qCircle,qCircle2];
plot3(trajectory(1,:),trajectory(2,:),trajectory(3,:),'r'),xlabel('x'),ylabel('y'),zlabel('z'),hold on;
plot3(trajectory(1,:),trajectory(2,:),trajectory(3,:),'o','color','g'),grid on;

% ���ٱ�
Ratio1 = 121;
Ratio2 = 160.68;
Ratio3 = 101.81;
Ratio4 = 99.69;
Ratio5 = 64.56;
Ratio6 = 49.99;

Ratio = [Ratio1, Ratio2, Ratio3, Ratio4, Ratio5, Ratio6];

for i = 1:length(trajectory)
    pose_start(1,4) = trajectory(1,i);
    pose_start(2,4) = trajectory(2,i);
    pose_start(3,4) = trajectory(3,i);
    q(i,:) = Ikine_Step(pose_start,Q_zero);%����
    qout(i,:) = q(i,:).*Ratio / 2; 
    qout(i,:) = qout(i,:) .* [1 1 1 1 -1 -1];
end

Sizefont = 30;
xlabel('X (m)','FontSize',Sizefont,'FontName','Times New Roman');
ylabel('Y (m)','FontSize',Sizefont,'FontName','Times New Roman');
zlabel('Z (m)','FontSize',Sizefont,'FontName','Times New Roman');
grid on 
format short;
%����ļ�
Pos = roundn(qout,-4);
T=table(Pos);
fid = fopen('Pos.txt','wt+');
fprintf(fid,'%-8.4f,%-8.4f,%-8.4f,%-8.4f,%-8.4f,%-8.4f,\n',Pos.');
writetable(T,'Pos.csv');

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
qzero = [0,0,0,0,pi/2,0,0,0];
show(robot,qzero','PreservePlot',false);
axes.CameraPositionMode = 'auto';
view([150 6]);%figure��С����
axis([-0.6 0.6 -0.4 0.8 0 0.8]);%���귶Χ
daspect([1 1 1]);%������ÿ��������ݵ�λ����,Ҫ�����з����ϲ�����ͬ�����ݵ�λ���ȣ�ʹ�� [1 1 1]
hold on;
% plot3(trajectory(1,:),trajectory(2,:),trajectory(3,:),'color',[1,0,0],'LineWidth',2);
plot3(-trajectory(2,:),trajectory(1,:),trajectory(3,:),'color',[1,0,0],'LineWidth',2);
hold on;
q1 = zeros(length(trajectory),8);%λ��-->���ؽ�Ϊ����ֵ,8�������ؽ��˶�.

for i = 1:length(trajectory)
%     q(i,:) = q(i,:).*[pi/180,pi/180,pi/180,pi/180,pi/180,pi/180];
%     robot.plot(q(i,:));
    q(i,:) = q(i,:).*[-pi/180,-pi/180,-pi/180,pi/180,pi/180,pi/180];
    q1(i,1:6) = q(i,:);
%     frame = getframe(figure(3)); 
%     im = frame2im(frame); 
%     [imind,cm] = rgb2ind(im,256);
%     if i == 1
%         imwrite(imind,cm,'robot1.gif','gif','WriteMode','overwrite', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,'robot1.gif','gif','WriteMode','append','DelayTime',0.2);
%     end
end

aviobj=VideoWriter('example.avi');
aviobj.FrameRate=30;%set FrameRate before open it
open(aviobj);

for i = 1:length(trajectory)   
    show(robot,q1(i,:)','PreservePlot',false);
    pause(0.1);
%     frame = getframe(figure(3)); 
%     im = frame2im(frame); 
%     [imind,cm] = rgb2ind(im,256);
%     if i == 1
%         imwrite(imind,cm,'robot.gif','gif','WriteMode','overwrite', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,'robot.gif','gif','WriteMode','append','DelayTime',0.01);
%     end
    fig=figure(3);
    MOV=getframe(fig);
    writeVideo(aviobj,MOV);
end
close(aviobj)


