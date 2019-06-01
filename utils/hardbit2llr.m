%llr = hardbit2llr(b, maxval=1)
%
% Converts a binary matrix into a matrix of LLR.
%
% Arguments:
%  b         - binary matrix
%  maxval    - amplitude of LLR
%
% Returns:
%  llr       - matrix of LLR

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function llr = hardbit2llr(b, maxval)
  if nargin < 2
    maxval = 1;
  end

  llr = ones(size(b)) * maxval;
  llr(b == 1) = -maxval;
end