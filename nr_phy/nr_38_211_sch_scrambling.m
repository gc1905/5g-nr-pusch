%bs = nr_38_211_sch_scrambling(b, n_rnti, n_ID, q=0)
%
% Symmetric scrambler/descrambler for PDSCH/PUSCH channel
% as specified by 3GPP 38.211 sec. 6.3.1.1 and 7.3.1.1.
% Can be used for both scrambling or descrambling.
% For uplink, set q = 0.
%
% Arguments:
%  b       - vector of bits or LLRs (in case of descrambling)
%  n_rnti  - RNTI identifier of the UE
%  n_ID    - data scrambling identity
%  q       - set to 1 for the second codeword, 0 otherwise
%
% Returns:
%  bs      - vector of scrambed bits (or LLR values)

% Copyright 2018 Grzegorz Cisek (grzegorzcisek@gmail.com)

function bs = nr_38_211_sch_scrambling(b, n_rnti, n_ID, q)
  if nargin < 4
    q = 0;
  else
    assert(ismember(q, [0,1]), 'q may be 0 or 1 only');
  end

  c_init = n_rnti * 2^15 + q * 2^14 + n_ID;
  c = reshape(gold31seq(c_init, length(b)), size(b));

  if all(ismember(b, [0 1]))
    % binary input
    bs = mod(b + c, 2);
  else
    % soft-decision input
    cs = zeros(size(b));
    cs(c == 1) = -1;
    cs(c == 0) = 1;
    bs = b .* cs;
  end
end