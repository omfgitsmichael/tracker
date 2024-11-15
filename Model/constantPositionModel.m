function [F, Q] = constantPositionModel(params, dt, x)
I = eye(3);
F = eye(3);

% Velocity process noise
processNoise = params.processNoise;
gamma = dt * I;
Q = gamma * gamma' * processNoise;
end

