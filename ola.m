% =========================================================================
% OVERLAP-ADD METHOD FOR NORMALIZING
% Developed for visualization in linear algebra project report
% =========================================================================
clear; clc; close all;

%% 1. variables
N = 256;                        
H = N / 2;                      
num_frames = 6;                 
total_len = (num_frames-1)*H + N; 
n = 1:total_len;                

%% 2. input signal
x_original = sin(2*pi*0.015*n);
w = 0.54 - 0.46 * cos(2*pi*(0:N-1) / (N-1)); % hamming

%% 3. math
x_unnorm = zeros(1, total_len); 
W_sum = zeros(1, total_len);    
frames_matrix = NaN(num_frames, total_len);
windows_matrix = NaN(num_frames, total_len);

for m = 0:num_frames-1
    start_n = m*H + 1;
    end_n = start_n + N - 1;
    
    x_m = x_original(start_n:end_n) .* w;
    frames_matrix(m+1, start_n:end_n) = x_m;
    windows_matrix(m+1, start_n:end_n) = w;
    
    x_unnorm(start_n:end_n) = x_unnorm(start_n:end_n) + x_m;
    W_sum(start_n:end_n) = W_sum(start_n:end_n) + w;
end

x_final = x_unnorm ./ W_sum; 

%% 4. visualization
figure('Position', [50, 50, 1100, 950], 'Color', 'w');
colors = lines(num_frames); 
c_black = 'k';
c_blue = [0, 0.4470, 0.7410];
c_orange = [0.8500, 0.3250, 0.0980];
c_gray = [0.8, 0.8, 0.8];

% --- row 1:input signal ---
ax1 = subplot(4, 2, [1, 2]); 
plot(n, x_original, 'Color', c_black, 'LineWidth', 2, 'LineStyle', '-');
title('1. Continuous Input Signal $x[n]$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Amplitude'); axis tight; ylim([-1.2 1.2]); grid on;
set(gca, 'XTickLabel', []);

% --- row 2 L: shifted x ---
ax2A = subplot(4, 2, 3); hold on;
yticks_2a = zeros(1, num_frames);
yticklabels_2a = cell(1, num_frames);
for m = 1:num_frames
    y_offset = (num_frames - m) * 1.5; 
    line([1 total_len], [y_offset y_offset], 'Color', c_gray, 'LineStyle', '-', 'LineWidth', 1);
    plot(n, frames_matrix(m, :) + y_offset, 'Color', colors(m,:), 'LineWidth', 1.5, 'LineStyle', '-');
    
    % Store y-ticks for the m indicators
    yticks_2a(m) = y_offset;
    yticklabels_2a{m} = num2str(m);
end
title('2A. Shifted Sequences $\hat{x}_m[n - mH]$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('Frame (m)'); axis tight; ylim([-1, num_frames*1.5]); grid off;
% m indicators
set(gca, 'YTick', flip(yticks_2a), 'YTickLabel', flip(yticklabels_2a)); 
set(gca, 'XTickLabel', []);

% --- row 2 R: shifted w ---
ax2B = subplot(4, 2, 4); hold on;
yticks_2b = zeros(1, num_frames);
yticklabels_2b = cell(1, num_frames);
for m = 1:num_frames
    y_offset = (num_frames - m) * 1.2; 
    line([1 total_len], [y_offset y_offset], 'Color', c_gray, 'LineStyle', '-', 'LineWidth', 1);
    plot(n, windows_matrix(m, :) + y_offset, 'Color', colors(m,:), 'LineWidth', 1.5, 'LineStyle', '-');
    
    yticks_2b(m) = y_offset;
    yticklabels_2b{m} = num2str(m);
end
title('2B. Shifted Windows $w[n - mH]$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('Frame (m)'); axis tight; ylim([-0.5, num_frames*1.2]); grid off;
% m indicators
set(gca, 'YTick', flip(yticks_2b), 'YTickLabel', flip(yticklabels_2b)); 
set(gca, 'XTickLabel', []);

% --- row 3 L: unnormalized sum x ---
ax3A = subplot(4, 2, 5); hold on;
for m = 1:num_frames
    plot(n, frames_matrix(m, :), 'Color', [colors(m,:) 0.5], 'LineWidth', 1.5, 'LineStyle', '--');
end

plot(n, x_unnorm, 'Color', c_blue, 'LineWidth', 2, 'LineStyle', '-');
title('3A. Unnormalized Accumulation $\tilde{x}[n]$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('Amplitude'); axis tight; ylim([-1.3 1.3]); grid on;
set(gca, 'XTickLabel', []);


% --- row 3 R: cola sum w ---
ax3B = subplot(4, 2, 6); hold on;
for m = 1:num_frames
    plot(n, windows_matrix(m, :), 'Color', [colors(m,:) 0.5], 'LineWidth', 1.5, 'LineStyle', '--');
end

plot(n, W_sum, 'Color', c_orange, 'LineWidth', 2.5, 'LineStyle', '-');
h_limit = yline(1.08, 'Color', c_black, 'LineWidth', 1.5, 'LineStyle', '-');

title('3B. $\sum_{m} w[n - mH] = C$', 'Interpreter', 'latex', 'FontSize', 13);
axis tight; ylim([0 1.4]); grid on;
set(gca, 'XTickLabel', []);
legend([h_limit], {'C = 1.08'}, 'Location', 'eastoutside');

% --- row 4: final compare ---
ax4 = subplot(4, 2, [7, 8]); hold on;
plot(n, x_final, 'Color', '#cf5eff', 'LineWidth', 2.5, 'LineStyle', '-');
plot(n, x_unnorm, 'Color', c_blue, 'LineWidth', 1.25, 'LineStyle', '-.');
title('4. $\hat{x}[n] = \tilde{x}[n] / C$', 'Interpreter', 'latex', 'FontSize', 14);
xlabel('Discrete Time Index $n$', 'Interpreter', 'latex', 'FontSize', 12); 
ylabel('Amplitude'); axis tight; ylim([-1.3 1.3]); grid on;
legend('Normalized Output', 'Unnormalized Sum', 'Location', 'eastoutside');