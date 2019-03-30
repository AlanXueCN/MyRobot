function [Tm1,T_CA1,T_CV,Tm2,T_CA2,Am1,Am2,Vite] = Adaptive(Cv, Ca, Cj, Distance, Vs, Ve, Vset)

Tm = 1.5 * Ca / Cj;
V1 = min(Ve,Vs);
V2 = max(Ve,Vs);
VmWoCA = 2*Cj*Tm*Tm/3;      % ���ȼ���״̬�·���ʱ�����ŵ�����ٶ�
Vma = Cj*Tm*Tm/3;
Dma = 0.1*Cj*Tm*Tm*Tm;       % ���������ٶ�Լ���ľ���
Dmv_n = 2*Vma*Tm;

%% �˶�ѧԼ���ж�
if(Cv - VmWoCA < 0)          %С���޷��ﵽ�����ٶ�����                                                                                       
    Tm = sqrt(1.5*Cv/Cj);
    Ca = 2*Cj*Tm/3;
    Dma = 0.1*Cj*Tm*Tm*Tm; 
    Vma = Cj*Tm*Tm/3;
    Dmv = 2*Vma*Tm ;          %�ﵽ����ٶ���������Ҫ�ľ���
    VmWoCA = 2*Cj*Tm*Tm/3;
else
    TCA = (Cv-VmWoCA)/Ca;  %�ȼ���ʱ��
    Dmv = Dmv_n + Tm*(Cv-VmWoCA) + TCA*(0.5*(Cv-VmWoCA)+Vma); %�ﵽ����ٶ���������Ҫ�ľ���
end

%% ���ݾ����ж�����ٶ�
if(Dmv >= Dmv_n)  %���Դ����ȼ��ٶ�(���忴����)                    
    
    if(Distance -(2*Tm+TCA)*V1>= Dmv)%�������٣������ȼ��٣����ܴﵽϵͳ����ٶ�
        Vmax = Cv;
        T_CA = (Cv-VmWoCA)/Ca;  %�ȼ���ʱ��
        Dmv = Dmv_n + Tm*(Cv-VmWoCA) + TCA*(0.5*(Cv-VmWoCA)+Vma); 
        T_CV = (Distance - 2*Dmv) / Cv;
    else
        if(Distance-2*Tm*V1 >= Dmv_n)%���������٣������ȼ��٣����޷��ﵽϵͳ����ٶ�
             A = 0.5*Ca;
             B = Tm*Ca+Vma+V1;
             C = Dmv_n-Distance+2*Tm*V1;
              T_Diff1 = (-B+sqrt(B*B-4*A*C))/(2*A);
              T_Diff2 = (-B-sqrt(B*B-4*A*C))/(2*A);
              if(min(T_Diff1,T_Diff2) <= 0)
                  T_CA = max(T_Diff1,T_Diff2);
              else
                  T_CA = min(T_Diff1,T_Diff2);  %�����ȼ���ʱ��
              end
             Vmax = 2 * Vma + T_CA * Ca + V1;
             T_CV = 0;
        else
            a = 2*Cj/3;
            b = 0;
            c = 2*V1;
            d = -Distance;

            A = b*b-3*a*c;  %A<=0
            B = b*c-9*a*d;  %B>0
            C = c*c-3*b*d;  %C>=0
            deta = B*B-4*A*C; %deta>0
        
            Y1 = A*b+3*a*(-B+sqrt(B*B-4*A*C))/2;
            Y2 = A*b+3*a*(-B-sqrt(B*B-4*A*C))/2;
            TM = (-b-(nthroot(Y1,3)+nthroot(Y2,3)))/(3*a);

            Vmax = Distance/TM - V1;
            T_CA = 0;
            T_CV = 0;
            Tm = TM;
        end
    end
    
else  %���ɴ����ȼ��ٶ�
    
    if(Distance-2*Tm*V1 >= Dmv)  %�������ٶ�
        Vmax = Cv;
        T_CA = 0;  %�ȼ���ʱ��
        Dmv = 2*Vma*Tm;
        T_CV = (Distance - 2*Dmv) / Cv;
    else %���������ٶ�
        a = 2*Cj/3;
        b = 0;
        c = 2*V1;
        d = -0.5*Distance;

        A = b^2-3*a*c;  %A<=0
        B = b*c-9*a*d;  %B>0
        C = c^2-3*b*d;  %C>=0
        deta = B^2-4*A*C; %deta>0

        Y1 = A*b+3*a*(-B+sqrt(B^2-4*A*C))/2;
        Y2 = A*b+3*a*(-B-sqrt(B^2-4*A*C))/2;
        TM = (-b-(nthroot(Y1,3)+nthroot(Y2,3)))/(3*a);

        Vmax = Distance/TM - V1; 
        T_CA = 0;
        T_CV = 0;
        Tm = TM;
    end   
end

Vmax = min(Vset, Vmax);
Vite_H = Cv;
Vite_L = 0;
%% ��С�������̾���
if(Vmax <= V2) 
    V2 = Vmax;
    if(Vs == max(Vs,Ve))
        Vs = V2;
    else
        Ve = V2;
    end
    Vite = V2;
else
    Vite = min(Vmax, Cv);
    k=1;
    j=1;
    Vite_T = NaN;
    while(1)
        
      V_Diff1 = Vite-V1-VmWoCA;
      TCA1 = V_Diff1/Ca;
      V_Diff2 = Vite-V2-VmWoCA;
      TCA2 = V_Diff2/Ca;
      
      Thresh = 0;
      if(TCA1 <= Thresh && TCA2 <= Thresh)
         Dite=(Vite+V1)*sqrt(3*(Vite-V1)/(2*Cj))+(Vite+V2)*sqrt(3*(Vite-V2)/(2*Cj));
      end
      if(TCA1 >= Thresh && TCA2 < Thresh)
         Dite=Dmv_n+Tm*(V_Diff1+2*V1)+TCA1*(0.5*V_Diff1+Vma+V1)+(Vite+V2)*sqrt(3*(Vite-V2)/(2*Cj));
      end
      if(TCA1 < Thresh && TCA2 >= Thresh)
         Dite=(Vite+V1)*sqrt(3*(Vite-V1)/(2*Cj))+Dmv_n+Tm*(V_Diff2+2*V2)+TCA2*(0.5*V_Diff2+Vma+V2);   
      end 
      if(TCA1 > Thresh && TCA2 > Thresh)
         Dite=Dmv_n+Tm*(V_Diff1+2*V1)+TCA1*(0.5*V_Diff1+Vma+V1)+Dmv_n+Tm*(V_Diff2+2*V2)+TCA2*(0.5*V_Diff2+Vma+V2);
      end
        
      if( (k>=20 && abs(Dite-Distance)<=1e-10 && Dite<=Distance) || (k==1 && (Dite-Distance)<=0) )break;end
%      if(Dite>Distance) %�ٶȹ���
%          if(isnan(Vite_T))
%           Vite=V2;
%          else
%           Vite=Vite_T;
%           j=j+1;
%           Vite=Vite+(Cv-Vite)/(2*j);
%         end
%      else
%         Vite_T=Vite;
%         Vite=Vite+(Cv-Vite)/(2*j);
%         j=1;                      %�߾���ʱע�͵�
%      end
       if(Dite > Distance) %�ٶȹ���
           Vite_H = Vite;  
           Vite = (Vite_H + Vite_L)/2;

       else
           Vite_L = Vite; 
           Vite = (Vite_H + Vite_L)/2;      
       end
       k = k + 1;
    end
    
end   
        
 VD1=Vite-Vs;
 V_Diff1=VD1-VmWoCA;
 if(V_Diff1 > 1e-10 )   %���ٶδ����ȼ���
    T_CA1=V_Diff1/Ca;
    Dmv1=Dmv_n+Tm*(V_Diff1+2*Vs)+T_CA1*(0.5*V_Diff1+Vma+Vs);
%     Tm1=2*Tm+TCA1;
    Am1=Ca;
    Tm1 = Tm;
 else
    Tm1 = sqrt(3*VD1/(2*Cj));
    Dmv1=VD1*sqrt(3*VD1/(2*Cj))+2*Vs*Tm1;
    Am1=sqrt(2*VD1*Cj/3);
    T_CA1=0;
    V_Diff1=0;
 end
 
VD2=Vite-Ve;
V_Diff2=VD2-VmWoCA;
if(V_Diff2 > 1e-10)   %���ٶδ����ȼ���
    T_CA2=V_Diff2/Ca;
    Dmv2=Dmv_n+Tm*(V_Diff2+2*Ve)+T_CA2*(0.5*V_Diff2+Vma+Ve);
%         Time_Vmax_Given2=2*Time_Amax_System+Time_ConAcc2;
    Am2=Ca;
    Tm2=Tm;
else
    Tm2=sqrt(3*abs(VD2)/(2*Cj));
    Dmv2=VD2*sqrt(3*VD2/(2*Cj))+2*Ve*Tm2;
    Am2=sqrt(2*abs(VD2)*Cj/3);
    T_CA2=0;
    V_Diff2=0;
end
  
T_CV = (Distance - Dmv1 - Dmv2) / Vite;


