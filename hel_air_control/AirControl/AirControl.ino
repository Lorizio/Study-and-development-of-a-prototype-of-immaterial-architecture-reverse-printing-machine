// adjustable, depends on the scheme
#define basePin 9

// accumulated received value via serial connection
int v = 0;
int air = 0;

// if accumulated value is received, start injecting
boolean execute = true;

void setup()
{
  // activate serial port
  Serial.begin(9600);
  
  pinMode(basePin, OUTPUT);
}

void loop()
{
  // byte received
  if (Serial.available())
  {
    // forbid the injection until not received everything
    execute = false;
    
    char ch = Serial.read();
    switch(ch)
    {
      case '0'...'9':
            v = v * 10 + ch - '0';
            break;
      case 'a':
            air = v;
            v = 0;
            
            // last symbol has come thus accept injection
            execute = true;
            break;
    }
  }
  Serial.flush();
  
  // inject the air
  if (execute)
  {
    analogWrite(basePin, air);
    delay(3);
  }
}
