%frame_cfg = nr_framing_constants(FR, scs, band, N_RB_sel=0)
%
% Generates the OFDM framing constants structure that consolidates
% all the parameters related to OFDM numerology and physical frame 
% structure.
% Based on 3GPP 38.211 sec. 4.3 and 3GPP 38.104 sec. 5.3.
%
% Arguments:
%  FR        - frequency range (1 - below 6 GHz, 2 - above 6 GHz)
%  scs       - subcarrier spacing in Hz. Permitted values:
%              FR1: [15e3 30e3 60e3]
%              FR2: [60e3 120e3]
%  band      - transmission bandwidth in MHz. Permitted values:
%              FR1: [5 10 15 20 25 30 40 50 60 70 80 90 100]
%              FR2: [50 100 200 400]
%  N_RB_sel  - number of PRB allocated for transmission. Cannot exceed
%              values specified by 3GPP 38.104. If set to 0, the maximum
%              number of PRB is used.
%
% Returns:
%  frame_cfg - OFDM framing constants structure with the elements:
%              technology - string, fixed to 'NR'
%              u - OFDM numerology (as per 3GPP 38.211 sec. 4.3.2)
%              N_fft - FFT size
%              scs - subcarrier spaing in Hz
%              bandwidth - transmission bandwidth in Hz
%              F_s - sampling frequency in Hz
%              N_sc  - number of subcarriers allocated for transmission
%              N_RB - number of PRB allocated for transmission
%              N_sc_RB - number of OFDM subcarriers per PRB (fixed to 12)
%              N_slot_symbol   - number of symbols in a slot
%              N_subframe_slot - number of slots in a subframe
%              N_frame_slot - number of slots in a frame

% Copyright 2018-2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function frame_cfg = nr_framing_constants(FR, scs, band, N_RB_sel)
  assert(ismember(scs, [15e3 30e3 60e3 120e3]), 'supported value of scs are: 15e3, 30e3, 60e3 and 120e3');
  if nargin < 4; N_RB_sel = 0; end
  
  if FR == 1
    scs_idx = find([15e3 30e3 60e3] == scs);
    band_idx = find([5 10 15 20 25 30 40 50 60 70 80 90 100] == band);

    % table 38.104 5.3.2-1
    tbl_5_3_2 = [ 25  52  79 106 133 160 216 270 NaN NaN NaN NaN NaN
                  11  24  38  51  65  78 106 133 162 189 217 245 273
                 NaN  11  18  24  31  38  51  65  79  93 107 121 135];
    tbl_5_3_3 = [ 242.5 312.5 382.5 452.5 522.5 592.5 552.5  692.5  NaN   NaN   NaN   NaN   NaN
                  505   665   645   805   785   945   905   1045    825   965   925   885   845
                  NaN  1010   990  1330  1310  1290  1610   1570   1530  1490  1450  1410  1370] * 1e3;
  elseif FR == 2
    scs_idx = find([60e3 120e3] == scs);
    band_idx = find([50 100 200 400] == band);

    tbl_5_3_2 = [ 66  132 264 NaN
                  32  66  132 264];
    tbl_5_3_3 = [ 1210  2450  4930   NaN
                  1900  2420  4900  9860] * 1e3;
  else
    error('FR must be either 1 or 2');
  end

  N_RB = tbl_5_3_2(scs_idx,band_idx);
  min_guard = tbl_5_3_3(scs_idx,band_idx);
  
  if N_RB_sel > 0
    assert(N_RB_sel <= N_RB);
    N_RB = N_RB_sel;
  end

  u = log2(scs/15e3);
  N_sc_RB = 12;
  N_slot_symbol = 14;
  N_sc = N_RB * N_sc_RB;

  FFT_SIZES = 2.^(8:12);
  fft_idx = min(find(N_sc * scs + 2 * min_guard < FFT_SIZES * scs));
  N_fft = FFT_SIZES(fft_idx);

  F_s = scs * N_fft;
  N_subframe_slot = 2^u;
  N_frame_slot = 2^u * 10;

  frame_cfg = struct('technology', 'NR', 'u', u, 'N_fft', N_fft, 'scs', scs, 'bandwidth', band*1e6,...
    'F_s', F_s, 'N_sc', N_sc, 'N_RB', N_RB, 'N_sc_RB', N_sc_RB, 'N_slot_symbol', N_slot_symbol,...
    'N_subframe_slot', N_subframe_slot, 'N_frame_slot', N_frame_slot);
end