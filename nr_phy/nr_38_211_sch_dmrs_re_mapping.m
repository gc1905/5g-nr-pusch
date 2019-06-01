%k = nr_38_211_sch_dmrs_re_mapping(n_PRB_start, n_PRB_sched, UL_DMRS_config_type, ap)
%
% Returns a vector of RE indices over a specified antenna port on which the DMRS 
% modulation symbols are mapped.
% Based on 3GPP 38.211 sec. 7.4.1.1.2.
%
% Arguments:
%  n_PRB_start   - numner of the first scheduled PRB
%  n_PRB_sched   - numner of scheduled PRBs
%  UL_DMRS_config_type - higher layer parameter
%  ap            - PDSCH/PUSCH antenna port number (values 0-7 for DMRS config 1, 
%                  0-11 for config 2)
%
% Returns:
%  k             - vector of RE indices (zero-based)

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function k = nr_38_211_sch_dmrs_re_mapping(n_PRB_start, n_PRB_sched, UL_DMRS_config_type, ap)
  if UL_DMRS_config_type == 1
    dmrs_re_per_prb = 6;
    k = zeros(n_PRB_sched*dmrs_re_per_prb,1);
    for idx = 0 : 3 * n_PRB_sched - 1
      k(2*idx+1) = idx * 4;
      k(2*idx+2) = idx * 4 + 2;
    end
  elseif UL_DMRS_config_type == 2
    dmrs_re_per_prb = 4;
    k = zeros(n_PRB_sched*dmrs_re_per_prb,1);
    for idx = 0 : 2 * n_PRB_sched - 1
      k(2*idx+1) = idx * 6;
      k(2*idx+2) = idx * 6 + 1;
    end
  end

  if UL_DMRS_config_type == 1
    if ismember(mod(ap, 4), [2,3])
      delta = 1;
    else
      delta = 0;
    end
  elseif UL_DMRS_config_type == 2
    if ismember(mod(ap, 6), [4,5])
      delta = 4;
    elseif ismember(mod(ap, 6), [2,3])
      delta = 2;
    else
      delta = 0;
    end
  end

  k = k + delta;
end