function benchmark_comparison()
    % Initialize parameters
    dim = 10;          % Problem dimension
    bounds = [-100 100]; % Search space bounds
    resolution = 50;    % Mesh resolution
    
    % Create 2D visualization mesh
    [X,Y] = meshgrid(linspace(bounds(1),bounds(2),resolution));
    
    % Initialize function containers
    funcs = {@F1_Shifted_Sphere, @F9_Shifted_Rastrigin, @F13_Griewank_Rosenbrock};
    titles = {'Unimodal (F1: Shifted Sphere)', ...
              'Multimodal Basic (F9: Shifted Rastrigin)', ...
              'Expanded (F13: Griewank+Rosenbrock)'};
    
    % Evaluate and plot
    figure('Position', [100 100 1200 400]);
    for i = 1:3
        Z = evaluate_function(funcs{i}, X, Y, dim);
        subplot(1,3,i);
        surf(X,Y,Z,'EdgeColor','none');
        title(titles{i});
        xlabel('x1'); ylabel('x2'); zlabel('f(x)');
        axis tight;
    end
    colormap(jet);
    sgtitle('Benchmark Function Comparison');
end

function Z = evaluate_function(func, X, Y, dim)
    [m,n] = size(X);
    Z = zeros(m,n);
    for i = 1:m
        for j = 1:n
            point = zeros(1,dim);
            point(1:2) = [X(i,j), Y(i,j)]; % Vary first two dimensions
            Z(i,j) = func(point);
        end
    end
end

%% Unimodal Function Implementations
function y = F1_Shifted_Sphere(x)
    persistent o
    if isempty(o)
        o = zeros(size(x)) + 30; % Simple shift for demonstration
    end
    z = x - o;
    y = sum(z.^2);
end

function y = F2_Shifted_Schwefel(x)
    persistent o
    if isempty(o)
        o = zeros(size(x)) + 30;
    end
    z = x - o;
    y = 0;
    for i = 1:length(z)
        y = y + sum(z(1:i))^2;
    end
end

%% Multimodal Function Implementations
function y = F9_Shifted_Rastrigin(x)
    persistent o
    if isempty(o)
        o = zeros(size(x)) + 30;
    end
    z = x - o;
    y = 10*numel(z) + sum(z.^2 - 10*cos(2*pi*z));
end

function y = F6_Shifted_Rosenbrock(x)
    persistent o
    if isempty(o)
        o = zeros(size(x)) + 30;
    end
    z = x - o + 1;
    y = sum(100*(z(1:end-1).^2 - z(2:end)).^2 + sum((z(1:end-1)-1).^2));
end

%% Expanded Function Implementations
function y = F13_Griewank_Rosenbrock(x)
    persistent o
    if isempty(o)
        o = zeros(size(x)) + 30;
    end
    z = x - o + 1;
    
    % Griewank component
    f1 = sum(z.^2)/4000 - prod(cos(z./sqrt(1:numel(z)))) + 1;
    
    % Rosenbrock component
    f2 = sum(100*(z(1:end-1).^2 - z(2:end)).^2 + (z(1:end-1)-1).^2);
    
    y = f1 + f2;
end

function y = F14_Scaffer(x)
    persistent o
    if isempty(o)
        o = zeros(size(x)) + 30;
    end
    z = x - o;
    y = 0;
    for i = 1:length(z)-1
        zi = z(i)^2 + z(i+1)^2;
        y = y + (0.5 + (sin(sqrt(zi))^2 - 0.5)/(1 + 0.001*zi)^2);
    end
end