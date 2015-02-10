import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.Random;

Minim minim;
AudioPlayer player;
FFT fft;
BeatDetect soundbeat;
String filename;
Random rand;
int radius;
float angle;
float inc;

/*
* Function that sets up all the variables to be used
*/
void setup()
{
  size(700, 700);
  frameRate(60);
  rand = new Random();
  minim = new Minim(this);
  
  selectInput("Select a song to play", "fileSelected");
  
  while(filename == null);
  
  player = minim.loadFile(filename);
  fft = new FFT(player.bufferSize(), player.sampleRate());
  soundbeat = new BeatDetect();
  
  radius = 250;
  inc = TWO_PI / player.bufferSize();
  
  player.play();
}

/*
* Function that draws one frame. System loops this function
*/
void draw()
{
  flashBackground();
  
  plotSomeDots();
  
  drawCircles();
  
  drawCircularWaveform();
}

/*
* Function that "flashes" the background by changing the background colour when a beat is detected
* and changing it back when not detected
*/
void flashBackground()
{
  soundbeat.detect(player.mix);
  
  if(soundbeat.isOnset())
    background(40);
  else
    background(0);
}

/*
* Draws the 5 circles. Colour is random, radius depends on the frequency spectrum
* calculated using an FFT
*/
void drawCircles()
{
  noStroke();
  
  fft.forward(player.mix);
  
  float h=0, w=0, rad=0;

  for(int i=0; i+1<fft.specSize(); i++)
  {
     float band = fft.getBand(i);
     fill(randomHex(), randomHex() , randomHex(), randomHex());
        
     int crit = i%5;
     switch(crit)
     {
        case 0: h = height/2;  w = width/2; 
                rad = band * 2;
                break;
        case 1: h = height/4;  w = width/4;
                rad = band;
                break;
        case 2: h = height/4;  w = .75 * width;
                rad = band;
                break;
        case 3: h = .75 * height;  w = width/4;
                rad = band;
                break;
       default: h = .75 * height;  w = .75 * width;
                rad = band;
                break;
     }
     
       ellipse(h, w, rad, rad);
  }
}

/*
* Draws a waveform in a circular pattern. Uses sound spectrum
*/
void drawCircularWaveform()
{
  stroke(120);
  strokeWeight(2);
  
  angle = 0;
  
  for(int i = 0; i < player.bufferSize() - 1; i++)
  {
    if(i%2 == 0)
      continue;
      
    //80 is simply a scaling factor
    float x1 = width/2 + cos(angle) * (radius + player.right.get(i)*80);
    float y1 = height/2 + sin(angle) * (radius + player.right.get(i)*80);
    
    float x2 = width/2 + cos(angle) * (radius + player.right.get(i+1)*80);
    float y2 = height/2 + sin(angle) * (radius + player.right.get(i+1)*80);
    
    line(x1, y1, x2, y2);
    
    angle += 2 * inc;
  } 
}

/*
* Plots 10 dots of random colour randomly on the screen
*/
void plotSomeDots()
{
   noStroke();
   for(int i=0; i<10; i++)
   {
     fill(randomHex(), randomHex(), randomHex());
     int x = rand.nextInt(width);
     int y = rand.nextInt(height);
     ellipse(x, y, 4, 4);
  } 
}

/*
* Returns a random number in 0-255
*/
int randomHex()
{
  return rand.nextInt(255);
}

/*
* Utility function used to fast-forward or rewiwnd by 10 seconds, pause or resume
*/
void keyPressed()
{
   if(keyCode == LEFT)
      player.skip(-10000);
   else if(keyCode == RIGHT)
      player.skip(10000);
   else if(keyCode == 32)
   {
     if(looping)
     {
       noLoop();
       player.pause();
     }
     else
     {
       loop();
       player.play();
     }
   } 
}

/*
* Sets the file name of the file selected
*/
void fileSelected(File file)
{
   filename = file.getAbsolutePath();
}
