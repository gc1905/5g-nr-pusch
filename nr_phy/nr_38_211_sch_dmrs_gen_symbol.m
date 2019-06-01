%a = nr_38_211_sch_dmrs_gen_symbol(n_PRB_start, n_PRB_sched, N_layer, antenna_ports, 
%                                  antenna_ports, tpmi, slot_num, symbol_num, 
%                                  UL_DMRS_config_type, tp_en, N_ID, n_SCID)
%
% Generates PUSCH/PDSCH DMRS constellation symbols for a given OFDM symbol
% in slot. Symbols for all antenna ports are generated and stored in output 
% matrix.
%
% Arguments:
%  n_PRB_start   - numner of the first scheduled PRB
%  n_PRB_sched   - numner of scheduled PRBs
%  N_layer       - number of layers
%  antenna_ports - vector of antenna port numbers (values 0-7 for DMRS config 1, 
%                  0-11 for config 2) of size [N_ap,1]
%  tpmi          - TPMI index from 3GPP 38.211 sec. 6.3.1.5.
%  slot_num      - number of slot in frame
%  symbol_num    - number of symbol in slot
%  UL_DMRS_config_type - higher layer parameter
%  tp_en         - if set to non-zero, transform precoding is enabled
%  N_ID          - scrambling identity
%  n_SCID        - scrambling identity
%
% Returns:
%  a             - matrix of size [n_PRB_sched*dmrs_re_per_prb,N_ap]

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function a = nr_38_211_sch_dmrs_gen_symbol(n_PRB_start, n_PRB_sched, N_layer, antenna_ports, tpmi, slot_num, symbol_num, UL_DMRS_config_type, tp_en, N_ID, n_SCID)
  dmrs_re_per_prb = nr_38_211_sch_dmrs_per_prb(UL_DMRS_config_type);

  n = n_PRB_start*dmrs_re_per_prb + (0:n_PRB_sched*dmrs_re_per_prb-1);
  N_ap = length(antenna_ports);

  r = nr_38_211_sch_dmrs_seq(n, slot_num, symbol_num, N_ID, n_SCID);
  rd = nr_38_211_precoding(repmat(r.', [1 N_layer]), N_ap, tpmi, tp_en);

  a = zeros(n_PRB_sched*dmrs_re_per_prb,N_ap);

  for ap = 1 : N_ap
    w_f = ones(n_PRB_sched*dmrs_re_per_prb,1);
    if mod(antenna_ports(ap), 2) == 1
      w_f(2:2:end) = -1;
    end
    
    a(:,ap) = w_f .* rd(1:n_PRB_sched*dmrs_re_per_prb,ap);
  end
end