%[sh, cw_valid, iter] = ldpc_decode(LLRin, H, max_iter=30)
%
% Soft-decoder of LDPC codes using Sum-Product Algorithm.
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

function [sh, cw_valid, iter] = ldpc_decode_spa(LLRin, H, max_iter)
  if nargin < 3; max_iter = 50; end

  persistent H_int sumX1 sumX2 i_idx j_idx

  [ncheck, nvar] = size(H);

  if isempty(H_int) || ~isequal(H, H_int)
    H_int = H;
    
    sumX1 = full(sum(H,1)');
    sumX2 = full(sum(H,2));

    cmax = max(sumX1);
    vmax = max(sumX2);

    C = zeros(cmax,nvar);
    V = zeros(ncheck,vmax);
    i_idx = zeros(nvar,cmax);
    j_idx = zeros(ncheck,vmax);

    for i = 1 : nvar
      c = find(H(:,i) == 1);
      C(1:numel(c),i) = c;
    end

    for j = 1 : ncheck
      v = find(H(j,:) == 1);
      V(j,1:numel(v)) = v;
    end

    for j = 1 : ncheck
      for ip = 1 : sumX2(j)
        vip = V(j,ip);
        k = 0;
        while C(k+1,vip) ~= j
          k = k + 1;
        end
        j_idx(j,ip) = vip + k * nvar;
      end
    end

    for i = 1 : nvar
      for jp = 1 : sumX1(i)
        cjp = C(jp,i);
        k = 0;
        while V(cjp,k+1) ~= i
          k = k + 1;
        end
        i_idx(i,jp) = cjp + k * ncheck;
      end
    end
  end
  
  try
    [sh, cw_valid, iter] = ldpc_decode_spa_mex(H, LLRin, sumX1, sumX2, i_idx-1, j_idx-1, max_iter);
    return;
  catch
    persistent flag
    if isempty(flag)
      disp('ldpc_decode_spa: compile mex file to reduce execution time');
      flag = 0;
    end
  end

  if check_syndrome(H, LLRin)
    iter = 0;
    cw_valid = true;
    sh = llr2hardbit(LLRin);
    return;
  end

  cw_valid = false;

  LLRout = zeros(size(LLRin));

  mcv = zeros(ncheck,max(sumX2));
  mvc = repmat(LLRin(:), 1, max(sumX1));

  for iter = 1 : max_iter
    % check to variable nodes
    for j = 1 : ncheck
      n = sumX2(j);
      mcv(j,1:n) = boxplus_sums(mvc(j_idx(j,1:n)));
    end

    % variable to check nodes
    for i = 1 : nvar
      j = 1 : sumX1(i);
      LLRout(i) = LLRin(i) + sum( mcv(i_idx(i,j)) );
      mvc(i,j) = LLRout(i) - mcv(i_idx(i,j));
    end

    if check_syndrome(H, LLRout)
      cw_valid = true;
      break;
    end
  end

  sh = llr2hardbit(LLRout);
end

% return a non-zero value if no errors detected
function cw_valid = check_syndrome(H, r)
  s = H * llr2hardbit(r(:));
  cw_valid = all(mod(s,2) == 0);
end

function mcv = boxplus_sums(mvc)
  n = numel(mvc);

  ml  = zeros(n,1);
  mr  = zeros(n,1);
  mcv = zeros(n,1);

  % partial sums
  ml(1) = mvc(1);
  mr(1) = mvc(n);
  for i = 1 : n-2
    ml(1+i) = boxplus_approx( ml(i), mvc(1+i) );
    mr(1+i) = boxplus_approx( mr(i), mvc(n-i) );
  end

  % merge
  mcv(1) = mr(n-1);
  mcv(n) = ml(n-1);
  mcv(2:n-1) = boxplus_approx( ml(1:n-2), mr(n-2:-1:1) );
end