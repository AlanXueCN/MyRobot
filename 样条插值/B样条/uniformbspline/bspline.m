clear all;
clc;
j=0;
for i=1:10
    index(i)=j;
    j=j+10;
end
for i=1:90
    squence(i)=i;
end

j=1;
for i=0:2/9*pi:2*pi
    Y(j)=sin(i);
    j=j+1;
end

bs = uniformbspline(index,Y,squence)
plot(bs,'.');
hold on;
plot(index,Y,'*');

% ���ξ���B������ֵ����(CBI Cubic B-spline Interpolation)
% bs = uniformbspline(index,x,sequence)
% �������:  index     Ϊ�����ĺ���������(Y������)
%               x     ��֪�ĵ������ֵ
%        sequence     ���е�ĺ��������� sequence=1:n;
% �������:
%              bs    ���ξ���B������ֵ���