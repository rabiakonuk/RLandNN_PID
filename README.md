# Hybrid Neural Network and Reinforcement Learning Approach for PID Controller Tuning

This repository contains the implementation of a novel approach to PID controller tuning, leveraging the synergy between Neural Networks (NN) and Reinforcement Learning (RL). Traditional PID tuning techniques may fall short under dynamically changing operational conditions; our method aims to address this by employing NNs for predicting optimal PID settings and RL for adaptively fine-tuning control parameters in response to system behavior.

## System Modeling and Design
The project employs a black-box model of an engine idle speed control system. The model, along with the integration of AI-driven methods with traditional control mechanisms, is developed in a MATLAB/Simulink environment.

### Reference PID Implementation
MATLAB's PID Autotuner is used as a benchmark to compare the performance of our AI-enhanced controllers.
