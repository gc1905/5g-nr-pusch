%c = nr_38_212_code_block_segmentation_ldpc(b, base_graph)
%
% Performs code block segmentation of 5G NR SCH according to 3GPP 38.212 
% sec. 5.2.2.
%
% Arguments:
%  b          - binary vector of information bits
%  base_graph - LDPC base graph (1 or 2) 
%
% Returns:
%  c          - segmented codeblocks (each row as a codeblock)
%               the size is [num_codeblocks,num_bits_per_codeblock]

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function c = nr_38_212_code_block_segmentation_ldpc(b, base_graph)
  if base_graph == 1
    K_cb = 8448; 
  elseif base_graph == 2
    K_cb = 3840;
  else
    error('base_graph permitted values are 1 or 2');
  end

  B = length(b);

  if B < K_cb
    L = 0;
    C = 1;
    Bp = B;
  else
    L = 24;
    C = ceil(B / (K_cb - L));
    Bp = B + C * L;
  end

  if base_graph == 1
    K_b = 22;
  else
    if B > 640
      K_b = 10;
    elseif B > 560
      K_b = 9;
    elseif B > 192
      K_b = 8;
    else
      K_b = 6;
    end
  end

  Z_c = 1000;
  for i_LS = 0 : 7
    Z = nr_ldpc_lifting_size_tbl_5_3_2_1(i_LS);
    for z = Z
      if z < Z_c && C * K_b * z >= Bp
        Z_c = z;
      end
    end
  end

  if base_graph == 1
    K = 22 * Z_c;
  else
    K = 10 * Z_c;
  end

  Kp = Bp / C;

  c = ones(C, K) * -1; % null filler bits

  s = 1;
  for r = 0 : C-1
    b_cur = b(s:s+Kp-L-1);
    s = s + Kp-L;

    c(r+1,1:Kp-L) = b_cur;

    if C > 1
      b_cur_crc = b_cur;
      b_cur_crc(b_cur_crc == -1) = 0;
      c(r+1,Kp-L+1:Kp) = nr_38_212_crc_calc(b_cur_crc, '24B');
    end
  end
end