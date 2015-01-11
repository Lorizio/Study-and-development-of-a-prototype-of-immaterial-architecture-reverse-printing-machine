#include <AccelStepper.h>

const int MICROSTEPS = 8;
const float ONE_FULL_STEP = 1.8;

const int MOTOR_DIR_PIN = 2;
const int MOTOR_STEP_PIN = 3;
const int MS1 = 8;
const int MS2 = 12;
const int MS3 = 13;

int angle = 0;
int speed_ = 0;
int acceleration = 0;
boolean rejectRX = false;
boolean targetSet = false;
AccelStepper stepper(1, MOTOR_STEP_PIN, MOTOR_DIR_PIN);

int v = 0;

void setup()
{
  Serial.begin(9600);

  pinMode(MS1, OUTPUT);
  pinMode(MS2, OUTPUT);
  pinMode(MS3, OUTPUT);
  
  digitalWrite(MS1, HIGH);
  digitalWrite(MS2, HIGH);
  digitalWrite(MS3, LOW); 
}

void loop()
{
   if (rejectRX == false)
   {    
     if(Serial.available())
     {
       char ch = Serial.read();
       switch(ch)
       {
         case '0'...'9':
            v = v * 10 + ch - '0';
            break;
            
         case 'd':
            angle = v;
            v = 0;         
            break;
            
         case 's':
            speed_ = v;
            v = 0;
            stepper.setMaxSpeed(speed_);
            stepper.setSpeed(speed_);
            break;
            
         case 'a':
            acceleration = v;
            v = 0;
            stepper.setAcceleration(acceleration);
            
            // forbid receiving as long as motor has not reached its target
            // position
            rejectRX = true;
            break;
       }
     }
     Serial.flush();
   }
   else
   { 
     // set target
     if (targetSet == false)
     {
       int targetPos = ((float)angle / ONE_FULL_STEP) * MICROSTEPS;
       
       stepper.moveTo(targetPos);
       targetSet = true;
     }
     
     // move
     else
     {
       int actualPos = stepper.distanceToGo();
       if (actualPos == 0)
       {
         // allow receiving once again     
         rejectRX = false;
         
         angle = 0;
         targetSet = false;
       }
       else
       {      
         stepper.run();
       }
     }
   }
}
