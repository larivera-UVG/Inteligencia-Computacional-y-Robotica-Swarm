% Fitness Function booth
function [f] = booth(v)
    x = v(1);
    y = v(2);
    f = (x + 2*y - 7)^2 + (2*x + y - 5)^2;
end