%[a, tb_crc_ok, cb_crc_ok] = nr_sch_decode(g, I_mcs, N_layers, rv_id, tbs, mcs_tbl)
%
% Decodes 5G NR PUSCH/PDSCH channels using LDPC codes according to
% 3GPP 38.212 sec. 6.2 and 7.2.
%
% Arguments:
%  g          - encoded transport block vector (LLR values)
%  I_mcs      - MCS index
%  N_layers   - number of layers
%  rv_id      - redundancy version index (0, 1, 2 or 3)
%  tbs        - transport block size (uncoded)
%  mcs_tbl    - index of MCS table (1 - 64-QAM, 2 - 256-QAM)
%
% Returns:
%  a          - binary transport block vector
%  tb_crc_ok  - set to 0 indicates transpor block CRC check failure
%  cb_crc_ok  - binary vector. Zero on any position indicates CRC check
%               failure for corresponding codeblock.

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [a, tb_crc_ok, cb_crc_ok] = nr_sch_decode(g, I_mcs, N_layers, rv_id, tbs, mcs_tbl)
  if nargin < 6
    mcs_tbl = 1;
  end

  A = tbs;

  % Transport Block crc size
  if A > 3824
    L = 24; 
  else
    L = 16;
  end

  % resolve MCS and select LDPC graph
  [Q_m, R] = nr_resolve_mcs(I_mcs, mcs_tbl);
  if (A <= 292) || (A <= 3824 && R <= 0.67) || (R <= 0.25)
    base_graph = 2;
  else
    base_graph = 1;
  end

  d = nr_38_212_rate_unmatching_ldpc(g, base_graph, N_layers, Q_m, rv_id, A+L);
  c = nr_38_212_channel_decoding_ldpc(d, base_graph);
  [b, cb_crc_ok] = nr_38_212_code_block_desegmentation_ldpc(c, base_graph, A+L);

  % Transport Block crc extraction and check
  p_ext = b(end-L+1:end);
  a = b(1:end-L);
  a = a(:);

  if A > 3824
    p_calc = nr_38_212_crc_calc(a, '24A');
  else
    p_calc = nr_38_212_crc_calc(a, 16);
  end

  tb_crc_ok = all(p_calc == p_ext);
  if numel(cb_crc_ok) == 1
    cb_crc_ok = tb_crc_ok;
  end
  % if ~tb_crc_ok
  %   display('TB CRC eror!');
  % end
end