function track = cartesianInit3State(params, track, detection)
% Calculate the rotation from the inertial frame to the target LOS %
CI2T = detection.sensor.CI2D;
azSigma = params.FOV / 6;
elSigma = params.FOV / 6;

if (detection.azValid && detection.elValid)
    CD2T = eulerRotationMatrix('321', [detection.azimuth; detection.elevation; 0.0]);
    CI2T = CD2T * detection.sensor.CI2D;

    azSigma = params.sigmaAz;
    elSigma = params.sigmaEl;
end

range = params.minRange + 0.5 * (params.maxRange - params.minRange);
rSigma = params.maxRange / 6;
if (detection.rangeValid)
    range = detection.range;
    rSigma = params.sigmaR;
end

rTst = [range; 0; 0];

% Initialize the track position %
track.pos = CI2T' * rTst + detection.sensor.pos;
track.vel = [0.0; 0.0; 0.0];
track.accel = [0.0; 0.0; 0.0];

% Initial uncertainty from the detections are in a spherical coordinate
% frame and need to be rotated into a cartesian coordinate frame.
P = zeros(9);
P(1, 1) = (rSigma / (range * range)) * (rSigma / (range * range));
P(2, 2) = azSigma * azSigma;
P(3, 3) = elSigma * elSigma;

temp = diag([range * range; range; range]);
F = CI2T' * temp;

P(1:3, 1:3) = F * P(1:3, 1:3) * F';

track.P = P;

% Set miscellaneous track data %
track.t = detection.t;
track.hitCount = 1;
track.detection = detection;
end
