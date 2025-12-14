function expDS_entry = pls_to_exp(plsDS_entry,relax_tail)
% converts data from plsDS to expDS format
% constructs two-points OCV-SOC using Uinit,Ufin via TEVP.get_params_plsDS

    [ecm_params,exp_params,IOdata] = TEVP.get_estim_input(plsDS_entry,relax_tail);
    expDS_entry = TEVP.init_expDS(1);
    expDS_entry.name = plsDS_entry.name;
    expDS_entry.AH = exp_params.AH;
    expDS_entry.initialSOC = exp_params.initialSOC;
    SOC_OCV = table;
    SOC_OCV.SOC = exp_params.SOC_vec;
    SOC_OCV.OCV = exp_params.OCV_vec;
    expDS_entry.SOC_OCV = {SOC_OCV};
    expDS_entry.data = plsDS_entry.data; 
    
end