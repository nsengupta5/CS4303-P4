import java.awt.geom.*;
import java.util.Arrays;

// Particle global variables
final int PARTICLE_INIT_XVEL = 0,
      PARTICLE_INIT_YVEL = 0;

final float PARTICLE_INVM_LOWER_LIM = 0.001f,
      PARTICLE_INVM_UPPER_LIM = 0.005f;

// Forces global variables
final float GRAVITY_STRONG_CONST = 0.3f,
      GRAVITY_MID_CONST = 2.4f,
      GRAVITY_WEAK_CONST = 0.10f,
      WIND_STRONG_CONST = 25f,
      WIND_MID_CONST = 15f,
      WIND_WEAK_CONST = 5f,
      DRAG_CONST = 0.005f,
      USER_FORCE_PROPORTION = 20f;

// World global variables
final int MIN_NUM_PLATFORMS = 15,
      MAX_NUM_PLATFORMS = 20,
      MIN_PLATFORM_LENGTH = 1,
      MAX_PLATFORM_LENGTH = 4,
      BLOCK_WIDTH_PROPORTION = 20,
      BLOCK_HEIGHT_PROPORTION = 20,
      BLOCK_INIT_X_PROPORTION = 4,
      GROUND_OFFSET_PROPORTION = 10;

// Player global variables
final int PLAYER_WIDTH_PROPORTION = 2,
      PLAYER_HEIGHT_PROPORTION = 4,
      PLAYER_INIT_X_PROPORTION = 20,
      PLAYER_MOVE_INCREMENT_PROPORTION = 150,
      PLAYER_JUMP_INCREMENT_PROPORTION = 30,
      PLAYER_VELX_LIMIT = 15;

final float PLAYER_ANIMATION_SCALE = 2.05;

// Screen button global variables
final float START_BUTTON_INIT_X_PROPORTION = 2.25,
      START_BUTTON_INIT_Y_PROPORTION = 2.5,
      SETTINGS_BUTTON_INIT_X_PROPORTION = 2.75,
      SETTINGS_BUTTON_INIT_Y_PROPORTION = 5,
      END_BUTTON_INIT_X_PROPORTION = 2.3,
      END_BUTTON_INIT_Y_PROPORTION = 3.2;

// Button global variables
final int BUTTON_WIDTH_PROPORTION = 8,
      BUTTON_HEIGHT_PROPORTION = 12,
      BUTTON_GAP_PROPORTION = 25,
      BUTTON_RADIUS = 5;

// Color global variables
final color GAME_PRIMARY = color(48,69,41),
            GAME_SECONDARY = color(203, 133, 133),
            GAME_WHITE = color(250, 250, 250),
            GAME_BACKGROUND = color(234, 221, 202);

// Frame rate
final int FRAME_RATE = 26;

Player player1;
Player player2;

boolean player1MovingLeft = false;
boolean player1MovingRight = false;
boolean player2MovingLeft = false;
boolean player2MovingRight = false;

PVector force;
float gravityVal, windLowerVal, windUpperVal;
ForceRegistry forceRegistry;
Wind wind;
Gravity gravity;
Drag drag;

World world;

boolean endScreen = false;
EndScreen end;

color gamePrimary;
color gameSecondary;
color gameBackground;

PImage backgroundimg;
JSONObject characterJSON;

int playerMoveIncrement;


enum PlayerState {
  IDLE, 
  ATTACKING, 
  DYING
}

void setup() {
  fullScreen();
  noSmooth();
  imageMode(CENTER);
  frameRate(FRAME_RATE);
  setupTheme();
  setupWorld();
  setupForces();
  setupPlayers();
  setupScreens();
  backgroundimg = loadImage("textures/Jungle.png","png");
  backgroundimg.resize(displayWidth,displayHeight);

  loadJson();
}


  void loadJson(){
    String sketchDir = sketchPath("");
    String jsonDir = sketchDir + "json/characterStats.json";
    characterJSON = loadJSONObject(jsonDir);
  }





void draw() {
  background(backgroundimg);
  // background(#000000);
  player1.checkHoveringOnPlatform(world.platforms);
  player2.checkHoveringOnPlatform(world.platforms);
  player2.moveAI(player1.position.copy(), world.platforms);
  player1.getJumpablePlatforms(world.platforms);
  if (endScreen && !player1.dying && !player2.dying) {
    end.draw();
  }
  else {
    world.draw();
    /* checkPlayerCollision(); */
    checkHit();
    drawHealthBars();
    forceRegistry.updateForces();
    player1.integrate();
    player1.draw(world.platforms);
    player2.integrate();
    player2.draw(world.platforms);
    /* integrateBlocks(); */
  }
}

void integrateBlocks() {
  for (Platform platform : world.platforms) {
    for (Block block : platform.blocks) {
      block.integrate();
    } 
  }
}

void drawHealthBars(){

  int proportion = displayWidth/PLAYER_INIT_X_PROPORTION*2;

  //draw player 1 health bar from health out of max health
  stroke(#ff0000);
  noFill();
  rect(proportion/3, proportion/3, player1.maxHealth * proportion/75, proportion/8);
  stroke(#ff0000);
  fill(#ff0000);
  rect(proportion/3, proportion/3, player1.health * proportion/75, proportion/8);

  //draw player 2 health bar from health out of max health
  stroke(#ff0000);
  noFill();
  rect(displayWidth - proportion/3 - player2.maxHealth * proportion/75, proportion/3, player2.maxHealth * proportion/75, proportion/8);
  stroke(#ff0000);
  fill(#ff0000);
  rect(displayWidth - proportion/3 - player2.health * proportion/75, proportion/3, player2.health * proportion/75, proportion/8);
}

/**
 * Sets up the theme colors
 */
void setupTheme() {
  gamePrimary = GAME_PRIMARY;
  gameSecondary = GAME_SECONDARY;
  gameBackground = GAME_BACKGROUND;
}

void setupPlayers() {
  int playerWidth = displayWidth/PLAYER_WIDTH_PROPORTION;
  int playerHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  int animationWidth = displayWidth/PLAYER_WIDTH_PROPORTION;
  int animationHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  int groundHeight = displayHeight / GROUND_OFFSET_PROPORTION;
  int player1InitX = animationWidth/2;
  int player2InitX = displayWidth - animationWidth/2;
  int playerInitY = displayHeight - animationHeight*4;

  playerMoveIncrement = displayWidth/PLAYER_MOVE_INCREMENT_PROPORTION;
  int playerJumpIncrement = displayHeight/PLAYER_JUMP_INCREMENT_PROPORTION;  //should be displayHeight?
  float playerLeftLimit = 0;
  float playerRightLimit = displayWidth;
  float playerUpLimit = 0;
  float playerDownLimit = displayHeight - groundHeight - animationHeight / PLAYER_ANIMATION_SCALE;

  player1 = new Player(player1InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), animationWidth, animationHeight, playerMoveIncrement, playerJumpIncrement, playerLeftLimit, playerRightLimit, playerUpLimit, playerDownLimit, playerDownLimit, PLAYER_VELX_LIMIT, 0, forceRegistry, gravity, false);
  player2 = new Player(player2InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), animationWidth, animationHeight, playerMoveIncrement, playerJumpIncrement, playerLeftLimit, playerRightLimit, playerUpLimit, playerDownLimit, playerDownLimit, PLAYER_VELX_LIMIT, 1, forceRegistry, gravity, true);
}

/**
 * Sets up the World
 */
void setupWorld() {
  int blockWidth = displayWidth/BLOCK_WIDTH_PROPORTION;
  int blockHeight = displayHeight/BLOCK_HEIGHT_PROPORTION;
  int groundHeight = displayHeight / GROUND_OFFSET_PROPORTION;
  int animationHeight = displayHeight/ PLAYER_HEIGHT_PROPORTION;
  float playerHeight = animationHeight / PLAYER_ANIMATION_SCALE;
  world = new World(PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, PARTICLE_INVM_LOWER_LIM, PARTICLE_INVM_UPPER_LIM ,groundHeight, MIN_NUM_PLATFORMS, MAX_NUM_PLATFORMS, MIN_PLATFORM_LENGTH, MAX_PLATFORM_LENGTH, blockWidth, blockHeight, gamePrimary, playerHeight);
}

/**
 * Sets up the screens in the game
 */
void setupScreens() {
  float endButtonInitX = displayWidth / END_BUTTON_INIT_X_PROPORTION;
  float endButtonInitY = displayHeight / END_BUTTON_INIT_Y_PROPORTION;
  int buttonWidth = displayWidth / BUTTON_WIDTH_PROPORTION;
  int buttonHeight = displayHeight / BUTTON_HEIGHT_PROPORTION;
  int buttonGap = displayHeight / BUTTON_GAP_PROPORTION;
  end = new EndScreen(endButtonInitX, endButtonInitY, buttonWidth, buttonHeight, BUTTON_RADIUS, buttonGap, gamePrimary, gameSecondary, GAME_WHITE, gamePrimary);
}

/**
 * Sets up the forces used in the game
 */
void setupForces() {
  gravityVal = GRAVITY_MID_CONST;
  windLowerVal = WIND_WEAK_CONST;
  windUpperVal = WIND_MID_CONST;
  forceRegistry = new ForceRegistry() ;  
  gravity = new Gravity(new PVector(0f, gravityVal));
  drag = new Drag(DRAG_CONST, DRAG_CONST);
  wind = new Wind(new PVector(random(windLowerVal,windUpperVal), 0));
  force = new PVector(0, 0);
  // forceRegistry.add(player1, gravity);
  // forceRegistry.add(player2, gravity);
  for (Platform platform : world.platforms) {
    for (Block block : platform.blocks) {
      forceRegistry.add(block, gravity);
    }
  }
}

void keyPressed() { 
  if(!endScreen){
    switch(key){
      case ' ':
      if(!player1.attacking && !player1.airAttacking ){
        player1.attack();
        //checkHit();
            //checkWinner();
      }
        break;
      case 'a':
      case 'A':
        player1.movingLeft = true;
        break;
      case 'd':
      case 'D':
        player1.movingRight = true;
        break;
      case 'W':
      case 'w':
        player1.jump();
        break;
      case 'F':
      case 'f':
        player1.block();
        break;
      case '/':
        player2.block();
        break;
      case 'o':
        player1.swapCharacter = true;
        break;
      case 'p':
        player2.swapCharacter = true;
        break;  
      case 'i':
        player1.loadJson();
        player2.loadJson();
        loadJson();
        break;

      
    }

    switch (keyCode) {
      case LEFT:
        player2.movingLeft = true;
        break;
      case RIGHT:
        player2.movingRight = true;
        break;
      case UP:
        player2.jump();
        break;
      case SHIFT:
      if(!player2.attacking && !player2.airAttacking){
        player2.attack();
        //checkHit();
        //checkWinner();
      }
        break;
    }
   }
}

void keyReleased(){
  switch(key) {
    case 'a':
    case 'A':
      player1.movingLeft = false;
      player1.velocity.x = 0;
      break;
    case 'd':
    case 'D':
      player1.movingRight = false;
      player1.velocity.x = 0;
      break;
  }

  switch (keyCode) {
    case LEFT:
      player2.movingLeft = false;
      player2.velocity.x = 0;
      break;
    case RIGHT:
      player2.movingRight = false;
      player2.velocity.x = 0;
      break;
  }
}

void checkWinner() {
  if (player1.health <= 0) {
    player1.die();
    end.updateWinner("Player 2");
    endScreen = true;
  }
  else if (player2.health <= 0) {
    player2.die();
    end.updateWinner("Player 1");
    endScreen = true;
  }
}

void checkHit(){

  // println("1"+ (player1.attacking));
  // println("2"+ (player1.currentFrame == player1.attackFrames.length/2));
  // println("3"+ (player2.attackBox.intersects(player1.playerBox)));

  // println();
  // println();

      JSONArray characters = characterJSON.getJSONArray("characters");
      JSONObject p1character = characters.getJSONObject(player1.characterIndex);
      JSONObject p1attacks = p1character.getJSONObject("attacks");
      JSONObject p1thisAttack;

      if(player1.airAttacking){
        p1thisAttack = p1attacks.getJSONObject("air");
      } else {
        p1thisAttack = p1attacks.getJSONObject("normal");  
      }


    int[] p1hitFrames = p1thisAttack.getJSONArray("hitframes").toIntArray();
    int p1damage = p1thisAttack.getInt("damage");

  
  if(player1.attacking 
  && Arrays.stream(p1hitFrames).anyMatch(i -> i == player1.currentFrame)){
  
    player1.drawAttackHitbox();
    
    if(player1.attackBox.intersects(player2.playerBox)
    && !player2.gettingHit){

   
    if(player2.blocking && player2.facingRight != player1.facingRight){
        //play block sound effect
    } else {
      player2.getHit(p1damage);
    
    checkWinner();
    }

  }
  }

      JSONObject p2character = characters.getJSONObject(player2.characterIndex);
      JSONObject p2attacks = p2character.getJSONObject("attacks");
      JSONObject p2thisAttack;

      if(player2.airAttacking){
        p2thisAttack = p2attacks.getJSONObject("air");
      } else {
        p2thisAttack = p2attacks.getJSONObject("normal");  
      }


    int[] p2hitFrames = p2thisAttack.getJSONArray("hitframes").toIntArray();
    int p2damage = p2thisAttack.getInt("damage");



  if(player2.attacking
  && Arrays.stream(p2hitFrames).anyMatch(i -> i == player2.currentFrame)){

    player2.drawAttackHitbox();

    if(player2.attackBox.intersects(player1.playerBox)
    && !player1.gettingHit){


    if(player1.blocking && player1.facingRight != player2.facingRight){
      //play block sound effect
    } else {
      player1.getHit(p2damage);

    checkWinner();  
    }
  }

  }



}


void checkPlayerCollision(){
  if(player1.facingRight && player1.movingRight){
    if(player1.playerBox.intersects(player2.playerBox)){
      player1.movingRight = false;
      player1.position.x -= playerMoveIncrement;
      player2.position.x += playerMoveIncrement;
    }
  } else if(!player1.facingRight && player1.movingLeft){
    if(player1.playerBox.intersects(player2.playerBox)){
      player1.movingLeft = false;
      player1.position.x += playerMoveIncrement;
      player2.position.x -= playerMoveIncrement;
    }
  } 
  
  if(player2.facingRight && player2.movingRight){
    if(player2.playerBox.intersects(player1.playerBox)){
      player2.movingRight = false;
      player2.position.x -= playerMoveIncrement;
      player1.position.x += playerMoveIncrement;
    }
  } else if(!player2.facingRight && player2.movingLeft){
    if(player2.playerBox.intersects(player1.playerBox)){
      player2.movingLeft = false;
      player2.position.x += playerMoveIncrement;
      player1.position.x -= playerMoveIncrement;
    }
  }


}
