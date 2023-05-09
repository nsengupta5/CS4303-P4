import java.util.Iterator ;

class ForceRegistry {
  
  /**
   * A registrations class to keep track of a particle's registered forces
   */
  class ForceRegistration {
    public final Particle particle ;
    public final ForceGenerator forceGenerator ;

    /*
     * Creates a new ForceRegistration
     * @param p The particle
     * @param fg The force generator to apply to the particle
     */
    ForceRegistration(Particle p, ForceGenerator fg) {
      particle = p ;
      forceGenerator = fg ; 
    }
  }
  
  ArrayList<ForceRegistration> registrations = new ArrayList() ;
  
  /**
   * Adds a registration
   * @param p The particle
   * @param fg The force to be apply to the particle
   */
  void add(Particle p, ForceGenerator fg) {
    registrations.add(new ForceRegistration(p, fg)) ; 
  }

  /**
   * Removes a registration
   * @param p The particle
   * @param fg The force to be removed from the particle
   */
  void remove(Particle p, ForceGenerator fg) {
    for (int i = registrations.size() - 1; i >= 0; i--) {
      ForceRegistration fr = registrations.get(i);
      if (fr.particle.equals(p) && fr.forceGenerator.equals(fg))
        registrations.remove(fr);
    }
  }

  /**
   * Clears all registrations
   */
  void clear() {
    registrations.clear() ; 
  }
  
  /**
   * Updates each particle with their corresponding force
   */
  void updateForces() {
    Iterator<ForceRegistration> itr = registrations.iterator() ;
    while(itr.hasNext()) {
      ForceRegistration fr = itr.next() ;
      fr.forceGenerator.updateForce(fr.particle) ;
    }
  }
}
