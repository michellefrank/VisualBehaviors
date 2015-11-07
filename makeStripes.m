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

% Make our rectangle coordinates
allRects = nan(4, numRecs);
for i = 1:numRecs
    allRects(:, i) = CenterRectOnPointd(baseRect, stripeXpos(i), yCenter);
end

% Draw rects to screen
Screen('FillRect', window, allColors, allRects);

% Flip to the screen
Screen('Flip', window);

% Wait for a key press
KbStrokeWait;

% Clear the screen
sca;