final class World {

  ArrayList<Platform> platforms;
  int groundHeight;
  int minNumPlatforms;
  int maxNumPlatforms;
  int minPlatformLength;
  int maxPlatformLength;
  int blockWidth, blockHeight;
  color blockColor;
  int particleXVel, particleYVel;
  float particleInvMLower, particleInvMUpper;
  
  public World(int xVel, int yVel, float invMLower, float invMUpper, int groundHeight, int minNumPlatforms, int maxNumPlatforms, int minPlatformLength, int maxPlatformLength, int blockWidth, int blockHeight, int blockColor) {
    this.particleXVel = xVel;
    this.particleYVel = yVel;
    this.particleInvMLower = invMLower;
    this.particleInvMUpper = invMUpper;
    this.groundHeight = groundHeight;
    this.minNumPlatforms = minNumPlatforms;
    this.maxNumPlatforms = maxNumPlatforms;
    this.minPlatformLength = minPlatformLength;
    this.maxPlatformLength = maxPlatformLength;
    this.blockWidth = blockWidth;
    this.blockHeight = blockHeight;
    this.blockColor = blockColor;
    this.platforms = new ArrayList<Platform>();
    generatePlatforms();
  }

  void draw() {
    fill(blockColor);
    stroke(blockColor);
    rect(0, displayHeight - groundHeight, displayWidth, displayHeight);
    for (Platform p : platforms) {
      p.draw();
    }
  }

  void generatePlatforms() {
    int numPlatforms = (int) random(minNumPlatforms, maxNumPlatforms);
    for (int i = 0; i < numPlatforms; i++) {
      int x = (int) random(0, displayWidth);
      int y = (int) random(displayHeight / 2, displayHeight - groundHeight - blockHeight * 3);
      int platformLength = (int) random(minPlatformLength, maxPlatformLength);
      int platformHeight = blockHeight;
      Platform p = new Platform(x, y, particleXVel, particleYVel, particleInvMLower, particleInvMUpper, platformLength, platformHeight, blockWidth, blockHeight, blockColor);

      boolean isCollision = false;
      for (Platform platform : platforms) {
        if (p.collides(platform)) {
          isCollision = true;
          break;
        }
      }

      if (isCollision) {
        i--;
        continue;
      }
      else {
        platforms.add(p);
      }
    }
    
  }

  boolean checkPlatformCollisions(Platform p) {
    for (Platform platform : platforms) {
      if (p.collides(platform)) {
        return true;
      }
    }
    return false;
  }
}
