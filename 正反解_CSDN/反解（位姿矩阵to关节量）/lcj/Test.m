clc
clear
Q_zero = [0,0,0,0,0,0];
Q_last = [0,0,0,0,0,0];

RobotPose=Fkine_Step(Q_zero)%��д���⺯��
Q_Ikine = Ikine_Step(RobotPose,Q_last)
%RobotPose= Fkine_Step(Q_Ikine)%��д���⺯��

