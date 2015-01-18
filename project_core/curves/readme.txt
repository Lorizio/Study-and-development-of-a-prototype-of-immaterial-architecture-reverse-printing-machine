	INTERFACE
	
	This interface allows to manually draw curve-shaped foam features using drag and drop.
Before drawing them, first two default sides have to be constructed. To construct them it
is sufficient to fill two text fields with desired number of control points from each side.
Using these control points we want to create curve features by again using drag and drop.
In order to achieve this goal, for each possible arc between the lower and upper neighbour of
any control point a set of intermediate points is created. This set represents half of the ellipse
and the more intermediate points there are, the more precise half ellipse we will get. Thus
one side of the foam is now represented by two sets of points: one set contains all control
points and their neighbours, and another one splits those and represents the discretization
of one side. The first array thus contains "nPoints = nPointsTemp * 2 + 1" elements, where
"nPointsTemp" is a number of control points we filled in a text field before, and the second
array contains "dataSize = (nPoints / 2) * nPointsProArc + 1" elements, where "nPointsProArc"
denotes a number of intermediate points between the lower and upper neighbour of any control point.
	Later in Arduino's section we are going to introduce two possible cutting algorithms that
make use of these two arrays. The first one will use data from a bigger array with "dataSize" number
of elements, whereas the second algorithm will use an array that contains only information about
control points.
	As soon as two sides have been created it becomes possible to move control points from each side
using drag and drop to get any curve-shaped sculpture we want. By moving control points from their
origin we want to create half ellipse that is considered to be good approximation for one curve
feature. To do this we first defined a parameter "stepAngle = PI/nPointsProArc" which denotes
a step, our half ellipse is going to be built with and again, the more intermediate points between the 
lower and upper neighbour of any control point we have defined, the more precise and good-looking
result we will get. Depending on to which side any control point is being moved relatively its
origin position, we should define two edge angles that will allow to build half ellipse. If a control
point has been moved to the right, we use as a start angle -PI/2 and end angle PI/2, whereas if it
has been moved to the left PI/2 as a start angle anf 3*PI/2 as end angle. Using a simple "for loop"
and starting from the start angle, using as a step "stepAngle", it is now possible to build half
ellipse containing all intermediate points, which coordinates are set using the following relation:
"float x = xC + w * cos(angle); float y = yC + h * sin(angle)", where "xC, yC" are x and y coordinates
of the origin, "w" is a distance between x coordinates of the actual position of control point and its origin, and
"h" is a distance between y coordinates of two neighbour points. Thus moving of any control point
and using above described approach it is feasible to create any curve-shaped features. Each draw()
cycle will completely rewrite the discretization array, filling it with new coordinates of each point
on the curve.
	All other principles, which were omitted here like rescaling the pixel coordinates into degrees the step
motors should move, are described in the square-shaped sculpture project. Depending on which cutting algorithm
is going to be applied, different data is sent to an appropriate Arduino board. As briefly mentioned above,
there exist two different algorithms: one uses rapid back-and-forth movements of two step motors, whereas
another one uses slow continious and smooth motion of step motors. In the first case the following data is
sent: first the rescaled discretization array containing all the target information for step motots is sent.
Further, another data block is sent which defines how big a delay should be between handling of two sequential
target positions. What it exactly means will be described below. In the second case only one data block is sent,
containing the rescaled information of control points array, representing two sets of target positions in degrees for
both step motors.

	RAPID BACK-AND-FORTH CUTTING ALGORITHM
	
	
	
	SLOW CONTINIOUS MOTION CUTTING ALGORITHM