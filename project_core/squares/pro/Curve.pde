/*
  class Curve represents one side of the foam
*/
class Curve
{
  // to auto scale distance between
  // the points 
  final int nPoints;
  
  // total number of points
  final int n_Points;
  
  final int _height = height - 50;
  final int startPosX;
  final int startPosY = 25;
  
  final int controlPoints;
  
  // array of points that define
  // one side of the foam
  MyPoint[] points;
  
  // index of a control point
  // that is being moved at the moment
  int pID = -1;
  
  // constructor
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
    
    // creating of control points and its two neighbour points
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
  
  // getter
  int getStartPosX()          { return startPosX; }
  int getControlPoints()      { return controlPoints; }
  
  MyPoint[] getControlData()  { return points; }
  int getControlSize()        { return n_Points; }
  
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
      
      // change neighbour's coordinates as well
      points[pID - 1].setX(points[pID - 1].getX() + xD * smooth);
      points[pID + 1].setX(points[pID + 1].getX() + xD * smooth);
    }
  }
  
  // resets one side of the foam to its default view
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
