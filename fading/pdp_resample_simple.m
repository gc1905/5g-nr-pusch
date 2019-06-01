%[r_delay, r_gain] = pdp_resample_simple(delay, gain, T_s)
%
% Computes a simplified channel model with time resolution
% T_s based on method described in [1].
%
% [1] 3GPP TR 25.943 'Technical Specification Group Radio
%     Access Network; Deployment aspects' V13.0.0
%
% Arguments:
%  delay   - base excess tap delay vector [s]
%  gain    - base relative power vector [dB]
%  T_s     - new time resolution for tap spacing [s]
%
% Returns:
%  r_delay - resampled excess tap delay vector [s]
%  r_gain  - resampled relative power vector [dB]

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [r_delay, r_gain] = pdp_resample_simple(delay, gain, T_s)
  assert(isvector(delay) && isvector(gain), 'delay and gain must be vecors');
  assert(length(delay) == length(gain), 'delay and gain mst have the same length');
  assert(issorted(delay), 'delay vector must be sorted in ascending order');

  r_delay = [];
  r_gain  = [];

  T = (0 : ceil(delay(end)/T_s)) * T_s;

  idx = 1;
 
  for t = T
    gain_acc = [];
    while (idx <= length(delay)) && (t + 0.5 * T_s >= delay(idx))
      gain_acc(end+1) = gain(idx);
      idx = idx + 1;
    end

    if ~isempty(gain_acc)
      r_delay(end+1) = t;
      r_gain(end+1) = 10 * log10( sum(10 .^ (gain_acc / 10)) );

      % if numel(gain_acc) > 1; warning('PDP path reduced at sample %d', t/T_s); end 
    end
  end

  if nargout < 2
    h = zeros(max(r_delay), 1);
    for it = 1 : length(r_delay)
      h(r_delay(it)+1) = 10 ^ (r_gain(it)/10);
    end
    r_delay = h;
  end
end