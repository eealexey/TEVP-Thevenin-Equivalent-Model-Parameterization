function plsDS = massParamEstim(plsDS,opts)
% runs parameter estimation for a every enetery in plsDS
% i.e. runs singleParamEstim for a every enetery in plsDS and adds resulted fitres-structures to the modified output plsDS
% plsDS - the only mandatory input
% all optional inputs are same as for the singleParamEstim

    arguments
        plsDS table
        % IMPORTANT! optional argument blocks in singleParamEstim AND massParamEstim MUST be the SAME
        opts.freedom_vec (1,5) {mustBeNumericOrLogical} = [0 1 1 1 1]
        opts.relax_tail {mustBeNumeric, mustBeScalarOrEmpty, mustBeNonempty} = 100
        opts.model_name string {mustBeTextScalar} = "inputModel_2RC_fit"
        opts.fittag string {mustBeTextScalar} = "2RC_R0fixed"
        opts.OptimOptions
    end


    Npls = size(plsDS,1);
    for idx = 1:Npls
        
        if isfield(opts,"OptimOptions")
            fitres = TEVP.singleParamEstim(plsDS(idx,:), freedom_vec = opts.freedom_vec, relax_tail = opts.relax_tail, model_name = opts.model_name, fittag = opts.fittag, OptimOptions = opts.OptimOptions);
        else
            fitres = TEVP.singleParamEstim(plsDS(idx,:), freedom_vec = opts.freedom_vec, relax_tail = opts.relax_tail, model_name = opts.model_name, fittag = opts.fittag);
        end
        
        plsDS.fitres{idx} = [plsDS.fitres{idx}; fitres];
        fprintf('%d of %d done \n#############################################################\n', idx, Npls);
    end

end