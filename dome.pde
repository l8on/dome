import artnetP5.*;

ArtnetP5 artnet;
PImage img;

void setup(){
  size(640, 480);
  artnet = new ArtnetP5();
  img = new PImage(24, 2, PApplet.RGB);
  print("width:" + img.width + "\n");
  print("height:" + img.height + "\n");
}

void draw(){
  int r = mouseX % 255;
  int other_r = 255 - r;
  int g = mouseY % 255;
  int other_g = 255 - g;
  int b = (mouseX + mouseY) % 255;
  int other_b = 255 - b;
  color first_color = color(r, g, b);
  //color first_color = color(0, 173, 242);
  color other_color = color(other_r, other_g, other_b);
  //color other_color = color(4, 82, 111);
  color current_color;

  noStroke();
  fill(first_color);
  rect(0, 0, width, height / 2);

  fill(other_color);
  rect(0, height / 2, width, height / 2);

  current_color = first_color;
  for(int i = 0; i < img.width; i++) {
    if (i % 2 == 0) {
      current_color = first_color;
    } else {
      current_color = other_color;
    }

    for (int j = 0; j < img.height; j++) {
      img.set(i, j, current_color);
    }
  }


  artnet.send(img.pixels, "10.0.0.116");
}
