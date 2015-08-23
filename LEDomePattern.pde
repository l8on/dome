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
  protected void onReset() {}
}

public abstract class LEDomeEffect extends LXEffect {
  protected LEDome model;
  
  protected LEDomeEffect(LX lx) {
    this(lx, false);    
  }
  
  protected LEDomeEffect(LX lx, boolean on) {
    super(lx, on); 
    this.model = (LEDome) lx.model;  
  }

  /**
   * Reset this pattern to its default state.
   */
  public LEDomeEffect reset() {
    for (LXParameter parameter : getParameters()) {
      parameter.reset();
    }
    onReset();
    
    return this;
  }
  
  /**
   * Subclasses may override to add additional reset functionality.
   */
  protected void onReset() {}
}
