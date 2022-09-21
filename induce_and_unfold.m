function data = induce_and_unfold( data )
%% function data = induce_and_unfold( data )
%
% Required data fields:
%
% N_smearing     -- number of events for estimating the smearing matrix
% N_meas         -- number of events for measured distribution
% order          -- order for unfolding
% acceptance     -- pwc object describing the acceptance
% true.amplitude -- vector of Fourier magnitudes for true distribution
% true.zentith   -- vector of Fourier zeniths for true distribution
%
% Additional fields added:
% meas.amplitude -- vector of Fourier magnitudes for measured (uncorrected) distribution 
% meas.zenith    -- vector of Fourier zeniths for measured distribution
% unf.amplitude  -- vector of Fourier magnitudes computed by unfolding
% unf.zenith     -- vector of Fourier zeniths computed by unfolding

%% prep

N_values = length(data.true.zenith);
assert( length(data.true.amplitude)  == N_values );
data.meas.amplitude = zeros(N_values,1);
data.meas.zenith    = zeros(N_values,1);
data.unf.amplitude  = zeros(N_values,1);
data.unf.zenith     = zeros(N_values,1);

%% Create smearing matrix

% unfolding object
obj = unfolding(data.order);

% generate simulated data according to acceptance
phi_sim = data.acceptance.genData(data.N_smearing) / data.acceptance.max_x * 2*pi;

% compute the smearing matrix
obj.compute_smearing_matrix(phi_sim);

%% induce true distribution

A = data.true.amplitude.*[cos(data.true.zenith) sin(data.true.zenith)];
data.meas.phi = zeros( data.N_meas, N_values );
data.true.phi = zeros( data.N_meas, 2 );

for k=1:N_values
  %% run simulation with a given set of true parameters
  
  % induce moment
  phi_test = induce_moment( A(k,1), A(k,2), data.N_meas, data.acceptance );
  
  % unfold
  obj.unfold( phi_test );
  
  % true data (for plotting)
  if( k <= 2 )
     data.true.phi(:,k) = induce_moment( A(k,1), A(k,2), data.N_meas );
  end
  
  % copy results
  data.cond              = cond(obj.S);
  data.meas.zenith(k)    = mod(atan2( obj.beta(2), obj.beta(1) ), 2*pi);
  data.meas.amplitude(k) = 2*sqrt(sum(obj.beta.^2));     % 2 x (...) as we are plotting the Fourier amplitudes
  data.meas.phi(:,k)     = phi_test;
  data.unf.zenith(k)     = mod(atan2( obj.alpha_prime(2), obj.alpha_prime(1) ), 2*pi);
  data.unf.amplitude(k)  = 2*sqrt(sum(obj.alpha_prime.^2));  % 2 x (...) as we are plotting the Fourier amplitudes
  
end


