function [az, el] = los2azel(uVec)
% Azimuth and elevation to LOS unit vector via a NED-like coordinate frame
az = atan2(uVec(2), uVec(1));
el = -atan2(uVec(3), norm(uVec(1:2)));
end

