%[H_est, v] = channel_estimate_SIMO(x_p, y_p, f_interp, t_interp, avg, method='LS')
%[H_est, v] = channel_estimate_SIMO(x_p, y_p, f_interp, t_interp, avg, method='MMSE', N_fft)
%
% Estimates the wireless channel matrix H using Least-Squares or 
% Minimum Mean Squared Error method. Performs interpolation of 
% estimated channel response using cubic splines.
% For SIMO channels only.
%
% Arguments:
%  x_p       - matrix of transmitted pilot symbols size [N_freq,N_time]
%  y_p       - matrix of received pilot symbols size [N_freq,N_time,N_rx_ant]
%  k_idx     - vector of frequency indices of pilot symbols
%  l_idx     - vector of time indices of pilot symbols
%  grid_size - size of frequency-time grid [N_freq,N_time]
%  avg       - determines how averaging is done on channel
%              estimate of frequency-time grid [A_freq,A_time]
%
% Returns:
%  H_est     - estimated channel time-frequency grid
%  P_noise   - estimated variance of complex Gaussian noise
%  P_signal  - estimated signal power

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [H_est, P_noise, P_signal] = channel_estimate_SIMO(x_p, y_p, k_idx, l_idx, grid_size, avg, method, N_fft)
  if nargin < 7
    method = 'LS';
  end

  if ndims(x_p) <= 2 && ndims(y_p) <= 2
    [H_est, v] = channel_estimate(x_p, y_p, k_idx, l_idx, grid_size, avg, method, N_fft);
    return;
  end

  assert(all(size(x_p(:,:,1)) == size(y_p(:,:,1))), 'x_p and y_p must have the same size of the two first dimensions');
  assert(ismatrix(x_p), 'x_p must have only 2 non-singleton dimensions');
  assert(ndims(y_p) == 3, 'y_p must have 3 non-singleton dimensions');
  assert(length(k_idx) == size(x_p,1), 'length of k_idx must be the same as the fist dimension of pilot matrix');
  assert(length(l_idx) == size(x_p,2), 'length of l_idx must be the same as the second dimension of pilot matrix');

  persistent R_hh N_fft_R_hh

  k_idx = reshape(k_idx, [], 1);
  l_idx = reshape(l_idx, [], 1);

  N_re = size(x_p,1);
  N_sym = size(x_p,2);
  N_rx_ant = size(y_p,3);

  H_est_raw = zeros(N_re, N_sym, N_rx_ant);

  for n_re = 1 : N_re
    for n_sym = 1 : N_sym
      H_est_raw(n_re,n_sym,:) = conj(x_p(n_re,n_sym)) * y_p(n_re,n_sym,:);
    end
  end

  % averaging
  H_est_raw_avg = H_est_raw;
  for n_ant = 1 : N_rx_ant
    if avg(1) > 0
      H_est_raw_avg(:,:,n_ant) = movavg(H_est_raw_avg(:,:,n_ant), avg(1), 1);
    end
    if length(l_idx) > 1 && avg(2) > 0
      H_est_raw_avg(:,:,n_ant) = movavg(H_est_raw_avg(:,:,n_ant), avg(2), 2);
    end
  end
  P_noise = var(H_est_raw_avg(:) - H_est_raw(:));
  P_signal = var(H_est_raw_avg(:));

  H_est = zeros(grid_size(1), grid_size(2), N_rx_ant);

  if strcmpi(method, 'MMSE')
    if isempty(R_hh) || N_fft_R_hh ~= N_fft
      N_fft_R_hh = N_fft;
      % use magic numbers for L and t_rms
      R_hh = channel_covariance_matrix_edfors(N_fft, 10, 1.25);
    end

    R_hh_dec = R_hh(k_idx, k_idx);
    S = R_hh_dec * inv(R_hh_dec + P_noise / P_signal * eye(size(R_hh_dec,1)));
    for n_ant = 1 : N_rx_ant
      for n_sym = 1 : length(l_idx)
        H_est_dec(:,n_sym,n_ant) = S * H_est_raw(:,n_sym,n_ant);
      end
    end
  elseif strcmpi(method, 'LS') 
    H_est_dec = H_est_raw_avg;
  else
    error('Channel estimation method not supported: %s', method);
  end

  % interpolate
  if length(l_idx) < 2
    % 1D interpolation in frequency domain
    for n_ant = 1 : N_rx_ant
      H_est_s = interp1(k_idx, H_est_dec(:,:,n_ant), 1:grid_size(1), 'spline');
      H_est_s = reshape(H_est_s, [], 1);
      H_est(:,:,n_ant) = repmat(H_est_s, [1 grid_size(2)]);
    end
  else
    % 2D interploation
    X = repmat(reshape(l_idx, 1, []), [length(k_idx) 1]);
    Y = repmat(reshape(k_idx, [], 1), [1 length(l_idx)]);
    Xp = repmat(1:grid_size(2), [grid_size(1) 1]);
    Yp = repmat((1:grid_size(1))', [1 grid_size(2)]);

    for n_ant = 1 : N_rx_ant
      H_est(:,:,n_ant) = interp2(X, Y, H_est_dec(:,:,n_ant), Xp, Yp, 'spline');
    end
  end
end