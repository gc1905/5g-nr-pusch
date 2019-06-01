%[p] = ldpc_encode_nr(s, H, Z_c)
%
% Implementation of simplified Richardson's efficient LDPC encoder (see [1]).
% Assumes E = 0 and T = I, which is true for 5G NR LDPC 
% parity check matrices.
%
% [1] T. Richardson and R. Urbanke, "Efficient Encoding of Low-Density 
%     Parity-Check Codes", IEEE Trans. Inf. Theory, vol. 47, no. 2, 
%     pp. 638-656, Feb. 2001.
%
% Arguments:
%  s         - vector of information bits
%  H         - parity check matrix
%  Z_c       - lifting size of matrix H
%
% Returns:
%  p         - vector of generated parity bits

% Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function p = ldpc_encode_nr(s, H, Z_c)
  persistent C_int D_int Dinv_C 

  s = s(:);

  n = size(H,2);
  r = size(H,1);
  k = n - r;
  g = 4 * Z_c;

  A = H(g+1:end, 1:k);
  B = H(g+1:end, k+1:k+g);
  C = H(1:g, 1:k);
  D = H(1:g, k+1:k+g);

  % E = H(1:g, k+g+1:end);
  % T = H(g+1:end, k+g+1:end);
  % assert(nnz(E) == 0, 'LDPC parity matrix error: E is expected to be a zero matrix');
  % assert(all(all(T == eye(r-g))), 'LDPC parity matrix error: T is expected to be a binary identity matrix');

  if ~isequal(D_int, D) || ~isequal(C_int, C)
    C_int = C;
    D_int = D;

    Dinv = mod(round(inv(D)), 2);
    Dinv_C = mod(Dinv * C, 2);
  end

  p1 = mod(Dinv_C * s, 2);
  p2 = mod(A * s + B * p1, 2);

  p = [p1; p2];
  
  assert(any(mod(H * [s;p], 2)) == 0, 'LDPC encoder error: parity check failed');
end