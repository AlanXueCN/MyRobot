function [center,rad] = CircleCenter(p1, p2, p3)
% ���������ռ�㣬�������Բ�ļ��뾶
% rad>0:   Բ��
% rad = -1:��������������
% rad = -2:���㹲��

center = 0;rad =0;
% ���ݼ��
% ������������ʽ�Ƿ���ȷ
if size(p1,2)~=3 || size(p2,2)~=3 || size(p3,2)~=3
    fprintf('�����ά�Ȳ�һ��\n');rad = -1;return;
end
n = size(p1,1);
if size(p2,1)~=n || size(p3,1)~=n
    fprintf('�����ά�Ȳ�һ��\n');rad = -1;return;
end

% ����p1��p2�ĵ�λ������p1��p3�ĵ�λ����
% �����Ƿ���ͬ
v1 = p2 - p1;
v2 = p3 - p1;
if find(norm(v1)==0) | find(norm(v2)==0) %#ok<OR2>
    fprintf('����㲻��һ��\n');rad = -1;return;
end
v1n = v1/norm(v1);
v2n = v2/norm(v2);

% ����Բƽ���ϵĵ�λ������
% ��������Ƿ���
nv = cross(v1n,v2n);
 if all(nv==0)
    fprintf('�����㹲��\n');rad = -2;return;
 end
if find(sum(abs(nv),2)<1e-5)
    fprintf('�����������ֱ��\n');rad = -1;return;
end

% ����������ϵUVW��
u = v1n;
w = cross(v2,v1)/norm(cross(v2,v1));
v = cross(w,u);

% ����ͶӰ
bx = dot(v1,u);
cx = dot(v2,u);
cy = dot(v2,v);

% ����Բ��
h = ((cx - bx/2)^2 + cy^2 -(bx/2)^2)/(2*cy);
center = zeros(1,3);
center(1,:) = p1(1,:) + bx/2.*u(1,:) + h.*v(1,:);

% �뾶
rad = sqrt((center(1,1)-p1(1,1)).^2+(center(1,2)-p1(1,2)).^2+(center(1,3)-p1(1,3)).^2);
end
