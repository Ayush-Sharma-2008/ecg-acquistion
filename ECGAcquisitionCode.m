T = readtable('C:\Users\itzay\ecg_rest_confirmed_beat.csv');
T = T(T.leadsoff == 0, :);
t = (T.t_us - T.t_us(1)) / 1e6;
v = T.adc * (3.3/1023);
dt = diff(t);
fs = 1/mean(dt);
fprintf('actual sampling rate: %.2f Hz\n', fs);
figure;
plot(t, v);
ylim([0 3.3]);
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Raw ECG');
xlim([10 13]);
save('ecg_session3_workspace.mat', 'T', 't', 'v')
saveas(gcf, 'ecg_heartbeat_confirmed.png')
%-- 9/3/2026 12:04 PM --%
load('ecg_session3_workspace.mat')
figure;
plot(t, v);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Raw ECG');
xlim([10,15]);
[b, a] = butter(2, [0.5 40]/(fs/2), 'bandpass');
xf = filtfilt(b, a, v);
% Manual 60 Hz notch, no toolbox required
w0 = 2*pi*60/fs;
r = 0.985;
bn = [1, -2*cos(w0), 1];
an = [1, -2*r*cos(w0), r^2];
xf = filtfilt(bn, an, xf);
figure;
subplot(2,1,1);
plot(t, v);
title('Raw');
xlabel('Time (s)');
ylabel('V');
xlim([10 15]);

subplot(2,1,2);
plot(t, xf);
title('Filtered');
xlabel('Time (s)');
ylabel('V');
xlim([10 15]);
saveas(gcf, 'ecg_filtered_comparison.png')