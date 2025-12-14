function expDS = validate_prmDS_over_expDS(expDS,prmDS,opts)

    arguments
        expDS table
        prmDS table
        opts.REVALID (1,1) {mustBeNumericOrLogical} = false
    end
    REVALID = opts.REVALID;

    Nexp = size(expDS,1);
    Nprm = size(prmDS,1);
    for i = 1:Nexp
        expDS_entry = expDS(i,:);
        for j = 1:Nprm
            DOVALID = true;
            fittag = prmDS.fittag{j};
            plsname = prmDS.plsname{j};

            % check parameters waere validated already
            if REVALID == false
                
                existing_valid = expDS_entry.valid{1,1};
                nv = size(existing_valid,1);
                    for v = 1:nv
                        if (existing_valid.plsname(v) == plsname) && (existing_valid.fittag(v) == fittag)
                            DOVALID = false;
                        end
                    end
            end


            if REVALID || DOVALID
                if contains(fittag,"2RC")
                    model_name = "inputModel_2RC_valid";
                elseif contains(fittag,"1RC")
                    model_name = "inputModel_1RC_valid";
                else
                    warning("fittag does not contain valid model tag: '1RC' or '2RC'")
                    continue
                end
                disp(expDS_entry.name + " || " + prmDS.plsname(j) + " || " + prmDS.fittag(j))
                ecm_params = prmDS.prms_table{j};
                valid = TEVP.validate_single(expDS_entry,ecm_params,model_name);
                valid.fittag = prmDS.fittag(j);
                valid.plsname = prmDS.plsname(j);
                expDS_entry.valid{1,1} = [expDS_entry.valid{1,1}; valid];
            end
        end
        expDS(i,:) = expDS_entry;
    end
end