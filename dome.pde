/**
 * This is the code to be thrown at LEDome! 
 * 
 * This Processing sketch is a fun place to build animations, effects, and 
 * interactions for the LEDome. Most of the ugly modeling and mapping code 
 * is contained in the LEDome class and setup files.
 * artist, you shouldn't need to worry about any of that.
 *
 * Below, you will find definitions of the Patterns, (and eventually) Effects, 
 * and Interactions.
 *
 * If you're an artist, create a new tab in the Processing environment with
 * your name. Implement your classes there, and add them to the list below.
 */ 
 
LXPattern[] patterns(P2LX lx) {
  return new LXPattern[] {
    // Create New Pattern Instances Below HERE

    // L8on
    new Explosions(lx),
    new SpotLights(lx),
    new Life(lx),
    new L8onMixColor(lx),

    // Test Patterns
    new LayerDemoPattern(lx),
    new IteratorTestPattern(lx).setTransition(new DissolveTransition(lx))
  };
}
