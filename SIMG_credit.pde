String text="Sound Is My Guide";
//String text="About";
float counter=0;
PFont theFont;
static final float MIN_BLUR=1;
boolean RECORDING=false;
float blurFactor=6;
SequenceState state=SequenceState.END;
float offset=0;
String [] filmmakers = { "Annemarie Bala", "Touqeer Ahmad", "Jerry Padfield" };
String firstName;
int filmmaker=2;
static final int STROKEWEIGHT=1;
static final int FRAMERATE=1;
//PShader blur;
static final float NOISE_INC=0.03;

enum SequenceState {
  START,
  END
};

void setup(){
  size(1280, 720);
  theFont=createFont("Courier New", 32);
  textFont(theFont);
  strokeWeight(STROKEWEIGHT);
  frameRate(FRAMERATE);
//  blur=loadShader("blur.glsl");
  firstName=filmmakers[filmaker].getFirstWord();
}
void screenshot(){
  if (state==SequenceState.START){
    saveFrame("data/frame-######.png");
  }else{
    saveFrame("data/"+firstName+"/frame"+filmmaker+"-######.png");
  }
}

 private String getFirstWord(String text) {
    if (text.indexOf(' ') > -1) { // Check if there is more than one word.
      return text.substring(0, text.indexOf(' ')); // Extract first word.
    } else {
      return text; // Text is the first word itself.
    }
  }

void draw(){
   surface.setTitle(int(frameRate) + " fps");
  if (state==SequenceState.START){
    drawStartSequence();
  } else if (state==SequenceState.END){
    drawEndSequence();
  }
  //println("In draw: "+frameCount);
  if (RECORDING){
    screenshot();
    if (frameCount==120){
      exit();
    }
  }

}

String credit1="Words & Sound by David Crossan";
String credit2="Visuals by "+filmmakers[filmmaker]; //Touqeer Ahmad, Annemarie Bala, Jerry Padfield";
String credit3="Performed by Martin Haddow";

void drawEndSequence(){
  background(0);
  stroke(255);
  drawLine();
//  blurFactor-=0.1;
//  if (blurFactor<=MIN_BLUR) blurFactor=MIN_BLUR;
  filter(BLUR, blurFactor);
//  filter(THRESHOLD, 0.9);
  textAlign(CENTER);
  int j=0;
  for (int i=0;i<text.length(); i++){
    textSize(24+noise(counter+=NOISE_INC)*24);
    text(text.charAt(i), width/2+j-128, height/2-16);
    j+=24;
  }
  j=0;
  for (int i=0;i<credit1.length(); i++){
    textSize(12+noise(counter+=NOISE_INC)*24);
    text(credit1.charAt(i), width/2+j-128, height/2+24);
    j+=16;
  }
  j=0;
  for (int i=0;i<credit2.length(); i++){
    textSize(12+noise(counter+=NOISE_INC)*24);
    text(credit2.charAt(i), width/2+j-128, height/2+48);
    j+=16;
  }  j=0;
  for (int i=0;i<credit3.length(); i++){
    textSize(12+noise(counter+=NOISE_INC)*24);
    text(credit3.charAt(i), width/2+j-128, height/2+72);
    j+=16;
  }
}

void drawStartSequence(){
  background(0);
  stroke(255);
  textAlign(CENTER);
  int j=0;
  for (int i=0;i<text.length(); i++){
    textSize(24+noise(counter+=NOISE_INC)*24);
    text(text.charAt(i), width/2+j-128, height/2);
    j+=24;
  }
  blurFactor-=0.1;
  if (blurFactor<=MIN_BLUR) blurFactor=MIN_BLUR;
  filter(BLUR, blurFactor);
//  filter(THRESHOLD, 0.9);
  drawLine();
}

void drawLine(){
  float f=0;
  offset=random(0,255);
  for (int i=0; i<width; i++){
    beginShape(LINES);
     vertex(i, height/2+noise(offset+(f+=0.01))*height/2.2);
     vertex(i+1, height/2+noise(offset+f+0.01)*height/2.2);
    endShape();
  }
}

public void keyPressed(){
  if (key == 'S' || key == 's'){
    screenshot();
  }
}