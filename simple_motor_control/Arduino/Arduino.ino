#include <AccelStepper.h>

#define ONE_FULL_STEP 1.8

// PINs definition
#define MOTOR_DIR_PIN  13
#define MOTOR_STEP_PIN 12
#define MS1 4
#define MS2 7
#define MS3 8

// vars
int angle = 0;
int speed_ = 0;
int acceleration = 0;
int microStepping = 16;

// other vars
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
            break;
            
         case 'm':
              microStepping = v;
              if (microStepping == 16)
              {
                digitalWrite(MS1, HIGH);
                digitalWrite(MS2, HIGH);
                digitalWrite(MS3, HIGH);
              }
              else if (microStepping == 8)
              {
                digitalWrite(MS1, HIGH);
                digitalWrite(MS2, HIGH);
                digitalWrite(MS3, LOW);
              }
              else if (microStepping == 4)
              {
                digitalWrite(MS1, LOW);
                digitalWrite(MS2, HIGH);
                digitalWrite(MS3, LOW);
              }
              else if (microStepping == 2)
              {
                digitalWrite(MS1, HIGH);
                digitalWrite(MS2, LOW);
                digitalWrite(MS3, LOW);
              }
              else
              {
                digitalWrite(MS1, LOW);
                digitalWrite(MS2, LOW);
                digitalWrite(MS3, LOW);
              }
              
              v = 0;
              rejectRX = true;
              break;
       }
     }
     Serial.flush();
   }
   else
   { 
     if (targetSet == false)
     {
       int targetPos = ((float)angle / ONE_FULL_STEP) * microStepping;
       stepper.moveTo(targetPos);
       targetSet = true;
     }
     else
     {
       int actualPos = stepper.distanceToGo();
       if (actualPos == 0)
       {
         rejectRX = false;
         targetSet = false;
       }
       else
       { 
         // Run the motor 
         stepper.run();
       }
     }
   }
}
