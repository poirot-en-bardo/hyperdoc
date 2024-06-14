%% CRUD operations on the illuminants_table.mat file
% can be accessed as: IlluminantOperations.function_name
% e.g. IlluminantOperations.add_illuminant(name, spd);

classdef IlluminantOperations
    methods(Static)

        % Function to load the illuminants table
        function illuminants_table = load_illuminants_table()
            load illuminants_table.mat illuminants_table;
        end
        

        % Function to add a new illuminant to the table
        function add_illuminant(name, spd)
            % the name should be of the format 'Illuminant_Name_Example'
            % the spd should be an nx1 matrix;

            % Constraint so that the fields are not empty
            if isempty(name) || isempty(spd)
                error('Name and SPD cannot be empty.');
            end
        
            % Load the existing table
            illuminants_table = IlluminantOperations.load_illuminants_table();
            
            % Check if the name already exists in the table
            if any(strcmp(illuminants_table.Name, name))
                error('An illuminant with the same name already exists.');
            end
            
            % Add the new illuminant
            new_row = {name, spd}; % Create a cell array for the new row
            illuminants_table = [illuminants_table; new_row]; % Append the new row
            
            % Save the updated table
            save illuminants_table.mat illuminants_table;
        end

        
        % Function to retrieve illuminant data from the table
        function spd = get_illuminant_by_name(name)
            % Load the existing table
            illuminants_table = IlluminantOperations.load_illuminants_table();
            
            % Find the illuminant by name
            idx = find(strcmp(illuminants_table.Name, name), 1);
            if ~isempty(idx)
                spd = illuminants_table.SPD{idx};
            else
                error(['Illuminant ' name ' not found.']);
            end
        end
        

        % Function to update an existing illuminant in the table
        function update_illuminant(name, new_spd)
            % the name should be of the format 'Illuminant_Name_Example'
            % the spd should be an nx1 matrix;

            % Constraint so that the fields are not empty
            if isempty(name) || isempty(new_spd)
                error('Name and SPD cannot be empty.');
            end
            
            % Load the existing table
            illuminants_table = IlluminantOperations.load_illuminants_table();
            
            % Find the illuminant by name
            idx = find(strcmp(illuminants_table.Name, name), 1);
            if ~isempty(idx)
                illuminants_table.SPD{idx} = new_spd;
                % Save the updated table
                save illuminants_table.mat illuminants_table;
            else
                error(['Illuminant ' name ' not found.']);
            end
        end

        
        % Function to delete an illuminant from the table
        function delete_illuminant(name)
            % Load the existing table
            illuminants_table = IlluminantOperations.load_illuminants_table();
            
            % Find the illuminant by name
            idx = find(strcmp(illuminants_table.Name, name), 1);
            if ~isempty(idx)
                % Remove the illuminant
                illuminants_table(idx, :) = [];
                % Save the updated table
                save illuminants_table.mat illuminants_table;
            else
                error(['Illuminant ' name ' not found.']);
            end
        end
    end
end