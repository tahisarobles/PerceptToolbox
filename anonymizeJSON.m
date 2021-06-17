% Anonymizing JSON files from Percept patients
% Bart Keulen 15-09-2020

close all;clear all; clc 

% Set patient ID and directories
ptID = 'NL3_JA'; % Anonymous reference to patient
save_path = append('C:\Users\tahis\Documents\Technical Medicine\Internship 3\MATLAB',filesep,ptID); % Directory for anonymous JSON files
% source_path = 'C:\Users\tahis\Documents\Technical Medicine\Internship 3\MATLAB\JSON files'; % Directory with original JSON files
source_path = 'C:\Users\tahis\Documents\Technical Medicine\Internship 3\MATLAB\JSON_3';
% List all JSON files in folder
cd(source_path)
folder_info = dir('*.json');

% For all files in folder
for file = folder_info'
    % Read JSON file and delete patient informclation
    cd(source_path)
    report = jsondecode(fileread(file.name));
    report.PatientInformation = ptID;
    json = jsonencode(report);

    % Write new JSON file with new name
    cd(save_path)
    filename_anonymous = append(ptID,'_',file.name);
    new_file = fopen(filename_anonymous,'w');
    fwrite(new_file,json);
    fclose(new_file);
end


