%y = cfo_fd_mtx(N, f_cfo, f_s = 1)
%
% Generates a frequency domain Carrier Frequency Response (CFO)
% matrix. If argument f_s is not provided, f_cfo is interpreted 
% as normalized to sampling frequency.
%
% Arguments:
%  N     - FFT size
%  f_cfo - CFO in Hz
%  df    - subcarrier spacing
%
% Returns:
%  C     - frequency domain CFO matrix

% Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [C] = cfo_fd_mtx(N, f_cfo, df)
  if nargin < 3; df = 15e3; end
  
  assert(isscalar(f_cfo), 'f_cfo must be scalar');

  if f_cfo == 0
    C = eye(N);
  else
    C = zeros(N);
    m = 0 : N-1;
    cfo = f_cfo / df;

    for k = 0 : N-1
      C(:,k+1) = sin(pi*(m-k+cfo)) ./ (N*sin(pi*((m-k+cfo)/N))) .* exp(1i*pi*(m-k+cfo)*(1-1/N));
    end
  end
end