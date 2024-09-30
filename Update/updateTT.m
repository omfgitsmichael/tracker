function [track, chi2] = updateTT(params, track, incomingTrack, distanceTest)
% Extrapolate the track to the incoming track time in a temporary track in
% case we are running a distance test
tempTrack = extrapolate(track, incomingTrack.t);
chi2 = 0;

% Compute a chi2 based off position only
if (distanceTest)
    residual = incomingTrack.pos - tempTrack.pos;
    H = eye(3);
    P = tempTrack.P(1:3, 1:3);
    R = incomingTrack.P(1:3, 1:3);

    S = H * P * H' + R;
    chi2 = residual' * S^-1 * residual;

    return;
end

% Update the temporary track via track to track Kalman filter update
H = eye(9);
P = tempTrack.P;
R = incomingTrack.P;

S = H * P * H' + R;
K = P * H' * S^-1;

% Update the track states 
xVec(1:3, 1) = tempTrack.pos;
xVec(4:6, 1) = tempTrack.vel;
xVec(7:9, 1) = tempTrack.accel;

xVecIncoming(1:3, 1) = incomingTrack.pos;
xVecIncoming(4:6, 1) = incomingTrack.vel;
xVecIncoming(7:9, 1) = incomingTrack.accel;

% Update the states based off the residual of all states
residual = xVecIncoming - xVec;
xVec = xVec + K * residual;

I = eye(9);
tempTrack.P = (I - K * H) * P * (I - K * H)' + K * R * K'; % Joseph formulation

tempTrack.pos = xVec(1:3);
tempTrack.vel = xVec(4:6);
tempTrack.accel = xVec(7:9);

% If we are not running a distance test then set the temporary track equal
% to the track so we can update it
track = tempTrack;
end
