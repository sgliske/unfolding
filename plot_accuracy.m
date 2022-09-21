function plot_accuracy( X0, Y0, X1, Y1, X2, Y2, do_legend )
%%
%
% good examples to show:
% plot_accuracy( A, f.results(2,2) )
%

%%
%clf
hold on
h0 = scatter( X0, Y0, 60, 'ro' );
h1 = scatter( X1, Y1, 40, 'bd' );
h2 = scatter( X2, Y2, 40, 'ks' );
hold off

colors = { [ 0.678 0.071 0.165 ], [ 0.165 0.071  0.678 ], 'k' };
h0.MarkerEdgeColor = colors{1};
h1.MarkerEdgeColor = colors{2};
h2.MarkerEdgeColor = colors{3};

h1.MarkerFaceColor = h1.MarkerEdgeColor;
h2.MarkerFaceColor = h2.MarkerEdgeColor;
%plot( [X0 X1]', [Y0 Y1]', 'k' );
%axis square
%axis equal

yL = [0 max(Y1(:))];
ylim(yL);

if( do_legend )
  xL = xlim();
  yL = ylim();
  xlim([xL(1) 2.0]);
  ylim([-0.8 yL(2)]);
  
  hL = legend('True','Raw','Corr.', 'Location','SouthEast','Orientation','Vertical');
  hL.Box = 'off';
end


