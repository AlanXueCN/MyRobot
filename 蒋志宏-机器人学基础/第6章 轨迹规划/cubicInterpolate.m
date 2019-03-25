% ���ܣ�������һ���滮���ֵ
% ����: i�������������滮�ؽ����
% �����out����������һ���Ĺ滮�Ƕ�
function out = cubicInterpolate( i )
    global cubic
	% ����ϴι滮�����������µ�
    if cubic(i).needNextPoint
       cubicAddPoint(i,cubic(i).x3); 
    end
	
	% ����滮��ʱ��
    cubic(i).Tnow = cubic(i).Tnow + cubic(i).Inc;
    
	% �жϴ˴ι滮�Ƿ����
    if abs(cubic(i).sTime - cubic(i).Tnow)<0.5*cubic(i).Inc
        cubic(i).needNextPoint = 1;
    end
	
    % ������һ���滮ֵ
    out = cubic(i).a*cubic(i).Tnow^3 + cubic(i).b*cubic(i).Tnow^2 + cubic(i).c*cubic(i).Tnow + cubic(i).d;
end

