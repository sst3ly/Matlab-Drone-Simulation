function path = bfs_pathfind(start, goal, drones, currentDroneIndex, gridsize)
% Breadth First Search pathfinding

    % -- get occupied grid cells --
    occupied = false(gridsize);
    for i = 1:length(drones)
        if i ~= currentDroneIndex
            pos = drones(i).position;
            occupied(pos(1), pos(2)) = true;
        end
    end

    if goal(1) >= 1 && goal(1) <= gridsize && goal(2) >= 1 && goal(2) <= gridsize && norm(start-goal) > 1
        occupied(goal(1), goal(2)) = false;
    end

    % -- search grid --
    queue = {start};
    visited = false(gridsize);
    visited(start(1), start(2)) = true;
    parent = cell(gridsize);

    % 2d movement w/ diagonals = 8 directions
    directions = [0 1; 0 -1; 1 0; -1 0; 1 1; 1 -1; -1 1; -1 -1];

    found = false;
    while ~isempty(queue) && ~found
        current = queue{1};
        queue(1) = [];

        if(isequal(current, goal))
            found = true;
            break
        end

        for d=1:size(directions, 1)
            neighbor = current + directions(d, :);
            nx = neighbor(1);
            ny = neighbor(2);

            % make sure its a valid square
            if (nx < 1 || nx > gridsize || ny < 1 || ny > gridsize) || visited(nx, ny) || occupied(nx, ny)
                continue
            end

            visited(nx, ny) = true;
            parent{nx, ny} = current;
            queue{end+1} = neighbor;
        end
    end

    % -- reconstruct path --
    if found
        path = [];
        current = goal;
        while ~isempty(current)
            path = [current; path];
            current = parent{current(1), current(2)};
        end
    else
        path = [start]; % no path found
    end
end