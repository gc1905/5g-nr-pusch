%d = nr_38_211_sch_dmrs_per_prb(UL_DMRS_config_type)
%
% Returns a number of RE allocated for DMRS per PRB, depending
% on UL_DMRS_config_type parameter.
%
% Arguments:
%  UL_DMRS_config_type - higher layer parameter
%
% Returns:
%  d                   - number of DMRS RE per PRB

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function d = nr_38_211_sch_dmrs_per_prb(UL_DMRS_config_type)
  if UL_DMRS_config_type == 1
    d = 6;
  elseif UL_DMRS_config_type == 2
    d = 4;
  else
    error('UL_DMRS_config_type=%d is not supported', UL_DMRS_config_type);
  end
end