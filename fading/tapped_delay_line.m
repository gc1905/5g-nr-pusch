%[iq_fade] = tapped_delay_line(x, tap_delay, tap_gain, tap_coeff)
%
% Applies specified channel according Tapped Delay Line
% FIR filter model to signal samples in time domain.
%
% Arguments:
%  x         - complex time domain sample vector of size (N,1)
%  tap_delay - multipath tap delay vector of size (1,L)
%              (delay unit is sample index)
%  tap_gain  - multipath tap linear gain vector of size (1,L)
%  tap_coeff - matrix of channel fading coefficients of size (N,L)
%
% Returns:
%  iq_fade   - vector of faded signal samples

% Copyright 2017 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [iq_fade] = tapped_delay_line(x, tap_delay, tap_gain, tap_coeff)
  N = size(x,1);
  L = length(tap_gain);
  iq_fade = zeros(N, 1);
  
  assert(length(tap_delay) == length(tap_gain), 'lengths of tap_gain and tap_delay must be equal');
  assert(all(size(tap_coeff) == [N, L]), 'tap_coeff must be a matrix of size [numel(x),L]');

  for i = 1 : L
    iq_fade(tap_delay(i)+1:end) = iq_fade(tap_delay(i)+1:end) + x(1:end-tap_delay(i)) .* tap_coeff(tap_delay(i)+1:end, i) * tap_gain(i);
  end
end