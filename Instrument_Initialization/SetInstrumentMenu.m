function SetInstrumentMenu(~,~,data_object,gui_object)
    % creates interface for setting the instrument
    % getting initial settings from last saved metadata
    
    %% gathering meta data and creating figure
    
    % get structs from objects
    data=guidata(data_object);
    gui=guidata(gui_object);
    
    % checks if already open
    InstrumentMenuNumber=501;
    if ishandle(InstrumentMenuNumber)
        warndlg('already open!','Error!')
        return
    end
    
    % load relevant metadata from last measurement
    gui.inst=GetStrFromPop(gui.InstrumentsPopup);
    md=load(fullfile(data.sourcepath,'lastmeta.mat'));
    md=md.instrumentsmetadata;
    
    % get list of cennected instrument indices
    all_inst=1:length(data.Instruments);
    connected_inst=all_inst(data.Connected==1);
    md=md{connected_inst(get(gui.InstrumentsPopup,'Value'))};
    
    % open window
    gui.instrumentsetWindow=figure(InstrumentMenuNumber);
    set(gui.instrumentsetWindow,...
        'Name', 'set Instrument', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Position', [230 250 460 510], ...
        'HandleVisibility', 'off' );

    instrumentsetLayout = uiextras.VBox( 'Parent', gui.instrumentsetWindow, ...
        'Padding', 3, 'Spacing', 3 );

    % creating buttons by type of instrument
    if regexp(gui.inst,'keithley')
        %% keithley 2400
        if strcmp(md{2},'VOLT')||strcmp(md{2},'Voltage')
            sourcevalue=1;
        elseif strcmp(md{2},'CURR')||strcmp(md{2},'Current')
            sourcevalue=2;
        end
        if sourcevalue==1
            sourcerangevalue=ceil(4-log10(md{3}/0.21));
        else
            sourcerangevalue=ceil(7-log10(md{3}/1.05e-6));
        end
        if strcmp(md{4},'VOLT')||strcmp(md{4},'Voltage')
            measurevalue=2;
        elseif strcmp(md{4},'CURR')||strcmp(md{4},'Current')
            measurevalue=1;
        end
        measurecompliance=md{5};
        if measurevalue==2
            measurerangevalue=ceil(4-log10(md{6}/0.21));
        else
            measurerangevalue=ceil(7-log10(md{6}/1.05e-6));
        end
        step=md{7};
        set_step=md{8};
        if strcmp(md{9},'off')
            fourwirevalue=1;
        elseif strcmp(md{9},'on')
            fourwirevalue=2;
        end
        if ~md{10}
            returntozerovalue=1;
        else
            returntozerovalue=2;
        end

        SourceLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', SourceLayout, ...
            'String', 'Source' );
        gui.SourcePopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', SourceLayout, ...
            'String', {'VOLT','CURR'}, ...
            'Value', sourcevalue, ...
            'Callback', {@Keit2400SourceChoose,data_object,gui_object});
        uicontrol( 'Style', 'text', ...
            'Parent', SourceLayout, ...
            'String', 'Source Range:' );
        if sourcevalue==1
            gui.SourceRangePopup = uicontrol( 'Style', 'popupmenu', ...
                'BackgroundColor', 'w', ...
                'Parent', SourceLayout, ...
                'String', {'210 V',...
                '21 V',...
                '2.1 V',...
                '210 mV'},...
                'Value', sourcerangevalue);
        else
            gui.SourceRangePopup = uicontrol( 'Style', 'popupmenu', ...
                'BackgroundColor', 'w', ...
                'Parent', SourceLayout, ...
                'String', {'1.05 A',...
                '105 mA',...
                '10.5 mA',...
                '1.05 mA',...
                '105 �A',...
                '10.5 �A',...
                '1.05 �A'},...
                'Value', sourcerangevalue);
        end

        MeasureLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25] );
        uicontrol( 'Style', 'text', ...
            'Parent', MeasureLayout, ...
            'String', 'Measure' );
        gui.MeasurePopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', MeasureLayout, ...
            'Value', measurevalue, ...
            'String', {'CURR','VOLT'});
        uicontrol( 'Style', 'text', ...
            'Parent', MeasureLayout, ...
            'String', 'Measure Range:' );
        if sourcevalue==1
            if measurerangevalue>7
                measurerangevalue=1;
            end
            gui.MeasureRangePopup = uicontrol( 'Style', 'popupmenu', ...
                'BackgroundColor', 'w', ...
                'Parent', MeasureLayout, ...
                'String', {'1.05 A',...
                '105 mA',...
                '10.5 mA',...
                '1.05 mA',...
                '105 �A',...
                '10.5 �A',...
                '1.05 �A'},...
                'Value', measurerangevalue);
        else
            if measurerangevalue>4
                measurerangevalue=1;
            end
            gui.MeasureRangePopup = uicontrol( 'Style', 'popupmenu', ...
                'BackgroundColor', 'w', ...
                'Parent', MeasureLayout, ...
                'String', {'210 V',...
                '21 V',...
                '2.1 V',...
                '210 mV'},...
                'Value', measurerangevalue);
        end
        uicontrol( 'Style', 'text', ...
            'Parent', MeasureLayout, ...
            'String', 'Measure Compliance:' );
        gui.MeasureCompEdit = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', MeasureLayout, ...
            'String', num2str(measurecompliance),...
            'Callback', @IsInputNumber);
        if sourcevalue==1
            gui.MeasureCompUnitPopup = uicontrol( 'Style', 'popupmenu', ...
                'BackgroundColor', 'w', ...
                'Parent', MeasureLayout, ...
                'String', {'A',...
                'mA',...
                '�A'});
        else
            gui.MeasureCompUnitPopup = uicontrol( 'Style', 'popupmenu', ...
                'BackgroundColor', 'w', ...
                'Parent', MeasureLayout, ...
                'String', {'210 V',...
                '21 V',...
                '2.1 V',...
                '210 mV'});
        end

        FourWireLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', FourWireLayout, ...
            'String', '4-wire mode' );
        gui.FourWirePopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', FourWireLayout, ...
            'String', {'off','on'},...
            'Value', fourwirevalue);
        
        StepLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', StepLayout, ...
            'String', 'Maximum Voltage Step' );
        gui.VoltageStepEdit = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', StepLayout, ...
            'String', num2str(step),...
            'Callback', @IsInputNumber);
        gui.VoltageStepUnitPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', StepLayout, ...
            'String', {'V',...
            'mV',...
            '�V'});
        uicontrol( 'Style', 'text', ...
            'Parent', StepLayout, ...
            'String', 'Set Step' );
        gui.VoltageSetStepEdit = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', StepLayout, ...
            'String', num2str(set_step),...
            'Callback', @IsInputNumber);
        gui.VoltageSetStepUnitPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', StepLayout, ...
            'String', {'V',...
            'mV',...
            '�V'});

        MoreLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 );
        uicontrol( 'Style', 'text', ...
            'Parent', MoreLayout, ...
            'String', 'Go To Zero: ' );
        gui.GoToZeroPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', MoreLayout, ...
            'String', {'off','on'},...
            'Value', returntozerovalue);
        
        % update data and gui objects
        guidata(data_object,data);
        guidata(gui_object,gui);
        
        SetButtonLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
        'Padding', 3, 'Spacing', 3 );
        uicontrol( 'Style', 'PushButton', ...
        'Parent', SetButtonLayout, ...
        'String', 'Set', ...
        'Callback', {@SetInstrument,data_object,gui_object,'keithley'});
    elseif regexp(gui.inst,'dmm')
        %% keithley 2000
        if strcmp(md{2},'VOLT')||strcmp(md{2},'Voltage')
            measurevalue=2;
        elseif strcmp(md{2},'CURR')||strcmp(md{2},'Current')
            measurevalue=1;
        end
        if measurevalue==2
            measurerangevalue=ceil(5-log10(md{3}/0.1));
        else
            measurerangevalue=ceil(4-log10(md{3}/0.01));
        end

        MeasureLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', MeasureLayout, ...
            'String', 'Measure' );
        gui.MeasurePopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', MeasureLayout, ...
            'Value', measurevalue, ...
            'String', {'Current','Voltage'},...
            'Callback', {@Keit2000MeasureChoose,data_object,gui_object});
        uicontrol( 'Style', 'text', ...
            'Parent', MeasureLayout, ...
            'String', 'Measure Range:' );
        if measurevalue==2
            gui.MeasureRangePopup = uicontrol( 'Style', 'popupmenu', ...
                'BackgroundColor', 'w', ...
                'Parent', MeasureLayout, ...
                'String', {'1000 V',...
                '100 V',...
                '10 V',...
                '1 V',...
                '100 mV'},...
                'Value', measurerangevalue);
        else
            gui.MeasureRangePopup = uicontrol( 'Style', 'popupmenu', ...
                'BackgroundColor', 'w', ...
                'Parent', MeasureLayout, ...
                'String', {'3 A',...
                '1 A',...
                '100 mA',...
                '10 mA'},...
                'Value', measurerangevalue);
        end
        
        % update data and gui objects
        guidata(data_object,data);
        guidata(gui_object,gui);

        SetButtonLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
        'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'PushButton', ...
        'Parent', SetButtonLayout, ...
        'String', 'Set', ...
        'Callback', {@SetInstrument,data_object,gui_object,'dmm'});
    elseif regexp(gui.inst,'lockin')
        %% lockin
        sens=md{2}+1;
        inp=md{3}+1;
        tconst=md{4}+1;
        slope=md{5}+1;
        couple=md{6}+1;
        ground=md{7}+1;
        filter=md{8}+1;
        reserve=md{9}+1;
        InputLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', InputLayout, ...
            'String', 'Input:' );
        gui.InputPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', InputLayout, ...
            'String', {'A','A-B','I'},...
            'Value', inp);

        SensetivityLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', SensetivityLayout, ...
            'String', 'sensitivity:' );
        gui.SensetivityPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', SensetivityLayout, ...
            'String', {'2 nV/fA',...
                '5 nV/fA',...
                '10  nV/fA',...
                '20 nV/fA',...
                '50 nV/fA',...
                '100  nV/fA',...
                '200 nV/fA',...
                '500 nV/fA',...
                '1 �V/pA',...
                '2 �V/pA',...
                '5 �V/pA',...
                '10 �V/pA',...
                '20 �V/pA',...
                '50 �V/pA',...
                '100 �V/pA',...
                '200 �V/pA',...
                '500 �V/pA',...
                '1 mV/nA',...
                '2 mV/nA',...
                '5 mV/nA',...
                '10 mV/nA',...
                '20 mV/nA',...
                '50 mV/nA',...
                '100 mV/nA',...
                '200 mV/nA',...
                '500 mV/nA',...
                '1 V/�A'},...
                'Value', sens);

        TimeConstLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', TimeConstLayout, ...
            'String', 'Time Constant:' );
        gui.TimeConstPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', TimeConstLayout, ...
            'String', {'10 �s',...
                '30 �s',...
                '100 �s',...
                '300 �s',...
                '1 ms',...
                '3 ms',...
                '10 ms',...
                '30 ms',...
                '100 ms',...
                '300 ms',...
                '1 s',...
                '3 s',...
                '10 s',...
                '30 s',...
                '100 s',...
                '300 s',...
                '1 ks',...
                '3 ks',...
                '10 ks',...
                '30 ks'},...
                'Value', tconst);

        SlopeLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', SlopeLayout, ...
            'String', 'Slope:' );
        gui.SlopePopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', SlopeLayout, ...
            'String', {'6 dB/oct','12 dB/oct','18 dB/oct','24 dB/oct'},...
            'Value', slope);

        CouplingLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', CouplingLayout, ...
            'String', 'Coupling:' );
        gui.CouplingPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', CouplingLayout, ...
            'String', {'AC','DC'},...
            'Value', couple);

        GroundLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', GroundLayout, ...
            'String', 'Ground:' );
        gui.GroundPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', GroundLayout, ...
            'String', {'Float','Ground'},...
            'Value', ground);

        FilterLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', FilterLayout, ...
            'String', 'Filter:' );
        gui.FilterPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', FilterLayout, ...
            'String', {'None','Line','2XLine','(1+2)XLine'},...
            'Value', filter);

        ReserveLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', ReserveLayout, ...
            'String', 'Reserve:' );
        gui.ReservePopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', ReserveLayout, ...
            'String', {'High Reserve','Normal','Low Noise'},...
            'Value', reserve);
        
        % update data and gui objects
        guidata(data_object,data);
        guidata(gui_object,gui);
        
        SetButtonLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
        'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'PushButton', ...
        'Parent', SetButtonLayout, ...
        'String', 'Set', ...
        'Callback', {@SetInstrument,data_object,gui_object,'lockin'});
    elseif regexp(gui.inst,'amplifier')
        %% amplifier
        instnames=cell([1,length(data.Instruments)]);
        for i=1:length(data.Instruments)
            if ~strcmp(data.Instruments{i}{1},'amplifier')
                instnames{i}=data.Instruments{i}{1};
            end
        end
        instnames=instnames(~cellfun('isempty',instnames));
        Amps2VoltLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        gui.Amps2VoltCheck= uicontrol( 'Style', 'checkbox', ...
            'Parent', Amps2VoltLayout, ...
            'String', 'Ampers per Volt:' );
        gui.Amps2VoltPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', Amps2VoltLayout, ...
            'String', {'10^-2',...
                '10^-3',...
                '10^-4',...
                '10^-5',...
                '10^-6',...
                '10^-7',...
                '10^-8',...
                '10^-9',...
                '10^-10',...
                '10^-11',...
                '10^-12'});
        ConnectedToLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', ConnectedToLayout, ...
            'String', 'Connected to:' );
        gui.ConnectedToPopup = uicontrol( 'Style', 'popupmenu', ...
            'BackgroundColor', 'w', ...
            'Parent', ConnectedToLayout, ...
            'String', instnames);
        
        % update data and gui objects
        guidata(data_object,data);
        guidata(gui_object,gui);
        
        SetButtonLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
        'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'PushButton', ...
        'Parent', SetButtonLayout, ...
        'String', 'Set', ...
        'Callback', {@SetInstrument,data_object,gui_object,'amplifier'});

    elseif regexp(gui.inst,'magnet')
        %% magnet
        range1=md{2};
        range2=md{3};
        range3=md{4};
        range4=md{5};
        range5=md{6};
        rate1=md{7};
        rate2=md{8};
        rate3=md{9};
        rate4=md{10};
        rate5=md{11};
        rate6=md{12};
        hilimit=md{13};
        lolimit=md{14};
        vlimit=md{15};
        SweepLimitLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', SweepLimitLayout, ...
            'String', 'High Sweep Limit [kG]:' );
        gui.HiLimit = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', SweepLimitLayout, ...
            'String', num2str(hilimit),...
            'Callback', @IsInputNumber);
        uicontrol( 'Style', 'text', ...
            'Parent', SweepLimitLayout, ...
            'String', 'Low Sweep Limit [kG]:' );
        gui.LoLimit = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', SweepLimitLayout, ...
            'String', num2str(lolimit),...
            'Callback', @IsInputNumber);
        uicontrol( 'Style', 'text', ...
            'Parent', SweepLimitLayout, ...
            'String', 'Voltage Limit [V]:' );
        gui.VLimit = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', SweepLimitLayout, ...
            'String', num2str(vlimit),...
            'Callback', @IsInputNumber);
        TitleLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', TitleLayout, ...
            'String', 'Amps' );
        uicontrol( 'Style', 'text', ...
            'Parent', TitleLayout, ...
            'String', '  ' );
        uicontrol( 'Style', 'text', ...
            'Parent', TitleLayout, ...
            'String', 'Amps' );
        uicontrol( 'Style', 'text', ...
            'Parent', TitleLayout, ...
            'String', '  ' );
        uicontrol( 'Style', 'text', ...
            'Parent', TitleLayout, ...
            'String', 'Amps/Sec' );
        FirstLimitLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        gui.FirstStart = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FirstLimitLayout, ...
            'String', '0.0000',...
            'Enable', 'Off');
        uicontrol( 'Style', 'text', ...
            'Parent', FirstLimitLayout, ...
            'String', 'To' );
        gui.FirstFinish = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FirstLimitLayout, ...
            'String', num2str(range1),...
            'Callback', {@FirstFinish,data,gui});
        uicontrol( 'Style', 'text', ...
            'Parent', FirstLimitLayout, ...
            'String', 'At' );
        gui.FirstRate = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FirstLimitLayout, ...
            'String', num2str(rate1),...
            'Callback', @IsInputNumber);
        SecondLimitLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        gui.SecondStart = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', SecondLimitLayout, ...
            'String', num2str(range1),...
            'Enable', 'Off');
        uicontrol( 'Style', 'text', ...
            'Parent', SecondLimitLayout, ...
            'String', 'To' );
        gui.SecondFinish = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', SecondLimitLayout, ...
            'String', num2str(range2),...
            'Callback', {@SecondFinish,data,gui});
        uicontrol( 'Style', 'text', ...
            'Parent', SecondLimitLayout, ...
            'String', 'At' );
        gui.SecondRate = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', SecondLimitLayout, ...
            'String', num2str(rate2),...
            'Callback', @IsInputNumber);
        ThirdLimitLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        gui.ThirdStart = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', ThirdLimitLayout, ...
            'String', num2str(range2),...
            'Enable', 'Off');
        uicontrol( 'Style', 'text', ...
            'Parent', ThirdLimitLayout, ...
            'String', 'To' );
        gui.ThirdFinish = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', ThirdLimitLayout, ...
            'String',  num2str(range3),...
            'Callback', {@ThirdFinish,data,gui});
        uicontrol( 'Style', 'text', ...
            'Parent', ThirdLimitLayout, ...
            'String', 'At' );
        gui.ThirdRate = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', ThirdLimitLayout, ...
            'String', num2str(rate3),...
            'Callback', @IsInputNumber);
        FourthLimitLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        gui.FourthStart = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FourthLimitLayout, ...
            'String', num2str(range3),...
            'Enable', 'Off');
        uicontrol( 'Style', 'text', ...
            'Parent', FourthLimitLayout, ...
            'String', 'To' );
        gui.FourthFinish = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FourthLimitLayout, ...
            'String', num2str(range4),...
            'Callback', {@FourthFinish,data,gui});
        uicontrol( 'Style', 'text', ...
            'Parent', FourthLimitLayout, ...
            'String', 'At' );
        gui.FourthRate = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FourthLimitLayout, ...
            'String', num2str(rate4),...
            'Callback', @IsInputNumber);
        FifthLimitLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        gui.FifthStart = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FifthLimitLayout, ...
            'String', num2str(range4),...
            'Enable', 'Off');
        uicontrol( 'Style', 'text', ...
            'Parent', FifthLimitLayout, ...
            'String', 'To' );
        gui.FifthFinish = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FifthLimitLayout, ...
            'String', num2str(range5),...
            'Callback', @IsInputNumber);
        uicontrol( 'Style', 'text', ...
            'Parent', FifthLimitLayout, ...
            'String', 'At' );
        gui.FifthRate = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FifthLimitLayout, ...
            'String', num2str(rate5),...
            'Callback', @IsInputNumber);
        FastLimitLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', FastLimitLayout, ...
            'String', '  ' );
        uicontrol( 'Style', 'text', ...
            'Parent', FastLimitLayout, ...
            'String', ' ' );
        uicontrol( 'Style', 'text', ...
            'Parent', FastLimitLayout, ...
            'String', 'FastMode' );
        uicontrol( 'Style', 'text', ...
            'Parent', FastLimitLayout, ...
            'String', 'At' );
        gui.FastRate = uicontrol( 'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'Parent', FastLimitLayout, ...
            'String', num2str(rate6),...
            'Callback', @IsInputNumber);
        
        % update data and gui objects
        guidata(data_object,data);
        guidata(gui_object,gui);
        
        SetButtonLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
        'Padding', 3, 'Spacing', 3,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'PushButton', ...
        'Parent', SetButtonLayout, ...
        'String', 'Set', ...
        'Callback', {@SetInstrument,data_object,gui_object,'magnet'});
    elseif regexp(gui.inst,'caen')
        %% caen
        obj=data.caen;
        CAEN=CaenRead(obj);      % Gets properties of the N1470 in cell form
        instrumentsetLayout = uiextras.VBox( 'Parent', gui.instrumentsetWindow, ...
            'Padding', 3, 'Spacing', 3);
        RemoteLayout = uiextras.HBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 );
        uicontrol( 'Style', 'text', ...
            'Parent', RemoteLayout, ...
            'String', 'Source Mode:' );
        uicontrol( 'Style', 'text', ...
            'Parent', RemoteLayout, ...
            'String', CAEN{1} );        
        ChsLayout = uiextras.HBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 12 );
        TextLayout = uiextras.VButtonBox( 'Parent', ChsLayout, ...
            'Padding', 0, 'Spacing', 10,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', ' ' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Polarity:', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Vmon/Vset (V):', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Imon (uA):', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Status:', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', ' ' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Power:', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Max. Voltage (V):', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Current Limit (uA):', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Ramp Up (V/s):', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Ramp Down (V/s):', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Trip (s):', ...
            'FontWeight', 'Bold' );
        uicontrol( 'Style', 'text', ...
            'Parent', TextLayout, ...
            'String', 'Power Down Mode:', ...
            'FontWeight', 'Bold' );
        
        ChannelLayout=zeros([4,1]);
        for i=1:4
            ChannelLayout(i) = uiextras.VButtonBox( 'Parent', ChsLayout, ...
                'Padding', 0, 'Spacing', 10,...
                'ButtonSize', [100,25]  );
            uicontrol( 'Style', 'text', ... %Channel
                'Parent', ChannelLayout(i), ...
                'String', ['Ch',int2str(i-1)], ...
                'FontWeight', 'Bold' );
            uicontrol( 'Style', 'text', ... %Polarity
                'Parent', ChannelLayout(i), ...
                'String', CAEN{2}{i} );
            uicontrol( 'Style', 'text', ... %Vmon/Vset
                'Parent', ChannelLayout(i), ...
                'String', [CAEN{3}{i}, ' / ', CAEN{12}{i}] );
            uicontrol( 'Style', 'text', ... %Imon/Iset
                'Parent', ChannelLayout(i), ...
                'String', CAEN{4}{i} );
            uicontrol( 'Style', 'text', ... %Status
                'Parent', ChannelLayout(i), ...
                'String', CAEN{6}{i} );
            uicontrol( 'Style', 'text', ...
                'Parent', ChannelLayout(i), ...
                'String', ' ' );
            if CAEN{5}(i)>-1
                gui.StatusPopup{i} = uicontrol( 'Style', 'popupmenu', ...
                    'BackgroundColor', 'w', ...
                    'Parent', ChannelLayout(i), ...
                    'String', {'Off','On'}, ...
                    'Value', CAEN{5}(i)+1 );
            else
                gui.StatusPopup{i} = uicontrol( 'Style', 'popupmenu', ...
                    'BackgroundColor', 'w', ...
                    'Parent', ChannelLayout(i), ...
                    'String', {'Off'} );
            end
            gui.MaxVoltEdit{i} = uicontrol( 'Style', 'edit', ...
                'BackgroundColor', 'w', ...
                'Parent', ChannelLayout(i), ...
                'String', CAEN{7}{i}, ...
                'Callback', @IsInputNumber);
            gui.LimCurrEdit{i} = uicontrol( 'Style', 'edit', ...
                'BackgroundColor', 'w', ...
                'Parent', ChannelLayout(i), ...
                'String', CAEN{13}{i}, ...
                'Callback', @IsInputNumber);
            gui.RampUpEdit{i} = uicontrol( 'Style', 'edit', ...
                'BackgroundColor', 'w', ...
                'Parent', ChannelLayout(i), ...
                'String', CAEN{8}{i}, ...
                'Callback', @IsInputNumber);
            gui.RampDownEdit{i} = uicontrol( 'Style', 'edit', ...
                'BackgroundColor', 'w', ...
                'Parent', ChannelLayout(i), ...
                'String', CAEN{9}{i}, ...
                'Callback', @IsInputNumber);
            gui.TripEdit{i} = uicontrol( 'Style', 'edit', ...
                'BackgroundColor', 'w', ...
                'Parent', ChannelLayout(i), ...
                'String', CAEN{10}{i}, ...
                'Callback', @IsInputNumber);
            gui.PowerDownPopup{i} = uicontrol( 'Style', 'popupmenu', ...
                'BackgroundColor', 'w', ...
                'Parent', ChannelLayout(i), ...
                'String', {'Kill','Ramp'}, ...
                'Value', CAEN{11}(i)+1 );
        end
        
        % update data and gui objects
        guidata(data_object,data);
        guidata(gui_object,gui);
        
        SetButtonLayout = uiextras.HButtonBox( 'Parent', instrumentsetLayout, ...
            'Padding', 3, 'Spacing', 3 ,...
            'ButtonSize', [100,25]  );
        uicontrol( 'Style', 'PushButton', ...
            'Parent', SetButtonLayout, ...
            'String', 'Set', ...
            'Callback', {@SetInstrument,data_object,gui_object,'caen'});
        
        set( instrumentsetLayout, 'Sizes', [-1 -7 -1 ] );
    end      
end