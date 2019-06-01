%y = nr_ofdma_modulator(x, frame_cfg, slot_num)
%
% Applies OFDM modulation to a slot time domain signal as specified 
% in 3GPP 38.211 sec. 5.3.1. Adds cyclic prefix and guardbands.
% Input array x may hold RE grids for multiple antenna layers in the 
% 3rd dimension.
%
% Arguments:
%  x         - RE grid (3-D array of size [N_sc,N_slot_symbol,N_ant])
%  frame_cfg - OFDM framing constants structure with the elements:
%              N_fft - FFT size
%              N_sc  - number of subcarriers allocated for transmission
%              N_slot_symbol   - number of symbols in a slot
%              N_subframe_slot - number of slots in a subframe
%              u - OFDM numerology (as per 3GPP 38.211 sec. 4.3.2)
%  slot_num  - number of slot in frame
%
% Returns:
%  y         - time domain OFDM signal (matrix of size [N_sample_slot,N_ant])

% Copyright 2017-2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function y = nr_ofdma_modulator(x, frame_cfg, slot_num)
  assert(size(x,1) == frame_cfg.N_sc && size(x,2) == frame_cfg.N_slot_symbol, 'input mst be be of size [N_sc,N_slot_symbol,N_ant]');

  N_ant = size(x,3);
  N_guard = (frame_cfg.N_fft - frame_cfg.N_sc) / 2;

  [N_cp_first, N_cp_other] = nr_cyclic_prefix_len(frame_cfg, slot_num);

  samples_in_slot = nr_samples_in_slot(frame_cfg, slot_num);
  y = zeros(samples_in_slot, N_ant);

  for ant = 1 : N_ant
    % guardband addition
    x_gb = [zeros(N_guard,frame_cfg.N_slot_symbol); x(:,:,ant); zeros(N_guard,frame_cfg.N_slot_symbol)];
    y_framed = zeros(frame_cfg.N_fft, frame_cfg.N_slot_symbol);

    for l = 1 : frame_cfg.N_slot_symbol
      if any(x(:,l))
        y_framed(:,l) = ifft(ifftshift(x_gb(:,l))) * sqrt(frame_cfg.N_fft);
      else
        y_framed(:,l) = zeros(frame_cfg.N_fft,1);
      end
    end

    % add CP and serialize
    sidx = 0;
    for l = 1 : frame_cfg.N_slot_symbol
      if l == 1
        N_cp = N_cp_first;
      else
        N_cp = N_cp_other;
      end

      y(sidx+1:sidx+N_cp,ant) = y_framed(end-N_cp+1:end,l);
      sidx = sidx + N_cp;
      y(sidx+1:sidx+frame_cfg.N_fft,ant) = y_framed(:,l);
      sidx = sidx + frame_cfg.N_fft;
    end
  end
end