final class World {

  float groundHeight;
  
  World(float groundHeight) {
    this.groundHeight = groundHeight;
  }

  void draw() {
    fill(120, 0, 255);
    stroke(120, 0, 255);
    rect(0, displayHeight - groundHeight, displayWidth, displayHeight);
  }
}
