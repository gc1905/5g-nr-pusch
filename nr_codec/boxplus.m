%y = boxplus(a, b)
%
% Calculates boxplus operation between two LLR values of binary 
% random variables a and b according to [1], Eq. (5).
%
% [1] X. Hu et. al., "Efficient Implementations of the Sum-Product 
%     Algorithm for Decoding LDPCCodes", in IEEE Global. Commun. 
%     Conf. (GLOBECOM), Nov. 2001.
%
% Arguments:
%  a,b    - LLR values
%
% Returns:
%  y     - result of boxplus operation between a and b

% Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function y = boxplus(a, b)
  x1 = sign(a) .* sign(b) .* min(abs(a), abs(b));
  x2 = log(1.0 + exp(-abs(a+b)));
  x3 = log(1.0 + exp(-abs(a-b)));
  y = x1 + x2 - x3;
end