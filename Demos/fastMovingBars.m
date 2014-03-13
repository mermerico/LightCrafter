function fastMovingBars(lcrMonitorNumber)
    if nargin < 1
        lcrMonitorNumber = 2;
    end
    
    patternBitDepth = 8;
    patternColor = 'blue';
    
    % Setup the LightCrafter.
    lightCrafter = Lcr4500(LcrMonitor(lcrMonitorNumber));
    lightCrafter.connect();
    lightCrafter.setMode(LcrMode.PATTERN);
    lightCrafter.setPatternAttributes(patternBitDepth, patternColor);
    
    % Open a window on the LightCrafter.
    window = Window(lightCrafter.NATIVE_RESOLUTION, true, lightCrafter.monitor);
    
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
    
    % Create a 4 second pattern presentation.
    presentation = LcrPatternPresentation(4);
    
    % Add the bar to the presentation.
    presentation.addStimulus(bar1);
    presentation.addStimulus(bar2);
    
    % Define the bar positions as a function of time.
    presentation.addController(bar1, 'position', @(state)[sin(state.time*5)*width/2+width/2, height/2]);
    presentation.addController(bar2, 'position', @(state)[-sin(state.time*5)*width/2+width/2, height/2]);
    
    % Create a pattern renderer for the canvas.
    renderer = LcrPatternRenderer(lightCrafter.getNumPatterns(), patternBitDepth);
    canvas.setRenderer(renderer);
    
    % Bind the pattern renderer to the pattern presentation.
    presentation.bindPatternRenderer(renderer);
    
    % Enable additive blending to allow rendering multiple patterns into a single frame.
    canvas.enableBlend(GL.SRC_ALPHA, GL.ONE);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end