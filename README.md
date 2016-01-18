#qDotFind.m
Quantum dot reaction event analysis software

Written for Walt Lab, Tufts U

August 2015

Copyright (c) 

Author Contact: regaldisclaimer@gmail.com

##Dependencies

-pkfnd.m (included in the repo. replaced locMax.m as of December 2015)

-tiffread2.m (included in the repo)

##How to use

0. Get MATLAB

1. Download all matlab scripts in the repo into a folder.

2. If you ever move the location of the scripts, ensure that the scripts reside in the same folder

3. Learn about [runtime options](#runtime-options)

4. Locate 'Section 0: Options' on qDotFind.m

5. Edit runtime options as desired 

6. Select qDotFind.m and click 'Run'

7. On prompt, select the tif image stack to be analyzed

8. On prompt, input background/threshold estimates (if applicable)

##Runtime Options

qDotFind currently accepts 6 different runtime options.

````Matlab
firstFrame = 1;
bgMethod = 1;
qFindMethod = 1;
dotSize = 2;
clump = 2;
debugMode = 1;
````

Edit the script, hardcode runtime options, and save the script so that your analyses will always use the same settings 
(save yourself from using wrong parameters by mistake, or forgetting which options to use)

Here's a short description of the runtime options:

````
 firstFrame: The frame # from which the analysis should start. First frame of the image stack is 1, not 0.
 	If the first 10 frames cannot be trusted, for example, set this option as `firstFrame = 11`, 
 	so that the analysis starts on frame #11.

 bgMethod: Algorithm code for how the background is determined

 0:	default: median +/- 3* SD = background and backgroundUpper. Uses both lower and upperbound.
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

````

##Contact
regaldisclaimer@gmail.com
