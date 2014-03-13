classdef LcrStageClient < StageClient
    
    methods
        
        % Gets the remote LightCrafter mode.
        function m = getLcrMode(obj)
            obj.sendEvent(LcrNetEvents.GET_LCR_MODE);
            m = obj.getResponse();
        end
        
        % Sets the remote LightCrafter mode.
        function setLcrMode(obj, mode)
            obj.sendEvent(LcrNetEvents.SET_LCR_MODE, mode);
            obj.getResponse();
        end
        
        % Sets the remote LightCrafter pattern rate (Hz) and color. Rate must be an allowable pattern rate.
        function setLcrPatternAttributes(obj, rate, color)
            obj.sendEvent(LcrNetEvents.SET_LCR_PATTERN_ATTRIBUTES, color, rate);
            obj.getResponse();
        end
        
        % Gets a list of allowable pattern rates (Hz) from the remote LightCrafter.
        function rates = getLcrAllowablePatternRates(obj)
            obj.sendEvent(LcrNetEvents.GET_LCR_ALLOWABLE_PATTERN_RATES);
            rates = obj.getResponse();
        end
        
        % Plays a given pattern presentation on the remote canvas. This method will return immediately. While the 
        % presentation plays remotely, further attempts to interface with the server will block until the presentation 
        % completes.
        function playLcrPatternPresentation(obj, presentation)
            obj.sendEvent(LcrNetEvents.PLAY_LCR_PATTERN_PRESENTATION, presentation);
            obj.getResponse();
        end
        
    end
    
end