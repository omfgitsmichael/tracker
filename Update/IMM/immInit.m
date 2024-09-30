function track = immInit(params, track, detection)
% Initialize IMM tracks using a base initialization function
initialize = str2func(params.initialize);
track = initialize(params.baseParams, track, detection);

N = params.numberFilters;

% Set all of the likelihood weights equal to each other upon initialization
track.imm.weights(1:N) = 1 / N;

% Create local tracks within the high level track for each of the imm
% models
track.imm.models(1:N) = track;
end
