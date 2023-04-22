abstract class Particle {
  
  public PVector position, velocity ;
  PVector forceAccumulator; 
  float invMass ;

  /**
   * Returns the mass of the particle
   */
  public float getMass() {
    return 1/invMass;
  }
  
  /**
   * Creates a particle object
   * @param x The particle's x coordinate
   * @param y The particle's y coordinate
   * @param xVel The particle's x velocity
   * @param yVel The particle's y velocity
   * @param invM The particle's inverse mass
   */
  Particle(int x, int y, float xVel, float yVel, float invM) {
    position = new PVector(x, y) ;
    velocity = new PVector(xVel, yVel) ;
    forceAccumulator = new PVector(0, 0);
    invMass = invM ;    
  }
  
  /**
   * Adds a force to the particle
   * @param force The force to add to the particle
   */
  void addForce(PVector force) {
    forceAccumulator.add(force) ;
  }
  
  /**
   * Integrates the particle's forces and updates its position and velocity
   */
  void integrate() {
    if (invMass <= 0f) return ;
    position.add(velocity) ;
    PVector resultingAcceleration = forceAccumulator.get() ;
    resultingAcceleration.mult(invMass) ;
    velocity.add(resultingAcceleration) ;
    forceAccumulator.x = 0 ;
    forceAccumulator.y = 0 ;    
  }
}
