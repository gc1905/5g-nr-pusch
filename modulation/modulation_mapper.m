%[iq] = modulation_mapper(x, Q_m)
%
% Modulates binary vector x using specified Gray-coded rectangular
% modulation type.
% Implemented according to [1].
%
% [1] 3GPP TS 36.211 version 12.4.0 Release 12
%
% Arguments:
%  x     - matrix of binary numbers
%  Q_m   - modulation order
%          1 - BPSK
%          2 - QPSK
%          4 - 16QAM
%          6 - 64QAM
%
% Returns:
%  iq    - matrix of modulated complex iq symbols

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [iq] = modulation_mapper(x, Q_m)
  assert(all(ismember(x(:),[1,0])), 'x can contain only 0 or 1');
  assert(mod(length(x), Q_m) == 0, 'size do not match modulation order');

  mod_tbl = modulation_alphabet(Q_m);

  try
    iq = modulation_mapper_mex(x, Q_m, mod_tbl);
    return;
  catch
    persistent flag
    if isempty(flag)
      disp('modulation_mapper: compile mex file to reduce execution time');
      flag = 0;
    end
  end
  
  iq = zeros(numel(x)/Q_m,1);

  for idx = 1 : numel(iq)
    tidx = 0;
    for idxx = 1 : Q_m
      tidx = tidx + x((idx-1) * Q_m + idxx) * 2 ^ (Q_m - idxx);
    end
    iq(idx) = mod_tbl(tidx+1);
  end
end