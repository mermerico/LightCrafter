classdef Lcr4500 < handle
    
    properties (SetAccess = private)
        monitor
    end
    
    properties (Constant)
        NATIVE_RESOLUTION = [912, 1140];
    end
    
    properties (Constant, Access = private)
        LEDS = {'none', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white'} % increasing bit order
        MIN_EXPOSURE_PERIODS = [235, 700, 1570, 1700, 2000, 2500, 4500, 8333] % increasing bit depth order, us
        NUM_BIT_PLANES = 24
        MIN_PATTERN_BIT_DEPTH = 1
        MAX_PATTERN_BIT_DEPTH = 8
    end
    
    methods
        
        function obj = Lcr4500(monitor)
            obj.monitor = monitor;
        end
        
        function delete(obj)
            obj.close();
        end
        
        function connect(obj) %#ok<MANU>
            nRetry = 5;
            for i = 1:nRetry
                try
                    lcrOpen();
                    break;
                catch x
                    lcrClose();
                    if i == nRetry
                        rethrow(x);
                    end
                end
            end
        end
        
        function close(obj) %#ok<MANU>
            lcrClose();
        end
        
        function m = getMode(obj) %#ok<MANU>
            m = LcrMode(lcrGetMode());
        end
        
        function setMode(obj, mode) %#ok<INUSL>
            lcrSetMode(logical(mode));
        end
        
        function setImageOrientation(obj, flipNorthSouth, flipEastWest) %#ok<INUSL>
            lcrSetShortAxisImageFlip(flipNorthSouth);
            lcrSetLongAxisImageFlip(flipEastWest);
        end
        
        % Allowable pattern rates (Hz) in increasing bit depth order.
        function rates = allowablePatternRates(obj)
            rates = nan(1, obj.MAX_PATTERN_BIT_DEPTH);
            
            for bitDepth = obj.MIN_PATTERN_BIT_DEPTH:obj.MAX_PATTERN_BIT_DEPTH
                theoretical = obj.monitor.refreshRate * floor(obj.NUM_BIT_PLANES / bitDepth);
                maximum = round(1 / (obj.MIN_EXPOSURE_PERIODS(bitDepth) * 1e-6));

                rates(bitDepth) = min(theoretical, maximum);
            end
        end
        
        function setPatternAttributes(obj, bitDepth, color)
            if obj.getMode() ~= LcrMode.PATTERN
                error('Must be in pattern mode to set pattern attributes');
            end
            
            if bitDepth < obj.MIN_PATTERN_BIT_DEPTH || bitDepth > obj.MAX_PATTERN_BIT_DEPTH
                error(['Bit depth must be between ' num2str(obj.MIN_PATTERN_BIT_DEPTH) ' and ' num2str(obj.MAX_PATTERN_BIT_DEPTH)]);
            end
            
            % Color to LED selection.
            index = cellfun(@(c)strncmpi(c, color, length(color)), obj.LEDS);
            if ~any(index)
                error('Unknown color');
            end
            ledSelect = find(index, 1, 'first') - 1;
            
            % Stop the current pattern sequence.
            lcrPatternDisplay(0);
            
            % Clear locally stored pattern LUT.
            lcrClearPatLut();           
            
            % Create new pattern LUT.
            nPatterns = floor(min(obj.NUM_BIT_PLANES / bitDepth, 1/obj.monitor.refreshRate/(obj.MIN_EXPOSURE_PERIODS(bitDepth) * 1e-6)));
            for i = 1:nPatterns
                if i == 1
                    trigType = 1; % external positive
                    bufSwap = true;
                else
                    trigType = 3; % no trigger
                    bufSwap = false;
                end
                
                patNum = i - 1;
                invertPat = false;
                insertBlack = false;
                trigOutPrev = false;
                
                lcrAddToPatLut(trigType, patNum, bitDepth, ledSelect, invertPat, insertBlack, bufSwap, trigOutPrev);
            end
            
            % Set pattern display data to stream through 24-bit RGB external interface.
            lcrSetPatternDisplayMode(true);
            
            % Set the sequence to repeat.
            lcrSetPatternConfig(nPatterns, true, nPatterns, 0);
            
            % Calculate and set the necessary pattern exposure period.
            vsyncPeriod = 1 / obj.monitor.refreshRate * 1e6; % us
            exposurePeriod = vsyncPeriod / nPatterns;
            lcrSetExposureFramePeriod(exposurePeriod, exposurePeriod);
            
            % Set the pattern sequence to trigger on vsync.
            lcrSetPatternTriggerMode(false);
            
            % Send pattern LUT to device.
            lcrSendPatLut();
            
            % Validate the pattern LUT.
            status = lcrValidatePatLutData();
            if status == 1 || status == 3
                error('Error validating pattern sequence');
            end
            
            % Start the pattern sequence.
            lcrPatternDisplay(2);
        end
        
        function [bitDepth, color] = getPatternAttributes(obj)
            % Check all patterns for a consistent bit depth and color.
            [~, ~, bitDepth, ledSelect] = lcrGetPatLutItem(0);
            nPatterns = obj.getNumPatterns();
            for i = 2:nPatterns
                [~, ~, d, l] = lcrGetPatLutItem(i - 1);
                
                if d ~= bitDepth
                    error('Nonhomogeneous bit depth');
                end
                
                if l ~= ledSelect
                    error('Nonhomogenenous color');
                end
            end
            
            % LED selection to color.
            color = obj.LEDS{ledSelect + 1};
        end
        
        function n = getNumPatterns(obj) %#ok<MANU>
            n = lcrGetPatternConfig();
        end
        
    end
    
end 