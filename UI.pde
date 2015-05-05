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
 * This file contains code to draws the dome model and set up 
 * the UI for the simulation. Please do not change this file
 * unless you know what you are doing. 
 */
 
/**
 * Here's a simple extension of a camera component. This will be
 * rendered inside the camera view context. We just override the
 * onDraw method and invoke Processing drawing methods directly.
 */
class UIDome extends UI3dComponent {
  private boolean LABEL_FACES = false; 
  
  protected void onDraw(UI ui, PGraphics pg) {
    HE_Mesh geodome = model.getLEDomeMesh();        
    
    stroke(5);
    render.drawEdges(geodome);
    
    if (LABEL_FACES) {
      stroke(1);
      labelFaces(geodome);
    }    
  }
  
  private void labelFaces(HE_Mesh geodome) {      
    int numFaces = geodome.getNumberOfFaces();
    HE_Face currentFace;
    WB_Point faceCenter;  
    
    for(int i = 0; i < numFaces; i++) {    
      currentFace = geodome.getFaceByIndex(i);
      faceCenter = currentFace.getFaceCenter();
      if (currentFace.getLabel() != -1) {
        pushMatrix();
        text(currentFace.getLabel(), faceCenter.xf(), faceCenter.yf(), faceCenter.zf());
        popMatrix();
      }
    }      
  }
}

class UIEngineControl extends UIWindow {
  
  final UIKnob fpsKnob;
  
  UIEngineControl(UI ui, float x, float y) {
    super(ui, "ENGINE", x, y, UIChannelControl.WIDTH, 96);
        
    y = UIWindow.TITLE_LABEL_HEIGHT;
    new UIButton(4, y, width-8, 20) {
      protected void onToggle(boolean enabled) {
        lx.engine.setThreaded(enabled);
        fpsKnob.setEnabled(enabled);
      }
    }
    .setActiveLabel("Multi-Threaded")
    .setInactiveLabel("Single-Threaded")
    .addToContainer(this);
    
    y += 24;
    fpsKnob = new UIKnob(4, y);    
    fpsKnob
    .setParameter(lx.engine.framesPerSecond)
    .setEnabled(lx.engine.isThreaded())
    .addToContainer(this);
  }
}

class LEDomeNDBOutputControl extends UIWindow { 
  LEDomeNDBOutputControl(UI ui, float x, float y) {
    super(ui, "NDB Output", x, y, UIChannelControl.WIDTH, 50);    
    
    y = UIWindow.TITLE_LABEL_HEIGHT;
    
    new UIButton(4, y, width-8, 20) {
      protected void onToggle(boolean enabled) {
        println("Toggle NDB output: " + enabled);
        output_manager.toggleNDBOutput(enabled);
      }  
    }
    .setInactiveLabel("Output to NDB")
    .setActiveLabel("Disconnect NDB")    
    .addToContainer(this);
  }
}

class LEDomeUIWindow extends UIWindow {
  public BooleanParameter outputNDBParameter = new BooleanParameter("NDB", false);  
  
  LEDomeUIWindow(UI ui, float x, float y) {
    super(ui, "UI COMPONENTS", x, y, 140, 10);       
        
    y = UIWindow.TITLE_LABEL_HEIGHT;    
    
    new UIButton(4, y, width-8, 20)
    .setActiveLabel("Boop!")
    .setInactiveLabel("Momentary Button")
    .setMomentary(true)
    .addToContainer(this);
    y += 24;
        
    for (int i = 0; i < 4; ++i) {
      new UISlider(UISlider.Direction.VERTICAL, 4 + i*34, y, 30, 60)
      .setParameter(new BasicParameter("VSl" + i, (i+1)*.25))
      .setEnabled(i % 2 == 1)
      .addToContainer(this);
    }
    y += 64;
    
    for (int i = 0; i < 2; ++i) {
      new UISlider(4, y, width-8, 24)
      .setParameter(new BasicParameter("HSl" + i, (i + 1) * .25))
      .setEnabled(i % 2 == 0)
      .addToContainer(this);
      y += 28;
    }
    
    new UIToggleSet(4, y, width-8, 24)
    .setParameter(new DiscreteParameter("Ltrs", new String[] { "A", "B", "C", "D" }))
    .addToContainer(this);
    y += 28;
    
    for (int i = 0; i < 4; ++i) {
      new UIIntegerBox(4 + i*34, y, 30, 22)
      .setParameter(new DiscreteParameter("Dcrt", 10))
      .addToContainer(this);
    }
    y += 26;
    
    new UILabel(4, y, width-8, 24)
    .setLabel("This is just a label.")
    .setAlignment(CENTER, CENTER)
    .setBorderColor(ui.theme.getControlDisabledColor())
    .addToContainer(this);
    y += 28;
    
    setSize(width, y);
  }
}
