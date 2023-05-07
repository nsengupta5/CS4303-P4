final public class State {
  
  PlayerState playerState;
  PImage[] currentFrames;

  public State (PlayerState playerState) {
    this.playerState = playerState;
  }

  public PlayerState getState () {
    return playerState;
  }

  public void setState (PlayerState playerState) {
    this.playerState = playerState;
  }

  void updateState() {
    switch (playerState) {
      case IDLE:
        break;
      case ATTACKING:
        break;
      case DYING:
        break;
    }
  }
}
