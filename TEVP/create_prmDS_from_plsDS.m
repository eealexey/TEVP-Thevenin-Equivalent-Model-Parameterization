function prmDS = create_prmDS_from_plsDS(plsDS)
% cretes a data-base of paramrters sets. 
% each parameters set contains parameters obtained for same pulse at different soc and under the same fitting procedure (checked by fit-tag) 

    % create a list of unique pls-names excluding 'socXX_' prefix
    plsname_list = plsDS.name(:);
    Np = numel(plsname_list);
    for i = 1:Np
        underscore_positions = strfind(plsname_list(i),'_');
        pos_cut = underscore_positions(1);
        plsname_list(i) = extractAfter(plsname_list(i), pos_cut);
    end
    plsname_list = unique(plsname_list);
    Np = numel(plsname_list);
    
    % create a list of unique fitres-tags excluding '_1tau' suffix (responsible for initiatl guess values)
    % only plsDS.fitres{1} is used to extract fit-tags, as the sets of fit-tags are supposed to be the same for different pulses 
    fittag_list = [plsDS.fitres{1,1}(:).fittag]';
    Nf = numel(fittag_list);
    for j = 1:Nf
        pos_cut = strfind(fittag_list(j), "_1tau");
        fittag_list(j) = extractBefore(fittag_list(j), pos_cut);
    end
    
    prmDS = TEVP.init_prmDS(0);
    warning('off','MATLAB:table:RowsAddedExistingVars') % turn off warning
    for i = 1:Np
        for j = 1:Nf
            ecm_params = TEVP.create_ecm_params_set(plsDS, plsname_list(i), fittag_list(j));
            prmDS.plsname(end+1) = plsname_list(i);
            prmDS.fittag(end) = fittag_list(j);
            prmDS.prms_table(end) = {ecm_params}; 
        end
    end

end