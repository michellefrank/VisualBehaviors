%% =====Clear everything and establish defaults=====

close all;
clear all;
sca;

PsychDefaultSetup(2);

% set the screen number
screenNumber = 2;

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;
inc = white-grey;

% Pick the color for your background and stripes
defBg = [0.4 0 0];
defStripe = [0.4 0.6 0];

%% =====Get/set screen parameters=====

% Open an on-screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, defBg);

% Get the size of the on-screen window (OSW)
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% =====Set up the stripes=====

% Define your stripe width (in pix)
stripeWidth = 120;

% Compute stripe num based on screen width
numStripes = screenXpixels / stripeWidth;

% Generate the initial mask (just like our basic stripe thing from earlier,
% this only needs to be two pixels). We'll be making our stripes in the
% third dimension (the alpha layer); basically this lets us make a set of
% transparent gratings through which the background of the screen is
% visible (making it look like a set of moving stripes)
stripeUnit = [1 1];
stripeUnit(:,:,2) = [1 0];

% Multiply the stripes to get the right number
baseStripes = repmat(stripeUnit, 1, numStripes);

% Make this thing a texture
stripeTex = Screen('MakeTexture', window, baseStripes);

% We will scale our texture up to size to make it fill the screen
dstRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRect(dstRect, windowRect);

%% =====Set up movement parameters=====

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

% Change filter mode for nearest neightbor filtering so we can get sharp edges
filterMode = 0;

% Sync us to the vertical retrace
vbl = Screen('Flip', window);

% Initialize the frame counter to zero
frameCounter = 0;

% Loop until a key is pressed
while ~KbCheck
    
    % Calculate the x offset for our grating
    xoffset = mod(frameCounter * shiftPerFrame, pixPerCycle);
    
    % Now increment the frame counter fo the next loop
    frameCounter = frameCounter + 1;
    
    % Update the source rectangle for this loop
    dstRect = [xoffset 0 xoffset + screenXpixels screenYpixels];
    
    % Draw our transparent grating
    Screen('DrawTextures', window, stripeTex, [], dstRect, [],...
        filterMode, [], defStripe);

    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
end

% Clear the screen
sca;