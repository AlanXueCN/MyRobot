function bs = uniformbspline(index,x,sequence)
% ���ξ���B������ֵ����(CBI Cubic B-spline Interpolation)
% bs = uniformbspline(index,x,sequence)
% �������:  index     Ϊ�����ĺ���������(Y������)
%               x     ��֪�ĵ������ֵ
%        sequence     ���е�ĺ��������� sequence=1:n;
% �������:
%              bs    ���ξ���B������ֵ���
% eMail  clearsblue@163.com


%
% beta = 1;
% t=0.1;  % ���Ը���
% p(t) = 1/6*[1 t t^2 t^3]*[0       6          0          0
%                           -3*beta 0          3*beta     0 
%                           6*beta  -18+3*beta 18-6*beta  -3*beta
%                           -3*beta 12-3*beta  -12+3*beta 3*beta  ]*[pL;pL1;pL2;pL3]
%
% ���ݲ���

if(nargin == 1)
     error('����������������: bs = uniformbspline(index,x)');
end

if length(index) ~=length(x)
   error('index,x�������Ȳ����!');
end;

% ����B������ֵ����
x=[x(1),x];
x=[x(1),x];
x=[x(1),x];
x=[x,x(end)];
x=[x,x(end)];
x=[x,x(end)];

index = [index(1),index];
index = [index(1),index];
index = [index(1),index];
index = [index,index(end)];
index = [index,index(end)];
index = [index,index(end)];

len = length(index);
beta = 0.000001;
ind = 1;
for i = 1:len-3
    pL = x(i);
    pL1 = x(i+1);
    pL2 = x(i+2);
    pL3 = x(i+3);
    Step = abs((index(i+2)-index(i+1)));
    if Step == 0 
       Step = 1;
    end;
    k = 0:1/Step:1;
    for j = 1:length(k)
        t = k(j);
        p(ind) = 1/6*[1 t t^2 t^3]*[0       6          0          0
                                   -3*beta  0          3*beta     0 
                                    6*beta  -18+3*beta 18-6*beta  -3*beta
                                   -3*beta   12-3*beta -12+3*beta  3*beta]*[pL;pL1;pL2;pL3];
        ind = ind + 1;
    end
    ind = ind  - 1;
end;
p = p(3:end-2);
indexmin = min(index);
if(nargin == 3)
   if indexmin < sequence(1)
      p = p(abs(indexmin)+2:end);    
   end;
   bs = p(sequence); 
else
   bs = p;
end;
