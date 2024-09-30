function [track, chi2] = updateTD(params, track, detection, distanceTest)
if (params.initializeTrack && ~distanceTest)
    initialize = str2func(params.initialize);
    track = initialize(params.initializeParams, track, detection);
    chi2 = 0;
else
    % Propagate the track to the detection in a temporary track in case we are
    % running a distance test
    propagate = str2func(params.propagate);
    tempTrack = propagate(params.propagateParams, track, detection);
    
    % Update the temporary trackacs
    update = str2func(params.update);
    [tempTrack, chi2, ~] = update(params.updateParams, tempTrack, detection, distanceTest);
    
    if (distanceTest)
        return;
    end
    
    % If we are not running a distance test then set the temporary track equal
    % to the track so we can update it
    track = tempTrack;
end
end
