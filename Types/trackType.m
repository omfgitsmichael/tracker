function track = trackType()
% Track Field Names %
trackFieldNames{1} = 'trackID';
trackFieldNames{2} = 'pos';
trackFieldNames{3} = 'vel';
trackFieldNames{4} = 'accel';
trackFieldNames{5} = 'P';
trackFieldNames{6} = 't';
trackFieldNames{7} = 'hitCount';
trackFieldNames{8} = 'detection';
trackFieldNames{9} = 'contributors';
trackFieldNames{10} = 'imm';
trackFieldNames{2, 1} = {};
track = struct(trackFieldNames{:});
end

