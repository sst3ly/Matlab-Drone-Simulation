function make_summary(drones)

arguments (Input)
    drones
end

% ---- save drone data ----
droneStatistics = table('Size', [length(drones), 4], ...
    'VariableTypes', {'double', 'double', 'double', 'double'}, ...
    'VariableNames', { 'DroneIndex', 'FireCellsExtinguished', 'DistanceTravelled', 'TimesRefilled' });

for di=1:length(drones)
    droneStatistics(di, :) = { di, drones(di).fire_cells_extinguished, drones(di).distance_travelled, drones(di).times_refilled };
end

writetable(droneStatistics, "saved_data/drone_summary.csv");

end