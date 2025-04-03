%% Fuzzy Logic Controller Behavior Analysis
% This script analyzes the performance of a fuzzy logic controller (FLC)
% by visualizing rule activation, controller output, and control surfaces

clc; clear; close all;

%% 1. Load or Create Fuzzy Inference System (FIS)
% Option 1: Load existing FIS
fis = readfis('temperature_controller.fis'); % Replace with your FIS file

% Option 2: Create a new Mamdani FIS (example)
% fis = mamfis('Name','Temperature_Controller');
% fis = addInput(fis, [15 35], 'Name', 'Temperature');
% fis = addInput(fis, [30 90], 'Name', 'Humidity');
% fis = addOutput(fis, [0 100], 'Name', 'Cooling_Power');
% ... (add membership functions and rules)

%% 2. Input Space Definition
% Define ranges for input variables
temp_range = linspace(fis.Inputs(1).Range(1), fis.Inputs(1).Range(2), 50);
humidity_range = linspace(fis.Inputs(2).Range(1), fis.Inputs(2).Range(2), 50);

% Create grid for surface plot
[temp_grid, humidity_grid] = meshgrid(temp_range, humidity_range);
inputs = [temp_grid(:), humidity_grid(:)];

%% 3. Evaluate Controller Output
outputs = evalfis(fis, inputs);
output_grid = reshape(outputs, length(humidity_range), length(temp_range));

%% 4. Rule Activation Analysis
test_points = [ % Define test points [temp, humidity]
    fis.Inputs(1).Range(1) fis.Inputs(2).Range(1) % Min-Min
    mean(fis.Inputs(1).Range) mean(fis.Inputs(2).Range) % Mid-Mid
    fis.Inputs(1).Range(2) fis.Inputs(2).Range(2) % Max-Max
    25 60 % Typical operating point
];

figure('Name', 'Rule Activation Analysis', 'Position', [100 100 1200 800]);
for i = 1:size(test_points, 1)
    % Evaluate FIS at test point
    [~, rule_input, ~, ~] = evalfis(fis, test_points(i,:));
    
    % Plot membership functions with activation
    subplot(4, 3, (i-1)*3 + 1);
    plotmf(fis, 'input', 1);
    hold on;
    line([test_points(i,1) test_points(i,1)], ylim, 'Color', 'r', 'LineWidth', 2);
    title(sprintf('Temp: %.1f°C, Humid: %.1f%%', test_points(i,1), test_points(i,2)));
    
    subplot(4, 3, (i-1)*3 + 2);
    plotmf(fis, 'input', 2);
    hold on;
    line([test_points(i,2) test_points(i,2)], ylim, 'Color', 'r', 'LineWidth', 2);
    
    % Plot rule activation strengths
    subplot(4, 3, (i-1)*3 + 3);
    bar(rule_input, 'FaceColor', [0.2 0.4 0.7]);
    title('Rule Activation Strength');
    xlabel('Rule Number');
    ylabel('Firing Strength');
    ylim([0 1]);
    grid on;
end

%% 5. Control Surface Visualization
figure('Name', 'Control Surface', 'Position', [100 100 800 600]);
surf(temp_grid, humidity_grid, output_grid);
title('FLC Control Surface');
xlabel('Temperature (°C)');
ylabel('Humidity (%)');
zlabel('Cooling Power (%)');
colormap('parula');
shading interp;
colorbar;
rotate3d on;

%% 6. Controller Output Slices
% Plot output for fixed humidity values
fixed_humidity = [40 60 80]; % Humidity values to analyze

figure('Name', 'Output at Fixed Humidity', 'Position', [100 100 900 400]);
for i = 1:length(fixed_humidity)
    subplot(1, length(fixed_humidity), i);
    idx = find(abs(humidity_range - fixed_humidity(i)) < 0.1);
    plot(temp_range, output_grid(idx(1), :), 'LineWidth', 2);
    title(sprintf('Humidity Fixed at %d%%', fixed_humidity(i)));
    xlabel('Temperature (°C)');
    ylabel('Cooling Power (%)');
    grid on;
end

%% 7. Dynamic Response Analysis
% Simulate time-varying inputs
time = 0:0.1:20;
temp_profile = 20 + 8*sawtooth(2*pi*0.1*time);
humidity_profile = 50 + 30*sin(2*pi*0.05*time);

% Evaluate controller response
dynamic_output = zeros(size(time));
for i = 1:length(time)
    dynamic_output(i) = evalfis(fis, [temp_profile(i), humidity_profile(i)]);
end

% Plot dynamic response
figure('Name', 'Dynamic Response', 'Position', [100 100 1000 600]);
subplot(3,1,1);
plot(time, temp_profile, 'r', 'LineWidth', 1.5);
title('Temperature Input');
ylabel('°C');
grid on;

subplot(3,1,2);
plot(time, humidity_profile, 'b', 'LineWidth', 1.5);
title('Humidity Input');
ylabel('%');
grid on;

subplot(3,1,3);
plot(time, dynamic_output, 'k', 'LineWidth', 2);
title('Controller Output');
xlabel('Time (s)');
ylabel('Cooling Power (%)');
grid on;