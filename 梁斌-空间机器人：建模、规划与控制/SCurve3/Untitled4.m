for i = 1:6
subplot(3,3,i);
plot(q(:,i),'r')
hold on;
plot(q1(:,i),'b')
hold on;
if i == 4
legend('���Ǻ����Ӽ���ģ��','���μӼ���ģ��');
end
end