
%% 1 Create the Environment Interface

open_system('PID_IdleSpeed')

% Nominal Engine Speed as the setpoint
Ne = 700; % Setpoint for Idle Speed

obsInfo = rlNumericSpec([3 1], 'LowerLimit', [-inf -inf 0]', 'UpperLimit', [inf inf inf]');
obsInfo.Name = "observations";
obsInfo.Description = "integrate error, error, and derivative error";

actInfo = rlNumericSpec([3 1], 'LowerLimit', [-1 -1 -1]', 'UpperLimit', [1 1 1]');
actInfo.Name = "Kp, Ki, Kd values";

% Define the environment
env = rlSimulinkEnv('PID_IdleSpeed','PID_IdleSpeed/RL Agent1',...
    obsInfo,actInfo);

% Reset function to initialize the simulation
env.ResetFcn = @(in)localResetFcn(in, Ne);

% Define the sample time for the RL problem
Ts = 0.0001; 
Tf = 2;

rng(0)

%% 2 Create the critic 

statePath = [
    featureInputLayer(obsInfo.Dimension(1),Name="netObsIn")
    fullyConnectedLayer(50)
    reluLayer
    fullyConnectedLayer(25,Name="CriticStateFC2")];

actionPath = [
    featureInputLayer(actInfo.Dimension(1),Name="netActIn")
    fullyConnectedLayer(25,Name="CriticActionFC1")];

commonPath = [
    additionLayer(2,Name="add")
    reluLayer
    fullyConnectedLayer(1,Name="CriticOutput")];

criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork,statePath);
criticNetwork = addLayers(criticNetwork,actionPath);
criticNetwork = addLayers(criticNetwork,commonPath);

criticNetwork = connectLayers(criticNetwork, ...
    "CriticStateFC2", ...
    "add/in1");
criticNetwork = connectLayers(criticNetwork, ...
    "CriticActionFC1", ...
    "add/in2");

figure
plot(criticNetwork)

criticNetwork = dlnetwork(criticNetwork);
summary(criticNetwork)

critic = rlQValueFunction(criticNetwork,obsInfo,actInfo, ...
    ObservationInputNames="netObsIn", ...
    ActionInputNames="netActIn");

getValue(critic, ...
    {rand(obsInfo.Dimension)}, ...
    {rand(actInfo.Dimension)})

%% Create the Actor
actorNetwork = [
    featureInputLayer(obsInfo.Dimension(1))
    fullyConnectedLayer(3)
    tanhLayer
    fullyConnectedLayer(actInfo.Dimension(1))
    ];

% Convert the network to a dlnetwork object and summarize its properties.
actorNetwork = dlnetwork(actorNetwork);
summary(actorNetwork)

% Create the actor approximator object
actor = rlContinuousDeterministicActor(actorNetwork,obsInfo,actInfo);

% Check the actor with a random input observation.
getAction(actor,{rand(obsInfo.Dimension)})

%% Create the DDPG Agent

agent = rlDDPGAgent(actor,critic);

agent.SampleTime = Ts;

agent.AgentOptions.TargetSmoothFactor = 1e-3;
agent.AgentOptions.DiscountFactor = 1.0;
agent.AgentOptions.MiniBatchSize = 64;
agent.AgentOptions.ExperienceBufferLength = 1e6; 

agent.AgentOptions.CriticOptimizerOptions.LearnRate = 1e-02;
agent.AgentOptions.CriticOptimizerOptions.GradientThreshold = 1;
agent.AgentOptions.ActorOptimizerOptions.LearnRate = 1e-03;
agent.AgentOptions.ActorOptimizerOptions.GradientThreshold = 1;

getAction(agent,{rand(obsInfo.Dimension)})

%% Train Agent

% disp("Environment action space: " + actInfo)
% disp("Agent action space: " + agent.ActionInfo)

trainOpts = rlTrainingOptions(...
    MaxEpisodes=100, ...
    MaxStepsPerEpisode=ceil(Tf/Ts), ...
    ScoreAveragingWindowLength=10, ...
    Verbose=false, ...
    Plots="training-progress",...
    StopTrainingCriteria ="AverageReward",...
    StopTrainingValue=200);

doTraining = true;

if doTraining
    % Train the agent.
    trainingStats = train(agent,env,trainOpts);
else
    % Load the pretrained agent for the example.
    load("PID_IdleSpeed.mat","agent")
end

%% Validate Trained Agent

simOpts = rlSimulationOptions(MaxSteps=ceil(Tf/Ts),StopOnError="on");
experiences = sim(env,agent,simOpts);

%% Save Trained Agent and Training Statistics

% Choose a file name for saving the trained agent
saveFileName = 'trainedAgent.mat';

% Save the trained agent to the file
save(saveFileName, 'agent', 'trainingStats');

%% Supporting functions
function in = localResetFcn(in, Ne)
    % Set the setpoint for the RL environment
    in = setVariable(in, 'Ne', Ne, 'Workspace', 'base');
    
    % Define the range for the initial error
    initialError = Ne - 0; % Assuming 0 is the initial output of the system

    % Initialize the integral of error and derivative of error
    initialIntegralError = 0; % Assuming no initial integral error
    initialDerivativeError = 0; % Assuming no initial derivative error

    % Set the initial conditions for the RL environment
    in = setVariable(in, 'initialError', initialError, 'Workspace', 'base');
    in = setVariable(in, 'initialIntegralError', initialIntegralError, 'Workspace', 'base');
    in = setVariable(in, 'initialDerivativeError', initialDerivativeError, 'Workspace', 'base');
end
