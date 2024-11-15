function uVec = azel2los(az, el)
% Azimuth and elevation to LOS unit vector via a NED-like coordinate frame
uVec = [cos(el) * cos(az);
        cos(el) * sin(az);
        -sin(el)];
end

