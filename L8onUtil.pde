/*
 * A container to keep state of the different 3d waves in the color remix.
 */
class L8onWave {
  public static final int DIRECTION_X = 1;
  public static final int DIRECTION_Y = 2;
  public static final int DIRECTION_Z = 3;

  int direction;
  float offset_multiplier;
  float hue_value;

  public L8onWave(int direction, float offset_multiplier) {
    this.direction = direction;
    this.offset_multiplier = offset_multiplier;
  }
}
