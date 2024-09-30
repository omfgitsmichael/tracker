function [params, frameDatabase, FusedListOut] = fusion(params, frameDatabase, fusedList, incomingFrames, time)
% Loop through each of the incoming tracklists from each of the incoming
% sensors
for i = 1:numel(incomingFrames)
    tempFusedList = trackType();

    % Grab this sensor in the database to have a sensor history
    sensorID = incomingFrames{i}.sensorID;
    sensorFound = false;
    for j = 1:numel(frameDatabase)
        databaseID = frameDatabase{j}.sensorID;
        if (databaseID == sensorID)
            frameIndex = j;
            sensorFound = true;
            break;
        end
    end

    if (~sensorFound)
        frameDatabase{end + 1}.sensorID = incomingFrames{i}.sensorID;
        frameDatabase{end}.trackList = trackType();
        frameIndex = numel(frameDatabase);
    end

    sensorHistory = frameDatabase{frameIndex};

    % Correlator algorithm (association and assignment algorithms) between
    % current fused tracks and incoming tracks. Correlator algorithm should
    % provide a solo track list, a solo detection list, and a list of
    % paired tracks
    [pairedList, soloFusedList, soloTrackList] = ...
        correlatorTT(params, fusedList, incomingFrames{i}.trackList);

    % Update algorithm (Kalman Filter tracker algorithm) for the associated
    % track pairs
    for j = 1:length(pairedList)
        % Check to see if we have this incoming track in the sensor
        % database
        trackFound = false;
        for k = 1:numel(sensorHistory.trackList)
            if sensorHistory.trackList(k).trackID == pairedList(j).incomingTrack.trackID
                trackIndex = k;
                trackFound = true;
                break;
            end
        end

        if (trackFound)
            % If the fused track corralated with itself, then we will do a
            % full state replacement
            if numel(pairedList(j).track.contributors) == 1 && ...
                pairedList(j).track.contributors.sensorID == sensorID
                trackID = pairedList(j).track.trackID;
                tempFusedList(end + 1) = pairedList(j).incomingTrack;
                tempFusedList(end).trackID = trackID;
            else
                % Set the fused track to the original track, we will update
                % it if the incoming track has a larger hit count than the
                % tracks history
                tempFusedList(end + 1) = pairedList(j).track;

                % The fused track correlated with another track. Do
                % track-to-detection kalman filter update (if the incoming 
                % track was previously updated)
                if pairedList(j).incomingTrack.hitCount > sensorHistory.trackList(trackIndex).hitCount
                    [track, ~] = updateTD(params.update, pairedList(j).track, pairedList(j).incomingTrack.detection, false);
                    tempFusedList(end) = track;
                end
            end
        else
            % We have not seen this track before
            % Update the tracks via track-to-track Kalman Filter
            [track, ~] = updateTT(params.update, pairedList(j).track, pairedList(j).incomingTrack, false);
            tempFusedList(end + 1) = track;
        end

        % Update the sensor history with this incoming paired track
        if trackFound
            sensorHistory.trackList(trackIndex) = pairedList(j).incomingTrack;
        else 
            sensorHistory.trackList(end + 1) = pairedList(j).incomingTrack;
        end

        % Update the contributor list with the new incoming paired track
        trackIDFound = false;
        for k = 1:numel(tempFusedList(end).contributors)
            tempSensorID = tempFusedList(end).contributors(k).sensorID;
            tempTrackID = tempFusedList(end).contributors(k).trackID;

            if (tempSensorID == sensorID && tempTrackID == pairedList(j).incomingTrack.trackID)
                trackIDFound = true;
                break;
            end
        end

        % We only need to add this track to the list if we did not already
        % have it
        if (~trackIDFound)
            tempFusedList(end).contributors(end + 1).sensorID = sensorID;
            tempFusedList(end).contributors(end).trackID = pairedList(j).incomingTrack.trackID;
        end
    end

    % Purge all of the expired tracks from the solo fused list and add the
    % remaining tracks to the fused list output
    remainingTracks = purge(params.purge, soloFusedList, time);
    if ~isempty(remainingTracks)
        for j = 1:numel(remainingTracks)
            tempFusedList(end + 1) = remainingTracks(j);
        end
    end

    % Initialize tracks from uncorrelated (solo) tracks and tracks to the
    % sensor history
    for j = 1:numel(soloTrackList)
        params.trackID = params.trackID + 1;
        tempFusedList(end + 1) = soloTrackList(j);
        tempFusedList(end).trackID = params.trackID;
        tempFusedList(end).contributors(1).sensorID = sensorID;
        tempFusedList(end).contributors(1).trackID = soloTrackList(j).trackID;

        sensorHistory.trackList(end + 1) = soloTrackList(j);
    end

    % Purge all of the expired tracks from the track database
    sensorHistory.trackList = purge(params.purge, sensorHistory.trackList, time);

    % Discriminate/report all of the tracks that should be output from the
    % tracker algorithm.

    % Set the fused list to be the output fused list for the next loop %
    frameDatabase{frameIndex} = sensorHistory;
    fusedList = tempFusedList;
end

FusedListOut = fusedList;
end
