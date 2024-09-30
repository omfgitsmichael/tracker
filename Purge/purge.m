function trackList = purge(params, trackList, time)
% Loop through all of the tracks in the list.
purgeIndex = [];

for i = 1:numel(trackList)
    track = trackList(i);
    dt = time - track.t;
    if (track.hitCount < params.matureHitCount && dt > params.immaturePurgeTime) ...
            || (track.hitCount >= params.matureHitCount && dt > params.maturePurgeTime)
        % If the track has not `matured` and we have not updated recently,
        % purge this track, or if the track has `matured` and we have not
        % updated recently, purge this track.
        purgeIndex(end + 1) = i;
    end
end

trackList(purgeIndex) = [];
end
