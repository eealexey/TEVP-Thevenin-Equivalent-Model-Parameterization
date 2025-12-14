function expDS = validate_fitres_over_expDS(expDS,fitres)
% validate fitres on all expirements in expDS
    Nexp = size(expDS,1);
    ecm_params = TEVP.simulink_params_to_table(fitres.pOpt);
    for idx = 1:Nexp
        expDS_entry = expDS(idx,:);
        model_name = replace(fitres.model_name,"fit","valid");
        valid = TEVP.validate_single(expDS_entry,ecm_params, model_name, plsname = fitres.plsname, fittag = fitres.fittag);
        valid.fitres = fitres;
        expDS.valid{idx} = [expDS.valid{idx}; valid];
    end
end