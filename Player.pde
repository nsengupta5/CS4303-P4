import java.io.File;
import java.awt.geom.Rectangle2D;

final float SLOW_RADIUS = 20f ;
final float TARGET_RADIUS = 3f ;
final float DRAG = 0.95f ;

final class Player extends Particle {

  PImage[] currentFrames;
  PImage[] idleFrames;
  PImage[] attackFrames;
  PImage[] runFrames; 
  PImage[] deathFrames;
  PImage[] jumpUpFrames;
  PImage[] jumpDownFrames;
  PImage[] hitFrames;

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
  float groundLimit;
  float velXLimit;

  boolean idle = false;
  boolean isAirborne = true;
  boolean facingRight = true;
  boolean movingLeft = false;
  boolean movingRight = false;
  boolean attacking = false;
  boolean dying = false;
  boolean gettingHit = false;
  
  int hitboxScale;
  int attackBoxScale;
  Rectangle2D playerBox;
  Rectangle2D attackBox;

  int monkScale;
  
  ForceRegistry thisRegistry;
  Gravity thisGravity;

  PlayerState state;
  ArrayList<Platform> platforms;
  PVector targetVelocity = new PVector(0, 0);

  Player(int x, int y, float xVel, float yVel, float invM, int animationWidth, int animationHeight, int moveIncrement, int jumpIncrement, float leftLimit, float rightLimit, float upperLimit, float lowerLimit, float groundLimit, float velXLimit, int characterIndex, ForceRegistry registry, Gravity gravity){
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
    this.groundLimit = groundLimit;
    //this.characterName = characterName;
    this.characterIndex = characterIndex;
    loadTextures(characters[characterIndex]);
    currentFrames = idleFrames;
    this.maxHealth = 100;
    this.velXLimit = velXLimit;
    this.health = maxHealth;

    playerBox = new Rectangle2D.Float(this.position.x-hitboxScale/2, this.position.y+hitboxScale/2, hitboxScale, hitboxScale);
    attackBox = new Rectangle2D.Float((float) playerBox.getX(), (float) playerBox.getY(), (float) playerBox.getWidth(), (float) playerBox.getHeight());

    thisRegistry = registry;
    thisGravity = gravity;

    thisRegistry.add(this, thisGravity);
    state = PlayerState.IDLE;
  }

  void draw(ArrayList<Platform> platforms){

    //update world
    this.platforms = platforms;


    //change character
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
    if((movingLeft || movingRight || attacking || dying || gettingHit)){
   
      
      if(movingLeft && !dying){
        moveLeft();
        facingRight = false;

      } else if(movingRight && !dying){
        moveRight();
        facingRight = true;
      }
      
    } 
    else if(!isAirborne) {
      idle = true;
      //currentFrame = 0;
      currentFrames = idleFrames;
    }


        //if landed on ground or platform
        if((position.y >= groundLimit || checkOnPlatform(platforms)) && isAirborne) {
            isAirborne = false;
            thisRegistry.remove(this, thisGravity);
            this.velocity.y = 0;
            idle = true;
        }

        //if walk off platform
        if(!isAirborne && !checkOnPlatform(platforms) && position.y < groundLimit){
          isAirborne = true;
          idle = false;
          thisRegistry.add(this, thisGravity);
        }

        
      //&& velcocity != 0 for platform, because isAirborne is true when on platform
      if(isAirborne){
        if(isFalling()){
          currentFrames = jumpDownFrames;
        } else {
          currentFrames = jumpUpFrames;
        }
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

    //if getting hit animation is done, go back to idle
    if(gettingHit && currentFrame == currentFrames.length-1){
      idle = true;
      gettingHit = false;

      currentFrame = 0;
      currentFrames = idleFrames;
    }


    //if dying animation is done, set dying to false so game can end
    if(dying && currentFrame == currentFrames.length-1){
      dying = false;
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

    /* rect((float) playerBox.getX(), (float) playerBox.getY(), (float) playerBox.getWidth(), (float) playerBox.getHeight()); */

    if(this.attacking){


      if(!facingRight){
        attackBoxScale = hitboxScale*-1; 
      } else {
        attackBoxScale = hitboxScale*3/2;
      }

      attackBox.setRect((float) playerBox.getX() + attackBoxScale, (float) playerBox.getY(), (float) playerBox.getWidth()/2, (float) playerBox.getHeight()/2);
      /* rect((float) attackBox.getX(), (float) attackBox.getY(), (float) attackBox.getWidth(), (float) attackBox.getHeight()); */
    }
  }


  void loadTextures(String characterName){
    // Get the current sketch directory using sketchPath()
    String sketchDir = sketchPath("");

    String idleDir = sketchDir + "textures/"+characterName+"/png/idle/";
    String attackDir = sketchDir + "textures/"+characterName+"/png/1_atk/";
    String runDir = sketchDir + "textures/"+characterName+"/png/run/";
    String deathDir = sketchDir + "textures/"+characterName+"/png/death/";
    String jumpUpDir = sketchDir + "textures/"+characterName+"/png/jump_up/";
    String jumpDownDir = sketchDir + "textures/"+characterName+"/png/jump_down/";
    String hitDir = sketchDir + "textures/"+characterName+"/png/take_hit/";

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

    deathFrames = new PImage[new File(deathDir).listFiles().length];
    for (int i = 0; i < deathFrames.length; i++) {
      deathFrames[i] = loadImage(deathDir + "death_" + (i+1) + ".png");
    }

    jumpUpFrames = new PImage[new File(jumpUpDir).listFiles().length];
    for (int i = 0; i < jumpUpFrames.length; i++) {
      jumpUpFrames[i] = loadImage(jumpUpDir + "jump_up_" + (i+1) + ".png");
    }

    jumpDownFrames = new PImage[new File(jumpDownDir).listFiles().length];
    for (int i = 0; i < jumpDownFrames.length; i++) {
      jumpDownFrames[i] = loadImage(jumpDownDir + "jump_down_" + (i+1) + ".png");
    }

    hitFrames = new PImage[new File(hitDir).listFiles().length];
    for (int i = 0; i < hitFrames.length; i++) {
      hitFrames[i] = loadImage(hitDir + "take_hit_" + (i+1) + ".png");
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

  boolean isFalling(){
    return isAirborne && velocity.y > 0;
  }

  void die(){
    idle = false;
    dying = true;
    currentFrame = 0;
    currentFrames = deathFrames;
  }

  void checkHoveringOnPlatform(ArrayList<Platform> platforms) {
    float x = position.x;
    float maxLowerLimit = groundLimit;
    for (Platform platform : platforms) {
      if (x >= platform.position.x && x <= platform.position.x + platform.platformWidth) {
        if (position.y + platform.platformHeight < platform.position.y) {
          if(isFalling()){
          float platY = platform.position.y - animationHeight / PLAYER_ANIMATION_SCALE;
          lowerLimit = platY;
          if (platY < maxLowerLimit) 
            maxLowerLimit = platY;
          }
        }
      }
    }
    lowerLimit = maxLowerLimit;
  }

  ArrayList<Platform> getJumpablePlatforms(ArrayList<Platform> platforms) {
    ArrayList<Platform> jumpablePlatforms = new ArrayList<Platform>();
    for (Platform platform : platforms) {
      if (position.y - platform.position.y <= playerBox.getWidth() * 2.5 && platform.position.y < position.y) {
        if (position.x >= platform.position.x && position.x <= platform.position.x + platform.platformWidth) {
          jumpablePlatforms.add(platform);
        }
      }
    }
    return jumpablePlatforms;
  }

  boolean checkOnPlatform(ArrayList<Platform> platforms) {
    for (Platform platform : platforms) {
      if (position.y == platform.position.y - animationHeight / PLAYER_ANIMATION_SCALE) {
        if (position.x >= platform.position.x && position.x <= platform.position.x + platform.platformWidth) {
          lowerLimit = platform.position.y - animationHeight / PLAYER_ANIMATION_SCALE;
          return true;
        }
      }
    }
    return false;
  }

  /**
   * Moves the player left
   */
  void moveLeft() {
        if(!attacking && !gettingHit){
          currentFrames = runFrames;    
         }

    if (velocity.x > -velXLimit) {
      velocity.x -= moveIncrement;
    }
    if (position.x <= leftLimit) position.x = leftLimit;
  }

  /**
   * Moves the player right
   */
  void moveRight() {
      if(!attacking && !gettingHit){
        //idle = false;
       // currentFrame = 0;
        currentFrames = runFrames;  
      }

    if (velocity.x < velXLimit) {
      velocity.x += moveIncrement;
    }
    if (position.x >= rightLimit) position.x = rightLimit;
  }  


  void jump() {
    if (!isAirborne) {
      velocity.y = 0;
      velocity.y -= jumpIncrement;
      isAirborne = true;
      idle = false;
      currentFrame = 0;
      currentFrames = jumpUpFrames;
      thisRegistry.add(this, thisGravity);
    }
    if (position.y <= 0) position.y = 0;
  }

  void getHit(int damage){
      if(!gettingHit){
        idle = false;
        gettingHit = true;
        currentFrame = 0;
        currentFrames = hitFrames;

        if(health > 0)        this.health -=damage;
        else                  this.health = 0;
      }
      
  }

  /* void moveLeftToPlayer(PVector otherPos) { */
  /*   PVector targetPos = position.copy().sub(otherPos); */
  /*   position.x += velocity.x; */
        
  /*   targetPos.normalize() ; */
  /*   if (velocity.x > -velXLimit) { */
  /*     velocity.x -= targetPos.x; */
  /*   } */
  /*   if (position.x <= leftLimit) position.x = leftLimit; */
  /* } */
  
  /* void moveRightToPlayer(PVector otherPos) { */
  /*   PVector targetPos = otherPos.copy().sub(position); */
        
  /*   targetPos.normalize() ; */
  /*   if (velocity.x < velXLimit) { */
  /*     velocity.x += targetPos.x; */
  /*   } */
  /*   if (position.x >= rightLimit) position.x = rightLimit; */
  /* } */

  void moveLeftToPlayer(PVector otherPos) {
    PVector targetPos = position.copy().sub(otherPos);
    position.x += velocity.x;
        
    float distance = targetPos.mag() ;
    // If arrived, no acceleration.
    if (distance > TARGET_RADIUS) {
      float targetSpeed = velXLimit;    
      if (distance <= SLOW_RADIUS)
        targetSpeed = velXLimit * distance / SLOW_RADIUS ;
    
      targetVelocity = targetPos.get() ;
      targetVelocity.normalize() ;
      if (velocity.x > -velXLimit) velocity.x -= targetVelocity.x;
    }
    
    // Bit of drag
    velocity.x *= DRAG;
  }

  void moveRightToPlayer(PVector otherPos) {
    PVector targetPos = otherPos.copy().sub(position);
    position.x += velocity.x;
        
    float distance = targetPos.mag() ;
    // If arrived, no acceleration.
    if (distance > TARGET_RADIUS) {
      float targetSpeed = velXLimit;    
      if (distance <= SLOW_RADIUS)
        targetSpeed = velXLimit * distance / SLOW_RADIUS ;
    
      targetVelocity = targetPos.get() ;
      targetVelocity.normalize() ;
      if (velocity.x < velXLimit) velocity.x += targetVelocity.x;
    }
    
    // Bit of drag
    velocity.x *= DRAG;
  }

  void moveAI(PVector otherPos, ArrayList<Platform> platforms) {
    if (otherPos.x < position.x) {
      moveLeftToPlayer(otherPos);
    } else if (otherPos.x > position.x) {
      moveRightToPlayer(otherPos);
    }
    ArrayList<Platform> jumpablePlatforms = getJumpablePlatforms(platforms);
    if (jumpablePlatforms.size() > 0 && otherPos.y + playerBox.getHeight() / 2 < position.y) {
      velocity.x = 0;
      jump();
    }
  }
}
