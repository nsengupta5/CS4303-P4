final class Block extends Particle {

  int row;
  int blockWidth, blockHeight;
  color blockColor;

  /**
   * Constructor for a Block
   * @param x The block's x coordinate
   * @param y The block's y coordinate
   * @param blockWidth The width of the block
   * @param blockHeight The height of the block
   * @param blockColor The color of the block
   * @param xVel The block's x velocity
   * @param yVel The block's y velocity
   * @param invM The block's inverse mass
   */
  public Block (int x, int y, int blockWidth, int blockHeight, int xVel, int yVel, float invM, int row, color blockColor) {
    super(x, y, xVel, yVel, invM);
    this.row = row;
    this.blockWidth = blockWidth;
    this.blockHeight = blockHeight;
    this.blockColor = blockColor;
  }

  void draw(){
    fill(blockColor);
    stroke(blockColor);
    rect(position.x, position.y, blockWidth, blockHeight);
  }
}
