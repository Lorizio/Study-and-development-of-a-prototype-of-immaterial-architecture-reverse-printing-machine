## Folder content

After providing the fundamentals of how to control different parts of given installation, it is possible now to aggregate them together and create different foam sculptures. Next three projects demonstrate how this can be done using three different interface versions for each kind of foam sculpture.

The following types of foam sculptures will be presented: squares, curves and squares which are formed automatically using microphone. For each of those types there exist an appropriate interface implemented using Processing, as well as one or multiple Arduino source code files that implements the desired behaviour. In each project we use two Arduino boards: one that controls foam fabrication and another one controls the desired behaviour of step motors. Using only one Arduino board to control everything is possible, but experimentally it has been proven that splitting the control mission into two independent parts shows much better results. 

Each project's interface is divided into two parts. The first one is common no matter what project it is and controls creating of canvas, where desired foam sculpture is drawn. This part of interface is also responsible for controlling the whole simulation. Another part of interface represents a canvas itself. Depending on the project it is possible either to create the desired form manually using drag and drop, or to create it automatically using microphone. As soon as everything is ready to simulate, a start simulation signal to one Arduino board can be sent which will start to produce foam, as well as a set of target positions for two step motors to another Arduino board to start cutting the sculpture.

Foam fabrication does not depend on cutting algorithm for step motors, thus can be explained separately here, whereas
an appropriate cutting algorithm for creating different foam sculptures and part of interface responsible for it, 
is something project's specific and will be introduced in appropriate project's readme file.

## Foam fabrication algorithm

**TODO**
	

