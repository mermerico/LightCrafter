classdef LcrStageServer < StageServer
    
    properties (Access = private)
        lightCrafter
    end
    
    methods (Static)
        
        function server = createAndStart(monitorNumber, port)
            if nargin < 1
                monitorNumber = 2;
            end
            
            if nargin < 2
                port = 5678;
            end
                        
            server = LcrStageServer(port);
            server.start(Lcr4500.NATIVE_RESOLUTION, true, LcrMonitor(monitorNumber));
        end
        
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
            
            monitor = obj.canvas.window.monitor;
            
            obj.lightCrafter = Lcr4500(monitor);
            obj.lightCrafter.connect();
            obj.lightCrafter.setMode(LcrMode.VIDEO);
            
            % Set LEDs to enable automatically.
            obj.lightCrafter.setLedEnables(true, true, true, true);
            
            if monitor.resolution == Lcr4500.NATIVE_RESOLUTION
                % Stretch the projection matrix to account for the LightCrafter diamond pixel screen.
                window = obj.canvas.window;
                obj.canvas.projection.setIdentity();
                obj.canvas.projection.orthographic(0, window.size(1)*2, 0, window.size(2));
            end
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
            
            if obj.lightCrafter.getMode() ~= mode
                obj.sessionData.player = [];
            end
            
            obj.lightCrafter.setMode(mode);
            client.send(NetEvents.OK);
        end
        
        function onEventSetLcrPatternAttributes(obj, client, value)
            rate = value{2};
            color = value{3};

            % Pattern rate to bit depth.
            bitDepth = find(obj.lightCrafter.allowablePatternRates() == rate, 1);
            if isempty(bitDepth)
                error('Specified pattern rate is not an allowable pattern rate');
            end
            
            if obj.lightCrafter.getPatternAttributes() ~= bitDepth
                obj.sessionData.player = [];
            end
            
            obj.lightCrafter.setPatternAttributes(bitDepth, color);
            client.send(NetEvents.OK);
        end
        
        function onEventGetLcrAllowablePatternRates(obj, client, value) %#ok<INUSD>
            rates = obj.lightCrafter.allowablePatternRates();
            client.send(NetEvents.OK, rates);
        end
        
        function onEventGetCanvasSize(obj, client, value) %#ok<INUSD>
            size = obj.canvas.size;
            if obj.canvas.window.monitor.resolution == Lcr4500.NATIVE_RESOLUTION
                % Stretch for diamond pixel layout.
                size(1) = size(1) * 2;
            end
            
            client.send(NetEvents.OK, size);
        end
        
        function onEventPlay(obj, client, value)
            if obj.lightCrafter.getMode() == LcrMode.VIDEO
                onEventPlay@StageServer(obj, client, value);
                return;
            end
            
            presentation = value{2};
            
            nPatterns = obj.lightCrafter.getNumPatterns();
            bitDepth = obj.lightCrafter.getPatternAttributes();
            renderer = LcrPatternRenderer(nPatterns, bitDepth);
            
            obj.canvas.setRenderer(renderer);
            resetRenderer = onCleanup(@()obj.canvas.resetRenderer());
            
            obj.sessionData.player = LcrPatternPlayer(presentation);
            obj.sessionData.player.bindPatternRenderer(renderer);
            
            % Unlock client to allow async operations during play.
            client.send(NetEvents.OK);
            
            try
                obj.sessionData.playInfo = obj.sessionData.player.play(obj.canvas);
            catch x
                obj.sessionData.playInfo = x;
            end
        end
        
        function onEventReplay(obj, client, value)
            if obj.lightCrafter.getMode() == LcrMode.VIDEO
                onEventReplay@StageServer(obj, client, value);
                return;
            end
            
            if isempty(obj.sessionData.player)
                error('No player exists');
            end
            
            % Unlock client to allow async operations during play.
            client.send(NetEvents.OK);
            
            try
                obj.sessionData.playInfo = obj.sessionData.player.replay(obj.canvas);
            catch x
                obj.sessionData.playInfo = x;
            end
        end
        
    end
    
end