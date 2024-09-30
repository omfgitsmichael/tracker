function paramsTracker = trackerIMMConfig()
% Tracker Params %
paramsTracker.trackID = 0;

% Correlator Params %
paramsTracker.correlator.assign = 'auction';
paramsTracker.correlator.defaultCost = 1000;
paramsTracker.correlator.errorGate = 5 * pi / 180;
paramsTracker.correlator.chi2Gate = 16;
paramsTracker.correlator.epsilon = 0.1;


% IMM Initialization Params %
paramsTracker.update.initializeTrack = false;
paramsTracker.update.initialize = 'immInit';
paramsTracker.update.initializeParams.initialize = 'cartesianInit9State';
paramsTracker.update.initializeParams.baseParams.FOV = 40 * pi / 180;
paramsTracker.update.initializeParams.baseParams.minRange = 10000;
paramsTracker.update.initializeParams.baseParams.maxRange = 225000;
paramsTracker.update.initializeParams.baseParams.maxVelocity = 400;
paramsTracker.update.initializeParams.baseParams.maxAcceleration = 10;
paramsTracker.update.initializeParams.baseParams.sigmaAz = 0.25 * pi / 180;
paramsTracker.update.initializeParams.baseParams.sigmaEl = 0.25 * pi / 180;
paramsTracker.update.initializeParams.baseParams.sigmaR = 5; % If range is valid
paramsTracker.update.initializeParams.baseParams.sigmaRDot = 10; % If range rate is valid
paramsTracker.update.initializeParams.numberFilters = 3;

% IMM Update Params %
paramsTracker.update.update = 'immUpdate';

paramsTracker.update.updateParams.update{1} = 'cartesianUpdate6State';
paramsTracker.update.updateParams.updateParams{1}.rangeParams.sigmaR = paramsTracker.update.initializeParams.baseParams.sigmaR;
paramsTracker.update.updateParams.updateParams{1}.rangeRateParams.sigmaRDot = paramsTracker.update.initializeParams.baseParams.sigmaRDot;
paramsTracker.update.updateParams.updateParams{1}.azParams.sigmaAz = paramsTracker.update.initializeParams.baseParams.sigmaAz;
paramsTracker.update.updateParams.updateParams{1}.elParams.sigmaEl = paramsTracker.update.initializeParams.baseParams.sigmaEl;

paramsTracker.update.updateParams.update{2} = 'cartesianUpdate9State';
paramsTracker.update.updateParams.updateParams{2}.rangeParams.sigmaR = paramsTracker.update.initializeParams.baseParams.sigmaR;
paramsTracker.update.updateParams.updateParams{2}.rangeRateParams.sigmaRDot = paramsTracker.update.initializeParams.baseParams.sigmaRDot;
paramsTracker.update.updateParams.updateParams{2}.azParams.sigmaAz = paramsTracker.update.initializeParams.baseParams.sigmaAz;
paramsTracker.update.updateParams.updateParams{2}.elParams.sigmaEl = paramsTracker.update.initializeParams.baseParams.sigmaEl;

paramsTracker.update.updateParams.update{3} = 'cartesianUpdate9State';
paramsTracker.update.updateParams.updateParams{3}.rangeParams.sigmaR = paramsTracker.update.initializeParams.baseParams.sigmaR;
paramsTracker.update.updateParams.updateParams{3}.rangeRateParams.sigmaRDot = paramsTracker.update.initializeParams.baseParams.sigmaRDot;
paramsTracker.update.updateParams.updateParams{3}.azParams.sigmaAz = paramsTracker.update.initializeParams.baseParams.sigmaAz;
paramsTracker.update.updateParams.updateParams{3}.elParams.sigmaEl = paramsTracker.update.initializeParams.baseParams.sigmaEl;

% IMM Propagate Params %
paramsTracker.update.propagate = 'immPropagate';
paramsTracker.update.propagateParams.flowMatrix = [-0.25 0.15 0.1; 0.15 -0.25 0.1; 0.4 0.2 -0.6]; % Needs to be N x N (N = number of models)

paramsTracker.update.propagateParams.propagate{1} = 'cartesianPropagate6State';
paramsTracker.update.propagateParams.propagateParams{1}.model = 'constantVelocityModel';
paramsTracker.update.propagateParams.propagateParams{1}.modelParams.processNoise = 1.0;

paramsTracker.update.propagateParams.propagate{2} = 'cartesianPropagate9State';
paramsTracker.update.propagateParams.propagateParams{2}.model = 'constantAccelerationModel';
paramsTracker.update.propagateParams.propagateParams{2}.modelParams.processNoise = 100.0;

paramsTracker.update.propagateParams.propagate{3} = 'cartesianPropagate9State';
paramsTracker.update.propagateParams.propagateParams{3}.model = 'turnModel';
paramsTracker.update.propagateParams.propagateParams{3}.modelParams.processNoise = 25.0;

% Purge Params %
paramsTracker.purge.immaturePurgeTime = 1.0;
paramsTracker.purge.maturePurgeTime = 3.0;
paramsTracker.purge.matureHitCount = 3;

% Reporter Params %
paramsTracker.reporter.matureHitCount = paramsTracker.purge.matureHitCount;
end

