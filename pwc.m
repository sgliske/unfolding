% Class pwc
%
% Created by:
% Stephen V. Gliske (steve.gliske@unmc.edu)
% Department of Neurosurgery
% University of Nebraska Medical Center
%
% (c) 2020-2022 
% Released under CC BY-NC-SA.  No warrenty express or implied.
%

classdef pwc
  properties 
    x(:,1) double {mustBeReal, mustBeFinite}
    y(:,1) double {mustBeReal, mustBeFinite}
    w(:,1) double {mustBeReal, mustBeFinite}
    max_x(1,1) double {mustBeReal}
  end
  methods
    function obj = pwc( x_in, y_in, max_x )
      obj.x = x_in;
      obj.y = y_in;
      obj.w = diff( [x_in; max_x] );
      obj.max_x = max_x;
    end
    
    function bin = getBin( obj, x )
      bin = discretize( x, [obj.x; obj.max_x ] )';
    end
    
    function y = getValue( obj, x )
      y = obj.y( obj.getBin(x) );
    end
    
    function w = getWidth( obj, x )
      w = obj.w( obj.getBin(x) );
    end
    
    function a = getArea( obj )
      a = obj.w' * obj.y;
    end
    
    function x_out = genData( obj, N )
      %% generate data according to the distribution 
      a = obj.y .* obj.w;
      cdf = [obj.x(1); cumsum( a ) ];
      a = a / max(cdf);
      cdf = cdf / max(cdf);

      r = rand(N,1)*(obj.max_x-obj.x(1)) + obj.x(1);
      b = discretize( r, cdf );
      
      x_out = (r - cdf(b)) ./ a(b) .* obj.w(b) + obj.x(b);
    end
    
  end
end


