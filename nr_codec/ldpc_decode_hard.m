%[sh, cw_valid, iter] = ldpc_decode_hard(LLRin, H, max_iter)
%
% Hard decoding of LDPC codes using Bit Flipping algorithm.
% Input LLR vector is converted to hardbit.
%
% Arguments:
%  LLRin     - vector of LLR
%  H         - parity check matrix
%  max_iter  - maximum nuber of iterations.
%
% Returns:
%  sh        - binary codeword vector after decoding
%  cw_valid  - a non-zero value indicates that sh is a valid 
%              codeword
%  iter      - number of iterations made

% Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [sh, ok, iter] = ldpc_decode_hard(r, H, max_iter)
  if nargin < 3; max_iter = 50; end

  [R, N] = size(H);
  K = N - R;

  % hard quantization of LLRs
  sd = zeros(size(r));
  sd(r > 0) = 1;
  sd(r < 0) = -1;

  syndrome = mod(H * llr2hardbit(sd), 2);

  ok = 0;
  iter = 0;
  
  p = zeros(N, 1);

  while (iter < max_iter) && (sum(syndrome) ~= 0)
    % iterate through variable nodes and calculated probabilities of error
    for n = 1 : N
      num_cNodes = sum(H(:,n));
      votesFlip  = sum(syndrome(H(:,n)~=0) == 1);
      p(n) = votesFlip / num_cNodes;
    end
    
    % select variable node with the highest probability and flip corresponding bit
    [~,n_max] = max(p);
    sd(n_max) = -sd(n_max);

    % update syndrome
    syndrome = mod(H * llr2hardbit(sd), 2);
    iter = iter + 1;
  end

  ok = (sum(syndrome) == 0);
  sh = llr2hardbit(sd(1:K));
end