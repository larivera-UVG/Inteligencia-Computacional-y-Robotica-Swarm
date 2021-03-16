function [p_l] = local_best(x,p_l,type)
    if (type == 0)
        if (rosenbrock(x) < rosenbrock(p_l))
            p_l = x;
        end
    elseif (type == 1)
        if (minima(x) < minima(p_l))
            p_l = x;
        end
    elseif (type == 2)
        if (sphere(x) < sphere(p_l))
            p_l = x;
        end
    elseif (type == 3)
        if (booth(x) < booth(p_l))
            p_l = x;
        end
    elseif (type == 4)
        if (himmelblau(x) < himmelblau(p_l))
            p_l = x;
        end
    elseif (type == 5)
        if (schaffer_f6(x) < schaffer_f6(p_l))
            p_l = x;
        end
    end
end

