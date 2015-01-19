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
has been moved to the left PI/2 as a start angle and 3*PI/2 as end angle. Using a simple "for loop"
and starting from the start angle, using as a step "stepAngle", it is now possible to build half
ellipse containing all intermediate points, which coordinates are set using the following relation:
"float x = xC + w * cos(angle); float y = yC + h * sin(angle)", where "xC, yC" are x and y coordinates
of the origin, "w" is a distance between x coordinates of the actual position of control point and its origin, and
"h" is a distance between y coordinates of two neighbour points. Thus moving of any control point
and using above described approach it is feasible to create any curve-shaped form. Each draw()
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
	
	As an input this algorithm gets two independent data blocks: array of target positions for a step motor and
and array of delay values. The first array discretizes one foam side into a set of target positions, whereas the second
one consists of delay values that will be used during sequential handling of target positions. The algorithm
is divided into two phases: passive, when two data blocks are being received, and active, when the actual cutting is being 
done. Let us have a look at the active phase more in detail. In the setup() method a step motor is adjusted in such a way that
it is able to move to any target position as instant as possible, which is provided by the following setting: microstepping
is set to 4, acceleration value is set to 29000 and speed equals 5000. 
	During active phase of the algorithm we pick one target position from an appropriate array, as well as a delay value from
another array. The step motor moves as quick as possible to this target position. As soon as it has reached it, it starts moving
back to the origin position again as instant as possible. When the step motor reaches zero, it stops moving and stays
in this idling mode during time interval, described by the picked delay value. These delay values describe how far in time the target
positions are from each other. For example, if the previously introduced parameter "nPointsProArc" was set to a small value, it
would have resulted in bigger delays, because we would have less target positions to handle, and vice versa setting that value to
a bigger number would result to smaller delays. After the time difference has reached a delay value, the step motor is allowed
to handle another target position in the same manner until there are no more positions to work on.
	Thus this algorithm tries to neglect time needed to go to any target position and back, by using the configuration which
allows to achieve this, in contrast to the picked delay time. One important aspect to mention is that in order to fill the delay array
with correct values, we should precisely know how long it takes for the foam to be fabricated. If we know this value, then cutting
procedure will be finished approximately at the same time the foam reaches its maximum in height.
	Experimental results were not perfect. Depending on the drawn foam sculpture, the results were either acceptable or not. For some
reasons different curve fragments have shown different acceptability level. For example, clockwise curve fragments of the left
side were much better recognizable as those which were counter-clockwise. If to consider possible improvements towards higher degree
of recognition, they could be: increasing a number of intermediate points for one arc fragment or changing of step motor configuration.
	Provided experimental results of this algorithm have become a source of motivation to implement another one, which would deliver 
much more acceptable results and the below described algorithm is able to achieve this goal.

	
	SLOW CONTINIOUS MOTION CUTTING ALGORITHM
		
	This algorithm implements continious motion of two step motors. Having two sequential target positions, now two step motors instead
of doing the sequence go to one target position, go to zero, delay, go to another target position, will slow and smoothly move from one
target position to another. This approach thus can be considered as an opposite to the first algorithm.
	The very first issue was to make a step motor move very slow, considerably slower than before. To achieve this a set of experiments
has been done. First an array containing a small number of target positions was created. During this test a step motor was sequentially
handling them as usual, but additionally two time stamps were introduced. During the first one our step motor was allowed to move, whereas
during the second one not. Trying different combinations of those it was possible to slown down a motor without changing its speed and
acceleration, but the motion itself was not smooth enough to be acceptable. The library's core for a step motor implicitly does this kind
of procedure, so implementing this kind of routine explicitly was not acceptable. This lead to make further experiments, but now an attempt
was made to reduce the acceleration.
	