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
  persistent A_BPSK A_QPSK A_16QAM A_64QAM

  if isempty(A_BPSK)
    A_BPSK = [   1+1i*1
                -1-1i*1] / sqrt(2);

    A_QPSK = [   1+1i*1
                 1-1i*1
                -1+1i*1
                -1-1i*1] / sqrt(2);

    A_16QAM = [  1+1i*1
                 1+1i*3
                 3+1i*1
                 3+1i*3
                 1-1i*1
                 1-1i*3
                 3-1i*1
                 3-1i*3
                -1+1i*1
                -1+1i*3
                -3+1i*1
                -3+1i*3
                -1-1i*1
                -1-1i*3
                -3-1i*1
                -3-1i*3] / sqrt(10);

    A_64QAM = [  3+1i*3
                 3+1i*1
                 1+1i*3
                 1+1i*1
                 3+1i*5
                 3+1i*7
                 1+1i*5
                 1+1i*7
                 5+1i*3
                 5+1i*1
                 7+1i*3
                 7+1i*1
                 5+1i*5
                 5+1i*7
                 7+1i*5
                 7+1i*7

                 3-1i*3
                 3-1i*1
                 1-1i*3
                 1-1i*1
                 3-1i*5
                 3-1i*7
                 1-1i*5
                 1-1i*7
                 5-1i*3
                 5-1i*1
                 7-1i*3
                 7-1i*1
                 5-1i*5
                 5-1i*7
                 7-1i*5
                 7-1i*7

                -3+1i*3
                -3+1i*1
                -1+1i*3
                -1+1i*1
                -3+1i*5
                -3+1i*7
                -1+1i*5
                -1+1i*7
                -5+1i*3
                -5+1i*1
                -7+1i*3
                -7+1i*1
                -5+1i*5
                -5+1i*7
                -7+1i*5
                -7+1i*7

                -3-1i*3
                -3-1i*1
                -1-1i*3
                -1-1i*1
                -3-1i*5
                -3-1i*7
                -1-1i*5
                -1-1i*7
                -5-1i*3
                -5-1i*1
                -7-1i*3
                -7-1i*1
                -5-1i*5
                -5-1i*7
                -7-1i*5
                -7-1i*7] / sqrt(42);
  end

  if Q_m == 1
    A = A_BPSK;
  elseif Q_m == 2
    A = A_QPSK;
  elseif Q_m == 4
    A = A_16QAM;
  elseif Q_m == 6
    A = A_64QAM;
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