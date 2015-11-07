%% Set default parameters and get screen info 

% Clear the workspace
close all;
clear all;
sca;

% Establish default settings
PsychDefaultSetup(2);

% Set screen number
screenNumber = 1;

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Define your stripe width (in pixels)
stripeWidth = 100;

% Open a window on-screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0.4 0 0]);

% Get the size of the screen
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the center coordinates
[xCenter, yCenter] = RectCenter(windowRect);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

%% Start setting parameters for the strips 

% Compute the number of rectangles to draw
numRecs = screenXpixels / stripeWidth / 2;

% Make a base Rect w/ size stripeWidth by the height of the screen
baseRect = [0 0 stripeWidth screenYpixels];

% Define screen x positions for our squares
stripeXpos = NaN(1, numRecs);
for i = 1:numRecs
    stripeXpos(i) = (i-1)*2*stripeWidth + stripeWidth/2;
end
%squareXpos = [screenXpixels * 0.25 screenXpixels * 0.5 screenXpixels * 0.75];
%numSquares = length(squareXpos);

% Set the colors for the rectangles
% NOTE: colors are specified by COLUMN
rectColor = [0.4; 0.7; 0];
allColors = repmat(rectColor, 1, numRecs);
%allColors = [0.4 0.4 0.4; 0.7 0.7 0.7; 0 0 0];

% We're going to move these gratings sinusoidally; set parameters
amplitude = screenXpixels * 0.25;
frequency = 0.2;
angFreq = 2 * pi * frequency;
startPhase = 0;
time = 0;

% Sync and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

%% Draw stuff to screen

% Loop the animation until a key is pressed
while ~KbCheck
    
    % Position of the stripes on this frame
    xpos = amplitude * sin(angFreq * time + startPhase);
    
    % Add this position to the screen center coordinate. This is the point
    % we want our squares to oscillate around
    stripeXpos = stripeXpos + xpos;

    % Make our rectangle coordinates
    allRects = nan(4, numRecs);
    for i = 1:numRecs
        allRects(:, i) = CenterRectOnPointd(baseRect, stripeXpos(i), yCenter);
    end
    
    % Draw rects to screen
    Screen('FillRect', window, allColors, allRects);

    % Flip to the screen
    Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    % Increment time
    time = time + ifi;
    
end

% Clear the screen
sca;