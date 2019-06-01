%[N_cp_1st, N_cp_other] = nr_cyclic_prefix_len(frame_cfg, slot_num)
%
% Returns a cyclic prefix lengths in samples for a given slot in frame.
% Two output arguments are valid - the first is a CP length of the 
% first symbol in slot (long CP), whereas the second one is applied
% to any other symbol in slot (short CP).
% Based on 3GPP 38.211 sec. 5.3.1.
%
% Arguments:
%  frame_cfg  - OFDM framing constants structure with the elements:
%               N_fft - FFT size
%               N_subframe_slot - number of slots in a subframe
%               u - OFDM numerology (as per 3GPP 38.211 sec. 4.3.2)
%  slot_num   - number of slot in frame
%
% Returns:
%  N_cp_1st   - long CP length in samples
%  N_cp_other - short CP length in samples

% Copyright 2017-2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [N_cp_1st, N_cp_other] = nr_cyclic_prefix_len(frame_cfg, slot_num)
  slot_in_sf = bitand(slot_num, frame_cfg.N_subframe_slot-1);

  cp_scale = frame_cfg.N_fft / (2048/2^frame_cfg.u);
  cp_short = cp_scale*144/2^frame_cfg.u;

  if ismember(slot_in_sf, [0, 2^(frame_cfg.u-1)])
    N_cp_1st = cp_scale*(144/2^frame_cfg.u + 16);
  else
    N_cp_1st = cp_short;
  end
  N_cp_other = cp_short;
end