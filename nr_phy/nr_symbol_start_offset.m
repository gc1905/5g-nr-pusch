%n = nr_symbol_start_offset(frame_cfg, slot_num, symbol_num)
%
% Calculates an offset from the start of a slot to the first sample
% of FFT window of a specified symbol (i.e. the first sample after the
% cyclic prefix).
%
% Arguments:
%  frame_cfg  - OFDM framing constants structure with the elements:
%               N_fft - FFT size
%               N_slot_symbol   - number of symbols in a slot
%               N_subframe_slot - number of slots in a subframe
%               u - OFDM numerology (as per 3GPP 38.211 sec. 4.3.2)
%  slot_num   - number of slot in frame
%  symbol_num - number of symbol in slot
%
% Returns:
%  n          - offset in samples

% Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function n = nr_symbol_start_offset(frame_cfg, slot_num, symbol_num)
  [N_cp_first, N_cp_other] = nr_cyclic_prefix_len(frame_cfg, slot_num);

  if symbol_num == 0
    n = N_cp_first;
  else
    n = N_cp_first + symbol_num * (N_cp_other + frame_cfg.N_fft);
  end

  if symbol_num > 7 && frame_cfg.u == 0
    n = n + N_cp_first - N_cp_other;
  end
end