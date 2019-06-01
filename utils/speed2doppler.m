%f_d = speed2doppler(v, f_c, vunit = 'kmph')
% 
% Calculates Doppler frequency from velocity and 
% carrier frequency for moving transmitter.
%
% Arguments:
%  v     - transmitter speed
%  f_c   - carrier frequency in Hz
%  vunit - unit of v ('kmph', 'mps')
%
% Returns:
%  f_d   - Doppler frequency in Hz

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function f_d = speed2doppler(v, f_c, vunit)
  if nargin < 3
    vunit = 'kmph';
  end

  if strcmpi(vunit, 'kmph')
    v = v * 1000 / 3600;
  elseif strcmpi(vunit, 'mps')
    v = v;
  else
    error('Velocity unit not supported (%s)', vunit);
  end

  f_d = v * f_c / 3e8;
end