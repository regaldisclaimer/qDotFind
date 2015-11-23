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


##Contact
regaldisclaimer@gmail.com