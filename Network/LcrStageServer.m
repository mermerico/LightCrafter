classdef LcrStageServer < StageServer
    
    properties (Access = private)
        lightCrafter
    end
    
    methods
        
        function obj = LcrStageServer(port)
            if nargin < 1
                port = 5678;
            end
            
            obj = obj@StageServer(port);
        end
        
    end
    
    methods (Access = protected)
        
        function prepareToStart(obj, varargin)
            prepareToStart@StageServer(obj, varargin{:});
            
            obj.lightCrafter = Lcr4500(obj.canvas.window.monitor);
            obj.lightCrafter.connect();
            obj.lightCrafter.setMode(LcrMode.VIDEO);
        end
        
        function onEventReceived(obj, src, data)
            client = data.client;
            value = data.value;
            
            try
                switch value{1}
                    case LcrNetEvents.GET_LCR_MODE
                        obj.onEventGetLcrMode(client, value);
                    case LcrNetEvents.SET_LCR_MODE
                        obj.onEventSetLcrMode(client, value);
                    case LcrNetEvents.SET_LCR_PATTERN_ATTRIBUTES
                        obj.onEventSetLcrPatternAttributes(client, value);
                    case LcrNetEvents.GET_LCR_ALLOWABLE_PATTERN_RATES
                        obj.onEventGetLcrAllowablePatternRates(client, value);
                    case LcrNetEvents.PLAY_LCR_PATTERN_PRESENTATION
                        obj.onEventPlayLcrPatternPresentation(client, value);
                    otherwise
                        onEventReceived@StageServer(obj, src, data);
                end
            catch x
                client.send(NetEvents.ERROR, x);
            end
        end
        
        function onEventGetLcrMode(obj, client, value) %#ok<INUSD>
            mode = obj.lightCrafter.getMode();
            client.send(NetEvents.OK, mode);
        end
        
        function onEventSetLcrMode(obj, client, value)
            mode = value{2};
            
            obj.lightCrafter.setMode(mode);
            client.send(NetEvents.OK);
        end
        
        function onEventSetLcrPatternAttributes(obj, client, value)
            patternRate = value{2};
            color = value{3};

            % Pattern rate to bit depth.
            bitDepth = find(obj.lightCrafter.allowablePatternRates() == patternRate, 1);
            if isempty(bitDepth)
                error('Specified pattern rate is not an allowable pattern rate');
            end

            obj.lightCrafter.setPatternAttributes(bitDepth, color);
            client.send(NetEvents.OK);
        end
        
        function onEventGetLcrAllowablePatternRates(obj, client, value) %#ok<INUSD>
            rates = obj.lightCrafter.allowablePatternRates();
            client.send(NetEvents.OK, rates);
        end
        
        function onEventPlayLcrPatternPresentation(obj, client, value)
            presentation = value{2};
            
            renderer = LcrPatternRenderer();
            renderer.numPatterns = obj.lightCrafter.getNumPatterns();
            renderer.patternBitDepth = obj.lightCrafter.getPatternAttributes();
            obj.canvas.setRenderer(renderer);
            resetRenderer = onCleanup(@()obj.canvas.resetRenderer());
            
            presentation.numPatterns = renderer.numPatterns;
            patternDrawn = addlistener(presentation, 'drewPattern', @()renderer.incrementPatternIndex()); %#ok<NASGU>
            
            % Unlock client to allow async operations during play.
            client.send(NetEvents.OK);
            
            try
                obj.sessionData.playInfo = presentation.play(obj.canvas);
            catch x
                obj.sessionData.playInfo = x;
            end
        end
        
    end
    
end