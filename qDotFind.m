%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %
%%%%%	%%%%%					qDotFind.m						%%%%%	%%%%%
%%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%	Quantum dot reaction event analysis software
%%
%%	Copyright (c) August 2015
%%	Regaldisclaimer
%%
%%	Written for Walt Lab, Tufts U
%%
%%	Author Contact: regaldisclaimer@gmail.com
%%
%%	Utilizes:
%%		pkfind.m by Eric R. Dufresne (Yale University)
%%		tiffread2.m by Francois Nedelec (nedelec@embl.de)
%%
%%
%%	Usage:
%%
%%
%%	Features:
%%
%%
%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 0: Options 								%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function void = qdf(bgMethod, qFindMethod, dotSize, contrast, debugMode)

% check to make sure all arguments are passed in for safety.
if(nargin>5)
 fprintf(1, 'WARNING: MISSING ARGUMENT(S). DEFAULT VALUES USED');
end

% bgMethod: Algorithm code for how the background is determined
%
% 0:	default. plots distribution and prompts for background value.

% qFindMethod: Method for finding qDots
%
% 0:	default. uses pkfind.m


% dotSize: expected dotsize. regions larger than this will be considered as clumps,
% 	and will be ignored.
%
%

% debugMode: turn debug comments on or off
% 
% 0:	default. no debug messages
% 1: 	comments will show to help you debug problems





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 1: Setup Monumental Variables 			%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageHeight; %height of the image
imageWidth; %width of the image

firstFrame; %number of frame on which analysis should start

background; %intensity value below which the pixel is considered background
eventThreshold; %intensity value below which qdot is considered to have turned off


%numStack; %number of images on the stack (declared later)










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 2: File Input 							%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Prompt user for file location
%
[fileName, filePath]=uigetfile('*.tif', 'Select the Source tif Image stack');


% Call tiffread2.m
% Input: filePath, fileName
% Output: 1 x numStack struct.
%	each struct: fileName, width, height, bits, resolution_unit, 512x512 data (intensity)
%	each data: 512 x 512 intensity values
%
% 	numStack: number of images on the stack
[tiffReadStack, numStack] = tiffread2([filePath, fileName]);

%set image dimensions
fileWidth = tiffReadStack(1).width;
fileHeight = tiffReadStack(1).height;

if (debugMode == 1)
	fprintf(1, 'Image width is: '+fileWidth);
	fprintf(1, 'Image height is: '+fileHeight);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 3: Format Input Data 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 4: Plot Distribution 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 5: Determine Background 				%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if bgMethod == 0
	%Default method.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 6: Locate Quantum Dots 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 7: Plot Distribution 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 8: Determine Threshold 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 9: Determine Events 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 10: Format Output Data 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 11: Plot Output 						%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

