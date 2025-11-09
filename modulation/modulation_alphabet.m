%[A, S0, S1] = modulation_alphabet(Q_m)
%
% Returns a rectangular Gray-coded modulation alphabet for a given 
% modulation order, according to 3GPP 38.211 sec. 5.1.
%
% Arguments:
%  Q_m    - modulation order
%
% Returns:
%  A      - vector consisting of modulation alphabet
%  S0     - matrix of size [Q_m,Q_m^2/2] with indices of constellation
%           points with zeros on a given bit position
%  S1     - matrix of size [Q_m,Q_m^2/2] with indices of constellation
%           points with ones on a given bit position

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [A, S0, S1] = modulation_alphabet(Q_m)
  persistent A_BPSK A_QPSK A_16QAM A_64QAM A_256QAM A_1024QAM

  if isempty(A_BPSK)
    A_BPSK    = generate_modulation_table( 1);
    A_QPSK    = generate_modulation_table( 2);
    A_16QAM   = generate_modulation_table( 4);
    A_64QAM   = generate_modulation_table( 6);
    A_256QAM  = generate_modulation_table( 8);
    A_1024QAM = generate_modulation_table(10);
  end

  if Q_m == 1
    A = A_BPSK;
  elseif Q_m == 2
    A = A_QPSK;
  elseif Q_m == 4
    A = A_16QAM;
  elseif Q_m == 6
    A = A_64QAM;
  elseif Q_m == 8
    A = A_256QAM;
  elseif Q_m == 10
    A = A_1024QAM;
  else
    error('modulation order not supported');
  end

  % TODO: optimize S0 and S1 to be persistent per modulation order
  if nargout > 1
    S0 = zeros(Q_m, length(A) / 2);
    S1 = S0;
    for q = 1 : Q_m
      S0(q,:) = find(bitand(0:length(A)-1, 2^(q-1)) == 0);
      S1(q,:) = find(bitand(0:length(A)-1, 2^(q-1)) ~= 0);
    end
  end
end

function s = sgn_from_bit(x, c, Q_m)
  bit = bitand(bitshift(x, -(Q_m - 1 - c)), 1);
  s = 1 - 2 * bit;
end

function A = generate_modulation_table(Q_m)
  num_points = 2 ^ Q_m;
  A = zeros(num_points,1);

  if Q_m == 1
    A = [1+1i;-1-1i] / sqrt(2);
  elseif Q_m == 2
    s = 1 / sqrt(2);
    for n = 0 : num_points - 1
      A(n+1) = s * complex(
        sgn_from_bit(n,0,Q_m),
        sgn_from_bit(n,1,Q_m)
      );
    end
  elseif Q_m == 4
    s = 1 / sqrt(10);
    for n = 0 : num_points - 1
      A(n+1) = s * complex(
        sgn_from_bit(n,0,Q_m) * (2 - sgn_from_bit(n,2,Q_m)),
        sgn_from_bit(n,1,Q_m) * (2 - sgn_from_bit(n,3,Q_m))
      );
    end
  elseif Q_m == 6
    s = 1 / sqrt(42);
    for n = 0 : num_points - 1
      A(n+1) = s * complex(
        sgn_from_bit(n,0,Q_m) * (4 - sgn_from_bit(n,2,Q_m) * (2 - sgn_from_bit(n,4,Q_m))),
        sgn_from_bit(n,1,Q_m) * (4 - sgn_from_bit(n,3,Q_m) * (2 - sgn_from_bit(n,5,Q_m)))
      );
    end
  elseif Q_m == 8
    s = 1 / sqrt(170);
    for n = 0 : num_points - 1
      A(n+1) = s * complex(
        sgn_from_bit(n,0,Q_m) * (8 - sgn_from_bit(n,2,Q_m) * (4 - sgn_from_bit(n,4,Q_m) * (2 - sgn_from_bit(n,6,Q_m)))),
        sgn_from_bit(n,1,Q_m) * (8 - sgn_from_bit(n,3,Q_m) * (4 - sgn_from_bit(n,5,Q_m) * (2 - sgn_from_bit(n,7,Q_m))))
      );
    end
  elseif Q_m == 10
    s = 1 / sqrt(682);
    for n = 0 : num_points - 1
      A(n+1) = s * complex(
        sgn_from_bit(n,0,Q_m) * (16 - sgn_from_bit(n,2,Q_m) * (8 - sgn_from_bit(n,4,Q_m) * (4 - sgn_from_bit(n,6,Q_m) * (2 - sgn_from_bit(n,8,Q_m))))),
        sgn_from_bit(n,1,Q_m) * (16 - sgn_from_bit(n,3,Q_m) * (8 - sgn_from_bit(n,5,Q_m) * (4 - sgn_from_bit(n,7,Q_m) * (2 - sgn_from_bit(n,9,Q_m)))))
      );
    end
  else
    error('modulation order not supported');
  end
end