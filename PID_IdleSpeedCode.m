%% By Mohammadreza Maleki
%% a Controller for Engine Idle Speed
%% Sec.1 Nominal Engine Speed
close All
clear 
clc
digits(6);
syms dWa Da Dp Dn Df Wa Dd DTl dDp dDn s
Ne=500; %Nominal Engine Speed

%% Sec.2 Typical parameters of an six-cylinder-engine idle speed

Ka=20;         
Kpm=0.776;
Kn=0.08;
tp=0.21;
Kr=67.2;
tr=3.98;
Hp=13.37;
Hd=10;
Hf=36.6;
T=0.033;

%% Sec.3 State Space & Transfer Function Models

dWa=Ka*Da; % The airflow rate
dDp=(-Dp/tp)+(Kpm*Ka*Da)-(Kpm*Kn*Dn); % The intake manifold pressure
dDn=(-Dn/tr)+Kr*((Hp*Dp)+(Hf*Df)+(Hd*Dd)-(DTl)); % The rotational dynamics model


dX =[dWa;dDp;dDn];
a=[diff(dWa,Wa) diff(dDp,Wa) diff(dDn,Wa) ;diff(dWa,Dp) diff(dDp,Dp)  diff(dDn,Dp); diff(dWa,Dn) diff(dDp,Dn)  diff(dDn,Dn)];
A=vpa(a');
X = [Wa;Dp;Dn];
b1=[diff(dWa,Da) diff(dDp,Da) diff(dDn,Da) ;diff(dWa,Dd) diff(dDp,Dd)  diff(dDn,Dd); diff(dWa,Df) diff(dDp,Df)  diff(dDn,Df)];
B=vpa(b1');
b2=[diff(dWa,DTl) diff(dDp,DTl) diff(dDn,DTl)];
b=vpa(b2');
v=DTl;
C=[0 0 1];
D=[0 0 0];
A1=double(A);
B1=double(B);
C1=double(C);
D1=double(D);
sys=ss(A1,B1,C1,D1);
[NUM,DUM]=ss2tf(A1,B1,C1,D1,3);
Gp=minreal(tf(NUM,DUM)) %Minreal Transfer Function
[NUM,DUM]=tfdata(Gp);
NUM=cell2mat(NUM);
DUM=cell2mat(DUM);

%% Sec.4 Designing a PID COntroller
Kp=0.0102080595074629; % Proportional gain
Ki=0.10944345575242; % Integral gain
Kd=0.000138654213001405; % Derivative gain
c = pid(Kp,Ki,Kd);
G_c=tf(c);
[NUM_c,DUM_c]=tfdata(G_c);
NUM_c=cell2mat(NUM_c);
DUM_c=cell2mat(DUM_c);

%% Sec.5 PID in a Loop with Tf and feedback=1
NUMGs=(conv(NUM_c,NUM));
DUMGs=(conv(DUM_c,DUM));
%Gs=minreal(tf(NUMGs,DUMGs))
Gs=tf(NUMGs,DUMGs)
Gsc=feedback(Gs,1) %feedback = 1

%% Sec.6 Simulation
t = 0:0.0001:2;
U = Ne * ones(size(t));
[Y1,t,X1]=lsim(Gsc,U,t);

%% Sec.7 Figure

% figure
% plot(t,Y1,'r');
% hold on;
% plot(t,U,'-. b');
% xlabel('Time (seconds)')
% ylabel('Engine Idle Speed (RPM)')
% xlim ([0 max(t)]) ;
% ylim([0 (1.1*Ne)]);
% grid on

% é : Updated Figure with Metrics

figure
plot(t,Y1,'r', 'LineWidth', 2); % Make the response line thicker
hold on;
plot(t,U,'-.b', 'LineWidth', 1); % Make the setpoint line a little thinner for contrast

% Annotate the graph with performance metrics
S = stepinfo(Gsc); % Get step response characteristics

% Overshoot
if S.Overshoot > 0
    line([S.RiseTime S.RiseTime], [Ne Ne*(1+S.Overshoot/100)], 'Color', 'g', 'LineStyle', '--');
    text(S.RiseTime, Ne*(1+S.Overshoot/100), sprintf('Overshoot: %.2f%%', S.Overshoot), 'VerticalAlignment', 'bottom');
end

% Rise Time
line([0 S.RiseTime], [Ne*1.02 Ne*1.02], 'Color', 'b', 'LineStyle', '--');
text(S.RiseTime/2, Ne*1.02, sprintf('Rise Time: %.2fs', S.RiseTime), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');

% Settling Time
line([S.SettlingTime S.SettlingTime], [0 Ne], 'Color', 'k', 'LineStyle', '--');
text(S.SettlingTime, Ne/2, sprintf('Settling Time: %.2fs', S.SettlingTime), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

% Steady State Error
ss_error = abs(1 - Y1(end)/Ne);
line([max(t)-0.5 max(t)], [Y1(end) Y1(end)], 'Color', 'm', 'LineStyle', '--');
text(max(t), Y1(end), sprintf('Steady State Error: %.2f%%', ss_error*100), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

% Annotations
title('Engine Idle Speed Control Performance');
xlabel('Time (seconds)')
ylabel('Engine Idle Speed (RPM)')
xlim ([0 max(t)]);
ylim([0 (1.1*Ne)]);
legend('Engine Speed Response', 'Nominal Engine Speed', 'Location', 'Best');

% Add grid
grid on;

