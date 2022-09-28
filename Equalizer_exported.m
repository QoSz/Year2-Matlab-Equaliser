classdef Equalizer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        TabGroup                   matlab.ui.container.TabGroup
        EqualizerTab               matlab.ui.container.Tab
        FiltersPanel               matlab.ui.container.Panel
        ResetButton                matlab.ui.control.Button
        EffectsPanel               matlab.ui.container.Panel
        ClearButton                matlab.ui.control.Button
        RingModulationCheckBox     matlab.ui.control.CheckBox
        FlangerCheckBox            matlab.ui.control.CheckBox
        WahWahCheckBox             matlab.ui.control.CheckBox
        PresetsDropDown            matlab.ui.control.DropDown
        PresetsDropDownLabel       matlab.ui.control.Label
        FiltersGainPanel           matlab.ui.container.Panel
        dBEditFieldLabel_11        matlab.ui.control.Label
        dBEditField10              matlab.ui.control.NumericEditField
        dBEditFieldLabel_9         matlab.ui.control.Label
        dBEditField9               matlab.ui.control.NumericEditField
        dBEditFieldLabel_8         matlab.ui.control.Label
        dBEditField8               matlab.ui.control.NumericEditField
        dBEditFieldLabel_7         matlab.ui.control.Label
        dBEditField7               matlab.ui.control.NumericEditField
        dBEditFieldLabel_6         matlab.ui.control.Label
        dBEditField6               matlab.ui.control.NumericEditField
        dBEditFieldLabel_5         matlab.ui.control.Label
        dBEditField5               matlab.ui.control.NumericEditField
        dBEditFieldLabel_4         matlab.ui.control.Label
        dBEditField4               matlab.ui.control.NumericEditField
        dBEditFieldLabel_3         matlab.ui.control.Label
        dBEditField3               matlab.ui.control.NumericEditField
        dBEditFieldLabel_2         matlab.ui.control.Label
        dBEditField1               matlab.ui.control.NumericEditField
        dBEditField2               matlab.ui.control.NumericEditField
        dBEditFieldLabel           matlab.ui.control.Label
        channel10                  matlab.ui.control.Slider
        KHzLabel_5                 matlab.ui.control.Label
        channel9                   matlab.ui.control.Slider
        KHzLabel_4                 matlab.ui.control.Label
        channel8                   matlab.ui.control.Slider
        KHzLabel_3                 matlab.ui.control.Label
        channel7                   matlab.ui.control.Slider
        KHzLabel_2                 matlab.ui.control.Label
        channel6                   matlab.ui.control.Slider
        KHzLabel                   matlab.ui.control.Label
        channel5                   matlab.ui.control.Slider
        HzLabel_5                  matlab.ui.control.Label
        channel4                   matlab.ui.control.Slider
        HzLabel_4                  matlab.ui.control.Label
        channel3                   matlab.ui.control.Slider
        HzLabel_3                  matlab.ui.control.Label
        channel2                   matlab.ui.control.Slider
        HzLabel_2                  matlab.ui.control.Label
        channel1                   matlab.ui.control.Slider
        HzLabel                    matlab.ui.control.Label
        FilterTypeButtonGroup      matlab.ui.container.ButtonGroup
        FIRButton                  matlab.ui.control.RadioButton
        IIRButton_2                matlab.ui.control.RadioButton
        PlayerPanel                matlab.ui.container.Panel
        VolumeEditField            matlab.ui.control.NumericEditField
        VolumeKnob                 matlab.ui.control.Knob
        VolumeKnobLabel            matlab.ui.control.Label
        OutputsamplerateEditField  matlab.ui.control.NumericEditField
        SampleRateEditFieldLabel   matlab.ui.control.Label
        SaveButton                 matlab.ui.control.Button
        PauseButton                matlab.ui.control.Button
        StopButton                 matlab.ui.control.Button
        PlayButton                 matlab.ui.control.Button
        Label_totalTime            matlab.ui.control.Label
        ofLabel                    matlab.ui.control.Label
        Label_currentTime          matlab.ui.control.Label
        BrowseButton               matlab.ui.control.Button
        directoryLabel             matlab.ui.control.Label
        FileLabel                  matlab.ui.control.Label
        OrignalSignalTab           matlab.ui.container.Tab
        UIAxes_4                   matlab.ui.control.UIAxes
        UIAxes_3                   matlab.ui.control.UIAxes
        ModifiedSignalTab          matlab.ui.container.Tab
        UIAxes_2                   matlab.ui.control.UIAxes
        UIAxes                     matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        player;
        paused;
        playing;
        seconds;
        pausedAt;
        file_path;
        Fs;
        y;
    end
    
    methods (Access = public)
        
        
        % Setting up the filters
        function setFilters(~,Fs,firOrder,iirOrder)
            global iirFilter;
            global numerator;
            global denominator;
            global frequencies;
            % Checks which filter type has been selected
            if (iirFilter == true)
                % Lowpass filter has been applied to all the frequency
                % sliders
                [numerator{1}, denominator{1}] = butter(iirOrder,frequencies(2)/(Fs/2));
                for i = 1 : 9
                     [numerator{i},denominator{i}] = butter(iirOrder,[frequencies(i) frequencies(i+1)]/(Fs/2));
                end
            else
                % Runs this code is FIR type has been selected
                numerator{1} = fir1(firOrder , frequencies(2)/(Fs/2));
                for i = 1 : 9
                    numerator{i} = fir1(firOrder, [frequencies(i) frequencies(i+1)]/(Fs/2));
                end
            end
        end

        
        % Filtering the sound
        function filterSound(~,y)
            global filteredSound;
            global iirFilter;
            filteredSound = cell(10,1);
            global numerator;
            global denominator;
            % Runs code based on filter type chosen
            if (iirFilter == true)
                % IIR Type
                for i = 1 : 9
                    filteredSound{i} = filter(numerator{i} , denominator{i}, y);
                end
            else
                % FIR Type
               for i = 1 : 9
                    filteredSound{i} = filter(numerator{i} , 1, y);
               end
            end
        end
        
        
        % Sets up the time format for the audio files
        function time = formatTime(~, seconds)
            minutes = floor(seconds / 60);
            seconds = seconds - minutes * 60;
            time = minutes + ":" + seconds;
        end
        
        % Calculates total time from audio file and displays it to the user
        function setTotalTime(app, size, Fs)
            app.seconds = ceil(size / Fs);
            app.Label_totalTime.Text = formatTime(app, app.seconds);
            app.Label_currentTime.Text = "0:00";
        end
        
        % Calculates the current time and changes as the audio file is
        % played
        function setCurrentTime(app)
            for i = 0 : app.seconds
                if(app.playing)
                    app.Label_currentTime.Text = formatTime(app, i);
                    app.pausedAt = i;
                    pause(1);
                end
            end
            if(app.pausedAt == app.seconds)
                app.Label_currentTime.Text = "0:00";
            end
        end
        
        % Incase the audio has been paused the current time is saved and
        % once the user clicks play again the time continues from where the
        % used decided to pause.
        function resumeCurrentTime(app)
            for i = app.pausedAt : app.seconds
                if(app.playing)
                    app.Label_currentTime.Text = formatTime(app, i);
                    pause(1);
                    temp = i;
                end
            end
            app.pausedAt = temp;
            if(app.pausedAt == app.seconds)
                app.Label_currentTime.Text = "0:00";
            end
        end
        
        % Gets the current values of the EQ sliders and stores it in an
        % array.
        function getSliders(app)
            global slidersValues;
            slidersValues(1) = app.channel1.Value;
            slidersValues(2) = app.channel2.Value;
            slidersValues(3) = app.channel3.Value;
            slidersValues(4) = app.channel4.Value;
            slidersValues(5) = app.channel5.Value;
            slidersValues(6) = app.channel6.Value;
            slidersValues(7) = app.channel7.Value;
            slidersValues(8) = app.channel8.Value;
            slidersValues(9) = app.channel9.Value;
            slidersValues(10) = app.channel10.Value;
        end

        % Calculating the plot values for the modified signal after the
        % filter has been applied to the orignal signal
        function compositeSignal =  getCompositeSignal(~)
            global slidersValues;
            global filteredSound;
            compositeSignal = 10^(slidersValues(1)/20) * filteredSound{1};
            for i = 1 : 9
                compositeSignal = compositeSignal + (10^(slidersValues(i)/20) * filteredSound{i});
            end
        end
        
        % Calculating the time length for the graph.
        function time = calculateTime(~,signal,Fs)
            dt = 1/Fs;
            time = 0:dt:(length(signal)*dt)-dt;
        end
        
        % Calculating the frequency range for the graph.
        function frequency = calculateFrequency(~,signal,Fs)
            n = length(signal) - 1;
            frequency = 0:Fs/n:Fs;
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            global iirFilter; 
            global firFilter; 
            global frequencies;
            global numerator; 
            global denominator;
            global slidersValues;
            global firOrder;
            global iirOrder;
            
            
            % Setting up the inital values for the equalizer
            
            frequencies = [32,64,125,250,500,1000,2000,4000,8000,16000];
            firFilter = false;
            iirFilter = true;
            numerator = cell(9,1);
            denominator = cell(9,1);
            slidersValues = [];
            firOrder = 30;
            iirOrder = 2;
            clc;
        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            % Allowing the user to load in an audio file
            [file,path] = uigetfile({'*.wav;*.mp3;*.flac;*.m4a;*.mp4;*.aac',['Audio Files ' ...
                '(*.wav,*.mp3,*.flac,*.m4a,*.mp4,*.aac)'];'*.wav;','Wav files (*.wav)'; ...
                '*.mp3;','MP3 files (*.mp3)';'*.flac;','Flac files (*.flac)';'*.m4a;', ...
                'MPEG-4 files (*.m4a)';'*.mp4;','MP4 files (*.mp4)';'*.aac;', ...
                'Advanced Audio Coding files (*.aac)';'*.*','All Files (*.*)'},'Select a File');
            % Storing file path and audio file name to display it to
            % the user so they know which file they are current playing.
            if ~isequal(file,0)
                app.file_path = fullfile(path,file);
                app.directoryLabel.Text = file;
                app.playing = false;
                app.paused = false;
            end
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            global compositeSignal;
            global firOrder;
            global iirOrder;
            
            % Checking if the current audio file was paused.
            if app.paused
                app.playing = true;
                resume(app.player);
                resumeCurrentTime(app);
            end
            
            if ~app.playing
                % Reading the audio files data
                [app.y, app.Fs] = audioread(app.file_path);
                % Getting user specified frequency
                userDefinedFs = app.OutputsamplerateEditField.Value;
                % Resampling the audio file with the user specified
                % frequency
                app.y = resample(app.y,userDefinedFs,app.Fs);
                size = length(app.y);
                
                % Setting up the total times and the filters
                setTotalTime(app, size, userDefinedFs);
                setFilters(app,userDefinedFs,firOrder,iirOrder);
                filterSound(app,app.y);
                getSliders(app);
                compositeSignal = getCompositeSignal(app);
                
                % Checks to see which filter has been chosen and depending
                % on the filter chosen that filter is run.
            if get(app.WahWahCheckBox, 'Value')
                compositeSignal = wah_wah(compositeSignal, userDefinedFs);
            end
            if get(app.FlangerCheckBox, 'Value')
                compositeSignal = flanger(compositeSignal, userDefinedFs);
            end
            if get(app.RingModulationCheckBox, 'Value')
                compositeSignal = ring_mod(compositeSignal, app.Fs);
            end
               
                % Amplifying audio based on users set volume
                compositeSignal = app.VolumeKnob.Value * compositeSignal;
                
                % Playing the audio file
                app.player = audioplayer(compositeSignal, userDefinedFs);
                time = calculateTime(app,compositeSignal,userDefinedFs);
                
                % Plotting the audio data
                plot(app.UIAxes,time,compositeSignal);
                frequency = calculateFrequency(app,compositeSignal,userDefinedFs);
                plot(app.UIAxes_2,frequency,abs(fftshift(fft(compositeSignal))));
                time = calculateTime(app,app.y,userDefinedFs);
                plot(app.UIAxes_3,time,app.y);
                frequency = calculateFrequency(app,app.y,userDefinedFs);
                plot(app.UIAxes_4,frequency,abs(fftshift(fft(app.y))));
                
                app.playing = true;
                play(app.player);
                setCurrentTime(app);
                StopButtonPushed(app)
            end
        end

        % Button pushed function: PauseButton
        function PauseButtonPushed(app, event)
            % Pauses the audio file at the current position
            if app.playing
                app.playing = false;
                pause(app.player);
                app.paused = true;
            end
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            % Completely stops the audio file from playing and the timer is
            % reset to the start
            app.playing = false;
            app.paused = false;
            stop(app.player);
            app.Label_currentTime.Text = "0:00";
            app.pausedAt = 0;
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            global compositeSignal;
            
            % Audio files can be saved one effects have been added to the
            % orignal audio.
            % One disadvantage is that the output file can we overwritten
            % if the user decides to save another file.
            userDefinedFs = app.OutputsamplerateEditField.Value;
            disp("Writing to output file")
            audiowrite('output.wav',compositeSignal,userDefinedFs);
        end

        % Selection changed function: FilterTypeButtonGroup
        function FilterTypeButtonGroupSelectionChanged(app, event)
            selectedButton = app.FilterTypeButtonGroup.SelectedObject;
            global iirFilter;
            global firFilter;
            
            % Checks to see which Type filter has been selected.
            if selectedButton.Text == "IIR"
                iirFilter = true;
                firFilter = false;
            else
                firFilter = true;
                iirFilter = false;
            end
        end

        % Value changed function: VolumeKnob
        function VolumeKnobValueChanged(app, event)
            % Stores the value of the volume selected by the user and
            % displays it to the user.
            value = app.VolumeKnob.Value;
            app.VolumeEditField.Value = value;
        end

        % Value changed function: VolumeEditField
        function VolumeEditFieldValueChanged(app, event)
            % User can manually set the volume using the numeric field.
            % Error checks are done to make sure the user does not enter a
            % negative value or a values over 100.
            Editvalue = app.VolumeEditField.Value;
            if  Editvalue > 100
                Editvalue = 100;
            end
            if Editvalue < 1
                Editvalue = 10;
            end
            app.VolumeKnob.Value = Editvalue;
        end

        % Value changed function: PresetsDropDown
        function presets_Callback(app, event)
            % Setting up the sliders based on the preset chosen.
            
            value = app.PresetsDropDown.Value;
            if (strcmp(value,'Manual'))
                
            elseif (strcmp(value,'Pop'))
                app.channel1.Value = -1.5;
                app.channel2.Value =  3.9;
                app.channel3.Value =  5.4;
                app.channel4.Value =  4.5;
                app.channel5.Value =  0.9;
                app.channel6.Value = -1.5;
                app.channel7.Value = -1.8;
                app.channel8.Value = -2.1;
                app.channel9.Value = -2.1;
                app.channel10.Value = 1.5;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Rock'))
                app.channel1.Value =  4.5;
                app.channel2.Value = -3.6;
                app.channel3.Value = -6.6;
                app.channel4.Value = -2.7;
                app.channel5.Value =  2.1;
                app.channel6.Value =  6.0;
                app.channel7.Value =  7.5;
                app.channel8.Value =  7.8;
                app.channel9.Value =  7.8;
                app.channel10.Value =  6.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Techno'))
                app.channel1.Value =  4.8;
                app.channel2.Value =  4.2;
                app.channel3.Value =  1.5;
                app.channel4.Value = -2.4;
                app.channel5.Value = -3.3;
                app.channel6.Value = -1.5;
                app.channel7.Value =  1.5;
                app.channel8.Value =  5.1;
                app.channel9.Value =  5.7;
                app.channel10.Value =  7.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Party'))
                app.channel1.Value =  6.0;
                app.channel2.Value =  0.0;
                app.channel3.Value =  0.0;
                app.channel4.Value =  0.0;
                app.channel5.Value =  0.0;
                app.channel6.Value =  0.0;
                app.channel7.Value =  0.0;
                app.channel8.Value =  0.0;
                app.channel9.Value =  0.0;
                app.channel10.Value =  6.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Classical'))
                app.channel1.Value =  0.0;
                app.channel2.Value =  0.0;
                app.channel3.Value =  0.0;
                app.channel4.Value =  0.0;
                app.channel5.Value =  0.0;
                app.channel6.Value =  0.0;
                app.channel7.Value = -0.3;
                app.channel8.Value = -5.7;
                app.channel9.Value = -6.0;
                app.channel10.Value =  -6.2;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Bass Booster'))
                app.channel1.Value =  3.0;
                app.channel2.Value =  3.0;
                app.channel3.Value =  2.0;
                app.channel4.Value =  2.0;
                app.channel5.Value =  1.0;
                app.channel6.Value =  0.0;
                app.channel7.Value =  0.0;
                app.channel8.Value =  0.0;
                app.channel9.Value =  0.0;
                app.channel10.Value =  0.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Bass Reducer'))
                app.channel1.Value =  -3.0;
                app.channel2.Value =  -3.0;
                app.channel3.Value =  -2.0;
                app.channel4.Value =  -2.0;
                app.channel5.Value =  -1.0;
                app.channel6.Value =  0.0;
                app.channel7.Value =  0.0;
                app.channel8.Value = 1.75;
                app.channel9.Value =  2.0;
                app.channel10.Value =  2.5;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'HipHop'))
                app.channel1.Value =  4.0;
                app.channel2.Value =  3.0;
                app.channel3.Value =  1.0;
                app.channel4.Value =  2.0;
                app.channel5.Value =  -1.0;
                app.channel6.Value =  -1.0;
                app.channel7.Value =  1.0;
                app.channel8.Value = -1.0;
                app.channel9.Value =  1.0;
                app.channel10.Value =  2.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Jazz'))
                app.channel1.Value =  3.0;
                app.channel2.Value =  2.0;
                app.channel3.Value =  1.0;
                app.channel4.Value =  1.0;
                app.channel5.Value =  -1.0;
                app.channel6.Value =  -1.0;
                app.channel7.Value =  0.0;
                app.channel8.Value = 1.0;
                app.channel9.Value =  2.0;
                app.channel10.Value =  3.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Loudness'))
                app.channel1.Value =  4.0;
                app.channel2.Value =  3.0;
                app.channel3.Value =  0.0;
                app.channel4.Value =  0.0;
                app.channel5.Value =  -1.0;
                app.channel6.Value =  0.0;
                app.channel7.Value =  -1.0;
                app.channel8.Value = -4.0;
                app.channel9.Value =  3.0;
                app.channel10.Value =  1.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Piano'))
                app.channel1.Value =  2.0;
                app.channel2.Value =  1.0;
                app.channel3.Value =  0.0;
                app.channel4.Value =  2.0;
                app.channel5.Value =  2.0;
                app.channel6.Value =  1.0;
                app.channel7.Value =  3.0;
                app.channel8.Value = 3.0;
                app.channel9.Value =  2.0;
                app.channel10.Value =  2.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Treble Booster'))
                app.channel1.Value =  0.0;
                app.channel2.Value =  0.0;
                app.channel3.Value =  0.0;
                app.channel4.Value =  0.0;
                app.channel5.Value =  0.0;
                app.channel6.Value =  1.0;
                app.channel7.Value =  2.0;
                app.channel8.Value = 3.0;
                app.channel9.Value =  3.0;
                app.channel10.Value =  4.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            elseif (strcmp(value,'Treble Reducer'))
                app.channel1.Value =  0.0;
                app.channel2.Value =  0.0;
                app.channel3.Value =  0.0;
                app.channel4.Value =  0.0;
                app.channel5.Value =  0.0;
                app.channel6.Value =  -1.0;
                app.channel7.Value =  -2.0;
                app.channel8.Value = -3.0;
                app.channel9.Value =  -3.0;
                app.channel10.Value =  -4.0;
                app.dBEditField1.Value = app.channel1.Value;
                app.dBEditField2.Value = app.channel2.Value;
                app.dBEditField3.Value = app.channel3.Value;
                app.dBEditField4.Value = app.channel4.Value;
                app.dBEditField5.Value = app.channel5.Value;
                app.dBEditField6.Value = app.channel6.Value;
                app.dBEditField7.Value = app.channel7.Value;
                app.dBEditField8.Value = app.channel8.Value;
                app.dBEditField9.Value = app.channel9.Value;
                app.dBEditField10.Value = app.channel10.Value;
            end
        end

        % Value changed function: channel1
        function Slider1ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel1.Value;
            app.dBEditField1.Value = value;
        end

        % Value changed function: dBEditField1
        function ChangeSlider1Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField1.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel1.Value = value;
        end

        % Value changed function: channel2
        function Slider2ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel2.Value;
            app.dBEditField2.Value = value;
        end

        % Value changed function: dBEditField2
        function ChangeSlider2Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField2.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel2.Value = value;
        end

        % Value changed function: channel3
        function Slider3ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel3.Value;
            app.dBEditField3.Value = value;
        end

        % Value changed function: dBEditField3
        function ChangeSlider3Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField3.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel3.Value = value;
        end

        % Value changed function: channel4
        function Slider4ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel4.Value;
            app.dBEditField4.Value = value;
        end

        % Value changed function: dBEditField4
        function ChangeSlider4Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField4.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel4.Value = value; 
        end

        % Value changed function: channel5
        function Slider5ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel5.Value;
            app.dBEditField5.Value = value;
        end

        % Value changed function: dBEditField5
        function ChangeSlider5Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField5.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel5.Value = value; 
        end

        % Value changed function: channel6
        function Slider6ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel6.Value;
            app.dBEditField6.Value = value;
        end

        % Value changed function: dBEditField6
        function ChangeSlider6Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField6.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel6.Value = value; 
        end

        % Value changed function: channel7
        function Slider7ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel7.Value;
            app.dBEditField7.Value = value;
        end

        % Value changed function: dBEditField7
        function ChangeSlider7Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField7.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel7.Value = value; 
        end

        % Value changed function: channel8
        function Slider8ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel8.Value;
            app.dBEditField8.Value = value;
        end

        % Value changed function: dBEditField8
        function ChangeSlider8Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField8.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel8.Value = value; 
        end

        % Value changed function: channel9
        function Slider9ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel9.Value;
            app.dBEditField9.Value = value;
        end

        % Value changed function: dBEditField9
        function ChangeSlider9Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField9.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel9.Value = value; 
        end

        % Value changed function: channel10
        function Slider10ValueChange(app, event)
            % Gets value of selected slider and displays it to the user
            % using the numeric field
            value = app.channel10.Value;
            app.dBEditField10.Value = value;
        end

        % Value changed function: dBEditField10
        function ChangeSlider10Value(app, event)
            % Allowing the user to manually enter a value for the slider
            % using the numberic field.
            % User can only enter a value from -12db to 12db
            value = app.dBEditField10.Value;
            if value > 12
                value = 12;
            end
            if value < -12
                value = -12;
            end
            app.channel10.Value = value; 
        end

        % Value changing function: channel1
        function Slider1ValueChange1(app, event)
            changingValue = event.Value;
            app.dBEditField1.Value = changingValue;
        end

        % Button pushed function: ResetButton
        function reset_Sliders(app, event)
            % Resets the slider values and text boxes to 0
            set(app.channel1,'value',0);
            set(app.channel2,'value',0);
            set(app.channel3,'value',0);
            set(app.channel4,'value',0);
            set(app.channel5,'value',0);
            set(app.channel6,'value',0);
            set(app.channel7,'value',0);
            set(app.channel8,'value',0);
            set(app.channel9,'value',0);
            set(app.channel10,'value',0);
            set(app.dBEditField1, 'value',0.00);
            set(app.dBEditField2, 'value',0.00);
            set(app.dBEditField3, 'value',0.00);
            set(app.dBEditField4, 'value',0.00);
            set(app.dBEditField5, 'value',0.00);
            set(app.dBEditField6, 'value',0.00);
            set(app.dBEditField7, 'value',0.00);
            set(app.dBEditField8, 'value',0.00);
            set(app.dBEditField9, 'value',0.00);
            set(app.dBEditField10, 'value',0.00);
        
            
            % Resets the drop-down preset to manual
            app.PresetsDropDown.Value = 'Manual';
        end

        % Value changed function: WahWahCheckBox
        function wahwah_Callback(app, event)
           % value = app.WahWahCheckBox.Value;
            
            % Makes sure no other check box has been selected
            set(app.FlangerCheckBox, 'Value',0);
            set(app.RingModulationCheckBox, 'Value',0);
        end

        % Value changed function: RingModulationCheckBox
        function ringmod_Callback(app, event)
           % value = app.RingModulationCheckBox.Value;
            
           % Makes sure no other check box has been selected
            set(app.FlangerCheckBox, 'Value',0);
            set(app.WahWahCheckBox, 'Value',0);
        end

        % Value changed function: FlangerCheckBox
        function flanger_Callback(app, event)
           % value = app.FlangerCheckBox.Value;
            
           % Makes sure no other check box has been selected
            set(app.WahWahCheckBox, 'Value',0);
            set(app.RingModulationCheckBox, 'Value',0);
        end

        % Button pushed function: ClearButton
        function clearcheckboxes_Callback(app, event)
            % Clears any selected check box
            set(app.WahWahCheckBox, 'Value',0);
            set(app.RingModulationCheckBox, 'Value',0);
            set(app.FlangerCheckBox, 'Value',0);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.7176 0.2745 1];
            app.UIFigure.Position = [100 100 894 603];
            app.UIFigure.Name = 'MATLAB App';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.TabLocation = 'bottom';
            app.TabGroup.Position = [1 0 894 604];

            % Create EqualizerTab
            app.EqualizerTab = uitab(app.TabGroup);
            app.EqualizerTab.Title = 'Equalizer';
            app.EqualizerTab.BackgroundColor = [0.149 0.9882 0.9059];
            app.EqualizerTab.ForegroundColor = [0 0 1];

            % Create PlayerPanel
            app.PlayerPanel = uipanel(app.EqualizerTab);
            app.PlayerPanel.TitlePosition = 'centertop';
            app.PlayerPanel.Title = 'Player';
            app.PlayerPanel.BackgroundColor = [0.7137 0.9804 0.9529];
            app.PlayerPanel.FontName = 'Comic Sans MS';
            app.PlayerPanel.FontWeight = 'bold';
            app.PlayerPanel.FontSize = 14;
            app.PlayerPanel.Position = [20 407 850 159];

            % Create FileLabel
            app.FileLabel = uilabel(app.PlayerPanel);
            app.FileLabel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FileLabel.FontName = 'Comic Sans MS';
            app.FileLabel.FontWeight = 'bold';
            app.FileLabel.Position = [41 106 106 22];
            app.FileLabel.Text = 'Audio File Name:';

            % Create directoryLabel
            app.directoryLabel = uilabel(app.PlayerPanel);
            app.directoryLabel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.directoryLabel.HorizontalAlignment = 'center';
            app.directoryLabel.FontName = 'Comic Sans MS';
            app.directoryLabel.Position = [146 106 500 22];
            app.directoryLabel.Text = 'Load A File To Play Audio From';

            % Create BrowseButton
            app.BrowseButton = uibutton(app.PlayerPanel, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Icon = 'icons8-search-26.png';
            app.BrowseButton.FontName = 'Comic Sans MS';
            app.BrowseButton.FontWeight = 'bold';
            app.BrowseButton.Position = [671 104 100 26];
            app.BrowseButton.Text = 'Browse';

            % Create Label_currentTime
            app.Label_currentTime = uilabel(app.PlayerPanel);
            app.Label_currentTime.FontName = 'Comic Sans MS';
            app.Label_currentTime.FontWeight = 'bold';
            app.Label_currentTime.Position = [133 74 51 22];
            app.Label_currentTime.Text = '-- : --';

            % Create ofLabel
            app.ofLabel = uilabel(app.PlayerPanel);
            app.ofLabel.FontName = 'Comic Sans MS';
            app.ofLabel.FontSize = 13;
            app.ofLabel.FontWeight = 'bold';
            app.ofLabel.Position = [191 74 25 22];
            app.ofLabel.Text = 'of';

            % Create Label_totalTime
            app.Label_totalTime = uilabel(app.PlayerPanel);
            app.Label_totalTime.FontName = 'Comic Sans MS';
            app.Label_totalTime.FontWeight = 'bold';
            app.Label_totalTime.Position = [215 74 51 22];
            app.Label_totalTime.Text = '-- : --';

            % Create PlayButton
            app.PlayButton = uibutton(app.PlayerPanel, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Icon = 'icons8-play-26.png';
            app.PlayButton.FontName = 'Comic Sans MS';
            app.PlayButton.FontWeight = 'bold';
            app.PlayButton.Position = [87 42 100 26];
            app.PlayButton.Text = 'Play';

            % Create StopButton
            app.StopButton = uibutton(app.PlayerPanel, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Icon = 'icons8-stop-26.png';
            app.StopButton.FontName = 'Comic Sans MS';
            app.StopButton.FontWeight = 'bold';
            app.StopButton.Position = [86 11 100 26];
            app.StopButton.Text = 'Stop';

            % Create PauseButton
            app.PauseButton = uibutton(app.PlayerPanel, 'push');
            app.PauseButton.ButtonPushedFcn = createCallbackFcn(app, @PauseButtonPushed, true);
            app.PauseButton.Icon = 'icons8-pause-26.png';
            app.PauseButton.FontName = 'Comic Sans MS';
            app.PauseButton.FontWeight = 'bold';
            app.PauseButton.Position = [212 42 100 26];
            app.PauseButton.Text = 'Pause';

            % Create SaveButton
            app.SaveButton = uibutton(app.PlayerPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Icon = 'icons8-save-as-26.png';
            app.SaveButton.FontName = 'Comic Sans MS';
            app.SaveButton.FontWeight = 'bold';
            app.SaveButton.Position = [213 11 100 26];
            app.SaveButton.Text = 'Save';

            % Create SampleRateEditFieldLabel
            app.SampleRateEditFieldLabel = uilabel(app.PlayerPanel);
            app.SampleRateEditFieldLabel.HorizontalAlignment = 'right';
            app.SampleRateEditFieldLabel.FontName = 'Comic Sans MS';
            app.SampleRateEditFieldLabel.FontWeight = 'bold';
            app.SampleRateEditFieldLabel.Position = [573 61 83 22];
            app.SampleRateEditFieldLabel.Text = 'Sample Rate:';

            % Create OutputsamplerateEditField
            app.OutputsamplerateEditField = uieditfield(app.PlayerPanel, 'numeric');
            app.OutputsamplerateEditField.Limits = [32001 Inf];
            app.OutputsamplerateEditField.ValueDisplayFormat = '%.0f';
            app.OutputsamplerateEditField.HorizontalAlignment = 'left';
            app.OutputsamplerateEditField.FontName = 'Comic Sans MS';
            app.OutputsamplerateEditField.Position = [671 61 100 22];
            app.OutputsamplerateEditField.Value = 44100;

            % Create VolumeKnobLabel
            app.VolumeKnobLabel = uilabel(app.PlayerPanel);
            app.VolumeKnobLabel.HorizontalAlignment = 'center';
            app.VolumeKnobLabel.FontName = 'Comic Sans MS';
            app.VolumeKnobLabel.FontWeight = 'bold';
            app.VolumeKnobLabel.Position = [396 46 45 22];
            app.VolumeKnobLabel.Text = 'Volume';

            % Create VolumeKnob
            app.VolumeKnob = uiknob(app.PlayerPanel, 'continuous');
            app.VolumeKnob.ValueChangedFcn = createCallbackFcn(app, @VolumeKnobValueChanged, true);
            app.VolumeKnob.FontName = 'Comic Sans MS';
            app.VolumeKnob.FontWeight = 'bold';
            app.VolumeKnob.Position = [475 31 52 52];

            % Create VolumeEditField
            app.VolumeEditField = uieditfield(app.PlayerPanel, 'numeric');
            app.VolumeEditField.ValueChangedFcn = createCallbackFcn(app, @VolumeEditFieldValueChanged, true);
            app.VolumeEditField.Position = [403 13 34 22];

            % Create FiltersPanel
            app.FiltersPanel = uipanel(app.EqualizerTab);
            app.FiltersPanel.TitlePosition = 'centertop';
            app.FiltersPanel.Title = 'Filters';
            app.FiltersPanel.BackgroundColor = [0.7137 0.9804 0.9529];
            app.FiltersPanel.FontName = 'Comic Sans MS';
            app.FiltersPanel.FontWeight = 'bold';
            app.FiltersPanel.FontSize = 14;
            app.FiltersPanel.Position = [20 17 850 379];

            % Create FilterTypeButtonGroup
            app.FilterTypeButtonGroup = uibuttongroup(app.FiltersPanel);
            app.FilterTypeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @FilterTypeButtonGroupSelectionChanged, true);
            app.FilterTypeButtonGroup.TitlePosition = 'centertop';
            app.FilterTypeButtonGroup.Title = 'Filter Type';
            app.FilterTypeButtonGroup.FontName = 'Comic Sans MS';
            app.FilterTypeButtonGroup.FontWeight = 'bold';
            app.FilterTypeButtonGroup.Position = [28 281 165 59];

            % Create IIRButton_2
            app.IIRButton_2 = uiradiobutton(app.FilterTypeButtonGroup);
            app.IIRButton_2.Text = 'IIR';
            app.IIRButton_2.FontName = 'Comic Sans MS';
            app.IIRButton_2.Position = [22 8 43 22];
            app.IIRButton_2.Value = true;

            % Create FIRButton
            app.FIRButton = uiradiobutton(app.FilterTypeButtonGroup);
            app.FIRButton.Text = 'FIR';
            app.FIRButton.FontName = 'Comic Sans MS';
            app.FIRButton.Position = [90 8 43 22];

            % Create FiltersGainPanel
            app.FiltersGainPanel = uipanel(app.FiltersPanel);
            app.FiltersGainPanel.TitlePosition = 'centertop';
            app.FiltersGainPanel.Title = 'Filter Slider Gains';
            app.FiltersGainPanel.FontName = 'Comic Sans MS';
            app.FiltersGainPanel.FontWeight = 'bold';
            app.FiltersGainPanel.Position = [23 19 803 245];

            % Create HzLabel
            app.HzLabel = uilabel(app.FiltersGainPanel);
            app.HzLabel.HorizontalAlignment = 'center';
            app.HzLabel.FontName = 'Comic Sans MS';
            app.HzLabel.FontWeight = 'bold';
            app.HzLabel.Position = [23 25 41 22];
            app.HzLabel.Text = '32 Hz';

            % Create channel1
            app.channel1 = uislider(app.FiltersGainPanel);
            app.channel1.Limits = [-12 12];
            app.channel1.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel1.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel1.Orientation = 'vertical';
            app.channel1.ValueChangedFcn = createCallbackFcn(app, @Slider1ValueChange, true);
            app.channel1.ValueChangingFcn = createCallbackFcn(app, @Slider1ValueChange1, true);
            app.channel1.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel1.FontName = 'Comic Sans MS';
            app.channel1.FontWeight = 'bold';
            app.channel1.Position = [15 60 3 147];

            % Create HzLabel_2
            app.HzLabel_2 = uilabel(app.FiltersGainPanel);
            app.HzLabel_2.HorizontalAlignment = 'center';
            app.HzLabel_2.FontName = 'Comic Sans MS';
            app.HzLabel_2.FontWeight = 'bold';
            app.HzLabel_2.Position = [105 25 41 22];
            app.HzLabel_2.Text = '64 Hz';

            % Create channel2
            app.channel2 = uislider(app.FiltersGainPanel);
            app.channel2.Limits = [-12 12];
            app.channel2.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel2.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel2.Orientation = 'vertical';
            app.channel2.ValueChangedFcn = createCallbackFcn(app, @Slider2ValueChange, true);
            app.channel2.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel2.FontName = 'Comic Sans MS';
            app.channel2.FontWeight = 'bold';
            app.channel2.Position = [96 60 3 147];

            % Create HzLabel_3
            app.HzLabel_3 = uilabel(app.FiltersGainPanel);
            app.HzLabel_3.HorizontalAlignment = 'center';
            app.HzLabel_3.FontName = 'Comic Sans MS';
            app.HzLabel_3.FontWeight = 'bold';
            app.HzLabel_3.Position = [183 25 48 22];
            app.HzLabel_3.Text = '125 Hz';

            % Create channel3
            app.channel3 = uislider(app.FiltersGainPanel);
            app.channel3.Limits = [-12 12];
            app.channel3.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel3.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel3.Orientation = 'vertical';
            app.channel3.ValueChangedFcn = createCallbackFcn(app, @Slider3ValueChange, true);
            app.channel3.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel3.FontName = 'Comic Sans MS';
            app.channel3.FontWeight = 'bold';
            app.channel3.Position = [177 60 3 147];

            % Create HzLabel_4
            app.HzLabel_4 = uilabel(app.FiltersGainPanel);
            app.HzLabel_4.HorizontalAlignment = 'center';
            app.HzLabel_4.FontName = 'Comic Sans MS';
            app.HzLabel_4.FontWeight = 'bold';
            app.HzLabel_4.Position = [264 25 48 22];
            app.HzLabel_4.Text = '250 Hz';

            % Create channel4
            app.channel4 = uislider(app.FiltersGainPanel);
            app.channel4.Limits = [-12 12];
            app.channel4.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel4.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel4.Orientation = 'vertical';
            app.channel4.ValueChangedFcn = createCallbackFcn(app, @Slider4ValueChange, true);
            app.channel4.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel4.FontName = 'Comic Sans MS';
            app.channel4.FontWeight = 'bold';
            app.channel4.Position = [258 60 3 147];

            % Create HzLabel_5
            app.HzLabel_5 = uilabel(app.FiltersGainPanel);
            app.HzLabel_5.HorizontalAlignment = 'center';
            app.HzLabel_5.FontName = 'Comic Sans MS';
            app.HzLabel_5.FontWeight = 'bold';
            app.HzLabel_5.Position = [338 25 48 22];
            app.HzLabel_5.Text = '500 Hz';

            % Create channel5
            app.channel5 = uislider(app.FiltersGainPanel);
            app.channel5.Limits = [-12 12];
            app.channel5.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel5.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel5.Orientation = 'vertical';
            app.channel5.ValueChangedFcn = createCallbackFcn(app, @Slider5ValueChange, true);
            app.channel5.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel5.FontName = 'Comic Sans MS';
            app.channel5.FontWeight = 'bold';
            app.channel5.Position = [335 60 3 147];

            % Create KHzLabel
            app.KHzLabel = uilabel(app.FiltersGainPanel);
            app.KHzLabel.HorizontalAlignment = 'center';
            app.KHzLabel.FontName = 'Comic Sans MS';
            app.KHzLabel.FontWeight = 'bold';
            app.KHzLabel.Position = [421 25 41 22];
            app.KHzLabel.Text = '1 KHz';

            % Create channel6
            app.channel6 = uislider(app.FiltersGainPanel);
            app.channel6.Limits = [-12 12];
            app.channel6.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel6.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel6.Orientation = 'vertical';
            app.channel6.ValueChangedFcn = createCallbackFcn(app, @Slider6ValueChange, true);
            app.channel6.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel6.FontName = 'Comic Sans MS';
            app.channel6.FontWeight = 'bold';
            app.channel6.Position = [412 60 3 147];

            % Create KHzLabel_2
            app.KHzLabel_2 = uilabel(app.FiltersGainPanel);
            app.KHzLabel_2.HorizontalAlignment = 'center';
            app.KHzLabel_2.FontName = 'Comic Sans MS';
            app.KHzLabel_2.FontWeight = 'bold';
            app.KHzLabel_2.Position = [501 25 41 22];
            app.KHzLabel_2.Text = {'2 KHz'; ''};

            % Create channel7
            app.channel7 = uislider(app.FiltersGainPanel);
            app.channel7.Limits = [-12 12];
            app.channel7.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel7.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel7.Orientation = 'vertical';
            app.channel7.ValueChangedFcn = createCallbackFcn(app, @Slider7ValueChange, true);
            app.channel7.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel7.FontName = 'Comic Sans MS';
            app.channel7.FontWeight = 'bold';
            app.channel7.Position = [492 60 3 147];

            % Create KHzLabel_3
            app.KHzLabel_3 = uilabel(app.FiltersGainPanel);
            app.KHzLabel_3.HorizontalAlignment = 'center';
            app.KHzLabel_3.FontName = 'Comic Sans MS';
            app.KHzLabel_3.FontWeight = 'bold';
            app.KHzLabel_3.Position = [582 25 41 22];
            app.KHzLabel_3.Text = {'4 KHz'; ''};

            % Create channel8
            app.channel8 = uislider(app.FiltersGainPanel);
            app.channel8.Limits = [-12 12];
            app.channel8.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel8.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel8.Orientation = 'vertical';
            app.channel8.ValueChangedFcn = createCallbackFcn(app, @Slider8ValueChange, true);
            app.channel8.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel8.FontName = 'Comic Sans MS';
            app.channel8.FontWeight = 'bold';
            app.channel8.Position = [573 60 3 147];

            % Create KHzLabel_4
            app.KHzLabel_4 = uilabel(app.FiltersGainPanel);
            app.KHzLabel_4.HorizontalAlignment = 'center';
            app.KHzLabel_4.FontName = 'Comic Sans MS';
            app.KHzLabel_4.FontWeight = 'bold';
            app.KHzLabel_4.Position = [662 25 41 22];
            app.KHzLabel_4.Text = '8 KHz';

            % Create channel9
            app.channel9 = uislider(app.FiltersGainPanel);
            app.channel9.Limits = [-12 12];
            app.channel9.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel9.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel9.Orientation = 'vertical';
            app.channel9.ValueChangedFcn = createCallbackFcn(app, @Slider9ValueChange, true);
            app.channel9.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel9.FontName = 'Comic Sans MS';
            app.channel9.FontWeight = 'bold';
            app.channel9.Position = [653 59 3 147];

            % Create KHzLabel_5
            app.KHzLabel_5 = uilabel(app.FiltersGainPanel);
            app.KHzLabel_5.HorizontalAlignment = 'center';
            app.KHzLabel_5.FontName = 'Comic Sans MS';
            app.KHzLabel_5.FontWeight = 'bold';
            app.KHzLabel_5.Position = [737 25 48 22];
            app.KHzLabel_5.Text = '16 KHz';

            % Create channel10
            app.channel10 = uislider(app.FiltersGainPanel);
            app.channel10.Limits = [-12 12];
            app.channel10.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel10.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel10.Orientation = 'vertical';
            app.channel10.ValueChangedFcn = createCallbackFcn(app, @Slider10ValueChange, true);
            app.channel10.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel10.FontName = 'Comic Sans MS';
            app.channel10.FontWeight = 'bold';
            app.channel10.Position = [733 60 3 147];

            % Create dBEditFieldLabel
            app.dBEditFieldLabel = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel.HorizontalAlignment = 'right';
            app.dBEditFieldLabel.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel.FontWeight = 'bold';
            app.dBEditFieldLabel.Position = [48 3 32 22];
            app.dBEditFieldLabel.Text = 'dB';

            % Create dBEditField2
            app.dBEditField2 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField2.ValueDisplayFormat = '%.2f';
            app.dBEditField2.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider2Value, true);
            app.dBEditField2.FontName = 'Comic Sans MS';
            app.dBEditField2.Position = [100 2 45 22];

            % Create dBEditField1
            app.dBEditField1 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField1.ValueDisplayFormat = '%.2f';
            app.dBEditField1.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider1Value, true);
            app.dBEditField1.FontName = 'Comic Sans MS';
            app.dBEditField1.Position = [22 3 42 22];

            % Create dBEditFieldLabel_2
            app.dBEditFieldLabel_2 = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel_2.HorizontalAlignment = 'right';
            app.dBEditFieldLabel_2.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel_2.FontWeight = 'bold';
            app.dBEditFieldLabel_2.Position = [137 2 25 22];
            app.dBEditFieldLabel_2.Text = 'dB';

            % Create dBEditField3
            app.dBEditField3 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField3.ValueDisplayFormat = '%.2f';
            app.dBEditField3.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider3Value, true);
            app.dBEditField3.FontName = 'Comic Sans MS';
            app.dBEditField3.Position = [189 3 37 22];

            % Create dBEditFieldLabel_3
            app.dBEditFieldLabel_3 = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel_3.HorizontalAlignment = 'right';
            app.dBEditFieldLabel_3.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel_3.FontWeight = 'bold';
            app.dBEditFieldLabel_3.Position = [218 3 25 22];
            app.dBEditFieldLabel_3.Text = 'dB';

            % Create dBEditField4
            app.dBEditField4 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField4.ValueDisplayFormat = '%.2f';
            app.dBEditField4.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider4Value, true);
            app.dBEditField4.FontName = 'Comic Sans MS';
            app.dBEditField4.Position = [262 2 44 22];

            % Create dBEditFieldLabel_4
            app.dBEditFieldLabel_4 = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel_4.HorizontalAlignment = 'right';
            app.dBEditFieldLabel_4.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel_4.FontWeight = 'bold';
            app.dBEditFieldLabel_4.Position = [298 2 25 22];
            app.dBEditFieldLabel_4.Text = 'dB';

            % Create dBEditField5
            app.dBEditField5 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField5.ValueDisplayFormat = '%.2f';
            app.dBEditField5.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider5Value, true);
            app.dBEditField5.FontName = 'Comic Sans MS';
            app.dBEditField5.Position = [339 2 42 22];

            % Create dBEditFieldLabel_5
            app.dBEditFieldLabel_5 = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel_5.HorizontalAlignment = 'right';
            app.dBEditFieldLabel_5.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel_5.FontWeight = 'bold';
            app.dBEditFieldLabel_5.Position = [373 2 25 22];
            app.dBEditFieldLabel_5.Text = 'dB';

            % Create dBEditField6
            app.dBEditField6 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField6.ValueDisplayFormat = '%.2f';
            app.dBEditField6.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider6Value, true);
            app.dBEditField6.FontName = 'Comic Sans MS';
            app.dBEditField6.Position = [414 2 46 22];

            % Create dBEditFieldLabel_6
            app.dBEditFieldLabel_6 = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel_6.HorizontalAlignment = 'right';
            app.dBEditFieldLabel_6.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel_6.FontWeight = 'bold';
            app.dBEditFieldLabel_6.Position = [452 2 25 22];
            app.dBEditFieldLabel_6.Text = 'dB';

            % Create dBEditField7
            app.dBEditField7 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField7.ValueDisplayFormat = '%.2f';
            app.dBEditField7.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider7Value, true);
            app.dBEditField7.FontName = 'Comic Sans MS';
            app.dBEditField7.Position = [496 2 43 22];

            % Create dBEditFieldLabel_7
            app.dBEditFieldLabel_7 = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel_7.HorizontalAlignment = 'right';
            app.dBEditFieldLabel_7.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel_7.FontWeight = 'bold';
            app.dBEditFieldLabel_7.Position = [531 2 25 22];
            app.dBEditFieldLabel_7.Text = 'dB';

            % Create dBEditField8
            app.dBEditField8 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField8.ValueDisplayFormat = '%.2f';
            app.dBEditField8.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider8Value, true);
            app.dBEditField8.FontName = 'Comic Sans MS';
            app.dBEditField8.Position = [575 2 38 22];

            % Create dBEditFieldLabel_8
            app.dBEditFieldLabel_8 = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel_8.HorizontalAlignment = 'right';
            app.dBEditFieldLabel_8.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel_8.FontWeight = 'bold';
            app.dBEditFieldLabel_8.Position = [605 2 25 22];
            app.dBEditFieldLabel_8.Text = 'dB';

            % Create dBEditField9
            app.dBEditField9 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField9.ValueDisplayFormat = '%.2f';
            app.dBEditField9.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider9Value, true);
            app.dBEditField9.FontName = 'Comic Sans MS';
            app.dBEditField9.Position = [657 3 44 22];

            % Create dBEditFieldLabel_9
            app.dBEditFieldLabel_9 = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel_9.HorizontalAlignment = 'right';
            app.dBEditFieldLabel_9.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel_9.FontWeight = 'bold';
            app.dBEditFieldLabel_9.Position = [693 3 25 22];
            app.dBEditFieldLabel_9.Text = 'dB';

            % Create dBEditField10
            app.dBEditField10 = uieditfield(app.FiltersGainPanel, 'numeric');
            app.dBEditField10.ValueDisplayFormat = '%.2f';
            app.dBEditField10.ValueChangedFcn = createCallbackFcn(app, @ChangeSlider10Value, true);
            app.dBEditField10.FontName = 'Comic Sans MS';
            app.dBEditField10.Position = [737 2 44 22];

            % Create dBEditFieldLabel_11
            app.dBEditFieldLabel_11 = uilabel(app.FiltersGainPanel);
            app.dBEditFieldLabel_11.HorizontalAlignment = 'right';
            app.dBEditFieldLabel_11.FontName = 'Comic Sans MS';
            app.dBEditFieldLabel_11.FontWeight = 'bold';
            app.dBEditFieldLabel_11.Position = [773 2 25 22];
            app.dBEditFieldLabel_11.Text = 'dB';

            % Create PresetsDropDownLabel
            app.PresetsDropDownLabel = uilabel(app.FiltersPanel);
            app.PresetsDropDownLabel.HorizontalAlignment = 'right';
            app.PresetsDropDownLabel.FontName = 'Comic Sans MS';
            app.PresetsDropDownLabel.FontWeight = 'bold';
            app.PresetsDropDownLabel.Position = [272 314 48 22];
            app.PresetsDropDownLabel.Text = 'Presets';

            % Create PresetsDropDown
            app.PresetsDropDown = uidropdown(app.FiltersPanel);
            app.PresetsDropDown.Items = {'Manual', 'HipHop', 'Jazz', 'Loudness', 'Piano', 'Treble Booster', 'Treble Reducer', 'Bass Booster', 'Bass Reducer', 'Pop', 'Rock', 'Techno', 'Party', 'Classical'};
            app.PresetsDropDown.ValueChangedFcn = createCallbackFcn(app, @presets_Callback, true);
            app.PresetsDropDown.Position = [229 285 133 22];
            app.PresetsDropDown.Value = 'Manual';

            % Create EffectsPanel
            app.EffectsPanel = uipanel(app.FiltersPanel);
            app.EffectsPanel.TitlePosition = 'centertop';
            app.EffectsPanel.Title = 'Effects';
            app.EffectsPanel.FontName = 'Comic Sans MS';
            app.EffectsPanel.FontWeight = 'bold';
            app.EffectsPanel.Position = [533 267 293 79];

            % Create WahWahCheckBox
            app.WahWahCheckBox = uicheckbox(app.EffectsPanel);
            app.WahWahCheckBox.ValueChangedFcn = createCallbackFcn(app, @wahwah_Callback, true);
            app.WahWahCheckBox.Text = 'Wah Wah';
            app.WahWahCheckBox.FontName = 'Comic Sans MS';
            app.WahWahCheckBox.Position = [46 32 77 22];

            % Create FlangerCheckBox
            app.FlangerCheckBox = uicheckbox(app.EffectsPanel);
            app.FlangerCheckBox.ValueChangedFcn = createCallbackFcn(app, @flanger_Callback, true);
            app.FlangerCheckBox.Text = 'Flanger';
            app.FlangerCheckBox.FontName = 'Comic Sans MS';
            app.FlangerCheckBox.Position = [46 6 63 22];

            % Create RingModulationCheckBox
            app.RingModulationCheckBox = uicheckbox(app.EffectsPanel);
            app.RingModulationCheckBox.ValueChangedFcn = createCallbackFcn(app, @ringmod_Callback, true);
            app.RingModulationCheckBox.Text = 'Ring Modulation';
            app.RingModulationCheckBox.FontName = 'Comic Sans MS';
            app.RingModulationCheckBox.Position = [137 32 111 22];

            % Create ClearButton
            app.ClearButton = uibutton(app.EffectsPanel, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @clearcheckboxes_Callback, true);
            app.ClearButton.Icon = 'icons8-back-26.png';
            app.ClearButton.FontName = 'Comic Sans MS';
            app.ClearButton.FontWeight = 'bold';
            app.ClearButton.Position = [137 5 100 25];
            app.ClearButton.Text = 'Clear';

            % Create ResetButton
            app.ResetButton = uibutton(app.FiltersPanel, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @reset_Sliders, true);
            app.ResetButton.Icon = 'icons8-reset-26.png';
            app.ResetButton.FontName = 'Comic Sans MS';
            app.ResetButton.FontWeight = 'bold';
            app.ResetButton.Position = [398 287 100 26];
            app.ResetButton.Text = 'Reset';

            % Create OrignalSignalTab
            app.OrignalSignalTab = uitab(app.TabGroup);
            app.OrignalSignalTab.Title = 'Orignal Signal';
            app.OrignalSignalTab.BackgroundColor = [0.149 0.9882 0.9059];
            app.OrignalSignalTab.ForegroundColor = [0 0 1];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.OrignalSignalTab);
            title(app.UIAxes_3, 'Signal in Time Domain')
            xlabel(app.UIAxes_3, 'Time')
            ylabel(app.UIAxes_3, 'Magnitude')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.FontName = 'Comic Sans MS';
            app.UIAxes_3.FontWeight = 'bold';
            app.UIAxes_3.XGrid = 'on';
            app.UIAxes_3.XMinorGrid = 'on';
            app.UIAxes_3.YGrid = 'on';
            app.UIAxes_3.YMinorGrid = 'on';
            app.UIAxes_3.Position = [27 284 843 264];

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.OrignalSignalTab);
            title(app.UIAxes_4, 'Signal in Frequency Domain')
            xlabel(app.UIAxes_4, 'Frequency')
            ylabel(app.UIAxes_4, 'Magnitude')
            zlabel(app.UIAxes_4, 'Z')
            app.UIAxes_4.FontName = 'Comic Sans MS';
            app.UIAxes_4.FontWeight = 'bold';
            app.UIAxes_4.XGrid = 'on';
            app.UIAxes_4.XMinorGrid = 'on';
            app.UIAxes_4.YGrid = 'on';
            app.UIAxes_4.YMinorGrid = 'on';
            app.UIAxes_4.Position = [28 17 842 268];

            % Create ModifiedSignalTab
            app.ModifiedSignalTab = uitab(app.TabGroup);
            app.ModifiedSignalTab.Title = 'Modified Signal';
            app.ModifiedSignalTab.BackgroundColor = [0.149 0.9882 0.9059];
            app.ModifiedSignalTab.ForegroundColor = [0 0 1];

            % Create UIAxes
            app.UIAxes = uiaxes(app.ModifiedSignalTab);
            title(app.UIAxes, 'Signal in Time Domain')
            xlabel(app.UIAxes, 'Time')
            ylabel(app.UIAxes, 'Magnitude')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontName = 'Comic Sans MS';
            app.UIAxes.FontWeight = 'bold';
            app.UIAxes.XGrid = 'on';
            app.UIAxes.XMinorGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.YMinorGrid = 'on';
            app.UIAxes.Position = [28 284 843 264];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.ModifiedSignalTab);
            title(app.UIAxes_2, 'Signal in Frequency Domain')
            xlabel(app.UIAxes_2, 'Frequency')
            ylabel(app.UIAxes_2, 'Magnitude')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.FontName = 'Comic Sans MS';
            app.UIAxes_2.FontWeight = 'bold';
            app.UIAxes_2.XGrid = 'on';
            app.UIAxes_2.XMinorGrid = 'on';
            app.UIAxes_2.YGrid = 'on';
            app.UIAxes_2.YMinorGrid = 'on';
            app.UIAxes_2.Position = [29 16 842 268];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Equalizer_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end