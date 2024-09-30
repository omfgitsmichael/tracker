function paramsTracker = trackerCartesianConfig()
% Tracker Params %
paramsTracker.trackID = 0;

% Correlator Params %
paramsTracker.correlator.assign = 'auction';
paramsTracker.correlator.defaultCost = 1000;
paramsTracker.correlator.errorGate = 5 * pi / 180;
paramsTracker.correlator.chi2Gate = 16;
paramsTracker.correlator.epsilon = 0.1;

% Update Params %
paramsTracker.update.initializeTrack = false;

paramsTracker.update.initialize = 'cartesianInit9State';
paramsTracker.update.initializeParams.FOV = 40 * pi / 180;
paramsTracker.update.initializeParams.minRange = 10000;
paramsTracker.update.initializeParams.maxRange = 225000;
paramsTracker.update.initializeParams.maxVelocity = 400;
paramsTracker.update.initializeParams.maxAcceleration = 10;
paramsTracker.update.initializeParams.sigmaAz = 0.25 * pi / 180;
paramsTracker.update.initializeParams.sigmaEl = 0.25 * pi / 180;
paramsTracker.update.initializeParams.sigmaR = 5; % If range is valid
paramsTracker.update.initializeParams.sigmaRDot = 10; % If range rate is valid

paramsTracker.update.update = 'cartesianUpdate9State';
paramsTracker.update.updateParams.rangeParams.sigmaR = paramsTracker.update.initializeParams.sigmaR;
paramsTracker.update.updateParams.rangeRateParams.sigmaRDot = paramsTracker.update.initializeParams.sigmaRDot;
paramsTracker.update.updateParams.azParams.sigmaAz = paramsTracker.update.initializeParams.sigmaAz;
paramsTracker.update.updateParams.elParams.sigmaEl = paramsTracker.update.initializeParams.sigmaEl;

paramsTracker.update.propagate = 'cartesianPropagate9State';
paramsTracker.update.propagateParams.model = 'constantAccelerationModel';
paramsTracker.update.propagateParams.modelParams.processNoise = 5.0;

% Purge Params %
paramsTracker.purge.immaturePurgeTime = 1.0;
paramsTracker.purge.maturePurgeTime = 3.0;
paramsTracker.purge.matureHitCount = 3;

% Reporter Params %
paramsTracker.reporter.matureHitCount = paramsTracker.purge.matureHitCount;
end

