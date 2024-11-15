function trackOutput = cartesianPropagate3State(params, track, detection)
dt = detection.t - track.t;

trackOutput = track;

% Turn off accel states if handed a 9 state track
trackOutput.accel = [0.0; 0.0; 0.0];
trackOutput.vel = [0.0; 0.0; 0.0];
trackOutput.P(1:9, 4:9) = zeros(9,6);
trackOutput.P(4:9, 1:9) = zeros(6,9);

xVec(1:3,1) = trackOutput.pos;

% Will only work with the constant velocity model.
model = str2func(params.model);
[F, Q] = model(params.modelParams, dt, xVec);

xVec = F * xVec;

trackOutput.pos = xVec(1:3);

P = trackOutput.P(1:3, 1:3);

P = F * P * F' + Q;

trackOutput.P(1:3, 1:3) = P;
end
