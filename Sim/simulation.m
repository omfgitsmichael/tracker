%% Tracker simulation %%
close all;
clear all;

%% Simulation Data %%
% scenario;
% scenarioConstPosition;
scenarioGhostTracks;

% Noise %
azSigma = 0.1 * pi / 180;
elSigma = 0.1 * pi / 180;
positionNoise = 0;

algorithmRate = 1; % seconds

%% For Plotting %%
plotIMMWeights = true;

%% Create the params %%
% paramsTracker = trackerCartesianConfig();
paramsTracker = trackerIMMConfig();
paramsFusion = fusionConfig();

for i = 1:numel(sensorPositions)
    trackList{i} = trackType();
    trackDatabase{i} = trackType();
    fusedList{i} = trackType();
end

for i = 1:length(tVec)
    for j = 1:numel(sensorPositions)
        trackListSaved{i, j} = trackType();
        fusedListSaved{i, j} = trackType();
    end
end

for i = 1:numel(sensorPositions)
    frameDatabase{i} = frameType();
end

%% Set the sensor orientation %%
targetMedian = zeros(length(tVec), 3);
for i = 1:numel(targetPositions)
    targetMedian = targetMedian + targetPositions{i};
end
targetMedian = targetMedian / numel(targetPositions);

for i = 1:numel(sensorPositions)
    uEat{i} = zeros(length(tVec), 3);
    for j = 1:length(tVec)
        rEat = targetMedian(j,:) - sensorPositions{i}(j,:);
        uEat{i}(j, :) = rEat / norm(rEat);
    end
end

for i = 1:numel(sensorPositions)
    sensorAzimuth{i} = linspace(atan2(uEat{i}(1,2), uEat{i}(1,1)),...
                                atan2(uEat{i}(end,2), uEat{i}(1,1)),...
                                length(tVec));
    sensorElevation{i} = linspace(atan2(uEat{i}(1,3), sqrt(uEat{i}(1,2)^2 + uEat{i}(1,1)^2)),...
                                  atan2(uEat{i}(end,3), sqrt(uEat{i}(end,2)^2 + uEat{i}(end,1)^2)),...
                                  length(tVec));
end

%% Main Simulation %%
for i = 1:length(tVec)
    % Loop through each of the sensors %
    for j = 1:numel(sensorPositions)
        % Loop through each of the targets to create detections %
        CI2D = eulerRotationMatrix('321', [sensorAzimuth{j}(i); sensorElevation{j}(i); 0.0]);
        for k = 1:numel(targetPositions)
            rIst = targetPositions{k}(i, :) - sensorPositions{j}(i, :);
            rIst = rIst' + [positionNoise * randn(1);
                            positionNoise * randn(1);
                            positionNoise * randn(1)];
            range = norm(rIst);
            uIst = rIst / range;
            uDst = CI2D * uIst;
            [azD, elD] = los2azel(uDst);
            azD = azD + azSigma * randn(1);
            elD = elD + elSigma * randn(1);

            % Test %
            CD2T = eulerRotationMatrix('321', [azD; elD; 0.0]);
            uTst = CD2T * uDst;
            % Test %
    
            detection.sensor.CI2D = CI2D;
            detection.sensor.pos = sensorPositions{j}(i, :)';
            detection.azValid = true;
            detection.azimuth = azD;
            detection.elValid = true;
            detection.elevation = elD;
            detection.rangeValid = false;
            detection.range = 0;
            detection.rangeRateValid = false;
            detection.rangeRate = 0;
            detection.t = tVec(i);
            detection.detectionID = j;
            detectionList(k) = detection;
        end

        %  Run the tracker %
        if mod(tVec(i), algorithmRate) == 0
            [paramsTracker, trackList{j}, trackDatabase{j}] = ...
                tracker(paramsTracker, trackDatabase{j}, detectionList, tVec(i));
        end
        trackListSaved{i, j} = trackList{j};

        % Create the tracklsits for the fusion algorithm input %
        incomingFrames = frameType;
        incomingFrames{1}.sensorID = j;
        incomingFrames{1}.trackList = trackList{j};

        for l = 1:numel(sensorPositions)
            if l ~= j && i ~= 1 && tVec(i) > 5.0
                incomingFrames{end + 1}.sensorID = l;
                incomingFrames{end}.trackList = trackListSaved{i - 1, l};
            end
        end

        % Run the track fusion algorithm %
        if mod(tVec(i), algorithmRate) == 0
            [paramsFusion, frameDatabase{j}, fusedList{j}] = ...
                fusion(paramsFusion, frameDatabase{j}, fusedList{j}, incomingFrames, tVec(i));
        end
        fusedListSaved{i, j} = fusedList{j};
    end   
end

%% Grab and Plot Data %%
% Grab the data for track 1 %
for i = 1:numel(trackListSaved(:, 1))
    trackList1 = trackListSaved{i, 1};
    for j = 1:numel(trackList1)
        track = trackList1(j);
        track1(i, j) = track;
    end

    trackList2 = trackListSaved{i, 2};
    for j = 1:numel(trackList2)
        track = trackList2(j);
        track2(i, j) = track;
    end  
end

for i = 1:numel(fusedListSaved(:, 1))
    fusedList1 = fusedListSaved{i, 1};
    for j = 1:numel(fusedList1)
        fused = fusedList1(j);
        fused1(i, j) = fused;
    end

    fusedList2 = fusedListSaved{i, 2};
    for j = 1:numel(fusedList2)
        fused = fusedList2(j);
        fused2(i, j) = fused;
    end  
end

% Get the range plot data %
for i = 1:numel(fused1(:,1))
    if ~isempty(fused1(i, 1).pos)
        rangeEst = fused1(i, 1).pos - sensorPositions{1}(i, :)';
        rangeTrue = (targetPositions{1}(i, :) - sensorPositions{1}(i, :))';
        rangeEstPlot(i) = norm(rangeEst) / 1000;
        rangeTruePlot(i) = norm(rangeTrue) / 1000;
        errorPlot(i) = norm(rangeEst - rangeTrue) / 1000;
        uncertainty(i) = sqrt(norm(fused1(i, 1).P(1:3,1:3))) / 1000;
        trackVelocity(:, i) = fused1(i, 1).vel;

        if (plotIMMWeights)
            weights(:, i) =  fused1(i, 1).imm.weights';
        end
    end
end

if (plotIMMWeights)
    figure
    grid on;
    hold on;
    plot(tVec, weights(1,:));
    plot(tVec, weights(2,:));
    plot(tVec, weights(3,:));
    hold off;
    xlabel('Time (s)')
    ylabel('IMM Model Weights')
    title('IMM Weights Over Time');
    legend('Model 1 Weight', 'Model 2 Weight', 'Model 3 Weight');
end

figure
grid on;
hold on;
plot(tVec, trackVelocity(1,:));
plot(tVec, trackVelocity(2,:));
plot(tVec, trackVelocity(3,:));
hold off;
xlabel('Time (s)')
ylabel('Track Velocity')
title('Track Velocity Over Time');
legend('Vx', 'Vy', 'Vz');

figure;
subplot 211
grid on;
hold on;
plot(tVec, rangeEstPlot, 'b');
plot(tVec, rangeTruePlot, 'k');
hold off;
xlabel('Time (s)')
ylabel('Range (km)')
legend('Range Estimated', 'Range True');
title('Range Estimate Over Time');

subplot 212
grid on;
hold on;
plot(tVec, errorPlot, 'b');
plot(tVec, 3 * uncertainty, 'k');
plot(tVec, -3 * uncertainty, 'k');
hold off;
xlabel('Time (s)')
ylabel('Range Error (km)')
legend('Range Error');
title('Range Error Over Time');

% Plot a random frame %
figure;
for i = 1:length(tVec)
    clf;
    for j = 1:numel(targetPositions)
        if isempty(track1(i, j).pos) || isempty(track2(i, j).pos) || isempty(fused1(i, j).pos) || isempty(fused2(i, j).pos)
            continue
        end

        trackPlot1 = track1(i, j);
        position1 = trackPlot1.pos;
        P1 = trackPlot1.P(1:3,1:3);
        [X1, Y1, Z1] = createCovarianceSphere(position1, P1, 25, 3);

        trackPlot2 = track2(i, j);
        position2 = trackPlot2.pos;
        P2 = trackPlot2.P(1:3,1:3);
        [X2, Y2, Z2] = createCovarianceSphere(position2, P2, 25, 3);

        hold on;
        plot3(sensorPositions{1}(i, 1), sensorPositions{1}(i, 2), sensorPositions{1}(i, 3), '+', 'Color', 'k', 'MarkerSize', 10);
        plot3(sensorPositions{2}(i, 1), sensorPositions{2}(i, 2), sensorPositions{2}(i, 3), '+', 'Color', 'k', 'MarkerSize', 10);
        plot3(targetPositions{j}(i, 1), targetPositions{j}(i, 2), targetPositions{j}(i, 3), '+', 'Color', 'k', 'MarkerSize', 10);
        plot3(position1(1), position1(2), position1(3), '+', 'Color', 'k', 'MarkerSize', 10);
        plot3(position2(1), position2(2), position2(3), '+', 'Color', 'k', 'MarkerSize', 10);
        surf(X1, Y1, Z1, 'EdgeColor','none', 'LineStyle','none','FaceColor', 'b', 'FaceAlpha', 0.25);
        surf(X2, Y2, Z2, 'EdgeColor','none', 'LineStyle','none','FaceColor', 'y', 'FaceAlpha', 0.25);

        if i ~= 1
            fusedPlot1 = fused1(i, j);
            position3 = fusedPlot1.pos;
            P3 = fusedPlot1.P(1:3,1:3);
            [X3, Y3, Z3] = createCovarianceSphere(position3, P3, 25, 3);
            surf(X3, Y3, Z3, 'EdgeColor','none', 'LineStyle','none','FaceColor', 'r', 'FaceAlpha', 0.5);
        end

        offset = 600;
        txt = ['Sensor ' num2str(j)];
        text(sensorPositions{j}(i, 1)+offset, sensorPositions{j}(i, 2)+offset, sensorPositions{j}(i, 3)+offset, txt);

        txt = ['Target ' num2str(j)];
        text(targetPositions{j}(i, 1)+offset, targetPositions{j}(i, 2)+offset, targetPositions{j}(i, 3)+offset, txt);

        hold off;
        grid on;
    end
    frameNumber = num2str(i);
    titleString = ['Track data frame ' frameNumber];
    title(titleString);

    test = 1; % PUT A BREAK POINT HERE TO PLOT NICELY %
end

figure;
for i = 1:length(tVec)
    clf;
    h1 = axes;
    % Create a plot which shows the detections in an image frame for one of
    % the sensors
    for j = 1:numel(targetPositions)

        if isempty(track1(i, j).pos)
            continue
        end

        trackPlot1 = track1(i, j);
        detection = trackPlot1.detection;
        az = detection.azimuth;
        el = detection.elevation;

        % Uncertainty around the detection
        circleRadius = sqrt(paramsTracker.update.initializeParams.sigmaAz^2 ...
            + paramsTracker.update.initializeParams.sigmaEl^2);
        theta = 0:pi/50:2*pi;
        x = circleRadius * cos(theta) + az;
        y = circleRadius * sin(theta) + el;

        hold on;
        plot(az, el, '+k', 'MarkerSize', 10);
        plot(x, y, 'b');
        hold off;
        grid on;
        xlim([-20*pi/180 20*pi/180]);
        ylim([-20*pi/180 20*pi/180]);

        txt = ['Detection ' num2str(j)];
        differenceY = min(y) - max(y);
        differenceX = max(x) - min(x);
        text(az - 4 * differenceX / 5, el + differenceY, txt)
    end

    xlabel('Azimuth (rad)');
    ylabel('Elevation (rad)');
    frameNumber = num2str(i);
    titleString = ['Detection via Sensor Frame: Frame ' frameNumber];
    title(titleString);
    set(h1, 'YDir', 'reverse');
    set(h1, 'XTick', -20*pi/180:2*pi/180:20*pi/180)
    set(h1, 'YTick', -20*pi/180:2*pi/180:20*pi/180)

    test = 1; % PUT A BREAK POINT HERE TO PLOT NICELY %
end
