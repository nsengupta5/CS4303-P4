/**
 * A force generator that applies a drag force.
 * One instance can be used for multiple particles.
 */
public final class Drag extends ForceGenerator {
  // Velocity drag coefficient
  private float k1 ;
  // Velocity squared drag coefficient
  private float k2 ;
  
  /**
   * Construct generator with the given coefficients
   */
  Drag(float k1, float k2) {
    this.k1 = k1 ;
    this.k2 = k2 ; 
  }
  
  /**
   * Applies the drag force to the given particle
   */
  public void updateForce(Particle particle) {
    PVector force = particle.velocity.get() ;
    
    //Calculate the total drag coefficient
    float dragCoeff = force.mag() ;
    dragCoeff = k1 * dragCoeff + k2 * dragCoeff * dragCoeff ;
    
    //Calculate the final force and apply it
    force.normalize() ;
    force.mult(-dragCoeff) ;
    particle.addForce(force) ;
  }
}
