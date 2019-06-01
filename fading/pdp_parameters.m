%[P, m_dly, rms_dly] = pdp_parameters(pdp)
%[P, m_dly, rms_dly] = pdp_parameters(delay, gain)
%
% Computes total power, mean delay and RMS delay spread of
% input PDP. Assumes unitary sampling interval for delay calculation.
%
% Arguments:
%  2 arg version:
%    delay   - base excess tap delay vector [s]
%    gain    - base relative power vector [dB]
%  1 arg version:
%    pdp     - pdp vector
%
% Returns:
%  P         - total power of PDP in linear scale
%  m_dly     - mean delay
%  rms_dly   - RMS delay spread

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [P, m_dly, rms_dly] = pdp_parameters(arg1, arg2)
  if nargin == 1
    delay = find(arg1 ~= 0) - 1;
    gain_lin = arg1(delay+1);
  elseif nargin == 2
    delay = arg1;
    gain = arg2;
    gain_lin = 10 .^ (gain / 20);
  else
    error('invalid numer of arguments');
  end

  P = sum(abs(gain_lin).^2);
  m_dly = sum(abs(gain_lin).^2 .* delay) / P;
  rms_dly = sqrt(sum(abs(gain_lin).^2 .* delay.^2) / P - m_dly^2);
end