/**
 *     DOUBLE BLACK DIAMOND        DOUBLE BLACK DIAMOND
 *
 *         //\\   //\\                 //\\   //\\  
 *        ///\\\ ///\\\               ///\\\ ///\\\
 *        \\\/// \\\///               \\\/// \\\///
 *         \\//   \\//                 \\//   \\//
 *
 *        EXPERTS ONLY!!              EXPERTS ONLY!!
 *
 * This implements the standard `setup` and `draw` methods of a 
 * Processing sketch. It instantiates LEDome model and the sets
 * up the DDP output to the NDB. This file should only be changed 
 * by people who know what their doing.
 */
 
//import java.awt.Dimension;
//import java.awt.Toolkit;

void setupPatterns() {
  LXPattern[] domePatterns = patterns(lx);
  for (LXPattern pattern: domePatterns) {
    LXBus channel = lx.engine.getFocusedChannel();
    if (channel instanceof LXChannel) {
      ((LXChannel)channel).addPattern(pattern);
    } else {
      lx.engine.addChannel(new LXPattern[] { pattern });
    }
  }  
  //lx.setPatterns(domePatterns);
}

void setupEffects() {
  lx.addEffects(effects(lx));  
}

void setupMidiDevices() {
  //LXMidiInput korgNanoControl2Input = null;
  ////LXMidiInput korgNanoControl2Input = lx.engine.midi.matchInput(KorgNanoKontrol2.DEVICE_NAMES);
  //if (korgNanoControl2Input == null) {
  //  println("Midi Remote not connected");
  //  return;
  //}
  
  //nanoKontrol2 = new KorgNanoKontrol2(korgNanoControl2Input);
  //korgNanoControl2Input.addListener(new KorgNanoKontrol2MidiListener(lx, nanoKontrol2));
  //lx.engine.getDefaultChannel().addListener(new KorgNanoKontrol2MidiListener(lx, nanoKontrol2));

  // Listen to each effect to connect the last 4 sliders to the latest effect.
  //for (LXEffect effect: lx.engine.getEffects()) {
  //  effect.enabled.addListener(new KorgNanoKontrol2EffectParameterListener(effect));  
  //}  
}
//void mousePressed() {
//  println("mouseX:" + mouseX + ", mouseY: " + mouseY);
//}