import processing.serial.*; 

// right screen (canvas)
PGraphics curvesControl;

// regulates how fast is control point
// approached to a mouse cursor while moving it
final float smooth = 0.5;

// maximum allowed distance in pixels
// to move a point from its origin
final int delta = 90;

// max allowed distance in degrees
// for step motors to move
final int dInDegree = 225;

// left side of the foam
Curve leftCurve = null;

// right side
Curve rightCurve = null;

// defines which side
// of the foam is being transformed at the moment
// for example is one any control point on the left side
// is being moved, then touched = 1
int touched = -1;

// as long as button construct in GUI has not been
// clicked, this parameter is false
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
    
    // draw the foam sculpture: two sides
    if (curvesConstructed)
    {
      MyPoint[] controlL = leftCurve.getControlData();
      MyPoint[] controlR = rightCurve.getControlData();
      int lControlSize = leftCurve.getControlSize();
      int rControlSize = rightCurve.getControlSize();
    
      curvesControl.stroke(color(0, 0, 255));
      
      // draw left side
      for (int i = 0; i < lControlSize - 1; i++)
      {
        MyPoint p1 = controlL[i];
        MyPoint p2 = controlL[i+1];
        
        curvesControl.line(p1.getX(), p1.getY(), p2.getX(), p2.getY());
      }
      
      // draw right side
      for (int i = 0; i < rControlSize - 1; i++)
      {
        MyPoint p1 = controlR[i];
        MyPoint p2 = controlR[i+1];
        
        curvesControl.line(p1.getX(), p1.getY(), p2.getX(), p2.getY());
      }
    
      // draw control points on the top
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
  // resets two sides to its default view
  if (mouseButton == RIGHT)
  {
    leftCurve.reset();
    rightCurve.reset();
  }
  
  else
  {
    // drop point
    if (touched == 1 || touched == 2)  
    {         
      touched = -1;  
    }
    
    // drag point
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
