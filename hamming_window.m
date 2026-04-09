% =========================================================================
% Effect of Hamming window on spectral leakage
% Developed for visualization in linear algebra project report *.*
% =========================================================================
clear; clc; close all;

N = 512;              % frame length
n = 0:N-1;            % sample index

%% 1. discrete time-domain frame x[n]
% applies a freq that doesnt fit exactly into an integer number of cycles 
% to induce spectral leakage (and some low-level random noise too)
f0 = 10.5; 
x = sin(2*pi*f0*n/N) + 0.05*randn(1, N); 

%% 2. window w[n]
% rectangle
w_rect = zeros(1, N);
w_rect(150:350) = 1;

% hamming
w_hamm = 0.54 - 0.46 * cos(2*pi*n / (N-1));

%% 3. multiply
% rectangle
x_rect = x .* w_rect;

% hamming
x_hamm = x .* w_hamm;

%% 4. ffft to calculate freq spectra |Xk|
X_rect_dB = 20*log10(abs(fft(x_rect)) / max(abs(fft(x_rect))));
X_hamm_dB = 20*log10(abs(fft(x_hamm)) / max(abs(fft(x_hamm))));
freq_axis = 0:(N/2-1);

%% 5. visualization
figure('Position', [50, 100, 1300, 750], 'Color', 'w');

% --- row 1: x[n] ---
subplot(3, 3, 1); plot(n, x, 'k', 'LineWidth', 1.1); 
title('Original Signal $x[n]$', 'Interpreter', 'latex');
ylabel('Amplitude'); axis tight; ylim([-1.5 1.5]); grid on;

subplot(3, 3, 2); plot(n, x, 'k', 'LineWidth', 1.1); 
title('Original Signal $x[n]$', 'Interpreter', 'latex');
axis tight; ylim([-1.5 1.5]); grid on;

% --- row 2: w[n] ---
subplot(3, 3, 4); plot(n, w_rect, 'b', 'LineWidth', 1.5); 
title('Rectangular Window $w[n]$', 'Interpreter', 'latex');
ylabel('Amplitude'); axis tight; ylim([-0.1 1.1]); grid on;

subplot(3, 3, 5); plot(n, w_hamm, 'r', 'LineWidth', 1.5); 
title('Hamming Window $w[n]$', 'Interpreter', 'latex');
axis tight; ylim([-0.1 1.1]); grid on;

% --- row 3: x[n] * w[n] ---
subplot(3, 3, 7); plot(n, x_rect, 'b', 'LineWidth', 1.2); 
title('Windowed Signal', 'Interpreter', 'latex');
xlabel('Sample index $n$', 'Interpreter', 'latex'); ylabel('Amplitude');
axis tight; ylim([-1.5 1.5]); grid on;

subplot(3, 3, 8); plot(n, x_hamm, 'Color', [0.5 0 0.8], 'LineWidth', 1.2); 
title('Windowed Signal', 'Interpreter', 'latex');
xlabel('Sample index $n$', 'Interpreter', 'latex');
axis tight; ylim([-1.5 1.5]); grid on;

% ||| |Xk| |||
subplot(3, 3, [3, 6, 9]);
plot(freq_axis, X_rect_dB(1:N/2), 'b', 'LineWidth', 1.2); hold on;
plot(freq_axis, X_hamm_dB(1:N/2), 'Color', [0.5 0 0.8], 'LineWidth', 1.5);
title('Frequency Spectrum $|X_k|$', 'Interpreter', 'latex', 'FontSize', 13);
xlabel('Frequency Bin $k$', 'Interpreter', 'latex'); ylabel('Magnitude (dB)');
legend('Rectangular Window', 'Hamming Window', 'Location', 'northeast', 'Interpreter', 'latex');
grid on; xlim([0 40]); ylim([-60 5]);