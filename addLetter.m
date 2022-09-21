function h = addLetter( letter, offset )
%%
%
%
%

if( nargin < 2 )
  offset = [-0.1, 0.01];
end

pos = [0 0 0.03 0.06];
g = gca;
pos(1) = g.Position(1) + offset(1);
pos(2) = g.Position(2) + (1-offset(2))*g.Position(4);
for j=1:2
  pos(j) = max( min( pos(j), 1), 0);
end

h = annotation( 'textbox', pos );
h.String = letter;
h.FontSize = 18;
h.FontWeight = 'bold';
h.LineStyle = 'none';
