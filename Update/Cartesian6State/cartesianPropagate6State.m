function trackOutput = cartesianPropagate6State(params, track, detection)
dt = detection.t - track.t;

trackOutput = track;

% Turn off accel states if handed a 9 state track
trackOutput.accel = [0.0; 0.0; 0.0];
trackOutput.P(1:9, 7:9) = zeros(9,3);
trackOutput.P(7:9, 1:9) = zeros(3,9);

xVec(1:3,1) = trackOutput.pos;
xVec(4:6,1) = trackOutput.vel;

% Will only work with the constant velocity model.
model = str2func(params.model);
[F, Q] = model(params.modelParams, dt, xVec);

xVec = F * xVec;

trackOutput.pos = xVec(1:3);
trackOutput.vel = xVec(4:6);

P = trackOutput.P(1:6, 1:6);

P = F * P * F' + Q;

trackOutput.P(1:6, 1:6) = P;
end
