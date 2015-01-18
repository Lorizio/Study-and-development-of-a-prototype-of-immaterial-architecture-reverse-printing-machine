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
int I = 0;
boolean lock = false;
int goToL, deltaTimeL;

unsigned long tL = 0;

AccelStepper stepper(1, MOTOR_STEP_PIN, MOTOR_DIR_PIN);
int goToLeft[MAX_SIZE];
int deltaTleft[MAX_SIZE - 1];

int v = 0;
int counter = 0;

boolean goToLeftThere = false;
boolean startCut = false;

void  setup()
{
  Serial.begin(9600);
  
  pinMode(MS1, OUTPUT);
  pinMode(MS2, OUTPUT);
  pinMode(MS3, OUTPUT);
  
  digitalWrite(MS1, LOW);
  digitalWrite(MS2, HIGH);
  digitalWrite(MS3, LOW);
  
  stepper.setMaxSpeed(SPEED);
  stepper.setSpeed(SPEED);
  stepper.setAcceleration(ACCELERATION);
}

void loop()
{
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
  
  if (startCut && goToIndexL < MAX_SIZE)
  { 
    goToL = goToLeft[goToIndexL];
    goToL = ((float)goToL / ONE_FULL_STEP) * MICRO;
    deltaTimeL = deltaTleft[goToIndexL];
    deltaTimeL *= 1000;
    
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
            
            int tosend = goToIndexL+1; 
            Serial.println(tosend);
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
    
    if (lock)
    { 
      if ( (millis() - tL) >= deltaTimeL )
      {
        lock = false;
        goToIndexL++;
      }
    }
    else 
    { 
      stepper.run();
    }
  }
  else  { startCut = false; }
}
