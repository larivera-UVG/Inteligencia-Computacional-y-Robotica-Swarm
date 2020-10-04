function golden_spiral
% GOLDEN_SPIRAL Explosion of golden rectangles.
% GOLDEN_SPIRAL Constructs a continuously expanding sequence
% of golden rectangles and inscribed quarter circles.
% Copyright 2020 The MathWorks, Inc.
% 
% Text used in the show_quote function:
% Jones, Robert Bishop. ?Aristotle METAPHYSICA Book 13 Part 3.? Aristotle METAPHYSICA Book 13 Part 3 
% Mathematics, Harmonics, Optics, Good and Beauty, 25 Nov. 1996, 
% www.rbjones.com/rbjpub/philos/classics/aristotl/m11303c.htm.
 % Initialize_variables
 klose = [];
 
 % Golden ratio
 phi = (1+sqrt(5))/2;
 % Control speed of zooming in
 n = 48;
 f = phi^(1/n);
 % Scaling
 a = 1;
 s = phi;
 t = 1/(phi+1);
 % Centers
 x = 0;
 y = 0;
 % A square
 us = [-1 1 1 -1 -1];
 vs = [-1 -1 1 1 -1];
 % Four quarter circles
 theta = 0:pi/20:pi/2;
 u1 = 2*cos(theta) - 1;
 v1 = 2*sin(theta) - 1;
 u2 = 2*cos(theta+pi/2) + 1;
 v2 = 2*sin(theta+pi/2) - 1;
 u3 = 2*cos(theta+pi) + 1;
 v3 = 2*sin(theta+pi) + 1;
 u4 = 2*cos(theta-pi/2) - 1;
 v4 = 2*sin(theta-pi/2) + 1;
 
 initialize_graphics
 
 % Loop
 k = 0;
 while get(klose,'Value') == 0
 if k <= 285
 if mod(k,n) == 0
 scaled_power
 switch mod(k/n,4)
 case 0, up
 case 1, left
 case 2, down
 case 3, right
 end
 end
 zoom_in
 k = k+1;
 else
 break
 end
 end
 pause(1) 
 clf
 show_quote
% ------------------------------------
 function scaled_power
 a = s;
 s = phi*s;
 t = phi*t;
 end % scaled_power
% ------------------------------------
 function zoom_in
 axis(f*axis)
 drawnow
 end % zoom_in
% ------------------------------------
 function right
 x = x + s;
 y = y + t;
 line(x+a*us,y+a*vs,'Color','black')
 line(x+a*u4,y+a*v4)
 end % right
% ------------------------------------
 function up
 y = y + s;
 x = x - t;
 line(x+a*us,y+a*vs,'Color','black')
 line(x+a*u1,y+a*v1)
 end % up
% ------------------------------------
 function left
 x = x - s;
 y = y - t;
 line(x+a*us,y+a*vs,'Color','black')
 line(x+a*u2,y+a*v2)
 end % left
% ------------------------------------
 function down
 y = y - s;
 x = x + t;
 line(x+a*us,y+a*vs,'Color','black')
 line(x+a*u3,y+a*v3)
 end % down
% ------------------------------------
 function initialize_graphics
 clf reset
 set(gcf,'Color','white','Menubar','none','Numbertitle','off', ...
 'Name','The Golden Spiral')
 shg
 axes('Position',[0 0 1 1])
 axis(3.5*[-1 1 -1 1])
 axis square
 axis off
 line(us,vs,'Color','black')
 line(u4,v4)
 klose = uicontrol('Units','normal','Position',[.04 .04 .12 .04], ...
 'Style','togglebutton','String','close','Visible','on');
 drawnow
 end % initialize graphics
 function show_quote 
 large_text = cell(4,1);
 large_text{1} = transform('Gur puvrs sbezf bs ornhgl ner');
 large_text{2} = transform('beqre naq flzzrgel naq qrsvavgrarff,');
 large_text{3} = transform('juvpu gur zngurzngvpny fpvraprf');
 large_text{4} = transform('qrzbafgengr va n fcrpvny qrterr.');
 medium_text = transform('- Nevfgbgyr');
 text(0.5, 0.6, large_text, 'HorizontalAlignment', 'center', 'Color', [0 0.4470 0.7410], 'FontWeight', 'bold', 'FontSize', 14);
 text(0.5, 0.4, medium_text, 'HorizontalAlignment', 'center', 'Color', [0 0.4470 0.7410], 'FontWeight', 'bold', 'FontSize', 12);
 axis off 
 drawnow
 end % show quote
 function s2 = transform(s1)
 m25=1:256;i17=97;m25(i17:i17+25)=[i17+13:i17+25 i17:i17+12];
 i17=65;m25(i17:i17+25)=[i17+13:i17+25 i17:i17+12];
 s2=char(m25(s1));
 end % transform
end % golden_spiral