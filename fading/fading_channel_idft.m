%[c] = fading_channel_idft(f_d, f_s, n)
%
% Calculates coefficients of Rayleigh fading waveform based on 
% IDFT method.
%
% [1] D.Young, N. Beaulieu, "The Generation of Correlated 
%     Rayleigh Random Variates by Inverse Discrete Fourier
%     Transform", IEEE Trans. Commun., vol. 48, no. 7, 
%     July 2000
%
% Arguments:
%  f_d - doppler frequency [hz]
%  f_s - baseband sampling frequency [hz]
%  N   - time domain indices of samples to generate
%
% Returns:
%  c   - channel coefficients

% Copyright 2017 Grzegorz Cisek (grzegorzcisek@gmail.com)

function c = fading_channel_idft(f_d, f_s, n)
  N = max(n) - min(n) + 1;

  f_norm = f_d / f_s;
  k_m = floor(f_norm * N);
  
  if k_m == 0
    error('WARNING: floor(f_norm * N) = 0'); 
  end

  % generate frequency mask
  F_m = zeros(N, 1);
  for k = 1 : k_m - 1
    F_m(k+1) = 1 / sqrt(2 * sqrt(1 - (k / N / f_norm)^2));
    F_m(N-k+1) = 1 / sqrt(2 * sqrt(1 - (k / N / f_norm)^2));
  end

  F_m(k_m+1) = sqrt(k_m/2 * (pi/2 - atan((k_m - 1)/sqrt(2*k_m - 1))));
  F_m(N-k_m+1) = F_m(k_m+1);

  uscale = sqrt(2) * N / sqrt(sum(F_m));

  % multiply by random variates
  F_m([1:k_m, end-k_m+1:end]) = F_m([1:k_m, end-k_m+1:end]) .* (randn(2*k_m,1) + 1i * randn(2*k_m,1)) / sqrt(2);

  % apply IDFT and apply unitary scaling
  c = ifft(F_m) * uscale;

  c = c(n - min(n) + 1);
end