% Fitness Function Sphere
function [y] = sphere(x)
    d = length(x);
    sum = 0;
    for i = 1:(d)
        x1 = x(i);
        new = x1^2;
        sum = sum + new;
    end
    y = sum;
end