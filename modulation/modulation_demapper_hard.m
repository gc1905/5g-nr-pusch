%[x] = modulation_demapper_hard(iq, ord)
%
% Demodulates complex data vector using specified modulation 
% type.
% Use hard decision demapper.
% Implemented according to [1].
%
% [1] 3GPP TS 36.211 version 12.4.0 Release 12
%
% Arguments:
%  iq    - matrix of modulated complex iq symbols
%  ord   - modulation order
%          1 - BPSK
%          2 - QPSK
%          4 - 16QAM
%          6 - 64QAM
%
% Returns:
%  x     - binary vector

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [x] = modulation_demapper_hard(iq, ord)
  x = zeros(numel(iq)*ord, 1);

  if ord == 1
    for idx = 1 : numel(iq)
      ang = angle(iq(idx));
      if (ang > -pi/4) && (ang < 3/4 * pi)
        x(idx) = 0;
      else
        x(idx) = 1;
      end
    end
  elseif ord == 2
    for idx = 1 : numel(iq)
      ang = angle(iq(idx));
      if (ang >= 0) && (ang < pi / 2)
        x(2*idx-1:2*idx) = [0; 0];
      elseif (ang >= -pi/2) && (ang < 0)
        x(2*idx-1:2*idx) = [0; 1];
      elseif (ang >= pi/2) && (ang < pi)
        x(2*idx-1:2*idx) = [1; 0];
      else
        x(2*idx-1:2*idx) = [1; 1];
      end
    end
  elseif ord == 4
    for idx = 1 : numel(iq)
      ang = angle(iq(idx));
      x(4*idx-3:4*idx) = [(real(iq(idx)) < 0); 
                          (imag(iq(idx)) < 0); 
                          (abs(real(iq(idx))) > 2/sqrt(10)); 
                          (abs(imag(iq(idx))) > 2/sqrt(10))];
    end
  elseif ord == 6
    error('64QAM demodulation not supported');  
  else
    error('modulation order not supported');  
  end
end