function trackOutput = cartesianPropagate9State(params, track, detection)
dt = detection.t - track.t;

trackOutput = track;

xVec(1:3,1) = trackOutput.pos;
xVec(4:6,1) = trackOutput.vel;
xVec(7:9,1) = trackOutput.accel;

% Will only work with the constant acceleration model.
model = str2func(params.model);
[F, Q] = model(params.modelParams, dt, xVec);

xVec = F * xVec;

trackOutput.pos = xVec(1:3);
trackOutput.vel = xVec(4:6);
trackOutput.accel = xVec(7:9);

P = trackOutput.P;

P = F * P * F' + Q;

trackOutput.P = P;
end
