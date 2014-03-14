classdef LcrPatternPlayer < PrerenderedPlayer
    
    properties (Access = private)
        patternRenderer
    end
    
    methods
        
        function obj = LcrPatternPlayer(presentation)
            obj = obj@PrerenderedPlayer(presentation);
        end
        
        function bindPatternRenderer(obj, renderer)
            obj.patternRenderer = renderer;
        end
        
    end
    
    methods (Access = protected)
        
        function drawFrame(obj, frame, frameDuration, time)
            numPatterns = obj.patternRenderer.numPatterns;            
            patternDuration = frameDuration / numPatterns;
            
            for pattern = 0:numPatterns-1
                state.frame = frame;
                state.frameDuration = frameDuration;
                state.time = patternDuration * pattern + time;
                state.pattern = pattern;
                state.patternDuration = patternDuration;
                
                obj.callControllers(state);
                
                obj.drawStimuli();
                
                obj.patternRenderer.incrementPatternIndex();
            end
        end
        
    end
    
end