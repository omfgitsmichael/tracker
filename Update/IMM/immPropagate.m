function trackOutput = immPropagate(params, track, detection)
trackOutput = track;
dt = detection.t - track.t;
N = length(track.imm.models);

% Create the mixing matrix via a flow matrix and dt to create a probability
% of transitioning models based off time
flowMatrix = params.flowMatrix;
mixingMatrix = expm(flowMatrix * dt);

% weightsTemp = zeros(1, N); % Is this needed?
modelsTemp = track.imm.models;

% Loop through each of the internal models and propagate them
for i = 1:N
    % Calculate the mixed likelihood weights for propagation for this model
    denominator = 0;
    for j = 1:N
        denominator = denominator + track.imm.weights(j) * mixingMatrix(j, i);
    end

    mixedWeights = zeros(1, N);
    for j = 1:N
        mixedWeights(j) = track.imm.weights(j) * mixingMatrix(j, i) / denominator;
    end

    % Mix the states prior to propagating
    [x, P] = immMixture(mixedWeights, track.imm.models);

    % Temp track to propagate
    tempTrack = track.imm.models(i);
    tempTrack.P = P;
    tempTrack.pos = x(1:3);
    tempTrack.vel = x(4:6);
    tempTrack.accel = x(7:9);

    % Propagate the temporary track
    propagate = str2func(params.propagate{i});
    modelsTemp(i) = propagate(params.propagateParams{i}, tempTrack, detection);
    % weightsTemp(i) = denominator; % ???
end

% trackOutput.imm.weights = weightsTemp; % I don't think this is correct ????
trackOutput.imm.models = modelsTemp;

% Mix the states again to set the propagated `outer` track. Can be skipped
% if immediately performing the IMM update afterward.
[x, P] = immMixture(trackOutput.imm.weights, trackOutput.imm.models);
trackOutput.P = P;
trackOutput.pos = x(1:3);
trackOutput.vel = x(4:6);
trackOutput.accel = x(7:9);
end
