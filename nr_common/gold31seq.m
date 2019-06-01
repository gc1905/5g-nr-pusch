%[c] = gold31seq(c_init, len)
%
% Calculates pseudo-random sequence as defined in 
% 3GPP 38.211 sec. 5.2.1.
%
% Arguments:
%  c_init     - initial value of x2 sequence
%  len        - length of the sequence
%
% Returns:
%  c          - generated binary sequence

% Copyright 2018-2019 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [c] = gold31seq(c_init, len)
  try
    c = gold31seq_mex(c_init, len);
    return;
  catch
    persistent flag
    if isempty(flag)
      disp('gold31seq: compile mex file to reduce execution time');
      flag = 0;
    end 
  end

  N_c = 1600;

  x1 = zeros(1,N_c + len + 31);
  x2 = zeros(1,N_c + len + 31);

  c_init_vec = (bitand(2.^(0:30),c_init) ~= 0);

  x1(1) = 1;
  x2(1:length(c_init_vec)) = c_init_vec;

  for n = 1 : (len+N_c)
    x1(n+31) = mod(x1(n+3) + x1(n),2);
    x2(n+31) = mod(x2(n+3) + x2(n+2) + x2(n+1) + x2(n),2);
  end

  c(1:len)= mod(x1((1:len)+N_c) + x2((1:len)+N_c),2);
end