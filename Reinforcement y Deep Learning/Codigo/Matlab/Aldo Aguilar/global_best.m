function [p_g] = global_best(x,p_g,type)
    if (type == 0)
        if (rosenbrock(x) < rosenbrock(p_g))
            p_g = x;
        end
    elseif (type == 1)
        if (minima(x) < minima(p_g))
            p_g = x;
        end
    elseif (type == 2)
        if (sphere(x) < sphere(p_g))
            p_g = x;
        end
    elseif (type == 3)
        if (booth(x) < booth(p_g))
            p_g = x;
        end
    elseif (type == 4)
        if (himmelblau(x) < himmelblau(p_g))
            p_g = x;
        end
    elseif (type == 5)
        if (schaffer_f6(x) < schaffer_f6(p_g))
            p_g = x;
        end
    end
end

