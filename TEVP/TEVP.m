 classdef TEVP
   % properties
   % end            
    methods(Static)

        plsDS_entry = proc_pls_raw_data(dat, Uinit, tau_pls, cellcap, nominal_soc, name)
        [R1, tau1, R2, tau2] = init_guessR1R2(plsDS_entry,opts)
        [prm_initguess,exp_params,IOdata] = get_estim_input(plsDS_entry,relax_scale)
        [pOpt,Info,OptimOptions] = ParamEstim_nRC(prm_initguess,exp_params,IOdata,model_name,OptimOptions)
        fitres = singleParamEstim(plsDS_entery,opts)
        plsDS = massParamEstim(plsDS,opts)
        ecm_params = create_ecm_params_set(plsDS, plsname_part, fittag_part)
        prmDS = create_prmDS_from_plsDS(plsDS)
        
        expDS_entry = pls_to_exp(plsDS_entry,relax_tail)
        simOut = run_sim(expDS_entry, model_name, ecm_params)
        expDS = validate_fitres_over_expDS(expDS,fitres)
        valid = validate_single(expDS_entry,ecm_params, model_name, opts)
        expDS = mass_validate_plsDS_over_expDS(plsDS, expDS)
        expDS = validate_prmDS_over_expDS(expDS,prmDS,opts)
        
        [simRes] = extract_simRes(simOut)

        function plsDS = init_pulse_data_set(N)
            plsDS = table();
            plsDS.name = string.empty(N,0);
            plsDS.nominal_soc = NaN(N,1);
            plsDS.cellcap = NaN(N,1);
            plsDS.tau_pls = NaN(N,1);
            plsDS.Uinit = NaN(N,1);
            plsDS.Ufin = NaN(N,1);
            plsDS.I = NaN(N,1);
            plsDS.dltQ = NaN(N,1);
            plsDS.dSoC = NaN(N,1);
            plsDS.Udrop = NaN(N,1);
            plsDS.R0 = NaN(N,1);
            plsDS.R1 = NaN(N,1);
            plsDS.tau1 = NaN(N,1);
            plsDS.R2 = NaN(N,1);
            plsDS.tau2 = NaN(N,1);
            plsDS.data = cell(N,1);%cell.empty(N,0);
            plsDS.fitres = cell(N,1); % make it struct! 
            % plsDS.fitres = struct.empty(N,0);
            plsDS.fitres{1} = [];
        end

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

        function prmDS = init_prmDS(N)
            prmDS = table('Size', [N,3],'VariableTypes', {'string', 'string','cell'},'VariableNames', {'plsname', 'fittag', 'prms_table'});
        end

        function ecm_params = simulink_params_to_table(simulink_params)
        % converts pOpt (simulink format of model aparameters) into simple table (structure in older version)
            % ecm_params = struct();
            ecm_params = table();
            N = size(simulink_params,1);
            for i = 1:N
                ecm_params.(simulink_params(i).Name) = simulink_params(i).Value;
            end
        end

    end
end