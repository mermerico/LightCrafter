classdef LcrStageClient < StageClient
    
    methods
        
        % Gets the remote LightCrafter mode.
        function m = getLcrMode(obj)
            obj.sendEvent(LcrNetEvents.GET_LCR_MODE);
            m = obj.getResponse();
        end
        
        % Sets the remote LightCrafter mode. Clears out the last played presentation.
        function setLcrMode(obj, mode)
            obj.sendEvent(LcrNetEvents.SET_LCR_MODE, mode);
            obj.getResponse();
        end
        
        % Sets the remote LightCrafter pattern rate (Hz) and color. Rate must be an allowable pattern rate. Clears out
        % the last played presentation.
        function setLcrPatternAttributes(obj, rate, color)
            obj.sendEvent(LcrNetEvents.SET_LCR_PATTERN_ATTRIBUTES, rate, color);
            obj.getResponse();
        end
        
        % Gets a list of allowable pattern rates (Hz) from the remote LightCrafter.
        function rates = getLcrAllowablePatternRates(obj)
            obj.sendEvent(LcrNetEvents.GET_LCR_ALLOWABLE_PATTERN_RATES);
            rates = obj.getResponse();
        end
        
        % Gets the remote LightCrafter LED currents.
        function [red, green, blue] = getLcrLedCurrents(obj)
            obj.sendEvent(LcrNetEvents.GET_LCR_LED_CURRENTS);
            [red, green, blue] = obj.getResponse();
        end
        
        % Sets the remote LightCrafter LED currents.
        function setLcrLedCurrents(obj, red, green, blue)
            obj.sendEvent(LcrNetEvents.SET_LCR_LED_CURRENTS, red, green, blue);
            obj.getResponse();
        end
        
    end
    
end