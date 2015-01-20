## Interface
	
This interface allows to manually draw square-shaped foam features using drag and drop. Before drawing them, first two default sides have to be constructed. To construct them it is sufficient to fill two text fields with desired number of control points from each side. Since the height of canvas is pre-defined and the number of control points can vary, autoscaling should be done in order to keep that height. In the source code the parameter **nPoints** is responsible for that. In order to get square-shaped features we move any control point in horizontal plane and two of its neighbour points are moved together with it. Further relevant aspect is that a lower neighbour point of any control point should be at the same height as an upper neighbour point of the next control point and a line between them has to exist. This is applicable to all control points, and in such a way it is feasible to create square-shaped sculptures on the canvas. The described procedure can be found in the **constructor of the class Curve**.

As soon as two sides have been created, it becomes possible to move control points from each side
using drag and drop to get any square-shaped sculpture we want. After the desired form has been
constructed, almost everything is ready to start the simulation. Before two sets of target positions
for each side are sent via serial connection, rescaling procesure of control points has to be done in
order to transform their pixel coordinates into degrees, two step motors should move. To do this we
need two static parameters: **delta** and **dInDegree**. The first parameter defines the maximum distance in 
pixels any control point is allowed to be shifted from its start position using drag and drop. Another
parameter defines the maximum distance, measured in degrees, two step motors are allowed to move. By
moving the control points from their start positions we know their new coordinates in pixels, thus
the only thing to be done in order to estimate exact number of degrees step motors should move, is to
find a relation between the new coordinates of control points and **delta** parameter, and multiply this
relation with **dInDegree**.

Now it is everything ready to start the simulation, as well as start cutting the foam according to
the drawn sculpture in interface. By clicking two appropriate buttons a start simulation signal
is sent to one Arduino board, as well as two sets of target positions measured now in degrees to another
board.
	
## Cutting algorithm
	
In the **setup()** function we first wait until all data is received. The following protocol to send and recieve data is used: **(target position 1, ..., target position R; target position 1, ..., target position L.)**, where **target position 1...R** is a set of control points measured in degrees the right step motor should move, and **target position 1...L** is a set of control points for the left step motor accordingly. All these target positions are stored in two arrays of fixed size and since it is impossible to know exact number of elements in these two arrays by compile time, this size is selected to be big enough. Another possibility would be to dynamically allocate required memory, but this has been considered as not the best solution using Arduino boards. Thus to detect end of constructive part in these arrays, they were **filled with some
identifier** (see code).

To construct square-shaped foam sculptures the following idea was used: we can measure the time needed to create foam of maximum height and we know a number of target positions from each side. Thus if we divide this time by the number of control points from each side, we get the time needed to treat exactly one control point. Since we try to obtain square-shaped sculptures, this time interval is considered to be the time step motor does not move. It simply stays at the specified position with the turned-on DC motor that sculptures the foam during this time interval. After that step motor moves to the next target position and stays in idling mode as described above. This kind of routine is repeated until all control points from each side have been handled by two step motors. 

One important point to notice is that in order to get approximately square-shaped sculptures the 
motion from one target position to another should be as instant as possible. Thus the value for 
microstepping has been chosen to be 4. At the same time it is logical to set the speed and 
acceleration as high as possible to achieve better results. Using configuration (see source code) 
it was possible to achieve some good-recognizable results, but setting those parameter as high 
(in case of speed and acceleration) as possible, while decreasing microstepping should bring better results.
