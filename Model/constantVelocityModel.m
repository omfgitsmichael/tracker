function [F, Q] = constantVelocityModel(params, dt, x)
I = eye(3);
F = eye(6);
F(1:3, 4:6) = dt * I;

% Acceleration process noise
processNoise = params.processNoise;
gamma = [(1/2) * dt^2 * I;
                   dt * I];
Q = gamma * gamma' * processNoise;
end
