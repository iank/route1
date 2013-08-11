figure('position',[100 100 600 700]);

% Load grid and initialize 'Routed' map
load fridge_alarm
R = zeros(size(G));

% Figure out net order based on bounding boxes
bbn = [];
for n=1:max(max(G))
    bbn = [bbn; countBB(G,n)];
end
[dum, netOrder] = sort(bbn);

% For each net, keep routing until entire net is routed (or unroutable)
for n=netOrder'
    lR = ones(size(R));
    while (any(any(R ~= lR)))
        lR = R;
        [G,R] = route(G,R,n);
    end
end
