%r = nr_38_211_sch_dmrs_seq(n, slot_num, symbol_num, N_ID, n_SCID=0)
%
% Generates DMRS sequence for PDSCH/PUSCH channels as specified
% in 3GPP 38.211 sec. 6.4.1.1.1 and 7.4.1.1.1.
%
% Arguments:
%  n          - vector of sequence indices to be generated
%  slot_num   - slot number within a frame
%  symbol_num - symbol number within a slot
%  N_ID       - scrambling identity
%  n_SCID     - scrambling identity
%
% Returns:
%  r          - vector of sequence modulation symbols

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function r = nr_38_211_sch_dmrs_seq(n, slot_num, symbol_num, N_ID, n_SCID)
  if nargin < 5; n_SCID = 0; end

  c_init = mod(2^17*(14*slot_num+symbol_num+1)*(2*N_ID+1)+2*N_ID+n_SCID, 2^31);
  c = gold31seq(c_init, 2 * (max(n) + 1));

  r = ((1 - 2*c(1+2*n)) + 1i * (1 - 2*c(2+2*n))) / sqrt(2);
end