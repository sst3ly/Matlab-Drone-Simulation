function [newDrone, newFireGrid] = drone_update(drones, droneIndex, fire, params)
% DRONE_UPDATE updates the drone passed in
arguments(Input)
    drones (1,:) struct 
    droneIndex (1, 1)
    fire (:,:) double
    params (1,1) struct
end

drone = drones(droneIndex);

% ------- water control -------
% if the drone is out of water, go back to the water tank
if(drone.water_level == 0)
    drone.has_target = true;
    drone.target = params.water_tank_position;
end

% ------- fire targeting -------
% check if drone target is still valid
if(drone.has_target && drone.target(2) ~= params.water_tank_position(2) && fire(drone.target(1), drone.target(2)) == 0)
    % previous target is no longer on fire
    drone.has_target = false;
end

% if the drone has no target, find a high priority fire cell
if(~drone.has_target)
    highestPriorityFireScore = 0;
    drone.target = params.water_tank_position;
    droneFurthestTarget = norm([size(fire,1), size(fire,2)] - [1,1]);

    % get base scores
    for xi=1:size(fire, 1)
        for yi=1:size(fire, 2)
            base_score = (droneFurthestTarget - norm([xi, yi] - drone.position)) * min(params.strength_threshold, fire(xi, yi));

            neighborScore = 0;
            for dx = -1:1
                for dy = -1:1
                    if dx == 0 && dy == 0
                        continue;
                    end
                    nx = xi + dx;
                    ny = yi + dy;
                    
                    if nx >= 1 && nx <= size(fire, 1) && ny >= 1 && ny <= size(fire, 2)
                        neighborScore = neighborScore + fire(nx, ny);
                    end
                end
            end
            fireScore = base_score + neighborScore;
            if(fireScore > highestPriorityFireScore)
                highestPriorityFireScore = fireScore;
                drone.target = [xi, yi];
                drone.has_target = true;
            end
        end
    end 
    % fallback to water tank
    if(~drone.has_target)
        drone.target = params.water_tank_position;
        drone.has_target = true;
    end
end

% water tank line-up logic
if isequal(drone.target, params.water_tank_position)
    % start with one axis to form a line and prevent a mob of drones
    % around the water tank, which could permanently stop the drones
    drone.target = [drone.position(1) params.water_tank_position(2)];
    if isequal(drone.position, drone.target)
        drone.target = params.water_tank_position;
    end
    % drone reached water tank
    if isequal(drone.position, params.water_tank_position)
        drone.water_level = params.max_drone_water;
        drone.times_refilled = drone.times_refilled + 1;
        drone.has_target = false;
    end
end

if(drone.has_target)
    bfs_path = bfs_pathfind(drone.position, drone.target, drones, droneIndex, params.grid_size);

    if(size(bfs_path, 1) > 1)
        drone.position = bfs_path(2,:);
        mov = drone.position - bfs_path(2,:);
        if(mov(2) == 0 || mov(1) == 0)
            drone.distance_travelled = drone.distance_travelled + 1;
        else
            drone.distance_travelled = drone.distance_travelled + 1.41421; % estimate for sqrt(2)
        end
    else
        drone.target = randi(params.grid_size, 1, 2);
    end

    % bounds checking
    drone.position(1) = max(1, min(size(fire, 1), drone.position(1)));
    drone.position(2) = max(1, min(size(fire, 2), drone.position(2)));
end

% ------- douse fire -------
if (drone.water_level >= 1 && isequal(drone.position, drone.target) || (drone.water_level > 1 && fire(drone.position(1), drone.position(2)) >= 0.25))
    
    fire(drone.position(1), drone.position(2)) = 0;
    if(drone.position(1) > 1)
        fire(drone.position(1) - 1, drone.position(2)) = max(0, fire(drone.position(1) - 1, drone.position(2)) - 0.5);
    end
    if(drone.position(1) < params.grid_size - 2)
        fire(drone.position(1) + 1, drone.position(2)) = max(0, fire(drone.position(1) + 1, drone.position(2)) - 0.5);
    end
    if(drone.position(2) > 1)
        fire(drone.position(1), drone.position(2) - 1) = max(0, fire(drone.position(1), drone.position(2) - 1) - 0.5);
    end
    if(drone.position(2) < params.grid_size - 2)
        fire(drone.position(1), drone.position(2) + 1) = max(0, fire(drone.position(1), drone.position(2) + 1) - 0.5);
    end

    drone.water_level = drone.water_level - 1;
    drone.fire_cells_extinguished = drone.fire_cells_extinguished + 1;
    if isequal(drone.position, drone.target)
        drone.has_target = false;
    end
end

% ------- return values -------
newFireGrid = fire;
newDrone = drone;

end