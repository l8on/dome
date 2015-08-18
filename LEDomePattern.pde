public abstract class LEDomePattern extends LXPattern {
  protected LEDome model;
  
  protected LEDomePattern(LX lx) {
    super(lx);
    this.model = (LEDome) lx.model;
  }
  
  
  /**
   * Reset this pattern to its default state.
   */
  public LEDomePattern reset() {
    for (LXParameter parameter : getParameters()) {
      parameter.reset();
    }
    onReset();
    
    return this;
  }
  
  /**
   * Subclasses may override to add additional reset functionality.
   */
  protected /*abstract*/ void onReset() {}
}
