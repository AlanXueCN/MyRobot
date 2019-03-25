function Torque = dynamics(angle, angluar_v, angluar_a)
% ��������, unit: Kg
mass = [65.0, 50.0, 20.0, 10.5, 3.5, 1.0];    

% �˼�����, unit: m
P1=0.43;
P2=0.0996;
P4=0.6507;
P5=0.0011;
P6=0.7002;


% �����ڸ˼�����ϵ�µı�ʾ, unit: m
PC = [  -0.028,     -0.014,     -0.093;
        0.281,      -0.023,     0.121; 
        0.0,        -0.049,     -0.014; 
        0.002,      0.006,      -0.254;
        -0.001,     -0.047,     0.005; 
        0.0001,     0.004,      0.130; ];


% ��һ������ϵ����һ������ϵ�µı�ʾ
P = [0.0, 0.0,  P1; 
	 -P2, 0.0, 0.0; 
     P4, 0.0, 0.0; 
	 P5, -P6, 0.0; 
	 0.0, 0.0, 0.0; 
	 0.0, 0.0, 0.0; ];	 

% �˼�����������ϵ�µĹ������� unit: kg*m^2
IC(:,:,1) = [1.3    0.0     0.0;  
			 0.0   	0.9		0.0;   
			 0.0 	0.0    	0.8]; 
IC(:,:,2) = [2.9   	0.0     0.0;  
			 0.0   	2.8		0.0;   
			 0.0 	0.0    	0.2]; 
IC(:,:,3) = [0.22	0.0     0.0;  
			 0.0   	0.22	0.0;   
			 0.0 	0.0    	0.17]; 
IC(:,:,4) = [0.32	0.0     0.0;  
			 0.0	0.32	0.0;   
			 0.0 	0.0    	0.03]; 
IC(:,:,5) = [0.002	0.0     0.0;  
			 0.0	0.002	0.0;   
			 0.0 	0.0		0.002]; 
IC(:,:,6) = [0.002	0.0     0.0;  
			 0.0	0.002	0.0;   
			 0.0 	0.0		0.0004]; 

% ��ȡ�˼������ת����(i+1��i�µı�ʾ) 
R(:,:,1) = [cos(angle(1)), 	-sin(angle(1)),	0.0; 
			sin(angle(1)), 	cos(angle(1)), 	0.0; 
			0.0,		   	0.0,			1.0];
        
R(:,:,2) = [sin(angle(2)),	cos(angle(2)),	0.0;  
			0.0,		   	0.0,			1.0;
			cos(angle(2)),	-sin(angle(2)), 0.0];
        
R(:,:,3) = [cos(angle(3)),	-sin(angle(3)),	0.0;  
			sin(angle(3)), 	cos(angle(3)),	0.0; 
			0.0,		   	0.0,			1.0];
        
R(:,:,4) = [cos(angle(4)),	-sin(angle(4)),	0.0; 
			0.0,		   	0.0,			-1.0; 
			sin(angle(4)), 	cos(angle(4)),	0.0];
        
R(:,:,5) = [cos(angle(5)),	-sin(angle(5)),	0.0; 
			0.0,		   	0.0,			1.0;
			-sin(angle(5)),	-cos(angle(5)),	0.0];
        
R(:,:,6) = [cos(angle(6)),	-sin(angle(6)),	0.0; 
			0.0,		   	0.0,			-1.0;
			sin(angle(6)), 	cos(angle(6)),	0.0];
			
% ��ȡ�˼������ת�����(i��i+1�µı�ʾ) 
for i1 = 1:6
    inR(:,:,i1) = inv(R(:,:,i1));
end

% ������ʼ��
% �������ٶ�Ϊ0
omiga_v0 = [0; 0; 0];
% �����Ǽ��ٶ�Ϊ0
omiga_a0 = [0; 0; 0];
% �����߼��ٶ�Ϊ0
acc0 = [0; 0; 0];

% ���ƣ���˼�1-6�Ľ��ٶȣ��߼��ٶȣ��Ǽ��ٶ�
for i = 1:6
	if (i == 1)
		% ��˼�1���ٶ�
		z = [0.0;0.0;angluar_v(i)];
		omiga_v(:,i) = ones(3,3)*omiga_v0 + z;
		% ��˼�1�Ǽ��ٶ�
		za = [0.0; 0.0; angluar_a(i)];
		omiga_a(:,i) = ones(3,3)*omiga_a0 + cross(ones(3,3)*omiga_v0, z) + za;
		% ��˼�1�߼��ٶ�   
		acc(:,i) = ones(3,3)*(cross(omiga_a0, P(i,:)') + cross(omiga_v0, cross(omiga_v0, P(i,:)')) + acc0);
	else
		% ��˼�2-6���ٶ�
		z = [0.0;0.0;angluar_v(i)];
		omiga_v(:,i) = inR(:,:,i)*omiga_v(:,i-1) + z;
		% ��˼�2-6�Ǽ��ٶ�
		za = [0.0; 0.0; angluar_a(i)];
		omiga_a(:,i) = inR(:,:,i)*omiga_a(:,i-1) + cross(inR(:,:,i)*omiga_v(:,i-1), z) + za;
		% ��˼�2-6�߼��ٶ�
		acc(:,i) = inR(:,:,i)*(cross(omiga_a(:,i-1), P(i,:)') + cross(omiga_v(:,i-1), cross(omiga_v(:,i-1), P(i,:)')) + acc(:,i-1));
    end

	% ��˼�1-6�����߼��ٶ�
    accz(:,i) = cross(omiga_a(:,i), PC(i,:)') + cross(omiga_v(:,i), cross(omiga_v(:,i), PC(i,:)')) + acc(:,i);
	% ��˼�1-6������
	force1(:,i) = mass(i)*accz(:,i);
	% ��˼�1-6��������
    torque1(:,i) = IC(:,:,i)*omiga_a(:,i) + cross(omiga_v(:,i), IC(:,:,i)*omiga_v(:,i));
end

% ĩ�˹ؽ�������/����
force2out = [0; 0; 0];
torque2out = [0; 0; 0];

% ���ƣ���ؽ�6-1����������	
for i=6:-1:1
	if (i==6)
		% ��˼�6�ܵ�����
		force2(:,i) = ones(3,3)*force2out + force1(:,i);
		% ��˼�6�ܵ�������
		torque2(:,i) = torque1(:,i) + ones(3,3)*torque2out + cross(PC(i,:)', force1(:,i)) + cross(zeros(3,1), ones(3,3)*force2out);
	else
		% ��˼�5-1�ܵ�����
		force2(:,i) = R(:,:,i+1)*force2(:,i+1) + force1(:,i);
		% ��˼�5-1�ܵ�������
		torque2(:,i) = torque1(:,i) + R(:,:,i+1)*torque2(:,i+1) + cross(PC(i,:)', force1(:,i)) + cross(P(i+1,:)', R(:,:,i+1)*force2(:,i+1));
	end
	
	% �ؽ�i������
    Torque(i) = torque2(3,i);
end