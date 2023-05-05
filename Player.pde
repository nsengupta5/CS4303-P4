import java.io.File;
import java.awt.geom.Rectangle2D;

final class Player extends Particle {

  PImage[] currentFrames;

  PImage[] idleFrames;
  PImage[] attackFrames;
  PImage[] runFrames;  

  // https://chierit.itch.io/
  // https://luizmelo.itch.io/
  //https://codemanu.itch.io/pixelart-effect-pack


  //String characterName;
  String[] characters = new String[]{
    "monk",
    "knight",
    "water",
    "leaf",
    "metal",
    "wind"};
  int characterIndex;
  boolean swapCharacter = false;


  int currentFrame = 0;
  int animationWidth;
  int animationHeight;

  int health;
  int maxHealth;

  int moveIncrement;
  int jumpIncrement;
  float leftLimit, rightLimit;
  float upperLimit, lowerLimit;

  boolean idle = true;
  boolean isAirborne = false;
  boolean facingRight = true;
  boolean movingLeft = false;
  boolean movingRight = false;
  boolean attacking = false;
  
  int hitboxScale;
  int attackBoxScale;
  Rectangle2D playerBox;
  Rectangle2D attackBox;


  int monkScale;

  Player(int x, int y, float xVel, float yVel, float invM, int animationWidth, int animationHeight, int moveIncrement, int jumpIncrement, float leftLimit, float rightLimit, float upperLimit, float lowerLimit, int characterIndex){
    super(x, y, xVel, yVel, invM);
    this.animationWidth = animationWidth;
    this.animationHeight = animationHeight;
    
    hitboxScale = animationWidth/10;
    monkScale = hitboxScale*3/10;


    //scale monk differently
    if(characterIndex == 0){
      this.animationHeight += monkScale;
    }

    this.moveIncrement = moveIncrement;
    this.jumpIncrement = jumpIncrement;
    this.leftLimit = leftLimit;
    this.rightLimit = rightLimit;
    this.upperLimit = upperLimit;
    this.lowerLimit = lowerLimit;
    //this.characterName = characterName;
    this.characterIndex = characterIndex;
    loadTextures(characters[characterIndex]);
    currentFrames = idleFrames;
    this.maxHealth = 100;
    this.health = maxHealth;

    playerBox = new Rectangle2D.Float(this.position.x-hitboxScale/2, this.position.y+hitboxScale/2, hitboxScale, hitboxScale);
    attackBox = new Rectangle2D.Float((float) playerBox.getX(), (float) playerBox.getY(), (float) playerBox.getWidth(), (float) playerBox.getHeight());
    
  }

  void draw(){

    if(swapCharacter){
      characterIndex++;

      if(characterIndex >= characters.length){
        characterIndex = 0;
        this.animationHeight += monkScale;
      } else if (characterIndex == 1){
        this.animationHeight -= monkScale;
      }
        
        
      loadTextures(characters[characterIndex]);
      swapCharacter = false;
    }

    

        // update the animation frame if enough game frames have passed
    if (frameCount % (72 / FRAME_RATE) == 0) {
      currentFrame = (currentFrame + 1) % currentFrames.length;
    }

    if (position.y >= lowerLimit) {
      position.y = lowerLimit;
    }


    //chosing animation frames
    if((movingLeft || movingRight || attacking)){
      if(idle){
        idle = false;
        currentFrame = 0;
        currentFrames = runFrames;    
      }
      if(movingLeft){
        moveLeft();
        facingRight = false;

      } else if(movingRight){
        moveRight();
        facingRight = true;
      }

    } 
    else{
      idle = true;
      //currentFrame = 0;
      currentFrames = idleFrames;
    }

    //looping animation
    if(currentFrame >= currentFrames.length){
      currentFrame = 0;
    }

    //draw current frame
    if(facingRight){
      image(currentFrames[currentFrame], this.position.x, this.position.y, animationWidth, animationHeight);
    } else{
      pushMatrix();
      scale( -1, 1 );
      image(currentFrames[currentFrame], -this.position.x, this.position.y, animationWidth, animationHeight);
      popMatrix();
    }


    //if attacking animation is done, go back to idle
    if(attacking && currentFrame == currentFrames.length-1){
      idle = true;
      attacking = false;

      currentFrame = 0;
      currentFrames = idleFrames;
    }
               


    //update hitbox but dont draw it yet
        playerBox.setRect(this.position.x-hitboxScale/2, this.position.y+hitboxScale/2, (float) playerBox.getWidth(), (float) playerBox.getHeight());



    drawHitbox(false);
  }

  void drawHitbox(boolean intersects){
    noFill();
    if(intersects)
    stroke(0, 255, 0);
    else
    stroke(255, 0, 0);

    rect((float) playerBox.getX(), (float) playerBox.getY(), (float) playerBox.getWidth(), (float) playerBox.getHeight());

    if(this.attacking){

      
      if(!facingRight){
        attackBoxScale = hitboxScale*-1; 
      } else {
        attackBoxScale = hitboxScale*3/2;
      }

      attackBox.setRect((float) playerBox.getX() + attackBoxScale, (float) playerBox.getY(), (float) playerBox.getWidth()/2, (float) playerBox.getHeight()/2);
      rect((float) attackBox.getX(), (float) attackBox.getY(), (float) attackBox.getWidth(), (float) attackBox.getHeight());
    }
  }

  void loadTextures(String characterName){
    // Get the current sketch directory using sketchPath()
    String sketchDir = sketchPath("");

    String idleDir = sketchDir + "textures/"+characterName+"/png/idle/";
    String attackDir = sketchDir + "textures/"+characterName+"/png/1_atk/";
    String runDir = sketchDir + "textures/"+characterName+"/png/run/";

    idleFrames = new PImage[new File(idleDir).listFiles().length];
    for (int i = 0; i < idleFrames.length; i++) {
      idleFrames[i] = loadImage(idleDir + "idle_" + (i+1) + ".png");
    }

    attackFrames = new PImage[new File(attackDir).listFiles().length];
    for (int i = 0; i < attackFrames.length; i++) {
      attackFrames[i] = loadImage(attackDir + "1_atk_" + (i+1) + ".png");
    }

    runFrames = new PImage[new File(runDir).listFiles().length];
    for (int i = 0; i < runFrames.length; i++) {
      runFrames[i] = loadImage(runDir + "run_" + (i+1) + ".png");
    }

  }

  void attack(){
  if(!attacking){
        idle = false;
        attacking = true;
        currentFrame = 0;
        currentFrames = attackFrames;
  }
  }

boolean checkIfAirborne(ForceRegistry registry, Gravity gravity) {
    if(position.y < lowerLimit){
      if (isAirborne == false)
        isAirborne = true;
        registry.add(this, gravity);
    }
    else{
      isAirborne = false;
      registry.remove(this, gravity);
    }
    return isAirborne;
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
    if (!isAirborne) {
      velocity.y = 0;
      velocity.y -= jumpIncrement;
    }
    if (position.y <= 0) position.y = 0;
  }
}
