clc;
clear;
close all;

%% -------------------------------
% BASIC SIGNAL SETUP (BEGINNER SAFE)
%% -------------------------------
fs = 16000;                    % Sampling frequency
t = 0:1/fs:2;                  % 2 seconds duration

% Simulated sounds
horn = 0.8*sin(2*pi*600*t);    % Vehicle horn (danger sound)
noise = 0.2*randn(size(t));    % Background noise
combinedSignal = horn + noise;

%% -------------------------------
% PLOT 1: RAW SOUND INPUT
% (What the jacket microphones hear)
%% -------------------------------
figure;
plot(t, combinedSignal);
title('Sound Captured by Microphones');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

%% -------------------------------
% PLOT 2: COMPARING DANGER VS NOISE
% (Why AI is needed)
%% -------------------------------
figure;
subplot(2,1,1);
plot(t, horn);
title('Danger Sound: Vehicle Horn');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t, noise);
title('Background Noise');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

%% -------------------------------
% FEATURE EXTRACTION (EDGE FRIENDLY)
%% -------------------------------
frameSize = 400;
energy = buffer(combinedSignal, frameSize);
energyFeature = rms(energy);

%% -------------------------------
% PLOT 3: SOUND ENERGY OVER TIME
% (What Edge AI actually sees)
%% -------------------------------
figure;
plot(energyFeature);
yline(0.35,'r--','Danger Threshold');
title('Sound Energy Detected by Edge AI');
xlabel('Audio Frame Number');
ylabel('Energy Level');
grid on;

%% -------------------------------
% EDGE AI DECISION
%% -------------------------------
dangerDetected = energyFeature > 0.35;

%% -------------------------------
% PLOT 4: EDGE AI CLASSIFICATION
% (Simple yes/no decision)
%% -------------------------------
figure;
stem(dangerDetected,'filled');
title('Edge AI Output (TensorFlow Lite Simulation)');
xlabel('Audio Frame');
ylabel('Detection Result');
yticks([0 1]);
yticklabels({'Safe','Danger'});
grid on;

%% -------------------------------
% FLUTTER APP PARAMETERS
%% -------------------------------
userSensitivity = 0.7;  % User-controlled slider

hapticOutput = dangerDetected * userSensitivity;

%% -------------------------------
% PLOT 5: HAPTIC FEEDBACK INTENSITY
% (What the user feels)
%% -------------------------------
figure;
plot(hapticOutput,'LineWidth',1.5);
title('Haptic Feedback Intensity');
xlabel('Time Frame');
ylabel('Vibration Strength');
grid on;

%% -------------------------------
% GOOGLE MAPS HEATMAP DATA
%% -------------------------------
lat = 12.9716 + 0.01*randn(1,100);
lon = 77.5946 + 0.01*randn(1,100);
risk = abs(randn(1,100));

%% -------------------------------
% PLOT 6: CITY NOISE HAZARD HEATMAP
% (Google Maps integration concept)
%% -------------------------------
figure;
scatter(lon, lat, 80, risk, 'filled');
colorbar;
title('Noise Hazard Heatmap of the City');
xlabel('Longitude');
ylabel('Latitude');
grid on;
