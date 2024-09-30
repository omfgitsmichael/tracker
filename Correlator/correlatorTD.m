function [paired, soloTracks, soloDetections] = correlatorTD(params, trackList, detectionList)
% Set all of the incoming tracks and detections to the solo list. We will
% remove the tracks that get paired out from this list.
soloTracks = trackList;
soloDetections = detectionList;

fieldNames{1} = 'track';
fieldNames{2} = 'detection';
fieldNames{2, 1} = {};
paired = struct(fieldNames{:});

% If either of these lists are empty, leave the correlator since there is
% nothing to correlate
if (isempty(soloTracks) || isempty(soloDetections))
    return;
end

% Cost matrix for the assignment algorithm.
cost = ones(numel(soloTracks), numel(soloDetections)) * params.correlator.defaultCost;

% Loop through all of the tracks in the track list.
for i = 1:numel(soloTracks)
    track = soloTracks(i);

    % Loop through all of the tracks in the detection list.
    for j = 1:numel(soloDetections)
        % Check to see if the detection azimuth and elevation are with in a
        % maximum `gate` size. If they are within that gate, then we can 
        % perform a distance test on it.
        detection = soloDetections(j);

        rIst = track.pos - detection.sensor.pos;
        range = norm(rIst);
        uIst = rIst / range;
        uDst = detection.sensor.CI2D * uIst;
        [az, el] = los2azel(uDst);
        
        error = 0;
        if (detection.azValid && detection.elValid)
            azError = detection.azimuth - az;
            elError = detection.elevation - el;
            error = norm([azError; elError]);
        elseif (detection.azValid)
            azError = detection.azimuth - az;
            error = norm(azError);
        elseif (detection.elValid)
            elError = detection.elevation - el;
            error = norm(elError);
        end

        if (error < params.correlator.errorGate)
            % Perform a distance test on each of the detections and the tracks.
            % If the chi2 score is within our distance gate size, then we can
            % add it to the cost matrix. First extrapolate track to
            % detection time.
            track = extrapolate(track, detection.t);
            [~, chi2] = updateTD(params.update, track, detection, true);

            if (chi2 < params.correlator.chi2Gate)
                cost(i, j) = chi2;
            end
        end
    end
end

% Run the assignment algorithm.
if (~isempty(soloTracks))
    assign = str2func(params.correlator.assign);
    assignments = assign(params.correlator, cost, numel(soloTracks), numel(soloDetections));

    % Map the cost matrix to the tracks and detections to create the paired
    % list.
    for i = 1:numel(soloTracks)
        track = soloTracks(i);
        for j = 1:numel(soloDetections)
            detection = soloDetections(j);
            detectionIndex = find(assignments(i, :), 1);
            if ~isempty(detectionIndex) && j == detectionIndex
                pair.track = track;
                pair.detection = detection;
                paired(end + 1) = pair;
                break;
            end
        end
    end
    
    % Removed all of the paired tracks and detections from the solo list.
    trackRemovalIndex = [];
    detectionRemovalIndex = [];
    for i = 1:numel(paired)
        pairedTrack = paired(i).track;
        for j = 1:numel(soloTracks)
            soloTrack = soloTracks(j);
    
            if pairedTrack.trackID == soloTrack.trackID
                trackRemovalIndex(end + 1) = j;
            end
        end
    
        pairedDetection = paired(i).detection;
        for j = 1:numel(soloDetections)
            soloDetection = soloDetections(j);
    
            if pairedDetection.detectionID == soloDetection.detectionID
                detectionRemovalIndex(end + 1) = j;
            end
        end
    end
    
    soloTracks(trackRemovalIndex) = [];
    soloDetections(detectionRemovalIndex) = [];
end
end
