%[d] = nr_38_212_channel_coding_ldpc(c, base_graph)
%
% Performs encoding of 5G NR SCH according to 3GPP 38.212 sec. 5.3.2.
%
% Arguments:
%  c          - codeblocks to be encoded (each row is a separate codeblock)
%  base_graph - LDPC base graph (1 or 2) 
%
% Returns:
%  d          - encoded codeblocks

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function d = nr_38_212_channel_coding_ldpc(c, base_graph)
  persistent H base_graph_int Z_c_int
  
  if isempty(base_graph_int) 
    base_graph_int = 0;
  end
  if isempty(Z_c_int)
    Z_c_int = 0;
  end

  C = size(c,1);
  K = size(c,2);

  if base_graph == 1
    Z_c = K / 22;
    N = 66 * Z_c;
  elseif base_graph == 2
    Z_c = K / 10;
    N = 50 * Z_c;
  else
    error('base_graph permitted values are 1 or 2');
  end

  if (Z_c ~= Z_c_int) || (base_graph ~= base_graph_int)
    Z_c_int = Z_c;
    base_graph_int = base_graph;
    H = nr_ldpc_parity_check_matrix(base_graph, Z_c);
  end

  % insert information bits
  d = ones(C,N) * -1;
  
  d(:,1:K-2*Z_c) = c(:,1+2*Z_c:K);

  c(c == -1) = 0;

  % generate and insert parity bits
  for r = 1:C
    p = ldpc_encode_nr(c(r,:)', H, Z_c);
    d(r,1+K-2*Z_c:N) = p;
  end
end