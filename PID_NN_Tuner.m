%
%% Step 1: Data Preparation
% Load the data
data = load("pid_tuning_data.mat");
% Handle NaN values by removing rows containing NaN
data_table = rmmissing(data_table);

% Define input features and output targets
input_features = data_table(:, {'Setpoint', 'RiseTime', 'SettlingTime', 'Overshoot', 'FinalValue'});
output_targets = data_table(:, {'Kp', 'Ki', 'Kd'});

% Calculate normalization parameters
minVals = min(table2array(input_features));
maxVals = max(table2array(input_features));

% Normalize input features using z-score normalization
input_features = (table2array(input_features) - mean(table2array(input_features))) ./ std(table2array(input_features));
output_targets = table2array(output_targets);

%% Step 2: Define Neural Network Architecture
% Define a network with two hidden layers
inputSize = size(input_features, 2);
outputSize = size(output_targets, 2);
layers = [
    sequenceInputLayer(inputSize)
    fullyConnectedLayer(64, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(outputSize, 'Name', 'fc3')
    regressionLayer('Name', 'output')
];

%% Step 3: Training and Validation Set Creation
% Split the data into training (80%) and validation (20%) sets
cv = cvpartition(size(input_features, 1), 'HoldOut', 0.2);
idxTrain = training(cv);
idxValidation = test(cv);

% Extract training and validation sets
XTrain = input_features(idxTrain, :);
YTrain = output_targets(idxTrain, :);
XValidation = input_features(idxValidation, :);
YValidation = output_targets(idxValidation, :);

%% Step 4: Train the Neural Network
% Define training options
options = trainingOptions('adam', ...
    'MaxEpochs', 1000, ...
    'MiniBatchSize', 32, ...
    'ValidationData', {XValidation', YValidation'}, ...
    'ValidationFrequency', 30, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% Train the network
net = trainNetwork(XTrain', YTrain', layers, options);

%% Step 5: Validate
% After training, use the network to predict on validation data
YPred = predict(net, XValidation');
validationMSE = mean((YPred' - YValidation).^2); % Mean squared error (MSE)
validationRMSE = sqrt(validationMSE); % Root Mean Squared Error (RMSE)

% Display the performance
disp(['Validation MSE: ', num2str(validationMSE)]);
disp(['Validation RMSE: ', num2str(validationRMSE)]);

% Save the trained neural network to a .mat file
save('trainedNet.mat', 'net');

% Save the normalization parameters
save('normalizationParameters.mat', 'minVals', 'maxVals');