% ///////////////////////////////////////////////////////////////////////
% Archivo: objfun.m
% Descripción: Función que evalúa a los individuos de la población
% Aquí definimos el problema a resolver

function objv = objfun(x, funcion_costo)
if (funcion_costo == "Banana")
    objv = 100*(x(:,2)-x(:,1).^2).^2+(ones(size(x(:,1)))-x(:,1)).^2;
elseif (funcion_costo == "Ackley")
    elevado = x.^2;
    sumaxi = -0.2.*sqrt(0.5.*(elevado(:,1)+elevado(:,2)));
    cosenado = cos(2.*pi.*x);
    sumacos = (cosenado(:,1)+cosenado(:,2));
    objv = -20.*exp(sumaxi)-exp(0.5.*sumacos)+20+exp(1);
elseif (funcion_costo == "Rastrigin")
    elevado = x.^2;
    cosenado = 10*cos(2.*pi.*x);
    restado = elevado - cosenado;
    objv = 20 + (restado(:, 1) + restado(:, 2));
elseif (funcion_costo == "Booth")
    objv=(x(:,1) + 2*x(:,2)-7).^2 + (2*x(:,1)+x(:,2)-5).^2;
end
end