% Fitness Function Rosenbrock
function [y] = rosenbrock(x)
    d = length(x);
    sum = 0;
    for i = 1:(d - 1)
        x1 = x(i);
        x2 = x(i + 1);
        new = (1 - x1)^2 + 100*(x2 - x1^2)^2;
        sum = sum + new;
    end
    y = sum;
end

