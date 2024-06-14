
%% Loading reflectance data
cube_data = load("data/MPD60a.mat");
cube = cube_data.cube.DataCube;
wavelength = cube_data.wl;

%% Testing the simulation
gamma = 2.4;
D = 0.9;

% Checking the names of the illuminants to choose those of interest
load illuminants_table.mat illuminants_table;
disp(illuminants_table.Name);

illuminant_names = {'D65', 'CRS', 'Philips_TH', 'CREE'};
simulations = simulate_illumination(cube, 400:5:1000, illuminant_names, ...
    gamma, D);

%% Example of how to add an illuminant
spd = [2, 123, 123, 23, 2, 23, 123, 0.02, 1232, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2]';
name = 'test1';
IlluminantOperations.add_illuminant(name, spd);

%% Example of how to retrieve an spd
spd_D65 = IlluminantOperations.get_illuminant_by_name('D65');

%% Example of how to delete an illuminant
IlluminantOperations.delete_illuminant('test1');

