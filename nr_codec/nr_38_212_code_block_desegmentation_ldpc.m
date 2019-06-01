%[b, cb_crc_ok] = nr_38_212_code_block_desegmentation_ldpc(c, base_graph, tbs)
%
% Performs code block de-segmentation of 5G NR SCH according to 3GPP 38.212 
% sec. 5.2.2.
%
% Arguments:
%  c          - segmented codeblocks (each row as a codeblock)
%               the size is [num_codeblocks,num_bits_per_codeblock]
%  base_graph - LDPC base graph (1 or 2)
%  tbs        - transport block size
%
% Returns:
%  b          - binary vector of information bits
%  cb_crc_ok  - binary vector. Zero on any position indicates CRC check
%               failure for corresponding codeblock.

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [b, cb_crc_ok] = nr_38_212_code_block_desegmentation_ldpc(c, base_graph, tbs)
  if base_graph == 1
    K_cb = 8448;
  elseif base_graph == 2
    K_cb = 3840;
  else
    error('base_graph permitted values are 1 or 2'); 
  end

  B = tbs;

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

  b = zeros(1, B);

  cb_crc_ok = zeros(1,C);

  s = 1;
  for r = 0 : C-1
    b_cur = c(r+1,1:Kp-L);
    b(s:s+Kp-L-1) = b_cur;
    s = s + Kp-L;

    if C > 1
      crc_ext = c(r+1,Kp-L+1:Kp);
      b_cur_crc = b_cur;
      b_cur_crc(b_cur_crc == -1) = 0;
      crc_cur = nr_38_212_crc_calc(b_cur_crc, '24B');
      cb_crc_ok(r+1) = all(crc_ext == crc_cur);
      % if ~cb_crc_ok(r+1)
      %   display('CB CRC eror!');
      % end
    else
      cb_crc_ok = 1;
    end
  end
end