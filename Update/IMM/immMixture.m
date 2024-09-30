function [xOut, POut] = immMixture(weights, models)

N = length(models);
xOut = zeros(9, 1);
POut = zeros(9, 9);

% Normalize likelihood weights in case they weren't normalized prior
weights = weights / sum(weights);

% Mix the state variables
for i = 1:N
    x = [models(i).pos; models(i).vel; models(i).accel];
    xOut = xOut + weights(i) * x;
end

% Mix the covariance matrix
for i = 1:N
    x = [models(i).pos; models(i).vel; models(i).accel];
    POut = POut + weights(i) * (models(i).P + (x - xOut) * (x - xOut)');
end

end
