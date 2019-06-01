%r = zadoffchu(n, N_zc, u = 1)
% 
% Generates a u-th Zadoff-Chu sequence of length N_zc.
%
% Arguments:
%  n    - vector of indices
%  N_zc - length of ZC sequence
%  u    - sequence number
%
% Returns:
%  r    - Zadoff-Chu sequence

% Copyright 2017 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [r] = zadoffchu (n, N_zc, u)
  if nargin < 3; u = 1; end
  r = exp(-1i .* pi .* u .* n .* (n + 1) ./ N_zc);
end