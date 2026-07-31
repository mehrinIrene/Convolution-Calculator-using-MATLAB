classdef projectol < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ControlsPanel                   matlab.ui.container.Panel %introduction of panels
        PlotsPanel                      matlab.ui.container.Panel
        SelectSignalDomainPanel         matlab.ui.container.Panel
        InputSignalPanel                matlab.ui.container.Panel
        ImpulseResponsePanel            matlab.ui.container.Panel
        ModeSelectionButtonGroup        matlab.ui.container.ButtonGroup
        ContinuousTimeSignalButton      matlab.ui.control.RadioButton
        DiscreteTimeSignalButton        matlab.ui.control.RadioButton
        InputTypeButtonGroup            matlab.ui.container.ButtonGroup %extra 2 button group
        InputManualButton               matlab.ui.control.RadioButton
        InputPredefinedButton           matlab.ui.control.RadioButton
        ImpulseTypeButtonGroup          matlab.ui.container.ButtonGroup
        ImpulseManualButton             matlab.ui.control.RadioButton
        ImpulsePredefinedButton         matlab.ui.control.RadioButton
        InputSignalVectorTextLabel      matlab.ui.control.Label
        EditField                       matlab.ui.control.EditField
        StartIndexNumericLabel          matlab.ui.control.Label
        EditField2                      matlab.ui.control.NumericEditField
        InputSignalDropDownLabel        matlab.ui.control.Label
        InputSignalDropDown             matlab.ui.control.DropDown
        StartTimeEditFieldLabel         matlab.ui.control.Label
        StartTimeEditField              matlab.ui.control.NumericEditField
        EndTimeEditFieldLabel           matlab.ui.control.Label
        EndTimeEditField                matlab.ui.control.NumericEditField
        AmplitudeEditFieldLabel         matlab.ui.control.Label
        AmplitudeEditField              matlab.ui.control.NumericEditField
        ImpulseResponseVectorLabel      matlab.ui.control.Label
        EditField_2                     matlab.ui.control.EditField
        ImpulseResponseStartIndexLabel  matlab.ui.control.Label
        EditField2_2                    matlab.ui.control.NumericEditField
        ImpulseSignalDropDownLabel      matlab.ui.control.Label
        ImpulseSignalDropDown           matlab.ui.control.DropDown
        StartTimeEditField_2Label       matlab.ui.control.Label
        StartTimeEditField_2            matlab.ui.control.NumericEditField
        EndTimeEditField_2Label         matlab.ui.control.Label
        EndTimeEditField_2              matlab.ui.control.NumericEditField
        AmplitudeEditField_2Label       matlab.ui.control.Label
        AmplitudeEditField_2            matlab.ui.control.NumericEditField
        AnimationspeedLabel             matlab.ui.control.Label
        Slider                          matlab.ui.control.Slider
        ComputeConvolutionButton        matlab.ui.control.Button
        ResetButton                     matlab.ui.control.Button
        ComputeCorrelationButton        matlab.ui.control.Button
        UIAxes                          matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes3                         matlab.ui.control.UIAxes
    end

    methods (Access = private)

        % Callback to toggle between DT and CT modes
        function ModeSelectionChanged(app, ~)
            isDiscrete = app.DiscreteTimeSignalButton.Value;
            app.InputManualButton.Value = isDiscrete;
            app.InputPredefinedButton.Value = ~isDiscrete;
            app.ImpulseManualButton.Value = isDiscrete;
            app.ImpulsePredefinedButton.Value = ~isDiscrete;  %define conditions upto this
            InputTypeChanged(app);
            ImpulseTypeChanged(app);
            app.ComputeCorrelationButton.Visible = isDiscrete; %correlation only for discrete
        end

        % Callback to toggle Input Signal controls
        function InputTypeChanged(app, ~)
            isManual = app.InputManualButton.Value;
            set([app.InputSignalVectorTextLabel, app.EditField, app.StartIndexNumericLabel, app.EditField2], 'Visible', isManual); %Ui element
            set([app.InputSignalDropDownLabel, app.InputSignalDropDown, app.StartTimeEditFieldLabel, app.StartTimeEditField, app.EndTimeEditFieldLabel, app.EndTimeEditField, app.AmplitudeEditFieldLabel, app.AmplitudeEditField], 'Visible', ~isManual); %parameters inside them
        end

        % Callback to toggle Impulse Response controls
        function ImpulseTypeChanged(app, ~)
            isManual = app.ImpulseManualButton.Value;
            set([app.ImpulseResponseVectorLabel, app.EditField_2, app.ImpulseResponseStartIndexLabel, app.EditField2_2], 'Visible', isManual);
            set([app.ImpulseSignalDropDownLabel, app.ImpulseSignalDropDown, app.StartTimeEditField_2Label, app.StartTimeEditField_2, app.EndTimeEditField_2Label, app.EndTimeEditField_2, app.AmplitudeEditField_2Label, app.AmplitudeEditField_2], 'Visible', ~isManual);
        end
        
        % Main convolution logic with full animation
        function ComputeConvolutionButtonPushed(app, ~)
            if app.DiscreteTimeSignalButton.Value
                if isempty(app.EditField.Value) || isempty(app.EditField_2.Value), uialert(app.UIFigure, 'Vectors are required.', 'Input Error'); return; end
                x = str2num(app.EditField.Value); n1 = app.EditField2.Value;
                h = str2num(app.EditField_2.Value); n2 = app.EditField2_2.Value;
                
                nx = n1:(n1 + length(x) - 1);
                nh = n2:(n2 + length(h) - 1);
                y = conv(x, h);
                ny_start = nx(1) + nh(1);
                ny = ny_start:(ny_start + length(y) - 1);
        %Mirror the impulse function
                h_mirrored = fliplr(h);
                nh_mirrored_base = -fliplr(nh);
        %Plot input signal          
                stem(app.UIAxes, nx, x, 'filled'); title(app.UIAxes, 'Input Signal');
        %Animation start   
                plot_limits = [min([nx, ny]) - 1, max([nx, ny]) + 1];
                ylim_h = [min([x,h,0])-1, max([x,h,0])+1]; if all(h==0)&&all(x==0), ylim_h=[-1,1]; end
                
                cla(app.UIAxes2); cla(app.UIAxes3);
                
                for i = 1:length(ny)
                    n_current = ny(i);
                    cla(app.UIAxes2);
                    hold(app.UIAxes2, 'on');
                    stem(app.UIAxes2, nx, x, 'filled', 'Color', [0.6 0.6 0.6]);
                    stem(app.UIAxes2, nh_mirrored_base + n_current, h_mirrored, 'filled', 'r');
                    hold(app.UIAxes2, 'off');
                    xlim(app.UIAxes2, plot_limits); ylim(app.UIAxes2, ylim_h); grid(app.UIAxes2, 'on');
                    title(app.UIAxes2, ['Mirrored & Shifting Response: h[', num2str(n_current), '-k]']);

                    stem(app.UIAxes3, ny(1:i), y(1:i), 'filled');
                    xlim(app.UIAxes3, plot_limits); grid(app.UIAxes3, 'on');
                    title(app.UIAxes3, 'Output Signal (Convolution)');
                    
                    pause(1 / (app.Slider.Value + 1));
                end

            else % Continuous-Time
                type_x = app.InputSignalDropDown.Value; t1_x = app.StartTimeEditField.Value; t2_x = app.EndTimeEditField.Value; A_x = app.AmplitudeEditField.Value;
                type_h = app.ImpulseSignalDropDown.Value; t1_h = app.StartTimeEditField_2.Value; t2_h = app.EndTimeEditField_2.Value; A_h = app.AmplitudeEditField_2.Value;
                fs = 1000;
                
                t_x = t1_x : 1/fs : t2_x; if isempty(t_x), t_x = t1_x; end
                t_h = t1_h : 1/fs : t2_h; if isempty(t_h), t_h = t1_h; end

                x = generateCTSignal(app, type_x, t_x, A_x); h = generateCTSignal(app, type_h, t_h, A_h);
                y = conv(x, h) / fs;
                t_y_start = t_x(1) + t_h(1);
                t_y = t_y_start : 1/fs : t_y_start + (length(y)-1)/fs;

                h_mirrored = fliplr(h);
                th_mirrored_base = -fliplr(t_h);

                plot(app.UIAxes, t_x, x, 'LineWidth', 2); title(app.UIAxes, 'Input Signal');
         %animation start      
                plot_limits = [min([t_x, t_y])-0.5, max([t_x, t_y])+0.5];
                ylim_h = [min([x,h,0])-1, max([x,h,0])+1]; if all(h==0)&&all(x==0), ylim_h=[-1,1]; end
         %clear axes
                cla(app.UIAxes2); cla(app.UIAxes3);
                
                step_size = max(1, floor(length(t_y) / 100));
                for i = 1:step_size:length(t_y)
                    t_current = t_y(i);
                    cla(app.UIAxes2);
                    hold(app.UIAxes2, 'on');
                    plot(app.UIAxes2, t_x, x, 'LineWidth', 2, 'Color', [0.6 0.6 0.6]);
                    plot(app.UIAxes2, th_mirrored_base + t_current, h_mirrored, 'LineWidth', 2, 'Color', 'r');
                    hold(app.UIAxes2, 'off');
                    xlim(app.UIAxes2, plot_limits); ylim(app.UIAxes2, ylim_h); grid(app.UIAxes2, 'on');
                    title(app.UIAxes2, ['Mirrored & Shifting Response: h(', sprintf('%.2f', t_current), '-\tau)']);

                    plot(app.UIAxes3, t_y(1:i), y(1:i), 'LineWidth', 2);
                    xlim(app.UIAxes3, plot_limits); grid(app.UIAxes3, 'on');
                    title(app.UIAxes3, 'Output Signal (Convolution)');
                    
                    pause(0.01);
                end
                plot(app.UIAxes3, t_y, y, 'LineWidth', 2);
            end
        end

        function ResetButtonPushed(app, ~)
            cla(app.UIAxes); title(app.UIAxes, 'Input Signal');
            cla(app.UIAxes2); title(app.UIAxes2, 'Mirrored & Shifting Response');
            cla(app.UIAxes3); title(app.UIAxes3, 'Output Signal (Convolution)');
        end
        
        function ComputeCorrelationButtonPushed(app, ~)
            x = str2num(app.EditField.Value); h = str2num(app.EditField_2.Value);
            if isempty(x) || isempty(h), uialert(app.UIFigure, 'Vectors are required!', 'Input Error'); return; end
            [r, lags] = xcorr(x, h);
            cla(app.UIAxes3); stem(app.UIAxes3, lags, r, 'filled');
            title(app.UIAxes3, 'Cross-Correlation'); xlabel(app.UIAxes3, 'Lag');
        end
        
        function y = generateCTSignal(~, type, t, A)
             y = zeros(size(t)); if isempty(t), return; end
             switch lower(type)
                case 'impulse', [~, mid_idx] = min(abs(t - (t(1)+t(end))/2)); y(mid_idx) = A * 100;
                case 'step', y = A * ones(size(t));
                case 'rectangular pulse', y = A * (t>=t(1) & t<=t(end));
                case 'triangular pulse', width = t(end)-t(1); mid = t(1)+width/2; if width == 0, y=A; return; end; y = A*max(0, 1-abs(t-mid)/(width/2));
                case 'sawtooth', width = t(end)-t(1); if width == 0, y=A; return; end; y = A * (t - t(1)) / width;
             end
        end
    end

    methods (Access = private)
        function createComponents(app)
            % color theme
            bgColor = [0.86 0.79 0.79]; % Color from user screenshot
            panelColor = [0.94 0.94 0.94]; % Default light gray
            fontColor = [0 0 0]; % Black font for light background
            
            app.UIFigure = uifigure('Visible', 'off', 'Position', [100 100 1100 750], 'Name', 'Signal Processing App', 'Color', bgColor);
            
            % --- Panels ---
            app.ControlsPanel = uipanel(app.UIFigure, 'Position', [0 0 350 750], 'BackgroundColor', bgColor, 'BorderType', 'none');
            app.SelectSignalDomainPanel = uipanel(app.ControlsPanel, 'Title', 'Select Signal Domain', 'Position', [20 650 310 80], 'BackgroundColor', panelColor, 'ForegroundColor', fontColor);
            app.InputSignalPanel = uipanel(app.ControlsPanel, 'Title', 'Input Signal', 'Position', [20 420 310 210], 'BackgroundColor', panelColor, 'ForegroundColor', fontColor);
            app.ImpulseResponsePanel = uipanel(app.ControlsPanel, 'Title', 'Impulse Response', 'Position', [20 190 310 210], 'BackgroundColor', panelColor, 'ForegroundColor', fontColor);
            app.PlotsPanel = uipanel(app.UIFigure, 'Position', [350 0 750 750], 'BackgroundColor', bgColor, 'BorderType', 'none');

            % --- Components ---
            app.ModeSelectionButtonGroup = uibuttongroup(app.SelectSignalDomainPanel, 'Position', [5 5 300 45], 'BackgroundColor', panelColor, 'ForegroundColor', fontColor, 'BorderType', 'none');
            app.DiscreteTimeSignalButton = uiradiobutton(app.ModeSelectionButtonGroup, 'Text', 'Discrete-Time (DT)', 'Position', [10 15 140 22], 'Value', true, 'FontColor', fontColor);
            app.ContinuousTimeSignalButton = uiradiobutton(app.ModeSelectionButtonGroup, 'Text', 'Continuous-Time (CT)', 'Position', [160 15 140 22], 'FontColor', fontColor);
            
            app.InputTypeButtonGroup = uibuttongroup(app.InputSignalPanel, 'Position', [5 155 300 30], 'BackgroundColor', panelColor, 'ForegroundColor', fontColor, 'BorderType', 'none');
            app.InputManualButton = uiradiobutton(app.InputTypeButtonGroup, 'Text', 'Manual Input', 'Position', [10 5 140 22], 'Value', true, 'FontColor', fontColor);
            app.InputPredefinedButton = uiradiobutton(app.InputTypeButtonGroup, 'Text', 'Predefined Signal', 'Position', [160 5 140 22], 'FontColor', fontColor);
            
            app.InputSignalVectorTextLabel = uilabel(app.InputSignalPanel, 'Text', 'Manual Input:', 'Position', [15 110 100 22], 'FontColor', fontColor);
            app.EditField = uieditfield(app.InputSignalPanel, 'text', 'Position', [15 85 280 22]);
            app.StartIndexNumericLabel = uilabel(app.InputSignalPanel, 'Text', 'Start Index:', 'Position', [15 50 100 22], 'FontColor', fontColor);
            app.EditField2 = uieditfield(app.InputSignalPanel, 'numeric', 'Position', [15 25 280 22]);
            
            app.InputSignalDropDown = uidropdown(app.InputSignalPanel, 'Items', {'Impulse', 'Step', 'Rectangular Pulse', 'Triangular Pulse', 'Sawtooth'}, 'Position', [15 110 280 22]);
            app.StartTimeEditFieldLabel = uilabel(app.InputSignalPanel, 'Text', 'Start Time:', 'Position', [15 80 100 22], 'FontColor', fontColor);
            app.StartTimeEditField = uieditfield(app.InputSignalPanel, 'numeric', 'Position', [135 80 160 22]);
            app.EndTimeEditFieldLabel = uilabel(app.InputSignalPanel, 'Text', 'End Time:', 'Position', [15 50 100 22], 'FontColor', fontColor);
            app.EndTimeEditField = uieditfield(app.InputSignalPanel, 'numeric', 'Position', [135 50 160 22]);
            app.AmplitudeEditFieldLabel = uilabel(app.InputSignalPanel, 'Text', 'Amplitude:', 'Position', [15 20 100 22], 'FontColor', fontColor);
            app.AmplitudeEditField = uieditfield(app.InputSignalPanel, 'numeric', 'Position', [135 20 160 22]);
            
            app.ImpulseTypeButtonGroup = uibuttongroup(app.ImpulseResponsePanel, 'Position', [5 155 300 30], 'BackgroundColor', panelColor, 'ForegroundColor', fontColor, 'BorderType', 'none');
            app.ImpulseManualButton = uiradiobutton(app.ImpulseTypeButtonGroup, 'Text', 'Manual Input', 'Position', [10 5 140 22], 'Value', true, 'FontColor', fontColor);
            app.ImpulsePredefinedButton = uiradiobutton(app.ImpulseTypeButtonGroup, 'Text', 'Predefined Signal', 'Position', [160 5 140 22], 'FontColor', fontColor);

            app.ImpulseResponseVectorLabel = uilabel(app.ImpulseResponsePanel, 'Text', 'Manual Input:', 'Position', [15 110 100 22], 'FontColor', fontColor);
            app.EditField_2 = uieditfield(app.ImpulseResponsePanel, 'text', 'Position', [15 85 280 22]);
            app.ImpulseResponseStartIndexLabel = uilabel(app.ImpulseResponsePanel, 'Text', 'Start Index:', 'Position', [15 50 100 22], 'FontColor', fontColor);
            app.EditField2_2 = uieditfield(app.ImpulseResponsePanel, 'numeric', 'Position', [15 25 280 22]);

            app.ImpulseSignalDropDown = uidropdown(app.ImpulseResponsePanel, 'Items', {'Impulse', 'Step', 'Rectangular Pulse', 'Triangular Pulse', 'Sawtooth'}, 'Position', [15 110 280 22]);
            app.StartTimeEditField_2Label = uilabel(app.ImpulseResponsePanel, 'Text', 'Start Time:', 'Position', [15 80 100 22], 'FontColor', fontColor);
            app.StartTimeEditField_2 = uieditfield(app.ImpulseResponsePanel, 'numeric', 'Position', [135 80 160 22]);
            app.EndTimeEditField_2Label = uilabel(app.ImpulseResponsePanel, 'Text', 'End Time:', 'Position', [15 50 100 22], 'FontColor', fontColor);
            app.EndTimeEditField_2 = uieditfield(app.ImpulseResponsePanel, 'numeric', 'Position', [135 50 160 22]);
            app.AmplitudeEditField_2Label = uilabel(app.ImpulseResponsePanel, 'Text', 'Amplitude:', 'Position', [15 20 100 22], 'FontColor', fontColor);
            app.AmplitudeEditField_2 = uieditfield(app.ImpulseResponsePanel, 'numeric', 'Position', [135 20 160 22]);
            
            % --- Execution Controls (MOVED UP) ---
            app.AnimationspeedLabel = uilabel(app.ControlsPanel, 'Text', 'Animation Speed:', 'Position', [20 150 150 22], 'FontColor', fontColor);
            app.Slider = uislider(app.ControlsPanel, 'Position', [20 135 310 3], 'Value', 10);
            app.ComputeConvolutionButton = uibutton(app.ControlsPanel, 'push', 'Text', 'Compute Convolution', 'Position', [20 60 310 40], 'FontSize', 14, 'FontWeight', 'bold');
            app.ResetButton = uibutton(app.ControlsPanel, 'push', 'Text', 'Reset', 'Position', [20 25 150 25]);
            app.ComputeCorrelationButton = uibutton(app.ControlsPanel, 'push', 'Text', 'Compute Correlation', 'Position', [180 25 150 25]);
            
            app.UIAxes = uiaxes(app.PlotsPanel, 'Position', [50 510 650 220]); title(app.UIAxes, 'Input Signal');
            app.UIAxes2 = uiaxes(app.PlotsPanel, 'Position', [50 280 650 220]); title(app.UIAxes2, 'Mirrored & Shifting Response');
            app.UIAxes3 = uiaxes(app.PlotsPanel, 'Position', [50 50 650 220]); title(app.UIAxes3, 'Output Signal (Convolution)');
            
            app.ModeSelectionButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ModeSelectionChanged, true);
            app.InputTypeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @InputTypeChanged, true);
            app.ImpulseTypeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ImpulseTypeChanged, true);
            app.ComputeConvolutionButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeConvolutionButtonPushed, true);
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ComputeCorrelationButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeCorrelationButtonPushed, true);
            
            ModeSelectionChanged(app);
            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = projectol
            createComponents(app)
            registerApp(app, app.UIFigure)
            if nargout == 0, clear app, end
        end
        function delete(app)
            delete(app.UIFigure)
        end
    end
end