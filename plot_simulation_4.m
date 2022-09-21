

%% theoretical

chisq = chi2inv(0.95,2);
n = logspace(2,6,100);
thres = sqrt(chisq/2./n);

%% numerical

f = load('data/simulation_4_results.mat');

num_threshold = [ f.results.threshold ]';
c             = [ f.results.cond ]';
nEvents       = [ f.results.nHFOs ]';

theo_threshold = sqrt(chisq/2./nEvents);  % theoretical threshold computed at the values of nEvents

%%

g = gcf;
g.Position(3:4) = [1200 300];
g.Position(2) = 50;
clf

letOffset = -0.07;

%%

subplot(1,3,1)
plot( n, thres, 'k', 'LineWidth', 2 )
g = gca;
g.XScale = 'log';
g.YScale = 'log';

xlabel('Number of events')
ylabel('First Circular Moment')
g.FontSize = 14;
g.Box = 'off';

hold on
I = c < 10000 & nEvents > 500;
h = scatter( nEvents(I), num_threshold(I), 'o' );
h.MarkerEdgeColor  = [0 0.4470 0.7410];
h.MarkerFaceColor = h.MarkerEdgeColor;

hL = legend('Analytic Threshold','Numeric Threshold');
hL.Location = 'SouthWest';
hL.Box = 'off';
hL.FontSize = 12;
hL.Position = [0.155 0.21 0.17 0.14];

addLetter('A', [letOffset 0]);

%%

subplot(1,3,2)
I = c < 10000 & nEvents > 500;
fprintf('Excluded due to not enough HFOs: %d\n', sum( nEvents <= 500 ) );
fprintf('Excluded due to high condition number: %d\n', sum( c >= 10000 ) );
fprintf('Number excluded/included\n');
tabulate(I)

delta = num_threshold(:) - theo_threshold(:);
h = histogram(delta(I), linspace(-0.01,0.13,28));
xlabel('Numeric - Analytic Threshold');
ylabel('Counts');
h.FaceAlpha = 1;

g = gca;
g.Box = 'off';
g.FontSize = 14;

fprintf('95th and 99th quantile of delta:\n');
quantile( delta(I), [0.95 0.99])

addLetter('B', [letOffset 0]);

%%

subplot(1,3,3)
h = scatter( delta(I), c(I), 'o' );
h.MarkerFaceColor = h.MarkerEdgeColor;

g = gca;
%g.XScale = 'log';
g.YScale = 'log';
g.XGrid = 'on';
g.YGrid = 'on';
g.XTick = 0:0.05:0.15;
%g.XTick = logspace(-4,1,6);

g.FontSize = 14;
g.Box = 'off';

xlabel('Numeric - Analytic Threshold')
ylabel({'Smearing Matrix','Condition Number'})

[rho, p] = corr( delta(I), c(I), 'Type', 'Spearman');
fprintf('Correlation: %.4f, p=%.4g\n', rho, p )

addLetter('C', [letOffset 0]);

%%
print('plots/simulation_4.svg','-dsvg');

