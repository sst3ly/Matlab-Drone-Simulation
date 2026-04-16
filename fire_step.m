function [new_fire] = fire_step(tiles, params)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    tiles
    params
end

arguments (Output)
    new_fire
end

% ------- Decay -------
% 
for x = 1 : length(tiles)
    for y = 1 : length(tiles)
        if tiles(x,y) > 0
        tiles(x,y) = tiles(x,y) - params.decay_rate;
            tiles(x,y) = max(0,tiles(x,y));
        end
    end
end

% ------- Spread -------
% 
for x = 1 : length(tiles)
    for y = 1 : length(tiles)
        if tiles(x,y) > 0
            if x > 2
            tiles(x-1 , y) = tiles(x-1 , y) + params.spread_rate;
                tiles(x-1,y) = min(1,tiles(x-1,y));
            end
            if x < params.grid_size - 1
            tiles(x+1 , y) = tiles(x+1 , y) + params.spread_rate;
                tiles(x+1,y) = min(1,tiles(x+1,y));
            end
            if y > 2
            tiles(x , y-1) = tiles(x , y-1) + params.spread_rate;
                tiles(x,y-1) = min(1,tiles(x,y-1));
            end
            if y < params.grid_size - 1
            tiles(x , y+1) = tiles(x , y+1) + params.spread_rate;
                tiles(x,y+1) = min(1,tiles(x,y+1));
            end
        end
    end
    new_fire = tiles;
end
        