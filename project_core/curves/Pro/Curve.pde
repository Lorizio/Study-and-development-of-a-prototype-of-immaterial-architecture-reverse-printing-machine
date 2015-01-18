class Curve
{
  final int nPoints;
  final int _height = height - 50;
  final int startPosX;
  final int startPosY = 25;
  
  final float stepAngle;  // see readme.txt
  final int dataSize;
  final int nPointsProArc;
  
  // counter to shift within the data array toArduino
  // during one draw() cycle
  int j;
  
  // while drawing counter-clockwise curve fragments
  // swapping of elements within toArduino array needed
  // because they are saved in reverse order
  MyPoint[] bufArray;
  
  // control points to draw the curve
  MyPoint[] points;
  
  // id of control point that is being moved
  // currently
  int pID = -1;
  
  // discretization array described in readme.txt
  MyPoint[] toArduino;
  
  // constructor
  Curve(int nPointsTemp, int nPointsProArcTemp, int startPosTempX)
  {
    nPoints = nPointsTemp * 2 + 1;
    points = new MyPoint[nPoints];
   
    startPosX = startPosTempX;
        
    nPointsProArc = nPointsProArcTemp;
    stepAngle = PI/nPointsProArc;
    dataSize = (nPoints / 2) * nPointsProArc + 1;        
    
    // first create control points and their
    // neighbours
    for (int i = 0; i < nPoints; i++)
    {
      float dBetweenPoints = (float)_height / (nPoints-1);
      float y = startPosY + i * dBetweenPoints;
      
      if ( i % 2 != 0)  { points[i] = new MyPoint(startPosX, y, 10, true); }
      else              { points[i] = new MyPoint(startPosX, y, 5, false); }
    }
    
    // create a global set of points which discretize one foam's side
    toArduino = new MyPoint[dataSize];
    
    for (int i = 0; i < dataSize; i++)
    {
      float dBetweenPoints = (float)_height / (dataSize-1);
      float y = startPosY + i * dBetweenPoints;      
      toArduino[i] = new MyPoint(startPosX, y, 2, false);
    }
    
    bufArray = new MyPoint[nPointsProArc + 1];
  }
  
  // getter
  int getStartPosX()          { return startPosX; }
  
  MyPoint[] getControlData()  { return points; }
  int getControlSize()        { return nPoints; }
  
  MyPoint[] getData()         { return toArduino; }
  int getSize()               { return dataSize; }
  
  // Analyze one foam's side,
  // whether a line or half ellipse
  // between two neighbours of any control point
  // should be drawn.
  // This method rewrites toArduino array completely
  // within each draw() cycle
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
  
  // creates one arc
  void drawArc(MyPoint p1, MyPoint p2, MyPoint p3)
  {
    // see readme.txt
    float w = abs(p1.getX() - p2.getX());
    float dBetweenPoints = (float)_height / (nPoints-1);
    float h = dBetweenPoints;
    float xC = p1.getX();
    float yC = p2.getY();
    
    float startAngle, endAngle;
    
    // clockwise arc
    if (p2.getX() > p1.getX())
    {
      startAngle = -PI/2;
      endAngle = PI/2;
    }
    
    // counter-clockwise arc
    else
    {
      startAngle = PI/2;
      endAngle = 3*PI/2;
    }
    
    // see readme.txt
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
  
  /*
    this method returns true
    if a mouse cursor coordinate is in
    local proximity of any control point coordinate
    => dragging phase
    
    this method also sets an ID of control point
    that was chosen to be moved
  */
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
  
  /*
    this method moves a previously chosen
    control point and resets its as well as
    the coordinates of its two neighbours to
    the coordinates of a mouse cursor.
    
    Moving is allowed only in horizontal plane
    thus only X coordinate changes.
  */
  void move(float x)
  {
    float xD = x - points[pID].getX();
    float d = abs(xD);
    
    if (d > 1)
    {
      points[pID].setX(points[pID].getX() + xD * smooth);
    }
  }
  
  // resets one side of the foam to its default view
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
