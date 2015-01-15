#define TWO_MINS 120000

#define AIR_PIN 6
#define HELIUM_PIN 5
#define SOAP_PIN 2

boolean stop_;
unsigned int v;
boolean soap;
boolean init1;
boolean init2done;
unsigned long time;

int countHelium = 0;
int heliumSpeed = 0;
int heliumValue = 0;
int airValue = 0;
int generation = 0;
boolean process = false;
int timeOfHelium = 190;
int timeOfAir = 350;

void setup()
{
  Serial.begin(9600);
  
  pinMode(AIR_PIN, OUTPUT);
  pinMode(HELIUM_PIN, OUTPUT);
  pinMode(SOAP_PIN, OUTPUT);
  
  analogWrite(AIR_PIN, 0);
  analogWrite(HELIUM_PIN, 0);
  digitalWrite(SOAP_PIN, HIGH);
  
  stop_ = true;
  v = 0;
  soap = false;
  init1 = false;
  init2done = false;
 
}

void loop()
{
  // read the message
  if (Serial.available())
  {
    char ch = Serial.read();
    switch(ch)
    {  
      case 'i':
        init1 = true;
        stop_ = false;
        time = millis();
        break;
        
      case 'g':
        stop_ = false;
        break;
            
      case 's':  
        if (v == 1)              { soap = true; }
        else if (v == 0)         { soap = false; }
        
        v = 0;
        break;
      
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
  
  if (init1)
  {
    if (millis() - time <= TWO_MINS)
    {
      analogWrite(AIR_PIN, 240);
      //analogWrite(HELIUM_PIN, 240);
    }
    else
    {
      analogWrite(AIR_PIN, 0);
      analogWrite(HELIUM_PIN, 0);
      init1 = false;
      stop_ = true;
    }
    delay(3);
  }
  
    if (soap)  { digitalWrite(SOAP_PIN, LOW); }
    else       { digitalWrite(SOAP_PIN, HIGH); }
  
  if (stop_)
  { 
    analogWrite(AIR_PIN, 0);
    analogWrite(HELIUM_PIN, 0);
  }
  
  // start the simulation
  else if (!init1)
  { 
      //initial process
    if(process == false){
      //it shift..this need to be reduced
      if(countHelium < 145){
  
        heliumValue = 165;
        //airValue = 190;  
      }
      else{
  
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
    if(process == true){ //control the number of time to produce the foam
  
      if (generation <= 8){
  
        if(countHelium < timeOfHelium){ 
  
          heliumValue = 208 + heliumSpeed ; 
          airValue = 0;
        }
        
        if(countHelium >= timeOfHelium && countHelium < timeOfHelium + timeOfAir){
  
          heliumValue = 0;
          airValue = 220;
        } 
  
        if(countHelium >= timeOfHelium + timeOfAir){
  
          if(generation%2 == 0){
            timeOfHelium = timeOfHelium-35; 
            timeOfAir = timeOfAir-10;
            heliumSpeed = heliumSpeed-4;
          }       
          // here depends on condition this value can be increased...
          // increase -> higher
          // 80 is min
          if(timeOfHelium < 110){          
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
