clc;
clear;
%��ʼ����
x_arry=[0,0.1,0.2];
v_arry=[0.05,0.05];
A_arry=[0.1,0.1];
weiyi=[x_arry(1)];sudu=[0];shijian=[0];timeall=0;jiasudu=[0]
for i=1:1:length(x_arry)-1;
%���
    a=[];v=[];s=[];
%����Ӽ��ٶε�ʱ���λ��
    L=x_arry(i+1)-x_arry(i);
    A=A_arry(i);
    vs=v_arry(i);
    Ta=sqrt(vs/A);
    L1=A*(Ta^3)/6;
    L2=A*(Ta^3)*(5/6); 
%�������ι켣����λ��
    T=4*Ta+(L-2*L1-2*L2)/vs;
    for t=0:0.001:T
        if t<=Ta;%�Ӽ��ٶȽ׶�
            ad=A*t;
            vd=0.5*A*t^2;
            sd=(1/6)*A*t^3;
            a=[a,ad];v=[v,vd];s=[s,sd];
        elseif t>Ta && t<=2*Ta;%�Ӽ��ٽ׶�
            ad=-A*(t-2*Ta);
            vd=-0.5*A*(t-2*Ta)^2+A*Ta^2;
            sd=-(1/6)*A*(t-2*Ta)^3+A*Ta^2*t-A*Ta^3;
            a=[a,ad];v=[v,vd];s=[s,sd];
         elseif t>2*Ta && t<=T-2*Ta;%���ٽ׶�
            ad=0;
            vd=vs;
            sd=A*Ta^2*t-A*Ta^3;  
            a=[a,ad];v=[v,vd];s=[s,sd];
        elseif t>T-2*Ta && t<=T-Ta;%���ӶȽ׶�
            ad=-A*(t-(T-2*Ta));
            vd=-0.5*A*(t-T+2*Ta)^2+A*Ta^2;
            sd=-(1/6)*A*(t-T+2*Ta)^3+A*Ta^2*t-A*Ta^3;
            a=[a,ad];v=[v,vd];s=[s,sd];
         elseif t>T-Ta && t<=T;%�����׶�
            ad=A*(t-T);
            vd=0.5*A*(t-T)^2;
            sd=(1/6)*A*(t-T)^3-2*A*Ta^3+A*Ta^2*T;
            a=[a,ad];v=[v,vd];s=[s,sd];
        end
    end
%ʱ��
    time=[timeall:0.001:timeall+T];
    timeall=timeall+T;
%����ÿһ�ι켣
    weiyi=[weiyi,s(2:end)+x_arry(i)];
    sudu=[sudu,v(2:end)];
    jiasudu=[jiasudu,a(2:end)];
    shijian=[shijian,time(2:end)];
end
subplot(3,1,1),plot(shijian,weiyi,'r');xlabel('t'),ylabel('position');grid on;
subplot(3,1,2),plot(shijian,sudu,'b');xlabel('t'),ylabel('velocity');grid on;
subplot(3,1,3),plot(shijian,jiasudu,'g');xlabel('t'),ylabel('accelerate');grid on;