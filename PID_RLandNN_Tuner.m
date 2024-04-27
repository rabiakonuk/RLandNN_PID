%% PID_RLandNN_Tuner.m
% Script to deploy the trained RL agent and NN for tuning the PID controller

% Load the trained RL agent and NN
load('trainedAgent.mat', 'agent');
load('trainedNet.mat', 'net');

% Load the Simulink model (replace with your actual model name)
model = 'PID_IdleSpeed';
load_system(model);

% Define the setpoint for the simulation
setpoint = 700; % Nominal Engine Speed as the setpoint
Ne = setpoint;

% Set the simulation time based on the original time vector used with lsim
% original time vector: t = 0:0.0001:2;
simTime = 2; % Simulation time in seconds

% Update the setpoint in the Simulink model
set_param([model '/Setpoint3'], 'Value', num2str(setpoint));

% Set the simulation options
simOptions = simset('SrcWorkspace', 'current', 'FixedStep', '0.0001');

% Start the simulation
out = sim(model, 'SimulationMode', 'normal', 'StopTime', num2str(simTime), simOptions);

% After simulation, retrieve the logged data for analysis
logsout = sim(model, 'ReturnWorkspaceOutputs', 'on').logsout;

% Analyze the error signal
errorSignal = logsout.getElement('error').Values.Data;

% Control effort
controlEffort = logsout.getElement('controlEffort').Values.Data;

% Observations used by RL Agent
observations = logsout.getElement('observations').Values.Data;

% Instantaneous rewards
rewards = logsout.getElement('reward').Values.Data;

% PID parameters adjusted by RL agent
Kp_RL = logsout.getElement('out.Kp').Values.Data;
Ki_RL = logsout.getElement('out.Ki').Values.Data;
Kd_RL = logsout.getElement('out.Kd').Values.Data;

% Performance metrics
performanceMetrics = logsout.getElement('performanceMetrics').Values.Data;

% PID parameters suggested by NN
Kp_NN = logsout.getElement('Kp').Values.Data; 
Ki_NN = logsout.getElement('Ki').Values.Data;
Kd_NN = logsout.getElement('Kd').Values.Data;

% Plant output
plantOutput = logsout.getElement('Y(s)').Values.Data;

% Compute performance metrics
mse = mean((errorSignal - Ne).^2);
iae = sum(abs(errorSignal - Ne)) * simOptions.FixedStep;
ise = sum((errorSignal - Ne).^2) * simOptions.FixedStep;
itae = sum(abs(errorSignal - Ne) .* out.tout) * simOptions.FixedStep;

% Extract performance metrics from the simulation
settlingTime_NN = performanceMetrics(1); 
riseTime_NN = performanceMetrics(2);      
overshoot_NN = performanceMetrics(3);     
steadyStateError_NN = abs(performanceMetrics(4) - Ne); 

% Display the performance results
fprintf('Performance with NN tuning:\n');
fprintf('MSE: %.4f\nIAE: %.4f\nISE: %.4f\nITAE: %.4f\n', mse, iae, ise, itae);
fprintf('Settling Time: %.2f sec\nRise Time: %.2f sec\nOvershoot: %.2f%%\nSteady State Error: %.2f RPM\n', ...
        settlingTime_NN, riseTime_NN, overshoot_NN, steadyStateError_NN);

% Plotting performance over time
figure;
plot(out.tout, errorSignal);
title('Error Over Time');
xlabel('Time (seconds)');
ylabel('Error (RPM)');
grid on;

% Save the performance results
save('PerformanceMetrics.mat', 'mse', 'iae', 'ise', 'itae', 'settlingTime_NN', 'riseTime_NN', 'overshoot_NN', 'steadyStateError_NN');