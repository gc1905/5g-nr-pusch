%[v] = rms(x)
% 
% Calculates Root Mean Square of discrete signal.
%
% Arguments:
%  x     - vector of signal samples
%  dim   - dimension
%
% Returns:
%  v     - RMS value

% Copyright 2017 Grzegorz Cisek (grzegorzcisek@gmail.com)

function v = rms(x, dim)
  if nargin < 2; dim = 1; end
  v = sqrt(sum(x .* conj(x), dim) / size(x, dim));
end