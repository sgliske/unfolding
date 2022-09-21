function simulation_3()
%% function simulation_3()
%
% Human NREM sleep
%
%

%% parameters
rng(10000);

data.N_smearing = 100000;
data.N_meas     = 100000;
data.order      = 1;

[amplitude, zenith] = meshgrid( 0.1:0.1:0.5, (1:2:24)/24*2*pi);
data.true.amplitude = amplitude(:);
data.true.zenith    = zenith(:);

order = [ 30 36 setdiff(1:length(data.true.zenith), [30 36] ) ];
data.true.zenith = data.true.zenith(order);
data.true.amplitude = data.true.amplitude(order);

%% create acceptance
f = load('data/human_data.mat');
data.acceptance = f.data(2,1).acceptance;

%% induce and unfold

data = induce_and_unfold( data );

for i=1:2
  fprintf('Induced: %.1f %.1f\n', data.true.amplitude(i), data.true.zenith(i)/pi*12 );
  fprintf('Measured: %.1f %.1f\n', data.meas.amplitude(i), data.meas.zenith(i)/pi*12 );
end
%% plot

plot_simulation_results( data );

%% save

print('plots/simulation_3.svg','-dsvg');
