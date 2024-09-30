% Creates all of the trajectories for all of the vehicles in the simulation
% scenario.
dt = 0.1;
endTime = 50;
tVec = 0:dt:endTime;

% Sensors
sensor1LLA1 = [9.9 10 0];
sensorPositions{1} = lla2ecef(sensor1LLA1);
sensorPositions{1} = sensorPositions{1} .* ones(length(tVec), 1);

sensor2LLA1 = [10.1 10 0];
sensorPositions{2} = lla2ecef(sensor2LLA1);
sensorPositions{2} = sensorPositions{2} .* ones(length(tVec), 1);

% Targets
target1LLA1 = [10.1 8.5 1000];
target1LLA2 = [10.1 10.5 1000];
target1Speed = 500;
target1LLA = createTrajectory(target1LLA1, target1LLA2, target1Speed, dt);
targetPositions{1} = lla2ecef(target1LLA);
targetPositions{1} = targetPositions{1}(1:length(tVec), :);

target2LLA1 = [9.9 8.5 2000];
target2LLA2 = [9.9 10.5 2000];
target2Speed = 500;
target2LLA = createTrajectory(target2LLA1, target2LLA2, target2Speed, dt);
targetPositions{2} = lla2ecef(target2LLA);
targetPositions{2} = targetPositions{2}(1:length(tVec), :);

% Plot the sensors and the targets %
figure;
hold on;
plot(target1LLA(:, 1), target1LLA(:, 2), 'r');
plot(target2LLA(:, 1), target2LLA(:, 2), 'r');
hold off;
xlabel('Latitude');
ylabel('Longitude');
xlim([9.5 10.5])
ylim([9 11])
