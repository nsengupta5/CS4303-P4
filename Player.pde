import java.io.File;
import java.awt.geom.Rectangle2D;

final float SLOW_RADIUS = 20f ;
final float TARGET_RADIUS = 200f ;
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
  PImage[] airAtkFrames;
  PImage[] blockFrames;
  PImage[] ability1Frames;
  PImage[] ability2Frames;

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

  boolean isAirborne = true;
  boolean facingRight = true;
  boolean movingLeft = false;
  boolean movingRight = false;
  boolean isAI = false;
  
  int hitboxXScale;
  int hitboxYScale;

  int attackBoxScale;
  Rectangle2D playerBox;
  Rectangle2D attackBox;

  ForceRegistry thisRegistry;
  Gravity thisGravity;

  PlayerState state;
  ArrayList<Platform> platforms;
  PVector targetVelocity = new PVector(0, 0);
  JSONObject characterJSON;
  float coolDownFrame = -1;

  int ability1Timer;
  int ability2Timer;
  int maxTimer;

  Player(int x, int y, float xVel, float yVel, float invM, int animationWidth, int animationHeight, int moveIncrement, int jumpIncrement, float leftLimit, float rightLimit, float upperLimit, float lowerLimit, float groundLimit, float velXLimit, int characterIndex, ForceRegistry registry, Gravity gravity, boolean isAI){
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
    this.velXLimit = velXLimit;
    this.health = maxHealth;
    this.isAI = isAI;
    this.maxTimer = 1000;
    this.ability1Timer = this.maxTimer;
    this.ability2Timer = this.maxTimer;
    

    playerBox = new Rectangle2D.Float(this.position.x-hitboxXScale/2, this.position.y+hitboxYScale/2, hitboxXScale, hitboxYScale);
    attackBox = new Rectangle2D.Float((float) playerBox.getX(), (float) playerBox.getY(), (float) playerBox.getWidth(), (float) playerBox.getHeight());

    thisRegistry = registry;
    thisGravity = gravity;

    thisRegistry.add(this, thisGravity);
    state = PlayerState.IDLE;

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

    if(movingLeft && state != PlayerState.DYING){
      if (state != PlayerState.ATTACKING && state != PlayerState.ATTACKING_ABILITY_ONE && state != PlayerState.ATTACKING_ABILITY_TWO && state != PlayerState.STUNNED && state != PlayerState.BLOCKING) 
        state = PlayerState.RUNNING;
      moveLeft();
      facingRight = false;
    } else if(movingRight && state != PlayerState.DYING){
      if (state != PlayerState.ATTACKING && state != PlayerState.ATTACKING_ABILITY_ONE && state != PlayerState.ATTACKING_ABILITY_TWO && state != PlayerState.STUNNED && state != PlayerState.BLOCKING) 
        state = PlayerState.RUNNING;
      moveRight();
      facingRight = true;
    }

    /* //choose idle frames if no other booleans are true */
    /* if((movingLeft || movingRight || attacking || dying || gettingHit || blocking || usingAbility1 || usingAbility2 || usingSpecial)){ */
   
      
    /*   if(movingLeft && !dying){ */
    /*     moveLeft(); */
    /*     facingRight = false; */

    /*   } else if(movingRight && !dying){ */
    /*     moveRight(); */
    /*     facingRight = true; */
    /*   } */
      
    /* } */ 
    /* else if(!isAirborne) { */
    /*   idle = true; */
    /*   //currentFrame = 0; */
    /*   currentFrames = idleFrames; */
    /* } */

    if(!isAirborne && state != PlayerState.DYING && state != PlayerState.ATTACKING_ABILITY_ONE && state != PlayerState.ATTACKING_ABILITY_TWO && state != PlayerState.STUNNED && state != PlayerState.BLOCKING && state != PlayerState.ATTACKING && velocity.x == 0) {
      state = PlayerState.IDLE;
    }

    //if landed on ground or platform
    if((position.y >= groundLimit || checkOnPlatform(platforms)) && isAirborne) {
      isAirborne = false;
      thisRegistry.remove(this, thisGravity);
      this.velocity.y = 0;
    }

    //if walk off platform
    if(!isAirborne && !checkOnPlatform(platforms) && position.y < groundLimit){
      isAirborne = true;
      state = PlayerState.FALLING;
      thisRegistry.add(this, thisGravity);
    }

    if (isAirborne) {
      if (state == PlayerState.ATTACKING) {
        state = PlayerState.AIR_ATTACKING;
      }
      else if (state != PlayerState.AIR_ATTACKING) {
        if (isFalling()) {
          state = PlayerState.FALLING;
        }
        else {
          state = PlayerState.JUMPING;
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
    if (state == PlayerState.ATTACKING && currentFrame == currentFrames.length-1) {
      state = PlayerState.IDLE;
    } 

    if (state == PlayerState.AIR_ATTACKING && currentFrame == currentFrames.length-1) {
      state = PlayerState.IDLE;
    }

    if (state == PlayerState.STUNNED && currentFrame == currentFrames.length-1) {
      state = PlayerState.IDLE;
    }
    
    if (state == PlayerState.ATTACKING_ABILITY_ONE && currentFrame == currentFrames.length-1) {
      ability1Timer = 0;
      state = PlayerState.IDLE;
    }

    if (state == PlayerState.ATTACKING_ABILITY_TWO && currentFrame == currentFrames.length-1) {
      ability2Timer = 0;
      state = PlayerState.IDLE;
    }

    if (state == PlayerState.BLOCKING && currentFrame == currentFrames.length-1) {
      state = PlayerState.IDLE;
    }

    if (state == PlayerState.DYING && currentFrame == currentFrames.length-1) {
      state = PlayerState.IDLE;
    }

    updateHitboxes();
    drawPlayerHitbox();

    if(ability1Timer < maxTimer)
      ability1Timer+= 2.5;
    else if(ability1Timer >= maxTimer)
      ability1Timer = maxTimer;

    if(ability2Timer < maxTimer)
      ability2Timer+= 2.5;
    else if (ability2Timer >= maxTimer)
      ability2Timer = maxTimer;
    
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
      if(state == PlayerState.AIR_ATTACKING){
      thisAttack = attacks.getJSONObject("air");
    } 
    else if (state == PlayerState.ATTACKING_ABILITY_ONE) {
      thisAttack = attacks.getJSONObject("ability1");
      if (!isAI)
        println(thisAttack);
    }
    else if (state == PlayerState.ATTACKING_ABILITY_TWO) {
      thisAttack = attacks.getJSONObject("ability2");
    }
    else {
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
    if(state == PlayerState.STUNNED)
      stroke(0, 255, 0);
    else
      stroke(255, 0, 0);

    rect((float) playerBox.getX(), (float) playerBox.getY(), (float) playerBox.getWidth(), (float) playerBox.getHeight());

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
    String ability1Dir = sketchDir + "textures/"+characterName+"/png/2_atk/";
    String ability2Dir = sketchDir + "textures/"+characterName+"/png/3_atk/";


    idleFrames = loadFrames(idleDir, "idle_", characterName == "monk");
    attackFrames = loadFrames(attackDir, "1_atk_", characterName == "monk");
    runFrames = loadFrames(runDir, "run_", characterName == "monk");
    deathFrames = loadFrames(deathDir, "death_",  characterName == "monk");
    jumpUpFrames = loadFrames(jumpUpDir, "jump_up_", characterName == "monk");
    jumpDownFrames = loadFrames(jumpDownDir, "jump_down_", characterName == "monk");
    hitFrames = loadFrames(hitDir, "take_hit_", characterName == "monk");
    airAtkFrames = loadFrames(airAtkDir, "air_atk_", characterName == "monk");
    blockFrames = loadFrames(blockDir, "defend_", characterName == "monk");
    ability1Frames = loadFrames(ability1Dir, "2_atk_", characterName == "monk");
    ability2Frames = loadFrames(ability2Dir, "3_atk_", characterName == "monk");

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
    if(state != PlayerState.BLOCKING && state != PlayerState.ATTACKING && state != PlayerState.ATTACKING_ABILITY_ONE && state != PlayerState.ATTACKING_ABILITY_TWO){
      state = PlayerState.ATTACKING;
    }
  }

  void useAbility1(){
    if (ability1Timer == maxTimer && state != PlayerState.ATTACKING && state != PlayerState.BLOCKING && state != PlayerState.ATTACKING_ABILITY_ONE && state != PlayerState.ATTACKING_ABILITY_TWO && !isAirborne) {
      state = PlayerState.ATTACKING_ABILITY_ONE;
      //ability1Timer = 0;
    }
  }

  void useAbility2(){
    if (ability2Timer == maxTimer && state != PlayerState.ATTACKING && state != PlayerState.BLOCKING && state != PlayerState.ATTACKING_ABILITY_ONE && state != PlayerState.ATTACKING_ABILITY_TWO && !isAirborne) {
      state = PlayerState.ATTACKING_ABILITY_TWO;
      //ability2Timer = 0;
    }
  }


  void block() {
    if (state != PlayerState.BLOCKING && state != PlayerState.ATTACKING && state != PlayerState.ATTACKING_ABILITY_ONE && state != PlayerState.ATTACKING_ABILITY_TWO && !isAirborne) {
      state = PlayerState.BLOCKING;
    }
  }

  boolean isFalling(){
    return isAirborne && velocity.y > 0;
  }

  void die(){

    state = PlayerState.DYING;
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

  Platform getNearestPlatform(ArrayList<Platform> platforms) {
    Platform minDistancePlatform = null;
    float minDistance = 100000;
    for (Platform platform : platforms) {
      float distance = Math.abs(position.x - platform.position.x);
      if (distance < minDistance) {
        minDistance = distance;
        minDistancePlatform = platform;
      }
    }
    return minDistancePlatform;
  }

  /**
   * Moves the player left
   */
  void moveLeft() {
    if (state != PlayerState.BLOCKING && state != PlayerState.ATTACKING && state != PlayerState.STUNNED) {
      state = PlayerState.RUNNING;
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
    if (state != PlayerState.BLOCKING && state != PlayerState.ATTACKING && state != PlayerState.STUNNED) {
      state = PlayerState.RUNNING;
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
      state = PlayerState.JUMPING;
      thisRegistry.add(this, thisGravity);
    }
    if (position.y <= 0) position.y = 0;
  }

  void getHit(int damage){
    if(state != PlayerState.STUNNED){
      state = PlayerState.STUNNED;
      if(health > 0)        this.health -=damage;
      else                  this.health = 0;
    } 
  }

  void moveLeftToPlayer(PVector otherPos) {
    facingRight = false;
    PVector targetPos = position.copy().sub(otherPos);
    if (velocity.x > -velXLimit) position.x += velocity.x;

    float distance = targetPos.mag() ;
    // If arrived, no acceleration.
    if (distance > TARGET_RADIUS) {
      float targetSpeed = velocity.x;    
      if (distance <= SLOW_RADIUS)
        targetSpeed = velocity.x * distance / SLOW_RADIUS ;

      targetVelocity = targetPos.get() ;
      targetVelocity.normalize() ;
      if (velocity.x >= -velXLimit) velocity.x -= targetVelocity.x / 2.5;
    }

    // Bit of drag
    velocity.x *= DRAG;
    if ((position.x <= leftLimit) || (position.x >= rightLimit)) {
      velocity.x = -velocity.x * 1.5;
    }
  }

  void moveLeftAwayPlayer(PVector otherPos) {
    facingRight = false;
    PVector targetPos = otherPos.copy().sub(position);
    if (velocity.x > -velXLimit) position.x += velocity.x;

    float distance = targetPos.mag() ;
    // If arrived, no acceleration.
    if (distance > TARGET_RADIUS) {
      float targetSpeed = velocity.x;    
      if (distance <= SLOW_RADIUS)
        targetSpeed = velocity.x * distance / SLOW_RADIUS ;

      targetVelocity = targetPos.get() ;
      targetVelocity.normalize() ;
      if (velocity.x >= -velXLimit) velocity.x -= moveIncrement / 8;
    }

    // Bit of drag
    velocity.x *= DRAG;
    if ((position.x <= leftLimit) || (position.x >= rightLimit)) {
      velocity.x = -velocity.x * 1.5;
    }
  }

  void moveRightToPlayer(PVector otherPos) {
    facingRight = true;
    PVector targetPos = otherPos.copy().sub(position);
    if (velocity.x < velXLimit) position.x += velocity.x;

    float distance = targetPos.mag() ;
    // If arrived, no acceleration.
    if (distance > TARGET_RADIUS) {
      float targetSpeed = velocity.x;    
      if (distance <= SLOW_RADIUS)
        targetSpeed = velocity.x * distance / SLOW_RADIUS ;

      targetVelocity = targetPos.get() ;
      targetVelocity.normalize() ;
      if (velocity.x < velXLimit) velocity.x += targetVelocity.x / 2.5;
    }

    // Bit of drag
    velocity.x *= DRAG;
    if ((position.x <= leftLimit) || (position.x >= rightLimit)) {
      velocity.x = -velocity.x * 1.5;
    }
  }

  void moveRightAwayPlayer(PVector otherPos) {
    facingRight = true;
    PVector targetPos = position.copy().sub(otherPos);
    if (velocity.x < velXLimit) position.x += velocity.x;

    float distance = targetPos.mag() ;
    // If arrived, no acceleration.
    if (distance > TARGET_RADIUS) {
      float targetSpeed = velocity.x;    
      if (distance <= SLOW_RADIUS)
        targetSpeed = velocity.x * distance / SLOW_RADIUS ;

      if (velocity.x < velXLimit) velocity.x += moveIncrement / 8;
    }

    // Bit of drag
    velocity.x *= DRAG;
    if ((position.x <= leftLimit) || (position.x >= rightLimit)) {
      velocity.x = -velocity.x * 1.5;
    }
  }

  void moveAI(PVector otherPos, ArrayList<Platform> platforms) {
    float playerDist = dist(position.x, position.y, otherPos.x, otherPos.y);
    if (playerDist > TARGET_RADIUS) {
      if (state != PlayerState.FLEEING) {
        state = PlayerState.RUNNING;
        if (otherPos.x < position.x) {
          moveLeftToPlayer(otherPos);
        } else if (otherPos.x > position.x) {
          moveRightToPlayer(otherPos);
        }
      }
      else {
        if (otherPos.x < position.x) {
          moveRightAwayPlayer(otherPos);
        } else if (otherPos.x > position.x) {
          moveLeftAwayPlayer(otherPos);
        }
      }
      ArrayList<Platform> jumpablePlatforms = getJumpablePlatforms(platforms);
      if (jumpablePlatforms.size() > 0 && otherPos.y + playerBox.getHeight() / 2 < position.y) {
        velocity.x = 0;
        jump();
      }
    }
    else {
      velocity.x = 0;
    }
  }

  void fleeJump(PVector otherPos, ArrayList<Platform> platforms) {
    if (otherPos.y > position.y) {
      Platform nearestPlatform = getNearestPlatform(platforms);
      if (nearestPlatform != null) {
        if (nearestPlatform.position.x < position.x) {
          moveRightToPlayer(new PVector(nearestPlatform.position.x, nearestPlatform.position.y));
        }
        else { 
          moveLeftToPlayer(new PVector(nearestPlatform.position.x, nearestPlatform.position.y)); 
        }
      }
    }
  }

  void updateState() {
    switch (state) {
      case IDLE:
        currentFrames = idleFrames;
        break;
      case ATTACKING:
        currentFrames = attackFrames;
        break;
      case RUNNING:
        currentFrames = runFrames;
        break;
      case DYING:
        currentFrames = deathFrames;
        break;
      case JUMPING:
        currentFrames = jumpUpFrames;
        break;
      case FALLING:
        currentFrames = jumpDownFrames;
        break;
      case STUNNED:
        currentFrames = hitFrames;
        break;
      case AIR_ATTACKING:
        currentFrames = airAtkFrames;
        break;
      case ATTACKING_ABILITY_ONE:
        currentFrames = ability1Frames;
        break;
      case ATTACKING_ABILITY_TWO:
        currentFrames = ability2Frames;
        break;
      case BLOCKING:
        currentFrames = blockFrames;
        break;
    }
  } 

  void findBestState(Player otherPlayer) {
    float playerDist = dist(position.x, position.y, otherPlayer.position.x, otherPlayer.position.y);
    float blockProbablity = random(0, 1);
    float attackProbablity = random(0, 1);
    float fleeProbablity = 0;
    if (health < 50) {
      blockProbablity += random(0, 0.2);
      fleeProbablity = random(0, 1);
    }
    if (playerDist < TARGET_RADIUS) {
      if (fleeProbablity > 0.3) {
        state = PlayerState.FLEEING;
      }
      else {
        velocity.x = 0;
        if (state == PlayerState.FLEEING) {
          state = PlayerState.IDLE;
        }
        if (otherPlayer.state == PlayerState.ATTACKING) {
          if (blockProbablity > 0.7) {
            state = PlayerState.BLOCKING;
          } 
        }
        else if (coolDownFrame + 15 < frameCount) {
          if (attackProbablity > 0.7){
            float attackChoice = random(0, 1);
            
         
          if(attackChoice < 0.8){
              attack();
          } else {
              if(ability1Timer == maxTimer && state != PlayerState.ATTACKING_ABILITY_ONE && state != PlayerState.ATTACKING_ABILITY_TWO && state != PlayerState.ATTACKING)
              useAbility1();
            else if(ability2Timer == maxTimer && state != PlayerState.ATTACKING_ABILITY_ONE && state != PlayerState.ATTACKING_ABILITY_TWO && state != PlayerState.ATTACKING)
              useAbility2();

          }
            coolDownFrame = frameCount;
        }
      }
    }
    }
    else {
      if (fleeProbablity > 0.3) {
        state = PlayerState.FLEEING;
      }
    }
  }
}
