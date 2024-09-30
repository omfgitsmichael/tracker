function result = auction(params, cost, numRows, numCols)

% Set up the cost matrix so it is ready to be used.
maxCost = 0;
for i = 1:numRows
    for j = 1:numCols
        if (maxCost < cost(i, j) && cost(i, j) ~= params.defaultCost)
            maxCost = cost(i, j);
        end
    end
end

maxCost = maxCost + params.defaultCost;
for i = 1:numRows
    for j = 1:numCols
        if (cost(i, j) == params.defaultCost)
            cost(i, j) = maxCost;
        end
    end
end

% Create a temp cost matrix that will be used inside of the auction
% assignment algorithm.
costTemp = zeros(numRows, numCols);
for i = 1:numRows
    for j = 1:numCols
        costTemp(i, j) = maxCost - cost(i, j);
    end
end

% If we have more rows than we do columns, transpose the matrix.
transpose = false;
if (numRows > numCols)
    transpose = true;
end

if (transpose)
    costTemp = costTemp';
end

% Run the auction assignment algorithm.
if (~transpose)
    assignedRow = performAuction(costTemp, numRows, numCols, params.epsilon);
else
    assignedRow = performAuction(costTemp, numCols, numRows, params.epsilon);
end

rows = numRows;
cols = numCols;
if (transpose)
    rows = numCols;
    cols = numRows;
end

% Create the output result matrix.
assignmentMatrix = zeros(rows, cols);
for j = 1:cols
    if (assignedRow(j) > 0)
        assignmentMatrix(assignedRow(j), j) = 1;
    end
end

result = zeros(numRows, numCols);
for i = 1:rows
    for j = 1:cols
        if (~transpose)
            result(i, j) = assignmentMatrix(i, j);
        else 
            result(j, i) = assignmentMatrix(i, j);
        end
    end
end
end


function assignedRow = performAuction(cost, numRows, numCols, epsilon)
assignedRow = zeros(numCols, 1);
prices = zeros(numCols, 1);
rows2Auction = zeros(numRows, 1);
for i = 1:numRows
    rows2Auction(i) = i;
end

nextAvailableToDo = numRows; % max available location in the to-do list
dp = epsilon / numRows; % minimum dual prices difference
done = false;

while ~done
    thisRow = rows2Auction(1);

    % Compute the assignment prices
    gains = zeros(numCols, 1);
    maxGain = 0;
    maxGainIndex = 0;
    for i = 1:numCols
        gains(i) = cost(thisRow, i) - prices(i);
        if (maxGain < gains(i))
            maxGain = gains(i);
            maxGainIndex = i;
        end
    end

    % At least one assignment is still feasible at the moment
    if (maxGain > 0)
        sortedGains = sort(gains);

        bump = sortedGains(numCols) + dp;
        if (numCols > 1 && sortedGains(numCols - 1) > 0)
            bump = bump - sortedGains(numCols - 1);
        end

        bestCol = maxGainIndex; % Which column had the best value
        loser = assignedRow(bestCol); % un-assign the prior winner (if any -- it could still be zero)
        assignedRow(bestCol) = thisRow; % Update the assigned row
        prices(bestCol) = prices(bestCol) + bump; % Update the prices with the bump

        if (loser > 0)
            rows2Auction(nextAvailableToDo + 1) = loser; % Put the loser at the end of the to-do list
        end
    end

    % We are done with this row for now. If this would empty the rows to do
    % list, then we are done.
    numRowsLeft = numel(rows2Auction);
    if (numRowsLeft > 1)
        rows2Auction(1) = [];
        nextAvailableToDo = nextAvailableToDo - 1;
    else
        done = true;
    end
end
end
