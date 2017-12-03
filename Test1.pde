/*
 * Generates visuals from an audio file. Algorithms:
 * Flash: flashes when the amplitude of the audio is above a certain threshold
 * Wall: A 3D wall which randomly dissipates
 * Plot: A frequency plot
 */
import ddf.minim.*;
import ddf.minim.ugens.*;
// options to change here:
static final int FRAME_RATE=24;
static final boolean SAVE_FRAMES=false;
static final AnimationType ani=AnimationType.PLOT;
static final float FLASH_THRESHOLD=0.3;

// Different animation algorithms
enum AnimationType {
  FLASH,
  WALL,
  PLOT
};
static final int cellsize=2;
static final int BUFFER_SCALE=1;
static final String fileName="Recording.mp3";

Minim minim;
AudioOutput audioOutput;
FilePlayer filePlayer;
PGraphics buffer;

void setup(){
  size(800, 600, P3D);
 // fullScreen(P3D); noCursor();
  minim=new Minim(this);
  audioOutput=minim.getLineOut(Minim.STEREO);
  filePlayer = new FilePlayer(minim.loadFileStream(fileName));
  filePlayer.patch(audioOutput);
  filePlayer.play();
  background(0);
  frameRate(FRAME_RATE);
//  step=22;
  buffer=createGraphics(width, height, P3D);
//  buffer.rect(0, 0, 800, 600);
  buffer.smooth(32);
  buffer.hint(ENABLE_DEPTH_TEST);
  if (ani==AnimationType.WALL){
  for (int i=0; i<BRICKS_ROWS; i++){
    for (int j=0;j<BRICKS_COLS; j++){
      int offset=0;
      if (i%2==0)  offset=50;
      bricks[i][j]=new Brick(j*100+offset, i*50);
    }
  }
  }
}

void draw(){
  surface.setTitle("FPS: "+frameRate);
  switch (ani) {
    case FLASH:
      drawFlash();
      break;
    case WALL:
      drawBricks();
      break;
    case PLOT:
      drawPlot();
      break;
  }
  if (SAVE_FRAMES){
    saveFrame("frames/frame-######.png");
  }
}

class Brick {
  PVector loc=new PVector();
  PVector mov=new PVector();
  static final float WIDTH=100;
  static final float HEIGHT=50;
  static final float DEPTH=50;
  Brick(int x, int y) {
    loc.x=x; loc.y=y; loc.z=0;
    mov.x=random(-5, 5)*10;
    mov.z=random(-5, 5)*10;
  }
  void draw(PGraphics g){
    g.pushMatrix();
     g.translate(loc.x, loc.y, loc.z);
     g.fill(255);
     g.stroke(0);
//  g.noStroke();
     g.box(Brick.WIDTH, Brick.HEIGHT, Brick.DEPTH);
    g.popMatrix();
  }
  void move(){
    loc=loc.add(mov);
  }
}
static final int BRICKS_ROWS=20;
static final int BRICKS_COLS=20;
Brick [][] bricks=new Brick[BRICKS_ROWS][BRICKS_COLS];

void drawBricks(){
  buffer.beginDraw();
  buffer.background(0);
  buffer.strokeWeight(1);
  buffer.smooth(32);
  //buffer.lights();
  //buffer.translate(width/2, height/2);
  for (int i=0; i<BRICKS_ROWS; i++){
    for (int j=0; j<BRICKS_COLS; j++){
      if (frameCount>=120)
        bricks[i][j].move();
      bricks[i][j].draw(buffer);
    }
  }
  //buffer.filter(BLUR, 1);
  //buffer.filter(THRESHOLD, 0.3);
  buffer.endDraw();
  image(buffer, 0, 0);
}
// Flash white if audio is beyond a certain amplitude
void drawFlash(){
  buffer.beginDraw();
  float f=abs(audioOutput.left.get(0));
  //println(f);
  if (f>=FLASH_THRESHOLD){
    buffer.background(255);
   // println("flash");
  } else {
    buffer.background(0);
  }
  buffer.endDraw();
  image(buffer, 0, 0);
}

void drawPlot(){
 // moveGraphics(buffer);
  buffer.beginDraw();
  //buffer.background(0);
  buffer.stroke(128, 128, 128, 80);
  buffer.fill(0, 0, 0, 10);
  buffer.strokeWeight(2);
  buffer.blendMode(BLEND);
//  buffer.rect(0, 0, 800, 600);
  buffer.blendMode(ADD);
  for (int i = 0; i < audioOutput.bufferSize()/BUFFER_SCALE-1; i++)
  {
    float x1 = map(i, 0, audioOutput.bufferSize()/BUFFER_SCALE, 0, width);
    float x2 = map(i+1, 0, audioOutput.bufferSize()/BUFFER_SCALE, 0, width);
    stroke(128);//strokeWeight(x2);
    //if (!inited)
    //    System.err.println("x1: "+x1+", x2: "+x2);
    buffer.line(x1, height/4 + audioOutput.left.get(i)*height/2, x2, height/4 + audioOutput.left.get(i+1)*height/2);
    buffer.line(x1, (3*height/4) + audioOutput.right.get(i)*height/2, x2, (3*height/4) + audioOutput.right.get(i+1)*height/2);

  }
/*  
  for ( int i = 0; i < 400;i++) {
    // Begin loop for rows
    for ( int j = 0; j < 300;j++) {
      int x = i*cellsize + cellsize/2; // x position
      int y = j*cellsize + cellsize/2; // y position
      int loc = x + y * width;           // Pixel array location
      color c = buffer.pixels[loc];       // Grab the color
      // Calculate a z position as a function of mouseX and pixel brightness
      float z = (mouseX/(float)width) * brightness(buffer.pixels[loc]) - 100.0;
      // Translate to the location, set fill and stroke, and draw the rect
      pushMatrix();
      translate(x, y, z*2);
      fill((c*2));
      noStroke();
      rectMode(CENTER);
      rect(0, 0, cellsize, cellsize);
      popMatrix();
    }
  }
  */
  buffer.endDraw();
  blendMode(BLEND);
  pushMatrix();
 //  rotateX(radians(45));
 //  translate(0, 0, 100);
   buffer.filter(BLUR, 1);
   image(buffer, 0, 0);
  popMatrix();
  //inited=true;
 // blendMode(BLEND);
 // fill(0);
 // noStroke();
 // rect(0, 0, width, 255);
//  blendMode(ADD);
//  strokeWeight(10);
//  stroke(128);
//  float f=audioOutput.left.get(0);
  //println("i="+f);
//  arc(128, 129, f*255, f*255, 0, f, OPEN);
}

int [] moved=new int[800*600];

void moveGraphics(PGraphics c) {
  c.beginDraw();
  c.loadPixels();
  arrayCopy(c.pixels, width, moved, 0, c.pixels.length-width); 
  arrayCopy(moved, 0, c.pixels, 0, c.pixels.length);
  c.updatePixels();
  c.endDraw();
}