%a = nr_pusch_transmit(b, Q_m, N_layer, frame_cfg, slot_num, symbol_start, n_PRB_start, 
%                      n_PRB_sched, antenna_ports, higher_layer_params, n_rnti, tpmi)
%
% Implements PUSCH/PDSCH transmitted chain from 3GPP 38.211 sec. 6.3.1 and 7.3.1.
%
% Arguments:
%  b         - vector of LLR values
%  Q_m       - modulation order
%              1 - BPSK
%              2 - QPSK
%              4 - 16QAM
%              6 - 64QAM
%              8 - 256QAM
%  N_layer   - number of layers
%  frame_cfg - OFDM framing constants structure
%  slot_num  - slot number in frame
%  symbol_start  - the first symbol of PDSCH/PUSCH transmission
%  n_PRB_start   - starting PRB number
%  n_PRB_sched   - number of scheduled PRBs
%  antenna_ports - vector of antenna port numbers (values 0-7 for DMRS config 1, 
%                  0-11 for config 2) of size [N_ap,1]
%  higher_layer_params - higher layer parameters structure
%  n_rnti    - UE RNTI identifier
%  tpmi      - TPMI index from 3GPP 38.211 sec. 6.3.1.5.
%
% Returns:
%  a         - RE grid with mapped PUSCH/PDSCH transmission
%              size [N_sc,N_slot_symbol,N_ap]

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function a = nr_pusch_transmit(b, Q_m, N_layer, frame_cfg, slot_num, symbol_start, n_PRB_start, n_PRB_sched, antenna_ports, higher_layer_params, n_rnti, tpmi)
  N_ap = length(antenna_ports);

  % prepare data modulation symbols
  bs = nr_38_211_sch_scrambling(b, n_rnti, higher_layer_params.Data_scrambling_Identity);
  d = modulation_mapper(bs(:), Q_m);
  x = nr_38_211_layer_mapping(d, N_layer);

  z = nr_38_211_precoding(x, N_ap, tpmi, higher_layer_params.PUSCH_tp);
  
  assert(higher_layer_params.UL_DMRS_max_len == 1, 'only single-symbol DM-RS is currently supported');

  symbols_sched = (1 + higher_layer_params.UL_DMRS_add_pos) + size(z,1) / (n_PRB_sched*frame_cfg.N_sc_RB);

  l_dmrs = nr_38_211_sch_dmrs_positions(symbols_sched, higher_layer_params.UL_DMRS_config_type, higher_layer_params.UL_DMRS_add_pos, 1, higher_layer_params.UL_DMRS_typeA_pos);
  k = frame_cfg.N_sc_RB*n_PRB_start + (1 : frame_cfg.N_sc_RB*n_PRB_sched);

  if higher_layer_params.UL_DMRS_config_type == 2
    l_dmrs = l_dmrs + symbol_start;
  end

  a = zeros(frame_cfg.N_sc_RB*frame_cfg.N_RB,frame_cfg.N_slot_symbol,N_ap);

  z_idx = 1;
  
  for l = symbol_start : symbol_start + symbols_sched - 1
    if ismember(l, l_dmrs)
      r_dmrs = nr_38_211_sch_dmrs_gen_symbol(n_PRB_start, n_PRB_sched, N_layer, antenna_ports, tpmi, slot_num, l, higher_layer_params.UL_DMRS_config_type, higher_layer_params.PUSCH_tp, higher_layer_params.UL_DMRS_Scrambling_ID(2), higher_layer_params.UL_DMRS_Scrambling_ID(1));
      for ap = 1 : N_ap
        k_dmrs = nr_38_211_sch_dmrs_re_mapping(n_PRB_start, n_PRB_sched, higher_layer_params.UL_DMRS_config_type, antenna_ports(ap));
        a(k_dmrs+1,l+1,ap) = r_dmrs(:,ap);
      end
    else
      for ap = 1 : N_ap
        a(k,l+1,ap) = z(z_idx:z_idx+n_PRB_sched*frame_cfg.N_sc_RB-1,ap);
      end
      z_idx = z_idx + n_PRB_sched*frame_cfg.N_sc_RB;
    end
  end
end