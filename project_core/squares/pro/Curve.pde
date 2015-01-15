class Curve
{
  final int nPoints;
  final int n_Points;
  
  final int _height = height - 50;
  final int startPosX;
  final int startPosY = 25;
  
  final int controlPoints;
  
  // control points to draw the curve
  MyPoint[] points;
  int pID = -1;
  
  Curve(int nPointsTemp, int startPosTempX)
  {
    controlPoints = nPointsTemp;
    nPoints = controlPoints * 2 + 1;
    n_Points = nPoints + (controlPoints - 1);
    
    points = new MyPoint[n_Points];
   
    startPosX = startPosTempX;     
    float dBetweenPoints = (float)_height / (nPoints-1);
    
    int j = 1;
    float y;
    for (int i = 1; i < n_Points; i += 3)
    {
      y = startPosY + j * dBetweenPoints;
      points[i] = new MyPoint(startPosX, y, 10, true);
      
      // create neighbours
      y =  startPosY + (j - 1) * dBetweenPoints;
      points[i - 1] = new MyPoint(startPosX, y, 4, false);
      
      y =  startPosY + (j + 1) * dBetweenPoints;
      points[i + 1] = new MyPoint(startPosX, y, 4, false);
      
      j += 2;
    }
  }
  
  int getStartPosX()          { return startPosX; }
  int getControlPoints()      { return controlPoints; }
  
  MyPoint[] getControlData()  { return points; }
  int getControlSize()        { return n_Points; }
  
  boolean allowMove(float x, float y)
  {
    for (int i = 0; i < n_Points; i++)
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
      
      // change neighbour's coordinates as well
      points[pID - 1].setX(points[pID - 1].getX() + xD * smooth);
      points[pID + 1].setX(points[pID + 1].getX() + xD * smooth);
    }
  }
  
  void reset()
  {
    float dBetweenPoints = (float)_height / (nPoints-1);
    
    int j = 1;
    float y;
    for (int i = 1; i < n_Points; i += 3)
    {
      y = startPosY + j * dBetweenPoints;
      points[i].setX(startPosX);
      points[i].setY(y);
      
      // create neighbours
      y =  startPosY + (j - 1) * dBetweenPoints;
      points[i - 1].setX(startPosX);
      points[i - 1].setY(y);
      
      y =  startPosY + (j + 1) * dBetweenPoints;
      points[i + 1].setX(startPosX);
      points[i + 1].setY(y);
      
      j += 2;
    }
  }
}
