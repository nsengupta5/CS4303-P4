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
  float playerHeight;
  
  public World(int xVel, int yVel, float invMLower, float invMUpper, int groundHeight, int minNumPlatforms, int maxNumPlatforms, int minPlatformLength, int maxPlatformLength, int blockWidth, int blockHeight, int blockColor, float playerHeight) {
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
    this.playerHeight = playerHeight;
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

  boolean isJumpable(Platform p) {
    if (p.position.y - groundHeight <= playerHeight * 1.3) {
      return true;
    }
    for (Platform platform : platforms) {
      if (abs(p.position.y - platform.position.y) <= playerHeight * 1.3) {
        if (p.position.x + p.platformWidth >= platform.position.x && p.position.x <= platform.position.x + platform.platformWidth)
          return true;
      }
    }
    return false;
  }

  ArrayList<Integer> getPossiblePlatformYs() {
    int segments = (int) ((displayHeight - groundHeight) / playerHeight);
    ArrayList<Integer> possibleY = new ArrayList<Integer>();
    for (int i = segments - 1; i >= 0; i--) {
      possibleY.add(i * (int) playerHeight);
    }
    return possibleY;
  }

  void generatePlatforms() {
    int numPlatforms = (int) random(minNumPlatforms, maxNumPlatforms);
    ArrayList<Integer> possibleY = getPossiblePlatformYs();
    int firstSegment = possibleY.get(possibleY.size() - 1);
    for (int i = 0; i < numPlatforms; i++) {
      int x = (int) random(0, displayWidth);
      int y = (int) random(firstSegment,possibleY.get(0));
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

      if (isCollision || isJumpable(p)) {
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
