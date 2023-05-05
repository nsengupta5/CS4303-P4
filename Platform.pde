final class Platform {

  ArrayList<Block> blocks;

  PVector position;
  int platformLength;
  int platformWidth;
  int platformHeight;
  int particleXVel, particleYVel;
  int blockWidth, blockHeight;
  color blockColor;
  float particleInvMLower, particleInvMUpper;

  public Platform (int x, int y, int xVel, int yVel, float invMLower, float invMUpper, int pLength, int pHeight, int bWidth, int bHeight, color bColor) {
    position = new PVector(x, y);
    this.blocks = new ArrayList<Block>();
    this.particleXVel = xVel;
    this.particleYVel = yVel;
    this.particleInvMLower = invMLower;
    this.particleInvMUpper = invMUpper;
    this.platformLength = pLength;
    this.platformHeight = pHeight;
    this.blockWidth = bWidth;
    this.blockHeight = bHeight;
    this.blockColor = bColor;
    createPlatform();
  }

  void draw(){
    for (Block block : blocks) {
      block.draw();
    }
  }

  void addBlock(Block block) {
    if (blocks.size() <= platformLength) {
      blocks.add(block);
      platformWidth += block.blockWidth;
    }
  }

  void createPlatform() {
    for (int i = 0; i < platformLength; i++) {
      Block block = new Block((int)position.x + i * blockWidth, (int)position.y, blockWidth, blockHeight, particleXVel, particleYVel, random(particleInvMLower, particleInvMUpper), i, blockColor);
      addBlock(block);
    }
  }

  void removeBlock(Block block) {
    blocks.remove(block);
  }

  boolean collides(Platform p) {
    Rectangle2D pBox = new Rectangle2D.Float(p.position.x, p.position.y, p.platformWidth, p.platformHeight); 
    Rectangle2D thisBox = new Rectangle2D.Float(this.position.x, this.position.y, this.platformWidth, this.platformHeight);
    return pBox.intersects(thisBox);
  }
}
