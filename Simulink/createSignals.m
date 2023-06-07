clear; clc; close all

amp = 1; % will be scaled in simulink

%% ------------MultiSine-------------------------------
fmin = 0.05; % min frequency for multisine
fmax = 1;    % max frequency for multisine
fs = 1000;
rLen = 300;  %% length of created signal (s) for multisine
nRepeats = 5;

sig = whiteNoiseGen(fs,fmin,fmax,rLen,nRepeats);

%% ------------Chirp-----------------------------------
f0 = 1/20;
f1 = 1/1;
fs = 1000;
initLength = 20;
numseconds = 300;
t = 0:1/fs:numseconds-1/fs;
t1 = numseconds;
chirp = chirp(t,f0,t1,f1);
r = 40/numseconds;
r_win = tukeywin(length(t),r)';
chirp = chirp .* r_win;
chirp = [zeros(1,fs*initLength) chirp];
t = 1/fs:1/fs:length(chirp)/fs;
sig.Chirp = timeseries(chirp,t);
plot(sig.Chirp)


%% ---------------Sine---------------------------------
period = 3; % period for sine wave
sineDuration = 60;
initLength = 20;
t = 1/fs:1/fs:sineDuration;
sine = amp .* sin(2*pi./period*t);
r = 40/t(end);
r_win = tukeywin(length(t),r)';
sine = sine.*r_win;
sine = [zeros(1,fs*initLength) sine zeros(1,fs*initLength)];
t = 1/fs:1/fs:length(sine)/fs;
sig.Sine = timeseries(sine,t);



%% ---------------Combine into input signals---------------------
commandSigs = Simulink.SimulationData.Dataset;
commandSigs = commandSigs.addElement(sig.Sine,'Sine');
commandSigs = commandSigs.addElement(sig.WN1,'WN1');
commandSigs = commandSigs.addElement(sig.WN2,'WN2');
commandSigs = commandSigs.addElement(sig.WN3,'WN3');
commandSigs = commandSigs.addElement(sig.Chirp,'Chirp');
save('commandSignals','commandSigs')

figure

subplot(211)
plot(sig.Sine)
xlabel('time (s)')
ylabel('sine signal')

subplot(212)
plot(sig.WN1)
hold on
plot(sig.WN2)
plot(sig.WN3)
xlabel('time (s)')
ylabel('white noise signal')
legend('WN1','WN2','WN3')
