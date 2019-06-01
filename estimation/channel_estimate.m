%[H_est, v] = channel_estimate_LS(x_p, y_p, f_interp, t_interp, avg, method='LS')
%[H_est, v] = channel_estimate_LS(x_p, y_p, f_interp, t_interp, avg, method='MMSE', N_fft)
%
% Estimates the wireless channel matrix H using Least-Squares or 
% Minimum Mean Squared Error method. Performs interpolation of 
% estimated channel response using cubic splines.
% For SISO channels only.
%
% Arguments:
%  x_p       - matrix of transmitted pilot symbols
%  y_p       - matrix of received pilot symbols
%  k_idx     - vector of frequency indices of pilot symbols
%  l_idx     - vector of time indices of pilot symbols
%  grid_size - size of frequency-time grid [N_freq,N_time]
%  avg       - determines how averaging is done on channel
%              estimate of frequency-time grid [A_freq,A_time]
%  method    - channel estimator: 'LS' or 'MMSE'
%  N_fft     - OFDM FFT size
%
% Returns:
%  H_est     - estimated channel time-frequency grid
%  P_noise   - estimated variance of complex Gaussian noise
%  P_signal  - estimated signal power

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [H_est, P_noise, P_signal] = channel_estimate(x_p, y_p, k_idx, l_idx, grid_size, avg, method, N_fft)
  assert(all(size(x_p) == size(y_p)), 'x_p and y_p must have the same sizes');
  assert(length(k_idx) == size(x_p,1), 'length of k_idx must be the same as the fist dimension of pilot matrix');
  assert(length(l_idx) == size(x_p,2), 'length of l_idx must be the same as the second dimension of pilot matrix');

  if nargin < 7
    method = 'LS';
  end

  persistent R_hh N_fft_R_hh

  k_idx = reshape(k_idx, [], 1);
  l_idx = reshape(l_idx, [], 1);

  H_est_raw = conj(x_p) .* y_p;
  
  % averaging
  H_est_raw_avg = H_est_raw;
  if avg(1) > 0
    H_est_raw_avg = movavg(H_est_raw_avg, avg(1), 1);
  end
  if length(l_idx) > 1 && avg(2) > 0
    H_est_raw_avg = movavg(H_est_raw_avg, avg(2), 2);
  end
  P_noise = var(H_est_raw_avg(:) - H_est_raw(:));
  P_signal = var(H_est_raw_avg(:));

  if strcmpi(method, 'MMSE')
    if isempty(R_hh) || N_fft_R_hh ~= N_fft
      N_fft_R_hh = N_fft;
      % use magic numbers for L and t_rms
      R_hh = channel_covariance_matrix_edfors(N_fft, 10, 32);
    end

    R_hh_dec = R_hh(k_idx, k_idx);
    H_est_dec = zeros(size(H_est_raw));
    S = R_hh_dec * inv(R_hh_dec + P_noise / P_signal * eye(size(R_hh_dec,1)));
    for n = 1 : length(l_idx)
      H_est_dec(:,n) = S * H_est_raw(:,n);
    end
  elseif strcmpi(method, 'LS') 
    H_est_dec = H_est_raw_avg;
  else
    error('Channel estimation method not supported: %s', method);
  end

  % interpolate
  if length(l_idx) < 2
    % 1D interpolation in frequency domain
    H_est_s = interp1(k_idx, H_est_dec, 1:grid_size(1), 'spline');
    H_est_s = reshape(H_est_s, [], 1);
    H_est = repmat(H_est_s, [1 grid_size(2)]);
  else
    % 2D interploation
    X = repmat(reshape(l_idx, 1, []), [length(k_idx) 1]);
    Y = repmat(reshape(k_idx, [], 1), [1 length(l_idx)]);
    Xp = repmat(1:grid_size(2), [grid_size(1) 1]);
    Yp = repmat((1:grid_size(1))', [1 grid_size(2)]);

    H_est = interp2(X, Y, H_est_dec, Xp, Yp, 'spline');
  end
end