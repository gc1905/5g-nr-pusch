%y = boxplus_approx(a, b)
%
% Approximates boxplus operation between two LLR values of binary 
% random variables using the two-piece linear approximation from [1],
% Equation (4).
%
% [1] G. Richter et. al., "Optimization of a reduced-complexity decoding 
%     algorithm for LDPC codes by density evolution," in IEEE Int. Conf. 
%     Commun. (ICC), vol. Seoul, South Korea, May 2005.
%
% Arguments:
%  a,b    - LLR values
%  approx - if set to non-zero, use linear apporximation to calculate 
%           term ln(1 + exp(-abs(x)))
%           if set to 0, use the true formula
%
% Returns:
%  y     - result of boxplus operation between a and b

% Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function y = boxplus_approx(a, b)
  x1 = sign(a) .* sign(b) .* min(abs(a), abs(b));

  r = abs(a+b);
  if r < 2.5
    x2 = 0.6 - 0.24 * r;
  else
    x2 = 0.0;
  end

  r = abs(a-b);
  if r < 2.5
    x3 = 0.6 - 0.24 * r;
  else
    x3 = 0.0;
  end

  y = x1 + x2 - x3;
end