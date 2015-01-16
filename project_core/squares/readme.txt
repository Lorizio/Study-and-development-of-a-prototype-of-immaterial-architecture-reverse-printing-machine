	INTERFACE
	
	
	ARDUINO CUTTING ALGORITHM
	
	In the setup() function we first wait until all data is received. The following protocol
to send and recieve data is used: ( target position_1, ..., target position_R; 
target position_1, ..., target position_L. ), where target position_1...R are control points
measured in degrees the right step motor should move, and target position_1...L are control
points for the left step motor. All these target positions are stored in two arrays of fixed
size and since it is impossible to know exact number of elements in these two arrays by compile
time, this size is selected to be big enough. Another possibility would be to dynamically allocate
required memory, but this has been considered as not the best solution using Arduino boards. Thus
to be able to detect end of constructive part in these arrays, they were filled with some 
identifier.
	To construct square-shaped foam sculptures the following idea has been used: we can measure the
time needed to create foam of maximum height and we know the number of target positions from each
side. Thus if we divide this time by the number of control points from each side, we get the time
needed to treat exactly one control point. Since we try to obtain square-shaped sculptures, this time
is the time step motor does not move. It simply stays at the specified position with turned-on
DC motor that sculptures the foam during this time interval. After that step motor moves to the next
target position and stays in idling mode as described above. This kind of routine is repeated until
all control points from each side have been handled by the step motors. 
	One important point to notice is that in order to get approximately square-shaped sculptures the 
motion from one target position to another should be as instant as possible. Thus the value for 
microstepping has been chosen to be 4. At the same time it is logical to set the speed and 
acceleration as high as possible to achieve better results. Using configuration (see source code) 
it was possible to achieve some good-recognizable results, but setting those parameter as high 
(in case of speed and acceleration) as possible, while decreasing microstepping should bring better results.