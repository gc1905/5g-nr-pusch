%[p] = p = ldpc_encode(s, H)
%
% Sub-optimal dense LDPC encoder.
% Extremely slow, but works with all parity check matrices 
% as long as H_p is non-singular.
%
% Arguments:
%  s         - vector of information bits
%  H         - parity check matrix
%
% Returns:
%  p         - vector of generated parity bits

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function p = ldpc_encode(s, H)
  s = s(:);
  
  N = size(H,2);
  R = size(H,1);
  K = N - R;

  H_s = H(:,1:K);
  H_p = H(:,K+1:end); 

  p = mod(inv(H_p) * H_s * s, 2);
  
  assert(any(mod(H * [s;p], 2)) == 0, 'encoder parity check failed');
end