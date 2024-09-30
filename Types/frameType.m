function frame = frameType()
% Frame Field Names %
frameFieldNames{1} = 'sensorID';
frameFieldNames{2} = 'trackList';
frameFieldNames{2, 1} = {};
frame = struct(frameFieldNames{:});
end

