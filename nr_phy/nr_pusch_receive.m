% b = nr_pusch_receive(a, Q_m, N_layer, frame_cfg, slot_num, symbol_start, symbols_sched, 
%        n_PRB_start, n_PRB_sched, antenna_ports, higher_layer_params, algorithms, n_rnti)
%
% Implements PUSCH/PDSCH receiver chain from 3GPP 38.211 sec. 6.3.1 and 7.3.1.
%
% Arguments:
%  a         - RE grid with mapped PUSCH/PDSCH transmission
%              size [N_sc,N_slot_symbol,N_rx_ant]
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
%  symbol_sched  - number of scheduled PDSCH/PUSCH OFDM symbols
%  n_PRB_start   - starting PRB number
%  n_PRB_sched   - number of scheduled PRBs
%  antenna_ports - vector of antenna port numbers (values 0-7 for DMRS config 1, 
%                  0-11 for config 2) of size [N_ap,1]
%  higher_layer_params - higher layer parameters structure
%  algorithms    - algorithm configuration structure
%  n_rnti    - UE RNTI identifier
%  tpmi      - TPMI index from 3GPP 38.211 sec. 6.3.1.5.
%
% Returns:
%  b         - vector of LLR values
%  evm_dmrs  - EVM of DMRS signal per TX layer and RX antenna
%              matrix size is [N_layer,N_rx_ant]

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [b, evm_dmrs] = nr_pusch_receive(a, Q_m, N_layer, frame_cfg, slot_num, symbol_start, symbols_sched, n_PRB_start, n_PRB_sched, antenna_ports, higher_layer_params, algorithms, n_rnti)
  assert(higher_layer_params.UL_DMRS_max_len == 1, 'only single-symbol DM-RS is currently supported');

  N_rx_ant = size(a,3);

  l_dmrs = nr_38_211_sch_dmrs_positions(symbols_sched, higher_layer_params.UL_DMRS_config_type, higher_layer_params.UL_DMRS_add_pos, 1, higher_layer_params.UL_DMRS_typeA_pos);
  k = frame_cfg.N_sc_RB*n_PRB_start + (1 : frame_cfg.N_sc_RB*n_PRB_sched);

  if higher_layer_params.UL_DMRS_config_type == 1
    l_dmrs = l_dmrs - symbol_start;
  end

  symbols_dmrs =  1 + higher_layer_params.UL_DMRS_add_pos;
  symbols_data = symbols_sched - symbols_dmrs;
  dmrs_per_rb = nr_38_211_sch_dmrs_per_prb(higher_layer_params.UL_DMRS_config_type);

  a_partial = a(k,symbol_start+1:symbol_start+symbols_sched,:);
  
  k_dmrs = zeros(nr_38_211_sch_dmrs_per_prb(higher_layer_params.UL_DMRS_config_type)*n_PRB_sched, N_layer);
  tx_pilot = zeros(dmrs_per_rb*n_PRB_sched, symbols_dmrs, N_layer);
  rx_pilot = zeros(dmrs_per_rb*n_PRB_sched, symbols_dmrs, N_layer, N_rx_ant);

  % Pilot generation and extraction
  ll = 1;
  for l = 0 : symbols_sched - 1 
    if ismember(l, l_dmrs) 
      r_dmrs = nr_38_211_sch_dmrs_gen_symbol(n_PRB_start, n_PRB_sched, N_layer, antenna_ports, 0, slot_num, l+symbol_start, higher_layer_params.UL_DMRS_config_type, higher_layer_params.PUSCH_tp, higher_layer_params.UL_DMRS_Scrambling_ID(2), higher_layer_params.UL_DMRS_Scrambling_ID(1));
      for n_layer = 1 : N_layer
        k_dmrs(:,n_layer) = nr_38_211_sch_dmrs_re_mapping(n_PRB_start, n_PRB_sched, higher_layer_params.UL_DMRS_config_type, antenna_ports(n_layer));
        tx_pilot(:,ll,n_layer) = r_dmrs(:,n_layer);
        for n_ant = 1 : N_rx_ant
          rx_pilot(:,ll,n_layer,n_ant) = a_partial(k_dmrs(:,n_layer)-n_PRB_start*dmrs_per_rb+1,l+1,n_ant);
        end
      end
      ll = ll + 1;
    end
  end
  
  % Carrier Frequency Offset estimation and compensation
  if ~strcmpi(algorithms.cfo_est, 'none')
    f_cfo_est = estimate_cfo_from_pilots(tx_pilot, rx_pilot, k_dmrs+1, l_dmrs+1, frame_cfg, algorithms.cfo_est);
    cfomtx = cfo_fd_mtx(frame_cfg.N_fft, rms(f_cfo_est(:)), frame_cfg.scs);
    cfomtx = cfomtx(k,k);
    for n_sym = 1 : size(a_partial,2)
      offset = nr_symbol_start_offset(frame_cfg, slot_num, symbol_start + n_sym - 1);
      for n_ant = 1 : size(a_partial,3)
        a_partial(:,n_sym,n_ant) = cfomtx * a_partial(:,n_sym,n_ant) * exp(2i*pi*offset/frame_cfg.N_fft);
      end
    end
  end
  
  % Sample Time Offset estimation and compensation
  if ~strcmpi(algorithms.sto_est, 'none')
    t_sto_est = estimate_sto_from_pilots(tx_pilot, rx_pilot, k_dmrs+1, l_dmrs+1, frame_cfg, algorithms.sto_est);
    for n_sym = 1 : size(a_partial, 2)
      for n_ant = 1 : size(a_partial, 3)
        a_partial(:,n_sym,n_ant) = a_partial(:,n_sym,n_ant) .* exp(2i * pi * (rms(t_sto_est(:,n_ant))) * (k-1)' / frame_cfg.N_fft);
      end
    end
  end

  % Pilot extraction after CFO and STO compensation
  for l_x = 1 : numel(l_dmrs)
    for n_layer = 1 : N_layer
      for n_ant = 1 : N_rx_ant
        rx_pilot(:,l_x,n_layer,n_ant) = a_partial(k_dmrs(:,n_layer)-n_PRB_start*dmrs_per_rb+1,l_dmrs(l_x)+1,n_ant);
      end
    end
  end
  
  if N_layer == 1 && N_rx_ant == 1
    % Channel estimator
    [H_est, noise_est, signal_est] = channel_estimate(tx_pilot, rx_pilot, k_dmrs+1, l_dmrs+1, [frame_cfg.N_sc_RB*n_PRB_sched,symbols_sched], algorithms.chan_est_avg, algorithms.chan_est, frame_cfg.N_fft);
    % Equalizer
    a_partial_eq = a_partial ./ H_est;
  elseif N_layer == 2 && N_rx_ant == 2
    a_partial_eq = zeros(size(a_partial));
    H_est = zeros(frame_cfg.N_sc_RB*n_PRB_sched,symbols_sched,N_layer,N_rx_ant);
    noise_est = zeros(N_layer,1);
    signal_est = zeros(N_layer,1);
    % Channel estimator
    for n_layer = 1 : N_layer
      [H_est(:,:,n_layer,:), noise_est(n_layer), signal_est(n_layer)] = channel_estimate_SIMO(tx_pilot(:,:,n_layer), reshape(rx_pilot(:,:,n_layer,:), [dmrs_per_rb*n_PRB_sched,symbols_dmrs,N_rx_ant]), k_dmrs(:,n_layer)+1, l_dmrs+1, [frame_cfg.N_sc_RB*n_PRB_sched,symbols_sched], algorithms.chan_est_avg, algorithms.chan_est, frame_cfg.N_fft);
    end
    % Equalizer
    NSR = rms(noise_est) / rms(signal_est);
    for n_sym = 1:size(a_partial,2)
      for n_re = 1:size(a_partial,1)
        Hd = reshape(H_est(n_re,n_sym,:,:), [N_layer,N_rx_ant]).';
        x_re = reshape(a_partial(n_re,n_sym,:),[],1);
        if strcmpi(algorithms.equalizer, 'MMSE')
          % MMSE receiver - 3GPP TR 36.829 V11.1.0 sec. 4.1
          a_partial_eq(n_re,n_sym,:) = Hd' * inv(Hd * Hd' + NSR * eye(size(Hd))) * x_re;
        elseif strcmpi(algorithms.equalizer, 'ZF')
          % ZF receiver
          a_partial_eq(n_re,n_sym,:) = inv(Hd) * x_re;
        else
          error('Equalizer algorithm not supported: %s', algorithms.equalizer);
        end
      end
    end
  else
    error('this MIMO configuration is not supported by the equalizer');
  end

  % Resource Element Demapping
  x_idx = 1;
  x = zeros(symbols_data*n_PRB_sched*frame_cfg.N_sc_RB, N_layer);
  x_sig_est = zeros(symbols_data*n_PRB_sched*frame_cfg.N_sc_RB, N_layer);
  for l = 0 : symbols_sched - 1
    if ~ismember(l, l_dmrs)
      for n_layer = 1 : N_rx_ant
        x(x_idx:x_idx+n_PRB_sched*frame_cfg.N_sc_RB-1,n_layer) = a_partial_eq(:,l+1,n_layer);
        x_sig_est(x_idx:x_idx+n_PRB_sched*frame_cfg.N_sc_RB-1,n_layer) = rms(H_est(:,l+1,n_layer,:), 4);
      end
      x_idx = x_idx + n_PRB_sched*frame_cfg.N_sc_RB;
    end
  end

  d = nr_38_211_layer_demapping(x, N_layer);
  d_sig_est = nr_38_211_layer_demapping(x_sig_est, N_layer);

  bs = modulation_demapper_soft(d, Q_m, algorithms.demodulation_method, rms(noise_est) ./ d_sig_est);
  b = nr_38_211_sch_scrambling(bs, n_rnti, higher_layer_params.Data_scrambling_Identity);
  
  if nargout > 1
    evm_dmrs = zeros(N_layer,1);
    for n_layer = 1 : N_layer
      rx_pilot_eq = a_partial_eq(k_dmrs(:,n_layer)-n_PRB_start*dmrs_per_rb+1,l_dmrs+1,n_layer);
      evm_dmrs(n_layer) = evm(rx_pilot_eq, tx_pilot(:,:,n_layer));
    end
  end
end