function R = eulerRotationMatrix(sequence, t)
% The theta sequence should be written in a 1-2-3 format and not a roll,
% pitch, and yaw format as the sequences may not use roll, pitch, or yaw.
% Referenced from Analytics of Space Systems by Hanspeter Schaub and John
% L. Junkins, pages 759 - 760

if sequence == '121'
    R = [cos(t(2)) sin(t(2))*sin(t(1)) -sin(t(2))*cos(t(1)); 
         sin(t(3))*sin(t(2)) -sin(t(3))*cos(t(2))*sin(t(1))+cos(t(3))*cos(t(1)) sin(t(3))*cos(t(2))*cos(t(1))+cos(t(3))*sin(t(1));
         cos(t(3))*sin(t(2)) -cos(t(3))*cos(t(2))*sin(t(1))-sin(t(3))*cos(t(1)) cos(t(3))*cos(t(2))*cos(t(1))-sin(t(3))*sin(t(1))];
elseif sequence == '123'
    R = [cos(t(3))*cos(t(2)) cos(t(3))*sin(t(2))*sin(t(1))+sin(t(3))*cos(t(1)) -cos(t(3))*sin(t(2))*cos(t(1))+sin(t(3))*sin(t(1));
         -sin(t(3))*cos(t(2)) -sin(t(3))*sin(t(2))*sin(t(1))+cos(t(3))*cos(t(1)) sin(t(3))*sin(t(2))*cos(t(1))+cos(t(3))*sin(t(1));
         sin(t(2)) -cos(t(2))*sin(t(1)) cos(t(2))*cos(t(1))];
elseif sequence == '131'
    R = [cos(t(2)) sin(t(2))*cos(t(1)) sin(t(2))*sin(t(1));
         -cos(t(3))*sin(t(2)) cos(t(3))*cos(t(2))*cos(t(1))-sin(t(3))*sin(t(1)) cos(t(3))*cos(t(2))*sin(t(1))+sin(t(3))*cos(t(1));
         sin(t(3))*sin(t(2)) -sin(t(3))*cos(t(2))*cos(t(1))-cos(t(3))*sin(t(1)) -sin(t(3))*cos(t(2))*sin(t(1))+cos(t(3))*cos(t(1))];
elseif sequence == '132'
    R = [cos(t(3))*cos(t(2)) cos(t(3))*sin(t(2))*cos(t(1))+sin(t(3))*sin(t(1)) cos(t(3))*sin(t(2))*sin(t(1))-sin(t(3))*cos(t(1));
         -sin(t(2)) cos(t(2))*cos(t(1)) cos(t(2))*sin(t(1));
         sin(t(3))*cos(t(2)) sin(t(3))*sin(t(2))*cos(t(1))-cos(t(3))*sin(t(1)) sin(t(3))*sin(t(2))*sin(t(1))+cos(t(3))*cos(t(1))];
elseif sequence == '212'
    R = [-sin(t(3))*cos(t(2))*sin(t(1))+cos(t(3))*cos(t(1)) sin(t(3))*sin(t(2)) -sin(t(3))*cos(t(2))*cos(t(1))-cos(t(3))*sin(t(1));
         sin(t(2))*sin(t(1)) cos(t(2)) sin(t(2))*cos(t(1));
         cos(t(3))*cos(t(2))*sin(t(1))+sin(t(3))*cos(t(1)) -cos(t(3))*sin(t(2)) cos(t(3))*cos(t(2))*cos(t(1))-sin(t(3))*sin(t(1))];
elseif sequence == '213'
    R = [sin(t(3))*sin(t(2))*sin(t(1))+cos(t(3))*cos(t(1)) sin(t(3))*cos(t(2)) sin(t(3))*sin(t(2))*cos(t(1))-cos(t(3))*sin(t(1));
         cos(t(3))*sin(t(2))*sin(t(1))-sin(t(3))*cos(t(1)) cos(t(3))*cos(t(2)) cos(t(3))*sin(t(2))*cos(t(1))+sin(t(3))*sin(t(1));
         cos(t(2))*sin(t(1)) -sin(t(2)) cos(t(2))*cos(t(1))];
elseif sequence == '231'
    R = [cos(t(2))*cos(t(1)) sin(t(2)) -cos(t(2))*sin(t(1));
         -cos(t(3))*sin(t(2))*cos(t(1))+sin(t(3))*sin(t(1)) cos(t(3))*cos(t(2)) cos(t(3))*sin(t(2))*sin(t(1))+sin(t(3))*cos(t(1));
         sin(t(3))*sin(t(2))*cos(t(1))+cos(t(3))*sin(t(1)) -sin(t(3))*cos(t(2)) -sin(t(3))*sin(t(2))*sin(t(1))+cos(t(3))*cos(t(1))];
elseif sequence == '232'
    R = [cos(t(3))*cos(t(2))*cos(t(1))-sin(t(3))*sin(t(1)) cos(t(3))*sin(t(2)) -cos(t(3))*cos(t(2))*sin(t(1))-sin(t(3))*cos(t(1));
         -sin(t(2))*cos(t(1)) cos(t(2)) sin(t(2))*sin(t(1));
         sin(t(3))*cos(t(2))*cos(t(1))+cos(t(3))*sin(t(1)) sin(t(3))*sin(t(2)) -sin(t(3))*cos(t(2))*sin(t(1))+cos(t(3))*cos(t(1))];
elseif sequence == '312'
    R = [-sin(t(3))*sin(t(2))*sin(t(1))+cos(t(3))*cos(t(1)) sin(t(3))*sin(t(2))*cos(t(1))+cos(t(3))*sin(t(1)) -sin(t(3))*cos(t(2));
         -cos(t(2))*sin(t(1)) cos(t(2))*cos(t(1)) sin(t(2));
         cos(t(3))*sin(t(2))*sin(t(1))+sin(t(3))*cos(t(1)) -cos(t(3))*sin(t(2))*cos(t(1))+sin(t(3))*sin(t(1)) cos(t(3))*cos(t(2))];
elseif sequence == '313'
    R = [cos(t(3))*cos(t(1))-sin(t(3))*cos(t(2))*sin(t(1)) cos(t(3))*sin(t(1))+sin(t(3))*cos(t(2))*cos(t(1)) sin(t(3))*sin(t(2));
         -sin(t(3))*cos(t(1))-cos(t(3))*cos(t(2))*sin(t(1)) -sin(t(3))*sin(t(1))+cos(t(3))*cos(t(2))*cos(t(1)) cos(t(3))*sin(t(2));
         sin(t(2))*sin(t(1)) -sin(t(2))*cos(t(1)) cos(t(2))];
elseif sequence == '321'
    R = [cos(t(2))*cos(t(1)) cos(t(2))*sin(t(1)) -sin(t(2));
         sin(t(3))*sin(t(2))*cos(t(1))-cos(t(3))*sin(t(1)) sin(t(3))*sin(t(2))*sin(t(1))+cos(t(3))*cos(t(1)) sin(t(3))*cos(t(2));
         cos(t(3))*sin(t(2))*cos(t(1))+sin(t(3))*sin(t(1)) cos(t(3))*sin(t(2))*sin(t(1))-sin(t(3))*cos(t(1)) cos(t(3))*cos(t(2))];
elseif sequence == '323'
    R = [cos(t(3))*cos(t(2))*cos(t(1))-sin(t(3))*sin(t(1)) cos(t(3))*cos(t(2))*sin(t(1))+sin(t(3))*cos(t(1)) -cos(t(3))*sin(t(2));
         -sin(t(3))*cos(t(2))*cos(t(1))-cos(t(3))*sin(t(1)) -sin(t(3))*cos(t(2))*sin(t(1))+cos(t(3))*cos(t(1)) sin(t(3))*sin(t(2));
         sin(t(2))*cos(t(1)) sin(t(2))*sin(t(1)) cos(t(2))];
else
    sprintf('Invalid rotation sequence')
end
end