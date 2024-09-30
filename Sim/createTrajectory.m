function lla = createTrajectory(startLLA, endLLA, speed, dt)
% Speed in nmi/hr
% lla: [latitude, longitude, altitude] in [degrees, degrees, meters]
% dt in sec

delLLA = endLLA - startLLA;
llMagnitude = norm(delLLA(1:2));

nmi2deg = 1 / 60;
hr2sec = 1 / 3600;
speedLLA = speed * nmi2deg * hr2sec; % degrees / sec

% How long it will take to get there if going in a straight line.
time = llMagnitude / speedLLA; 
size = round(time / dt);

lla = [linspace(startLLA(1), endLLA(1), size)',...
       linspace(startLLA(2), endLLA(2), size)',...
       linspace(startLLA(3), endLLA(3), size)'];
end
