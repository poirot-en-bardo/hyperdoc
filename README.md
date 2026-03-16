# Hyperdoc Internship Project

This project is centred on simulating different illumination types upon manuscripts of historical interest. 
The main function is *simulate_illumination* and it uses the reflectance hypercube of the target (the manuscript), as well as the chosen illuminants. 

The predefined illuminants are included in *illuminants_table.mat*, but the user can edit this table to add, remove or update the illuminants, using the static methods of the *IlluminantOperations* class.

This tool was developed during an internship at the University of Granada (UGR) and later integrated into the broader HYPERDOC toolbox for heritage imaging and manuscript analysis.



## Features

- Simulate manuscript appearance under **custom or standard illuminants**.  
- Use hyperspectral reflectance data to generate **realistic visual renderings**, based on chromatic adaptation.  
- Easily **modify illuminants** without altering core code.  
- Explore the impact of light on **legibility, pigment perception, and material contrast**.  


## Usage

1. Load a **reflectance hypercube** of your manuscript.  
2. Select an **illuminant** (from the table or custom-defined).  
3. Run `simulate_illumination` to generate the simulated output.  
4. If needed, update `illuminants_table.mat` using `IlluminantOperations`.  

