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
         0  1  0 -0.2;
         0  0  1 -0.4;
         0  0  0  1;];
pose_end1 = trans*pose_start;
line1 = Sline(0.1,0.03,0.1,trans,pose_start);
%ƽ��
trans1 = [1  0  0  0;
          0  1  0  0;
          0  0  1 -0.1;
          0  0  0  1;];
pose_end2 = trans1*pose_end1;
line2 = Sline(0.1,0.03,0.1,trans1,pose_end1);
line3 = line2(:,end:-1:1);
%ƽ��
trans2 = [1  0  0  0;
          0  1  0  0.4;
          0  0  1  0;
          0  0  0  1;];
pose_end3 = trans2*pose_end1;
line4 = Sline(0.1,0.03,0.1,trans2,pose_end1);

pose_end4 = trans1*pose_end3;
line5 = Sline(0.1,0.03,0.1,trans1,pose_end3);
figure(1);
trajectory = [line1,line2,line3,line4,line5];
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

Sizefont = 10;
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
end

aviobj=VideoWriter('example.avi');
aviobj.FrameRate=30;%set FrameRate before open it
open(aviobj);

for i = 1:length(trajectory)   
    show(robot,q1(i,:)','PreservePlot',false);
    pause(0.1);

    fig=figure(3);
    MOV=getframe(fig);
    writeVideo(aviobj,MOV);
end
close(aviobj)


