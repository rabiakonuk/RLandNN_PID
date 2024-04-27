% Create the data set for NN w/o having the model of the system

% Define the range of PID parameters to test
% Use a logarithmic scale to sample a wide range of orders of magnitude
% We tried to make an educated-guess here
Kp_range = logspace(-4, -1, 10); % From 0.0001 to 0.1
Ki_range = logspace(-3, 0, 10);  % From 0.001 to 1
Kd_range = logspace(-6, -3, 10); % From 0.000001 to 0.001

% Define setpoints (nominal engine speeds) to test
setpoints = [500, 600, 700, 800];  % Example setpoints

% Initialize the dataset
data = [];

% Load the Simulink model
model = 'PID_IdleSpeed';
load_system(model);

% Specify the block names for the PID controller and setpoint
PID_block = [model '/PID Controller'];
Setpoint_block = [model '/Setpoint'];
% Scope

% Loop through all combinations of PID parameters and setpoints
for Kp = Kp_range
    for Ki = Ki_range
        for Kd = Kd_range
            for Ne = setpoints
                % Update the PID parameters in the Simulink model
                set_param(PID_block, 'P', num2str(Kp));
                set_param(PID_block, 'I', num2str(Ki));
                set_param(PID_block, 'D', num2str(Kd));

                % Set the setpoint value directly
                set_param(Setpoint_block, 'Value', num2str(Ne));

                % Run the Simulink model
                simOut = sim(model, 'SimulationMode', 'normal');

                % Access the logged data for 'Setpoint' and 'TransferFcn'
                setpointData = simOut.logsout.get('SetpointSignal').Values.Data;
                outputData = simOut.logsout.get('TransferFcnSignal').Values.Data;

                % Compute performance metrics
                S = stepinfo(outputData, simOut.logsout.get('TransferFcnSignal').Values.Time, Ne);

                % Append to dataset
                data = [data; Kp, Ki, Kd, Ne, S.RiseTime, S.SettlingTime, S.Overshoot, outputData(end)];
            end
        end
    end
end

% Convert to table for better readability
data_table = array2table(data, ...
    'VariableNames', {'Kp', 'Ki', 'Kd', 'Setpoint', 'RiseTime', 'SettlingTime', 'Overshoot', 'FinalValue'});

% Save dataset to file
save('pid_tuning_data.mat', 'data_table');

% Unload the model
% unload_system(model);