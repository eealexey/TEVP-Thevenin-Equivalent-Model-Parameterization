function expDS = mass_validate_plsDS_over_expDS(plsDS, expDS)

    Npls = size(plsDS,1);
    for idx =1:Npls
        Nfr = size(plsDS.fitres{idx},1);
        for k = 1:Nfr
            fitres = plsDS.fitres{idx}(k);
            expDS = TEVP.validate_fitres_over_expDS(expDS,fitres);
        end
    end

end