function result = munkres(params, cost, numRows, numCols)
transpose = false;

if numRows > numCols
    transpose = true;
    cost = cost';
end

% Step 0: Reduce the cost matrix 
cost = cost - min(cost, [], numCols) * ones(1, size(cost, numCols)); % Subtract the row minimum from each column

% Step 1: Initialize
runMunkres = true;
coveredCols = false(numCols, 1);
coveredRows = false(numRows, 1);
primeIndices = false(numRows, numCols);
step = 2;

% Main Munkres assignment loop 
while runMunkres
    switch step
        case 2
            [starIndices, step] = step2(cost, numRows, numCols);
        case 3
            [coveredCols, step] = step3(starIndices, numRows, numCols);
        case 4
            [coveredRows, coveredCols, primeIndices, step] = ...
                step4(cost, coveredRows, coveredCols, starIndices, primeIndices);
        case 5
            [coveredRows, coveredCols, starIndices, primeIndices, step] = ...
                step5(cost, coveredRows, coveredCols, starIndices, primeIndices);
        case 6
            [cost, step] = step6(cost, coveredRows, coveredCost);
        otherwise
            % An optimal assignment has been found. Terminate the loop.
            runMunkres = false;
            result = starIndices;
    end
end

if transpose
    result = result';
end
end

% Find the zeros in the cost matrix, return starIndices which is a matrix
% which has 1's at the each of the starred zeros 
function [starIndices, step] = step2(cost, numRows, numCols)
starIndices = false(numRows, numCols);
zeroLocations = logical(cost == 0);
coveredCols = false(1, numCols);

% Find and star the zeros such that there no two zeros starred in any
% single row or column
for i = 1:numRows
    if sum(zeroLocations(i,:)) == 1
        stars = find(zeroLocations(i,:) & ~coveredCols, 1, 'first');
        starIndices(i, stars) = true; % Star the zeros in this row
        coveredCols = coveredCols | starIndices(i,:);
    end
end

step = 3;
end

function [coveredCols, step] = step3(starIndices, numRows, numCols)
% Cover each column containing a starred zero 
coveredCols = logical(sum(starIndices, 1));

if sum(coveredCols) == min(numRows, numCols)
    % Munkres found the optimal assignment 
    step = 7;
else
    step = 4;
end
end

function [coveredRows, coveredCols, primeIndices, step] = ...
    step4(cost, coveredRows, coveredCols, starIndices, primeIndices)
% Find a non-covered zero and prime it %
notStarred = logical(cost == 0) & ~starIndices; % All zeros that are not starred
notStarred(:, coveredCols) = false;
notStarred(coveredRows, :) = false;
pIndex = find(notStarred, 1, 'first');
primeIndices(pIndex) = true;

if ~any(notStarred)
    % No uncovered zeros. Go to step 6
    step = 6;
else
    % There is at least 1 uncovered zero and it is now primed. Find starred
    % zeros in the row of the primed zero 
    [row, ~] = ind2sub(size(primeIndices), pIndex);
    col = find(starIndices(row, :), 1);

    if isempty(col)
        % No starred zeros in the row of the primed zero, go to step 5 
        step = 5;
    else
        % There is a starred zero in the row of the primed zero. Cover the
        % row and uncover the column of the starred zero. Repeat step 4. 
        coveredRows(row) = true;
        coveredCols(col) = false;
        step = 4;
    end
end
end

function [coveredRows, coveredCols, starIndices, primeIndices, step] = ...
    step5(cost, coveredRows, coveredCols, starIndices, primeIndices)
% Initialize temp variables for internal loop %
n = max(length(coveredRows), length(coveredCols));
s = cell(1, n);
p = cell(1, n);
run = true;
i = 1;

while run
    if i == 1
        % Find the column of the uncovered primed zero found in the
        % previous step 
        notCovered = primeIndices;
        notCovered(coveredRows, :) = false;
        notCovered(:, coveredCols) = false;
        [row, col] = find(notCovered, 1, 'first');
        p{1} = [row, col];
    else
        % Find a primed zero in the row of the starred zero 
        p{i}(2) = find(primeIndices(s{i-1}(1), :));
        p{i}(1) = s{i-1}(1);
    end

    % Find a starred zero in the column of the primed zero 
    temp = find(starIndices(:, p{i}(2)), 1, 'first');

    % Check to see if there is a starred zero. If not then create the
    % sequence %
    if ~isempty(temp)
        s{i}(1) = tmp;
        s{i}(2) = p{i}(2);
    else
        % Unstar each starred zero in the sequence 
        for j = 1:length(s)
            if ~isempty(s{j})
                starIndices(s{j}(1), s{j}(2)) = false;
            end
        end

        % Star each primed zero in the sequence 
        for j = 1:length(p)
            if ~isempty(p{j})
                starIndices(p{j}(1), p{j}(2)) = true;
            end
        end

        % Unprime all zeros and uncover all rows and cols 
        primeIndices = false(size(primeIndices));
        coveredRows = false(size(coveredRows));
        coveredCols = false(size(coveredCols));

        % Go to step 3 %
        step = 3;
    end
    
    % Iterate i %
    i = i + 1;
end
end

function [cost, step] = step6(cost, coveredRows, coveredCols)
% Get rid of all the covered rows/cols 
costTemp = cost(~coveredRows, ~coveredCols);

% Find the minimum of the remaining cost matrix 
minValue = min(min(costTemp));

% Add the minimum value to all the covered rows and columns, then subtract
% the minimum value from every element in the original cost matrix 
if sum(coveredRows)
    cost(coveredRows, :) = cost(coveredRows, :) + minValue;
end

if (sum(coveredCols))
    cost(:, coveredCols) = cost(:, coveredCols) + minValue;
end
cost = cost - minValue;

% Go to step 4 
step = 4;
end
