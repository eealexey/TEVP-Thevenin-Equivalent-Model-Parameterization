function expDS = init_expDS(N)
% initilize expDS table
    expDS = table();
    expDS.name = string.empty(N,0);
    expDS.AH = NaN(N,1);
    expDS.initialSOC = NaN(N,1);
    expDS.SOC_OCV = cell(N,1);
    expDS.data = cell(N,1);
    expDS.valid = cell(N,1);
    % expDS.valid = struct.empty(N,0);
    % expDS.valid{1} = [];
end