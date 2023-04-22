public final class Wind extends ForceGenerator {

  private PVector wind ;
  
  /**
   * Constructs the generator with the given force
   * @param wind The force
   */
  Wind(PVector wind) {
    this.wind = wind ;
  }

  /**
   * Sets the wind force and randomly picks a direction
   * @param x The x force
   * @param y The y force
   */
  void set(float x, float y) {
    wind.x = x ;
    wind.y = y ; 
    setRandomDirection();
  }

  /**
   * Sets a random direction for the wind
   */
  void setRandomDirection() {
    float dir = random(1);
    if (dir > 0.5)
      wind.x *= -1;
  }

  /** 
   * Applies the wind force to the given particle
   */
  void updateForce(Particle particle) {
    particle.addForce(wind) ;
  }

  /**
   * Gets the wind's magnitude
   * @return The wind's mag
   */
  float getMag() {
    return wind.mag();
  }

  /**
   * Returns the direction of the wind as a string
   * @return The wind's direction
   */
  String getDirection() {
    String direction = "";
    if (wind.y < 0)
      direction += 'N';
    else if (wind.y < 0)
      direction += 'S';

    if (wind.x > 0)
      direction += 'E';
    else if (wind.x < 0)
      direction += 'W';

    return direction;
  }
}
