function [paired, soloTracks, soloIncomingTracks] = correlatorTT(params, trackList, incomingTrackList)
% Set all of the incoming tracks and detections to the solo list. We will
% remove the tracks that get paired out from this list.
soloTracks = trackList;
soloIncomingTracks = incomingTrackList;

fieldNames{1} = 'track';
fieldNames{2} = 'incomingTrack';
fieldNames{2, 1} = {};
paired = struct(fieldNames{:});

% If either of these lists are empty, leave the correlator since there is
% nothing to correlate
if (isempty(soloTracks) || isempty(incomingTrackList))
    return;
end

% First find the most recently updated track and extrapolate all tracks to
% that time, so all tracks are at a common time when correlating.
extrapolationTime = 0;
for i = 1:numel(soloTracks)
    extrapolationTime = max(extrapolationTime, soloTracks(i).t);
end

for i = 1:numel(incomingTrackList)
    extrapolationTime = max(extrapolationTime, incomingTrackList(i).t);
end

for i = 1:numel(soloTracks)
    soloTracks(i) = extrapolate(soloTracks(i), extrapolationTime);
end

for i = 1:numel(incomingTrackList)
    incomingTrackList(i) = extrapolate(incomingTrackList(i), extrapolationTime);
end

% Cost matrix for the assignment algorithm.
cost = ones(numel(soloTracks), numel(soloIncomingTracks)) * params.correlator.defaultCost;

% Loop through all of the tracks in the track list.
for i = 1:numel(soloTracks)
    track = soloTracks(i);

    % Loop through all of the tracks in the incoming track list.
    for j = 1:numel(soloIncomingTracks)
        incomingTrack = soloIncomingTracks(j);

        % Perform a distance test on each of the incoming tracks and the
        % current tracks. If the chi2 score is within our distance gate
        % size, then we can add it to the cost matrix.
        [~, chi2] = updateTT(params.update, track, incomingTrack, true);

        if (chi2 < params.correlator.chi2Gate)
            cost(i, j) = chi2;
        end
    end
end

% Run the assignment algorithm.
if (~isempty(soloTracks))
    assign = str2func(params.correlator.assign);
    assignments = assign(params.correlator, cost, numel(soloTracks), numel(soloIncomingTracks));

    % Map the cost matrix to the tracks and incoming tracks to create the
    % paired list.
    for i = 1:numel(soloTracks)
        track = soloTracks(i);
        for j = 1:numel(soloIncomingTracks)
            incomingTrack = soloIncomingTracks(j);
            detectionIndex = find(assignments(i, :), 1);
            if ~isempty(detectionIndex) && j == detectionIndex
                pair.track = track;
                pair.incomingTrack = incomingTrack;
                paired(end + 1) = pair;
                break;
            end
        end
    end
    
    % Removed all of the paired tracks and incoming track from the solo lists.
    trackRemovalIndex = [];
    incomingRemovalIndex = [];
    for i = 1:numel(paired)
        pairedTrack = paired(i).track;
        for j = 1:numel(soloTracks)
            tempTrack = soloTracks(j);
    
            if pairedTrack.trackID == tempTrack.trackID
                trackRemovalIndex(end + 1) = j;
            end
        end
    
        pairedIncoming = paired(i).incomingTrack;
        for j = 1:numel(soloIncomingTracks)
            tempTrack = soloIncomingTracks(j);
    
            if pairedIncoming.trackID == tempTrack.trackID
                incomingRemovalIndex(end + 1) = j;
            end
        end
    end
    
    soloTracks(trackRemovalIndex) = [];
    soloIncomingTracks(incomingRemovalIndex) = [];
end
end
