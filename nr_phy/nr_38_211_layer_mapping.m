%x = nr_38_211_layer_mapping(d, N_layers)
%
% Performs layer mapping according to 3GPP 38.211 Table 7.3.1.3-1.
%
% Arguments:
%  d         - vector of modulation symbols
%  N_layers  - number of layers
%
% Returns:
%  x         - layer matrix of size [N_samples/N_layers,N_layers]

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function x = nr_38_211_layer_mapping(d, N_layers)
  assert(ismember(N_layers, 1:4), 'up to 4 layers are supported');
  x = reshape(d, N_layers, []).';
end