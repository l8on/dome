class ColorSpiral extends LXPattern {
  private final int minSB = 100;
  private final int faceCount = ((LEDome)model).faces.size();
  private final SawLFO currIndex = new SawLFO(0, faceCount, 5000);

  public ColorSpiral(LX lx) {
    super(lx);
    addModulator(currIndex).start();
  }

  public void run(double deltaMs) {
    int index = (int) currIndex.getValuef();
    int effectiveIndex, satbright;

    for(int i = 0; i < faceCount; i++) {
      LEDomeFace face = ((LEDome)model).faces.get(i);
      effectiveIndex = (i + index) % faceCount;
      satbright = minSB + int((i / float(faceCount)) * (100 - minSB));
      if(!face.hasLights()) {
        continue;
      }
      for(LXPoint p : face.points) {
        colors[p.index] = LX.hsb(effectiveIndex / float(faceCount) * 360, satbright, satbright);
      }
    }
  }
}
