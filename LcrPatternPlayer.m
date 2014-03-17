% A player that draws each frame as a sequence of patterns by coordinating with an LcrPatternRenderer.

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
            nPatterns = obj.patternRenderer.numPatterns;            
            patternDuration = frameDuration / nPatterns;
            
            for pattern = 0:nPatterns-1
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