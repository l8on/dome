public static class LEDomeUtil {
  LEDomeUtil() {
  }
  
  /*
   * Use this to decrease the brightness of a light over `delay` ms.
   * The current color is reduces by the appropriate proportion given   
   * the deltaMs of the current run.   
   */   
  public static float decayed_brightness(color c, float delay,  double deltaMs) {
    float bright_prop = min(((float)deltaMs / delay), 1.0);
    float bright_diff = max((LXColor.b(c) * bright_prop), 1);
    return max(LXColor.b(c) - bright_diff, 0.0);
  }
  
  
  public static float natural_hue_blend(float hueBase, float hueNew) {
    return natural_hue_blend(hueBase, hueNew, 2);    
  }
  
  /**
   * Use this to "naturally" blend colors.   
   * Can be used iteratively on a point as more colors are "mixed" into it, or 
   * used simply with 2 colors.
   * 
   */ 
  public static float natural_hue_blend(float hueBase, float hueNew, int count) {    
    // Return hueA if there is only one hue to mix
    if(count == 1) { return hueBase; }
        
    if(count > 2) {
      // Jump color by 180 before blending again to avoid regression towards the mean (180)
      hueBase = (hueBase + 180) % 360;
    }    
    
    // Blend a with b
    float minHue = min(hueBase, hueNew);
    float maxHue = max(hueBase, hueNew);    
    return (minHue * 2.0 + maxHue / 2.0) / 2.0;    
  }
}

public class OffLayer extends LXLayer {
  private color black = LX.hsb(0, 0, 0);
  
  public OffLayer(LX lx, LXDeviceComponent pattern) {
    super(lx, pattern);
  }
  
  public void run(double deltaMs) {  
    for (LXPoint p : model.points) {
      setColor(p.index, black);  
    }
  }
}


public class BlurLayer extends LXLayer {
  public final BoundedParameter amount;
  private final int[] blurBuffer;

  public BlurLayer(LX lx, LXDeviceComponent pattern) {
    this(lx, pattern, new BoundedParameter("BLUR", 0));
  }

  public BlurLayer(LX lx, LXDeviceComponent pattern, BoundedParameter amount) {    
    super(lx, pattern); 
    this.amount = amount;
    this.blurBuffer = new int[lx.total];
    
    for (int i = 0; i < blurBuffer.length; ++i) {
      this.blurBuffer[i] = 0xff000000;
    }
  }
  
  public void run(double deltaMs) {
    float blurf = this.amount.getValuef();
    if (blurf > 0) {
      blurf = 1 - (1 - blurf) * (1 - blurf) * (1 - blurf);
      for (int i = 0; i < this.colors.length; ++i) {
        int blend = LXColor.screen(this.colors[i], this.blurBuffer[i]);
        this.colors[i] = LXColor.lerp(this.colors[i], blend, blurf);
      }
    }
    for (int i = 0; i < this.colors.length; ++i) {
      this.blurBuffer[i] = this.colors[i];
    }
  }
}

public class TwinkleLayer extends LXLayer {
  private final float E = exp(1);
  private SinLFO[] twinklers = new SinLFO[lx.total];
  private boolean[] twinkleBits;
    
  private BoundedParameter twinkleRate;
  private BoundedParameter maxBrightness;
  
  public TwinkleLayer(LX lx, LXDeviceComponent pattern) {
    this(lx, pattern, new BoundedParameter("RATE", 2.5, 0.5, 12));
  }
  
  public TwinkleLayer(LX lx, LXDeviceComponent pattern, BoundedParameter twinkleRate) {
    this(lx, pattern, twinkleRate, new boolean[lx.total]);
    Arrays.fill(this.twinkleBits, true);    
  }
  
  public TwinkleLayer(LX lx, LXDeviceComponent pattern, BoundedParameter twinkleRate, boolean[] twinkleBits) {
    this(lx, pattern, twinkleRate, twinkleBits, new BoundedParameter("TWBR", 100, 1, 100));    
  }
  
  public TwinkleLayer(LX lx, LXDeviceComponent pattern, BoundedParameter twinkleRate, boolean[] twinkleBits, BoundedParameter maxBrightness) {
    super(lx, pattern);
    this.twinkleRate = twinkleRate;
    this.twinkleBits = twinkleBits;
    this.maxBrightness = maxBrightness;
    this.initTwinklers();
  }
  
  public void run(double deltaMs) {    
    for (LXPoint p : model.points) {
      if(!twinklers[p.index].isRunning()) {
        this.resetTwinkler(p.index);
      }      
      
      // If we've been told not to twinkle this index, don't
      if (!this.twinkleBits[p.index]) { continue; }
            
      double currentBrightness = Math.min(LXColor.b(colors[p.index]), maxBrightness.getValuef());
      double twinkle = norm(-exp(twinklers[p.index].getValuef()), -1/E, -E);
      double brightness = currentBrightness + (twinkle * (maxBrightness.getValuef() - currentBrightness));    
      colors[p.index] = LXColor.hsb(LXColor.h(colors[p.index]), LXColor.s(colors[p.index]), brightness);
    }    
  }
  
  private void initTwinklers() {
    for (int p = 0; p < lx.total; p++) {
      twinklers[p] = new SinLFO(-1, 1, getRate());
      twinklers[p].setLooping(false);
      addModulator(twinklers[p]).start();
    }
  }
  
  public double getRate() {
    float varianceRange = 0.2;
    float rate = twinkleRate.getValuef();
    float variance = random(-varianceRange, varianceRange) * rate;
    return (rate + variance) * SECONDS;
  }
  
  public void resetTwinkler(int p) {
    twinklers[p].setPeriod(getRate());
    twinklers[p].setBasis(random(0.02, 0.15));
    twinklers[p].start();
  }
}