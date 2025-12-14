function [R1, tau1, R2, tau2] = init_guessR1R2(plsDS_entry,opts)

    arguments
        plsDS_entry table % single plsDS entery 
        opts.tau_offset {mustBeNumeric, mustBeScalarOrEmpty} = 0
        opts.tau_cutoff {mustBeNumeric, mustBeScalarOrEmpty} = 20
        opts.tau2 {mustBeNumeric, mustBeScalarOrEmpty} = 100
    end
    tau_offset = opts.tau_offset;
    tau_cutoff = opts.tau_cutoff;
    
    data = plsDS_entry.data{1,1};
    ind1 = find(data.Time > plsDS_entry.tau_pls+tau_offset,1);
    ind2 = find(data.Time > plsDS_entry.tau_pls+tau_offset+tau_cutoff,1);
    t_raw = data.Time(ind1:ind2);
    y_raw = data.E(ind1:ind2);
    
    t = [t_raw(1):0.1:t_raw(end)]';
    y = interp1(t_raw, y_raw, t,"linear");
    t = t - t(1);
    
    [fitresult, gof] = createFit(t, y);
    
    tau1 = -1/fitresult.b;
    R1 = -fitresult.a/-plsDS_entry.I;
    R2 = (data.E(end)-y(1) - (-fitresult.a))/-plsDS_entry.I;
    tau2 = opts.tau2;

    function [fitresult, gof] = createFit(t, y)
        [xData, yData] = prepareCurveData( t, y );
        % Set up fittype and options.
        ft = fittype( 'exp2' );
        options = fitoptions( 'Method', 'NonlinearLeastSquares' );
        options.Display = 'Off';
        options.Lower = [-Inf -Inf -Inf 0];
        options.StartPoint = [-(y(end)-y(1)) -(1/10) mean(y) 0];
        options.Upper = [Inf Inf Inf 0];
        
        % Fit model to data.
        [fitresult, gof] = fit( xData, yData, ft, options );
        
        % % Plot fit with data.
        % figure( 'Name', 'untitled fit 1' );
        % h = plot( fitresult, xData, yData );
        % legend( h, 'y vs. t', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
        % % Label axes
        % xlabel( 't', 'Interpreter', 'none' );
        % ylabel( 'y', 'Interpreter', 'none' );
        % grid on
    end
end