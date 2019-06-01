%[sh, cw_valid, iter] = ldpc_decode(LLRin, H, max_iter=30)
%
% Determines transport block size (TBS) based on precedure given by 
% 3GPP 38.214 sec. 5.1.3.2.
%
% Arguments:
%  N_sh_symb  - number of symbols allocated within the slot
%  N_PRB_DMRS - number of REs reserved for DM-RS per PRB 
%  n_PRB      - number of scheduled PRB
%  I_mcs      - MCS index
%  N_layers   - number of layers
%  mcs_tbl    - index of MCS table (1 - 64-QAM, 2 - 256-QAM)
%
% Returns:
%  tbs        - determined transport block size in bits
%  coded_tbs  - number of bits after encoding

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [tbs, coded_tbs] = nr_transport_block_size(N_sh_symb, N_PRB_DMRS, n_PRB, I_mcs, N_layers, mcs_tbl)
  if nargin < 6
    mcs_tbl = 1;
  end

  % overhead configured by higher layer parameter Xoh-PDSCH - assume to be disabled
  N_PRB_oh = 0;

  % determine the number of REs (NRE) within the slot. 
  Np_RE = 12 * N_sh_symb - N_PRB_DMRS - N_PRB_oh;

  % determine the quantized number of REs allocated for PDSCH within a PRB
  if Np_RE <= 9
    Ndp_RE = 6;
  elseif Np_RE <= 15
    Ndp_RE = 12;
  elseif Np_RE <= 30
    Ndp_RE = 18;
  elseif Np_RE <= 57
    Ndp_RE = 42;
  elseif Np_RE <= 90
    Ndp_RE = 72;
  elseif Np_RE <= 126
    Ndp_RE = 108;
  elseif Np_RE <= 150
    Ndp_RE = 144;
  else
    Ndp_RE = 156;
  end

  % determine the total number of REs allocated for PDSCH 
  N_RE = Ndp_RE * n_PRB;

  % Intermediate number of information bits
  [Q_m, R] = nr_resolve_mcs(I_mcs, mcs_tbl);
  N_info = N_RE * R * Q_m * N_layers;

  coded_tbs = N_sh_symb * n_PRB * Q_m * N_layers * (12 - N_PRB_DMRS - N_PRB_oh);

  if (N_info <= 3824)
    % quantized intermediate number of information bits
    n = max(3, floor(log2(N_info)) - 6);
    Np_info = max(24, 2^n * floor(N_info / 2^n));

    % use Table 5.1.3.2-2 find the closest TBS that is not less than Np_info
    tbl_5_1_3_2_2 = [24, 32, 40, 48, 56, 64, 72, 80, 88, 96, 104, 112, 120, 128, 136, 144, 152, 160, 168, 176, 184, 192, 208, 224, 240, 256, 272, 288, 304, 320, 336, 352, 368, 384, 408, 432, 456, 480, 504, 528, 552, 576, 608, 640, 672, 704, 736, 768, 808, 848, 888, 928, 984, 1032, 1064, 1128, 1160, 1192, 1224, 1256, 1288, 1320, 1352, 1416, 1480, 1544, 1608, 1672, 1736, 1800, 1864, 1928, 2024, 2088, 2152, 2216, 2280, 2408, 2472, 2536, 2600, 2664, 2728, 2792, 2856, 2976, 3104, 3240, 3368, 3496, 3624, 3752, 3824];
    for t = tbl_5_1_3_2_2
      if t >= Np_info
        tbs = t;
        break;
      end
    end
  else
    % quantized intermediate number of information bits 
    n = floor(log2(N_info - 24)) - 5;
    Np_info = 2^n * round((N_info - 24) / 2^n);

    if R <= 0.25
      C = ceil((Np_info + 24) / 3816);
    elseif Np_info > 8424
      C = ceil((Np_info + 24) / 8424);
    else
      C = 1;
    end

    tbs = 8 * C * ceil((Np_info + 24) / (8 * C)) - 24;
  end
end