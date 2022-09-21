function phi = induce_moment( a, b, N, acceptance )
%%
%
%
%

if( nargin < 4 )
  % uniform over full 2*pi (ideal acceptance)
  phi = rand(3*N,1)*2*pi;
else
  % uniform within acceptance
  phi = acceptance.genData(3*N) / acceptance.max_x * 2*pi;
end

% evaluate pdf
pdf = 1 + a*cos(phi) + b*sin(phi);
pdf = pdf/max(pdf);

% discard data to induce moment
keep = pdf > rand(size(pdf));
phi = phi(keep);

% reduce to exactly the given N
phi = phi(1:N);
