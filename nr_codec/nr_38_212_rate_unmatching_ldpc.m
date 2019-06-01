%d = nr_38_212_rate_unmatching_ldpc(g, base_graph, N_layers, Q_m, rv_id, tbs)
%
% Performs rate un-matching and code block de-concatenaion of 5G NR SCH according 
% to 3GPP 38.212 sec. 5.2.4 and 5.5.
%
% Arguments:
%  g          - vector of concatenated LLR
%  base_graph - LDPC base graph (1 or 2) 
%  N_layers   - number of layers
%  Q_m        - modulation order
%               1 - BPSK
%               2 - QPSK
%               4 - 16QAM
%               6 - 64QAM
%               8 - 256QAM
% rv_id       - redundancy version index (0, 1, 2 or 3)
% tbs        - transport block size (uncoded)
%
% Returns:
%  d          - matrix of codeblock LLR (each row as a codeblock)
%               the size is [num_codeblocks,num_enc_bits_per_codeblock]

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function d = nr_38_212_rate_unmatching_ldpc(g, base_graph, N_layers, Q_m, rv_id, tbs)
  bits = struct([]);

  % recalculate parameters B, C, E, G, k_0
  B = tbs;
  G = length(g);
 
  if base_graph == 1
    K_cb = 8448;
    K_b = 22;
    switch rv_id
      case 0
        k_0 = 0;
      case 1
        k_0 = floor(17 * N_cb / (66 * Z_c)) * Z_c;
      case 2
        k_0 = floor(33 * N_cb / (66 * Z_c)) * Z_c;
      case 3
        k_0 = floor(56 * N_cb / (66 * Z_c)) * Z_c;
      otherwise
        error('rv_id permitted values are in integer range 0:3');
    end
  elseif base_graph == 2
    K_cb = 3840;
    if B > 640
      K_b = 10;
    elseif B > 560
      K_b = 9;
    elseif B > 192
      K_b = 8;
    else
      K_b = 6;
    end
    switch rv_id
      case 0
        k_0 = 0;
      case 1
        k_0 = floor(13 * N_cb / (50 * Z_c)) * Z_c;
      case 2
        k_0 = floor(25 * N_cb / (50 * Z_c)) * Z_c;
      case 3
        k_0 = floor(43 * N_cb / (50 * Z_c)) * Z_c;
      otherwise
        error('rv_id permitted values are in integer range 0:3');
    end
  else
    error('base_graph permitted values are 1 or 2');
  end

  if B < K_cb
    C = 1;
    L = 0;
    Bp = B;
  else
    L = 24;
    C = ceil(B / (K_cb - L));
    Bp = B + C * L;
  end

  Z_c = 1000;
  for i_LS = 0 : 7
    Z = nr_ldpc_lifting_size_tbl_5_3_2_1(i_LS);
    for z = Z
      if z < Z_c && C * K_b * z >= B + C * L
        Z_c = z;
      end
    end
  end

  if base_graph == 1
    N = 66 * Z_c;
    K = 22 * Z_c;
  elseif base_graph == 2
    N = 50 * Z_c;
    K = 10 * Z_c;
  end

  % FIXME: simplified N_cb calculation
  N_cb = N;
  Cp = C;
  Kp = Bp / C;
  Fp = K - Kp;

  for r = 0 : C-1
    if r <= Cp - mod(G / (N_layers * Q_m), Cp)
      bits(r+1).E = N_layers * Q_m * floor(G / (N_layers * Q_m * Cp));
    else
      bits(r+1).E = N_layers * Q_m * ceil(G / (N_layers * Q_m * Cp));
    end
  end

  % codeblock deconcatenation
  k = 1;
  for r = 0 : C-1
    bits(r+1).f = g(k:k+bits(r+1).E-1);
    k = k + bits(r+1).E;
  end

  d = zeros(C,N);

  Fbst = Kp - 2*Z_c;
  Fbsz = K - Kp;

  try
    for r = 0 : C-1
      d(r+1,:) = nr_38_212_circbuff_deinterleave_mex(bits(r+1).f, N, Q_m, k_0, Fbst, Fbsz);
    end
  catch
    persistent flag
    if isempty(flag)
      disp('nr_38_211_rate_unmatching_ldpc: compile mex file to reduce execution time');
      flag = 0;
    end

    for r = 0 : C-1
      bits(r+1).e = zeros(1, bits(r+1).E);
      % deinterleaving
      for j = 0 : bits(r+1).E / Q_m - 1
        for i = 0 : Q_m - 1
          bits(r+1).e(1+i*bits(r+1).E/Q_m+j) = bits(r+1).f(1+i+j*Q_m);
        end
      end

      % do LLR combining on circular buffer
      j = 0;
      for k = 0 : bits(r+1).E - 1
        if mod(k_0 + k, N_cb) < Fbst || mod(k_0 + k, N_cb) >= Fbst + Fbsz
          d(r+1,1+mod(k_0 + k, N_cb)) = d(r+1,1+mod(k_0 + k, N_cb)) + bits(r+1).e(1+mod(j,bits(r+1).E));
          j = j + 1;
        end
      end
    end
  end
  
end