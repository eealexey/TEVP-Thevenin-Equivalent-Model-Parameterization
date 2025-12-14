function [simRes] = extract_simRes(simOut)
% extract every signal from the simulation_output 
% and stores it as 1-d vectors in a structure;
% structure field-names correspond to signal-names within the model
% An additianal extra vector is the simulation time-points "tout"
    tout = simOut.tout;
    data_size = size(tout);
    data_size = data_size(1);
    
    simRes.tout = tout;
    dat_names = getElementNames(simOut.logsout);
    n_signals = size(dat_names,1);
    
    for i = 1:n_signals
        name = dat_names{i};
        dat = get(simOut.logsout,name);
        dat = dat.Values.Data;
        dat = reshape(dat,[data_size,1]);
        simRes.(name) = dat;
    end
end