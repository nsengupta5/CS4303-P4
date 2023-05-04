final class World {

  int groundHeight;
  
  World(int groundHeight) {
    this.groundHeight = groundHeight;
  }

  void draw() {
    fill(120, 0, 255);
    stroke(120, 0, 255);
    rect(0, displayHeight - groundHeight, displayWidth, displayHeight);
  }

}
