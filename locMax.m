%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %
%%%%%	%%%%%					locMax.m						%%%%%	%%%%%
%%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %%  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%	Local Maxima Locator
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
%%		no dependencies.
%%		
%%
%%
%%	Usage:
%%
%%		for use with qDotFind.m
%%		reference the github page (github.com/regaldisclaimer/qDotFind)
%%		for more information on using this software
%%
%%
%%
%%	Based on pkfnd.m by Eric R. Dufresne, Yale University
%%
%%
%%
%%
%%
%%
function coord = locMax(image, background, dotSize, clump);




%Input:
	%image: source image for maxima location
	%background: background for the given layer
	%size: suspected diameter for peaks
	%clump: 
	% 1:	legacy. keep brightest pixel in clumps
	% 2:	don't check for clumps
	%
	% x:	default. ignore all points in clumps. checks border of size and makes sure
	%			that all points on the border is lower than background + x * (peak-background).
	%			x is allowance between 0 and 1.
	%			x will default to 0.25 if x = 0.

%Output: 
	%coordinates. Column1: x coord. Column2: y coord.

%get img dimension
[imgHeight, imgWidth] = size(image);

%find dots above threshold
brightDots = find(image > background);
numBrightDots = length(brightDots);

%if none found
if (numBrightDots == 0)
	coord = [];
	return;
end

foundMax = [];

%get coordinates of bright dots
coordinate = [mod(brightDots, imgHeight), floor(brightDots/imgHeight)+1]; %ceil?

for (i = 1: brightDots)
	row = coordinate(i,1);
	column = coordinate(i,2);

	%not on the boundary
	if (row > 1 & row < imgHeight & column > 1 & column < imgWidth)
		%it's the max in 3x3 sq. centered on itself
		if (image(row, column) == max(image(row-1:row+1:column-1:column+1)))
			foundMax = [foundMax,[row, column]'];
		end
	end
end

%invert
foundmax = foundMax';

%exclude clumps
[foundPeaks, unused] = size(foundMax);


%%Remove ones on edges
if (foundPeaks > 0)
	index = find(foundMax(:,1) > dotSize & foundMax(:,1) < (imgHeight-dotSize) & foundMax(:,2) > dotSize & foundMax(:,2) < (imgWidth-dotSize));
	foundMax = foundMax(index,:);
end

%%Remove clump
if (foundPeaks > 1)

	%map peaks
	peakMap = 0.*image;
	for (i = 1:foundPeaks)
		peakMap(foundMax(i,1),foundMax(i,2)) = image(foundMax(i,1),foundMax(i,2));
	end


	if (clump == 1)

		%keep the brightest

		for (i = 1:foundPeaks)
			%locMax of region of radius size/2
			[maxRow, indexi] = max(peakMap((foundMax(i,1)-floor(dotSize/2)):(foundMax(i,1)+(floor(dotSize/2)+1)),(foundMax(i,2)-floor(dotSize/2)):(foundMax(i,2)+(floor(dotSize/2)+1))));
			[maxVal, indexj] = max(maxRow);
			%empty the region
			peakMap((foundMax(i,1)-floor(dotSize/2)):(foundMax(i,1)+(floor(dotSize/2)+1)),(foundMax(i,2)-floor(dotSize/2)):(foundMax(i,2)+(floor(dotSize/2)+1)))=0;

			%reinstate the highest
			peakMap(foundMax(i,1)-floor(dotSize/2)+indexi(indexj)-1,foundMax(i,2)-floor(dotSize/2)+indexj-1)=maxVal;
		end

		%get coordinates
		index = find(peakMap > 0);
		foundMax = [mod(index, imgHeight), floor(index/imgHeight) +1];
	end

	if (clump == 2)
		%% -> don't bother with clumps
	end

	if (clump > 0)
		%%remove the whole thing. Border around must be lower than bg + A*(Max-bg).
		
		borderdSize = dotSize + 2;

		%define border
		for (i = 1:foundPeaks)


			%border is the set of coords. peakMap(i,j)
			for (i = (foundMax(i,1)-floor(borderSize/2)):(foundMax(i,1)+(floor(borderSize/2)+1)))
				for (j = (foundMax(i,2)-floor(borderSize/2)):(foundMax(i,2)+(floor(borderSize/2)+1)))
					%add indices
					border(end+1,1) = i;
					border(end+1,2) = j;
				end
			end

			for (i = (foundMax(i,1)-floor(dotSize/2)):(foundMax(i,1)+(floor(dotSize/2)+1)))
				for (j = (foundMax(i,2)-floor(dotSize/2)):(foundMax(i,2)+(floor(dotSize/2)+1)))
					%remove indices
					thisIndex = [i,j];
					border = setdiff(border, thisIndex);
				end
			end



			% filledBorder = peakMap((foundMax(i,1)-floor(borderSize/2)):(foundMax(i,1)+(floor(borderSize/2)+1)),(foundMax(i,2)-floor(borderSize/2)):(foundMax(i,2)+(floor(borderSize/2)+1)));
			% inner = peakMap((foundMax(i,1)-floor(size/2)):(foundMax(i,1)+(floor(size/2)+1)),(foundMax(i,2)-floor(size/2)):(foundMax(i,2)+(floor(size/2)+1)));
			
			% %not sure if this works.

			% border = setdiff(filledBorder, inner);

			maxVal = max(max(border));

			borderThreshold = background + clump * (maxVal-background);

			%% at least 1 pixel is above border threshold or negative
			if (find((peakMap(border(:)) > borderThreshold)) > 0)||(find ((peakMap(border(:)) < 0)) > 0)
				%%make inner portion negative
				peakMap(border(:)) = -1;
			end
		end
	end
end

%%Return coordinates

if (size(foundMax) > 0)
	coord(:,1) = foundMax(:,1);
	coord(:,2) = foundMax(:,2);
end

if (size(foundMax) == 0)
	coord = [];
end