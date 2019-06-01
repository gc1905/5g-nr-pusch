%[c] = fading_channel_zheng(f_d, f_s, n, N_sin=8)
%
% Calculates coefficients of fading channel based on Sum-of-Sinusoid
% method. Implementation according to Zheng and Xiao model [1].
%
% [1] Y. R. Zheng, C. Xiao, 'Improved models for the generation 
%     of multiple uncorrelated Rayleigh fading waveforms', 
%     IEEE Commun. Lett., vol. 6, no. 6, pp. 256–258, Jun. 2002.
%
% Arguments:
%  f_d   - doppler frequency [Hz]
%  f_s   - baseband sampling frequency [Hz]
%  ns    - vector of sample indices to generate
%  N_sin - number of sinusoids
%
% Returns:
%  c     - vector of complex random variates

% Copyright 2017-2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [c] = fading_channel_zheng(f_d, f_s, ns, N_sin)
  if nargin < 4; N_sin = 8; end

  assert(f_d < f_s, 'f_d must be lower than f_s');

  try
    c = fading_channel_zheng_mex(f_d, f_s, ns, N_sin);
    return;
  catch
    persistent flag
    if isempty(flag)
      disp('fading_channel_zheng: compile mex file to reduce execution time');
      flag = 0;
    end
  end

  % symbol duration
  t = ns / f_s;
 
  % randoms (uniform distribution)
  th = 2 * pi * (rand - 0.5);
  pr = 2 * pi * (rand(1,N_sin) - 0.5);
  pc = 2 * pi * (rand(1,N_sin) - 0.5);

  n_sin = 1:1:N_sin;
  c = zeros(length(ns),1);
  s = sqrt(2 / N_sin);

  for i = 1:length(t)
    ph = 2 * pi * t(i) * f_d * exp(1i * (pi * (2*n_sin - 1) + th) / (4 * N_sin));
    c(i) = s * (sum(cos(real(ph) + pr)) + 1i * sum(cos(imag(ph) + pc)));
  end
end