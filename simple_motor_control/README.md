In the previous version of this project the installation had much smaller size. Additionally, to be able to move two parts
of this installation that cut the foam from both sides, two servo motors were used. In this project a focus on using a
different kind of motors has been made and there are different reasons for that.
	Servo motors are widely used in practice because it is very easy to control them and in a wide range of applications this
simple behaviour is often enough to achieve quite good results. However there is a list of disadvantages in using them:
- Moving is limited only to a specific angle.
- Impossibility to get a feed-back at which position during run-time the servo motor is (there is a hack to do it by using an
  internal potentiometer, but it involves some soldering efforts).
- Limited power.
	It is impossible to ignore these disadvantages in terms of this project, thus a decision has been made to use step motors,
which turn all previously mentioned disadvantages into advantages thus allowing to be obtain more flexibility. Using them is
becomes possible to move to any point you want, with adjustable speed/acceleration and in any direction. This is exactly what
we need, since the purpose is to be able to create different forms of foam within a specific time interval. Step motors have
its minimum allowed movement called "step". A majority of step motors realize one revolution (360 degrees) using 200 steps, thus
one step corresponds to 1.8 degree.
	Powering the motor is a next issue we want to discuss. Step motors are not powered directly from the power supply, but through
the so called Big Easy Step Drivers. It is an additional middle layer hardware component between Arduino board and step motor itself.
It can take high abuse and power and powers step motors directly. It is possible to power this Driver using 8-30V but the common 
recommendation is to use the highest voltage value it is allowed to. In such a way step motors will spin faster. In our setting
we use 15 V power supply which has shown good results. 
	The second important aspect which can drastically influence the step motor's
behaviour is Driver's built-in adjustable potentiometer, which determines how much current (0-2A) will be going through the motor's
coils. Setting it too less will not let the motor be powerful enough, whereas setting it up to high can just burn the motor. After
providing a set of experiments it has been justified that the current value has to be 1.12 V +/- some delta to provide the best and
smoothest step motor behaviour.
	The very last Driver's component to be discussed is ability to divide one step = 1.8 degrees into microsteps. Microstepping
allows to break down one step into microsteps thus allowing the motor to move smoother, quieter, more accurately at lower speeds.
There are 3 PINs on the Driver's board (MS1, MS2, MS3) which by default are not soldered. Thus after soldering them to the board 
and connecting with Arduino it has become possible to set them up in a way we want depending on the speed we want to gain.
There are five different combinations which allow to set the microstepping and thus the end speed of our motor: (LOW, LOW, LOW)
will correspond to a setting without microstepping = full step = highest speed. Whereas (HIGH, HIGH, HIGH) is default configuration
that breaks one step into 16 microsteps and in such a way makes the motor move much slower. More information on that can be found
here: http://bildr.org/2012/11/big-easy-driver-arduino/ . Depending on applications that have been implemented, one step has been
usually broken down into 4 or 16 microsteps, depending on whether the motors had to move slow or fast.
	We have discussed the Hardware part of step motor control. Let us now lighten the Software part of it. To benefit from controlling
the step motors in the best way they can be controlled, it has been decided to use an open source AccelStepper library. This library 
allows to abstract from control on the lowest level by providing a set of intuitive methods, using which it becomes feasible and easy
to control the step motors in a way we want, without worrying to do something wrong. More important, controlling more than one step
motor without using an external library has been considered to be quite a big problem. Since we use two step motors in this project,
it has been obvious to choose this library, because it allows to control more than one motor without increasing difficulty of the
code. It is also worth to mention that along with the fact that setting up Hardware for step motors allows to vary its speed in wide range,
using some Software core methods from this library allows to make the last fine tuning of such values as speed and acceleration. 
This library is attached and the information how to import and use it, can be found in the root of project's repository.
	
	SOFTWARE CORE FOR STEP MOTOR
	
	During the semester a number of algorithms have been implemented, which use step motors to cut the foam differently starting from
some simple cases and ending with more complex ones. But all of them as a core use the following steps:

- Define the values for direction, step PINs as well as for MS1, MS2, MS3.
- Create a stepper object: AccelStepper stepper(1, MOTOR_STEP_PIN, MOTOR_DIR_PIN);
- As you can see, the constructor does not contain PINs MS_i. The core of AccelStepper library does not set up these PINs, thus it has
  to be done in the setup() method in every Arduino sketch using commands: pinMode(MS_i, OUTPUT) and digitalWrite(MS_i, LOW/HIGH).
- Set up speed and acceleration using methods setSpeed(SPEED) and setAcceleration(ACCELERATION). The first method sets up the end speed
  of step motor, whereas the second one defines how quick or how slow this end speed is going to be reached. If to have a look over the core code
  of this library, it can be concluded that in order to reach some position, step motor will first accelerate up to some intermediate position
  and then decelerate before reaching the specified position.
- We want to be able to ensure that two step motors rotate exactly to an angle we specify in degrees. There exist a special method for
  such purpose in this library called moveTo(NUMBER_OF_STEPS). As an argument it takes not a number of degrees the motor should move,
  but a number of raw steps. Thus it is important to recalculate how many steps should step motor do if we want it to rotate to a specific
  angle measured in degrees, using the following relation: int targetPos = ((float)angle / ONE_FULL_STEP) * MICROSTEPS, where ONE_FULL_STEP
  corresponds to 1.8 degree and MICROSTEPS can take values from {1, 2, 4, 8, 16} depending on MS_i PINs.
- We want to be able to tell step motor that it should move to another position as soon as it has rotated to the previous one. For that we
  should receive a feed-back from step motor when it has actually reached it. If to have a look over the core code, method distanceToGo() 
  would be one option to adress this problem. This method calculates the difference between the specified target position and the 
  actual position. If difference reaches zero, it would mean our step motor has reached it and another target position can be defined.
- To make an actual step the method run() is used, which executes exactly one step depending on the current speed.

	This is all we need to tell step motors what we expect doing from them. Creating of different foam shapes is based on intelligent choice
of a set of target positions, how they are processed, as well as intelligent choice of speed and acceleration. These aspects will be discussed in 
later sections.

	SUB PROJECT DESCRIPTION
	
	An attached project in this folder summarizes the above described information. It is again separated into Processing part and an executable
Arduino part. With a help of three sliders, radio button and simple send button it is possible to adjust a number of degrees step motor should move,
microstepping, speed and acceleration and then send this data to Arduino. Arduino sketch waits until all parameters are received. If it the case it 
forbids receiving of another data block as long as step motor is still moving. When the step motor is at the target position, arduino sketch switches
to wait for data modus and the process repeats once again. This project allows to play with different angles to move, different speeds in large interval
due to be able to change microstepping parameter, as well as to provide micro tuning of step motor control by changing acceleration and speed.
	
