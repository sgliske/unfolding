function simulation_4()
%% function simulation_4()
%
% Scan over all patient data, using the patient data as the acceptance.
%

%% prep

% parameters
data_init.N_smearing = 100000;
data_init.order      = 1;
data_init.true.amplitude = zeros(1000,1);
data_init.true.zenith    = zeros(1000,1);

% patient data
f = load('data/human_data.mat');
[nP,nS] = size(f.data);

% prep
results = cell(nP,nS);

%% loop

ticA = tic;
for i=1:nP
  %%
  fprintf('On %2d of %d\n', i, nP );
  for j=1:nS

    data = data_init;
    data.acceptance = f.data(i,j).acceptance;
    data.N_meas = f.data(i,j).nHFOs;
   
    data = induce_and_unfold( data );
    results{i,j}.nHFOs     = data.N_meas;
    results{i,j}.cond      = data.cond;
    results{i,j}.threshold = quantile( data.unf.amplitude, 0.95 ) / 2;  % /2 to convert from Fourier to circular moment

  end
end
toc(ticA); % about 400 sec

%%
results = cell2mat(results);

save('data/simulation_4_results.mat','results');

