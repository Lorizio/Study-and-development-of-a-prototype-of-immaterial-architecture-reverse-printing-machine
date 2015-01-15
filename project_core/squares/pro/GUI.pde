import controlP5.*;

ControlP5 controlP5;

Button bConstructCurve, bCutCurve;
Button bInitSim, bStartSim, bStopSim;
RadioButton r;
Textfield tControlL, tControlR;

void setupGUI()
{
  controlP5 = new ControlP5(this);
  controlP5.setControlFont(font);
  controlP5.setColorBackground(color(0));
  controlP5.setColorActive(color(0, 0, 255));
  controlP5.setColorForeground(color(100));
  controlP5.setColorLabel(color(255));
     
  bConstructCurve = controlP5.addButton("construct", 0, 100, 200, 70, 20);
  bCutCurve = controlP5.addButton("cut", 0, 100, 230, 70, 20);
  
  bInitSim = controlP5.addButton("init_sim", 0, 100, 400, 70, 20);
  bStartSim = controlP5.addButton("start_sim", 0, 100, 430, 70, 20);
  bStopSim = controlP5.addButton("stop_sim", 0, 100, 460, 70, 20);
  
  r = controlP5.addRadioButton("soap")
       .setPosition(200, 400)
       .setSize(30,20)
       .setColorForeground(color(100))
       .setColorActive(color(0, 0, 255))
       .setColorLabel(color(0))
       .setItemsPerRow(1)
       .setSpacingColumn(50)
       .addItem("Soap ON", 1)
       .addItem("Soap OFF", 2);
       
  tControlL = controlP5.addTextfield("left control points")
     .setPosition(100, 110)
     .setSize(40,20)
     .setFont(font)
     .setFocus(false)
     .setColor(255)
     .setColorLabel(color(0))
     .setText("4");
     
  tControlR = controlP5.addTextfield("right control points")
     .setPosition(100, 150)
     .setSize(40,20)
     .setFont(font)
     .setFocus(false)
     .setColor(255)
     .setColorLabel(color(0))
     .setText("4");
}

void controlEvent(ControlEvent event)
{
                  // cut
  
  if (event.name().equals("construct"))
  {
    int controlL = parseInt(tControlL.getText());
    int controlR = parseInt(tControlR.getText());
    
    rightCurve = new Curve(controlR, curvesControl.width/2 + curvesControl.width/4);
    leftCurve = new Curve(controlL, curvesControl.width/2 - curvesControl.width/4);
    
    curvesConstructed = true;
  }
  
  else if (event.name().equals("cut"))
  {    
                    // right curve
    
    MyPoint[] rightData = rightCurve.getControlData();
    int n1 = rightCurve.getControlSize();
    
    int j = 0;
    for (int i = 0; i < n1; i++)
    {
      MyPoint p = rightData[i];
      if (p.getIsControl())
      {
        j++;
        float x = p.getX();
        
        float tmp = rightCurve.getStartPosX() - x;
        int toSend = (int)(tmp / delta * dInDegree);
        
        //println((i+1) + " point: " + toSend + " degrees");
        
        if (j < rightCurve.getControlPoints())  { port.write(toSend + ","); }
        else                                    { port.write(toSend + ";"); }
      }
    }
    
    //println("------------------------------------------------");
    
                    // left curve
                    
    MyPoint[] leftData = leftCurve.getControlData();
    int n2 = leftCurve.getControlSize();
    
    j = 0;
    for (int i = 0; i < n2; i++)
    {
      MyPoint p = leftData[i];
      if (p.getIsControl())
      {
        j++;
        float x = p.getX();
        
        float tmp = x - leftCurve.getStartPosX();
        int toSend = (int)(tmp / delta * dInDegree);
        
        //println((i+1) + " point: " + toSend + " degrees");
        
        if (j < leftCurve.getControlPoints())  { port.write(toSend + ","); }
        else                                   { port.write(toSend + "."); }
      }
    }
  }
  
                          // foam
                       
  else if (event.name().equals("soap"))
  { 
    if (r.getState(0))        { port2.write(1 + "s"); }
    else if (r.getState(1))   { port2.write(0 + "s"); }
  }
  else if (event.name().equals("init_sim"))
  { 
    port2.write("i");
  }
  else if (event.name().equals("start_sim"))
  {
    port2.write("g");
  }
  else if (event.name().equals("stop_sim"))
  {
    port2.write("q");
  }  
}

void serialEvent(Serial p)
{
  String msg = port.readStringUntil('\n');
  if (msg != null)
  {
    print(msg);
  }
}

