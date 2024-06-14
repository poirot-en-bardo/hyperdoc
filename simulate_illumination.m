function simulations = simulate_illumination(reflectance_cube, reflectance_range, ...
    illuminant_names, gamma, D)

    % Description:
    %   This function simulates the appearance of a reflectance cube under 
    %   different illuminants, both with simple visualisation and using 
    %   chromatic adaptation with the CIECAM02 model.
    %
    %
    % Input Arguments:
    %   reflectance_cube - A 3D matrix representing the reflectance data 
    %                      (height x width x channels)
    %   reflectance_range - A vector specifying the wavelength values for 
    %                       each channel in reflectance_cube (e.g.
    %                       400:5:1000)
    %   illuminant_names - A cell array of strings specifying the names of 
    %                      the chosen illuminants (e.g. {'D65', 'FL1', 'LED1'})
    %   gamma            - A scalar value for gamma correction; commonly
    %                      used values are 2.2 (standard) and 2.4
    %   
    %   D                - The degree of adaptation to the illuminant (in 
    %                      the CIECAM02 model), in the range 0-1; the 
    %                      default value that can be used is 0.9
    %
    % Output Arguments:
    %   simulations - A structure containing the simulated 
    %                 results under different illuminants:
    %       - .simple_illum: Struct of sRGB images (in range [0,1])
    %                        obtained through simple visualisation under 
    %                        each illuminant, identifiable by the 
    %                        illuminant names
    %       - .adapted_images: Struct of sRGB images (in range [0,1])
    %                          with chromatic adaptation obtained using 
    %                          CIECAM02, identifiable by the 
    %                          illuminant names
    %
    % Author:
    %   Eliza Balica (balica.eliza@gmail.com)
    %
    % Date:
    %   June 11, 2024


    % 1931 Colour Matching Functions and all the illuminants
    load CMFs.mat CMFs;
    load illuminants_table.mat illuminants_table;

    working_range = 400:5:780; % the visible range

    % Check if the initial reflectance range covers the working range
    if min(reflectance_range) > min(working_range) || ...
        max(reflectance_range) < max(working_range)
        error('The reflectance range must include the range of 400 to 780 nm.');
    end

    % Retrieving the chosen illuminants
    illuminant_data = cell(size(illuminant_names));
    for i = 1:length(illuminant_names)
        illuminant_data{i} = get_illuminant_by_name(illuminants_table, ...
            illuminant_names{i});
    end
    
    clear illuminants_table;

    % Interpolating the reflectance data to the working range
    [height, width, channels] = size(reflectance_cube);
    reflectance_cube_reshaped = reshape(reflectance_cube, [], channels);
    reflectance_cube_interpolated = interp1(reflectance_range, ...
        reflectance_cube_reshaped', working_range, 'pchip', 0)';
    cube_vis = reshape(reflectance_cube_interpolated, height, width, ...
        length(working_range));

    
    % Interpolating the illuminants and the CMFs to the target range
    CMFs = interp1(360:5:830, CMFs, working_range, 'pchip');
    for i = 1:length(illuminant_data)
        interpolated_illuminant = interp1(400:1:780, illuminant_data{i}, ...
            working_range, 'pchip')';
        illuminant_data{i} = interpolated_illuminant;
    end
    
    
    %  ==========  Simple visualisation under different illuminants  ==========
    
    % Obtaining the sRGB visualisation from the spectral data, one for each
    % illuminant
    results_simple_illum = struct();
    for i = 1:length(illuminant_names)
        illuminant = illuminant_data{i};
        results_simple_illum.(illuminant_names{i}) = spectral_to_sRGB( ...
            cube_vis, gamma, illuminant, CMFs);
    
        % Displaying the results
        figure;
        imshow(results_simple_illum.(illuminant_names{i}));
        title(['Preliminary visualisation under ' illuminant_names{i}], ...
            'Interpreter','none');
    end
    
    
    %  ================ CIECAM02 chromatic adaptation =================
    
    % Applying chromatic adaptation
    results_ciecam = struct();
    for i = 1:length(illuminant_data)
        illuminant_name = illuminant_names{i};
        illuminant = illuminant_data{i};
        [XYZ_flat, XYZw] = calculate_XYZs(cube_vis, illuminant, CMFs);
    
        results_ciecam.(illuminant_name) = XYZtoCiecam_v2(XYZ_flat, ...
            XYZw, D);
    end
    
    
    adapted_images = struct();
    [height, width, ~] = size(cube_vis);
    
    % Conversion of the CIECAM results to sRGB
    for i = 1:length(illuminant_names)
    
        XYZ_adapted = results_ciecam.(illuminant_names{i}).XYZ_adapted;
        XYZ_adapted = reshape(XYZ_adapted, height, width, 3);
    
        % Converting the adapted XYZ to sRGB
        adapted_images.(illuminant_names{i}) = XYZ2sRGB(XYZ_adapted, gamma);
    
        % Displaying the results
        figure;
        imshow(adapted_images.(illuminant_names{i}));
        title(['Adapted visualisation under ' illuminant_names{i}], ...
            'Interpreter','none');
    end
    
    % Output results
    simulations.simple_illum = results_simple_illum;
    simulations.adapted_images = adapted_images;
end



%% Helper functions

% Function to convert XYZ values to sRGB
function sRGB = XYZ2sRGB(XYZ, gamma)

    % Based on IEC_61966-2-1.pdf
    
    % normalization
    XYZ_normalized = max(XYZ, 0);
    Y = XYZ_normalized(:, :, 2);
    XYZ_normalized = XYZ_normalized / max(Y(:));
    
    % Image dimensions
    d = size(XYZ_normalized);
    r = prod(d(1:end-1));   % product of sizes of all dimensions except last, wavelength
    w = d(end);             % size of last dimension, wavelength
    
    % Reshape for calculation, converting to w columns with r rows.
    XYZ_flat = reshape(XYZ_normalized, [r w]);
    
    % Forward transformation from 1931 CIE XYZ values to sRGB values (Eqn 6 in
    % IEC_61966-2-1.pdf).
    M = [3.2406 -1.5372 -0.4986
        -0.9689 1.8758 0.0414
         0.0557 -0.2040 1.0570];
    RGB = (M * XYZ_flat')';
    
    % Cropping the values
    RGB = max(RGB, 0);
    RGB = min(RGB, 1);
    % Gamma correction
    sRGB = RGB.^(1/gamma);
    sRGB = reshape(sRGB, d);
    end

% Function to convert a spectral image to an sRGB image
function sRGB = spectral_to_sRGB(im, gamma, illum, xyz)

    % This function converts a spectral image to an sRGB image, with the code
    % proposed by Nascimento and Foster in http://personalpages.manchester.ac.uk/staff/david.foster/Hyperspectral_images_of_natural_scenes_04.html
    % INPUTS: im (hyperspectral image containing spectral reflectances for each pixel)
    %            
    %  gamma (gamma factor to apply to the sRGB final image). Usual
    %  values are around 2.4
    %         
    %  illum is the illumination of the scene. It must be in the same
    %  wavelength range than the image
    
    %  xyz are the CIE corresponding matching functions, again in the
    %  same range as im and illum, N x 3 where N is number of bands
    %           
    
    % Normalization
    im=im./max(im(:));
    
    [r, c, w] = size(im);
    ref_res = reshape(im, r*c, w);
    ref_res=ref_res';
    ill = repmat(illum,1,size(ref_res,2));
    
    % Computing radiances
    radiances = ref_res .* ill;
    clear im;
    clear ill;
    
    % CIE XYZ image
    % Record the size of the array radiances, and then reshape it as a matrix of w columns for matrix multiplication with the colour-matching functions
    XYZ = (xyz'*radiances)';
    % Correct the shape of XYZ so that it represents the original 2-dimensional image with three planes (rather than a matrix of 3 columns)
    XYZ = reshape(XYZ, r, c, 3);
    
    % Converting the result to sRGB
    sRGB = XYZ2sRGB(XYZ, gamma);
end


% Function to calculate the flattened XYZ values and the XYZ values of the illuminant
function [XYZ_flat, XYZw] = calculate_XYZs(reflectance_cube, illuminant, cmf)

    [~, ~, bands] = size(reflectance_cube);
    % Normalizing the XYZ values
    k = 100 / sum(illuminant .* cmf(:, 2));  
    % The XYZ values of the illuminant
    XYZ_illum = sum(illuminant .* cmf, 1);
    % Normalizing the illuminant XYZ values 
    XYZw = XYZ_illum * k;
    
    reflectance_flat = reshape(reflectance_cube, [], bands);
    XYZ_flat = k * reflectance_flat * diag(illuminant) * cmf;
end

% Function to apply chromatic adaptation using CIECAM02
function XYZtoCiecam = XYZtoCiecam_v2(XYZ, XYZw, D)
    % Transpose the XYZ and XYZw matrices for easier manipulation
    XwYwZw = XYZw';

    % Matrice for transformation
    Mcat = [0.7328 0.4296 -0.1624; -0.7036 1.6975 0.0061; 0.0030 0.0136 0.9834];

    % Reference white in RGB
    RwGwBw = Mcat * XwYwZw;
    % Conversion of XYZ to RGB
    RGB = Mcat * XYZ';
    
    % Degree of adaptation
    RcGcBc = (XwYwZw(2) * D ./ RwGwBw + 1 - D) .* RGB;
    
    % Transform back to XYZ
    XYZprima = Mcat \ RcGcBc;

    % Assign result
    XYZtoCiecam.XYZ_adapted = XYZprima';
end


% Function to retrieve SPD based on illuminant name
function spd = get_illuminant_by_name(illuminants_table, name)
    idx = find(strcmp(illuminants_table.Name, name), 1);
    if ~isempty(idx)
        spd = illuminants_table.SPD{idx};
    else
        error(['Illuminant ' name ' not found.']);
    end
end

