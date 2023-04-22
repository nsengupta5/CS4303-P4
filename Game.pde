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
final int FRAME_RATE = 16;

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

void setup() {
  fullScreen();
  frameRate(FRAME_RATE);

  setupForces();
  setupPlayers();
}


void draw() {
  background(#808080);
  forceRegistry.updateForces();
  player1.integrate();
  player1.draw();
  player2.integrate();
  player2.draw();
  movePlayers();
}

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

  player1 = new Player(player1InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), playerWidth, playerHeight, playerMoveIncrement, playerLeftLimit, playerRightLimit);
  player2 = new Player(player2InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), playerWidth, playerHeight, playerMoveIncrement, playerLeftLimit, playerRightLimit);
  /* forceRegistry.add(player1, gravity); */
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
}

/**
 * Moves the players
 */
void movePlayers() {
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
}

void keyPressed() { 
  switch(key){
    case ' ':
      player1.attack();
      break;
    case 'a':
      player1MovingLeft = true;
      player1.faceLeft();
      break;
    case 'd':
      player1.faceRight();
      player1MovingRight = true;
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
  }

  switch (keyCode) {
    case LEFT:
      player2MovingLeft = false;
      break;
    case RIGHT:
      player2MovingRight = false;
      break;
  }
}
