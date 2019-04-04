%���������
clear
clc
robot = importrobot('Test_Link6.urdf');%���������������ʽ
robot.DataFormat='column';%���ݸ�ʽΪ�У�rowΪ�У�Ϊ��row'ʱq0Ҫת��-->q0��
robot.Gravity = [0 0 -9.80];%������������
qzero = [0,0,0,0,pi/2,0,0,0];
show(robot,qzero','PreservePlot',false);

axes.CameraPositionMode = 'auto';

%����켣Ϊ�뾶Ϊ0.15��Բ
t = (0:0.1:10)'; 
count = length(t);
center = [0 0.5 0.3];
radius = 0.15;
theta = t*(2*pi/t(end));
points =(center + radius*[cos(theta) sin(theta) zeros(size(theta))])';

hold on
plot3(points(1,:),points(2,:),points(3,:),'r')%��������Ĺ켣


Q_zero = [90,0,0,0,90,0];%���� -> ץ��

Angle_Last = Q_zero + [0,90,0,0,0,0];
pose_start = Fkine_Final(Q_zero)%����
q1 = zeros(length(points),8);%λ��-->���ؽ�Ϊ����ֵ,8�������ؽ��˶�.
    
for i = 1:length(points)
    pose_start(1,4) = points(2,i);
    pose_start(2,4) = -points(1,i);
    pose_start(3,4) = points(3,i);
    q(i,:) = Ikine_Step(pose_start,Q_zero);%����
    q(i,:) = q(i,:).*[-pi/180,-pi/180,-pi/180,pi/180,pi/180,pi/180];
    q1(i,1:6) = q(i,:);
end


title('robot move follow the trajectory')
hold on
axis([-0.6 0.6 -0.4 0.8 0 0.8]);
for i = 1:size(points,2)
    show(robot,q1(i,:)','PreservePlot',false);%false��Ϊtrueʱ��������Ӱ��
    pause(0.01)
end
hold off

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
