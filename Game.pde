import java.awt.geom.*;
import java.util.Arrays;

// Particle global variables
final int PARTICLE_INIT_XVEL = 0,
      PARTICLE_INIT_YVEL = 0;

// Logo global variable
final int LOGO_INIT_X_PROPORTION = 3,
          LOGO_INIT_Y_PROPORTION = 6;


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
      PLAYER_VELX_LIMIT = 10;

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
      GAME_SECONDARY = color(108, 172, 156),
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
Gravity gravity;

World world;

Help help;
EndScreen end;
StartScreen start;
boolean endScreen = false;
boolean startScreen = true;
boolean helpScreen = false;

color gamePrimary;
color gameSecondary;
color gameBackground;

PImage backgroundimg;
JSONObject characterJSON;

int playerMoveIncrement;


enum PlayerState {
  IDLE, 
  ATTACKING, 
  RUNNING,
  DYING,
  JUMPING,
  FALLING,
  STUNNED,
  AIR_ATTACKING,
  ATTACKING_ABILITY_ONE,
  ATTACKING_ABILITY_TWO,
  ATTACKING_SPECIAL,
  BLOCKING,
  FLEEING,
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
  if (startScreen) {
    start.draw();
  }
  else if (helpScreen) {
    help.draw();
  }
  else if (endScreen && player1.state != PlayerState.DYING && player2.state != PlayerState.DYING) {
    end.draw();
  }
  else {
    player1.updateState();
    player2.updateState();
    player1.checkHoveringOnPlatform(world.platforms);
    player2.checkHoveringOnPlatform(world.platforms);
    player2.moveAI(player1.position.copy(), world.platforms);
    player2.findBestState(player1);
    player1.getJumpablePlatforms(world.platforms);
    world.draw();
    /* checkPlayerCollision(); */
    checkHit();
    drawHUD();
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

void drawHUD(){



  String[] characters = new String[]{
    "monk",
    "knight",
    "water",
    "leaf",
    "metal",
    "wind"};


  int xproportion = displayWidth/PLAYER_INIT_X_PROPORTION*2;
  int yproportion = displayHeight/PLAYER_INIT_X_PROPORTION*3;

  String p1CharacterName = characters[player1.characterIndex];
  String p2CharacterName = characters[player2.characterIndex];

  String sketchDir = sketchPath("");
  PImage p1Face = loadImage(sketchDir + "textures/" + p1CharacterName + "/" + p1CharacterName + ".png");
  PImage p2Face = loadImage(sketchDir + "textures/" + p2CharacterName + "/" + p2CharacterName + ".png");

  imageMode(CORNER);
  image(p1Face, xproportion/8, yproportion/8, xproportion, yproportion);
  imageMode(CENTER);
  

  //draw player 1 health bar from health out of max health
  stroke(#ff0000);
  noFill();
  rect(xproportion/8, yproportion/3 + yproportion, player1.maxHealth * yproportion/90, yproportion/8);
  stroke(#ff0000);
  fill(#ff0000);
  rect(xproportion/8, yproportion/3 + yproportion, player1.health * xproportion/90, yproportion/8);



stroke(#FEBE00);
noFill();
rect(xproportion/8 + xproportion, yproportion/6 + yproportion, yproportion/8, -player1.maxTimer * yproportion/player1.maxTimer);
rect(xproportion/8 + xproportion*1.3, yproportion/6 + yproportion, yproportion/8, -player1.maxTimer * yproportion/player1.maxTimer);
stroke(#FEBE00);
fill(#FEBE00);
rect(xproportion/8 + xproportion, yproportion/6 + yproportion, yproportion/8, -player1.ability1Timer * yproportion/player1.maxTimer);
rect(xproportion/8 + xproportion *1.3, yproportion/6 + yproportion, yproportion/8, -player1.ability2Timer * yproportion/player1.maxTimer);


      imageMode(CORNER);
      pushMatrix();
      scale( -1, 1 );
      image(p2Face, ((displayWidth) - xproportion/8)*-1, yproportion/8, xproportion, yproportion);
      
      popMatrix();
      imageMode(CENTER);

  //draw player 2 health bar from health out of max health
  stroke(#ff0000);
  noFill();
  rect(displayWidth - xproportion/8 - player2.maxHealth * xproportion/90, yproportion/3 + yproportion, player2.maxHealth * xproportion/90, yproportion/8);
  stroke(#ff0000);
  fill(#ff0000);
  rect(displayWidth - xproportion/8 - player2.health * xproportion/90, yproportion/3 + yproportion, player2.health * xproportion/90, yproportion/8);

stroke(#FEBE00);
noFill();
rect(displayWidth - xproportion/8 - xproportion*1.2, yproportion/6 + yproportion, yproportion/8, -player2.maxTimer * yproportion/player2.maxTimer);
rect(displayWidth  - xproportion*1.6, yproportion/6 + yproportion, yproportion/8, -player2.maxTimer * yproportion/player2.maxTimer);
stroke(#FEBE00);
fill(#FEBE00);
rect(displayWidth - xproportion/8 - xproportion*1.2, yproportion/6 + yproportion, yproportion/8, -player2.ability1Timer * yproportion/player2.maxTimer);
rect(displayWidth - xproportion *1.6, yproportion/6 + yproportion, yproportion/8, -player2.ability2Timer * yproportion/player2.maxTimer);

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
  float startButtonInitX = displayWidth / START_BUTTON_INIT_X_PROPORTION;
  float startButtonInitY = displayHeight / START_BUTTON_INIT_Y_PROPORTION;
  float endButtonInitX = displayWidth / END_BUTTON_INIT_X_PROPORTION;
  float endButtonInitY = displayHeight / END_BUTTON_INIT_Y_PROPORTION;
  int buttonWidth = displayWidth / BUTTON_WIDTH_PROPORTION;
  int buttonHeight = displayHeight / BUTTON_HEIGHT_PROPORTION;
  int buttonGap = displayHeight / BUTTON_GAP_PROPORTION;
  int logoInitX = displayWidth / LOGO_INIT_X_PROPORTION;
  int logoInitY = displayHeight / LOGO_INIT_Y_PROPORTION;
  end = new EndScreen(endButtonInitX, endButtonInitY, buttonWidth, buttonHeight, BUTTON_RADIUS, buttonGap, gamePrimary, gameSecondary, GAME_WHITE, gamePrimary);
  start = new StartScreen(startButtonInitX, startButtonInitY, buttonWidth, buttonHeight, BUTTON_RADIUS, gamePrimary, gameSecondary, GAME_WHITE, buttonGap, logoInitX, logoInitY);
  help = new Help(GAME_WHITE, BUTTON_GAP_PROPORTION);
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
  force = new PVector(0, 0);
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
        if (player1.state != PlayerState.ATTACKING && player1.state != PlayerState.AIR_ATTACKING) {
          player1.attack();
        }
        break;
      case 'a':
      case 'A':
        player1.movingLeft = true;
        player1.state = PlayerState.RUNNING;
        break;
      case 'd':
      case 'D':
        player1.movingRight = true;
        player1.state = PlayerState.RUNNING;
        break;
      case 'W':
      case 'w':
        player1.jump();
        break;
      case 'F':
      case 'f':
        player1.block();
        break;
      case 'E':
      case 'e':
        player1.useAbility1();
        break;
      case 'R':
      case 'r':
        player1.useAbility2();
        break;
      case '/':
        player2.block();
        break;
      case ':':
      case ';':
        player2.useAbility1();
        break;
      case '\'':
      case '@':
      case '"':
        player2.useAbility2();
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
        if (player2.state != PlayerState.ATTACKING && player2.state != PlayerState.AIR_ATTACKING) {
          player2.attack();
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
      player2.state = PlayerState.IDLE;
      player2.velocity.x = 0;
      break;
    case RIGHT:
      player2.movingRight = false;
      player2.state = PlayerState.IDLE;
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
  JSONArray characters = characterJSON.getJSONArray("characters");
  JSONObject p1character = characters.getJSONObject(player1.characterIndex);
  JSONObject p1attacks = p1character.getJSONObject("attacks");
  JSONObject p1thisAttack;

  if(player1.state == PlayerState.AIR_ATTACKING){
    p1thisAttack = p1attacks.getJSONObject("air");
  } 
  else if (player1.state == PlayerState.ATTACKING_ABILITY_ONE) {
    p1thisAttack = p1attacks.getJSONObject("ability1");
  }
  else if (player1.state == PlayerState.ATTACKING_ABILITY_TWO) {
    p1thisAttack = p1attacks.getJSONObject("ability2");
  }
  else {
    p1thisAttack = p1attacks.getJSONObject("normal");  
  }

  int[] p1hitFrames = p1thisAttack.getJSONArray("hitframes").toIntArray();
  int p1damage = p1thisAttack.getInt("damage");

  if((player1.state == PlayerState.ATTACKING || player1.state == PlayerState.ATTACKING_ABILITY_ONE || player1.state == PlayerState.ATTACKING_ABILITY_TWO || player1.state == PlayerState.AIR_ATTACKING)
      && Arrays.stream(p1hitFrames).anyMatch(i -> i == player1.currentFrame)){

    player1.drawAttackHitbox();

    if(player1.attackBox.intersects(player2.playerBox)
        && player2.state != PlayerState.STUNNED){

      if (player2.state == PlayerState.BLOCKING && player2.facingRight != player1.facingRight) {
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

  if(player2.state == PlayerState.AIR_ATTACKING){
    p2thisAttack = p1attacks.getJSONObject("air");
  } 
  else if (player2.state == PlayerState.ATTACKING_ABILITY_ONE) {
    p2thisAttack = p2attacks.getJSONObject("ability1");
  }
  else if (player2.state == PlayerState.ATTACKING_ABILITY_TWO) {
    p2thisAttack = p2attacks.getJSONObject("ability2");
  }
  else {
    p2thisAttack = p2attacks.getJSONObject("normal");  
  }

  int[] p2hitFrames = p2thisAttack.getJSONArray("hitframes").toIntArray();
  int p2damage = p2thisAttack.getInt("damage");

  if((player2.state == PlayerState.ATTACKING || player2.state == PlayerState.ATTACKING_ABILITY_ONE || player2.state == PlayerState.ATTACKING_ABILITY_TWO || player2.state == PlayerState.AIR_ATTACKING)
      && Arrays.stream(p2hitFrames).anyMatch(i -> i == player2.currentFrame)){

    player2.drawAttackHitbox();

    if(player2.attackBox.intersects(player1.playerBox)
        && player1.state != PlayerState.STUNNED){


      if (player1.state == PlayerState.BLOCKING && player1.facingRight != player2.facingRight) {
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

void resetGame() {
  int animationWidth = displayWidth/PLAYER_WIDTH_PROPORTION;
  int animationHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  int player1InitX = animationWidth/2;
  player1.health = 100;
  player2.health = 100;
  player1.position.x = animationWidth/2;
  player2.position.x = displayWidth - animationWidth/2;
  player1.position.y = displayHeight - animationHeight*4;
  player2.position.y = displayHeight - animationHeight*4;
  player1.ability1Timer = player1.maxTimer;
  player1.ability2Timer = player1.maxTimer;
  player2.ability1Timer = player2.maxTimer;
  player2.ability2Timer = player2.maxTimer;
}

/**
 * End screen mouse pressed actions
 */
void endMousePressedActions() {
  if (end.newGameButton.buttonHover) {
    /* // Reset the game */ 
    resetGame();
    endScreen = false;
    /* start.startedGame = true; */
  }
  else if (end.mainMenu.buttonHover) {
    startScreen = true;
    endScreen = false;
  }
  else if (end.endButton.buttonHover) {
    exit();
  }
}

/**
 * Start screen mouse pressed actions
 */
void startMousePressedActions() {
  if (start.startButton.buttonHover && start.startButton.active) {
    // Reset game and load user settings
    resetGame();
    startScreen = false;
    /* loadSettings(); */
    start.startedGame = true;
  }
  else if (start.resumeGameButton.buttonHover && start.resumeGameButton.active) {
    startScreen = false;
  }
  /* else if (start.settingsButton.buttonHover && start.settingsButton.active) { */
  /*   startScreen = false; */
  /*   /1* settingsScreen = true; *1/ */
  /* } */
  else if (start.mainMenuButton.buttonHover && start.mainMenuButton.active) {
    start.startedGame = false;
  }
  else if (start.helpButton.buttonHover) {
    startScreen = false;
    helpScreen = true;
  }
  else if (start.endButton.buttonHover) {
    exit();
  }
}

/**
 * Help screen mouse pressed actions
 */
void helpMousePressedActions() {
  if (mouseX >= displayWidth / 60 && mouseX <= displayWidth / 60 + help.backIcon.width) {
    if (mouseY >= displayHeight / 25 && mouseY <= displayHeight / 25 + help.backIcon.height) {
      helpScreen = false;
      startScreen = true;
    }
  }
}

void mousePressed() {
  if (endScreen) {
    endMousePressedActions();
  }
  if (startScreen) {
    startMousePressedActions();
  }
  if (helpScreen) {
    helpMousePressedActions();
  }
}
