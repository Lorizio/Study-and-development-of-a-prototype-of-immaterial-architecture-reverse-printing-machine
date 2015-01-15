import processing.serial.*; 

PGraphics curvesControl;

final float smooth = 0.5;
final int delta = 90;

final int dInDegree = 225;

Curve leftCurve = null;
Curve rightCurve = null;

int touched = -1;
boolean curvesConstructed = false;

PFont font;

Serial port;    // cut
Serial port2;   // foam

void setup()
{
  size(1000, 600);
  font = loadFont("Arial-BoldMT-10.vlw");
  
  curvesControl = createGraphics(width/2, height);
   
  println(Serial.list());
  port = new Serial(this, Serial.list()[1], 9600);
  port2 = new Serial(this, Serial.list()[0], 9600);
  
  setupGUI();
}

void draw()
{
  background(255);
  
  curvesControl.beginDraw();
  {
    curvesControl.background(255);
    
    if (curvesConstructed)
    {
      MyPoint[] controlL = leftCurve.getControlData();
      MyPoint[] controlR = rightCurve.getControlData();
      int lControlSize = leftCurve.getControlSize();
      int rControlSize = rightCurve.getControlSize();
    
      curvesControl.stroke(color(0, 0, 255));
      
      for (int i = 0; i < lControlSize - 1; i++)
      {
        MyPoint p1 = controlL[i];
        MyPoint p2 = controlL[i+1];
        
        curvesControl.line(p1.getX(), p1.getY(), p2.getX(), p2.getY());
      }
      
      for (int i = 0; i < rControlSize - 1; i++)
      {
        MyPoint p1 = controlR[i];
        MyPoint p2 = controlR[i+1];
        
        curvesControl.line(p1.getX(), p1.getY(), p2.getX(), p2.getY());
      }
    
      for (int i = 0; i < lControlSize; i++)    { controlL[i].draw(); }      
      for (int i = 0; i < rControlSize; i++)    { controlR[i].draw(); }
    }    
  }
  curvesControl.endDraw();
  
  image(curvesControl, width/2, 0);
}

// which point should be moved...
void mousePressed()
{ 
  if (mouseButton == RIGHT)
  {
    leftCurve.reset();
    rightCurve.reset();
  }
  
  else
  {
    if (touched == 1 || touched == 2)  
    {         
      touched = -1;  
    }
    
    else if (curvesConstructed)
    { 
      if (leftCurve.allowMove(mouseX - width/2, mouseY))        { touched = 1; }
      else if (rightCurve.allowMove(mouseX - width/2, mouseY))  { touched = 2; }
    }
  }
}

// smoothly move the chosen point to the desired position
void mouseMoved()
{
  if (touched != -1)
  {
    if (touched == 1)
    {
       if ( mouseX <= (width/2 + leftCurve.getStartPosX() + delta)
           && mouseX >= (width/2 + leftCurve.getStartPosX()) )
       {
         leftCurve.move(mouseX - width/2);
       } 
    }
    else
    { 
      if ( mouseX >= (width/2 + rightCurve.getStartPosX() - delta)
          && mouseX <= (width/2 + rightCurve.getStartPosX()) )
      {
        rightCurve.move(mouseX - width/2); 
      }
    }
  }
}
