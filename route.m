function [G,R] = route(G,R,n)
    %%%% Find X, all points in net n
    [I J] = ind2sub(size(G), find(G == n & R ~= 1));
    X = [I J];

    % If there are no nodes in this net that are unrouted, we are done
    if (size(X,1) == 0)
        return
    end

    %%%% Pick S and T

    % Let S be either: the first node in X, or all routed cells in X.
    [I J] = ind2sub(size(G), find(G == n & R == 1));
    S = [I J];
    if (size(S,1) == 0)
        S = X(1,:);
        X = X(2:end,:);
    end

    %%%% Pick T
    % Find distance from every candidate T to (first) S, pick closest.
    % FIXME: S(1,:) isn't the best
    dist = sum((X - repmat(S(1,:),[size(X,1) 1])).^2,2);
    [dum,i] = min(dist);
    T = X(i,:);
    X(i,:) = [];

    %%%% Make weight grid W
    W = G;
    W(W ~= 0) = Inf;
    W(W == 0) = 1;  % default unoccupied weight

    %%%% Make cost grid C
    C = zeros(size(G));
    % Mark all cells in S as visited (and lowest cost)
    C(sub2ind(size(G), S(:,1), S(:,2))) = 1;
    % Give the destination a special value
    C(T(1),T(2)) = -1;   % -1: destination
    % All other cells are unmarked (unvisited)
    C(C == 0) = Inf;

    %%%% Wave expansion
    done = 0;
    nMarked = 0;
    while ~done
        % Find marked cells. Use these as starting point for each iteration
        [I J] = ind2sub(size(C), find(C >= 1 & ~isinf(C)));
        marked = [I J];

        % If the number of marked cells hasn't changed since last iteration,
        % we're trapped in a box or we've marked the entire grid and cannot
        % reach the target. (Unroutable)
        if (nMarked == size(marked,1))
            return;
        end

        % For each marked cell, iterate over neighbors
        for i=1:size(marked,1)
            N = getNeighbors(marked(i,:), size(G));
            % For each neighbor, examine and update cost
            for j=1:size(N,1)
                % Is it T ?  then we are done
                if (C(N(j,1), N(j,2)) == -1)
                    done = 1
                end

                % Update cost (if we can do better)
                newcost = C(marked(i,1), marked(i,2)) + W(N(j,1),N(j,2));
                C(N(j,1),N(j,2)) = min(C(N(j,1),N(j,2)), newcost);
            end
        end
        subplot(2,1,1); imagesc(C); drawnow;
        nMarked = size(marked,1);
    end

    % TODO: must do one more iteration after we've found T (to surround it entirely

    %%%% Backtrack best path
    % We have propagated a wave from S to T, so we have at least one
    % path. Backtrack from T using the lowest-cost cell at each step in
    % order to find a minimum-cost path

    done = 0;
    current = T;   % Start at T
    while ~done
        % Bookkeeping: As we move along the path:
        % - mark cell as part of net n,
        % - set the cost to Inf so we don't double back,
        % - and mark each cell as being part of a route
        G(current(1), current(2)) = n;
        C(current(1), current(2)) = Inf;
        R(current(1), current(2)) = 1;

        % Find lowest-cost neighbor
        N = getNeighbors(current,size(G));
        Ni = sub2ind(size(G),N(:,1),N(:,2));
        Nimin = find(C(Ni) == min(C(Ni)),1); % First neighbor index w/ min cost

        % Step to neighbor
        current = N(Nimin,:);
        if (C(current(1),current(2)) == 1)
            % We are finished, do some final bookkeeping and quit
            done = 1;
            G(current(1), current(2)) = n;
            R(current(1), current(2)) = 1;
        end
        subplot(2,1,2); imagesc(G); drawnow;
    end
end
