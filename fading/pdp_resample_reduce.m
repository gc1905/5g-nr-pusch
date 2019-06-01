%[r_delay, r_gain] = pdp_resample_reduce(delay, gain, T_0, T_i=10e-9, M=50)
%
% Computes a simplified channel model based on a method 
% described in [1].
%
% [1] Ch. Mehlfuhrer and M. Rupp, "Approximation and resampling 
%     of tapped delay line channel models with guaranteed 
%     channel properties," IEEE Int. Conf. Acoustics, Speech 
%     and Signal Process., Las Vegas, USA, March 2018.
%
% Arguments:
%  delay   - base excess tap delay vector [s]
%  gain    - base relative power vector [dB]
%  T_0     - sampling time of the simulator [s]
%  T_i     - sampling time of the PDP [s]
%  M       - sinc window length
%
% Returns:
%  r_delay - reduced excess tap delay vector [s]
%  r_gain  - reduced relative power vector [dB]

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [r_delay, r_gain] = pdp_resample_reduce(delay, gain, T_0, T_i, N_taps)
  assert(isvector(delay) && isvector(gain), 'delay and gain must be vecors');
  assert(length(delay) == length(gain), 'delay and gain mst have the same length');
  assert(issorted(delay), 'delay vector must be sorted in ascending order');

  if nargin < 4; T_i = 1e-9; end

  % Part I.: Resampling and Path Reduction

  % convert delay-gain vectors to single impulse response vector
  delay_norm = round(delay / T_i);
  gain_norm = 10.0 .^ (gain / 10.0);
  
  a = zeros(max(delay_norm)+1, 1);
  for l = 1 : length(delay_norm)
    a(delay_norm(l)+1) = gain_norm(l);
  end

  ds_rate = T_0 / T_i;
  M_up = 4;
  M = round(ds_rate) * M_up;
  
  fil = sinc(1 / ds_rate * (-M:M));

  b = downsample(conv(a,fil), round(ds_rate));
  
  b(M_up+1) = b(M_up+1) + sum(b(1:M_up));
  b = b(M_up+1:end);
  
  % reduce b to delay-gain form again
  b_delay = find(b ~= 0) - 1;
  b_gain = b(b_delay+1);
  
  while length(b_delay) > N_taps
    % find index and value of the weakest tap
    [~, i_min] = min(abs(b_gain));
    v_min = b_gain(i_min);
    % combine 
    if i_min == length(b_gain)
      b_gain(i_min-1) = b_gain(i_min-1) + v_min;
    elseif i_min == 1
      b_gain(i_min+1) = b_gain(i_min+1) + v_min;
    elseif abs(b_delay(i_min) - b_delay(i_min+1)) > abs(b_delay(i_min) - b_delay(i_min-1))
      b_gain(i_min-1) = b_gain(i_min-1) + v_min;
    elseif abs(b_delay(i_min) - b_delay(i_min+1)) < abs(b_delay(i_min) - b_delay(i_min-1))
      b_gain(i_min+1) = b_gain(i_min+1) + v_min;
    elseif abs(b_gain(i_min+1)) > abs(b_gain(i_min-1))
      b_gain(i_min-1) = b_gain(i_min-1) + v_min;
    else
      b_gain(i_min+1) = b_gain(i_min+1) + v_min;
    end
    b_delay(i_min) = [];
    b_gain(i_min) = [];
  end

  r_delay = b_delay.' * T_0;
  if nargout < 2
    h = zeros(max(r_delay), 1);
    for it = 1 : length(r_delay)
      h(r_delay(it)+1) = b_gain(it);
    end
    r_delay = h;
  else
    r_gain = 10 * log10(abs(b_gain.'));
  end
end