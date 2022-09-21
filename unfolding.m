% Class unfolding
%
% Created by:
% Stephen V. Gliske (steve.gliske@unmc.edu)
% Department of Neurosurgery
% University of Nebraska Medical Center
%
% (c) 2020-2022 
% Released under CC BY-NC-SA.  No warrenty express or implied.
%

classdef unfolding < handle
  properties (SetAccess = private)
    order(1,1) double {mustBeReal, mustBeFinite}
    n(1,1) double {mustBeReal, mustBeFinite}
    S
    S_inv
    beta
    alpha
    alpha_prime
    gamma
    gamma_uncor
    
    C_S
    C_beta
    C_alpha_S
    C_alpha_beta
    C_alpha
    C_alpha_prime
    C_gamma    
    C_gamma_uncor
   
  end
  methods
    function obj = unfolding( order )
      obj.order = order;
      obj.n = 2*order+1;
    end
    
    function compute_smearing_matrix( obj, phi_M, phi_T )
      % check if true and measured values are the same
      if( nargin < 3 )
        same = true;
      else
        assert( length(phi_M) == length(phi_T) )
        same = (phi_M == phi_T);
      end
      
      %% compute value of basis functions at each data point
      XM = obj.compute_basis(phi_M);  % measured value
      if( same )
        XT = XM;
      else
        XT = obj.compute_basis(phi_T);  % true value
      end
      
      N_sim = length(phi_M);
      X = zeros( N_sim, obj.n, obj.n );
      for i=1:obj.n
          for j=1:obj.n
              X(:,i,j) = XM(:,i) .* XT(:,j);
          end
      end
      X = X(:,:); % now it is N x n^2
      
      % compute smearing matrix
      obj.S = 2*pi* reshape( mean(X,1), obj.n, obj.n );
      obj.C_S = 2*pi* reshape( cov(X)/N_sim, obj.n, obj.n, obj.n, obj.n );
      
      % compute S inverse
      obj.S_inv = inv(obj.S);
    end
    
    function unfold( obj, phi_M )
      %%
      assert( ~isempty(obj.S), 'Error: must compute the smearing matrix before unfolding.' );

      % compute basis at each data point
      X = obj.compute_basis(phi_M);
      
      % compute beta
      obj.beta = mean(X,1)';
      if( size(X,1) == 1 )
        obj.C_beta = nan(size(X,2));
      else
        obj.C_beta = cov(X)/length(phi_M);
      end
      
      % compute alpha
      obj.alpha = obj.S \ obj.beta;
      temp = repmat( obj.alpha', obj.n, 1, obj.n, obj.n );
      C_S_ = squeeze( sum(sum( obj.C_S .* temp .* permute(temp,[3 4 1 2]), 4 ), 2 ));
      
      obj.C_alpha_S    = obj.S_inv * C_S_       * obj.S_inv';
      obj.C_alpha_beta = obj.S_inv * obj.C_beta * obj.S_inv';
      obj.C_alpha = obj.C_alpha_S + obj.C_alpha_beta;
      
      % compute alpha prime (the normalized alpha)
      obj.alpha_prime   = obj.alpha(2:end) / 2/ obj.alpha(1);

      J_alpha = zeros( obj.n-1, obj.n);
      J_alpha(:,1) = -obj.alpha(2:end)/2/(obj.alpha(1)^2);
      J_alpha(:,2:end) = eye(obj.n-1)/2/obj.alpha(1);
      obj.C_alpha_prime = J_alpha * obj.C_alpha * J_alpha';

      % compute the angle and magnitude
      [ obj.gamma, obj.C_gamma ] = obj.angle_and_magnitude( obj.alpha_prime, obj.C_alpha_prime );
      
      % now the uncorrected version (which is beta)
      obj.beta = obj.beta(2:end);
      obj.C_beta = obj.C_beta(2:end,2:end);
      [ obj.gamma_uncor, obj.C_gamma_uncor ] = obj.angle_and_magnitude( obj.beta, obj.C_beta );

    end
    
    function X = compute_basis( obj, phi )
      %% compute the basis function evaluted at phi
      N = length(phi);
      X = ones(N,2*obj.order+1);
      for k=1:obj.order
        X(:,2*k) = cos(k*phi);
        X(:,2*k+1) = sin(k*phi);
      end
    end

    function [gamma, C_gamma] = angle_and_magnitude( ~, alpha, C_alpha )
     
      order = length(alpha)/2;  %#ok<PROPLC>
      half1 = 1:order;          %#ok<PROPLC>
      half2 = half1 + order;    %#ok<PROPLC>
      
      a = alpha( half1 );
      b = alpha( half2 );
      R     = sqrt( a.^2 + b.^2 );
      phase = atan2( b, a );
      
      gamma = [ R; phase ];
      
      J_gamma = zeros( order, order ); %#ok<PROPLC>
      J_gamma( half1, half1 ) = diag(  a ./ R );
      J_gamma( half1, half2 ) = diag(  b ./ R );
      J_gamma( half2, half1 ) = diag( -1 ./ R.^2 );
      J_gamma( half2, half2 ) = diag(  a ./ R.^2 );
      
      C_gamma = J_gamma * C_alpha * J_gamma';
    end
  end
end
