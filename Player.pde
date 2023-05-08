import java.io.File;
import java.awt.geom.Rectangle2D;

final class Player extends Particle {

  PImage[] currentFrames;
  PImage[] idleFrames;
  PImage[] attackFrames;
  PImage[] runFrames; 
  PImage[] deathFrames;
  PImage[] jumpUpFrames;
  PImage[] jumpDownFrames;
  PImage[] hitFrames;
  PImage[] airAtkFrames;
  PImage[] blockFrames;


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

  boolean idle = false;
  boolean isAirborne = true;
  boolean facingRight = true;
  boolean movingLeft = false;
  boolean movingRight = false;
  boolean attacking = false;
  boolean dying = false;
  boolean gettingHit = false;
  boolean airAttacking = false;
  boolean blocking = false;
  
  int hitboxXScale;
  int hitboxYScale;

  int attackBoxScale;
  Rectangle2D playerBox;
  Rectangle2D attackBox;

  ForceRegistry thisRegistry;
  Gravity thisGravity;

  ArrayList<Platform> platforms;

  JSONObject characterJSON;


  Player(int x, int y, float xVel, float yVel, float invM, int animationWidth, int animationHeight, int moveIncrement, int jumpIncrement, float leftLimit, float rightLimit, float upperLimit, float lowerLimit, float groundLimit, int characterIndex, ForceRegistry registry, Gravity gravity){
    super(x, y, xVel, yVel, invM);
    this.animationWidth = animationWidth;
    this.animationHeight = animationHeight;

    hitboxXScale = animationWidth/10;
    hitboxYScale = animationHeight/3;


    this.moveIncrement = moveIncrement;
    this.jumpIncrement = jumpIncrement;
    this.leftLimit = leftLimit;
    this.rightLimit = rightLimit;
    this.upperLimit = upperLimit;
    this.lowerLimit = lowerLimit;
    this.groundLimit = groundLimit;
    this.characterIndex = characterIndex;
    loadTextures(characters[characterIndex]);
    currentFrames = idleFrames;
    this.maxHealth = 100;
    this.health = maxHealth;

    playerBox = new Rectangle2D.Float(this.position.x-hitboxXScale/2, this.position.y+hitboxYScale/2, hitboxXScale, hitboxYScale);
    attackBox = new Rectangle2D.Float((float) playerBox.getX(), (float) playerBox.getY(), (float) playerBox.getWidth(), (float) playerBox.getHeight());

    thisRegistry = registry;
    thisGravity = gravity;

    thisRegistry.add(this, thisGravity);

    loadJson();
  }

  void draw(ArrayList<Platform> platforms){

    //update world
    this.platforms = platforms;


    //change character
    if(swapCharacter){
      characterIndex++;

      if(characterIndex >= characters.length){
        characterIndex = 0;
      } 


      loadTextures(characters[characterIndex]);
      loadJson();
      swapCharacter = false;
    }


    // update the animation frame if enough game frames have passed
    if (frameCount % (72 / FRAME_RATE) == 0) {
      currentFrame = (currentFrame + 1) % currentFrames.length;
    }

    if (position.y >= lowerLimit) {
      position.y = lowerLimit;
    }


    //choose idle frames if no other booleans are true
    if((movingLeft || movingRight || attacking || dying || gettingHit || blocking)){
   
      
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
            //idle = true;
        }

        //if walk off platform
        if(!isAirborne && !checkOnPlatform(platforms) && position.y < groundLimit){
          isAirborne = true;
          idle = false;
          thisRegistry.add(this, thisGravity);
        }

        
      if(isAirborne){
        if(attacking && !airAttacking){
          idle = false;
          attacking = true;
          currentFrame = 0;
          currentFrames = airAtkFrames;
          airAttacking = true;
        } else if (gettingHit){
          idle = false;
          currentFrames = hitFrames;
        } else if(!airAttacking) {
          if(isFalling()){
          currentFrames = jumpDownFrames;
          } else {
            currentFrames = jumpUpFrames;
          }
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

    //if air attacking animation is done, go back to idle
    if(airAttacking && currentFrame == currentFrames.length-1){
      idle = true;
      airAttacking = false;
      attacking = false;

      currentFrame = 0;
      currentFrames = idleFrames;
    }

    //if getting hit animation is done, go back to idle
    if(gettingHit && currentFrame == currentFrames.length-1 && !dying){
      idle = true;
      gettingHit = false;

      currentFrame = 0;
      currentFrames = idleFrames;
    }

    //if blocking animation is done, go back to idle
    if(blocking && currentFrame == currentFrames.length-1){
      idle = true;
      blocking = false;

      currentFrame = 0;
      currentFrames = idleFrames;
    }


    //if dying animation is done, set dying to false so game can end
    if(dying && currentFrame == currentFrames.length-1){
      dying = false;
    }
               

   
    updateHitboxes();
    drawPlayerHitbox();


    
  }

  void loadJson(){
    String sketchDir = sketchPath("");
    String jsonDir = sketchDir + "json/characterStats.json";
    characterJSON = loadJSONObject(jsonDir);
  }

  

  void updateHitboxes(){
  //update hitboxes but dont draw it yet
  
      JSONArray characters = characterJSON.getJSONArray("characters");
      JSONObject character = characters.getJSONObject(characterIndex);
      JSONObject attacks = character.getJSONObject("attacks");
      JSONObject thisAttack;

      if(airAttacking){
         thisAttack = attacks.getJSONObject("air");
      } else {
          thisAttack = attacks.getJSONObject("normal");  
      }
      JSONArray hitboxDim = thisAttack.getJSONArray("attackBoxDim");

      int[] hitboxDims = hitboxDim.toIntArray();
      // println(hitboxDims);

    playerBox.setRect(this.position.x-hitboxXScale/2, this.position.y+hitboxYScale/2, (float) playerBox.getWidth(), (float) playerBox.getHeight());

    

    float attackBoxX;
    float attackBoxY = this.position.y+hitboxYScale/2 + ((float)hitboxDims[1]*hitboxYScale/100);
    float attackBoxWidth = ((float)hitboxDims[2]*hitboxXScale/100);
    float attacBoxHeight = ((float)hitboxDims[3]*hitboxYScale/100);

    if(!facingRight){
      attackBoxX = this.position.x - ((float)hitboxDims[0]*hitboxXScale/100)- attackBoxWidth;
    } else {
      attackBoxX = this.position.x + ((float)hitboxDims[0]*hitboxXScale/100);
    } 

    // attackBox.setRect((float) playerBox.getX() + attackBoxScale, (float) playerBox.getY() + hitboxDims[1], (float) playerBox.getWidth()/2 + hitboxDims[2], (float) playerBox.getHeight()/2 + hitboxDims[3]);
      attackBox.setRect(attackBoxX, attackBoxY, attackBoxWidth, attacBoxHeight);

  } 


  void drawPlayerHitbox(){
    noFill();
    if(this.gettingHit)
      stroke(0, 255, 0);
    else
      stroke(255, 0, 0);

    rect((float) playerBox.getX(), (float) playerBox.getY(), (float) playerBox.getWidth(), (float) playerBox.getHeight());

    int monkFrame = 2;
    int knightFrame = 4;

    // if(this.attacking && characterIndex == 0 && currentFrame == monkFrame || this.attacking && characterIndex == 1 && currentFrame == knightFrame){
    //   rect((float) attackBox.getX(), (float) attackBox.getY(), (float) attackBox.getWidth(), (float) attackBox.getHeight());
    // }
  }

  void drawAttackHitbox(){
    noFill();
    stroke(255, 0, 0);
    rect((float) attackBox.getX(), (float) attackBox.getY(), (float) attackBox.getWidth(), (float) attackBox.getHeight());
  }


  void loadTextures(String characterName){
    // Get the current sketch directory
    String sketchDir = sketchPath("");

    String idleDir = sketchDir + "textures/"+characterName+"/png/idle/";
    String attackDir = sketchDir + "textures/"+characterName+"/png/1_atk/";
    String runDir = sketchDir + "textures/"+characterName+"/png/run/";
    String deathDir = sketchDir + "textures/"+characterName+"/png/death/";
    String jumpUpDir = sketchDir + "textures/"+characterName+"/png/jump_up/";
    String jumpDownDir = sketchDir + "textures/"+characterName+"/png/jump_down/";
    String hitDir = sketchDir + "textures/"+characterName+"/png/take_hit/";
    String airAtkDir = sketchDir + "textures/"+characterName+"/png/air_atk/";
    String blockDir = sketchDir + "textures/"+characterName+"/png/defend/";

    idleFrames = loadFrames(idleDir, "idle_", characterName == "monk");
    attackFrames = loadFrames(attackDir, "1_atk_", characterName == "monk");
    runFrames = loadFrames(runDir, "run_", characterName == "monk");
    deathFrames = loadFrames(deathDir, "death_",  characterName == "monk");
    jumpUpFrames = loadFrames(jumpUpDir, "jump_up_", characterName == "monk");
    jumpDownFrames = loadFrames(jumpDownDir, "jump_down_", characterName == "monk");
    hitFrames = loadFrames(hitDir, "take_hit_", characterName == "monk");
    airAtkFrames = loadFrames(airAtkDir, "air_atk_", characterName == "monk");
    blockFrames = loadFrames(blockDir, "defend_", characterName == "monk");

  }

  PImage[] loadFrames(String dir, String prefix, boolean isMonk) {
    PImage[] frames = new PImage[new File(dir).listFiles().length];
    File[] files = new File(dir).listFiles();
    for (int i = 0; i < frames.length; i++) {
      frames[i] = loadImage(dir + prefix + (i+1) + ".png");
      if(isMonk) //monk has a weird texture that needs to be cropped
      frames[i] = frames[i].get(0, 0, frames[i].width, frames[i].height-6);
    }
    return frames;
  }


  void attack(){
    if(!attacking){
        idle = false;
        attacking = true;
        currentFrame = 0;
        currentFrames = attackFrames;
    }
  }


  void block(){
    if(!blocking && !attacking && !isAirborne){
      idle = false;
      blocking = true;
      currentFrame = 0;
      currentFrames = blockFrames;
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

        if(!attacking && !gettingHit && !blocking){
          //idle = false;
          //currentFrame = 0;
          currentFrames = runFrames;    
         }

    position.x -= moveIncrement;
    if (position.x <= leftLimit) position.x = leftLimit;
  }

  /**
   * Moves the player right
   */
  void moveRight() {
      if(!attacking && !gettingHit && !blocking){
        //idle = false;
       // currentFrame = 0;
        currentFrames = runFrames;  
      }

    position.x += moveIncrement;
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


}
