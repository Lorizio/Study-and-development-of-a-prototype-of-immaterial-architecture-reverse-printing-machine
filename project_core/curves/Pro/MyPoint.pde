class MyPoint
{
  float x;
  float y;
  int r;
  boolean isControl;
  boolean other;
  
  MyPoint(float xTemp, float yTemp, int rTemp, boolean isControlTemp)
  {
    x = xTemp;
    y = yTemp;
    r = rTemp;
    isControl = isControlTemp;
  }
  
  float getX()              { return x; }
  float getY()              { return y; }
  int getR()                { return r; }
  boolean getIsControl()    { return isControl; }
  
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
