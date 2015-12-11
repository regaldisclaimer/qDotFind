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
%%
%%		locMax.m
%%				influenced by:	pkfnd.m by Eric R. Dufresne (Yale University)
%%								tiffread2.m by Francois Nedelec (nedelec@embl.de)
%%
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

%function ans= qDotFind(bgMethod, qFindMethod, dotSize, clump, debugMode)

% check to make sure all arguments are passed in for safety.
%if(nargin<5)
%	error('WARNING: MISSING ARGUMENT(S). PROGRAM EXITING');
%end


%%Run with inbuilt options for debug
bgMethod = 1;
qFindMethod = 0;
dotSize = 3;
clump = 0;
debugMode = 1;





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
	formatSpec = '\n Image width is: %d';
	fprintf(formatSpec, fileWidth);
	formatSpec = '\n Image height is: %d';
	fprintf(formatSpec, fileHeight);
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
	fprintf(1,'\n Section 4 start');
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
		formatSpec = '\n Background is set at: %d';
		fprintf(formatSpec, background);
	end

end



%%%
%%% feedback method (background only)
%%%
if (bgMethod == 1)

	firstFrameData = tiffReadStack(firstFrame).data;

	%plot first frame intensity
	figure(01);
	hist(double(firstFrameData), 100);

	response = 'N';

	%repeat until good value for background is found
	while ~((response == 'Y')|| (response == 'y'))
		background = input('\n Enter a guess for the baseline');
		%plot dots


		%may consider adding contrast range: imshow(firstFrameData, [low, high])
		figure(02);
		imshow(firstFrameData);

		for i = 1:fileHeight
			for j = 1:fileWidth
				if firstFrameData(i,j) >= background
					rectangle('Position',[i, j, 1, 1],...
							  'LineStyle', '--',...
							  'LineWidth', 0.1,...
							  'EdgeColor', 'r');
				end
			end
		end

		response = input('\n Are you happy with the baseline? [Y/N]');
	end

	formatSpec = '\n Great. Background set @ %d';
	fprintf(formatSpec, background);

end


%%%
%%% conservative method (background and cutoff)
%%%
if (bgMethod ==2)

	%plot first frame intensity
	hist(tiffReadStack(firstFrame).data, 100);

	response = 'N';

	%repeat until good value for background is found
	while ~((response == 'Y')|| (response == 'y'))
		background = input('\n Enter a guess for the baseline', 's');
		%plot dots

		for i = 1:fileHeight
			for j = 1:fileWidth
				if firstFrameData(i,j) >= background
					rectangle('Position',[i, j, 1, 1],...
							  'LineStyle', '--',...
							  'LineWidth', 0.1,...
							  'EdgeColor', 'r');
				end
			end
		end

		response = input('\n Are you happy with the baseline? [Y/N]', 's');
	end
	formatSpec = '\n Great. Background set @ %d';
	fprintf(formatSpec, background);

	response = 'N';
	%repeat until good cutoff is found
	while ~((response == 'Y')|| (response == 'y'))
		cutoff = input('\n Enter a guess for the cutoff', 's');
		%plot dots
		
		for i = 1:fileHeight
			for j = 1:fileWidth
				if firstFrameData(i,j) >= background
					rectangle('Position',[i, j, 1, 1],...
							  'LineStyle', '--',...
							  'LineWidth', 0.1,...
							  'EdgeColor', 'r');
				end
			end
		end

		response = input('\n Are you happy with the cutoff? [Y/N]', 's');
	end
	formatSpec = '\n Great. Cutoff set @ %d';
	fprintf(formatSpec, cutoff);

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
		formatSpec = '\n Background set as %d using legacy method';
		fprintf(formatSpec, background);
	end
end


if (debugMode == 1)
	tocTime = toc;
	formatSpec = '\n Section 4 took: %f'
	fprintf(formatSpec, tocTime);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 6: Locate Quantum Dots 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (debugMode == 1)
	tic;
	fprintf(1,'\n Section 5 start');
end

					%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					%%% default: slow & accurate method
					%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (qFindMethod == 0)
	%run locMax for all layers

    qDotLayers = zeros(numStack);
    
	%for each layer
	for i = firstFrame:numStack
		thisLayer = double(tiffReadStack(i).data);
		qDotLayers(i) = locMax(thisLayer, background, dotSize, clump);
	end

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

	qDotLayer = locMax(maxProfile, background, dotsize, clump);

end


if (debugMode == 1)
	tocTime = toc;
	formatSpec = '\n Section 5 took: %f';
	fprintf(formatSpec, tocTime);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 7: Plot Distribution 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%show distribution of local maxima 
if (qFindMethod == 0)

	%%initialize hist stack

%	histStack = [];

%	for i = firstFrame:numStack
%		%%hist stack
%		histStack[1] = hist(qDotLayers(i), 100);
%	end

	figure
	implay(hist(qDotLayers(firstFrame:numStack),100));

end

if (qFindMethod == 1)
	figure
	hist(qDotLayer, 100);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 8: Determine Threshold 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%receive input for threshold

%show image and dots

thresResponse = 'N';

while ~((response == 'Y') || (response == 'y'))
	eventThreshold = input('\n Enter a guess for the event threshold');

	figure
	imshow(firstFrameData, [min(firstFrameData(:)), eventThreshold])

	%plot events
	for q=1:size(qDotLayer,1)
	    rectangle('Position', [qDotLayer(q,1)-0.5,qDotLayer(q,2)-0.5,1,1], ...
	        'LineStyle', 'none', 'FaceColor', 'r')
	end

	thresResponse = input('\n Are you happy with the event threshold? [Y/N]');

end

formatSpec = '\n Great. Event Threshold set @ %d';
fprintf(formatSpec ,eventThreshold);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 9: Determine Events 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%determine events 
if (qFindMethod == 0)
	%consolidate list of qDots
	%could setdiff, but ordering issues
	%just iterate

	qDotPresence = zeros(fileHeight, fileWidth);

	for s=firstFrame:numStack
		for p=1:size(qDotLayers,1)
			thisLayer = qDotLayers(p);
			qDotPresence(thisLayer(q,2),thisLayer(q,1));
		end
	end


	for i = 1:fileHeight
		for j = 1:fileWidth
			if qDotPresence(i,j)==1
				%qDot exists here
				qDotLayer(end+1,1) = i;
				qDotLayer(end+1,2) = j;
			end
		end
	end
end







%fetch intensity of each qdot for each frame
dotHistory = zeros(numStack, size(qDotLayer,1));

%for each dot
for q=1:size(qDotLayer,1)

	%qDot intensity for current qDot
	thisQDots = zeros(numStack);

	%look through all stacks

	for s=firstFrame:numStack

		%takes intensity of q'th qDot in s'th frame
		thisQDots = double(stack(s).data(qDotLayer(q,2), qDotLayer(q,1)));
	end


	%store this layer to total
	dotHistory(:,q) = thisQDots;

end

%calc. average intensity of qDot over next 10 frames
%for each qDot

for r=1:size(dotHistory,2)
	%from 1 to number of stacks -10
	for t=1:numStack-10
		%histAvg: #stack-10 x #qdot (double)
		%take average of 10 frames from t'th frame for each qDot
		histAvg(t,r) = mean(dotHistory(t:t+10,r));
	end
end

%qDotEvents: #ofEvent x 2(double)
qDotEvents = [];

%n goes from 1 to # of qDot
for n=1:size(res,2)

    %%for n'th quantum dot, find last frame for which 10frame average was higher than threshold 
    %"off occurs the last frame before the smoothed average falls below the event threshold"
    off=find(smooth(:,n)>qthresh,1,'last'); 

    %for how many frames the qdot is above the event threshold
    count=length(find(smooth(1:off,n)>qthresh));

    %Obscure conditions for weeding out events. Conditions:
    %Off event exists && last frame is at least 100 frames from start frame &&
    %last frame is at least 100 frames from the last frame &&
    %length of the event should be greater than half of the last frame number??? obscure...
    %Average intensity of this quantumdot over the first 10 frames is greater than the threshold
    %these conditions dramatically reduce monitored dots, and no rationale specified.

    if ~isempty(off) && off>start+100 && off<num-100 && count>off/2 && smooth(1,n)>qthresh  
        %add frame/10, presumably seconds, and which quantumdot it was
        qDotEvents=[qDotEvents; [off/10,n]];
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 10: Format Output Data 					%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%	%%%%%	Section 11: Plot Output 						%%%%%	%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%implay can be used for multiframe image array.
%%implay(I, FPS)
%%grayscale image can be M-N-K array



for i=firstFrame:numStack
	allData(i) = tiffReadStack(i).data;
end


figure
plot(dotHistory(:,(qDotEvents(:,2))))

implay(allData)

%plot events
for q=1:size(qDotEvents,1)
    rectangle('Position', [qDotLayer(q,1)-1.5,qDotLayer(q,2)-1.5,0.5,0.5], ...
        'LineStyle', 'none', 'FaceColor', 'r')
    rectangle('Position', [qDotLayer(q,1)+1,qDotLayer(q,2)-1.5,0.5,0.5], ...
        'LineStyle', 'none', 'FaceColor', 'r')
    rectangle('Position', [qDotLayer(q,1)-1.5,qDotLayer(q,2)+1,0.5,0.5], ...
        'LineStyle', 'none', 'FaceColor', 'r')
    rectangle('Position', [qDotLayer(q,1)+1,qDotLayer(q,2)+1,0.5,0.5], ...
        'LineStyle', 'none', 'FaceColor', 'r')
end
