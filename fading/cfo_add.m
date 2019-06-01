%y = cfo_add(x, f_cfo, f_s = 1, offset = 0)
%
% Adds Carrier Frequency Offset f_cfo to input time-domain 
% samples. If argument f_s is not provided, f_cfo is interpreted 
% as normalized to sampling frequency.
%
% Arguments:
%  x      - vector of time-domain samples size = (N_sample, N_ant)
%  f_cfo  - CFO in Hz
%  f_s    - sampling frequency in Hz
%  offset - starting sample offset
%
% Returns:
%  y     - vector of time-domain samples with CFO added

% Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function y = cfo_add(x, f_cfo, f_s, offset)
  if nargin < 3; f_s = 1; end
  if nargin < 4; offset = 0; end

  N_sample = size(x,1);
  N_ant = size(x,2);

  ph = exp(-2i * pi *  (offset + (0 : N_sample-1)).' * (f_cfo / f_s));

  y = zeros(size(x));

  for n_ant = 1 : N_ant
    y(:,n_ant) = x(:,n_ant) .* ph;
  end
end