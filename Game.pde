import java.awt.geom.*;

// Particle global variables
final int PARTICLE_INIT_XVEL = 0,
      PARTICLE_INIT_YVEL = 0;

final float PARTICLE_INVM_LOWER_LIM = 0.001f,
      PARTICLE_INVM_UPPER_LIM = 0.005f;

// Forces global variables
final float GRAVITY_STRONG_CONST = 0.3f,
      GRAVITY_MID_CONST = 0.88f,
      GRAVITY_WEAK_CONST = 0.10f,
      WIND_STRONG_CONST = 25f,
      WIND_MID_CONST = 15f,
      WIND_WEAK_CONST = 5f,
      DRAG_CONST = 0.005f,
      USER_FORCE_PROPORTION = 20f;

// World global variables
final int GROUND_OFFSET_PROPORTION = 200;

// Player global variables
final int PLAYER_WIDTH_PROPORTION = 2,
      PLAYER_HEIGHT_PROPORTION = 4,
      PLAYER_INIT_X_PROPORTION = 20,
      PLAYER_MOVE_INCREMENT_PROPORTION = 150,
      PLAYER_JUMP_INCREMENT_PROPORTION = 100;

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
final color GAME_PRIMARY = color(71, 45, 44),
            GAME_SECONDARY = color(203, 133, 133),
            GAME_WHITE = color(250, 250, 250),
            GAME_BACKGROUND = color(234, 221, 202);

// Frame rate
final int FRAME_RATE = 24;

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

void setup() {
  fullScreen();
  noSmooth();
  imageMode(CENTER);
  frameRate(FRAME_RATE);
  setupTheme();
  setupPlayers();
  setupForces();
  setupScreens();
  setupWorld();
}


void draw() {
  background(gameBackground);
  if (endScreen) {
    end.draw();
  }
  else {
    world.draw();
    drawHealthBars();
    forceRegistry.updateForces();
    player1.integrate();
    player1.draw();
    player2.integrate();
    player2.draw();
    checkWinner();
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
  int player1InitX = animationWidth;
  int player2InitX = displayWidth - animationWidth;
  int playerInitY = displayHeight - groundHeight - animationHeight;

  int playerMoveIncrement = displayWidth/PLAYER_MOVE_INCREMENT_PROPORTION;
  int playerJumpIncrement = displayWidth/PLAYER_JUMP_INCREMENT_PROPORTION;
  float playerLeftLimit = 0;
  float playerRightLimit = displayWidth;
  float playerUpLimit = 0;
  float playerDownLimit = displayHeight - groundHeight - playerHeight;

  player1 = new Player(player1InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), animationWidth, animationHeight, playerMoveIncrement, playerJumpIncrement, playerLeftLimit, playerRightLimit, playerUpLimit, playerDownLimit, "water");
  player2 = new Player(player2InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), animationWidth, animationHeight, playerMoveIncrement, playerJumpIncrement, playerLeftLimit, playerRightLimit, playerUpLimit, playerDownLimit, "knight");
}

/**
 * Sets up the World
 */
void setupWorld() {
  float animationHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  float groundHeight = displayHeight / GROUND_OFFSET_PROPORTION;
  world = new World(groundHeight);
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

  forceRegistry.add(player1, gravity);
  forceRegistry.add(player2, gravity);
}

void keyPressed() { 
  switch(key){
    case ' ':
      player1.attack();      
      if(checkHit(player1, player2)){
        if(player2.health > 0) player2.health -=10;
        else player2.health = 0;
      }  
      break;
    case 'a':
      player1.movingLeft = true;
      break;
    case 'd':
      player1.movingRight = true;
      break;
    case 'w':
      if (!player1.isAirborne)
        player1.jump();
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
      if (!player2.isAirborne)
        player2.jump();
      break;
    case SHIFT:
      player2.attack();
      if(checkHit(player2, player1)){
        if(player1.health > 0) player1.health -=10;
        else player1.health = 0;
      }
      break;
  }
}

void keyReleased(){
  switch(key) {
    case 'a':
      player1.movingLeft = false;
      break;
    case 'd':
      player1.movingRight = false;
      break;
  }

  switch (keyCode) {
    case LEFT:
      player2.movingLeft = false;
      break;
    case RIGHT:
      player2.movingRight = false;
      break;
  }
}

void checkWinner() {
  if (player1.health <= 0) {
    end.updateWinner("Player 2");
    endScreen = true;
  }
  else if (player2.health <= 0) {
    end.updateWinner("Player 1");
    endScreen = true;
  }
}

boolean checkHit(Player attacker, Player defender){

  Rectangle2D attackingBox = new Rectangle2D.Float(attacker.position.x, attacker.position.y, attacker.animationWidth, attacker.animationHeight);
  Rectangle2D defendingBox = new Rectangle2D.Float(defender.position.x, defender.position.y, defender.animationWidth, defender.animationHeight);

  if(attackingBox.intersects(defendingBox)){
    return true;
  } else {
    return false;
  }
}
