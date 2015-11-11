%% Clear everything and establish defaults

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

% Set default screen color
defRed = [0.4 0 0];

% Set default bar color
defGreen = [0.4 0 0.6];%[0.4 0.6 0];
%% Get screen parameters

% Open an on-screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, defRed);

% Get the size of the on-screen window (OSW)
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha blending for smooth lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Set up grating parameters

% Grating size in pixels
gratingSizePix = screenXpixels; %600;

% Grating frequency incycles/pixel
freqCyclesPerPix = 0.01;

% Drift speed cycles per second
cyclesPerSecond = 1;

% Define half size of the grating image
texsize = gratingSizePix / 2;

% First we compute pixels per cycle rounded to the nearest pixel
pixPerCycle = ceil(1 / freqCyclesPerPix);

% Frequency in radians
freqRad = freqCyclesPerPix * 2 * pi;

% This is the visible size of the grating
visibleSize = gratingSizePix + 1; %2 * texsize + 1;

% Define our grating; note it is only 1 pixel high. PTB will make it a full
% grating upon drawing. We make the grating in a super convoluted way
% because doing it this way is functional. Wee.
x = meshgrid(-texsize:texsize + pixPerCycle, 1);
grating = round(grey * cos(freqRad*x) + grey);

% Make a two-layer mask filled with the background color
mask = ones(1, numel(x), 2);

% Define color mod (to make things the right shade)
colorMod = [0.4 0.6 0];

% Place the grating in the 'alpha' channel of the mask
mask(:, :, 2) = grating;

% Make our grating mask a texture
gratingMaskTex = Screen('MakeTexture', window, mask);

% Make a destination rectangle for our textures and center this on the
% screen
dstRect = [0 0 visibleSize visibleSize];
dstRect = CenterRect(dstRect, windowRect);

% We set PTB to wait one frame before re-drawing
waitframes = 1;

% Calculate the wait duration
waitDuration = waitframes * ifi;

% Compute pixPerCycle, this time without the ceil() operation from above
% (otherwise we will get wrong drift speed due to rounding errors)
pixPerCycle = 1 / freqCyclesPerPix;

% Translate requested speed of the grating (in cycles per second) into a
% shift value in "pixels per frame"
shiftPerFrame = cyclesPerSecond * pixPerCycle * waitDuration;

%% Draw stuff! 

% Sync us to the vertical retrace
vbl = Screen('Flip', window);

% Set the frame counter to zero, we need this to 'drift' our grating
frameCounter = 0;

% Loop until a key is pressed
while ~KbCheck
    
    % Calculate the x offset for our window through which to sample our
    % grating
    xoffset = mod(frameCounter * shiftPerFrame, pixPerCycle);
    
    % Now imcrement the frame counter fo the next loop
    frameCounter = frameCounter + 1;
    
    % Define our source rectangle for grating sampling
    srcRect = [xoffset 0 xoffset + visibleSize visibleSize];
    
    % Draw grating mask
    Screen('DrawTexture', window, gratingMaskTex, srcRect, dstRect, [],...
        0, [], colorMod);
    
    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
end

% Clear the screen
sca;
close all;