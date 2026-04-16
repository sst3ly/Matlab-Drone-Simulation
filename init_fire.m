function tiles = init_fire(params)

arguments (Input)
    params
end

arguments (Output)
    tiles
end


% ------- Create Grid -------
% makes an X sized grid with all values zero for inital intenisty
tiles = Zeros(params.grid_size);

% -------  -------
% 
for ii = 1 : params.tile_count
    x = randi(params.grid_size);
    y = randi(params.grid_size);
    tiles(x, y) = 1;
end

end