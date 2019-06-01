%n = nr_samples_in_slot(frame_cfg, slot_num)
%
% Calculates a number of time-domain samples in a slot.
%
% Arguments:
%  frame_cfg - OFDM framing constants structure with the elements:
%              N_fft - FFT size
%              N_slot_symbol   - number of symbols in a slot
%              N_subframe_slot - number of slots in a subframe
%              u - OFDM numerology (as per 3GPP 38.211 sec. 4.3.2)
%  slot_num  - number of slot in frame
%
% Returns:
%  n         - number of samples in a slot

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function n = nr_samples_in_slot(frame_cfg, slot_num)
  [N_cp_first, N_cp_other] = nr_cyclic_prefix_len(frame_cfg, slot_num);
  if frame_cfg.u == 0
    n = 2 * N_cp_first + (frame_cfg.N_slot_symbol-2)*N_cp_other + frame_cfg.N_slot_symbol*frame_cfg.N_fft;
  else
    n = N_cp_first + (frame_cfg.N_slot_symbol-1)*N_cp_other + frame_cfg.N_slot_symbol*frame_cfg.N_fft;
  end
end