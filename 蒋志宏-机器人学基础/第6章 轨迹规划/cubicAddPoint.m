% ���ܣ�����ؽڹ滮������������˶���
% ����: i�������������滮�ؽ����
%       point�����ؽ������˶���
% �����out���������滮����ӵ�ɹ���־
function out = cubicAddPoint( i,point )

    global cubic
	%�ж��Ƿ���Ҫ�����µ�
    if cubic(i).needNextPoint == 0 
        out = -1 ;
        return
    end
	
	% ����滮��û���������滮��
    if cubic(i).filled == 0	
        cubic(i).x0 = point;
        cubic(i).x1 = point;
        cubic(i).x2 = point;
        cubic(i).x3 = point;
        cubic(i).filled = 1;
	% ����滮���������滻���һ��
    else
        cubic(i).x0 = cubic(i).x1;
        cubic(i).x1 = cubic(i).x2;
        cubic(i).x2 = cubic(i).x3;
        cubic(i).x3 = point;
    end
    
	% ����������ϵ��λ��
    wp0 = (cubic(i).x0 + 4*cubic(i).x1 + cubic(i).x2)/6.0;
    wp1 = (cubic(i).x1 + 4*cubic(i).x2 + cubic(i).x3)/6.0;
	% ����������ϵ���ٶ�
    vel0 = (cubic(i).x2 - cubic(i).x0)/(2.0*cubic(i).sTime);
    vel1 = (cubic(i).x3 - cubic(i).x1)/(2.0*cubic(i).sTime);
	% ����滮������
    cubic(i).d = wp0;
	cubic(i).c = vel0;
	cubic(i).b = 3*(wp1 - wp0)/cubic(i).sTime^2 - (2*vel0 + vel1)/cubic(i).sTime;
	cubic(i).a = -2*(wp1 - wp0)/cubic(i).sTime^3 + (vel0 + vel1)/cubic(i).sTime^2;
	
	%����״̬
    cubic(i).Tnow = 0;
    cubic(i).needNextPoint = 0;
	out = 0;
end

