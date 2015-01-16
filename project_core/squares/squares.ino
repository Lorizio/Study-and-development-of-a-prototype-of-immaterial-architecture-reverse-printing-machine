#include <AccelStepper.h>

#define ONE_FULL_STEP 1.8
#define MICROSTEPS 4

#define MS1 13
#define MS2 12
#define MS3 8
#define MOTOR_DIR_PIN  4
#define MOTOR_STEP_PIN 3

#define MS4 A0
#define MS5 A1
#define MS6 A2
#define MOTOR2_DIR_PIN 7
#define MOTOR2_STEP_PIN 6

// described in readme END delimiter for the arrays
#define END 255

#define FOAM_TIME 148  // adjustable

#define SPEED 5000
#define ACCEL 29000

// in this case maximum 15 control points
// allowed
#define N 15

AccelStepper stepper(1, MOTOR_STEP_PIN, MOTOR_DIR_PIN);
AccelStepper stepper2(1, MOTOR2_STEP_PIN, MOTOR2_DIR_PIN);

int goToRight[N];  // array with control points in degrees for right
int goToLeft[N];   // same for left side

int v = 0;
int counter = 0;  // counts number of target positions for right
int counter2 = 0; // same for left side

boolean rcvd = false;

int targetPos;
int targetPos2;

int posId = -1;  // IDs of goTo positions for right
int posId2 = -1; // same for left side

boolean stop_;  // flag that identifies when right side
boolean stop2;  // or left side have been handled

unsigned long waitTime;  // described in readme idling time
unsigned long waitTime2; // of step motors

unsigned long time;
unsigned long time2;

// first receive right curve
boolean rightCurve = true;

boolean _begin = true;  // some auxiliary flags
boolean _begin2 = true;

boolean pause = false;    // flags identifying when step motors
boolean pause2 = false;   // should not move and be idle

void setup()
{
  Serial.begin(9600);
  
  // receive modus
  while(!rcvd)
  {   
    if (Serial.available())
    {
      char ch = Serial.read();
      switch (ch)
      {
        case '0'...'9':
          v = v * 10 + ch - '0';
          break;
          
        case ',':
          if (rightCurve)  
          { 
            goToRight[counter] = v; 
            counter++;
          }
          else
          {
            goToLeft[counter2] = v;
            counter2++;
          }
          v = 0;
          break;
          
        case ';':
          goToRight[counter] = v;
          v = 0;
          counter++;
          
          // start receiving left curve
          rightCurve = false;
          break;
          
        case '.':
          goToLeft[counter2] = v;
          v = 0;
          counter2++;
          rcvd = true;
          break;
      }
    }
  }
  
  // here data successfully received
  
  waitTime = FOAM_TIME / counter;
  // in ms
  waitTime *= 1000;
  
  waitTime2 = FOAM_TIME / counter2;
  // in ms
  waitTime2 *= 1000;
  
  // fill rest of array with some id
  for (int i = counter; i < N; i++)   { goToRight[i] = END; }
  for (int i = counter2; i < N; i++)  { goToLeft[i] = END; }
  
  stepper.setMaxSpeed(SPEED);
  stepper2.setMaxSpeed(SPEED);
  stepper.setAcceleration(ACCEL);
  stepper2.setAcceleration(ACCEL);
  
  pinMode(MS1, OUTPUT);
  pinMode(MS2, OUTPUT);
  pinMode(MS3, OUTPUT);
  
  pinMode(MS4, OUTPUT);
  pinMode(MS5, OUTPUT);
  pinMode(MS6, OUTPUT);
  
  digitalWrite(MS1, LOW);
  digitalWrite(MS2, HIGH);
  digitalWrite(MS3, LOW);
  
  digitalWrite(MS4, LOW);
  digitalWrite(MS5, HIGH);
  digitalWrite(MS6, LOW);
}

void loop()
{ 
  //  right step motor
  if (stepper.distanceToGo() == 0 && !pause)
  { 
    if (goToRight[posId + 1] != END)
    {
      stop_ = false;
      posId++;
      targetPos = ((float)goToRight[posId] / ONE_FULL_STEP) * MICROSTEPS;
      stepper.moveTo(targetPos);
      
      if (!_begin)
      {
        pause = true;
        time = millis();
      }
      else  { _begin = false; }
    }
    else  { stop_ = true; }
  }
  // wait
  else if ( pause && ((millis() - time) >= waitTime ) )  { pause = false; }
  
  //--------------------------------------------------------------------------
  
  // left step motor
  if (stepper2.distanceToGo() == 0 && !pause2)
  { 
    if (goToLeft[posId2 + 1] != END)
    {
      stop2 = false;
      posId2++;
      targetPos2 = ((float)goToLeft[posId2] / ONE_FULL_STEP) * MICROSTEPS;
      stepper2.moveTo(targetPos2);
      
      if (!_begin2)
      {
        pause2 = true;
        time2 = millis();
      }
      else  { _begin2 = false; }
    }
    else  { stop2 = true; }
  }
  // wait
  else if ( pause2 && ((millis() - time2) >= waitTime2 ) )  { pause2 = false; }
  
  if (!stop_ && !pause)   { stepper.run(); }
  if (!stop2 && !pause2)  { stepper2.run(); }
}
