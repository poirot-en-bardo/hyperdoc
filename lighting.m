cube_data = load("data/MPD60a.mat");
cube = cube_data.cube.DataCube;
wavelength = cube_data.wl;

%% loading illuminant and cmf data
illum_a = readmatrix("data/illuminants_cmfs.xlsx","Sheet","A_D50_D65","Range","B102:B402"); % 400-700 nm at 1 nm
illum_d50 = readmatrix("data/illuminants_cmfs.xlsx","Sheet","A_D50_D65","Range","C102:C402"); 
illum_d65 = readmatrix("data/illuminants_cmfs.xlsx","Sheet","A_D50_D65","Range","D102:D402"); 
illum_f1 = readmatrix("data/illuminants_cmfs.xlsx","Sheet","Fs","Range","B2:B62"); % 400-700 nm at 5 nm
illum_f2 = readmatrix("data/illuminants_cmfs.xlsx","Sheet","Fs","Range","C2:C62");
illum_f3 = readmatrix("data/illuminants_cmfs.xlsx","Sheet","Fs","Range","D2:D62");
CMF = readmatrix("data/illuminants_cmfs.xlsx","Sheet","CMF","Range","B10:D70");

% interpolation to 400-700 at 5 nm
illum_a = interp1(400:1:700, illum_a, 400:5:700, 'pchip')'; 
illum_d50 = interp1(400:1:700, illum_d50, 400:5:700, 'pchip')';
illum_d65 = interp1(400:1:700, illum_d65, 400:5:700, 'pchip')';

%% data processing
% extracting the visible part of the cube
max_wavelength = 700;
indices = find(wavelength <= max_wavelength);
cube_vis = cube(:, :, indices);
im = cube_vis(:,:,[50 34 9]);
imwrite(im,'vis.png')

% Visualisation with D50
srgb_d50 = visualise_illuminated(cube_vis, illum_d50, CMF);
srgb_d65 = visualise_illuminated(cube_vis, illum_d65, CMF);
srgb_a = visualise_illuminated(cube_vis, illum_a, CMF);
srgb_f1 = visualise_illuminated(cube_vis, illum_f1, CMF);
srgb_f2 = visualise_illuminated(cube_vis, illum_f2, CMF);
srgb_f3 = visualise_illuminated(cube_vis, illum_f3, CMF);


%% loading illuminant and cmf data
illum_a_ext = readmatrix("data/illuminants_cmfs.xlsx","Sheet","A_D50_D65","Range","B102:B482"); % 400-700 nm at 1 nm
illum_d50_ext = readmatrix("data/illuminants_cmfs.xlsx","Sheet","A_D50_D65","Range","C102:C482"); 
illum_d65_ext = readmatrix("data/illuminants_cmfs.xlsx","Sheet","A_D50_D65","Range","D102:D482"); 
CMF_ext = readmatrix("data/illuminants_cmfs.xlsx","Sheet","CMF","Range","B10:D86");

% interpolation to 400-700 at 5 nm
illum_a_ext = interp1(400:1:780, illum_a_ext, 400:5:780, 'pchip')'; 
illum_d50_ext = interp1(400:1:780, illum_d50_ext, 400:5:780, 'pchip')';
illum_d65_ext = interp1(400:1:780, illum_d65_ext, 400:5:780, 'pchip')';

%% data processing
% extracting the visible part of the cube
max_wavelength = 780;
indices = find(wavelength <= max_wavelength);
cube_vis = cube(:, :, indices);
im = cube_vis(:,:,[50 34 9]);
imwrite(im,'vis.png')

% Visualisation with D50
srgb_d50 = visualise_illuminated(cube_vis, illum_d50_ext, CMF_ext);
srgb_d65 = visualise_illuminated(cube_vis, illum_d65_ext, CMF_ext);
srgb_a = visualise_illuminated(cube_vis, illum_a_ext, CMF_ext);


%% Function to visualise the document under different illuminants
function [srgb_image] = visualise_illuminated(reflectance_cube, spd, cmf)

[ref_length, ref_width, bands] = size(reflectance_cube);
flat_cube = reshape(reflectance_cube, [], bands);
k = 100 / (cmf(:, 2)' * spd);
XYZ_d50 = k * flat_cube * diag(spd) * cmf;

% conversion to srgb
srgb_d50 = xyz2srgb(XYZ_d50);
max( srgb_d50,[],'all')
srgb_image = uint8(reshape(srgb_d50, ref_length, ref_width, 3));
figure; imshow(srgb_image);

if ~exist('visualisation', 'dir')
   mkdir('visualisation')
end
imwrite(srgb_image, ['visualisation/srgb_' inputname(2) '.png']);
end
