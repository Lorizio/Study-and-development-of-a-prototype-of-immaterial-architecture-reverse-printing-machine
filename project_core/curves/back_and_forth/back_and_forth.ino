#include <AccelStepper.h>

#define ONE_FULL_STEP 1.8
#define MS1 4
#define MS2 13
#define MS3 7
#define MOTOR_DIR_PIN  12
#define MOTOR_STEP_PIN 11
#define MICRO 4
#define SPEED 5000
#define ACCELERATION 29000
#define MAX_SIZE 61

int goToIndexL = 0;

// to switch between modes
// I = 0 -> go to target position
// I = 1 -> go to zero
// I = 2 -> delay mode
int I = 0;

// delay flag
boolean lock = false;

// current target position and delay value
int goToL, deltaTimeL;

// start counting delay time
unsigned long tL = 0;

AccelStepper stepper(1, MOTOR_STEP_PIN, MOTOR_DIR_PIN);

// discretization array of target positions
int goToLeft[MAX_SIZE];

// delay array
int deltaTleft[MAX_SIZE - 1];

int v = 0;
int counter = 0;

// first receive target positions data block
boolean goToLeftThere = false;

boolean startCut = false;

void  setup()
{
  Serial.begin(9600);
  
  pinMode(MS1, OUTPUT);
  pinMode(MS2, OUTPUT);
  pinMode(MS3, OUTPUT);
  
  // set a step motor's configuration to be very quick
  // in moving
  
  digitalWrite(MS1, LOW);
  digitalWrite(MS2, HIGH);
  digitalWrite(MS3, LOW);
  
  stepper.setMaxSpeed(SPEED);
  stepper.setSpeed(SPEED);
  stepper.setAcceleration(ACCELERATION);
}

void loop()
{
  // receive data
  if (Serial.available())
  {
    char ch = Serial.read();
    switch(ch)
    {  
      case '0'...'9':
        v = v * 10 + ch - '0';
        break;
        
      case ',':
        if (goToLeftThere == false)   { goToLeft[counter] = v; }
        else                          { deltaTleft[counter] = v; }
        
        v = 0;
        counter++;
        break;
        
      case ';':
        if (goToLeftThere == false)
        {
          goToLeft[counter] = v;
          v = 0;
          counter = 0;
          
          goToLeftThere = true;
        }
        break;
        
      case '.':
        deltaTleft[counter] = v;
        v = 0;
        counter = 0;
        startCut = true;
        break;
    }
    Serial.flush();
  }
  
  // data received
  if (startCut && goToIndexL < MAX_SIZE)
  { 
    goToL = goToLeft[goToIndexL];
    goToL = ((float)goToL / ONE_FULL_STEP) * MICRO;
    deltaTimeL = deltaTleft[goToIndexL];
    deltaTimeL *= 1000;
    
    // define in which mode a step motor currently is
    if (!lock)
    { 
      if (stepper.distanceToGo() == 0)
      {
        if (I % 2 == 0)
        {
          if (I == 2)
          {
            lock = true;
            I = -1;
            tL = millis();
          }
          else
          {
            stepper.moveTo(goToL);
          }
        }
        else
        {
          stepper.moveTo(0);
        }
        
        I++;
      }
    }
    
    // start waiting
    if (lock)
    { 
      if ( (millis() - tL) >= deltaTimeL )
      {
        lock = false;
        goToIndexL++;
      }
    }
    
    // do one step
    else 
    { 
      stepper.run();
    }
  }
  
  // all target positions are handled
  else  { startCut = false; }
}
