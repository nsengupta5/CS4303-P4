class Player{

PImage[] currentFrames;

PImage[] idleFramesRight;
PImage[] attackFramesRight;

PImage[] idleFramesLeft;
PImage[] attackFramesLeft;

int currentFrame = 0;
int playerWidth = displayWidth/10;
int playerHeight = playerWidth /2;
boolean idle = true;

boolean facingRight = true;

Player(){

    loadTextures();
    currentFrames = idleFramesRight;

}

void loadTextures(){
  idleFramesRight = new PImage[8];
  for (int i = 0; i < idleFramesRight.length; i++) {
    idleFramesRight[i] = loadImage("textures/idle/r" + (i+1) + ".png");
  }

    idleFramesLeft = new PImage[8];
    for (int i = 0; i < idleFramesLeft.length; i++) {
        idleFramesLeft[i] = loadImage("textures/idle/l" + (i+1) + ".png");
    }


  attackFramesRight = new PImage[6];
    for (int i = 0; i < attackFramesRight.length; i++) {
        attackFramesRight[i] = loadImage("textures/attack/r" + (i+1) + ".png");
    }

    attackFramesLeft = new PImage[6];
    for (int i = 0; i < attackFramesLeft.length; i++) {
        attackFramesLeft[i] = loadImage("textures/attack/l" + (i+1) + ".png");
    }




}

void attack(){
    if(idle){
        idle = false;
        currentFrame = 0;

        if(facingRight)
        currentFrames = attackFramesRight;
        else
        currentFrames = attackFramesLeft;
        
    }
}

void faceLeft(){
    if(idle && facingRight){
        currentFrames = idleFramesLeft;
        facingRight = false;
    }
}

void faceRight(){
    if(idle && !facingRight){
        currentFrames = idleFramesRight;
        facingRight = true;
    }
}


void draw(){

   // update the current frame if enough frames have passed
  if (frameCount % (60 / FRAME_RATE) == 0) {
    currentFrame = (currentFrame + 1) % currentFrames.length;
  }



  //draw current frame
  image(currentFrames[currentFrame], playerWidth, playerWidth, playerWidth, playerHeight);


    //if non idle animation is done, go back to idle
    if(!idle && currentFrame == currentFrames.length-1){
        idle = true;
        currentFrame = 0;

        if(facingRight)
        currentFrames = idleFramesRight;
        else
        currentFrames = idleFramesLeft;

    }
    


}
}