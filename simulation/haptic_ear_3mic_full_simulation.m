% HAPTIC EAR – 3 MIC SYSTEM
% PRESENTATION-GRADE: BASELINE vs AI COMPARISON
% Explicit visualization of AI impact

clc; clear; close all;

%% ================= 1. PARAMETERS =================
fs = 8000;
T  = 5;
t  = 0:1/fs:T-1/fs;

ADC_BITS = 12;
ADC_MAX  = 2^ADC_BITS - 1;

f_horn  = 440;
f_voice = 250;

alpha_fast = 0.15;
alpha_slow = 0.005;

fixed_threshold = 0.02;
base_threshold  = 0.02;

min_on_time = round(0.02 * fs);
max_pwm = 255;

%% ================= 2. SIGNAL GENERATION =================
horn_pulse = (square(2*pi*4*t) > 0) .* (t > 0.5 & t < 1.5);
horn = sin(2*pi*f_horn*t) .* horn_pulse;

voice_env = exp(-5*(t-3).^2);
voice = sin(2*pi*f_voice*t) .* (t > 2.5 & t < 3.5) .* voice_env;

glitch = zeros(size(t));
gidx = find(t > 4.2,1);
glitch(gidx:gidx+5) = 2.0;

noise_amp = zeros(size(t));
noise_amp(t<2)=0.02;
noise_amp(t>=2 & t<4)=0.08;
noise_amp(t>=4)=0.15;
noise = noise_amp .* randn(size(t));

mic.L = horn + 0.2*voice + noise + glitch;
mic.R = 0.3*horn + 0.9*voice + noise + 0.5*glitch;
mic.F = 0.6*horn + 0.5*voice + noise + glitch;

%% ================= 3. ADC & NORMALIZATION =================
adc = @(x) min(max(round((x+1)/2*ADC_MAX),0),ADC_MAX);

for ch = ["L","R","F"]
    adc_out.(ch) = adc(mic.(ch));
    dc.(ch) = mean(adc_out.(ch)(1:round(0.2*fs)));
    sig.(ch) = abs(adc_out.(ch)-dc.(ch))/ADC_MAX;
end

%% ================= 4. ENVELOPE & ENERGY =================
fast = struct('L',0,'R',0,'F',0);
slow = fast;

energy = struct('L',zeros(size(t)), ...
                'R',zeros(size(t)), ...
                'F',zeros(size(t)));

hist_fast_L = zeros(size(t));
hist_slow_L = zeros(size(t));

for n=2:length(t)
    for ch=["L","R","F"]
        fast.(ch) = alpha_fast*sig.(ch)(n) + (1-alpha_fast)*fast.(ch);
        slow.(ch) = alpha_slow*fast.(ch) + (1-alpha_slow)*slow.(ch);
        energy.(ch)(n) = max(fast.(ch)-slow.(ch),0);
    end
    hist_fast_L(n) = fast.L;
    hist_slow_L(n) = slow.L;
end

%% ================= 5. BASELINE SYSTEM =================
pwm_base = struct('L',zeros(size(t)), ...
                  'R',zeros(size(t)), ...
                  'F',zeros(size(t)));
cnt = 0;

for n=1:length(t)
    [mx,idx] = max([energy.L(n),energy.R(n),energy.F(n)]);
    if mx > fixed_threshold
        cnt = cnt+1;
    else
        cnt = 0;
    end
    
    if cnt > min_on_time
        strength = min(mx*10*max_pwm,max_pwm);
        if idx==1, pwm_base.L(n)=strength; end
        if idx==2, pwm_base.R(n)=strength; end
        if idx==3, pwm_base.F(n)=strength; end
    end
end

%% ================= 6. AI SYSTEM =================
env_energy = (energy.L + energy.R + energy.F)/3;
adaptive_threshold = base_threshold + 0.6*movmean(env_energy,fs);

priority = ones(size(t));
for n=1:length(t)
    if max([energy.L(n),energy.R(n),energy.F(n)]) > 0.15
        priority(n)=3;      % Alarm / horn
    elseif abs(sig.L(n)-sig.R(n))>0.02
        priority(n)=2;      % Voice-like
    end
end
priority_gain = [0.5 1.0 1.6];

pwm_ai = struct('L',zeros(size(t)), ...
                'R',zeros(size(t)), ...
                'F',zeros(size(t)));
cnt = 0;

for n=1:length(t)
    [mx,idx] = max([energy.L(n),energy.R(n),energy.F(n)]);
    if mx > adaptive_threshold(n)
        cnt = cnt+1;
    else
        cnt = 0;
    end
    
    if cnt > min_on_time && priority(n)>1
        strength = min(mx*priority_gain(priority(n))*max_pwm,max_pwm);
        if idx==1, pwm_ai.L(n)=strength; end
        if idx==2, pwm_ai.R(n)=strength; end
        if idx==3, pwm_ai.F(n)=strength; end
    end
end

%% ================= 7. METRICS =================
alerts_base = sum(pwm_base.L>0 | pwm_base.R>0 | pwm_base.F>0);
alerts_ai   = sum(pwm_ai.L>0   | pwm_ai.R>0   | pwm_ai.F>0);

fprintf('\nBASELINE ALERTS: %d\n',alerts_base);
fprintf('AI ALERTS:       %d\n',alerts_ai);

%% ================= 8. PLOTS =================
figure('Position',[80 50 1300 900]);

subplot(4,2,1)
plot(t,sig.L,'Color',[0.6 0.6 0.6]); hold on
xline(4.2,'r:','GLITCH');
title('Raw Normalized Mic Signal (Left)');
ylabel('Amplitude'); grid on

subplot(4,2,2)
plot(t,hist_fast_L,'b','LineWidth',1.5); hold on
plot(t,hist_slow_L,'r--','LineWidth',2)
title('Envelope vs Noise Floor (Left)');
legend('Fast Envelope','Noise Floor'); grid on

subplot(4,2,3)
plot(t,energy.L,'b',t,energy.R,'r',t,energy.F,'g','LineWidth',1.3)
title('Effective Energy (Noise Removed)');
ylabel('Energy'); legend('Left','Right','Front'); grid on

subplot(4,2,4)
plot(t,fixed_threshold*ones(size(t)),'k--','LineWidth',1.5); hold on
plot(t,adaptive_threshold,'m','LineWidth',2)
title('Fixed Threshold vs AI Adaptive Threshold');
legend('Fixed','AI Adaptive'); grid on

subplot(4,2,5)
area(t,pwm_base.L,'FaceAlpha',0.3); hold on
area(t,pwm_base.R,'FaceAlpha',0.3)
area(t,pwm_base.F,'FaceAlpha',0.3)
title('Baseline Output (False Alerts Present)');
ylabel('PWM'); ylim([0 260]); grid on

subplot(4,2,6)
area(t,pwm_ai.L,'FaceAlpha',0.3); hold on
area(t,pwm_ai.R,'FaceAlpha',0.3)
area(t,pwm_ai.F,'FaceAlpha',0.3)
title('AI Output (Prioritized & Clean)');
ylabel('PWM'); ylim([0 260]); grid on

subplot(4,2,7)
stairs(t,priority,'m','LineWidth',2)
ylim([0 4])
yticks([1 2 3])
yticklabels({'Noise','Voice','Alarm'})
title('AI Sound Priority Classification');
xlabel('Time (s)'); grid on

subplot(4,2,8)
bar([alerts_base alerts_ai])
set(gca,'XTickLabel',{'Baseline','AI'})
title('Total Alerts Comparison');
ylabel('Alert Count'); grid on
