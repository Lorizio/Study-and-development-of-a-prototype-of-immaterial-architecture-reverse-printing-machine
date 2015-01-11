	BACKGROUND
	
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
	
	