Player player1;
int FRAME_RATE = 16;


void setup() {
    fullScreen();
    frameRate(FRAME_RATE);

    player1 = new Player();



    }


void draw() {
    background(#808080);
    player1.draw();
}


void keyPressed() { 

  switch(key){
    case ' ':
      player1.attack();
      break;
    case 'a':
      player1.faceLeft();
      break;
    case 'd':
      player1.faceRight();
      break;
  }
  }