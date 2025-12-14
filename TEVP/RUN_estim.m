% [pOpt,Info] = parameterEstimation_inputModel_2RC_fit();



load("DS_test.mat","plsDS")



model_name = "inputModel_1RC_fit";
freedom_vec = [0 1 1 1 1];
relax_scale = 1;
fittag = "1RC_R0fixed";
plsDS = TEVP.massParamEstim(plsDS,model_name=model_name,freedom_vec=freedom_vec, relax_scale=relax_scale, fittag=fittag);

model_name = "inputModel_1RC_fit";
freedom_vec = [1 1 1 1 1];
relax_scale = 1;
fittag = "1RC_R0free";
plsDS = TEVP.massParamEstim(plsDS,model_name=model_name,freedom_vec=freedom_vec, relax_scale=relax_scale, fittag=fittag); 

model_name = "inputModel_2RC_fit";
freedom_vec = [0 1 1 1 1];
relax_scale = 1;
fittag = "2RC_R0fixed";
plsDS = TEVP.massParamEstim(plsDS,model_name=model_name,freedom_vec=freedom_vec, relax_scale=relax_scale, fittag=fittag);

model_name = "inputModel_2RC_fit";
freedom_vec = [1 1 1 1 1];
relax_scale = 1;
fittag = "2RC_R0free";
plsDS = TEVP.massParamEstim(plsDS,model_name=model_name,freedom_vec=freedom_vec, relax_scale=relax_scale, fittag=fittag);

% save("plsDS_soc50fr.mat","plsDS")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% model_name = "inputModel_2RC_fit";
% freedom_vec = [1 1 1 1 1];
% relax_scale = 2;
% fittag = "2RC_R0free_rlx2";
% plsDS = TEVP.massParamEstim(plsDS,model_name=model_name,freedom_vec=freedom_vec, relax_scale=relax_scale, fittag=fittag);
% 
% model_name = "inputModel_2RC_fit";
% freedom_vec = [1 1 1 1 1];
% relax_scale = 4;
% fittag = "2RC_R0free_rlx4";
% plsDS = TEVP.massParamEstim(plsDS,model_name=model_name,freedom_vec=freedom_vec, relax_scale=relax_scale, fittag=fittag);

% plsDS_ent = plsDS(1,:);
% plsDS_ent.fitres{1}(5:6) = [];
% 
% model_name = "inputModel_2RC_fit";
% freedom_vec = [1 1 1 1 1];
% relax_scale = 4;
% fittag = "2RC_R0free_rlx4";
% plsDS_ent = TEVP.massParamEstim(plsDS_ent,model_name=model_name,freedom_vec=freedom_vec, relax_scale=relax_scale, fittag=fittag);
% 
% model_name = "inputModel_2RC_fit";
% freedom_vec = [1 1 1 1 1];
% relax_scale = 16;
% fittag = "2RC_R0free_rlx16";
% plsDS_ent = TEVP.massParamEstim(plsDS_ent,model_name=model_name,freedom_vec=freedom_vec, relax_scale=relax_scale, fittag=fittag);