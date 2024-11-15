% Add the GSW toolbox to your path before running this script
% Ensure that the GSW toolbox is installed in MATLAB
% addpath('path_to_gsw_toolbox');

% Specify the folder containing the Excel files
folderPath = 'D:\Downloads\test_data_processed';

% List all Excel files in the folder
fileList = dir(fullfile(folderPath, '*.csv'));
numFiles = numel(fileList);

% Loop through each file
for i = 1:numFiles
    filePath = fullfile(fileList(i).folder, fileList(i).name);
    try
        data = readtable(filePath, 'VariableNamingRule', 'preserve');

        % Check for required columns
        requiredColumns = {'DATE (YYYY-MM-DDTHH:MI:SSZ)', 'LONGITUDE (degree_east)', 'LATITUDE (degree_north)', 'PRES (decibar)', 'TEMP (degree_Celsius)', 'PSAL (psu)'};
        if all(ismember(requiredColumns, data.Properties.VariableNames))
            % Extract the month from the 'DATE' column and add a new column 'MONTH'
            data.MONTH = extractBetween(data.('DATE (YYYY-MM-DDTHH:MI:SSZ)'), 6, 7);

            % Calculate the rho_TEOS10 column
            % Ensure the GSW functions are available
            SA = gsw_SA_from_SP(data.('PSAL (psu)'), data.('PRES (decibar)'), data.('LONGITUDE (degree_east)'), data.('LATITUDE (degree_north)'));
            CT = gsw_CT_from_t(SA, data.('TEMP (degree_Celsius)'), data.('PRES (decibar)'));
            data.rho_TEOS10 = gsw_rho(SA, CT, data.('PRES (decibar)'));

            % Write the modified table back to the Excel file
            writetable(data, filePath);
        else
            % If any column is missing, delete the file
            delete(filePath);
        end
    catch ME
        % Handle any errors (e.g., if the file is open or corrupted)
        fprintf('Error processing file %s: %s\n', fileList(i).name, ME.message);
    end
end
disp('Processing completed for all files.');
