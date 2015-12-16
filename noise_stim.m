% NoiseStim generates a noisy stimulus (a la Clandinin 2008) using 
% PsychToolbox and moves it across the screen. The user is free to
% determine the speed of motion and the size of individual dots. (i.e., by
% changing the base size of the box which gets zoomed in to fill the screen

%% Establish global parameters
clear all;

% Set the screen number
screenNumber = 2;

% Determine the ratio by which the noise stim should be enlarged (smaller
% number = smaller dots)
size_factor = 10;

% Set movement speed
speedInc = 2;

% Set sparsity factor: how noisy do you want your stimulus to be?
% Changing this number to be either greatly above or below 0.5 (but between
% 0 and 1) will have equivalent effects, but will change which color (i.e.,
% color1 or color2) will predominate.
sparse_factor = 0.9;

% Set colors
color1 = [0.5 0 0];
color2 = [0.5 0.6 0];
%% Get/set screen parameters

% Set default PTB startup parameters
PsychDefaultSetup(2);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% Open an on-screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, color1);

% Get the size of the on-screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha blending for smooth lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Generate the noisy simulus

% Calculate rectangle size & make the noise texture
base_square = cast(rand(screenYpixels/size_factor,...
    screenXpixels/size_factor*10)>sparse_factor, 'double');

% Move everything into the second layer to achieve transparency
noise_mask = ones(size(base_square));
noise_mask(:,:,2) = base_square;

noise_tex = Screen('MakeTexture', window, noise_mask);

% Make a destination rectangle for our textures and center it on the screen
dstRect = [0 0 screenXpixels*10 screenYpixels];

if speedInc > 0
    dstRect = AlignRect(dstRect, windowRect, 'right', 'top');
else
    dstRect = AlignRect(dstRect, windowRect, 'left', 'top');
end


% We set PTB to wait one frame before re-drawing
waitframes = 1;

% Calculate the wait duration
waitDuration = waitframes * ifi;
%% Put the thing on the screen

% Sync us to the vertical retrace
vbl = Screen('Flip', window);% Loop until a key is pressed

% Loop until a key is pressed
while ~KbCheck
    
    % Increment the grating position
    dstRect(1) = dstRect(1) + speedInc;
    dstRect(3) = dstRect(3) + speedInc;
    
% Draw grating
    Screen('DrawTexture', window, noise_tex, [], dstRect, [],...
        0, [], color2);
    
    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
end

% Clear the screen
sca;
close all;