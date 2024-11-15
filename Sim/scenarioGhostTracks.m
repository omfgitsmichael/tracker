% Creates all of the trajectories for all of the vehicles in the simulation
% scenario.
dt = 0.1;
endTime = 50;
tVec = 0:dt:endTime;

% Sensors - moving at constant velocity
sensorPositions{1} = [linspace(-1000, 0, length(tVec))' linspace(1000, 1000, length(tVec))' linspace(100, 100, length(tVec))'];
sensorPositions{2} = [linspace(-1000, 0, length(tVec))' linspace(-1000, -1000, length(tVec))' linspace(100, 100, length(tVec))'];

% Targets - stationary
targetPositions{1} = [linspace(1000, 1000, length(tVec))' linspace(100, 100, length(tVec))' linspace(100, 100, length(tVec))'];
targetPositions{2} = [linspace(1000, 1000, length(tVec))' linspace(-100, -100, length(tVec))' linspace(100, 100, length(tVec))'];