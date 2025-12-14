function fitres = singleParamEstim(plsDS_entery,opts)
% runs parameter estimation for a single enetery of plsDS
% returen fitres structure, which is supposed to be addede to the plsDS (plsDS.fitres{idx} = [plsDS.fitres{idx}; fitres];)
% plsDS_entery - single row from plsDS table (the only mandatory argument)
% optional arguments (argname = arg_value)
% freedom_vec - array[1,5]; elements controls frredom of the ecm parameters (0 - fixed, 1 - free) - [R0, R1, tau1, R2, tau2] 
% ... override default settings of .*_free in prm_initguess produced by TEVP.get_estim_input
% relax_scale - the length of the relax-tale devided by the pulse duration, passed directly to TEVP.get_estim_input
% model_name - string, the name of the *.slx model used: "inputModel_2RC_fit" or "inputModel_1RC_fit"
% fittag - string, just a text label for the result

    arguments
        plsDS_entery (1,:) table
        % IMPORTANT! optional argument blocks in singleParamEstim AND massParamEstim MUST be the SAME
        opts.freedom_vec (1,5) {mustBeNumericOrLogical} = [0 1 1 1 1]
        opts.relax_tail {mustBeNumeric, mustBeScalarOrEmpty} = 100
        opts.model_name string {mustBeTextScalar} = "inputModel_2RC_fit"
        opts.fittag string {mustBeTextScalar} = "2RC_R0fixed"
        opts.OptimOptions
    end
    [prm_initguess,exp_params,IOdata] = TEVP.get_estim_input(plsDS_entery, opts.relax_tail);
    prm_initguess.R0_free   = opts.freedom_vec(1);
    prm_initguess.R1_free   = opts.freedom_vec(2);
    prm_initguess.tau1_free = opts.freedom_vec(3);
    prm_initguess.R2_free   = opts.freedom_vec(4);
    prm_initguess.tau2_free = opts.freedom_vec(5);
    
    fprintf('%s | %s\n',plsDS_entery.name, opts.fittag)
    if isfield(opts,"OptimOptions")
        [pOpt,OptInfo,OptimOptions] = TEVP.ParamEstim_nRC(prm_initguess,exp_params,IOdata,opts.model_name,opts.OptimOptions);
    else
        [pOpt,OptInfo,OptimOptions] = TEVP.ParamEstim_nRC(prm_initguess,exp_params,IOdata,opts.model_name);
    end
    OptInfo.EstimTime = seconds(OptInfo.Stats.EndTime - OptInfo.Stats.StartTime);
    fprintf('Estimation time (s): %.1f\n',OptInfo.EstimTime);

    fitres = struct();
    fitres.plsname = plsDS_entery.name;
    fitres.fittag = opts.fittag;
    fitres.model_name = opts.model_name;
    fitres.prm_initguess = prm_initguess;
    fitres.exp_params = exp_params;
    fitres.relax_tail = opts.relax_tail;
    % fitres.IOdata = IOdata;
    fitres.OptimOptions = OptimOptions;
    fitres.pOpt = pOpt;
    fitres.OptInfo = OptInfo;

    params = TEVP.simulink_params_to_table(pOpt);
    fitres.R0 = params.R0;
    fitres.R1 = params.R1;
    fitres.tau1 = params.tau1;
    if size(pOpt,1) == 5
        fitres.R2 = params.R2;
        fitres.tau2 = params.tau2;
    elseif size(pOpt,1) == 3
        fitres.R2 = NaN;
        fitres.tau2 = NaN;
    end
    fitres.resnorm = OptInfo.SolverOutput.resnorm;
    fitres.exitflag = OptInfo.exitflag;

end