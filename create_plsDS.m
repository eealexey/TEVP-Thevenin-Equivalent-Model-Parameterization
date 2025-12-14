%%
% Script to extract data about test-pulses and convert it 
% into "pulse Data Set" table  plsDS for further use with TEVP library
%%

%% CHANGE THESE PARAMETERS FOR YOUR EXPERIMENT
csv_folder = ".\П1-047\101-1-3-П1-047_processed\";
Npls = 36; % number of test pulses to process
Cap_nom = 1.5; % cell capacity value to calculate SoC
soc_list = [100:-2.5:12.5]'/100; % list of soc values for the processed experimental series
tau = 45; % pulse duration (seconds, precise value)
tag = "pls45"; % just a text-tag for pulse duration (i.e. 45 seconds pulses - "pls45")
%%

data = import_csv(csv_folder+"000.csv");
previous_end_voltage = data.E(end); % get rest voltage before the 1st pulse
plsDS = [];
for i = 1:Npls
    label = "soc"+sprintf("%.01f",soc_list(i)*100)+"_"+tag;
    soc_nom = soc_list(i);
    data = import_csv(csv_folder+sprintf("%.03d",i)+".csv");
    D1 = TEVP.proc_pls_raw_data(data,previous_end_voltage,tau, Cap_nom, soc_nom, label);
    plsDS = [plsDS; D1];
    previous_end_voltage = data.E(end);

    if sum(diff(data.Time) == 0)
        df = diff(data.Time);
        fprintf("Warning! Same timestamp in pls %d",i)
    end
end
%% CHANGE the output mat-file name IF NEEDED
save("plsDS.mat", "plsDS")

%%
function data = import_csv(filename, dataLines)
%IMPORTFILE Import data from a text file
%% Input handling
% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["Step", "Time", "I", "E", "Var5"];
opts.SelectedVariableNames = ["Step", "Time", "I", "E"];
opts.VariableTypes = ["double", "double", "double", "double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Var5", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Var5", "EmptyFieldRule", "auto");

% Import the data
data = readtable(filename, opts);

end
