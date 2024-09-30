function track = extrapolate(track, time)
dt = time - track.t;

if dt ~= 0
    I = eye(3);
    F = eye(9);
    F(1:3, 4:6) = dt * I;
    F(1:3, 7:9) = (1 / 2) * dt^2 * I;
    F(4:6, 7:9) = dt * I;

    xVec(1:3, 1) = track.pos;
    xVec(4:6, 1) = track.vel;
    xVec(7:9, 1) = track.accel;

    xVec = F * xVec;
    track.pos = xVec(1:3);
    track.vel = xVec(4:6);
    track.accel = xVec(7:9);

    P = track.P;
    P = F * P * F';
    track.P = P;

    track.t = time;
end
end
