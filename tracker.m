function [params, trackList, trackDatabase] = tracker(params, trackDatabase, detectionList, time)
trackList = trackType();

% Correlator algorithm (association and assignment algorithms) between
% current tracks and incoming detections. Correlator algorithm should
% provide a solo track list, a solo detection list, and a list of paired
% tracks and detections.
[pairedList, soloTrackList, soloDetectionList] = correlatorTD(params, trackDatabase, detectionList);

% Update algorithm (Kalman Filter tracker algorithm) for the associated
% tracks.
for i = 1:length(pairedList)
    [track, ~] = updateTD(params.update, pairedList(i).track, pairedList(i).detection, false);
    trackList(end + 1) = track;
end

% Create new tracks for all of the detections that did not associate with a
% track.
params.update.initializeTrack = true;
for i = 1:length(soloDetectionList)
    params.trackID = params.trackID + 1;
    newTrack = trackType();
    newTrack(1).trackID = params.trackID;

    [newTrack, ~] = updateTD(params.update, newTrack, soloDetectionList(i), false);
    trackList(end + 1) = newTrack;
end
params.update.initializeTrack = false;

% Purge all of the expired tracks from the solo track list.
remainingTracks = purge(params.purge, soloTrackList, time);
if ~isempty(remainingTracks)
    for i = 1:numel(remainingTracks)
        trackList(end + 1) = remainingTracks(i);
    end
end

% Set the tracks in the data base equal to all of the output tracks prior
% to running the discriminator and reporter algorithms
trackDatabase = trackList;

% Discriminate/report all of the tracks that should be output from the
% tracker algorithm.
trackList = reporter(params.reporter, trackList);
end
