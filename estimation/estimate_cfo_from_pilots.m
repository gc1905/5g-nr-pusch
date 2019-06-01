%f_cfo_est = estimate_cfo_from_pilots(x_p, y_p, k_idx, l_idx, df)
%
% Estimates Carrier Frequency Offset from pilots using method 
% from [1]. Dimension of input vectors is [N_sc, N_sym, N_ant].
%
% [1] F. Classen and H. Meyr, "Frequency synchronization 
%     algorithms for OFDM systems suitable for communication 
%     over frequency selective fading channels," in IEEE Veh. 
%     Technol. Conf. (VTC), June 1994.
%
% Arguments:
%  x_p       - matrix of transmitted pilot symbols
%  y_p       - matrix of received pilot symbols
%  k_idx     - vector of frequency indices of pilot symbols
%  l_idx     - vector of time indices of pilot symbols
%  frame_cfg - OFDM framing constants structure with the elements:
%              scs - subcarrier spacing [Hz]
%
% Returns:
%  f_cfo_est - estimated CFO

% Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function f_cfo_est = estimate_cfo_from_pilots(x_p, y_p, k_idx, l_idx, frame_cfg, method)
  assert(all(size(x_p(:,:,1)) == size(y_p(:,:,1))), 'x_p and y_p must have the same size of the two first dimensions');
  assert(length(k_idx) == size(x_p,1), 'length of k_idx must be the same as the fist dimension of pilot matrix');
  assert(length(l_idx) == size(x_p,2), 'length of l_idx must be the same as the second dimension of pilot matrix');

  if length(l_idx) < 2
    warning('cannot estimate f_cfo from single DMRS symbol');
    f_cfo_est = 0;
    return;
  end

  N_layer = size(x_p, 3);
  N_ant_rx = size(y_p, 4);

  f_cfo = zeros(size(x_p,3), size(y_p,4));

  if strcmpi(method, 'prony') 
    for n_layer = 1 : size(x_p,3)
      for n_rx_ant = 1 : size(y_p,4)
        H = conj(x_p(:,:,n_layer)) .* y_p(:,:,n_layer,n_rx_ant);
        acc = 1./(l_idx(2:numel(l_idx)) - l_idx(1:numel(l_idx)-1)) .*  angle(sum(conj(H(:,2:numel(l_idx))) .* H(:,1:numel(l_idx)-1)));
        f_cfo_est(n_layer,n_rx_ant) = mean(acc(:)) / pi * frame_cfg.scs;
      end
    end
  else
    error('Frequency offset estimator not supported: %s', method);  
  end
end