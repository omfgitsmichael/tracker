function uVec = azel2los(az, el)
uVec = [cos(el) * cos(az);
        cos(el) * sin(az);
        -sin(el)];
end

