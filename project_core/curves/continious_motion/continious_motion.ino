#include <AccelStepper.h>

#define ONE_FULL_STEP 1.8
#define MICROSTEPS 16

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

#define WAIT 254
#define END 255

#define FOAM_TIME 148  // adjustable

#define SPEED 800
#define BASE_ACCEL 110

#define N 21
#define N2 3000
//#define N2 1800

AccelStepper stepper(1, MOTOR_STEP_PIN, MOTOR_DIR_PIN);
AccelStepper stepper2(1, MOTOR2_STEP_PIN, MOTOR2_DIR_PIN);

byte goToRight[N];
byte goToLeft[N];
//unsigned int goToRight[N];
//unsigned int goToLeft[N];

int v = 0;
int counter = 0;
int counter2 = 0;

boolean rcvd = false;

int targetPos;
int targetPos2;

int posId = -1;
int posId2 = -1;

boolean stop_;
boolean stop2;

byte iMediate[N2];
byte iMediate2[N2];
//unsigned int iMediate[N2];
//unsigned int iMediate2[N2];

unsigned int waitTime;
unsigned int waitTime2;
unsigned int time;
unsigned int time2;

// first receive right curve
boolean rightCurve = true;

void setup()
{
  Serial.begin(9600);
  
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
  
  waitTime = FOAM_TIME / (counter - 1);
  waitTime *= 1000;
  
  waitTime2 = FOAM_TIME / (counter2 - 1);
  waitTime2 *= 1000;
  
  // fill rest of array with some id
  for (int i = counter; i < N; i++)   { goToRight[i] = END; }
  for (int i = counter2; i < N; i++)  { goToLeft[i] = END; }
  
  // set acceleration depending on
  // the number of potential curves
  int curves = (counter - 1) / 2;
  int curves2 = (counter2 - 1) / 2;
  
  double power = log(curves) / log(2);
  double power2 = log(curves2) / log(2);
  
  double accel = BASE_ACCEL * pow(2, (power * 2));
  double accel2 = BASE_ACCEL * pow(2, (power2 * 2));
  
  stepper.setMaxSpeed(SPEED);
  stepper2.setMaxSpeed(SPEED);
  stepper.setAcceleration(accel);
  stepper2.setAcceleration(accel2);
  
  pinMode(MS1, OUTPUT);
  pinMode(MS2, OUTPUT);
  pinMode(MS3, OUTPUT);
  
  pinMode(MS4, OUTPUT);
  pinMode(MS5, OUTPUT);
  pinMode(MS6, OUTPUT);
  
  digitalWrite(MS1, HIGH);
  digitalWrite(MS2, HIGH);
  digitalWrite(MS3, HIGH);
  
  digitalWrite(MS4, HIGH);
  digitalWrite(MS5, HIGH);
  digitalWrite(MS6, HIGH);
  
  // fill the goToRight array with intermediate positions
  // in order to smooth the acceleration and make
  // it not notable -> new array iMediate
  
  //int k = 0;
  //for (k = 0; k <= goToRight[0]; k++) { iMediate[k] = k; }
  
  iMediate[0] = goToRight[0];
  int k = 1;
  
  for (int i = 1; i < N; i++)
  {
    if (goToRight[i] == END)  { break; }
    
    if (goToRight[i] > goToRight[i-1])
    {
      for (int j = goToRight[i-1]; j <= goToRight[i]; j++)
      {
        iMediate[k] = j;
        //Serial.println(iMediate[k]);
        k++;
      }
    }
    else if (goToRight[i] < goToRight[i-1])
    {
      for (int j = goToRight[i-1]; j >= goToRight[i]; j--)
      {
        iMediate[k] = j;
        //Serial.println(iMediate[k]);
        k++;
      }
    }
    else
    {
      iMediate[k] = WAIT;
      //Serial.println(iMediate[k]);
      k++;
    }
  }
  
  // fill rest of array with some id
  for (int i = k; i < N2; i++) { iMediate[k] = END; }
    
  //-----------------------------------------------------------------
  
  //for (k = 0; k <= goToLeft[0]; k++) { iMediate2[k] = k; }
  
  iMediate2[0] = goToLeft[0];
  k = 1;
  
  for (int i = 1; i < N; i++)
  {
    if (goToLeft[i] == END)  { break; }
    
    if (goToLeft[i] > goToLeft[i-1])
    {
      for (int j = goToLeft[i-1]; j <= goToLeft[i]; j++)
      {
        iMediate2[k] = j;
        //Serial.println(iMediate[k]);
        k++;
      }
    }
    else if (goToLeft[i] < goToLeft[i-1])
    {
      for (int j = goToLeft[i-1]; j >= goToLeft[i]; j--)
      {
        iMediate2[k] = j;
        //Serial.println(iMediate[k]);
        k++;
      }
    }
    else
    {
      iMediate2[k] = WAIT;
      //Serial.println(iMediate[k]);
      k++;
    }
  }
  
  // fill rest of array with some id
  for (int i = k; i < N2; i++) { iMediate2[k] = END; }
}

void loop()
{ 
  if (stepper.distanceToGo() == 0)
  {
    if (iMediate[posId + 1] != END && iMediate[posId + 1] != WAIT)
    {
      stop_ = false;
      posId++;
      targetPos = ((float)iMediate[posId] / ONE_FULL_STEP) * MICROSTEPS;
      stepper.moveTo(targetPos);
      
      //Serial.println(iMediate[posId]);
    }
    else if (iMediate[posId + 1] == WAIT)  
    { 
      // idle
      stop_ = true;
      time = millis();
      while ( (millis() - time) <= waitTime)  { ; }
      
      posId++;
    }
    else  { stop_ = true; }
  }
  
  //-------------------------------------------------------------------
  
  if (stepper2.distanceToGo() == 0)
  {
    if (iMediate2[posId2 + 1] != END && iMediate2[posId2 + 1] != WAIT)
    {
      stop2 = false;
      posId2++;
      targetPos2 = ((float)iMediate2[posId2] / ONE_FULL_STEP) * MICROSTEPS;
      stepper2.moveTo(targetPos2);
    }
    else if (iMediate2[posId2 + 1] == WAIT)  
    { 
      // idle
      stop2 = true;
      time2 = millis();
      while ( (millis() - time2) <= waitTime2)  { ; }
      
      posId2++;
    }
    else  { stop2 = true; }
  }
  
  if (!stop_)  { stepper.run(); }
  if (!stop2)  { stepper2.run(); }
}
