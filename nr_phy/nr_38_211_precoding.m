%z = nr_38_211_precoding(x, N_ap, tpmi, tp_en)
%
% Performs transform precoding according to 3GPP 38.211 sec. 6.3.1.4
% and precoding as in 3GPP 38.211 sec. 6.3.1.5.
%
% Arguments:
%  x         - matrix of layer-mapped modulation symbols of size 
%              [N_samples/N_layers,N_layers]
%  N_ap      - number of antenna ports
%  tpmi      - TPMI index from 3GPP 38.211 sec. 6.3.1.5.
%  tp_en     - if set to non-zero, transform precoding is enabled
%
% Returns:
%  z         - matrix of precoded data

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function z = nr_38_211_precoding(x, N_ap, tpmi, tp_en)

  % FIXME!
  assert(tp_en == 0, 'transform precoding is not supported yet');

  N_layer = size(x, 2);

  W = nr_38_211_precoding_matrix(tpmi, N_layer, N_ap);

  z = (W * x.').';
end