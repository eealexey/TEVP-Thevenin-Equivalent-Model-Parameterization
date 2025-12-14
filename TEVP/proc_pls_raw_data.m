function plsDS_entry = proc_pls_raw_data(dat, Uinit, tau_pls, cellcap, nominal_soc, name)

    %params
    idxVstep = 1; % index of volatage data-point in the discharge data-array which is used for calculating R0
    
    
    % processing
    plsDS_entry = TEVP.init_pulse_data_set(1);
    plsDS_entry.name = name;
    plsDS_entry.nominal_soc = nominal_soc;
    plsDS_entry.tau_pls = tau_pls;
    plsDS_entry.cellcap = cellcap;
    plsDS_entry.Uinit = Uinit;
    plsDS_entry.data = {dat};
    
    % I, dSoC
    [~, ix_pls] = min(abs(dat.Time - tau_pls));
    plsDS_entry.dltQ = trapz(dat.Time(1:ix_pls),dat.I(1:ix_pls));
    plsDS_entry.dSoC = plsDS_entry.dltQ/3600/cellcap;
    plsDS_entry.I = plsDS_entry.dltQ/dat.Time(ix_pls);
    % R0
    plsDS_entry.Ufin = dat.E(end);
    plsDS_entry.Udrop = Uinit - dat.E(idxVstep) ;
    plsDS_entry.R0 = plsDS_entry.Udrop/(-plsDS_entry.I);

    [R1, tau1, R2, tau2] = TEVP.init_guessR1R2(plsDS_entry, tau_offset = 0.5, tau_cutoff = 20);
    plsDS_entry.R1 = R1;
    plsDS_entry.tau1 = tau1;
    plsDS_entry.R2 = R2;
    plsDS_entry.tau2 = tau2;

    %% old way
    % plsDS_entry.R1 = ( (dat.E(end)-dat.E(ix_pls)) - plsDS_entry.Udrop )/(-plsDS_entry.I);
    % dVrelax = plsDS_entry.Ufin-dat.E(ix_pls+idxVstep);
    % V_tau1 = plsDS_entry.Ufin-dVrelax/exp(1);
    % [~, ix_tau1] = min(abs(dat.E-V_tau1));
    % plsDS_entry.tau1 = dat.Time(ix_tau1);
    % tau2_default = 1.0; % tau2 value to set
    % plsDS_entry.tau2 = tau2_default;    
    % [~, ix_tau2] = min(abs(dat.Time - plsDS_entry.tau2));
    % plsDS_entry.R2 = (dat.E(ix_tau2)-dat.E(1))/plsDS_entry.I;

end