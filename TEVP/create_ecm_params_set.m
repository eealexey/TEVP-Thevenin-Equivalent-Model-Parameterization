function ecm_params = create_ecm_params_set(plsDS, plsname_part, fittag_part)
% creates a single entry prmDS from estimated parameters in input plsDS
% This function unites parameters from similar fit-results (for similar pulses) at different soc
% plsname_part - is string array containing common parts of pulse-names to search in plsDS
% i.e. "1Cdch_9sec" in plsname_part is used to select "soc95_1Cdch_9sec", "soc90_1Cdch_9sec", "soc85_1Cdch_9sec" etc 
% fittag_part - is string array containing common parts of fit-tags to search in plsDS, e.g. "2RC_R0free_rlx36"
% The function searches plsDS for all simultaneous matches plsname nad fittag 


    if contains(fittag_part, "2RC")
        T = table('Size', [0,8], 'VariableTypes', {'double', 'string', 'string', 'double','double','double','double','double'}, 'VariableNames', {'nominal_soc', 'plsname', 'fittag', 'R0', 'R1', 'tau1','R2', 'tau2'});
        nRC = 2; 
    elseif contains(fittag_part, "1RC")
        T = table('Size', [0,6], 'VariableTypes', {'double', 'string', 'string', 'double','double','double'}, 'VariableNames', {'nominal_soc', 'plsname', 'fittag', 'R0', 'R1', 'tau1'});
        nRC = 1;
    else
        quit();
    end
    
    Npls = size(plsDS,1);
    for p = 1:Npls
        if contains(plsDS.name(p),plsname_part)
            Nf = size(plsDS.fitres{p,1},1);
            for i = 1:Nf
                if contains(plsDS.fitres{p,1}(i).fittag,fittag_part)
                    C = cell(1,6);
                    C{1} = plsDS.nominal_soc(p);
                    C{2} = plsDS.name(p);
                    C{3} = plsDS.fitres{p,1}(i).fittag;
                    C{4} = plsDS.fitres{p,1}(i).R0;
                    C{5} = plsDS.fitres{p,1}(i).R1;
                    C{6} = plsDS.fitres{p,1}(i).tau1;
                    if nRC == 2
                        C{7} = plsDS.fitres{p,1}(i).R2;
                        C{8} = plsDS.fitres{p,1}(i).tau2;
                    end
                    T(end+1,:) = C;
                end
            end
        end
    end
    T = sortrows(T,'nominal_soc');
    ecm_params = T;
end