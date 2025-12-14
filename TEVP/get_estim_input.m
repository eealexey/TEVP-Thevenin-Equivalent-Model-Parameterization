function [prm_initguess,exp_params,IOdata] = get_estim_input(plsDS_entry,relax_tail)
% Create parameter sets for ParamEstim_2RC
% params - parameters relted to the battery model: R0, r1, tau1...
%           R2 - is considered to be related to electric double layer (small tau2 < 2.0)
% exp_params - parameters specific for the experiment (not to be estimated): initialSOC, AH, local SOC and OCV vectors
% relax_scale - the length of the relax-tale devided by the pulse duration 

    arguments
        plsDS_entry table
        relax_tail {mustBeNumeric, mustBeScalarOrEmpty}

    end
    if nargin < 2
        relax_tail = plsDS_entry.tau_pls;
    end

    % function parameters
    t_samp = 0.1;
    
    %% prepare ixperiment data - input/output signals
    Time = plsDS_entry.data{1}.Time;
    I = plsDS_entry.data{1}.I;
    U = plsDS_entry.data{1}.E;
    % cut and interpolate data 
    t_cut = plsDS_entry.tau_pls + relax_tail;
    [~, k_cut] = min(abs(Time-t_cut));
    t = [0:t_samp:Time(k_cut)]';
    I = interp1(Time,I,t,'linear');
    U = interp1(Time,U,t,'linear');
    clear Time
    % convert to timeseries
    IOdata.EXP_Sig_Input_Value = timeseries(I, t);
    IOdata.EXP_Sig_Output_Value = timeseries(U, t);
    
    %% prepare experiment-related parameters
    exp_params.AH = plsDS_entry.cellcap;
    exp_params.initialSOC = plsDS_entry.nominal_soc;
    exp_params.SOC_vec = [exp_params.initialSOC, exp_params.initialSOC + plsDS_entry.dSoC]'; 
    exp_params.OCV_vec = [plsDS_entry.Uinit, plsDS_entry.Ufin;]';% initaial and final U are assumed equlibrium
    [exp_params.SOC_vec, sort_order] = sort(exp_params.SOC_vec); % sort
    exp_params.OCV_vec = exp_params.OCV_vec(sort_order); % sort
    
    %% prepare model parameters
    prm_initguess.R0 = plsDS_entry.R0;
    prm_initguess.R1 = plsDS_entry.R1;
    prm_initguess.tau1 = plsDS_entry.tau1;
    % set default R2,tau2 if not present in the plsDS 
    if sum(string(plsDS_entry.Properties.VariableNames) == "R2") && ~isnan(plsDS_entry.R2) 
        prm_initguess.R2 = plsDS_entry.R2;
    else
        prm_initguess.R2 = plsDS_entry.R0*0.1;
    end
    if sum(string(plsDS_entry.Properties.VariableNames) == "tau2") && ~isnan(plsDS_entry.tau2)
        prm_initguess.tau2 = plsDS_entry.tau2;
    else
        prm_initguess.tau2 = 0.5;
    end

    % set params constrains
    prm_initguess.tau1_low = 0;
    prm_initguess.tau1_high = max(plsDS_entry.tau_pls, relax_tail);
    prm_initguess.tau2_low = 0;
    prm_initguess.tau2_high = max(plsDS_entry.tau_pls, relax_tail);
    % % set params constrains
    % prm_initguess.tau1_low = 0;
    % prm_initguess.tau1_high = Inf;
    % prm_initguess.tau2_low = 0;
    % prm_initguess.tau2_high = Inf;
    % set params freedom
    prm_initguess.R0_free = 0;
    prm_initguess.R1_free = 1;
    prm_initguess.tau1_free = 1;
    prm_initguess.R2_free = 1;
    prm_initguess.tau2_free = 1;

end