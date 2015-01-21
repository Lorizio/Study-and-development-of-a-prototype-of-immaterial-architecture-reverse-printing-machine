// initialize time
#define TWO_MINS 120000

#define AIR_PIN 6
#define HELIUM_PIN 5
#define SOAP_PIN 2

// stop simulation
boolean stop_;

unsigned int v;

// turn on/off soap
boolean soap;

// initialize phase is active
boolean init1;

// start measureing time
unsigned long time;

int countHelium = 0;
int heliumSpeed = 0;
int heliumValue = 0;
int airValue = 0;

// controls the maximum height of the foam
int generation = 0;

boolean process = false;
int timeOfHelium = 190;
int timeOfAir = 350;

void setup()
{
  Serial.begin(9600);
  
  // pins configuration
  pinMode(AIR_PIN, OUTPUT);
  pinMode(HELIUM_PIN, OUTPUT);
  pinMode(SOAP_PIN, OUTPUT);
  
  analogWrite(AIR_PIN, 0);
  analogWrite(HELIUM_PIN, 0);
  
  // for soap in should be inverted
  digitalWrite(SOAP_PIN, HIGH);
  
  // init vars
  stop_ = true;
  v = 0;
  soap = false;
  init1 = false;
}

void loop()
{
  // read the message
  if (Serial.available())
  {
    char ch = Serial.read();
    switch(ch)
    {  
      // initialize phase active
      case 'i':
        init1 = true;
        stop_ = false;
        time = millis();
        break;
        
      // start simulation
      case 'g':
        stop_ = false;
        break;
        
      // turn on/off soap    
      case 's':  
        if (v == 1)              { soap = true; }
        else if (v == 0)         { soap = false; }
        
        v = 0;
        break;
      
      // stop initialize phase/simulation
      case 'q':
        stop_ = true;
        init1 = false;
        break;
        
      case '0'...'9':
        v = v * 10 + ch - '0';
        break;
     }
     
     Serial.flush();
  }
  
  // initialize pahse active
  // keep injecting air and helium
  // during two minutes using almost max
  // values
  if (init1)
  {
    if (millis() - time <= TWO_MINS)
    {
      analogWrite(AIR_PIN, 240);
      analogWrite(HELIUM_PIN, 240);
    }
    
    // after two minutes stop injecting them
    // initialize phase is over
    else
    {
      analogWrite(AIR_PIN, 0);
      analogWrite(HELIUM_PIN, 0);
      init1 = false;
      stop_ = true;
    }
    
    // min necessary delay for PWM pins
    delay(3);
  }
  
  // turn on/off soap
  if (soap)  { digitalWrite(SOAP_PIN, LOW); }
  else       { digitalWrite(SOAP_PIN, HIGH); }
  
  // if stop everything flag is true
  // turn off everything
  if (stop_)
  { 
    analogWrite(AIR_PIN, 0);
    analogWrite(HELIUM_PIN, 0);
  }
  
  // start the simulation
  else if (!init1)
  { 
     //initial process
    if(process == false)
    {
      if(countHelium < 145)
      {
        heliumValue = 165;
      }
      else
      {
        countHelium = 0;
        airValue = 0;
        heliumValue = 0;
        process = true;
        heliumSpeed = 1;
      }
  
      analogWrite(HELIUM_PIN, heliumValue);
      analogWrite(AIR_PIN, airValue);
    }
  
    //simulation process
    if(process == true)
    { 
      //control the number of time to produce the foam
      if (generation <= 8)
      {
        // first mode (see readme)
        if(countHelium < timeOfHelium)
        { 
          heliumValue = 208 + heliumSpeed ; 
          airValue = 0;
        }
        
        // second mode
        if(countHelium >= timeOfHelium && countHelium < timeOfHelium + timeOfAir)
        {
          heliumValue = 0;
          airValue = 220;
        } 
  
        // third mode -> value corrections
        if(countHelium >= timeOfHelium + timeOfAir)
        {
          if(generation%2 == 0)
          {
            timeOfHelium = timeOfHelium-35; 
            timeOfAir = timeOfAir-10;
            heliumSpeed = heliumSpeed-4;
          }       
          // here depends on condition this value can be increased...
          // increase -> higher
          // 80 is min
          if(timeOfHelium < 110)
          {          
            timeOfHelium = 110;
          }
          airValue = 0;
          heliumValue = 0;      
          countHelium = -1;
          generation++;      
        }
        
        analogWrite(HELIUM_PIN, heliumValue);
        analogWrite(AIR_PIN, airValue);   
      }
      
      // foam has reached its maximum height
      // stop simulation
      else
      {
        analogWrite(HELIUM_PIN, 0);
        analogWrite(AIR_PIN, 0);
      }
    }
    
    countHelium++;
  }
  
  delay(50);
}
