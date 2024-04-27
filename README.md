# Hybrid Neural Network and Reinforcement Learning Approach for PID Controller Tuning

This repository is part of a research initiative that focuses on augmenting the traditional Proportional-Integral-Derivative (PID) controller tuning process with advanced machine learning techniques. It specifically explores the potential of combining Neural Networks (NNs) with Reinforcement Learning (RL) to optimize PID controllers under conditions that are dynamic and unpredictable - a scenario where classical tuning methodologies might not suffice.

## System Modeling and Design

The core of this project is a model that simulates an engine idle speed control system, which has been traditionally challenging due to its nonlinear characteristics and sensitivity to operational conditions. By adopting a black-box approach, the model allows the integration of AI-driven methods with conventional control mechanisms in a MATLAB/Simulink environment. This setup provides a fertile testing ground for our hybrid NN and RL-based tuning strategy.

### Reference PID Implementation

As a comparative benchmark, we employ MATLAB's PID Autotuner, a tool that automatically adjusts PID parameters by observing the system's response. This helps to set a performance baseline against which the AI-enhanced controllers' effectiveness can be measured. For more information on the MATLAB PID Autotuner, please refer to the official [MathWorks documentation](https://www.mathworks.com/help/control/ug/pid-controller-tuning-in-simulink.html).

## Background and Motivation

PID controllers are ubiquitous in control systems engineering, yet their tuning can be intricate, especially when dealing with systems where the operating conditions are in constant flux. The synergy between NNs and RL presents an opportunity to develop a control system that not only self-optimizes in real time but also learns and adapts from the system's performance history.

This repository takes inspiration from and builds upon an existing model for PID engine idle speed control, which can be found at the following repository:
[PID_EngineIdle_Speed by Mr. Maleki](https://github.com/mrmaleki1376/PID_EngineIdle_Speed/tree/main).

We extend this foundational work by incorporating a neural network to predict optimal PID settings and an RL algorithm that fine-tunes these parameters adaptively, catering to the intricate demands of modern control systems.

## Research Objective

The ambition driving this research is to construct a PID tuning system that exemplifies both robustness and adaptability, making it well-suited to the complexities of contemporary and future control system applications. By sharing our progress and methodology through this repository, we invite the academic and professional communities to explore the viability and effectiveness of AI in enhancing PID controller tuning.
