% Fitness Function Himmelblau
function [f] = himmelblau(v)
    x = v(1);
    y = v(2);
    f = (x^2 + y - 11)^2 + (x + y^2 - 7)^2;
end