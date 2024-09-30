function trackListOut = reporter(params, trackList)
% Report only the `mature` tracks that have received the required number of
% detections.
trackListOut = trackType;
for i = 1:numel(trackList)
    if (trackList(i).hitCount > params.matureHitCount)
        trackListOut(end + 1) = trackList(i);
    end
end
end
