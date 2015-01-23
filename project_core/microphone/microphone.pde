import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.serial.*; 

// max allowed angle to move
final float maxDegrees = 180;

// if volume it too high this
// parameter will limit its height
final float delta = 100;

// to make a result of FFT more or less
// visible
final float scale = 4;

PFont font;

// 2nd screen
PGraphics micro;

Serial port;

// micro object
Minim minim;

// input signal
AudioInput in;

// fast Fourier transformation object
FFT fft;

ControlP5 controlP5;
Button bCapture, bCancel, bSend;

// width of one frequency band
int w;

// two frequency spectrum arrays which 
// contain the vloume values for each
// frequency band from two audio channels
float[] lCurve, rCurve;

// feed-back from Arduino
float[] rCurveProgress;

// start X positions
float leftX, rightX;

// capture the current fft result
boolean isCaptured = false;
boolean isSent = false;

// feed-back information from Arduino
// how many square features have already been
// handled
int counter = 0;

void setup()
{
  size(1000, 700);
  minim = new Minim(this);
  
  // get an audio input using stereo sound and buffer size 1024
  in = minim.getLineIn(Minim.STEREO, 1024);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  
  // fft result will be logarithmic scaled
  // because in this way our ear perceives the sound
  fft.logAverages(60, 7);
  
  // define a width of one frequency band to completely
  // fill the screen with FFT result
  w = height/fft.avgSize();
  font = loadFont("Arial-BoldMT-10.vlw");
  micro = createGraphics(width - 300, height);
  setupGUI();
  
  lCurve = new float[fft.avgSize()];
  rCurve = new float[fft.avgSize()];
  
  leftX = micro.width/2 - micro.width/4;
  rightX = micro.width/2 + micro.width/4;
  
  rCurveProgress = new float[fft.avgSize()];
  
  println(Serial.list());
  port = new Serial(this, Serial.list()[0], 9600);
}

void setupGUI()
{
  controlP5 = new ControlP5(this);
  controlP5.setControlFont(font);
  controlP5.setColorBackground(color(0));
  controlP5.setColorActive(color(255,0,0));
  controlP5.setColorForeground(color(100));
  controlP5.setColorLabel(color(255));
  
  bCapture = controlP5.addButton("capture", 0, 10, 300, 70, 20);
  bCancel = controlP5.addButton("cancel", 0, 10, 330, 70, 20);
  bSend = controlP5.addButton("send", 0, 10, 360, 70, 20);
}

void draw()
{
  background(190);
  
  micro.beginDraw();
  {
    micro.background(0);
    
    micro.stroke(0);
    micro.strokeWeight(1);
    micro.fill(255);
    micro.rectMode(CORNERS);
    micro.rect(leftX, 0, rightX , height);
    
    micro.stroke(0);
    micro.strokeWeight(w);
    micro.strokeCap(SQUARE);
    
    if (!isSent)
    {
      // provide FFT for the right sound channel
      fft.forward(in.right);
      
      // fft.avgSize() makes a number of frequency bands
      // out of each individual frequency
      for (int i = 0; i < fft.avgSize(); i++)
      {
        // if not captured draw the current result
        if (!isCaptured)
        {
          // if sound is too loud, use delta to limit it in its height
          if (fft.getAvg(i)*scale > delta) { micro.line(rightX, i*w + w/2, rightX - delta, i*w + w/2); }
          
          // if not, draw the current sound level
          else { micro.line(rightX, i*w + w/2, rightX - fft.getAvg(i)*scale, i*w + w/2); }
        }
        
        // if captured, draw the saved result
        else { micro.line(rightX, i*w + w/2, rightX - rCurve[i], i*w + w/2); }
      }
      
      // the same for the left audio channel
      fft.forward(in.left);
      for (int i = 0; i < fft.avgSize(); i++)
      {
        if (!isCaptured)
        {
          if (fft.getAvg(i)*scale > delta)  { micro.line(leftX, i*w + w/2, leftX + delta, i*w + w/2); }
          else  { micro.line(leftX, i*w + w/2, leftX + fft.getAvg(i)*scale, i*w + w/2); }
        }
        else  { micro.line(leftX, i*w + w/2, leftX + lCurve[i], i*w + w/2); }
      }
    }
    
    // get a feed-back from Arduino, which square fragment it is
    // currently handling
    else
    {
      // draw progress
      for (int i = 0; i < counter; i++)
      { 
        if (i > 1)
        { 
          float val = rCurveProgress[i] * delta / maxDegrees; 
          micro.line(rightX, i*w + w/2, rightX - val, i*w + w/2);
        }
      }
    }
  }
  micro.endDraw();
  
  image(micro, 300, 0);
}

void controlEvent(ControlEvent e)
{
  if (e.name().equals("capture"))
  {
     fft.forward(in.right);
     for (int i = 0; i < fft.avgSize(); i++)
     {
       if (fft.getAvg(i)*scale > delta)  { rCurve[i] = delta; }
       else                              { rCurve[i] = fft.getAvg(i)*scale; }
     }
     
     fft.forward(in.left);
     for (int i = 0; i < fft.avgSize(); i++)
     {
       if (fft.getAvg(i)*scale > delta)  { lCurve[i] = delta; }
       else                              { lCurve[i] = fft.getAvg(i)*scale; }
     }
     
     isCaptured = true;
  }
  if (e.name().equals("cancel"))  { isCaptured = false; }
  
  if (e.name().equals("send")) 
  { 
    if (isCaptured)
    {
      if (!isSent)
      {
        int toSend;
        for (int i = 0; i < fft.avgSize(); i++)
        {
          toSend = (int)(rCurve[i] / delta * maxDegrees);
          if (i < fft.avgSize() - 1)  { port.write(toSend + ","); }
          else                        { port.write(toSend + "."); }
        }
      }
      isSent = true;
    }
  }
}

// receive a feed-back from Arduino here
void serialEvent(Serial p)
{
  String msg = port.readStringUntil('\n');
  if (msg != null)  
  { 
    rCurveProgress[counter] = Float.valueOf(msg).floatValue();
    counter++;
  }
}
