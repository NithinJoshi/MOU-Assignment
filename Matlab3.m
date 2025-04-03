%% Fuzzy Logic Controller Design with Justifications
% Initialize Mamdani FIS (chosen for interpretability in healthcare applications)
fis = mamfis('Name','AssistiveEnvironment_FLC');

% 1. Membership Functions Design
% Temperature input: trapezoidal for extremes, triangular for mid-range
fis = addInput(fis,[0 40],'Name','Temperature');
% Cold (trapmf): broad coverage for low temperatures
fis = addMF(fis,'Temperature','trapmf',[0 0 10 15],'Name','Cold');
% Moderate (trimf): precise control in comfort zone
fis = addMF(fis,'Temperature','trimf',[10 20 25],'Name','Moderate');
% Hot (trapmf): broad coverage for high temperatures
fis = addMF(fis,'Temperature','trapmf',[20 30 40 40],'Name','Hot');

% Activity Level input: trapezoidal for all ranges
fis = addInput(fis,[0 10],'Name','Activity');
fis = addMF(fis,'Activity','trapmf',[0 0 2 4],'Name','Low');
fis = addMF(fis,'Activity','trimf',[3 5 7],'Name','Medium');
fis = addMF(fis,'Activity','trapmf',[6 8 10 10],'Name','High');

% Heater Power output: trapezoidal for smooth control
fis = addOutput(fis,[0 100],'Name','HeaterPower');
fis = addMF(fis,'HeaterPower','trapmf',[0 0 30 50],'Name','Low');
fis = addMF(fis,'HeaterPower','trimf',[40 60 80],'Name','Medium');
fis = addMF(fis,'HeaterPower','trapmf',[70 90 100 100],'Name','High');

% 2. Rule Base Design (8 rules covering all combinations)
rules = [
    "Temperature==Cold & Activity==Low => HeaterPower=High (1)"; % Safety priority
    "Temperature==Cold & Activity==Medium => HeaterPower=High (1)";
    "Temperature==Cold & Activity==High => HeaterPower=Medium (1)";
    "Temperature==Moderate & Activity==Low => HeaterPower=Medium (1)";
    "Temperature==Moderate & Activity==Medium => HeaterPower=Medium (1)";
    "Temperature==Moderate & Activity==High => HeaterPower=Low (1)"; % Energy saving
    "Temperature==Hot & Activity==Low => HeaterPower=Low (1)";
    "Temperature==Hot & Activity==High => HeaterPower=Low (1)"];
fis = addRule(fis,rules);

