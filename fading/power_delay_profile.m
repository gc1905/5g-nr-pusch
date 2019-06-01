%[delay, gain] = power_delay_profile(name)
%[delay, gain] = power_delay_profile(name, T_s)
%[delay, gain] = power_delay_profile(name, T_s, 'reduce', N_taps)
%
% Returns multi-path power delay profile model as defined in [1] 
% and [2].
%
% [1] 3GPP TS 36.104 v. 13.4.0, Annex B
% [2] 3GPP TR 25.943 v. 13.0.0
% [3] 3GPP TR 38.901 v. 15.0.0
% [4] 3GPP TS 38.104 v. 15.4.0, Annex G
%
% Arguments:
%  name      - name of the model
%             'Flat' - single tap profile
%             'EPA' - Extended Pedestrian A
%             'EVA' - Extended Vehicular A
%             'ETU' - Extended Typical Urban
%             'Tu'  - Typical Urban
%             'Ra'  - Rural Area
%             'HT'  - Hilly Terrain
%             'TDL-{X}({DS})' - 5G TDL model defined in [3], where
%                     {X} is a letter from A to E and {DS} is an 
%                     integer delay spread
%             'TDLA30'  - reduced TDL-A(30) 5G model (see [4])
%             'TDLB100' - reduced TDL-B(100) 5G model (see [4])
%             'TDLC300' - reduced TDL-C(300) 5G model (see [4])
%  T_s       - time resolution for tap spacing [s]
%  resample_method - 'simple', 'reduce'
%  N_taps    - parameter for 'reduce' method
%
% Returns:
%  delay   - Excess tap delay [seconds]
%  gain    - Relative power [dB]
%  (length of both vectors is equal to the number of paths)

% Copyright 2017-2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [delay, gain] = power_delay_profile(name, T_s, resample_method, N_taps)
  if nargin < 3; resample_method = 'simple'; end

  % convert to lowercase
  name = lower(name);

  if strncmpi('tdl-', name, 4)
    pr = sscanf(name, 'tdl-%c(%d)');
    if strcmpi(char(pr(1)), 'a')
      delay = [0.0000, 0.3819, 0.4025, 0.5868, 0.4610, 0.5375, 0.6708, 0.5750, 0.7618, 1.5375, 1.8978, 2.2242, 2.1718, 2.4942, 2.5119, 3.0582, 4.0810, 4.4579, 4.5695, 4.7966, 5.0066, 5.3043, 9.6586];
      gain  = [-13.4, 0, -2.2, -4, -6, -8.2, -9.9, -10.5, -7.5, -15.9, -6.6, -16.7, -12.4, -15.2, -10.8, -11.3, -12.7, -16.2, -18.3, -18.9, -16.6, -19.9, -29.7];
      LOS_gain = NaN;
    elseif strcmpi(char(pr(1)), 'b')
      delay = [0.0000, 0.1072, 0.2155, 0.2095, 0.2870, 0.2986, 0.3752, 0.5055, 0.3681, 0.3697, 0.5700, 0.5283, 1.1021, 1.2756, 1.5474, 1.7842, 2.0169, 2.8294, 3.0219, 3.6187, 4.1067, 4.2790, 4.7834];
      gain  = [0, -2.2, -4, -3.2, -9.8, -1.2, -3.4, -5.2, -7.6, -3, -8.9, -9, -4.8, -5.7, -7.5, -1.9, -7.6, -12.2, -9.8, -11.4, -14.9, -9.2, -11.3];
      LOS_gain = NaN;
    elseif strcmpi(char(pr(1)), 'c')
      delay = [0.0000, 0.2099, 0.2219, 0.2329, 0.2176, 0.6366, 0.6448, 0.6560, 0.6584, 0.7935, 0.8213, 0.9336, 1.2285, 1.3083, 2.1704, 2.7105, 4.2589, 4.6003, 5.4902, 5.6077, 6.3065, 6.6374, 7.0427, 8.6523];
      gain  = [-4.4, -1.2, -3.5, -5.2, -2.5, 0, -2.2, -3.9, -7.4, -7.1, -10.7, -11.1, -5.1, -6.8, -8.7, -13.2, -13.9, -13.9, -15.8, -17.1, -16, -15.7, -21.6, -22.8];
      LOS_gain = NaN;
    elseif strcmpi(char(pr(1)), 'd')
      delay = [0.0000, 0.035, 0.612, 1.363, 1.405, 1.804, 2.596, 1.775, 4.042, 7.937, 9.424, 9.708, 12.525];
      gain  = [-13.5, -18.8, -21, -22.8, -17.9, -20.1, -21.9, -22.9, -27.8, -23.6, -24.8, -30.0, -27.7];
      LOS_gain = -0.2;
    elseif strcmpi(char(pr(1)), 'e')
      delay = [0.0000, 0.5133, 0.5440, 0.5630, 0.5440, 0.7112, 1.9092, 1.9293, 1.9589, 2.6426, 3.7136, 5.4524, 12.0034, 20.6519];
      gain  = [-22.03, -15.8, -18.1, -19.8, -22.9, -22.4, -18.6, -20.8, -22.6, -22.3, -25.6, -20.2, -29.8, -29.2];
      LOS_gain = -0.3;
    else
      error('no such model defined')
    end
    delay = delay * pr(2);
  elseif strcmpi(name, 'flat')
    delay = [0];
    gain  = [0];
  elseif strcmpi(name, 'epa')
    delay = [0, 30, 70, 90, 110, 190, 410];
    gain  = [0, -1, -2, -3, -8, -17.2, -20.8];
  elseif strcmpi(name, 'eva')
    delay = [0, 30, 150, 310, 370, 710, 1090, 1730, 2510];
    gain  = [0, -1.5, -1.4, -3.6, -6, -9.1, -7.0, -12.0, -16.9];
  elseif strcmpi(name, 'etu')
    delay = [0, 50, 120, 200, 230, 500, 1600, 2300, 5000];
    gain  = [-1, -1, -1, 0, 0, 0, -3, -5, -7];
  elseif strcmpi(name, 'tu')
    delay = [0, 217, 512, 514, 517, 674, 882, 1230, 1287, 1311, 1349, 1533, 1535, 1622, 1818, 1836, 1884, 1943, 2048, 2140];
    gain  = [-5.7, -7.6, -10.1, -10.2, -10.2, -11.5, -13.4, -16.3, -16.9, -17.1, -17.4, -19.0, -19.0, -19.8, -21.5, -21.6, -22.1, -22.6, -23.5, -24.3];
  elseif strcmpi(name, 'ra')
    delay = [0, 42, 101, 129, 149, 245, 312, 410, 469, 528];
    gain  = [-5.2, -6.4, -8.4, -9.3, -10.0, -13.1, -15.3, -18.5, -20.4, -22.4];
  elseif strcmpi(name, 'ht')
    delay = [0, 356, 441, 528, 546, 609, 625, 842, 916, 941, 15000, 16172, 16492, 16876, 16882, 16978, 17615, 17827, 17849, 18016];
    gain  = [-3.6, -8.9, -10.2, -11.5, -11.8, -12.7, -13.0, -16.2, -17.3, -17.7, -17.6, -22.7, -24.1, -25.8, -25.8, -26.2, -29.0, -29.9, -30.0, -30.7];
  elseif strcmpi(name, 'tdla30')
    delay = [0, 10, 15, 20, 25, 50, 65, 75, 105, 135, 150, 290];
    gain  = [-15.5, 0, -5.1, -5.1, -9.6, -8.2, -13.1, -11.5, -11, -16.2, -16.6, -26.2];
  elseif strcmpi(name, 'tdlb100')
    delay = [0, 10, 20, 30, 35, 45, 55, 120, 170, 245, 330, 480];
    gain  = [0, -2.2, -0.6, -0.6, -0.3, -1.2, -5.9, -2.2, -0.8, -6.3, -7.5, -7.1];
  elseif strcmpi(name, 'tdlc300')
    delay = [0, 65, 70, 190, 195, 200, 240, 325, 520, 1045, 1510, 2595];
    gain  = [-6.9, 0, -7.7, -2.5, -2.4, -9.9, -8, -6.6, -7.1, -13, -14.2, -16];
  else
    error('no such model defined')
  end

  % sort by delay in ascending order
  [delay, didx] = sort(delay);
  gain = gain(didx);

  % convert from namoseconds to seconds
  delay = delay * 1e-9;

  if strcmpi(resample_method, 'simple')
    [delay, gain] = pdp_resample_simple(delay, gain, T_s);
  elseif strcmpi(resample_method, 'reduce')
    [delay, gain] = pdp_resample_reduce(delay, gain, T_s, 1e-9, N_taps);
  else
    error('invalid PDP resample method');
  end

  % convert delay from ns to samples
  delay = round(delay / T_s);

  if nargout < 2
    gain = 10.0 .^ (gain / 10.0); 
    cir = zeros(1,max(delay));
    for idx = 1 : length(gain)
      cir(delay(idx)+1) = gain(idx);
    end
    delay = cir;
  end
end