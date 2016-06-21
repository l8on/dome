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
  private boolean LABEL_EDGES = false; 
  
  protected void onDraw(UI ui, PGraphics pg) {
    HE_Mesh geodome = model.getLEDomeMesh();      

    if (RENDER_3D) {
      stroke(5);
      render.drawEdges(geodome);
    }

    if (RENDER_3D && LABEL_FACES) {
      stroke(1);
      labelFaces(geodome);
    }

    if (RENDER_3D && LABEL_EDGES) {
      stroke(1);      
      labelEdges();
    }    
  }
  
  private void labelFaces(HE_Mesh geodome) {      
    int numFaces = geodome.getNumberOfFaces();
    HE_Face currentFace;
    WB_Point faceCenter;
    PFont labelFont = createFont("SansSerif", 8, true);  
    textFont(labelFont);
    textAlign(CENTER, CENTER); 
    
    pushMatrix();
    scale(1, -1, 1);
    
    for(int i = 0; i < numFaces; i++) {    
      currentFace = geodome.getFaceByIndex(i);
      faceCenter = currentFace.getFaceCenter();
      if (currentFace.getLabel() != -1) {                               
        text(currentFace.getLabel(), faceCenter.xf(), -1 * faceCenter.yf(), faceCenter.zf());        
      }
    }

    popMatrix();
  }
  
  private void labelEdges() {      
    int numEdges = model.edges.size();
    PFont labelFont = createFont("SansSerif", 7, true);  
    textFont(labelFont);  
    textAlign(CENTER, CENTER);
    
    pushMatrix();
    scale(1, -1);
    
    for(int i = 0; i < numEdges; ++i) {  
      LEDomeEdge edge = model.edges.get(i);
      LXPoint middlePoint = edge.points.get(1);   
            
      text(i, middlePoint.x, -1 * middlePoint.y, middlePoint.z);
    }
    
    popMatrix();
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
        outputManager.toggleNDBOutput(enabled);
      }  
    }
    .setInactiveLabel("Output to NDB")
    .setActiveLabel("Disconnect NDB")
    .setParameter(ndbOutputParameter)    
    .addToContainer(this);
  }
}
