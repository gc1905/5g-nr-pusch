%l = nr_38_211_sch_dmrs_positions(symbols_sched, config_type, add_pos, dmrs_symbols, 
%                                 typeA_pos=2)
%
% Returns a vector of PUSCH/PDSCH DMRS symbol position in a slot based on 
% 3GPP 38.211 Table 7.4.1.1.2-3 and 7.4.1.1.2-4.
%
% Arguments:
%  symbols_sched   - duration of PDSCH/PUSCH allcoation in symbols
%  config_type     - PDSCH mapping type (1 = A, 2 = B)
%  add_pos         - parameter dmrs-AdditionalPosition
%  dmrs_symbols    - number of consecutive DMRS symbols (1 - single, 2 - double)
%  typeA_pos       - parameter dmrs-TypeA-Position, valid only for config_type = 1,
%                    can be set to 2 or 3
%
% Returns:
%  l               - vector of DMRS symbol indices in slot (zero-based) 

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function l = nr_38_211_sch_dmrs_positions(symbols_sched, config_type, add_pos, dmrs_symbols, typeA_pos)
  if nargin < 5; typeA_pos = 2; end

  if dmrs_symbols == 1
    if config_type == 1
      if add_pos == 3 && typeA_pos ~= 2 
        error('The case UL-DMRS-add-pos equal to 3 is only supported when UL-DMRS-typeA-pos is equal to 2');
      end
      DMRS_pos = {
        {typeA_pos, typeA_pos, typeA_pos, typeA_pos, typeA_pos, typeA_pos, typeA_pos, typeA_pos}, 
        {-1, -1, [typeA_pos,7], [typeA_pos,9], [typeA_pos,9], [typeA_pos,9], [typeA_pos,11], [typeA_pos,11]}, 
        {-1, -1, -1, [typeA_pos,6,9], [typeA_pos,6,9], [typeA_pos,6,9], [typeA_pos,7,11], [typeA_pos,7,11]}, 
        {-1, -1, -1, -1, -1, [typeA_pos,5,8,11], [typeA_pos,5,8,11], [typeA_pos,5,8,11]}};
    elseif config_type == 2
      DMRS_pos = {
        {0, 0, 0, 0, 0, 0, 0, -1}, 
        {[0,4], [0,6], [0,6], [0,8], [0,8], [0,10], [0,10], -1}, 
        {-1, [0,3,6], [0,3,6], [0,4,8], [0,4,8], [0,5,10], [0,5,10], -1}, 
        {-1, -1, -1, [0,3,6,9], [0,3,6,9], [0,3,6,9], [0,3,6,9], -1}};
    else
      error('config type must be 1 or 2');
    end
  elseif dmrs_symbols == 2
    if config_type == 1
      DMRS_pos = {
        {typeA_pos, typeA_pos, typeA_pos, typeA_pos, typeA_pos, typeA_pos, typeA_pos, typeA_pos},
        {-1, -1, -1, [typeA_pos,8], [typeA_pos,8], [typeA_pos,8], [typeA_pos,10], [typeA_pos,10]},
        {-1, -1, -1, -1, -1, -1, -1, -1},
        {-1, -1, -1, -1, -1, -1, -1, -1}};
    elseif config_type == 2
      DMRS_pos = {
        {0, 0, 0, 0, 0, 0, 0, -1},
        {-1, [0,5], [0,5], [0,7], [0,7], [0,9], -1, -1},
        {-1, -1, -1, -1, -1, -1, -1, -1},
        {-1, -1, -1, -1, -1, -1, -1, -1}};
    else
      error('config type must be 1 or 2');
    end
  else
    error('DMRS can be 1 or 2 symbols long only');
  end

  if symbols_sched <= 7
    dur_idx = 1;
  else
    dur_idx = symbols_sched - 6;
  end

  l = DMRS_pos{add_pos+1}{dur_idx};

  if l == -1
    error('invalid configuration (dmrs_symbols=%d, config_type=%d, add_pos=%d, symbols_sched=%d)', dmrs_symbols, config_type, add_pos, symbols_sched);
  end
end