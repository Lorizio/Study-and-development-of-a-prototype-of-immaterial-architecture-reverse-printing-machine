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
  
  Slider s = controlP5.addSlider("Air PWM", 0, 255, 0, 10, 132, 100, 10);
  
  controlP5.addButton("send", 0, 10, 93, 42, 20);
  
  controlP5.setAutoDraw(false);  
}

// send to Arduino
void send()
{
  port.write(air + "a");
}

// is invoked each time we move the slider
void controlEvent(ControlEvent theEvent)
{  
    air = (int)theEvent.controller().value();
}

void gui()
{ 
  cam.beginHUD();
  camera();
  controlP5.draw();
  cam.endHUD();  
}
