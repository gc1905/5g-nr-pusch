%p = nr_38_212_crc_calc(b, crc_gen) 
%
% Calculates CRC as defined in 3GPP 38.212 sec. 5.1.
%
% Arguments:
%  b          - binary vector
%  crc_gen    - polynomial selection: 
%               6, 11, 16, '24a', '24b' or '24c'
%
% Returns:
%  p          - binary vector of calculated CRC bits

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function p = nr_38_212_crc_calc(b, crc_gen) 
  if crc_gen == 6
    crc_poly = [1,1,0,0,0,0,1];
  elseif crc_gen == 11
    crc_poly = [1,1,1,0,0,0,1,0,0,0,0,1];
  elseif crc_gen == 16
    crc_poly = [1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];
  elseif strcmpi(crc_gen, '24a')
    crc_poly = [1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,1];
  elseif strcmpi(crc_gen, '24b')
    crc_poly = [1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1];
  elseif strcmpi(crc_gen, '24c')
    crc_poly = [1,1,0,1,1,0,0,1,0,1,0,1,1,0,0,0,1,0,0,0,1,0,1,1,1];
  else
    error('Invalid crc_gen (%s)', crc_gen);
  end

  try
    p = crc_calc_mex(b, crc_poly);
    return;
  catch
    persistent flag
    if isempty(flag)
      disp('nr_38_211_crc_calc: compile mex file to reduce execution time');
      flag = 0;
    end
  end

  lfsr = zeros(1,length(crc_poly));
  b_ext = [b(:); zeros(length(crc_poly)-1,1)];

  for n = 1:length(b_ext)
    lfsr = [lfsr(2:end) b_ext(n)];
    if (lfsr(1) ~= 0)
      lfsr = mod(lfsr + crc_poly, 2);
    end
  end

  p = lfsr(2:end);
end