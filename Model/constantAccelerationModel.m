function [F, Q] = constantAccelerationModel(params, dt, x)
I = eye(3);
F = eye(9);
F(1:3, 4:6) = dt * I;
F(1:3, 7:9) = (1 / 2) * dt^2 * I;
F(4:6, 7:9) = dt * I;

processNoise = params.processNoise;
gamma = [(1/6) * dt^3 * I
         (1/2) * dt^2 * I
                   dt * I];
Q = gamma * gamma' * processNoise;
end
