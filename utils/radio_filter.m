%b = radio_filter(N, frame_cfg)
%
% Designs an OFDM transmission FIR filter using Remez algorithm.
%
% Arguments:
%  N         - FIR filter order or 0 for no filter
%  frame_cfg - structure inorporating OFDM waveform parameters:
%              N_sc      - number of subcarriers allcocated for tranmission
%              scs       - subcarrier spacing [Hz]
%              bandwidth - transmission bandwidth [Hz]
%              F_s       - sampling frequency [Hz]
%
% Returns:
%  b         - FIR filter coefficients

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function b = radio_filter(N, frame_cfg)
  if N == 0
    b = 1;
    return;
  end

  assert(mod(N,2) == 1, 'N must be odd');

  f = [0 frame_cfg.N_sc*frame_cfg.scs frame_cfg.bandwidth frame_cfg.F_s] / frame_cfg.F_s;
  a = [1 1 0 0];
  w = [1 0.8];

  b = firls(N-1, f, a, w);
end