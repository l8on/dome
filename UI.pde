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
    
  @Override
  protected void onDraw(UI ui, PGraphics pg) {
    HE_Mesh geodome = model.getLEDomeMesh();            
  
    if (RENDER_3D) {
      pg.stroke(5);
      render = new WB_Render((PGraphics3D)pg);      
      render.drawEdges(geodome);
    }

    if (RENDER_3D && LABEL_FACES) {
      pg.stroke(1);
      labelFaces(geodome, pg);
    }

    if (RENDER_3D && LABEL_EDGES) {
      pg.stroke(1);      
      labelEdges(pg);
    }   
  }
  
  @Override
  protected void endDraw(UI ui, PGraphics pg) {
    pg.noLights();
  }
  
  private void labelFaces(HE_Mesh geodome, PGraphics pg) {      
    int numFaces = geodome.getNumberOfFaces();
    HE_Face currentFace;
    WB_Point faceCenter;
    PFont labelFont = createFont("SansSerif", 5, true);  
    pg.textFont(labelFont);
    pg.textAlign(CENTER, CENTER); 
    
    pg.pushMatrix();
    pg.scale(1, -1, 1);
    
    for(int i = 0; i < numFaces; i++) {                
      currentFace = geodome.getFaceByIndex(i);
      faceCenter = currentFace.getFaceCenter();           
      if (currentFace.getLabel() != -1) {       
        pg.text(currentFace.getLabel(), faceCenter.xf(), -1 * faceCenter.yf(), faceCenter.zf());        
      }
    }

    pg.popMatrix();
  }
  
  private void labelEdges(PGraphics pg) {      
    int numEdges = model.edges.size();
    PFont labelFont = createFont("SansSerif", 7, true);  
    pg.textFont(labelFont);  
    pg.textAlign(CENTER, CENTER);
    
    pg.pushMatrix();
    pg.scale(1, -1);
    
    for(int i = 0; i < numEdges; ++i) {  
      LEDomeEdge edge = model.edges.get(i);
      LXPoint middlePoint = edge.points.get(1);   
            
      pg.text(i, middlePoint.x, -1 * middlePoint.y, middlePoint.z);
    }
    
    pg.popMatrix();
  }  
}