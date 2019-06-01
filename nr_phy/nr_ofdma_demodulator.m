%x = nr_ofdma_demodulator(y, frame_cfg, slot_num)
%
% Applies OFDM demodulation to a slot time domain signal as specified 
% in 3GPP 38.211 sec. 5.3.1. Removes cyclic prefix and guardbands.
% Input y may be a matrix holding OFDM signals from multiple antennas.
%
% Arguments:
%  y         - time domain OFDM signal (matrix of size [N_sample_slot,N_ant])
%  frame_cfg - OFDM framing constants structure with the elements:
%              N_fft - FFT size
%              N_sc  - number of subcarriers allocated for transmission
%              N_slot_symbol   - number of symbols in a slot
%              N_subframe_slot - number of slots in a subframe
%              u - OFDM numerology (as per 3GPP 38.211 sec. 4.3.2)
%  slot_num  - number of slot in frame
%
% Returns:
%  x         - RE grid (3-D array of size [N_sc,N_slot_symbol,N_ant])

% Copyright 2017-2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function x = nr_ofdma_demodulator(y, frame_cfg, slot_num)
  [N_cp_first, N_cp_other] = nr_cyclic_prefix_len(frame_cfg, slot_num);
  N_guard = (frame_cfg.N_fft - frame_cfg.N_sc) / 2;

  N_ant = size(y,2);
  x = zeros(frame_cfg.N_sc, frame_cfg.N_slot_symbol, N_ant);

  for ant = 1 : N_ant
    y_framed = zeros(frame_cfg.N_fft, frame_cfg.N_slot_symbol);
    sidx = 0;

    for l = 1 : frame_cfg.N_slot_symbol
      if l == 1
        N_cp = N_cp_first;
      else
        N_cp = N_cp_other;
      end

      sidx = sidx + N_cp;
      y_framed(:,l) = y(sidx+1:sidx+frame_cfg.N_fft,ant);
      sidx = sidx + frame_cfg.N_fft;
    end

    for l = 1 : frame_cfg.N_slot_symbol
      if any(y_framed(:,l))
        x_gb = fftshift(fft(y_framed(:,l))) / sqrt(frame_cfg.N_fft);
        x(:,l,ant) = x_gb(1+N_guard:N_guard+frame_cfg.N_sc);
      else
        x(:,l,ant) = zeros(frame_cfg.N_sc,1);
      end
    end
  end
end