%[x] = modulation_demapper_soft(iq, ord, method, N0)
%
% Demodulates complex data vector using specified modulation 
% type.
% Use soft decision with LLR.
%
% [1] A. Viterbi, "An Intuitive Justification and a Simplified Implementation 
%     of the MAP Decoder for Convolutional Codes," IEEE J. Sel. Areas Commun.,
%     vol. 16, no. 2, pp. 260-264, Feb. 1998.
%
% Arguments:
%  iq     - matrix of modulated complex IQ samples
%  ord    - modulation order
%           1 - BPSK
%           2 - QPSK
%           4 - 16QAM
%           6 - 64QAM
%
%  method - soft-demodulation algorithm selection:
%           'True LLR'   - true LLR using LOGMAP
%           'Approx LLR' - Viterbi LLR appoximation [1]
%           'Hard'       - hard demodulation
%
%  N0     - noise variance, may be provided as a single value, 
%           or one per IQ sample
%
% Returns:
%  x      - vector of LLR

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [x] = modulation_demapper_soft(iq, ord, method, N0)
  if nargin < 3; method = 'Hard'; end
  if nargin < 4; N0 = 0.01; end

  if numel(N0) == 1
    N0 = ones(size(iq)) * N0;
  end

  x = zeros(numel(iq)*ord, 1);

  [A, S0, S1] = modulation_alphabet(ord);

  try
    x = modulation_demapper_soft_mex(iq, ord, method, N0, A, S0-1, S1-1);
    return;
  catch
    persistent flag
    if isempty(flag)
      disp('modulation_demapper_soft: compile mex file to reduce execution time');
      flag = 0;
    end
  end

  if strcmpi(method, 'True LLR')
    for idx = 1 : numel(iq)
      for q = 1 : ord
        P0 = sum( exp(-abs(iq(idx) - A(S0(q,:))).^2 / N0(idx)) );
        P1 = sum( exp(-abs(iq(idx) - A(S1(q,:))).^2 / N0(idx)) );
        x(ord*idx-q+1) = tlog(P0) - tlog(P1);
      end
    end
  elseif strcmpi(method, 'Approx LLR')
    for idx = 1 : numel(iq)
      for q = 1 : ord
        d0 = min( abs(iq(idx) - A(S0(q,:))).^2 );
        d1 = min( abs(iq(idx) - A(S1(q,:))).^2 );
        x(ord*idx-q+1) = -1 * (1 / N0(idx)) *  (d0 - d1);
      end
    end
  elseif strcmpi(method, 'Hard')
    for idx = 1 : numel(iq)
      for q = 1 : ord
        d0 = min( abs(iq(idx) - A(S0(q,:))).^2 );
        d1 = min( abs(iq(idx) - A(S1(q,:))).^2 );
        if d0 > d1
          x(ord*idx-q+1) = - 1/N0(idx);
        else
          x(ord*idx-q+1) = 1/N0(idx);
        end
      end
    end
  else
    error('demodulation method not supported ("%s")', method);
  end
end

% truncated logarithm - to avoid NaNs in the results
function y = tlog(x)
  if isinf(x)
    x = realmax;
  elseif (x <= 0)
    x = eps;
  end
  y = log(x);
end