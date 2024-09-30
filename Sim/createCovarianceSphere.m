function [X, Y, Z] = createCovarianceSphere(range, P, n, sigma)
% range = track position %
% P = track position covariance %
% n = number of points ni ellipsoid %
% sigma = standard deviations of sphere %

theta = (-n:2:n) / n * pi;
phi = (-n:2:n)' / n * pi / 2;

cosphi = cos(phi);
cosphi(1) = 0;
cosphi(n + 1) = 0;

sintheta = sin(theta);
sintheta(1) = 0;
sintheta(n + 1) = 0;

x = cosphi * cos(theta);
y = cosphi * sintheta;
z = sin(phi) * ones(1, n + 1);

xyz = [x(:), y(:), z(:)];

[eigenVec, eigenVal] = eig(P);
xyz = xyz * sqrt(eigenVal) * eigenVec';

X(:) = sigma * xyz(:, 1) + range(1);
Y(:) = sigma * xyz(:, 2) + range(2);
Z(:) = sigma * xyz(:, 3) + range(3);

X = reshape(X, [n + 1, n + 1]);
Y = reshape(Y, [n + 1, n + 1]);
Z = reshape(Z, [n + 1, n + 1]);

end
