%[iq_fade] = apply_fading_td(iq, f_d, f_s, mpprofile, channel='sos')
%
% Applies specified channel profile to time domain IQ data using specified 
% channel profile and fading coefficients generators.
%
% Arguments:
%  iq        - matrix of time domain samples of size [num_samples, num_TX_ant]
%  f_d       - Doppler frequency [Hz]
%  f_s       - baseband sampling frequency [Hz]
%  mpprofile - channel power delay profile string ('epa', 'eva', 'etu') or 2 x L
%              matrix containing multipath tap delays [s] in column 1 and 
%              multipath tap gains [dB] in column 2
%  channel   - method for generation of channel tap coefficients or channel 
%              matrix
%              'zheng' - Rayleigh fading: Zheng and Xiao Sum-of-Sinusoids method
%              'jtc'   - Rayleigh fading: JTC Fader
%              Matrix of size len(iq) x (NumOfTaps) containing time varying
%              channel coefficients may be passed instead.
%  mimo      - vector with MIMO configuration with elements:
%              1 - TX ant num, 2 - RX ant num, 3 - TX ant corr, 4 - RX ant corr
%
% Returns:
%  iq_fade   - faded time domain IQ data
%  h         - generated matrix of size [num_samples, num_taps] containing time 
%              varying channel coefficients may be passed instead.

% Copyright 2017 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [iq_fade,h] = apply_fading_td(iq, f_d, f_s, mpprofile, channel, mimo)
  if nargin < 6; mimo = [1,1]; end
  if nargin < 5; channel = 'zheng'; end

  ant_TX = mimo(1);
  ant_RX = mimo(2);
  if ant_TX > 1 || ant_RX > 1
    cor_TX = mimo(3);
    cor_RX = mimo(4);
  end
  MIMO_channels = ant_TX * ant_RX;

  assert(size(iq, 2) == ant_TX, 'number of columns in input IQ must be equal to number of TX antennas');

  if ~ischar(mpprofile)
    assert(size(mpprofile, 1) == 2, 'mpprofile must be string or L x 2 matrix');
    tds = mpprofile(1,:);
    tgl = mpprofile(2,:);
  else
    [tds, tgl] = power_delay_profile(mpprofile, 1 / f_s);
  end

  tgl = 10.0 .^ (tgl / 10.0); 

  assert(length(tds) == length(tgl), 'lengths of tap_gain and tap_delay must be equal');

  N = size(iq,1);
  L = numel(tds);
  h = zeros([N, L, MIMO_channels]);

  if strcmp(channel, 'zheng')
    for m = 1 : MIMO_channels
      for l = 1 : L
        h(:,l,m) = fading_channel_zheng(f_d, f_s, 1:N);
      end
    end
  elseif strcmp(channel, 'jtc')
    for m = 1 : MIMO_channels
      for l = 1 : L
        h(:,l,m) = fading_channel_jtc(f_d, f_s, 1:N);
      end
    end
  elseif strcmp(channel, 'idft')
    for m = 1 : MIMO_channels
      for l = 1 : L
        h(:,l,m) = fading_channel_idft(f_d, f_s, 1:N);
      end
    end
  elseif ischar(channel)
    error('no such channel generation method');
  else
    h = channel;
  end

  if (MIMO_channels > 1)
    R = kronecker_correlation_matrix(ant_TX, ant_RX, [cor_TX, cor_RX]);
    C = chol(R);

    h_c = zeros(size(h));
    for l = 1 : L
      h_c(:,l,:) = (C' * reshape(h(:,l,:), [N,MIMO_channels]).').';
    end

    iq_fade_ch = zeros(size(iq,1), MIMO_channels);
    for m_rx = 1 : ant_RX
      for m_tx = 1 : ant_TX
        ch_id = ((m_rx-1)*ant_RX)+m_tx;
        iq_fade_ch(:,ch_id) = tapped_delay_line(iq(:,m_tx), tds, tgl, h_c(:,:,ch_id));
      end
    end

    iq_fade = zeros(size(iq,1), ant_RX);
    for m_rx = 1 : ant_RX
      iq_fade(:,m_rx) = sum(iq_fade_ch(:,(m_rx-1)*ant_TX+1 : m_rx*ant_TX),2);
    end

    h = h_c;
  else
    iq_fade = tapped_delay_line(iq, tds, tgl, h);
  end
end