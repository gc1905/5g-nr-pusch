%x = randiq(ord, sz)
%
% Generates random IQ samples.
%
% Arguments:
%  ord      - modulation order
%              1 - BPSK
%              2 - QPSK
%              4 - 16QAM
%              6 - 64QAM
%  sz       - output matrix size
%
% Returns:
%  x        - matrix of random IQ samples

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function x = randiq(ord, sz)
  num = prod(sz);
  b = randi([0 1], num*ord, 1);
  x = modulation_mapper(b, ord);
  x = reshape(x, sz);
end