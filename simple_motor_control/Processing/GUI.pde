import controlP5.*;

ControlP5 controlP5;

void setupGUI()
{
  controlP5 = new ControlP5(this);
  controlP5.setControlFont(font);
  controlP5.setColorBackground(color(0));
  controlP5.setColorActive(color(255,0,0));
  controlP5.setColorForeground(color(100));
  controlP5.setColorLabel(color(255));
  
  Slider s = controlP5.addSlider("angle", 0, 360, 0, 10, 132, 100, 10);
  s.setId(1);
  Slider s2 = controlP5.addSlider("speed", 5000, 7000, 0, 10, 144, 100, 10); 
  s2.setId(2);
  Slider s3 = controlP5.addSlider("acceleration", 29000, 30000, 0, 10, 156, 100, 10); 
  s3.setId(3);
  
  controlP5.addButton("send", 0, 10, 93, 42, 20);
  
  controlP5.setAutoDraw(false);  
}

void send()
{
  port.write(angle + "d");
  port.write(speed + "s");
  port.write(acceleration + "a");
}

void controlEvent(ControlEvent theEvent)
{  
  switch(theEvent.controller().id())
  {
    case(1):
    angle = (int)theEvent.controller().value();
    break;
    case(2):
    speed = (int)theEvent.controller().value();
    break;
    case(3):
    acceleration = (int)theEvent.controller().value();
    break;
  }  
}

void gui()
{ 
  cam.beginHUD();
  camera();
  controlP5.draw();
  cam.endHUD();  
 }
