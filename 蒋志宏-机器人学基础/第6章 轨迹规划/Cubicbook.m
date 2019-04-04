clear
close all
clc

global cubic
TrajTime = 0.1;%�滮�ؽ��˶�������100ms
ServoTime = 0.01;%�ŷ�ʱ�䣬��ÿ��10ms�������˷���һ������ָ��
deltaT = 0.01;%��������PLC10ms(����)

for i = 1:6
    % ��ʼ״̬�滮�����ݲ��������Ϊ0
	cubic(i).filled = 0;
    % ��ʾ��Ҫ�µĹ滮��
    cubic(i).needNextPoint = 1;
    % ����滮����
    cubic(i).sTime = TrajTime;
    % ����ÿ�ι滮����
    cubic(i).Rate = TrajTime/ServoTime + 1;
    % ��ǰ�滮��ʱ����Ϊ0
    cubic(i).interpolationTime = 0;
    % ����滮��ʱ������
    cubic(i).Inc = cubic(i).sTime/(cubic(i).Rate-1);
    % ��չ滮�����е�
    cubic(i).x0 = 0;
    cubic(i).x1 = 0;
    cubic(i).x2 = 0;
    cubic(i).x3 = 0;
    % ��չ滮��ϵ��
    cubic(i).a = 0;
    cubic(i).b = 0;
    cubic(i).c = 0;
    cubic(i).d = 0;
end
index = 1;%����ؽڽǶȸ�������
sinT = 0;%���ҹ滮ʱ��
AngleInit = [0 0 0 0 0 0];%��ʼ�ؽڽ�

%ѹ���ʼ�ǶȽ���滮��
for i = 1:6
    cubicAddPoint(i,AngleInit(i));
    cubic(i).needNextPoint = 1;
end
%��ʼʱ������ֵ
on = 1;
num = 1;
%�ܹ滮ʱ��
for t = 0:deltaT:1
	% �����Ҫ�����滮�����������
    while cubic(1).needNextPoint
		% ��������ʱ��������˶����ߵ�
        if on 
            for i = 1:6
%                 point(i,num) = 1*sin(2*pi*sinT) + AngleInit(i);                
                point(i,num) = exp(num) + AngleInit(i);
                cubicAddPoint(i,point(i,num));
            end
		% �رտ���ʱ����ϴ�������
        else
            for i = 1:6
                cubicAddPoint(i,cubic(i).x3);
                point(i,num) = point(i,num-1);
            end
        end
        sinT = sinT + TrajTime;
        num = num + 1;
    end
	% ���ؽڽǶȹ滮
    for i = 1:6
        Joint(i,index) = cubicInterpolate(i);
    end
    index = index + 1;
	% ���ʱ�����15s��ֹͣ�˶�����
    if t>1
        on = 0;
    end
end
% ����1�ؽڵĹ滮�������켣
time = 0:(index-2);
time= time*deltaT;
plot(time,Joint(1,:),'b-')
grid on 
hold on
time = 0:(num-2);
time= time*TrajTime;
plot(time,point(1,:),'r*')
ylim([-1.5 1.5])
xlabel('time(s)')
ylabel('angle(rad)')
title('�ؽ�1�����켣��ʵ�ʹ滮�켣����')
legend('�滮�켣','�����켣')

figure;
v = diff(Joint(1,:));
a = diff(v);
aa = diff(a);
subplot(2,2,1);
plot(Joint(1,:));
subplot(2,2,2);
plot(v);
subplot(2,2,3);
plot(a);
subplot(2,2,4);
plot(aa);
