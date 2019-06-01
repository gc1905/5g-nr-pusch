%d = nr_38_211_layer_demapping(x, N_layers)
%
% Performs layer de-mapping according to 3GPP 38.211 Table 7.3.1.3-1.
%
% Arguments:
%  x         - layer matrix of size [N_samples/N_layers,N_layers]
%  N_layers  - number of layers
%
% Returns:
%  d         - vector of modulation symbols

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function d = nr_38_211_layer_demapping(x, N_layers)
  assert(ismember(N_layers, 1:4), 'up to 4 layers are supported');
  d = reshape(x.', [], 1);
end