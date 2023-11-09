
%% Parameter Config
Mc = 1+1.2; % Central Mass
m = 0.2; % Rotor Mass
g=9.8;
M = Mc + 4*m; % Total Mass
R=0.1; % Radius of central
l=0.3; % Arm length

Jx = 2*Mc*R^2/5 + 2*m*l^2;
Jy = 2*Mc*R^2/5 + 2*m*l^2;
Jz = 2*Mc*R^2/5 + 4*m*l^2;

Command_Roll = 0;
Command_Pitch = 0;
Command_Yaw = 0;
Command_Z = 0;

%% PID Parameter Config
% Roll Config
Kp_roll = 80;
Ki_roll = 1;
Kd_roll = 15;

% Pitch Config
Kp_pitch = 80;
Ki_pitch = 1;
Kd_pitch = 15;

% Yaw Config
Kp_yaw = 80;
Ki_yaw = 1;
Kd_yaw = 15;

% Z Config
Kp_z = 80;
Ki_z = 10;
Kd_z = 15;


%% Adaptive Feedback Linearization Config

% feedback linearization config
K_phi = 80;
K_theta = 80;
K_psi = 80;
K_z = 80;

% adaptive config
lumda_phi = 1;
lumda_theta = 1;
lumda_psi = 1;
lumda_z = 1;

%% LQR config

A =     [0  1 0 0 0 0 0 0 0 0 0 0;...
         0  0 0 0 0 0 0 0 0 0 0 0;...
         -1 0 0 0 0 0 0 0 0 0 0 0;...

         0 0 0  0 1 0 0 0 0 0 0 0;...
         0 0 0  0 0 0 0 0 0 0 0 0;...
         0 0 0 -1 0 0 0 0 0 0 0 0;...

         0 0 0 0 0 0  0 1 0 0 0 0;...
         0 0 0 0 0 0  0 0 0 0 0 0;...
         0 0 0 0 0 0 -1 0 0 0 0 0;...

         0 0 0 0 0 0 0 0 0 0 1 0;...
         0 0 0 0 0 0 0 0 0 0 0 0;...
         0 0 0 0 0 0 0 0 0 -1 0 0;...
         ];
B =     [0 0 0 0;...
         1/Jx 0 0 0;...
         0 0 0 0;...
         
         0 0 0 0;...
         0 1/Jy 0 0;...
         0 0 0 0;...

         0 0 0 0;...
         0 0 1/Jz 0;...
         0 0 0 0;...

         0 0 0 0;...
         0 0 0 1/M;...
         0 0 0 0;...
         ];
% C_phi = [-1 0];
% Q_phi = C_phi'*C_phi;
weight_vector = [5 30 90 5 30 90 5 30 90 5 30 90];
Q = diag(weight_vector);
R = diag([1,1,1,1]);
% R_phi = 1;
[K_lqr] = lqr(A,B,Q,R);


%% Sensor & Environment Config

% K_gyro = 131;
%K_acc = ;
bias_gyro = rand*10-5;
bias_acc = rand*0.05-0.025;
% Measure in meters
Sa = 0.6231*0.4159; % standard 35mm film frame size, approximately 36mm x 24mm, count in meters
S = 0.6231;
f = 0.035; % 35 mm = 0.035 meter

% Measure in mm
% Sa = 36*24; % standard 35mm film frame size, approximately 36mm x 24mm, count in meters
% S = 36;
% f = 35; 

Pixel_full = 7360*4912; % 36MP Full Frame
Trans = sqrt(Pixel_full/Sa); % How many pixels one meter have.

WorkTemperature = 30;
Wind_x = 0;
Wind_y = 0;
Wind_z = 0;
Wind_phi = 0;
Wind_theta = 0;
Wind_psi = 0;

%% plot


PID_linear = sim("PID2.slx");

% Define time vector
PID_linear_time = PID_linear.tout;

PID_linear_command_roll = PID_linear.PID_linear_command_roll.Data;
PID_linear_roll = PID_linear.PID_linear_roll.Data;

PID_linear_command_z = PID_linear.PID_linear_command_z.Data;
PID_linear_z = PID_linear.PID_linear_z.Data;

figure(1);
plot(PID_linear_time, PID_linear_command_roll, PID_linear_time, PID_linear_roll,'LineWidth',1);
legend('command roll','roll','Location','east');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Roll angle (rad)');
title('Command Roll and Roll in PID control');

figure(2);
plot(PID_linear_time, PID_linear_command_z, PID_linear_time, PID_linear_z,'LineWidth',1);
legend('command z','z');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Z value (meter)');
title('Command z and z in PID control, (Kp-roll, Ki-roll, Kd-roll) = (80,10,15)');

Feedback_linear = sim("Test2_feedback_linearization_control.slx");

% Define time vector
Feedback_linear_time = Feedback_linear.tout;

Feedback_linear_command_roll = Feedback_linear.Feedback_linear_command_roll.Data;
Feedback_linear_roll = Feedback_linear.Feedback_linear_roll.Data;

Feedback_linear_command_z = Feedback_linear.Feedback_linear_command_z.Data;
Feedback_linear_z = Feedback_linear.Feedback_linear_z.Data;

figure(3);
plot(Feedback_linear_time, Feedback_linear_command_roll, Feedback_linear_time, Feedback_linear_roll,'LineWidth',1);
legend('command roll','roll','Location','east');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Roll angle (rad)');
title('Command Roll and Roll in PID with FL');

figure(4);
plot(Feedback_linear_time, Feedback_linear_command_z, Feedback_linear_time, Feedback_linear_z,'LineWidth',1);
legend('command z','z');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Z value (meter)');
title('Command z and z in PID with FL');

% LQR %%%%%%%%%

LQR_linear = sim("LQR.slx");

% Define time vector
LQR_linear_time = LQR_linear.tout;

LQR_linear_command_roll = LQR_linear.LQR_linear_command_roll.Data;
LQR_linear_roll = LQR_linear.LQR_linear_roll.Data;

LQR_linear_command_z = LQR_linear.LQR_linear_command_z.Data;
LQR_linear_z = LQR_linear.LQR_linear_z.Data;

figure(5);
plot(LQR_linear_time, LQR_linear_command_roll, LQR_linear_time, LQR_linear_roll,'LineWidth',1);
legend('command roll','roll','Location','east');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Roll angle (rad)');
title('Command Roll and Roll in LQR control with integral feedback');

figure(6);
plot(LQR_linear_time, LQR_linear_command_z, LQR_linear_time, LQR_linear_z,'LineWidth',1);
legend('command z','z');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Z value (meter)');
title('Command z and z in LQR control with integral feedback');

%% plot for nonlinear result
% PID
PID_nonlinear = sim("PID_nonlinear_improved_practical.slx");

% Define time vector
PID_nonlinear_time = PID_nonlinear.tout;

PID_nonlinear_command_roll = PID_nonlinear.command_phi.Data;
PID_nonlinear_roll = PID_nonlinear.phi.Data;

PID_nonlinear_command_z = PID_nonlinear.command_z.Data;
PID_nonlinear_z = PID_nonlinear.z.Data;
PID_nonlinear_resistence = PID_nonlinear.resistence.Data;

% Feedback
feedback_linearization = sim("feedback_linearization_control_practical.slx");

% Define time vector
feedback_linearization_time = feedback_linearization.tout;

feedback_linearization_command_roll = feedback_linearization.command_phi.Data;
feedback_linearization_roll = feedback_linearization.phi.Data;

feedback_linearization_command_z = feedback_linearization.command_z.Data;
feedback_linearization_z = feedback_linearization.z.Data;
feedback_linearization_resistence = feedback_linearization.resistence.Data;

% LQR
LQR_nonlinear = sim("LQR_nonlinear_improved.slx");

% Define time vector
LQR_nonlinear_time = LQR_nonlinear.tout;

LQR_nonlinear_command_roll = LQR_nonlinear.command_phi.Data;
LQR_nonlinear_roll = LQR_nonlinear.phi.Data;

LQR_nonlinear_command_z = LQR_nonlinear.command_z.Data;
LQR_nonlinear_z = LQR_nonlinear.z.Data;
LQR_nonlinear_resistence = LQR_nonlinear.resistence.Data;

% PID completely nonlinear
PID_completely_nonlinear = sim("PID_nonlinear_dynamics.slx");
PID_completely_nonlinear_time = PID_completely_nonlinear.tout;

PID_completely_nonlinear_command_roll = PID_completely_nonlinear.command_phi.Data;
PID_completely_nonlinear_roll = PID_completely_nonlinear.phi.Data;

PID_completely_nonlinear_command_z = PID_completely_nonlinear.command_z.Data;
PID_completely_nonlinear_z = PID_completely_nonlinear.z.Data;


figure(7);
hold on;
plot(PID_nonlinear_time, PID_nonlinear_command_roll,'LineStyle',"--");
plot(PID_nonlinear_time, PID_nonlinear_roll,'LineWidth',2);
plot(feedback_linearization_time, feedback_linearization_roll,'LineStyle',":",'LineWidth',1,'Color',"black");
plot(LQR_nonlinear_time,LQR_nonlinear_roll,'LineWidth',1);
scatter(10,0.68,10,"red",'LineWidth',2);
% plot(LQR_nonlinear_time,LQR_nonlinear_resistence,'LineWidth',1,'LineStyle',"-.");
legend('command roll','PID','PID with FL','LQR','Disturbance Begin','Location','southeast');
% legend('command roll','PID','PID with FL','LQR','Location','east');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Roll angle (rad)');
title('Command roll and response signals of three controllers');
hold off;

figure(8);
hold on;
plot(PID_nonlinear_time, PID_nonlinear_command_z,'LineStyle',"--");
plot(PID_nonlinear_time, PID_nonlinear_z,'LineWidth',2);
plot(feedback_linearization_time, feedback_linearization_z,'LineStyle',":",'LineWidth',1,'Color',"black");
plot(LQR_nonlinear_time,LQR_nonlinear_z,'LineWidth',1);
scatter(10,-3,10,"red",'LineWidth',2);
% plot(LQR_nonlinear_time,LQR_nonlinear_resistence,'LineWidth',1,'LineStyle',"-.");
legend('command z','PID','PID with FL','LQR','Disturbance Begin');
% legend('command z','PID','PID with FL','LQR');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Z value (meter)');
title('Command z and response signals of three controllers');
hold off;

figure(9);
plot(PID_completely_nonlinear_time, PID_completely_nonlinear_command_roll, PID_completely_nonlinear_time, PID_completely_nonlinear_roll,'LineWidth',1);
legend('command roll','roll');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Roll angle (rad)');
title('Command Roll and Roll in PID control with nonlinear model');

figure(10);
plot(PID_completely_nonlinear_time, PID_completely_nonlinear_command_z, PID_completely_nonlinear_time, PID_completely_nonlinear_z,'LineWidth',1);
legend('command z','z','Location','northwest');
xlabel('Time (second)');
xlim([0 20]);
ylabel('Z value (meter)');
title('Command z and z in PID control with nonlinear model');
