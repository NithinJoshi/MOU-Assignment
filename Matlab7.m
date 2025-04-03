%% Fuzzy Logic Controller Performance Analysis
% This script provides complete analysis of a fuzzy controller's behavior
% including rule activation patterns, control surfaces, and operational scenarios

clc; clear; close all;

%% 1. Fuzzy System Initialization
% Load existing FIS or create example controller
try
    fis = readfis('fuzzy_controller.fis'); % Load your FIS file
catch
    % Create example temperature controller if no file found
    warning('FIS file not found. Creating example temperature controller.');
    fis = mamfis('Name','Temperature_Controller');
    
    % Add inputs with ranges and membership functions
    fis = addInput(fis, [15 35], 'Name', 'Temperature');
    fis = addMF(fis, 'Temperature', 'trapmf', [15 15 18 22], 'Name', 'Cold');
    fis = addMF(fis, 'Temperature', 'trimf', [20 25 30], 'Name', 'Comfortable');
    fis = addMF(fis, 'Temperature', 'trapmf', [28 32 35 35], 'Name', 'Hot');
    
    % Add second input
    fis = addInput(fis, [30 90], 'Name', 'Humidity');
    fis = addMF(fis, 'Humidity', 'trapmf', [30 30 40 50], 'Name', 'Dry');
    fis = addMF(fis, 'Humidity', 'trimf', [45 60 75], 'Name', 'Moderate');
    fis = addMF(fis, 'Humidity', 'trapmf', [70 80 90 90], 'Name', 'Humid');
    
    % Add output
    fis = addOutput(fis, [0 100], 'Name', 'Cooling_Power');
    fis = addMF(fis, 'Cooling_Power', 'trimf', [0 25 50], 'Name', 'Low');
    fis = addMF(fis, 'Cooling_Power', 'trimf', [25 50 75], 'Name', 'Medium');
    fis = addMF(fis, 'Cooling_Power', 'trimf', [50 75 100], 'Name', 'High');
    
    % Define rules
    ruleList = [
        1 1 1 1 1;   % If Temp is Cold AND Humid is Dry THEN Cooling is Low
        2 2 2 1 1;    % If Temp is Comfortable AND Humid is Moderate THEN Cooling is Medium
        3 3 3 1 1;    % If Temp is Hot AND Humid is Humid THEN Cooling is High
        1 3 2 1 1;    % Additional rules...
        3 1 3 1 1
    ];
    fis = addRule(fis, ruleList);
end

%% 2. Control Surface Analysis
% Create input space grid
temp_points = linspace(fis.Inputs(1).Range(1), fis.Inputs(1).Range(2), 50);
humid_points = linspace(fis.Inputs(2).Range(1), fis.Inputs(2).Range(2), 50);
[temp_grid, humid_grid] = meshgrid(temp_points, humid_points);

% Evaluate entire control surface
outputs = zeros(size(temp_grid));
for i = 1:numel(temp_grid)
    outputs(i) = evalfis(fis, [temp_grid(i), humid_grid(i)]);
end

% Plot 3D control surface
figure('Name', 'Control Surface', 'Position', [100 100 800 600]);
surf(temp_grid, humid_grid, outputs, 'EdgeColor', 'none');
title('Fuzzy Controller Control Surface', 'FontSize', 12);
xlabel('Temperature (°C)', 'FontSize', 10);
ylabel('Relative Humidity (%)', 'FontSize', 10);
zlabel('Cooling Power (%)', 'FontSize', 10);
colormap(jet);
colorbar('FontSize', 9);
view(135, 30);
grid on;
rotate3d on;

%% 3. Rule Activation Analysis
% Define critical test points
test_conditions = [
    fis.Inputs(1).Range(1) fis.Inputs(2).Range(1); % Min-Min
    fis.Inputs(1).Range(1) fis.Inputs(2).Range(2); % Min-Max
    mean(fis.Inputs(1).Range) mean(fis.Inputs(2).Range); % Mid-Mid
    fis.Inputs(1).Range(2) fis.Inputs(2).Range(1); % Max-Min
    fis.Inputs(1).Range(2) fis.Inputs(2).Range(2)  % Max-Max
];

% Create rule activation figure
figure('Name', 'Rule Activation Analysis', 'Position', [50 50 1200 900]);

for k = 1:size(test_conditions, 1)
    % Evaluate FIS at test point
    [output, rule_input, rule_output, mf_output] = evalfis(fis, test_conditions(k,:));
    
    % Plot input membership function activation
    subplot(5, 4, (k-1)*4 + 1);
    plotmf(fis, 'input', 1);
    hold on;
    line([test_conditions(k,1) test_conditions(k,1)], ylim, 'Color', 'r', 'LineWidth', 2);
    title(sprintf('Temp MF Activation\n(%.1f°C, %.1f%%)', test_conditions(k,1), test_conditions(k,2)));
    
    subplot(5, 4, (k-1)*4 + 2);
    plotmf(fis, 'input', 2);
    hold on;
    line([test_conditions(k,2) test_conditions(k,2)], ylim, 'Color', 'r', 'LineWidth', 2);
    title(sprintf('Humidity MF Activation\n(%.1f°C, %.1f%%)', test_conditions(k,1), test_conditions(k,2)));
    
    % Plot rule firing strengths
    subplot(5, 4, (k-1)*4 + 3);
    bar(rule_input, 'FaceColor', [0.3 0.6 0.9]);
    title('Rule Firing Strengths');
    xlabel('Rule Index');
    ylabel('Strength');
    ylim([0 1]);
    grid on;
    
    % Plot output membership function activation
    subplot(5, 4, (k-1)*4 + 4);
    plotmf(fis, 'output', 1);
    hold on;
    line([output output], ylim, 'Color', 'g', 'LineWidth', 2);
    title(sprintf('Output: %.2f%%', output));
end

%% 4. Operational Scenario Simulation
% Create dynamic operational scenario
sim_time = 0:0.5:60; % 1 minute simulation
temp_profile = 20 + 10*square(2*pi*0.01*sim_time, 30) + 2*randn(size(sim_time));
humid_profile = 60 + 20*sin(2*pi*0.015*sim_time) + 3*randn(size(sim_time));

% Simulate controller response
controller_output = zeros(size(sim_time));
rule_activation = zeros(length(sim_time), length(fis.Rules));

for i = 1:length(sim_time)
    [controller_output(i), rule_activation(i,:)] = evalfis(fis, [temp_profile(i), humid_profile(i)]);
end

% Plot operational scenario
figure('Name', 'Operational Scenario', 'Position', [100 100 1000 800]);

% Inputs plot
subplot(3,1,1);
plot(sim_time, temp_profile, 'r', 'LineWidth', 1.5);
title('Environmental Conditions', 'FontSize', 12);
ylabel('Temperature (°C)', 'FontSize', 10);
yyaxis right;
plot(sim_time, humid_profile, 'b', 'LineWidth', 1.5);
ylabel('Humidity (%)', 'FontSize', 10);
legend('Temperature', 'Humidity', 'Location', 'northeast');
grid on;

% Controller output
subplot(3,1,2);
plot(sim_time, controller_output, 'k', 'LineWidth', 2);
title('Controller Response', 'FontSize', 12);
ylabel('Cooling Power (%)', 'FontSize', 10);
grid on;

% Rule activation over time
subplot(3,1,3);
imagesc(sim_time, 1:length(fis.Rules), rule_activation');
colormap(jet);
colorbar;
title('Rule Activation Pattern Over Time', 'FontSize', 12);
xlabel('Time (seconds)', 'FontSize', 10);
ylabel('Rule Number', 'FontSize', 10);
set(gca, 'YDir', 'normal');

%% 5. Performance Metrics Calculation
% Calculate key performance indicators
response_time = calculateResponseTime(sim_time, controller_output);
overshoot = calculateOvershoot(controller_output);
steady_state_error = calculateSteadyStateError(controller_output);

fprintf('\nController Performance Metrics:\n');
fprintf('Average Response Time: %.2f seconds\n', mean(response_time));
fprintf('Maximum Overshoot: %.2f%%\n', max(overshoot));
fprintf('Steady-State Error: %.2f%%\n', steady_state_error);

%% Helper Functions
function rt = calculateResponseTime(t, y)
    % Find 10% to 90% rise time for each major transition
    y_diff = diff(y);
    transition_points = find(abs(y_diff) > 0.1*std(y_diff)) + 1;
    rt = zeros(length(transition_points)-1, 1);
    
    for i = 1:length(transition_points)-1
        start_idx = transition_points(i);
        end_idx = transition_points(i+1);
        rt(i) = t(end_idx) - t(start_idx);
    end
end

function os = calculateOvershoot(y)
    % Calculate percentage overshoot for each peak
    [peaks, locs] = findpeaks(y);
    baseline = median(y);
    os = 100*(peaks - baseline)/baseline;
end

function sse = calculateSteadyStateError(y)
    % Calculate steady-state error as deviation from median
    sse = 100*mean(abs(y - median(y)))/range(y);
end