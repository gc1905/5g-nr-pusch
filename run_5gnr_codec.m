% simulation parameters
ITERS = 10;
SNR = -5;
N_prb = 200;
N_symbols = 12;
N_layers = 2; 
I_mcs = 1;
rv_id = 0;
% % % %

N0 = 10.0 ^ (-SNR / 20.0);
Q_m = nr_resolve_mcs(I_mcs, 1);
[tbs, ctbs] = nr_transport_block_size(N_symbols, 0, N_prb, I_mcs, N_layers);

bits_tx    = 0;
bits_err   = 0;
blocks_tx  = 0;
blocks_err = 0;

for it = 1 : ITERS
  a = randi([0 1], [tbs 1]);
  g = nr_sch_encode(a, I_mcs, N_layers, rv_id, ctbs);

  d = modulation_mapper(g, Q_m);
  d_noisy = d + N0 / sqrt(2) * (randn(size(d)) + 1i * randn(size(d)));

  LLR = modulation_demapper_soft(d_noisy, Q_m, 'Approx LLR', N0);
  [a_rx, tb_crc_ok, cb_crc_ok] = nr_sch_decode(LLR, I_mcs, N_layers, rv_id, tbs);

  bits_tx = bits_tx + tbs;
  bits_err = bits_err + sum(a_rx ~= a);
  blocks_tx = blocks_tx + numel(cb_crc_ok);
  blocks_err = blocks_err + sum(cb_crc_ok == 0);
end

BER = bits_err / bits_tx
BLER = blocks_err / blocks_tx