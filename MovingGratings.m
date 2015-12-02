% Uses Matlab''s Psychtoolbox package to create a moving grating stimulus. 
% Largely adapted from ContrastModulatedGrating demo from PsychToolbox3 
% (psychtoolbox.org). Written by MMF Nov. 2015.


%% Clear everything and establish default PTB parameters
close all;
clear all;
sca;

PsychDefaultSetup(2);

%% Establish experimental parameters
% This section is where we establish experimental parameters for color and
% movement.

% set the screen number
screenNumber = 1;

% Set screen background color
bgColor = [0.4 0 0];

% Set grating color
gratingColor = [0.4 0.6 0];

% Grating frequency in cycles/pixel (sets spatial frequency; 
% basically in units of degrees/360)
freqCyclesPerPix = 30/360; %0.01;

% Speed in cycles per second (sets temporal frequency)
cyclesPerSecond = 2;

%% Get/set screen parameters

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% Open an on-screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgColor);

% Get the size of the on-screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha blending for smooth lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Calculate grating parameters

% Grating size in pixels (we want it to take up the whole screen)
gratingSizePix = screenXpixels;

% Define half size of the grating image
texsize = gratingSizePix / 2;

% First we compute pixels per cycle rounded to the nearest pixel
pixPerCycle = ceil(1 / freqCyclesPerPix);

% Frequency in radians
freqRad = freqCyclesPerPix * 2 * pi;

% This is the visible size of the grating
visibleSize = gratingSizePix + 1;

% Define our grating. We make it in a super convoluted way
% because this method is functional. Wee.
x = meshgrid(-texsize:texsize + pixPerCycle, 1);
grating = round(grey * cos(freqRad*x) + grey);

% Make a two-layer mask (initialized to all ones)
mask = ones(1, numel(x), 2);

% Place the grating in the 'alpha' channel of the mask (i.e. the third
% dimension). This will make the grating into a transparency.
mask(:, :, 2) = grating;

% Make our grating a texture
gratingTex = Screen('MakeTexture', window, mask);

% Make a destination rectangle for our textures and center it on the screen
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

% Initialize the frame counter to zero
frameCounter = 0;

% Loop until a key is pressed
while ~KbCheck
    
    % Calculate the x offset for our grating
    xoffset = mod(frameCounter * shiftPerFrame, pixPerCycle);
    
    % Increment the frame counter
    frameCounter = frameCounter + 1;
    
    % Re-define the source rectangle with the x-offset
    srcRect = [xoffset 0 xoffset + visibleSize visibleSize];
    
    % Draw grating
    Screen('DrawTexture', window, gratingTex, srcRect, dstRect, [],...
        0, [], gratingColor);
    
    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
end

% Clear the screen
sca;
close all;