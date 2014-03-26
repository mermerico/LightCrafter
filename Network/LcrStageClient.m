classdef LcrStageClient < StageClient
    
    methods
        
        % Sets the remote LightCrafter bit depth, color, and optionally number of patterns.
        function setLcrPatternAttributes(obj, bitDepth, color, numPatterns)
            if nargin < 4
                numPatterns = [];
            end
            
            obj.sendEvent(LcrNetEvents.SET_LCR_PATTERN_ATTRIBUTES, bitDepth, color, numPatterns);
            obj.getResponse();
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