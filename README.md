#qDotFind.m
Quantum dot reaction event analysis software

Written for Walt Lab, Tufts U

August 2015

Copyright (c) 

Author Contact: regaldisclaimer@gmail.com

##Dependencies

-locMax.m

-tiffread2.m by Francois Nedelec (nedelec@embl.de)

##How to use

0. Get MATLAB

1. Acquire dependencies

2. Download qDotFind.m and put all files in the same folder

3. Learn about [runtime options](#runtime-options)

4. Run qDotFind.m on MATLAB with appropriate parameters on the command line.

5. On prompt, select the tif image stack to analyze.

##Runtime Options

qDotFind currently accepts 5 different as you can see:

````Matlab
function void = qDotFind(bgMethod, qFindMethod, dotSize, clump, debugMode);
````

To run the program, type `qDotFind()` in the command line with appropriate option arguments.
For example, to set `bgMethod = 0`, `qFindMethod = 1`, `dotRadius = 3`, `clump = 0`, `debugMode = 1`

You will run the following in the command line:

````Matlab
qDotFind(0,1,3,0,1)
````

Here's a short description of the runtime options:

 bgMethod: Algorithm code for how the background is determined

 0:	dafault: median + 3* SD = background
 1:	feedback: plots distribution and prompts for background value.
 2:	conservative fb: plots distribution and prompts for background and cutoff
 3:	legacy: 3 * second smallest from the projection

 qFindMethod: Method for finding qDots

 0:	default. slower. iterates through every single frame for accuracy
 1:	legacy. faster. uses highest aggregate intensity


 dotSize: expected dotsize. regions larger than this will be considered as clumps.
 	Set slightly larger than suspected diameter


 clump: whether clumps are completely ignored, or treated as one qdot.
		
 1:	legacy. keep brightest pixel in clumps
 2:	don't check for clumps

 x:	default. ignore all points in clumps. checks border of size and makes sure
			that all points on the border is lower than background + x * (peak-background).
			x is allowance between 0 and 1.
			x will default to 0.25 if x = 0.


 debugMode: turn debug comments on or off
 
 0:	default. no debug messages
 1: 	comments will show to help you debug problems



##Contact
regaldisclaimer@gmail.com