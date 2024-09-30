function [az, el] = los2azel(uVec)
az = atan2(uVec(2), uVec(1));
el = -asin(uVec(3));
% el = -atan2(uVec(3), norm(uVec(1:2)));
end

