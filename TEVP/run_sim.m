function simOut = run_sim(expDS_entry, model_name, ecm_params)

    load_system(model_name);
    set_param(model_name+"/from_ws",'Value','1')

    t = expDS_entry.data{1}.Time;    
    I = expDS_entry.data{1}.I; 
    U = expDS_entry.data{1}.E;  
    simTime  = t(end);


    %% USING Simulink.SimulationInput
    % Use this syntax to specify values for variables in the base workspace or data dictionaries. The variable values you specify override the variable values saved in the (!)base workspace(!) or data dictionary during simulation and are reverted when the simulation completes.
   
    % simIn = Simulink.SimulationInput(model_name);
    % simIn = setVariable(simIn,'R0',ecm_params.R0);
    % simIn = setVariable(simIn,'R1',ecm_params.R1);
    % simIn = setVariable(simIn,'tau1',ecm_params.tau1);
    % simIn = setVariable(simIn,'R2',ecm_params.R2);
    % simIn = setVariable(simIn,'tau2',ecm_params.tau2);
    % 
    % simIn = setVariable(simIn,'AH',expDS_entry.AH);
    % simIn = setVariable(simIn,'initialSOC',expDS_entry.initialSOC);
    % simIn = setVariable(simIn,'SOC_vec',expDS_entry.SOC_OCV{1}.SOC);
    % simIn = setVariable(simIn,'OCV_vec',expDS_entry.SOC_OCV{1}.OCV);
    % simIn = setVariable(simIn,'unit_vec',ones(size(expDS_entry.SOC_OCV{1}.SOC)));
    % 
    % simIn = setModelParameter(simIn,StopTime=string(simTime));
    % simOut = sim(simIn);

    mdlWks = get_param(model_name,'ModelWorkspace');

    AH = expDS_entry.AH;
    initialSOC = expDS_entry.initialSOC;
    SOC_vec = expDS_entry.SOC_OCV{1}.SOC;
    OCV_vec = expDS_entry.SOC_OCV{1}.OCV;
    unit_vec = ones(size(SOC_vec));

    assignin(mdlWks,'AH',AH);
    assignin(mdlWks,'initialSOC',initialSOC);
    assignin(mdlWks,'SOC_vec',SOC_vec);
    assignin(mdlWks,'OCV_vec',OCV_vec);
    assignin(mdlWks,'t',t);
    assignin(mdlWks,'I',I);
    % assignin(mdlWks,'unit_vec',ones(size(expDS_entry.SOC_OCV{1}.SOC)));

    %% prepare ecm parameters
    if size(ecm_params,1)==1
        R0_vec = ecm_params.R0*unit_vec;
        R1_vec = ecm_params.R1*unit_vec;
        tau1_vec = ecm_params.tau1*unit_vec;
        if model_name == "inputModel_2RC_valid"
            R2_vec = ecm_params.R2*unit_vec;
            tau2_vec = ecm_params.tau2*unit_vec;
        end
    else
        soc_prm = ecm_params.nominal_soc(:);
        if model_name == "inputModel_2RC_valid"
            prm_matrix = [ecm_params.R0(:),ecm_params.R1(:),ecm_params.tau1(:),ecm_params.R2(:),ecm_params.tau2(:)];
        else
            prm_matrix = [ecm_params.R0(:),ecm_params.R1(:),ecm_params.tau1(:)];
        end
        prm_matrix_interp = interp1(soc_prm, prm_matrix,SOC_vec, "linear","extrap");
        prm_matrix_interp([SOC_vec <= soc_prm(1)],:) = ones(sum([SOC_vec <= soc_prm(1)]),1)*prm_matrix(1,:);
        prm_matrix_interp([SOC_vec >= soc_prm(end)],:) = ones(sum([SOC_vec >= soc_prm(end)]),1)*prm_matrix(end,:);
        R0_vec = prm_matrix_interp(:,1);
        R1_vec = prm_matrix_interp(:,2);
        tau1_vec = prm_matrix_interp(:,3);
        if model_name == "inputModel_2RC_valid"
            R2_vec = prm_matrix_interp(:,4);
            tau2_vec = prm_matrix_interp(:,5);
        end
    end
    assignin(mdlWks,'R0_vec',R0_vec);
    assignin(mdlWks,'R1_vec',R1_vec);
    assignin(mdlWks,'tau1_vec',tau1_vec);
    if model_name == "inputModel_2RC_valid"
        assignin(mdlWks,'R2_vec',R2_vec);
        assignin(mdlWks,'tau2_vec',tau2_vec);
    end

    % set "Model Configuration Parameters" to output results at the same time-points as input
    configSet = getActiveConfigSet(model_name);
    set_param(configSet,OutputOption='SpecifiedOutputTimes');
    set_param(configSet,OutputTimes='t');

    simOut = sim(model_name, simTime);

end