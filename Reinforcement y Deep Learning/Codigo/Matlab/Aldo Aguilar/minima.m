% Fitness Function Minima
function [y] = minima(x)
    d = length(x);
    sum = 0;
    for i = 1:(d - 1)
        x1 = x(i);
        x2 = x(i + 1);
        new = exp(x1 - 2*x1.^2 - x2.^2).*sin(6*(x1 + x2 + x1.*x2.^2));
        sum = sum + new;
    end
    y = sum;
end

