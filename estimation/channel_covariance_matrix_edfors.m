%R_hh = channel_covariance_matrix_edfors(N_fft, L, t_rms)
%
% Calculates approximation of the multipath channel covariance 
% matrix according to [1] Equation (11).
%
% [1] O. Edfors et. al., "OFDM Channel Estimation by Singular 
%     Value Decomposition," IEEE Trans. Commun., vol. 46, 
%     no. 7, July 1998.
%
% Arguments:
%  N_fft     - FFT size
%  L         - number of multipath components
%  t_rms     - RMS delay spread of the channel (in samples)
%
% Returns:
%  R_hh      - covariance matrix

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function R_hh = channel_covariance_matrix_edfors(N_fft, L, t_rms)
  R_hh = zeros(N_fft);

  m = repmat((0:N_fft-1)', [1 N_fft]);
  n = repmat((0:N_fft-1) , [N_fft 1]);

  R_hh = (1 - exp(-L * (1/t_rms + 2i*pi*(m-n)/N_fft) )) ./ (t_rms * (1 - exp(-L/t_rms)) .* (1/t_rms + 2i*pi*(m-n)/N_fft) );
end