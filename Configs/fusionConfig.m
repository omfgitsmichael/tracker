function paramsFusion = fusionConfig()
paramsFusion.trackID = 0;

% Correlator Params %
paramsFusion.correlator.assign = 'auction';
paramsFusion.correlator.defaultCost = 1000;
paramsFusion.correlator.errorGate = 5 * pi / 180;
paramsFusion.correlator.chi2Gate = 16;
paramsFusion.correlator.epsilon = 0.1;

% Update Params %
paramsFusion.update.initializeTrack = false;

paramsFusion.update.initialize = 'cartesianInit9State';
paramsFusion.update.initializeParams.FOV = 40 * pi / 180;
paramsFusion.update.initializeParams.minRange = 10000;
paramsFusion.update.initializeParams.maxRange = 225000;
paramsFusion.update.initializeParams.maxVelocity = 400;
paramsFusion.update.initializeParams.maxAcceleration = 10;
paramsFusion.update.initializeParams.sigmaAz = 0.25 * pi / 180;
paramsFusion.update.initializeParams.sigmaEl = 0.25 * pi / 180;
paramsFusion.update.initializeParams.sigmaR = 5; % If range is valid
paramsFusion.update.initializeParams.sigmaRDot = 10; % If range rate is valid

paramsFusion.update.update = 'cartesianUpdate9State';
paramsFusion.update.updateParams.rangeParams.sigmaR = paramsFusion.update.initializeParams.sigmaR;
paramsFusion.update.updateParams.rangeRateParams.sigmaRDot = paramsFusion.update.initializeParams.sigmaRDot;
paramsFusion.update.updateParams.azParams.sigmaAz = paramsFusion.update.initializeParams.sigmaAz;
paramsFusion.update.updateParams.elParams.sigmaEl = paramsFusion.update.initializeParams.sigmaEl;

paramsFusion.update.propagate = 'cartesianPropagate9State';
paramsFusion.update.propagateParams.model = 'constantAccelerationModel';
paramsFusion.update.propagateParams.modelParams.processNoise = 2.5;

% Purge Params %
paramsFusion.purge.immaturePurgeTime = 1.0;
paramsFusion.purge.maturePurgeTime = 3.0;
paramsFusion.purge.matureHitCount = 3;

% Reporter Params %
paramsFusion.reporter.matureHitCount = paramsFusion.purge.matureHitCount;
end

