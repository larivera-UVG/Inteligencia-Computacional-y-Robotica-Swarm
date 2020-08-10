function E = m_random(n)

E.mechanisms  = ones(n,1);
E.anchors     = [nan nan];
E.radii       = 4*(rand(n,1)/2+.5)*[1 0.2]/n;
E.masses      = pi*sum(E.radii.^2,2);
E.joints      = [ceil(((2:n)-1).*rand(1,n-1).^0.2);2:n]'; % random tree
% joints      = [1:n-1;2:n]';  % chain
E.j_locs      = [ones(n-1,1) -ones(n-1,1)];
E.j_constr    = (1:size(E.joints,1))';
E.j_constr    = [];
E.a_constr    = [];
E.a_lims      = ones(size(E.joints,1),1)*[-2*pi/3 2*pi/3];
E.a_lims      = wrap(E.a_lims);
E.a_lims      = zeros(0,2);
% a_constr    = [];
% a_lims      = zeros(0,2);
E.draw_order  = 1:n;
E.collidable  = false(n);
E.walls       = [0 1 -5; 1 0 -5; -1 0 -5; 0 -1 -5];