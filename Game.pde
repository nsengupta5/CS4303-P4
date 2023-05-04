import java.awt.geom.*;

// Particle global variables
final int PARTICLE_INIT_XVEL = 0,
      PARTICLE_INIT_YVEL = 0;

final float PARTICLE_INVM_LOWER_LIM = 0.001f,
      PARTICLE_INVM_UPPER_LIM = 0.005f;

// Forces global variables
final float GRAVITY_STRONG_CONST = 0.3f,
      GRAVITY_MID_CONST = 0.18f,
      GRAVITY_WEAK_CONST = 0.10f,
      WIND_STRONG_CONST = 25f,
      WIND_MID_CONST = 15f,
      WIND_WEAK_CONST = 5f,
      DRAG_CONST = 0.005f,
      USER_FORCE_PROPORTION = 20f;

// World global variables
final int GROUND_OFFSET_PROPORTION = 15;

// Player global variables
final int PLAYER_WIDTH_PROPORTION = 5,
      PLAYER_HEIGHT_PROPORTION = 10,
      PLAYER_INIT_X_PROPORTION = 7,
      PLAYER_INCREMENT_PROPORTION = 150;

// Frame rate
final int FRAME_RATE = 32;

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

void setup() {
  fullScreen();
  frameRate(FRAME_RATE);
  setupPlayers();
  setupForces();
  setupWorld();
}


void draw() {
  background(#0b0b0b);
  forceRegistry.updateForces();
  drawHealthBars();
  world.draw();
  player1.integrate();
  player1.draw();
  player2.integrate();
  player2.draw();
  movePlayers();
}


void drawHealthBars(){
  int proportion = displayWidth/PLAYER_WIDTH_PROPORTION;

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
 * Sets up the players of the game
 */
void setupPlayers() {
  int playerWidth = displayWidth/PLAYER_WIDTH_PROPORTION;
  int playerHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  int groundHeight = displayHeight / GROUND_OFFSET_PROPORTION;
  int player1InitX = displayWidth/PLAYER_INIT_X_PROPORTION - playerWidth/2;
  int player2InitX = displayWidth - displayWidth/PLAYER_INIT_X_PROPORTION - playerWidth/2;
  int playerInitY = displayHeight - groundHeight - playerHeight;

  int playerMoveIncrement = displayWidth/PLAYER_INCREMENT_PROPORTION;
  float playerLeftLimit = 0;
  float playerRightLimit = displayWidth - playerWidth;
  float playerUpLimit = 0;
  float playerDownLimit = displayHeight - groundHeight - playerHeight;

  player1 = new Player(player1InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), playerWidth, playerHeight, playerMoveIncrement, playerLeftLimit, playerRightLimit, playerUpLimit, playerDownLimit);
  player2 = new Player(player2InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), playerWidth, playerHeight, playerMoveIncrement, playerLeftLimit, playerRightLimit, playerUpLimit, playerDownLimit);
}

/**
 * Sets up the world of the game
 */
void setupWorld() {
  int groundHeight = displayHeight / GROUND_OFFSET_PROPORTION;
  world = new World(groundHeight);
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

/**
 * Moves the players
 */
void movePlayers() {
  checkIfAirborne(player1);
  checkIfAirborne(player2);
  // For two player games
  if (player1MovingLeft) {
    player1.moveLeft();
  }
  else if (player1MovingRight) {
    player1.moveRight();
  }

  if (player2MovingLeft) {
    player2.moveLeft();
  }
  else if (player2MovingRight) {
    player2.moveRight();
  }

  if (player1.isJumping) {
    forceRegistry.add(player1, gravity);
    player1.jump();
  }
  if (player2.isJumping) {
    forceRegistry.add(player2, gravity);
    player2.jump();
  }
}

void checkIfAirborne(Player player) {
  if(player.position.y < displayHeight - player.playerHeight - world.groundHeight){
    player.isAirborne = true;
  }
  else{
    player.isAirborne = false;
    forceRegistry.remove(player, gravity);
  }
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
      player1MovingLeft = true;
      player1.faceLeft();
      break;
    case 'd':
      player1.faceRight();
      player1MovingRight = true;
      break;
    case 'w':
      player1.isJumping = true;
      player1.isAirborne = true;
      break;
  }

  switch (keyCode) {
    case LEFT:
      player2MovingLeft = true;
      player2.faceLeft();
      break;
    case RIGHT:
      player2MovingRight = true;
      player2.faceRight();
      break;
    case UP:
      player2.isJumping = true;
      player2.isAirborne = true;
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
      player1MovingLeft = false;
      break;
    case 'd':
      player1MovingRight = false;
      break;
    case 'w':
      player1.isJumping = false;
      player1.isAirborne = false;
      break;'
  }

  switch (keyCode) {
    case LEFT:
      player2MovingLeft = false;
      break;
    case RIGHT:
      player2MovingRight = false;
      break;
    case UP:
      player2.isJumping = false;
      player2.isAirborne = false;
      break;
  }
}



boolean checkHit(Player attacker, Player defender){

  Rectangle2D attackingBox = new Rectangle2D.Float(attacker.position.x, attacker.position.y, attacker.playerWidth, attacker.playerHeight);
  Rectangle2D defendingBox = new Rectangle2D.Float(defender.position.x, defender.position.y, defender.playerWidth, defender.playerHeight);

  if(attackingBox.intersects(defendingBox)){
    return true;
  } else {
    return false;
  }
}
