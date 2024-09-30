function [track, chi2, likelihood] = immUpdate(params, track, detection, distanceTest)
N = length(track.imm.models);
chi2Temp = zeros(N, 1);
tempWeights = track.imm.weights;

% Loop through each of the IMM models and update each of them individually
for i = 1:N
    update = str2func(params.update{i});
    [track.imm.models(i), chi2Temp(i), likelihood] = ...
        update(params.updateParams{i}, track.imm.models(i), detection, distanceTest);

    tempWeights(i) = tempWeights(i) * likelihood;
end

% Normalize the updated likelihood weights
tempWeights = tempWeights / sum(tempWeights);

chi2 = tempWeights * chi2Temp; % Mix the chi2 from the various models
likelihood = 1; % Don't need to return a likelihood here, so just return 1

% Return before updating the track if we were only running a distance test
if (distanceTest)
    return;
end

% Update the `outer` track state if we aren't running a distance test
track.imm.weights = tempWeights;
[x, P] = immMixture(track.imm.weights, track.imm.models);

track.P = P;
track.pos = x(1:3);
track.vel = x(4:6);
track.accel = x(7:9);

track.t = detection.t;
track.hitCount = track.hitCount + 1;
track.detection = detection;
end
