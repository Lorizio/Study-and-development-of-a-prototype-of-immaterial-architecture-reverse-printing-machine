/*
  class MyPoint represents user-defined
  point
*/
class MyPoint
{
  float x;            // x coordinate
  float y;            // y coordinate
  int r;              // radius
  boolean isControl;  // whether a point is a control one
  
  MyPoint(float xTemp, float yTemp, int rTemp, boolean isControlTemp)
  {
    x = xTemp;
    y = yTemp;
    r = rTemp;
    isControl = isControlTemp;
  }
  
  // getter
  float getX()              { return x; }
  float getY()              { return y; }
  int getR()                { return r; }
  boolean getIsControl()    { return isControl; }
  
  // setter
  void setX(float xTemp)  { x = xTemp; }
  void setY(float yTemp)  { y = yTemp; }
  
  void draw()
  {
    curvesControl.noStroke();
    
    if (isControl == true)
    { 
      curvesControl.fill(0, 0, 255); 
    }
    else              
    {
      curvesControl.fill(0); 
    }
   
    curvesControl.ellipse(x, y, r, r);
  }
}
