function grafo = rrt_generator(grid)
goal = [-8, -8, 0];
start = [4, 4, 0];
veh = Bicycle('steermax', 5);
rrt = RRT(veh, 'goal', goal, 'range', grid);
rrt.plan('noprogress') % create navigation tree
% rrt.plot()
% Extraemos los parámetros de Edges
EndNodes = rrt.graph.edgelist';
Weight = ones(size(EndNodes, 1), 1);  % Tau
Eta = 1./rrt.graph.edgelen';  % 1/costo
% Extraemos los parámetros de Nodes
X = rrt.graph.vertexlist(1, :)';
Y = rrt.graph.vertexlist(2, :)';
Name = string(1:size(X, 1))';
G = graph(table(EndNodes, Weight, Eta), table(Name, X, Y));
grafo = simplify(G);
G = grafo;
save('rrt_test_graph.mat', 'G')
% figure()
% plot(grafo, 'XData', grafo.Nodes.X, 'YData', grafo.Nodes.Y, 'NodeColor', 'k');
% rrt.query(start, goal)
end