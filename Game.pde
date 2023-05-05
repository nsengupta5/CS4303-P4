import java.awt.geom.*;


// Particle global variables
final int PARTICLE_INIT_XVEL = 0,
      PARTICLE_INIT_YVEL = 0;

final float PARTICLE_INVM_LOWER_LIM = 0.001f,
      PARTICLE_INVM_UPPER_LIM = 0.005f;

// Forces global variables
final float GRAVITY_STRONG_CONST = 0.3f,
      GRAVITY_MID_CONST = 1f,
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
      PLAYER_JUMP_INCREMENT_PROPORTION = 50;

    

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

void setup() {
  fullScreen();
  noSmooth();
  imageMode(CENTER);
  frameRate(FRAME_RATE);
  setupPlayers();
  setupForces();
  setupWorld();
}


void draw() {
  background(#808080);
  drawHealthBars();
  player1.checkIfAirborne(forceRegistry, gravity);
  player2.checkIfAirborne(forceRegistry, gravity);

  forceRegistry.updateForces();
  player1.integrate();
  player1.draw();
  player2.integrate();
  player2.draw();
  drawHitboxes();
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

void setupPlayers() {
  int playerWidth = displayWidth/PLAYER_WIDTH_PROPORTION;
  int playerHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  int animationWidth = displayWidth/PLAYER_WIDTH_PROPORTION;
  int animationHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  int groundHeight = displayHeight / GROUND_OFFSET_PROPORTION;
  int player1InitX = animationWidth/2;
  int player2InitX = displayWidth - animationWidth/2;
  int playerInitY = displayHeight - groundHeight - animationHeight;

  int playerMoveIncrement = displayWidth/PLAYER_MOVE_INCREMENT_PROPORTION;
  int playerJumpIncrement = displayWidth/PLAYER_JUMP_INCREMENT_PROPORTION;
  float playerLeftLimit = 0;
  float playerRightLimit = displayWidth;
  float playerUpLimit = 0;
  float playerDownLimit = displayHeight - groundHeight - playerHeight;

  player1 = new Player(player1InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), animationWidth, animationHeight, playerMoveIncrement, playerJumpIncrement, playerLeftLimit, playerRightLimit, playerUpLimit, playerDownLimit, 0);
  player2 = new Player(player2InitX, playerInitY, PARTICLE_INIT_XVEL, PARTICLE_INIT_YVEL, random(PARTICLE_INVM_LOWER_LIM,PARTICLE_INVM_UPPER_LIM), animationWidth, animationHeight, playerMoveIncrement, playerJumpIncrement, playerLeftLimit, playerRightLimit, playerUpLimit, playerDownLimit, 1);
}

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

void keyPressed() { 
  switch(key){
    case ' ':
    if(!player1.attacking){
      player1.attack();
      checkHit();
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
    case 'e':
      player1.swapCharacter = true;
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
    if(!player2.attacking){
      player2.attack();
      checkHit();
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



void checkHit(){


  if(player1.attacking && player1.attackBox.intersects(player2.playerBox) ){


    if(player2.health > 0)        player2.health -=10;
    else                          player2.health = 0;
      


  } 
  
  if (player2.attacking && player2.attackBox.intersects(player1.playerBox)) {


    if(player1.health > 0) player1.health -=10;
    else                    player1.health = 0;
      

  }



}

void drawHitboxes(){
  if(player1.attacking || player2.attacking){
  if(player1.attacking && player1.attackBox.intersects(player2.playerBox) ){
    player1.drawHitbox(false);
    player2.drawHitbox(true);

  } 
  if (player2.attacking && player2.attackBox.intersects(player1.playerBox)) {
    player1.drawHitbox(true);
    player2.drawHitbox(false);

  } 
}
  else {
    player1.drawHitbox(false);
    player2.drawHitbox(false);
  }
  

}
