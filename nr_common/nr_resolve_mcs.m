%[Q_m, R, se] = nr_resolve_mcs(I_mcs, tbl_no)
%
% Resolves MCS index into modulation order and coding rate for PUSCH channel
% based on 3GPP 38.214 Tables 6.1.4.1-1 and 6.1.4.1-2. 
%
% Arguments:
%  I_mcs     - MCS index
%  tbl_no    - index of MCS table (1 - 64-QAM, 2 - 256-QAM)
%
% Returns:
%  Q_m       - modulation order
%  R         - coding rate
%  se        - spectral efficiency

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function [Q_m, R, se] = nr_resolve_mcs(I_mcs, tbl_no)
if tbl_no == 1
  switch I_mcs
    case 0 
      A = [2 120 0.2344];
    case 1 
      A = [2 157 0.3066];
    case 2 
      A = [2 193 0.3770];
    case 3 
      A = [2 251 0.4902];
    case 4 
      A = [2 308 0.6016];
    case 5 
      A = [2 379 0.7402];
    case 6 
      A = [2 449 0.8770];
    case 7 
      A = [2 526 1.0273];
    case 8 
      A = [2 602 1.1758];
    case 9 
      A = [2 679 1.3262];
    case 10
      A = [4 340 1.3281];
    case 11
      A = [4 378 1.4766];
    case 12
      A = [4 434 1.6953];
    case 13
      A = [4 490 1.9141];
    case 14
      A = [4 553 2.1602];
    case 15
      A = [4 616 2.4063];
    case 16
      A = [4 658 2.5703];
    case 17
      A = [6 438 2.5664];
    case 18
      A = [6 466 2.7305];
    case 19
      A = [6 517 3.0293];
    case 20
      A = [6 567 3.3223];
    case 21
      A = [6 616 3.6094];
    case 22
      A = [6 666 3.9023];
    case 23
      A = [6 719 4.2129];
    case 24
      A = [6 772 4.5234];
    case 25
      A = [6 822 4.8164];
    case 26
      A = [6 873 5.1152];
    case 27
      A = [6 910 5.3320];
    case 28
      A = [6 948 5.5547];
  end
elseif tbl_no == 2
  switch I_mcs
    case 0
      A = [2 120 0.2344];
    case 1
      A = [2 193 0.3770];
    case 2
      A = [2 308 0.6016];
    case 3
      A = [2 449 0.8770];
    case 4
      A = [2 602 1.1758];
    case 5
      A = [4 378 1.4766];
    case 6
      A = [4 434 1.6953];
    case 7
      A = [4 490 1.9141];
    case 8
      A = [4 553 2.1602];
    case 9
      A = [4 616 2.4063];
    case 10
      A = [4 658 2.5703];
    case 11 
      A = [6 466 2.7305];
    case 12 
      A = [6 517 3.0293];
    case 13 
      A = [6 567 3.3223];
    case 14 
      A = [6 616 3.6094];
    case 15 
      A = [6 666 3.9023];
    case 16 
      A = [6 719 4.2129];
    case 17 
      A = [6 772 4.5234];
    case 18 
      A = [6 822 4.8164];
    case 19 
      A = [6 873 5.1152];
    case 20 
      A = [8 682.5 5.3320];
    case 21 
      A = [8 711 5.5547];
    case 22 
      A = [8 754 5.8906];
    case 23 
      A = [8 797 6.2266];
    case 24 
      A = [8 841 6.5703];
    case 25 
      A = [8 885 6.9141];
    case 26 
      A = [8 916.5 7.1602];
    case 27 
      A = [8 948 7.4063];
  end
else
  error('Invalid MCS index table number (TS 38.214 Table 5.1.3.1-1/2)');
end

Q_m = A(1);
R = A(2) / 1024;
se = A(3);

end