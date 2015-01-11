import processing.serial.*;
import peasy.*; 

PeasyCam cam;
PFont font;
int angle = 0;
int speed = 0;
int acceleration = 0;
Serial port;

void setup()
{
  size(300,300,P3D);
  font = loadFont("Arial-BoldMT-10.vlw");
  
  //sketch to the desired serial port.
  println(Serial.list());
  port = new Serial(this, Serial.list()[0], 9600);
  
  cam = new PeasyCam(this, 300);
  setupGUI();
}

void draw() 
{
  background(190);
  gui();
}

// for debugging
void serialEvent(Serial p)
{
  String msg = port.readStringUntil('\n');
  if (msg != null)
  {
    print(msg);
  }
}
