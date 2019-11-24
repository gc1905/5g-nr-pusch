%[g] = nr_sch_encode(a, I_mcs, N_layers, rv_id, ctbs, mcs_tbl)
%
% Encodes 5G NR PUSCH/PDSCH channels using LDPC codes according to
% 3GPP 38.212 sec. 6.2 and 7.2.
%
% Arguments:
%  a          - binary transport block vector
%  I_mcs      - MCS index
%  N_layers   - number of layers
%  rv_id      - redundancy version index (0, 1, 2 or 3)
%  ctbs       - transport block size after encoding
%  mcs_tbl    - index of MCS table (1 - 64-QAM, 2 - 256-QAM)
%
% Returns:
%  g          - encoded binary transport block vector

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [g] = nr_sch_encode(a, I_mcs, N_layers, rv_id, ctbs, mcs_tbl)
  if nargin < 6
    mcs_tbl = 1;
  end

  % convert a to row vector
  a = reshape(a, 1, []);
  A = length(a); 

  % Transport Block crc attachment
  if A > 3824
    p = nr_38_212_crc_calc(a, '24A');
  else
    p = nr_38_212_crc_calc(a, 16);
  end
  b = [a, p];

  % resolve MCS and select LDPC graph
  [Q_m, R] = nr_resolve_mcs(I_mcs, mcs_tbl);
  if (A <= 292) || (A <= 3824 && R <= 0.67) || (R <= 0.25)
    base_graph = 2;
  else
    base_graph = 1;
  end
  
  c = nr_38_212_code_block_segmentation_ldpc(b, base_graph);
  d = nr_38_212_channel_coding_ldpc(c, base_graph);
  g = nr_38_212_rate_matching_ldpc(d, base_graph, N_layers, Q_m, rv_id, ctbs);

  g(g == -1) = 0;
  g = g(:);
end