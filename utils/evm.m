%v = evm(s, r)
%
% Calculates EVM of the signal according to 3GPP specification as defined 
% in [1].
%
% [1] 3GPP TS 36.101 version 12.7.0 Release 12 F.2 Basic Error 
%     Vector Magnitude measurement
%
% Arguments:
%  x     - signal under test
%  r     - ideal reference signal
%
% Returns:
%  v     - Error Vector Magnitude of the signal

% Copyright 2017 Grzegorz Cisek (grzegorzcisek@gmail.com)

function v = evm(x, r)
  assert(isequal(size(x),size(r)), 'x and r must be equal size');

  v1 = sum(abs(x(:) - r(:)).^2);
  v2 = sum(abs(r(:)).^2);

  v = sqrt(v1 / v2);
end