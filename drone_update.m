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
    for xi=1:size(fire, 1)
        for yi=1:size(fire, 2)
            fireScore = (droneFurthestTarget - norm([xi, yi] - drone.position)) * fire(xi, yi);
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
        drone.has_target = false;
    end
end

if(drone.has_target)
    % calculate drone vel
    droneGoalVelHorz = sign(drone.target(1) - drone.position(1));
    droneGoalVelVert = sign(drone.target(2) - drone.position(2));
    % calculate drone move goal
    droneMoveGoalHorz = drone.position(1) + droneGoalVelHorz;
    droneMoveGoalVert = drone.position(2) + droneGoalVelVert;
    
    % ------- update drone position -------
    % check collisions
    collisions = {[], [], []};
    for di=1:length(drones)
        if(di == droneIndex) continue; end
        % if a drone is in the way of this drone
        % put the move goal blocker in collisions(1)
        % put a horizontal blocker in collisions(2)
        % put a vertical blocker in collisions(3)
        if isequal(drones(di).position, [droneMoveGoalHorz, droneMoveGoalVert])
            collisions{1} = drones(di);
        end
        if (droneGoalVelHorz ~= 0 && isequal(drones(di).position, [droneMoveGoalHorz, drone.position(2)]))
            collisions{2} = drones(di);
        end
        if (droneGoalVelVert ~= 0 && isequal(drones(di).position, [drone.position(1), droneMoveGoalVert]))
            collisions{3} = drones(di);
        end
    end
    % move if possible
    if isempty(collisions{1})
        drone.position = [droneMoveGoalHorz, droneMoveGoalVert];
    else
        if isempty(collisions{2}) && droneGoalVelHorz ~= 0
            drone.position(1) = droneMoveGoalHorz;
        elseif isempty(collisions{3}) && droneGoalVelVert ~= 0
            drone.position(2) = droneMoveGoalVert;
        else
            % unable to move anywhere
        end
    end
    
    % bounds checking
    drone.position(1) = max(1, min(size(fire, 1), drone.position(1)));
    drone.position(2) = max(1, min(size(fire, 2), drone.position(2)));
end

% ------- douse fire -------
if (drone.water_level >= 1 && isequal(drone.position, drone.target) || (drone.water_level > 1 && fire(drone.position(1), drone.position(2)) >= 0.25))
    fire(drone.position(1), drone.position(2)) = 0;
    drone.water_level = drone.water_level - 1;
    if isequal(drone.position, drone.target)
        drone.has_target = false;
    end
end

% ------- return values -------
newFireGrid = fire;
newDrone = drone;

end