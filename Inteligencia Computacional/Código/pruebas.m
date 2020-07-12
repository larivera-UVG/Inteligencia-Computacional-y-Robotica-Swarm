
grid = 5;
map = makemap(grid*grid);
prm = PRM(map, 'npoints', 50);
prm.plan()
prm.plot()
% Extraemos los parámetros de Edges
EndNodes = prm.graph.edgelist(:, prm.graph.edgelen ~= 0)';
Weight = ones(size(EndNodes, 1), 1);  % Tau
Eta = 1./prm.graph.edgelen(prm.graph.edgelen ~= 0)';  % 1/costo
% Extraemos los parámetros de Nodes
X = prm.graph.vertexlist(1, :)';
Y = prm.graph.vertexlist(2, :)';
Name = string(1:size(X, 1))';
G = graph(table(EndNodes, Weight, Eta), table(Name, X, Y));
grafo = simplify(G);
figure()
plot(grafo, 'XData', grafo.Nodes.X, 'YData', grafo.Nodes.Y, 'NodeColor', 'k');


