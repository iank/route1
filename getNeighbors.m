% Get (4-adjacency) neighbors of X in a grid of size sz
function N=getNeighbors(X, sz)
    % Select four neighbors
    U = X + [-1  0];
    R = X + [ 0  1];
    D = X + [ 1  0];
    L = X + [ 0 -1];

    N = [U;R;D;L];

    % Eliminate too-small N
    [I dum] = ind2sub(size(N), find(N < 1));
    N(I,:) = [];

    % Eliminate too-large N
    I = find(N(:,1) > sz(1));
    N(I,:) = [];
    I = find(N(:,2) > sz(2));
    N(I,:) = [];
end
