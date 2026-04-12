function drone = make_drone(numdrones)

drone(numdrones).position = []; % to stop resizing for performance
for n=1:numdrones
    drone(n).position = [1 1];
    drone(n).target = [1 1];
    drone(n).has_target = false;
    drone(n).water_level = 5;
    drone(n).logs = {};
end

end