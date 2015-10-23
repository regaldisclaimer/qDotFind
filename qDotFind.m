%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %
%%%%%	%%%%%					qDotFind.m						%%%%%	%%%%%
%%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%	Quantum dot reaction event analysis software
%%
%%
%%  August 2015
%%	Copyright (c)
%%	Regaldisclaimer
%%	Author Contact: regaldisclaimer@gmail.com
%%
%%	Written for Walt Lab, Tufts U
%%
%%
%%	THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES 
%%	WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF 
%%	MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR 
%%	ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES 
%%	WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN 
%%	ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF 
%%	OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
%%
%%
%%	Utilizes:
%%		pkfnd.m by Eric R. Dufresne (Yale University)
%%		tiffread2.m by Francois Nedelec (nedelec@embl.de)
%%
%%
%%	Usage:
%%		reference the github page (github.com/regaldisclaimer/qDotFind)
%%		for more information on using this software
%%
%%
%%
%%
%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 0: Options 								%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function void = qDotFind(bgMethod, qFindMethod, dotSize, clump, debugMode)

% check to make sure all arguments are passed in for safety.
if(nargin>5)
	error('WARNING: MISSING ARGUMENT(S). PROGRAM EXITING');
end

% bgMethod: Algorithm code for how the background is determined
%
% 0:	dafault: median + 3* SD = background
% 1:	feedback: plots distribution and prompts for background value.
% 2:	conservative fb: plots distribution and prompts for background and cutoff
% 3:	legacy: 3 * second smallest from the projection

% qFindMethod: Method for finding qDots
%
% 0:	default. slower. iterates through every single frame for accuracy
% 1:	legacy. faster. uses highest aggregate intensity


% dotSize: expected dotsize. regions larger than this will be considered as clumps.
% 	Set slightly larger than suspected diameter
%

% clump: whether clumps are completely ignored, or treated as one qdot.
%		
% 1:	legacy. keep brightest pixel in clumps
% 2:	don't check for clumps
%
% x:	default. ignore all points in clumps. checks border of size and makes sure
%			that all points on the border is lower than background + x * (peak-background).
%			x is allowance between 0 and 1.
%			x will default to 0.25 if x = 0.


% debugMode: turn debug comments on or off
% 
% 0:	default. no debug messages
% 1: 	comments will show to help you debug problems



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 1: Describe Important Variables 		%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fileHeight:		height of the image
% fileWidth:		width of the image

% numStack:			number of images on the stack
% firstFrame:		number of frame on which analysis should start
firstFrame = 1;

% background:		intensity value below which the pixel is considered background
% eventThreshold:	intensity value below which qdot is considered to be off











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


% set image dimensions
fileWidth = tiffReadStack(1).width;
fileHeight = tiffReadStack(1).height;

if (debugMode == 1)
	fprintf(1, 'Image width is: '+fileWidth);
	fprintf(1, 'Image height is: '+fileHeight);
end

%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 3: Format Input Data 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 4: Distribution + Background selection	%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (debugMode == 1)
	tic;
	fprintf(1,'Section 4 start');
end

%%%
%%% default method (median+3*SD)
%%%
if (bgMethod == 0)

	firstFrameData = tiffReadStack(firstFrame).data;

	%calc. median
	firstMedian = median(firstFrameData);

	%calc. S.D.
	firstSTD = std(firstFrameData);

	background = firstMedian + 3*(firstSTD);


	if (debugMode == 1)
		fprintf(1,'Background is set at: '+background);
	end

end



%%%
%%% feedback method (background only)
%%%
if (bgMethod == 1)

	firstFrameData = tiffReadStack(firstFrame).data;

	%plot first frame intensity
	hist(firstFrameData, 100);

	response = 'N';

	%repeat until good value for background is found
	while ~((response == 'Y')| (response == 'y'))
		background = input('Enter a guess for the baseline');
		%plot dots


		%may consider adding contrast range: imshow(firstFrameData, [low, high])
		imshow(firstFrameData);

		for (i = 1:fileHeight)
			for (j = 1:fileWidth)
				if (firstFrameData(i,j) >= background)
					rectangle('Position',[i, j, 1, 1],...
							  'LineStyle', '--',...
							  'LineWidth', 0.1,...
							  'EdgeColor', 'r');
				end
			end
		end

		response = input('Are you happy with the baseline? [Y/N]');
	end

	fprintf(1,'Great. Background set @ '+background);

end


%%%
%%% conservative method (background and cutoff)
%%%
if (bgMethod ==2)

	%plot first frame intensity
	hist(tiffReadStack(firstFrame).data, 100);

	response = 'N';

	%repeat until good value for background is found
	while ~((response == 'Y')| (response == 'y'))
		background = input('Enter a guess for the baseline', 's');
		%plot dots

		for (i = 1:fileHeight)
			for (j = 1:fileWidth)
				if (firstFrameData(i,j) >= background)
					rectangle('Position',[i, j, 1, 1],...
							  'LineStyle', '--',...
							  'LineWidth', 0.1,...
							  'EdgeColor', 'r');
				end
			end
		end

		response = input('Are you happy with the baseline? [Y/N]', 's');
	end

	fprintf(1,'Great. Background set @ '+background);

	response = 'N';
	%repeat until good cutoff is found
	while ~((response == 'Y')| (response == 'y'))
		cutoff = input('Enter a guess for the cutoff', 's');
		%plot dots
		
		for (i = 1:fileHeight)
			for (j = 1:fileWidth)
				if (firstFrameData(i,j) >= background)
					rectangle('Position',[i, j, 1, 1],...
							  'LineStyle', '--',...
							  'LineWidth', 0.1,...
							  'EdgeColor', 'r');
				end
			end
		end

		response = input('Are you happy with the cutoff? [Y/N]', 's');
	end

	fprintf(1,'Great. Cutoff set @ '+cutoff);

end

%%%
%%% legacy method
%%%
if (bgMethod ==3)


	maxProfile = zero(fileHeight, fileWidth);

	%for each layer in stack
	for i = firstFrame:numStack
		thisLayer = double(tiffReadStack(i).data);
		%for each pixel
		for j = fileHeight
			for k = fileWidth
				%store the higher value
				if (thisLayer(j,k)>maxProfile(j,k))
					maxProfile(j,k) = thisLayer(j,k);
				end
			end
		end
	end

	background = 3*min(setdiff(maxProfile(:),min(maxProfile(:))));

	if (debugMode == 1)
		fprintf(1,'Background set as ' +background+ ' using legacy method');
	end
end


if (debugMode == 1)
	tocTime = toc;
	fprintf(1,'Section 4 took: '+ tocTime);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 6: Locate Quantum Dots 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (debugMode == 1)
	tic;
	fprintf(1,'Section 5 start');
end

					%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					%%% default: slow & accurate method
					%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (qFindMethod == 0)
	%run pkfnd for all layers

	qDotLayers





end




							%%%%%%%%%%%%%%%%%%%%%%%%
							%%% fast & clumsy method
							%%%%%%%%%%%%%%%%%%%%%%%%
if (qFindMethod == 1)


	%%%
	%%%create aggregate maximum intensity profile
	%%%
	maxProfile = zero(fileHeight, fileWidth);

	%for each layer in stack
	for i = firstFrame:numStack
		thisLayer = double(tiffReadStack(i).data);
		%for each pixel
		for j = fileHeight
			for k = fileWidth
				%store the higher value
				if (thisLayer(j,k)>maxProfile(j,k))
					maxProfile(j,k) = thisLayer(j,k);
				end
			end
		end
	end

	%%% Find local maxima

	qDots = locMax(maxProfile, background, dotsize, clump);

end


if (debugMode == 1)
	tocTime = toc;
	fprintf(1,'Section 5 took: '+tocTime);
end

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

%%implay can be used for multiframe image array.
%%implay(I, FPS)
%%grayscale image can be M-N-K array


