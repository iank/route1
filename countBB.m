% For net n on grid G, find the bounding box of nodes in n.
% Count the number of pins within the bounding box not belonging to net n.

function N = countBB(G,n)
    % Find bounding box
    [I J] = ind2sub(size(G), find(G == n));
    X = [I J];
    B1 = min(X(:,1), min(X(:,2)));
    B2 = max(X(:,1), max(X(:,2)));

    N = 0;
    for i=B1(1):B2(1)
        for j=B1(2):B2(2)
            if (G(i,j) > 0 & G(i,j) ~= n)
                N = N + 1;
            end
        end
    end
end
