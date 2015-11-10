%% Clear everything and establish defaults

close all;
clear all;
sca;

PsychDefaultSetup(2);

% set the screen number
screenNumber = 1;

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;
inc = white-grey;

%% Get/set screen parameters

% Open an on-screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0.4 0 0]);

% Get the size of the on-screen window (OSW)
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Set up the stripes

% Define your stripe width (in pix)
stripeWidth = 100;

% Compute stripe num based on screen width
numStripes = screenXpixels / stripeWidth;

% Define single unit of stripes (i.e. define their colors & reshape
% accordingly)
stripeUnit = [0.4 0 0; 0.4 0.6 0]; %each row is a color
stripeUnit = reshape(stripeUnit, 1, 2, 3); %reshape into a 1x2x3 matrix (so colors are read as RGB)

% Define a simple 1 x numStripes set of stripes
baseStripes = repmat(stripeUnit, 1, numStripes);

% Make the stripes into a texture (1 x n pixels)
stripeTex = Screen('MakeTexture', window, baseStripes);

% We will scale our texture up to size to make it fill the screen
dstRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);

%% Set up movement parameters

% Grating frequency in cycles/pixel
freqCyclesPerPix = 0.01;

% Drift speed cycles per second
cyclesPerSecond = 1 ; % 4 Hz recommended by M. Reiser

% We set PTB to wait one frame before re-drawing
waitframes = 1;

% Calculate the wait duration
waitDuration = waitframes * ifi;

% Compute pixPerCycle
pixPerCycle = 1 / freqCyclesPerPix;

% Translate requested speed of the grating (in cycles per second) into a
% shift value in "pixels per frame"
shiftPerFrame = cyclesPerSecond * pixPerCycle * waitDuration;

%% Draw everything to the screen

% Change filter mode to 0 for nearest neightbor filtering.
filterMode = 0;

% Sync us to the vertical retrace
vbl = Screen('Flip', window);

% Set the frame counter to zero, we need this to 'drift' our grating
frameCounter = 0;

% Loop until a key is pressed
while ~KbCheck
    
    % Calculate the x offset for our window through which to sample our
    % grating
    xoffset = mod(frameCounter * shiftPerFrame, pixPerCycle);
    
    % Now increment the frame counter fo the next loop
    frameCounter = frameCounter + 1;
    
    % Update the source rectangle for this loop
    %srcRect = [xoffset 0 xoffset + screenXpixels screenYpixels];
    
    % Draw stripes to the screen
    Screen('DrawTexture', window, stripeTex, [] , dstRect, 0, filterMode);
        
    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
end

% Clear the screen
sca;