%[c] = nr_38_212_channel_decoding_ldpc(d, base_graph)
%
% Performs decoding of 5G NR SCH according to 3GPP 38.212 sec. 5.3.2.
% When avaliable, uses LDPC decoder from Matlab communications package.
%
% Arguments:
%  d          - received LLR values (each row as a codeblock)
%  base_graph - LDPC base graph (1 or 2) 
%
% Returns:
%  c          - decoded codeblocks (each row is a separate codeblock)

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function c = nr_38_212_channel_decoding_ldpc(d, base_graph)
  persistent H hLDPCDec base_graph_int Z_c_int

  if isempty(base_graph_int) 
    base_graph_int = 0;
  end
  if isempty(Z_c_int)
    Z_c_int = 0;
  end

  C = size(d,1);
  N = size(d,2);

  if base_graph == 1
    Z_c = N / 66;
    K = Z_c * 22;
  elseif base_graph == 2
    Z_c = N / 50;
    K = Z_c * 10;
  else
    error('base_graph permitted values are 1 or 2');
  end

  if (Z_c ~= Z_c_int) || (base_graph ~= base_graph_int)
    Z_c_int = Z_c;
    base_graph_int = base_graph;

    H = nr_ldpc_parity_check_matrix(base_graph, Z_c);

    % Matlab communications toolbox LDPC decoder
    % try
    %   if ~isempty(hLDPCDec); release(hLDPCDec); end
    %   hLDPCDec = comm.LDPCDecoder('ParityCheckMatrix', H);
    %   hLDPCDec.DecisionMethod = 'Hard decision';
    % end
  end
  
  c = zeros(C,K);

  for r = 1:C
    w = [zeros(1, 2*Z_c), d(r,:)];
    %try
    %  c(r,:) = step(hLDPCDec, w');
    %catch
      wd = ldpc_decode_spa(w, H);
      c(r,:) = wd(1:K);
    %end
  end
end