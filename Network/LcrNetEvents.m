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
        
        % Requests LightCrafter LED current settings.
        GET_LCR_LED_CURRENTS = 'GET_LCR_LED_CURRENTS'
        
        % Requests new LightCrafter LED current settings.
        SET_LCR_LED_CURRENTS = 'SET_LCR_LED_CURRENTS'
    end
    
end