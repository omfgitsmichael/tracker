function [track, chi2, likelihood] = cartesianUpdate6State(params, track, detection, distanceTest)
% The cartesian coordinate kalman filter update function for the target
% tracker. The track should be propagated to the time of the detection
% prior to entering this function.
chi2 = 0;
likelihood = 1;
if (detection.rangeValid)
    [track, chi2Temp, likelihoodTemp] = cartesianUpdateRange(params.rangeParams, track, detection.sensor, detection.range, distanceTest);
    chi2 = chi2 + chi2Temp;
    likelihood = likelihood * likelihoodTemp;
end

if (detection.rangeRateValid)
    [track, chi2Temp, likelihoodTemp] = cartesianUpdateRangeRate(params.rangeRateParams, track, detection.sensor, detection.rangeRate, distanceTest);
    chi2 = chi2 + chi2Temp;
    likelihood = likelihood * likelihoodTemp;
end

if (detection.azValid)
    [track, chi2Temp, likelihoodTemp] = cartesianUpdateAzimuth(params.azParams, track, detection.sensor, detection.azimuth, distanceTest);
    chi2 = chi2 + chi2Temp;
    likelihood = likelihood * likelihoodTemp;
end

if (detection.elValid)
    [track, chi2Temp, likelihoodTemp] = cartesianUpdateElevation(params.elParams, track, detection.sensor, detection.elevation, distanceTest);
    chi2 = chi2 + chi2Temp;
    likelihood = likelihood * likelihoodTemp;
end

% Update the extra track info to the if we had received a valid detection
% and are not running a distance test
if ((detection.azValid || detection.elValid || detection.rangeValid) && ~distanceTest)
    track.t = detection.t;
    track.hitCount = track.hitCount + 1;
    track.detection = detection;
end

end

function [track, chi2, likelihood] = cartesianUpdateCalculation(H, residual, R, track, distanceTest)
xVec(1:3, 1) = track.pos;
xVec(4:6, 1) = track.vel;

P = track.P(1:6, 1:6);

S = H * P * H' + R;
K = P * H' * S^-1;

chi2 = residual' * S^-1 * residual;

likelihood = exp(-0.5 * chi2) / sqrt(det(2 * pi * S));

if (distanceTest)
    return;
end

xVec = xVec + K * residual;

I = eye(6);
track.P(1:6, 1:6) = (I - K * H) * P * (I - K * H)' + K * R * K'; % Joseph formulation

track.pos = xVec(1:3);
track.vel = xVec(4:6);
end

function [track, chi2, likelihood] = cartesianUpdateRange(params, track, sensor, rangeMeasurement, distanceTest)
rIst = track.pos - sensor.pos;
range = norm(rIst);

% Jacobian of the range measurement in the inertial frame is the
% unit vector (range = range regardless of which frame we are in):
%                     d   
%                H = -- r
%                    dx
H(1, 1:3) = rIst / range;
H(1, 4:6) = 0;

residual = rangeMeasurement - range;
R = params.sigmaR * params.sigmaR;

% Update the track estimate off the range measurement if it is
% valid
[track, chi2, likelihood] = cartesianUpdateCalculation(H, residual, R, track, distanceTest);
end

function [track, chi2, likelihood] = cartesianUpdateRangeRate(params, track, sensor, rangeRateMeasurement, distanceTest)
rIst = track.pos - sensor.pos;
range = norm(rIst);
uIst = rIst / range;

vIst = track.vel - sensor.vel;
rangeRate = vIst' * uIst;

% Jacobian of the range measurement in the inertial frame is the
% unit vector (range = range regardless of which frame we are in):
%                     d   
%                H = -- rDot
%                    dx
H(1, 1:3) = vIst' * (eye(3) - uIst * uIst') / range;
H(1, 4:6) = uIst';

residual = rangeRateMeasurement - rangeRate;
R = params.sigmaRDot * params.sigmaRDot;

% Update the track estimate off the range measurement if it is
% valid
[track, chi2, likelihood] = cartesianUpdateCalculation(H, residual, R, track, distanceTest);
end

function [track, chi2, likelihood] = cartesianUpdateAzimuth(params, track, sensor, azimuthMeasurement, distanceTest)
CI2D = sensor.CI2D;
rIst = track.pos - sensor.pos;
rDst = CI2D * rIst;
sqrtxy = sqrt(rDst(1)^2 + rDst(2)^2);

% Jacobian of the azimuth measurement in the detector frame into
% the inertial frame:
%            d         C_21 * xi + C_22 * yi + C_23 * zi
%       H = --  arctan(---------------------------------)
%           dx         C_11 * xi + C_12 * yi + C_13 * zi
H(1, 1:3) = (rDst(1) * CI2D(2, :) - rDst(2) * CI2D(1, :)) / (sqrtxy * sqrtxy);
H(1, 4:6) = 0;

azimuth = atan2(rDst(2), rDst(1));
residual = azimuthMeasurement - azimuth;
R = params.sigmaAz * params.sigmaAz;

% Update the track estimate off the azimuth measurement if it is
% valid
[track, chi2, likelihood] = cartesianUpdateCalculation(H, residual, R, track, distanceTest);
end

function [track, chi2, likelihood] = cartesianUpdateElevation(params, track, sensor, elevationMeasurement, distanceTest)
CI2D = sensor.CI2D;
rIst = track.pos - sensor.pos;
range = norm(rIst);
rDst = CI2D * rIst;
uIst = rIst / range;
sqrtxy = sqrt(rDst(1)^2 + rDst(2)^2);

% Jacobian of the elevation measurement in the detector frame into
% the inertial frame:
%       d                                -C_31 * xi + C_32 * yi + C_33 * zi
%  H = --  arctan(----------------------------------------------------------------------------------)
%      dx         sqrt((C_11 * xi + C_12 * yi + C_13 * zi)^2 + (C_21 * xi + C_22 * yi + C_23 * zi)^2) 
H(1, 1:3) = (rDst(3) * uIst' - range * CI2D(3, :)) / (sqrtxy * range);
H(1, 4:6) = 0;

elevation = atan2(-rDst(3), sqrtxy); % Alternatively -sin(rDst(3) / range);
residual = elevationMeasurement - elevation;
R = params.sigmaEl * params.sigmaEl;

% Update the track estimate off the elevation measurement if it is
% valid
[track, chi2, likelihood] = cartesianUpdateCalculation(H, residual, R, track, distanceTest);
end
