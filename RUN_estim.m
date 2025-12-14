
file_names = ["plsDS"]; % names of mat-files containing plsDS
relax_tail = 90; % relaxation period to fit
model_name = "inputModel_2RC_fit"; % 2RC model - "inputModel_2RC_fit"; 1RC model - "inputModel_1RC_fit"
freedom_vec = [1 1 1 1 1]; % fit all 5 parameters ( [1 1 1] in case of 1RC)
model_tag = "2RC_R0free"; % just a text tag for model used

% Initial guess valuses for the model parameters
PI.R0 = 0.025;
PI.R1 = 0.01;
PI.tau1 = 3.0;
PI.R2 = 0.03;
PI.tau2 = 80.0;

for fn = 1:numel(file_names)
    file_name = file_names(fn);
    load(file_name+".mat","plsDS")

    plsDS = plsDS(1:2,:);

    Np = size(plsDS,1);
    for p = 1:Np
        if p == 1
            plsDS.R0(p) = PI.R0;  
            plsDS.R1(p) = PI.R1;  
            plsDS.tau1(p) = PI.tau1;  
            plsDS.R2(p) = PI.R2;  
            plsDS.tau2(p) = PI.tau2; 
        else
            plsDS.R0(p) = plsDS.fitres{p-1,1}(1).R0;  
            plsDS.R1(p) = plsDS.fitres{p-1,1}(1).R1;  
            plsDS.tau1(p) = plsDS.fitres{p-1,1}(1).tau1;  
            plsDS.R2(p) = plsDS.fitres{p-1,1}(1).R2;  
            plsDS.tau2(p) = plsDS.fitres{p-1,1}(1).tau2; 
        end

        fittag = model_tag+string(sprintf('_rlx%u_1tau%.1f_2tau%.1f',relax_tail,plsDS.tau1(p),plsDS.tau2(p)));
        plsDS(p,:) = TEVP.massParamEstim(plsDS(p,:),model_name=model_name,freedom_vec=freedom_vec, relax_tail=relax_tail, fittag=fittag);

        plsDS.R0(p) = plsDS.fitres{p,1}(1).R0;  
        plsDS.R1(p) = plsDS.fitres{p,1}(1).R1;  
        plsDS.tau1(p) = plsDS.fitres{p,1}(1).tau1;  
        plsDS.R2(p) = plsDS.fitres{p,1}(1).R2;  
        plsDS.tau2(p) = plsDS.fitres{p,1}(1).tau2; 
    end
    save(file_name+"_"+model_tag+".mat","plsDS")
end