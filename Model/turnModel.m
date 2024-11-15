function [F, Q] = turnModel(params, dt, x)

acceleration = norm(x(7:9));
velocity = norm(x(4:6));

w = acceleration / velocity;
w1 = 1 / w;
w2 = 1 / (w * w);

% Safe gaurd against cases where the velocity estimate is zero %
if (velocity < 1e-6)
    w = 1e-6;
    w1 = 1 / w;
    w2 = 1 / (w * w);
end

I = eye(3);
F = zeros(9);

F(1:3, 1:3) = I;
F(1:3, 4:6) = w1 * sin(w * dt) * I;
F(1:3, 7:9) = w2 * (1 - cos(w * dt)) * I;

F(4:6, 4:6) = cos(w * dt) * I;
F(4:6, 7:9) = w1 * sin(w * dt) * I;

F(7:9, 4:6) = -w * sin(w * dt) * I;
F(7:9, 7:9) = cos(w * dt) * I;

% Jerk process noise
processNoise = params.processNoise;
gamma = [(1/6) * dt^3 * I
         (1/2) * dt^2 * I
                   dt * I];
Q = gamma * gamma' * processNoise;
end
