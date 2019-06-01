%[R] = kronecker_correlation_matrix(N_ue, N_enb, correlation, scale=0)
%
% Calculates channel spatial correlation matrix between UE and eNB.
%
% The scaling is applied in the following way [1]:
%   R = ( R_{spatial} + scale * eye(n) ) / (1 + scale)
% When the coefficients a, b are set via string variable, scaling 
% is applied automatically depending on correlation type and antenna
% number.
%
% [1] 3GPP TS 36.104 version 13.4.0 Release 13,
%     'Evolved Universal Terrestrial Radio Access (E-UTRA);
%     Base Station (BS) radio transmission and reception',
%     Annex B.5
%
% Arguments:
%  N_enb       - number of eNB antennas
%  N_ue        - number of UE antennas
%  correlation - spatial correlation between RX/TX antennas
%                May be a string indicating correlation type:
%                'low'    -> a = 0.0, b = 0.0
%                'medium' -> a = 0.9, b = 0.3
%                'high'   -> a = 0.9, b = 0.9
%                Otherwise, can be 2 element vector, with 1st element 
%                being eNB correlation and 2nd being UE correlation.
%  scale       - scaling factor (applied only for vector correlation)
%
% Returns:
%  R         - spatial correlation matrix

% Copyright 2017 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [R] = kronecker_correlation_matrix(N_enb, N_ue, correlation, scale)

  if isstr(correlation)
    if strcmp('low', correlation)
      a = 0.0; 
      b = 0.0;
      scale = 0;
    elseif strcmp('medium', correlation)
      a = 0.9; 
      b = 0.3;
      if N_ue == 2 && N_enb == 4
        scale = 0.0001;
      elseif N_ue == 4 && N_enb == 4
        scale = 0.00012;
      else
      	scale = 0;
      end
    elseif strcmp('high', correlation)
      a = 0.9;
      b = 0.9;
      if N_ue == 2 && N_enb == 4
        scale = 0.0001;
      elseif N_ue == 4 && N_enb == 4
        scale = 0.00012;
      else
      	scale = 0;
      end
    else
      error('unknown correlation type');
    end
  elseif length(correlation) == 2
  	a = correlation(1);
    b = correlation(2);

    if nargin == 3
      scale = 0;
    end
  else
  	error('wrong input argument format');
  end

  if N_enb == 1
  	R_enb = 1;
  elseif N_enb == 2
    t = [0 a; 0 0];
    R_enb = t + eye(2) + conj(t');
  elseif N_enb == 4
  	a1 = a^(1/9);
  	a4 = a^(4/9);
    t = [0 a1 a4 a; 0 0 a1 a4; 0 0 0 a1; 0 0 0 0];
    R_enb = t + eye(4) + conj(t');
  else
  	error('only 1, 2 or 4 eNB antennas supported');
  end

  if N_ue == 1
  	R_ue = 1;
  elseif N_ue == 2
    t = [0 b; 0 0];
    R_ue = t + eye(2) + conj(t');
  elseif N_ue == 4
  	b1 = b^(1/9);
  	b4 = b^(4/9);
    t = [0 b1 b4 b; 0 0 b1 b4; 0 0 0 b1; 0 0 0 0];
    R_ue = t + eye(4) + conj(t');
  else
  	error('only 1, 2 or 4 UE antennas supported');
  end

  % R_spat is the Kronecker product of R_enb and R_ue
  R_spat = kron(R_ue, R_enb);

  % apply scaling
  R = ( R_spat + scale * eye(size(R_spat)) ) / (1 + scale);
end