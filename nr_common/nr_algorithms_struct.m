%alg = nr_algorithms_struct()
%
% Generates a structure that holds algorithm configuration for
% receiver processing of 5G NR channels. The structure is filled
% with default values, which can be modified afterwards.
%
% Returns:
%  alg - algorithm structure with the elements:
%        chan_est - channel estimation algorithm
%           'LS' - Least Squares method 
%           'MMSE' - Minimum Mean Squared Error method
%        chan_est_avg - smoothing MA filter configuration
%           of estimated channel response. The first element
%           sets half-window length for frequency domain
%           averaging, when the second is for time averaging.\
%        sto_est - sample time offset estimation algorithm
%           'none' - bypass STO estimation and correction
%           'dft'  - DFT method
%           'prony' - Prony's method (Lank-Reed-Pollon)
%        cfo_est - carrier frequency offset estimation algorithm
%           'none' - bypass STO estimation and correction
%           'prony' - Prony's method (Lank-Reed-Pollon)
%        equalizer -  equalizer algorithm for MIMO channel
%           'ZF' - Zero-Forcing equalizer
%           'MMSE' - Minimum Mean Squared Error equalizer
%        demodulation_method - calculation of LLR values
%           'Approx LLR' - approximated LLR
%           'True LLR' - LLR based on LOGMAP
%           'Hard' - hard demodulation 

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function alg = nr_algorithms_struct()
  alg = struct();

  alg.chan_est = 'LS'; % 'MMSE', 'LS'
  alg.chan_est_avg = [3,0];
  alg.sto_est = 'dft'; % 'prony', 'none'
  alg.cfo_est = 'none'; % 'prony'
  alg.equalizer = 'MMSE'; % 'ZF'
  alg.demodulation_method = 'Approx LLR'; % 'True LLR', 'Hard'
end