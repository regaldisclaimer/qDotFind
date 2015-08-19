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
function coord = locMax(image, background, size, clump);




%Input:
	%image: source image for maxima location
	%background: background for the given layer
	%size: suspected diameter for peaks
	%clump: ignore all points in clump if 0. Keep brightest if 1.

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

if (foundPeaks > 0)
	


if (foundPeaks > 1)
