function valid = validate_single(expDS_entry,ecm_params, model_name, opts)
    arguments
        expDS_entry (1,:) table
        ecm_params table
        model_name string {mustBeTextScalar}
        opts.plsname string {mustBeTextScalar} = ""
        opts.fittag string {mustBeTextScalar} = ""
    end

    simOut = TEVP.run_sim(expDS_entry, model_name, ecm_params);
    simRes = TEVP.extract_simRes(simOut);
    simRes = rmfield(simRes,"tout");
    simRes = rmfield(simRes,"I_cell");

    valid = table();
    valid.plsname(1) = opts.plsname;
    valid.fittag(1) = opts.fittag;
    valid.ecm_params(1) = {ecm_params};
    valid.simRes(1) = {simRes};
    valid.rmse = sqrt(mean((expDS_entry.data{1}.E - simRes.U_cell).^2));
    valid.max_abs_error = max(abs(expDS_entry.data{1}.E - simRes.U_cell));

end