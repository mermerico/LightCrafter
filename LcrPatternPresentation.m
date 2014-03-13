classdef LcrPatternPresentation < Presentation
    
    properties (Access = private)
        patternRenderer
    end
    
    methods
        
        function obj = LcrPatternPresentation(duration)
            obj = obj@Presentation(duration);
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
                
                % Call controllers.
                for i = 1:length(obj.controllers)
                    c = obj.controllers{i};
                    handle = c{1};
                    prop = c{2};
                    func = c{3};

                    handle.(prop) = func(state);
                end

                % Draw stimuli.
                for i = 1:length(obj.stimuli)
                    obj.stimuli{i}.draw();
                end
                
                obj.patternRenderer.incrementPatternIndex();
            end
        end
        
    end
    
end