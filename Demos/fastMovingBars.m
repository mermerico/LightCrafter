function fastMovingBars(monitorNumber)
    if nargin < 1
        monitorNumber = 2;
    end
    
    patternBitDepth = 8;
    patternColor = 'blue';
    
    % Setup the LightCrafter.
    lightCrafter = Lcr4500(LcrMonitor(monitorNumber));
    lightCrafter.connect();
    lightCrafter.setMode(LcrMode.PATTERN);
    lightCrafter.setPatternAttributes(patternBitDepth, patternColor);
    
    % Open a window on the LightCrafter.
    window = Window(Lcr4500.NATIVE_RESOLUTION, true, lightCrafter.monitor);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Stretch the projection matrix to account for the LightCrafter diamond pixel screen.
    width = window.size(1) * 2;
    height = window.size(2);
    canvas.projection.setIdentity();
    canvas.projection.orthographic(0, width, 0, height);
    
    % Create 2 bar stimuli.
    bar1 = Rectangle();
    bar1.size = [100, height];
    bar1.color = 0.5;
    
    bar2 = Rectangle();
    bar2.size = [100, height];
    bar2.color = 0.5;
    
    % Create a 3 second presentation.
    presentation = Presentation(3);
    
    % Add the bars to the presentation.
    presentation.addStimulus(bar1);
    presentation.addStimulus(bar2);
    
    % Define the bar positions as a function of time.
    presentation.addController(bar1, 'position', @(state)[sin(state.time*5)*width/2+width/2, height/2]);
    presentation.addController(bar2, 'position', @(state)[-sin(state.time*5)*width/2+width/2, height/2]);
    
    % Create a pattern renderer for the canvas.
    renderer = LcrPatternRenderer(lightCrafter.getNumPatterns(), patternBitDepth);
    canvas.setRenderer(renderer);
    
    % Create a pattern player.
    player = LcrPatternPlayer(presentation);
    player.bindPatternRenderer(renderer);
    
    % Enable additive blending to allow rendering multiple patterns into a single frame.
    canvas.enableBlend(GL.SRC_ALPHA, GL.ONE);
    
    % Play the presentation on the canvas!
    player.play(canvas);
    
    % After playing the presentation once, it may be "replayed" to skip prerendering.
    player.replay(canvas);
    
    % Window automatically closes when the window object is deleted.
end