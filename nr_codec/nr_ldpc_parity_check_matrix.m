%H = nr_ldpc_parity_check_matrix(base_graph, Z_c)
%
% Generates 5G NR LDPC parity check matrix as defined in
% 3GPP 38.212 5.3.2.
%
% Arguments:
%  base_graph - LDPC base graph (1 or 2) 
%  Z_c        - lifting size
%
% Returns:
%  H          - parity check matrix (sparse)

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function H = nr_ldpc_parity_check_matrix(base_graph, Z_c)
  % find the set index i_LS in Table 5.3.2-1 which contains Z_c.
  for i_LS_i = 0 : 7
    Z = nr_ldpc_lifting_size_tbl_5_3_2_1(i_LS_i);
    for z = Z
      if z == Z_c
        i_LS = i_LS_i;
        break;
      end 
    end
  end

  [i, j, V_i_j] = nr_ldpc_base_graph_tbl_5_3_2(base_graph, i_LS);

  if base_graph == 1
    rows_H = 46 * Z_c;
    cols_H = 68 * Z_c;
  else
    rows_H = 42 * Z_c;
    cols_H = 52 * Z_c;
  end

  H = sparse(rows_H, cols_H);

  for it = 0 : max(i)
    idx = find(i == it);
    for jt = idx
      row_idx = it*Z_c+1:(it+1)*Z_c;
      col_idx = j(jt)*Z_c+1:(j(jt)+1)*Z_c;
      H(row_idx,col_idx) = circshift(eye(Z_c), [0 (-mod(V_i_j(jt),Z_c))]);
    end
  end
end