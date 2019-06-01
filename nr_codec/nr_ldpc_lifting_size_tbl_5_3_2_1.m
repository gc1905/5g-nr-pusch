%Z = nr_ldpc_lifting_size_tbl_5_3_2_1(i_LS)
%
% Returns a vector consisting of lifting size values belonging
% to a specified lifting size set.
% Implements tables from 3GPP 38.212 5.3.2-1.
%
% Arguments:
%  base_graph - LDPC base graph (1 or 2) 
%  i_LS       - lifting size set index
%
% Returns:
%  Z          - vector of lifting sizes

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)
 
function Z = nr_ldpc_lifting_size_tbl_5_3_2_1(i_LS)
  switch i_LS
    case 0
      Z = [2, 4, 8, 16, 32, 64, 128, 256];
    case 1
      Z = [3, 6, 12, 24, 48, 96, 192, 384];
    case 2
      Z = [5, 10, 20, 40, 80, 160, 320];
    case 3
      Z = [7, 14, 28, 56, 112, 224];
    case 4
      Z = [9, 18, 36, 72, 144, 288];
    case 5
      Z = [11, 22, 44, 88, 176, 352];
    case 6
      Z = [13, 26, 52, 104, 208];
    case 7
      Z = [15, 30, 60, 120, 240];
    otherwise
      error('invalid value of i_LS');
  end
end