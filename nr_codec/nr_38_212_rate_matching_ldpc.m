%g = nr_38_212_rate_matching_ldpc(d, base_graph, N_layers, Q_m, rv_id, ctbs)
%
% Performs rate matching and code block concatenaion of 5G NR SCH according 
% to 3GPP 38.212 sec. 5.2.4 and 5.5.
%
% Arguments:
%  d          - matrix of encoded codeblocks (each row as a codeblock)
%               the size is [num_codeblocks,num_enc_bits_per_codeblock]
%  base_graph - LDPC base graph (1 or 2) 
%  N_layers   - number of layers
%  Q_m        - modulation order
%               1 - BPSK
%               2 - QPSK
%               4 - 16QAM
%               6 - 64QAM
%               8 - 256QAM
%  rv_id      - redundancy version index (0, 1, 2 or 3)
%  ctbs       - transport block size after encoding
%
% Returns:
%  g          - vector of concatenated bits

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function g = nr_38_212_rate_matching_ldpc(d, base_graph, N_layers, Q_m, rv_id, ctbs)
  C = size(d,1);
  N = size(d,2);
 
  Cp = C;

  bits = struct([]);

  % FIXME: simplified N_cb calculation assuming I_LBRM = 0
  N_cb = N;
  G = ctbs;

  for r = 0 : C-1
    if r <= Cp - mod(G / (N_layers * Q_m), Cp)
      bits(r+1).E = N_layers * Q_m * floor(G / (N_layers * Q_m * Cp));
    else
      bits(r+1).E = N_layers * Q_m * ceil(G / (N_layers * Q_m * Cp));
    end
  end

  if base_graph == 1
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

  try
    for r = 0 : C-1
      bits(r+1).f = nr_38_212_circbuff_interleave_mex(d(r+1,:), bits(r+1).E, Q_m, k_0);
    end
  catch
    persistent flag
    if isempty(flag)
      disp('nr_38_211_rate_matching_ldpc: compile mex file to reduce execution time');
      flag = 0;
    end

    for r = 0 : C-1
      bits(r+1).e = zeros(1, bits(r+1).E);
      k = 0;
      j = 0;
      while k < bits(r+1).E
        if d(r+1,1+mod(k_0 + j, N_cb)) ~= -1
          bits(r+1).e(k+1) = d(r+1,1+mod(k_0 + j, N_cb));
          k = k + 1;
        end
        j = j + 1;
      end

      bits(r+1).f = zeros(1, bits(r+1).E);
      % interleaving
      for j = 0 : bits(r+1).E/Q_m - 1
        for i = 0 : Q_m - 1
          bits(r+1).f(1+i+j*Q_m) = bits(r+1).e(1+i*bits(r+1).E/Q_m+j);
        end
      end
    end
  end

  % codeblock concatenation
  g = zeros(1,G);
  k = 1;
  for r = 0 : C-1
    g(k:k+bits(r+1).E-1) = bits(r+1).f;
    k = k + bits(r+1).E;
  end
end