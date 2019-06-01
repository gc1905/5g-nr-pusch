%[M] = movavg(A, n)
%[M] = movavg(A, n dim = 1)
%
% Computes moving average over vector or matrix A.
% In case of matrix, computes column or row wise
% depending on parameter dim.
%
% Arguments:
%  A    - input matrix or vector
%  n    - length of averaging filter
%  dim  - dimension of A to do averaging
%
% Returns:
%  w    - matrix of twiddle factors

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [M] = movavg(A, n, dim)
  if nargin < 3
  	dim = 1;
  elseif ~ismember(dim, [1,2])
    error('dim can be only 1 or 2');
  end

  M = zeros(size(A));

  if isvector(A)
    for idx = 1 : length(A)
      x = A(max(idx-n,1):min(idx+n,length(A)));
      M(idx) = mean(x);
    end
  else
    if dim == 1
      for row = 1 : size(A, 2)
        for col = 1 : size(A, 1)
          M(col,row) = mean(A(max(col-n,1):min(col+n,size(A,1)), row));
        end
      end
    else
      for row = 1 : size(A, 2)
        for col = 1 : size(A, 1)
          M(col,row) = mean(A(col, max(row-n,1):min(row+n,size(A,2))));
        end
      end
    end
  end
end