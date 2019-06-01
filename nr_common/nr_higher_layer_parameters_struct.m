%hlp = nr_higher_layer_parameters_struct()
%
% Generates a structure that holds 5G NR higher layer parameters
% defined in 3GPP 38.211-214 standards. The structure is filled
% with default values, which can be modified afterwards.
%
% Returns:
%  hlp - higher layer parameters structure

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function hlp = nr_higher_layer_parameters_struct()
  hlp = struct();

  % 38.211 6.3.1.1
  hlp.Data_scrambling_Identity = 0; % 0 - 1023 

  % 38.211 6.4.1.1
  hlp.UL_DMRS_Scrambling_ID = [0, 0]; % [0 - 1, 0 - 65535] 
  hlp.UL_DMRS_config_type = 1; % 1 or 2
  hlp.UL_DMRS_typeA_pos = 2; % 2 or 3
  hlp.UL_DMRS_add_pos = 0; % 0 - 3
  hlp.UL_DMRS_max_len = 1; % 1 or 2

  % 38.211 6.4.1.2
  hlp.nDMRS_CSH_Identity_Transform_precoding = [0, 0]; % 0 - 1023
  hlp.UL_PTRS_RE_offset = 0; % 0 - 3

  % 38.212 6.2.5
  hlp.LBRM_FBRM_selection = 0; % FBRM = 0, LBRM = 1

  % 38.214 5.1.3
  hlp.MCS_Table_PDSCH = 1; % 1 (64QAM) or 2 (256QAM)

  % 38.214 6.1.4
  hlp.PUSCH_tp = 0; % 0 or 1 
  hlp.MCS_Table_PUSCH = 1; % 1 (64QAM) or 2 (256QAM)
end