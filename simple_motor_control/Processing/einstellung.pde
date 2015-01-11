import controlP5.*;

ControlP5 controlP5;
RadioButton r;
Slider s1, s2, s3;

void setupGUI()
{
  controlP5 = new ControlP5(this);
  controlP5.setControlFont(font);
  controlP5.setColorBackground(color(0));
  controlP5.setColorActive(color(255,0,0));
  controlP5.setColorForeground(color(100));
  controlP5.setColorLabel(color(255));
  
  s1 = controlP5.addSlider("angle", 0, 3600, 0, 10, 132, 100, 10);
  s2 = controlP5.addSlider("speed", 5000, 7000, 0, 10, 144, 100, 10); 
  s3 = controlP5.addSlider("acceleration", 29000, 30000, 0, 10, 156, 100, 10); 
  
  controlP5.addButton("send", 0, 10, 93, 42, 20);
  
  r = controlP5.addRadioButton("radioButton")
       .setPosition(100,300)
       .setSize(40,20)
       .setColorForeground(color(120))
       .setColorActive(color(255))
       .setColorLabel(color(255))
       .setItemsPerRow(5)
       .setSpacingColumn(30)
       .addItem("16x",1)
       .addItem("8x", 2)
       .addItem("4x", 3)
       .addItem("2x", 4)
       .addItem("1x", 5);
    
    controlP5.setAutoDraw(false); 
}

void send()
{
  angle = (int)s1.getValue();
  speed = (int)s2.getValue();
  acceleration = (int)s3.getValue();
  
  if       (r.getState(0))  microStepping = 16;
  else if  (r.getState(1))  microStepping = 8;
  else if  (r.getState(2))  microStepping = 4;
  else if  (r.getState(3))  microStepping = 2;
  else if  (r.getState(4))  microStepping = 1;
  
 
  port.write(angle + "d");          // d - degree (angle) 
  port.write(speed + "s");          // s - speed
  port.write(acceleration + "a");   // a - acceleration 
  port.write(microStepping + "m");  // m - microstepping

}

void keyPressed() {
  switch(key) {
    case('1'): r.activate(0); break;
    case('2'): r.activate(1); break;
    case('3'): r.activate(2); break;
    case('4'): r.activate(3); break;
    case('5'): r.activate(4); break;
  }
}

void gui()
{ 
  cam.beginHUD();
  camera();
  controlP5.draw();
  cam.endHUD();  
}
