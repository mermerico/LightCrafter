classdef LcrNetEvents
    
    properties (Constant)
        %% Client to server:
        % Requests the current LightCrafter mode.
        GET_LCR_MODE = 'GET_LCR_MODE'
        
        % Requests a new LightCrafter mode.
        SET_LCR_MODE = 'SET_LCR_MODE'
        
        % Requests a new LightCrafter pattern rate and color.
        SET_LCR_PATTERN_ATTRIBUTES = 'SET_LCR_PATTERN_ATTRIBUTES'
        
        % Requests the currently allowable LightCrafter pattern rates.
        GET_LCR_ALLOWABLE_PATTERN_RATES = 'GET_LCR_ALLOWABLE_PATTERN_RATES'
    end
    
end