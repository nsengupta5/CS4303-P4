final class Player extends Particle {

  PImage[] currentFrames;

  PImage[] idleFramesRight;
  PImage[] attackFramesRight;

  PImage[] idleFramesLeft;
  PImage[] attackFramesLeft;  
  
 // https://chierit.itch.io/
 // https://luizmelo.itch.io/
//https://codemanu.itch.io/pixelart-effect-pack

  int currentFrame = 0;
  int playerWidth;
  int playerHeight;

  int health;
  int maxHealth;

  int moveIncrement;
  float leftLimit, rightLimit;
  float upperLimit, lowerLimit;

  boolean idle = true;
  boolean isAirborne = false;
  boolean isJumping = false;
  boolean facingRight = true;

  Player(int x, int y, float xVel, float yVel, float invM, int playerWidth, int playerHeight, int moveIncrement, float leftLimit, float rightLimit, float upperLimit, float lowerLimit){
    super(x, y, xVel, yVel, invM);
    this.playerWidth = playerWidth;
    this.playerHeight = playerHeight;
    this.moveIncrement = moveIncrement;
    this.leftLimit = leftLimit;
    this.rightLimit = rightLimit;
    this.upperLimit = upperLimit;
    this.lowerLimit = lowerLimit;
    loadTextures();
    currentFrames = idleFramesRight;
    this.maxHealth = 100;
    this.health = maxHealth;
  }

  void draw(){
    // update the current frame if enough frames have passed
    if (frameCount % (60 / FRAME_RATE) == 0) {
      currentFrame = (currentFrame + 1) % currentFrames.length;
    }

    if (position.y >= lowerLimit) {
      position.y = lowerLimit;
    }

    //draw current frame#
    if(facingRight)
      image(currentFrames[currentFrame], this.position.x, this.position.y, playerWidth, playerHeight);
    else
      image(currentFrames[currentFrame], this.position.x - playerWidth/2, this.position.y, playerWidth, playerHeight);

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

  /**
   * Moves the player left
   */
  void moveLeft() {
    position.x -= moveIncrement;
    if (position.x <= leftLimit) position.x = leftLimit;
  }

  /**
   * Moves the player right
   */
  void moveRight() {
    position.x += moveIncrement;
    if (position.x >= rightLimit) position.x = rightLimit;
  }  

  void jump() {
    if (!isAirborne && isJumping) {
      velocity.y -= 20;
    }
    if (position.y <= 0) position.y = 0;
  }
}
