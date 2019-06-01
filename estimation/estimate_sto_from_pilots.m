% f_cfo_est = estimate_sto_from_pilots(y_p, k_idx, l_idx, method='dft')
%
% Estimates time offset of OFDM frame from pilots using Lank-Reed-Pollon 
% (Prony's) or DFT method. 
% Dimension of input vectors is [N_sc, N_sym, N_ant].
%
% Arguments:
%  x_p       - matrix of transmitted pilot symbols
%  y_p       - matrix of received pilot symbols
%  k_idx     - vector of frequency indices of pilot symbols
%  l_idx     - vector of time indices of pilot symbols
%  frame_cfg - OFDM framing constants structure with the elements:
%              N_fft - FFT size
%              N_sc - number of subcarriers allocated for tranmission
%  method    - select estimator: 'dft' (default) or 'prony'
%
% Returns:
%  sto       - estimated sample time offset

% Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function sto = estimate_sto_from_pilots(x_p, y_p, k_idx, l_idx, frame_cfg, method)
  assert(length(k_idx) == size(y_p,1), 'length of k_idx must be the same as the fist dimension of pilot matrix');
  assert(length(l_idx) == size(y_p,2), 'length of l_idx must be the same as the second dimension of pilot matrix');

  if nargin < 5
    method = 'dft';
  end

  pilot_spacing = k_idx(2,1) - k_idx(1,1);
  N_guard = (frame_cfg.N_fft - frame_cfg.N_sc) / 2;
  sto = zeros(size(x_p,3), size(y_p,4));

  if strcmpi(method, 'prony') 
    for n_layer = 1 : size(x_p,3)
      for n_rx_ant = 1 : size(y_p,4)
        H_est = conj(x_p(:,:,n_layer) ) .* y_p(:,:,n_layer,n_rx_ant);
        acc = angle(H_est(1:length(k_idx)-1,:) .* conj(H_est(2:length(k_idx),:)));
        sto(n_layer,n_rx_ant) = 1/pilot_spacing * mean(acc(:)) / (2*pi/frame_cfg.N_fft);
      end
    end
  elseif strcmpi(method, 'dft')
    for n_layer = 1 : size(x_p,3)
      for n_rx_ant = 1 : size(y_p,4)
        H_est = conj(x_p(:,:,n_layer) ) .* y_p(:,:,n_layer,n_rx_ant);
        to_meas = zeros(length(l_idx),1);
        for n_sym = 1 : length(l_idx)
          fd = zeros(frame_cfg.N_fft,1);
          fd(N_guard+k_idx(:,n_layer)) = H_est(:,1);
          PDP = abs(ifft(fd));
          [~,idx] = max(PDP(floor(1:frame_cfg.N_fft / pilot_spacing)));
          to_meas(n_sym) = idx-1;
        end
        sto(n_layer,n_rx_ant) = mean(to_meas);
      end
    end
  else
    error('Time offset estimator not supported: %s', method);  
  end

  est_range = frame_cfg.N_fft / pilot_spacing;
  for r = 1 : numel(sto)
    if sto(r) > est_range/2
      sto(r) = -1 * (est_range - sto(r));
    end
  end
end