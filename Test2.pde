/*
 * Uses an algorithm to generate images from the FFT of an audio file
 * https://gist.github.com/Bleuje/e93045c1dc34c21bbe24cc97501348fb
 * TODO: save audio spectrum to file
 * reload file and generate frames from it
 */
import processing.sound.*;
static final int FRAME_RATE=25;
private boolean RECORDING=true;
static int take=4;
FFT fft;
SoundFile in;
int bands = 512;
float[] spectrum = new float[bands];
JSONArray frames;
int[][] result;
float t, c;
private boolean started=false;
static final float ANI_RADIUS=1.8;

float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

float ease(float p, float g) {
  if (p < 0.5) 
    return 0.5 * pow(2*p, g);
  else
    return 1 - 0.5 * pow(2*(1 - p), g);
}

float mn = .5*sqrt(3), ia = atan(sqrt(.5));

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

void draw__() {

  if (!recording) {
    t = mouseX*1.0/width;
    c = mouseY*1.0/height;
    if (mousePressed)
      println(c);
    draw_jd();
  } else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    c = 0;
    for (int sa=0; sa<samplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
      draw_jd();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 | 
        int(result[i][0]*1.0/samplesPerFrame) << 16 | 
        int(result[i][1]*1.0/samplesPerFrame) << 8 | 
        int(result[i][2]*1.0/samplesPerFrame);
    updatePixels();

    saveFrame("fr###.png");
    println(frameCount,"/",numFrames);
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////////////

int samplesPerFrame = 5;
int numFrames = 80;        
float shutterAngle = .8;

boolean recording = false;

int N = 50;
int n = 512;
float l = 250;
float scl = 0.01;
float r = 0.5;

void draw_jd(){
  background(0);
  
  noStroke();
  stroke(255);
  strokeWeight(2);
  
  for (int i=0;i<N;i++){  //lines
    float y = map(i, 0, N-1, 0, height);
    
    stroke(noise(random(0,1))*255, noise(random(0,1))*255, noise(random(0,1))*255);
    fill(0);
    
    beginShape();
    vertex(-1, height+10);
    for (int j=0; j<n; j++){
      float x = map(j, 0, n-1, -1, width);
      
      float intensity = ease(constrain(map(dist(x, y, width/2, height/2), 0, ANI_RADIUS*width,1,0),0,1),2.0);
      
      float yy = y + intensity*l*(float)noise(spectrum[j]*height);
      
      vertex(x, yy);
    }
    vertex(width, height+10);
    endShape();
  }
}

void setup() {
  size(800, 600);
  background(0);
  
  frames=new JSONArray();
  result = new int[width*height][3];
  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  in = new SoundFile(this, "Recording.mp3");
  
  // start the Audio Input
  in.play();
  frameRate(FRAME_RATE);
  // patch the AudioIn
  fft.input(in);
}     
JSONObject obj=new JSONObject();
int frame=0;

void draw() { 
  surface.setTitle("FPS: "+frameRate);
  background(0);
  //stroke(255);
  fft.analyze(spectrum);
  obj=new JSONObject();
//  obj.setInt("frame", frame);
//  for (int i=0;i<spectrum.length; i++){
//    obj.setFloat("val"+i, spectrum[i]);
//  }
//  frames.setJSONObject(frame++, obj);
  
  draw__();
 // for (int i=0; i<bands; i++){
    // The result of the FFT is normalized
    // draw the line for frequency band i scaling it up by 5 to get more amplitude.
  //  line(i, height, i, height - spectrum[i]*height*5);
 // }
  //draw_lines();
  filter(DILATE);
  filter(BLUR, 4);
  filter(THRESHOLD, 0.3);
  if (RECORDING) // save to different directory for different takes
      saveFrame("data/"+take+"/frame-######.png");
}

int N_ = 40;
float b = 50;
float l_ = 10;
float scl_ = 0.01;
float r_ = 0.6;

void draw_lines(){
  background(0);
  
  stroke(255);
  strokeWeight(2);
  for (int i=0; i<N_; i++){
    for (int j=0; j<N_; j++){
      float x = map(i, 0, N_-1, b, width-b);
      float y = map(j, 0, N_-1, b, height-b);
      float theta = 25*(float)spectrum[j]*scl_*25;
      float vx = l*cos(theta);
      float vy = l*sin(theta);
      float intensity = 0.1+1.5*ease((float)spectrum[i]*scl);
      vx*=intensity;
      vy*=intensity;
      line(x, y , x+vx, y+vy);
    }
  }
}
//void exit()  {      
//    println("Closing sketch");
    // Place here the code you want to execute on exit
 // println("in stop");
 // saveJSONArray(frames, "data/frames.json");
 // super.exit();
//}  
public void keyPressed(){
  if (key=='s' || key == 'S'){
    started=true;
  }
}