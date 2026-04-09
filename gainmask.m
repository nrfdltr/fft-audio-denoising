% =========================================================================
% Spectral Subtraction Gain Mask Analysis
% Demonstrates the tripathi et al. tuning parameters (\alpha and \beta) >:3
% =========================================================================
clear; clc; close all;

%% 1. theory of gain
% gamma = |X_k| / |N_k|
% gamma low -> mostly noise
% gamma high -> speech
gamma = linspace(1, 15, 1000); 

% alpha
alpha_vals = [1.0, 3.0, 5.0];
beta_fixed = 0.01;
G_alpha_sweep = zeros(length(alpha_vals), length(gamma));
for i = 1:length(alpha_vals)
    G_alpha_sweep(i, :) = max(1 - alpha_vals(i) ./ gamma, beta_fixed);
end

% beta
alpha_fixed = 5.0;
beta_vals = [0.00, 0.05, 0.15];
G_beta_sweep = zeros(length(beta_vals), length(gamma));
for i = 1:length(beta_vals)
    G_beta_sweep(i, :) = max(1 - alpha_fixed ./ gamma, beta_vals(i));
end

%% 2. simulation
N = 512;
freq_axis = 0:(N/2-1);

% bg noise
N_mag_est = 0.2 + 0.05 * rand(1, N/2);
mean_N = mean(N_mag_est);

% speech spikes
S_mag = zeros(1, N/2);
S_mag(30) = 4.0; S_mag(80) = 2.5; S_mag(150) = 1.8; 

% |X_k|
X_mag = S_mag + N_mag_est;

% tripathi gain formula, woth alpha = 5.0, beta = 0.01
G_k = max(1 - alpha_fixed .* (mean_N ./ X_mag), beta_fixed);

% |S_k|
S_clean = G_k .* X_mag;

%% 3. visualization
figure('Position', [50, 100, 1200, 750], 'Color', 'w');

% --- top left ---
subplot(2, 2, 1); hold on;
colors_alpha = {'#0072bd', '#d95319', '#7e2f8e'};
for i = 1:length(alpha_vals)
    plot(gamma, G_alpha_sweep(i, :), 'Color', colors_alpha{i}, 'LineWidth', 2);
end
title('Effect of Over-subtraction Factor ($\alpha$)', 'Interpreter', 'latex', 'FontSize', 13);
xlabel('Signal-to-Noise Magnitude $\frac{|X_k|}{|\hat{N}_k|}$, with $\beta = 0.01$', 'Interpreter', 'latex');
ylabel('Gain $G_k$', 'Interpreter', 'latex');
legend('\alpha = 1.0', '\alpha = 3.0', '\alpha = 5.0', 'Location', 'southeast');
grid on; ylim([0 1.1]);

% --- top right ---
subplot(2, 2, 2); hold on;
colors_beta = {'#fa82e4', '#edb120', '#77ac30'};
for i = 1:length(beta_vals)
    plot(gamma, G_beta_sweep(i, :), 'Color', colors_beta{i}, 'LineWidth', 2);
end
title('Effect of Spectral Floor ($\beta$)', 'Interpreter', 'latex', 'FontSize', 13);
xlabel('Signal-to-Noise Magnitude $\frac{|X_k|}{|\hat{N}_k|}$, with $\alpha = 5.0$', 'Interpreter', 'latex');
ylabel('Gain $G_k$', 'Interpreter', 'latex');
legend('\beta = 0.00', '\beta = 0.05', '\beta = 0.15', 'Location', 'southeast');
grid on; ylim([0 1.1]);

% --- bottom left---
subplot(2, 2, 3);
plot(freq_axis, X_mag, 'b', 'LineWidth', 1.2); hold on;
yline(mean_N * alpha_fixed, 'r--', 'LineWidth', 1);
title('Noisy Spectrum $|X_k|$ vs. Threshold', 'Interpreter', 'latex', 'FontSize', 13);
xlabel('Frequency Bin $k$', 'Interpreter', 'latex'); ylabel('Magnitude');
legend('Noisy Signal $|X_k|$', 'Threshold ($\alpha \cdot |\hat{N}_k|$)', 'Interpreter', 'latex');
grid on; axis tight; ylim([0 4.5]);

% --- bottom right ---
subplot(2, 2, 4);
yyaxis left; % plot clean signal
plot(freq_axis, S_clean, 'Color', [0 0.6 1], 'LineWidth', 3); % Purple
ylabel('Cleaned Magnitude $|\hat{S}_k|$', 'Interpreter', 'latex');
ylim([0 4.5]);

yyaxis right; % plot gain
plot(freq_axis, G_k, 'Color', [1 0.5 0], 'LineWidth', 0.1);
ylabel('Applied Gain $G_k$', 'Interpreter', 'latex');
ylim([0 1.1]);

title('Reconstructed Spectrum and Gain Profile', 'Interpreter', 'latex', 'FontSize', 13);
xlabel('Frequency Bin $k$', 'Interpreter', 'latex');
legend('Cleaned Speech $|\hat{S}_k|$', 'Gain $G_k$', 'Interpreter', 'latex');
grid on; axis tight;