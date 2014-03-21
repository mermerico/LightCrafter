% A player that draws each frame as a sequence of patterns by coordinating with an LcrPatternRenderer.

classdef LcrPatternPlayer < PrerenderedPlayer
    
    properties (Access = private)
        patternRenderer
        vao
        texture
        framebuffer
        renderer
    end
    
    methods
        
        function obj = LcrPatternPlayer(presentation)
            obj = obj@PrerenderedPlayer(presentation);
        end
        
        function bindPatternRenderer(obj, renderer)
            obj.patternRenderer = renderer;
        end
        
        function prerender(obj, canvas)
            % Each vertex position is followed by a texture coordinate and a mask coordinate.
            w = canvas.size(1);
            h = canvas.size(2);
            vertexData = [ 0  h  0  1,  0  1,  0  1 ...
                           0  0  0  1,  0  0,  0  0 ...
                           w  h  0  1,  1  1,  1  1 ...
                           w  0  0  1,  1  0,  1  0];

            vbo = VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);

            obj.vao = VertexArrayObject(canvas);
            obj.vao.setAttribute(vbo, 0, 4, GL.FLOAT, GL.FALSE, 8*4, 0);
            obj.vao.setAttribute(vbo, 1, 2, GL.FLOAT, GL.FALSE, 8*4, 4*4);
            obj.vao.setAttribute(vbo, 2, 2, GL.FLOAT, GL.FALSE, 8*4, 6*4);

            obj.texture = TextureObject(canvas, 2);
            obj.texture.setImage(zeros(h, w, 4, 'uint8'));
            
            obj.framebuffer = FramebufferObject(canvas);
            obj.framebuffer.attachColor(0, obj.texture);
            
            obj.renderer = Renderer(canvas);
            obj.renderer.projection.orthographic(0, canvas.size(1), 0, canvas.size(2));
            
            prerender@PrerenderedPlayer(obj, canvas);
        end
        
    end
    
    methods (Access = protected)
        
        function drawFrame(obj, canvas, frame, frameDuration, time)
            nPatterns = obj.patternRenderer.numPatterns;            
            patternDuration = frameDuration / nPatterns;
            
            for pattern = 0:nPatterns-1
                state.frame = frame;
                state.frameDuration = frameDuration;
                state.time = patternDuration * pattern + time;
                state.pattern = pattern;
                state.patternDuration = patternDuration;
                
                obj.callControllers(state);
                
                canvas.setFramebuffer(obj.framebuffer);
                canvas.clear();
                obj.drawStimuli(canvas);
                canvas.resetFramebuffer();
                
                canvas.enableBlend(GL.SRC_ALPHA, GL.ONE);
                obj.renderer.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, [1, 1, 1, 1], [], obj.texture, []);
                canvas.resetBlend();
                
                obj.patternRenderer.incrementPatternIndex();
            end
        end
        
    end
    
end