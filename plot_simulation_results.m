function plot_simulation_results( data )
%% function plot_simulation_results( data )
%
% data should be the output of the 'induce_and_unfold' function
%

%% prep

g = gcf;
g.Position(3:4) = [1200 600];
g.Position(2) = 50;
clf

labels = {'true', 'meas'};
colors = { [ 0.678 0.071 0.165 ], [ 0.165 0.071  0.678 ], 'k' };
linewidth = 4;

if( mean(data.meas.zenith) < pi )
  loc = 'NorthEast';
else
  loc = 'NorthWest';
end

ymax = [];

%% PANEL A: ACCEPTANCE

subplot(2,3,1);

x = data.acceptance.x;
y = data.acceptance.y;

x = [x(:); data.acceptance.max_x];
y = [y(:); y(end)];

x = x/data.acceptance.max_x*24;
y = y/max(y);

h = stairs( x, y );
h.Color = 'k';
h.LineWidth = linewidth;

ylim([0 1.1])

xlim([0 24])
g=gca;
g.XTick = 0:4:24;
g.FontSize = 14;
g.Box = 'off';
ylabel('Acceptance');
xlabel('Hour of day');

addLetter( 'A', [-0.05 0] );

%% TWO EXAMPLE PARAMETERS

cmax = -Inf;

for k=1:2
  
  %% PANEL B/D: HISTOGRAM
  
  subplot(2,3,2*k);
  nBins = 24;
  edges = linspace(0,24,nBins+1);
  
  
  hold on
  for i=1:2
    c = histcounts( data.(labels{i}).phi(:,k)/pi*12, edges );
    c(end+1) = c(end);
    c = c/mean(c);
    
    h = stairs( edges, c );
    h.Color = colors{i};
    h.LineWidth = linewidth;
    
    if( i==1 )
      h.LineStyle = ':';
    end
    cmax = max( cmax, max(c) );
  end
  hold off
  
  xlim([0 24]);
  
  g=gca;
  g.XTick = 0:4:24;
  
  hL = legend('Ideal Data','Measured Data');
  %hL.Orientation = 'horizontal';
  hL.Location = loc;
  hL.Box = 'off';
  
  
  g.FontSize = 14;
  ylabel('Normalized Counts');
  xlabel('Hour of day');
  
  addLetter( char('A'+2*k-1), [-0.05 0] );
  
  %% PANEL C: SIN/COS PLOT
  
  subplot(2,3,2*k+1);
  
  % prep lines
  t = linspace(0,24,100)';
  
  b = ones(3,3);
  labels = {'true','meas','unf'};
  for i=1:3
    A     = data.(labels{i}).amplitude(k);
    phi_0 = data.(labels{i}).zenith(k);
    
    b(2,i) = A*cos(phi_0);
    b(3,i) = A*sin(phi_0);
  end
  
  X = [ ones(length(t),1), cos(t/12*pi), sin(t/12*pi) ];
  x = X*b;
  
  h = plot(t,x);
  
  for i=1:3
    h(i).Color = colors{i};
    h(i).LineWidth = linewidth;
  end
  h(1).LineWidth = linewidth*3;
  h(1).LineStyle = ':';
  
  xlim([0 24]);
  
  g=gca;
  g.XTick = 0:4:24;
  
  hL = legend('True','Measured','Unfolded');
  %hL.Orientation = 'horizontal';
  hL.Location = loc;
  hL.Box = 'off';
  
  g.FontSize = 14;
  ylabel('Model Fit');
  xlabel('Hour of day');
  g.Box = 'off';
  
  addLetter( char('A'+2*k), [-0.05 0] );
end

for i=2:5
  subplot(2,3,i);
  ylim([0 cmax+1]);
end


%% PANEL F

subplot(2,3,6)

plot_accuracy( ...
  data.true.zenith/pi*12, data.true.amplitude, ...
  data.meas.zenith/pi*12, data.meas.amplitude, ...
  data.unf.zenith/pi*12,  data.unf.amplitude, ...
  false );

xlim([0 24])
%ylim([0 1])


xlim([0 24]);
ylim([0 max(data.meas.amplitude)+0.1]);
g=gca;
g.XTick = 0:4:24;
g.FontSize = 14;
g.Box = 'off';
ylabel('Amplitude');
xlabel('Zenith [hour of day]');

addLetter( 'F', [-0.05 0] );

hL = legend({'True','Measured','Unfolded'},'Location',loc);
hL.Box = 'off';
%hL.Orientation = 'horizontal';

%%
labels = {'true','unf'};
X = cell(2,1);
for i=1:2
  A = data.(labels{i}).amplitude;
  phi = data.(labels{i}).zenith;
  X{i} = A.*[cos(phi) sin(phi)];
end

X = X{2}-X{1};

fprintf('RMS: %.3f\n', sqrt(mean(X(:).^2)) );


