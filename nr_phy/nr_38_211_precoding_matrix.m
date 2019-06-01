%W = nr_38_211_precoding_matrix(tpmi, N_layer, N_ap)
%
% Retruns precoding matrix W as defined in 3GPP 38.211 sec. 6.3.1.5.
%
% Arguments:
%  tpmi      - TPMI index from 3GPP 38.211 sec. 6.3.1.5.
%  N_layer   - number of layers
%  N_ap      - number of antenna ports
%
% Returns:
%  W         - precoding matrix

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function W = nr_38_211_precoding_matrix(tpmi, N_layer, N_ap)
  % FIXME: only 6.3.1.5-1 and 4 are implemented

  if N_layer == 1 && N_ap == 1
    W = 1;
  elseif N_layer == 1 && N_ap == 2
    switch tpmi
      case 0
        W = [1; 0];
      case 1 
        W = [0; 1];
      case 2
        W = 1/sqrt(2) * [1; 1];
      case 3
        W = 1/sqrt(2) * [1; -1];
      case 4
        W = 1/sqrt(2) * [1; 1i];
      case 5
        W = 1/sqrt(2) * [1; -1i];
      otherwise
        error('no such TPMI configuration');
    end
  elseif N_layer == 2 && N_ap == 2
    switch tpmi
      case 0
        W = [1 0; 0 1];
      case 1
        W = 1/sqrt(2) * [1 1; 1 -1];
      case 2
        W = 1/sqrt(2) * [1 1; 1i -1i];
      otherwise
        error('no such TPMI configuration');
    end 
  end
end
