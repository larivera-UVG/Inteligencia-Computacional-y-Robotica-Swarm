function [X1,Y1,Z] = GA_contour(funcion_costo)
if (funcion_costo == "Banana")
    [X1,Y1] = meshgrid(-5:0.1:10);
    Z=100*(Y1-X1.^2).^2+(ones(size(X1))-X1).^2;
elseif (funcion_costo == "Ackley")
    [X1,Y1] = meshgrid(-33:0.5:33);
    X2 = reshape(X1, [size(X1,1)^2 1]);Y2 = reshape(Y1, [size(Y1,1)^2 1]);
    X = [X2 Y2];
    elevado = X.^2;
    sumaxi = -0.2.*sqrt(0.5.*(elevado(:,1)+elevado(:,2)));
    cosenado = cos(2.*pi.*X);
    sumacos = (cosenado(:,1)+cosenado(:,2));
    Z1 = -20.*exp(sumaxi)-exp(0.5.*sumacos)+20+exp(1);
    Z = reshape(Z1, size(X1));
elseif (funcion_costo == "Rastrigin")
    [X1,Y1] = meshgrid(-6:0.1:6);
    X2 = reshape(X1, [size(X1,1)^2 1]);Y2 = reshape(Y1, [size(Y1,1)^2 1]);
    X = [X2 Y2];
    elevado = X.^2;
    cosenado = cos(2.*pi.*X);
    restado = elevado-cosenado;
    Z1 = 20+(restado(:,1)+restado(:,2));
    Z = reshape(Z1, size(X1));
elseif (funcion_costo == "Booth")
    [X1,Y1] = meshgrid(-10:0.1:10);
    Z=(X1 + 2*Y1-7).^2 + (2*X1+Y1-5).^2;

end