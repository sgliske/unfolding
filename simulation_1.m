function simulation_1()
%% function simulation_1()
%
% Zero acceptance 18-24 hours
%
%

%% parameters
rng(10000);

data.N_smearing = 100000;
data.N_meas     = 100000;
data.order      = 1;
data.true.amplitude = 0.3*ones(12,1);
data.true.zenith    = (1:2:24)'/24 *2*pi;

order = [ 2 11 1 3:10 12 ];
data.true.zenith = data.true.zenith(order);

%% create acceptance

data.acceptance = pwc( [0 18/24]', [1 0]', 1 );

%% induce and unfold

data = induce_and_unfold( data );

for i=1:2
  fprintf('Induced: %.1f %.1f\n', data.true.amplitude(i), data.true.zenith(i)/pi*12 );
  fprintf('Measured: %.1f %.1f\n', data.meas.amplitude(i), data.meas.zenith(i)/pi*12 );
end

%% plot

plot_simulation_results( data );

print('plots/simulation_1.svg','-dsvg');

