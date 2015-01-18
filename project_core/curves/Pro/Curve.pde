class Curve
{
  final int nPoints;
  final int _height = height - 50;
  final int startPosX;
  final int startPosY = 25;
  
  final float stepAngle;
  final int dataSize;
  final int nPointsProArc;
  
  // counter to shift within the data array toArduino
  // during one draw() cycle
  int j;
  MyPoint[] bufArray;
  
  // control points to draw the curve
  MyPoint[] points;
  int pID = -1;
  
  MyPoint[] toArduino;
  
  Curve(int nPointsTemp, int nPointsProArcTemp, int startPosTempX)
  {
    nPoints = nPointsTemp * 2 + 1;
    points = new MyPoint[nPoints];
   
    startPosX = startPosTempX;
        
    nPointsProArc = nPointsProArcTemp;
    stepAngle = PI/nPointsProArc;
    dataSize = (nPoints / 2) * nPointsProArc + 1;        
    
    for (int i = 0; i < nPoints; i++)
    {
      float dBetweenPoints = (float)_height / (nPoints-1);
      float y = startPosY + i * dBetweenPoints;
      
      if ( i % 2 != 0)  { points[i] = new MyPoint(startPosX, y, 10, true); }
      else              { points[i] = new MyPoint(startPosX, y, 5, false); }
    }
    
    toArduino = new MyPoint[dataSize];
    
    for (int i = 0; i < dataSize; i++)
    {
      float dBetweenPoints = (float)_height / (dataSize-1);
      float y = startPosY + i * dBetweenPoints;      
      toArduino[i] = new MyPoint(startPosX, y, 2, false);
    }
    
    bufArray = new MyPoint[nPointsProArc + 1];
  }
  
  int getStartPosX()          { return startPosX; }
  
  MyPoint[] getControlData()  { return points; }
  int getControlSize()        { return nPoints; }
  
  MyPoint[] getData()         { return toArduino; }
  int getSize()               { return dataSize; }
  
  void draw()
  {        
    j = 0;
    
    int i = 0;
    while (i < nPoints)
    {
      MyPoint p1 = points[i];
      MyPoint p2;
      
      if ( (i+1) < nPoints )  { p2 = points[i+1]; }
      else                    {  break; }
      
      // draw curve
      if (p2.getX() != p1.getX())
      {
        MyPoint p3 = points[i+2];
        drawArc(p1, p2, p3);
        
        i += 2;
      }
      
      // draw line
      else
      {
        j += nPointsProArc / 2;
        i++;
      }
    }       
  }
  
  void drawArc(MyPoint p1, MyPoint p2, MyPoint p3)
  {
    float w = abs(p1.getX() - p2.getX());
    float dBetweenPoints = (float)_height / (nPoints-1);
    float h = dBetweenPoints;
    float xC = p1.getX();
    float yC = p2.getY();
    
    float startAngle, endAngle;
    
    if (p2.getX() > p1.getX())
    {
      startAngle = -PI/2;
      endAngle = PI/2;
    }
    else
    {
      startAngle = PI/2;
      endAngle = 3*PI/2;
    }
    
    for (float angle = startAngle; angle <= endAngle; angle += stepAngle)
    {
      float x = xC + w * cos(angle);
      float y = yC + h * sin(angle);
           
      toArduino[j].setX(x);
      toArduino[j].setY(y);      
      
      j++;
    }
    
    j--;
    
    // swap the values
    if (p2.getX() < p1.getX())
    { 
      int k = 0;

      for (int i = j - nPointsProArc; i <= j; i++)
      {
        MyPoint pTmp = toArduino[i];
        bufArray[nPointsProArc - k] = pTmp;
        k++;
      }
      
      k = 0;

      for (int i = j - nPointsProArc; i <= j; i++)
      {
        MyPoint pTmp = bufArray[k];
        toArduino[i] = pTmp;
        k++;
      }      
    }
  }
  
  boolean allowMove(float x, float y)
  {
    for (int i = 0; i < nPoints; i++)
    {
      float d = sqrt((x-points[i].getX())*(x-points[i].getX())+(y-points[i].getY())*(y-points[i].getY()));
      
      if (d <= points[i].getR() && points[i].getIsControl() == true)
      {
        pID = i;        
        return true;        
      }
    }
    return false;
  }
  
  void move(float x)
  {
    float xD = x - points[pID].getX();
    float d = abs(xD);
    
    if (d > 1)
    {
      points[pID].setX(points[pID].getX() + xD * smooth);
    }
  }
  
  void reset()
  {
    for (int i = 0; i < nPoints; i++)
    {
      float dBetweenPoints = (float)_height / (nPoints-1);
      float y = startPosY + i * dBetweenPoints;
      points[i].setX(startPosX);
      points[i].setY(y);
    }
    
    for (int i = 0; i < dataSize; i++)
    {
      float dBetweenPoints = (float)_height / (dataSize-1);
      float y = startPosY + i * dBetweenPoints;      
      toArduino[i].setX(startPosX);
      toArduino[i].setY(y);
    }
  }
}
