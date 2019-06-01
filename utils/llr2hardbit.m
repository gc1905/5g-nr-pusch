%b = llr2hardbit(llr)
%
% Converts a matrix of LLR into a binary matrix.
%
% Arguments:
%  llr       - matrix of LLR
%
% Returns:
%  b         - binary matrix

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function b = llr2hardbit(llr)
  b = zeros(size(llr));
  b(llr < 0) = 1;
end