function [pOpt,Info,OptimOptions] = ParamEstim_nRC(prm_initguess,exp_params,IOdata,model_name,OptimOptions)
%PARAMETERESTIMATION_INPUTMODEL_2RC_FITidxVstep
%
% Solve a parameter estimation problem for the inputModel_2RC_fit model.
%

    %% Open the model.
    % model_name = "inputModel_2RC_fit";
    model_name = string(model_name); % ensure ""-string
    open_system(model_name)
    set_param(model_name+"/from_ws",'Value','0')
    
    %% Specify Model Parameters to Estimate

    % (!!!) Scale is 1.0 when creating the parameters manually
    % Set the right scales or use sdo.getParameterFromModel :: p = sdo.getParameterFromModel('inputModel_2RC_fit',{'R0','R1','tau1','R2','tau2'})
    % Scaling factor. During optimization, the design variables are scaled, or normalized, by dividing their current value by a scale value. The default value is the nearest power of 2 greater than the current value of the parameter.
    if model_name == "inputModel_2RC_fit"
        p = param.Continuous.empty(5,0);
    elseif model_name == "inputModel_1RC_fit"
        p = param.Continuous.empty(3,0);
    end
    
    p(1,1) = param.Continuous('R0',prm_initguess.R0);
    p(2) = param.Continuous('R1',prm_initguess.R1); 
    p(3) = param.Continuous('tau1',prm_initguess.tau1);
    if model_name == "inputModel_2RC_fit"
        p(4) = param.Continuous('R2',prm_initguess.R2); 
        p(5) = param.Continuous('tau2',prm_initguess.tau2);
    end

    p(1).Free = prm_initguess.R0_free;
    p(2).Free = prm_initguess.R1_free;
    p(3).Free = prm_initguess.tau1_free;
    if model_name == "inputModel_2RC_fit"
        p(4).Free = prm_initguess.R2_free;
        p(5).Free = prm_initguess.tau2_free;
    end
    
    for i = 1:numel(p)
        % just as in documentation: "The default value is the nearest power of 2 greater than the current value of the parameter."
        p(i).Scale = 2^ceil(log2(abs(p(i).Value)));
    end

    %% TODO: check if limits low/high exists inthe structure
    p(3).Minimum = prm_initguess.tau1_low;
    p(3).Maximum = prm_initguess.tau1_high;
    if model_name == "inputModel_2RC_fit"
        p(5).Minimum = prm_initguess.tau2_low;
        p(5).Maximum = prm_initguess.tau2_high;
    end
    
    %% Define the Estimation Experiments
    
    EXP = sdo.Experiment(model_name);
    
    %%
    % Specify the experiment input data used to generate the output.
    EXP_Sig_Input = Simulink.SimulationData.Signal;
    EXP_Sig_Input.Values    = IOdata.('EXP_Sig_Input_Value');
    EXP_Sig_Input.BlockPath = char(model_name+"/Input"); %'inputModel_2RC_fit/Input';
    EXP_Sig_Input.PortType  = 'outport';
    EXP_Sig_Input.PortIndex = 1;
    EXP_Sig_Input.Name      = 'I_port';
    EXP.InputData = EXP_Sig_Input;
    %%
    % Specify the measured experiment output data.
    EXP_Sig_Output = Simulink.SimulationData.Signal;
    EXP_Sig_Output.Values    = IOdata.('EXP_Sig_Output_Value');
    EXP_Sig_Output.BlockPath = char(model_name+"/PS-Simulink Converter2"); %'inputModel_2RC_fit/PS-Simulink Converter2';
    EXP_Sig_Output.PortType  = 'outport';
    EXP_Sig_Output.PortIndex = 1;
    EXP_Sig_Output.Name      = 'U_cell';
    EXP.OutputData = EXP_Sig_Output;
      
    expParam = param.Continuous.empty(5,0);
    expParam(1,1) = param.Continuous('AH',exp_params.AH);
    expParam(1).Free = 0;
    expParam(2) = param.Continuous('OCV_vec',exp_params.OCV_vec);
    expParam(2).Free = zeros(size(exp_params.OCV_vec));
    expParam(3) = param.Continuous('SOC_vec',exp_params.SOC_vec);
    expParam(3).Free = zeros(size(exp_params.SOC_vec));
    expParam(4) = param.Continuous('initialSOC',exp_params.initialSOC);
    expParam(4).Free = 0;
    expParam(5) = param.Continuous('unit_vec',ones(size(exp_params.SOC_vec)));
    expParam(5).Free = zeros(size(exp_params.SOC_vec));

    EXP.Parameters = expParam;
    
    %%
    % Create a model simulator from an experiment
    Simulator = createSimulator(EXP);
    
    %% Create Estimation Objective Function
    %
    % Create a function that is called at each optimization iteration
    % to compute the estimation cost.
    %
    % Use an anonymous function with one argument that calls inputModel_2RC_fit_optFcn.
    optimfcn = @(P) batmodel_optFcn(P,Simulator,EXP);
    
    %% Optimization Options
    %
    % Specify optimization options.
    
    if nargin >=5
        Options = OptimOptions;
    else
        Options = sdo.OptimizeOptions;
        Options.Method = 'lsqnonlin';
        Options.MethodOptions.FunctionTolerance = 1e-6;
        Options.MethodOptions.OptimalityTolerance = 1e-6;
        Options.MethodOptions.StepTolerance = 1e-6;
        OptimOptions = Options;
    end

    Options.OptimizedModel = Simulator;
    
    %% Estimate the Parameters
    %
    % Call sdo.optimize with the estimation objective function handle,
    % parameters to estimate, and options.
    [pOpt,Info] = sdo.optimize(optimfcn,p,Options);
    
    %%
    % Update the experiments with the estimated parameter values.
    EXP = setEstimatedValues(EXP,pOpt);
    
    %% Update Model
    %
    % Update the model with the optimized parameter values.
    sdo.setValueInModel(model_name,pOpt);
    
    function Vals = batmodel_optFcn(P,Simulator,EXP)
    %INPUTMODEL_2RC_FIT_OPTFCN
    %
    % Function called at each iteration of the estimation problem.
    %
    % The function is called with a set of parameter values, P, and returns
    % the estimation cost, Vals, to the optimization solver.
    %
    % See the sdoExampleCostFunction function and sdo.optimize for a more
    % detailed description of the function signature.
    %
    
        %%
        % Define a signal tracking requirement to compute how well the model
        % output matches the experiment data.
        r = sdo.requirements.SignalTracking('Method', 'Residuals');
        %%
        % Update the experiment(s) with the estimated parameter values.
        EXP = setEstimatedValues(EXP,P);
        
        %%
        % Simulate the model and compare model outputs with measured experiment
        % data.
        
        F_r = [];
        Simulator = createSimulator(EXP,Simulator);
        strOT = mat2str(EXP.OutputData(1).Values.Time);
        Simulator = sim(Simulator, 'OutputOption', 'AdditionalOutputTimes', 'OutputTimes', strOT);
        
        SimLog = find(Simulator.LoggedData,get_param(model_name,'SignalLoggingName'));
        Sig = find(SimLog,EXP.OutputData.Name);
        
        Error = evalRequirement(r,Sig.Values,EXP.OutputData.Values);
        F_r = [F_r; Error(:)];
        
        %% Return Values.
        %
        % Return the evaluated estimation cost in a structure to the
        % optimization solver.
        Vals.F = F_r;
    end
end