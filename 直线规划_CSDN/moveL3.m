function Q = moveL3(PT1,PT2)
% clear;
% clc;
q0=PT1;
q1=PT2; %ָ����ֹλ��
t0=0;
t1=0.5;%ָ����ֹʱ��
v0=0;
v1=0;%ָ����ֹ�ٶ�
a0=q0;
a1=v0;
a2=(3/(t1)^2)*(q1-q0)-(1/t1)*(2*v0+v1);
a3=(2/(t1)^3)*(q0-q1)+(1/t1^2)*(v0+v1);%�������ζ���ʽϵ��
t=t0:0.01:t1;
q=a0+a1*t+a2*t.^2+a3*t.^3;%���ζ���ʽ��ֵ��λ��
v=a1+2*a2*t+3*a3*t.^2;%���ζ���ʽ��ֵ���ٶ�
a=2*a2+6*a3*t;%���ζ���ʽ��ֵ�ļ��ٶ�

% subplot(3,1,1),plot(t,q),xlabel('t'),ylabel('position');grid on;
% subplot(3,1,2),plot(t,v),xlabel('t'),ylabel('velocity');grid on;
% subplot(3,1,3),plot(t,a),xlabel('t'),ylabel('accelerate');grid on;

Q = q;