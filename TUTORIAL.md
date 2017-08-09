# LEDome Software Setup and Animation Tutorial

The setup is simple and depends only on Processing 3 and git. If you have issues with the setup, submit an issue and I’ll be happy to help you get up and running.
Special thanks to the Dr. Brainlove crew for allowing me to plagiarise their document.

## Setup Instructions
From the top:
* Download the latest version of [Processing 3](https://processing.org/download/)
  because the LEDome software runs in Processing
* If you don’t have it already, download and intall [git](https://git-scm.com/downloads) 
  (also create a free GitHub account if you don't have one already.)
* Visit this repo on GitHub (https://github.com/l8on/dome)
* Fork the repo.
* Clone your version of the repo:
  `[dome]$~ git clone git@github.com:yourgithubname/dome.git .`
* Open `dome.pde` in processing.
* Create a new tab and name the file after yourself. 
* Write some code! See below for an introduction.
* Add an instance of your class to the list of patterns in `dome.pde`
* Select your pattern when the simulator runs (Go ahead and put your current pattern at the top of the list in dome.pde while you are testing it so you won't have to find it each time.)
* When ready to submit your pattern, push your branch back to GitHub
  `[dome]$~ git push origin HEAD`
* Find your branch in GitHub and create a [Pull Request](https://help.github.com/articles/creating-a-pull-request/)
* Tag `@l8on` in the pull request to expedite review.

## Coordinate System

The LEDome software uses (x, y, z) coordinates -- x is left-right, y is up-down, and z is forward-back. 
To figure out the position of a point relative to where it is in the model, you can use model.xMax or model.xMin 
(same for y and z) in the formula (p.x-model.xMin)/(model.xMax-model.xMin). The model is centered at (0,0,0).
Each LXPoint in the points array (which ultimately stores the LED colors each iteration) has attributes x, y, and z. 
Each LEDomeFace has xf(), yf(), zf() methods to get coordinates as floats, and xd(), yf(), zd() methods to get the 
coordinates as doubles. The methods align with the coordinate methods exposed by HE_Mesh - the library that generates 
the geodesic shape.

## How to Write Patterns

Patterns (algorithmic behaviors for the LEDs on the dome) are kept in individual artists files. 
Other than the need to have globally unique names, artists are free to create any patterns and utility classes they like. 
An instance of your pattern is added to list in dome.pde. If you want to poke around in them, the data models for the 
dome are in the `LEDome.pde` and `LEDomeFace.pde` files. 

To write a pattern, first declare a new class which extends the LEDomePattern class and call `super(lx)` in its constructor:
```java
class HelloWorldPattern extends LEDomePattern {
	public HelloWorldPattern(LX lx){
super(lx);
}
}
```

`LEDomePattern` is a simple subclass of `LXPattern`, so anything it supports LEDomePattern supports.
It adds features specific for LEDome: `LEDomePattern` knows that its model is an instance of LEDome, 
and exposes a reset method that resets all parameters to their start values.

Then, add a run loop that iterates through the colors array.
LX likes to work with hue, saturation, and brightness (HSB), though it can convert from RGB if you insist. 
If you’re not familiar with HSB colors, here’s a [quick explanation](http://www.tomjewett.com/colors/hsb.html). 

In the example below:
* `model.points` is the list of all of the points in the model (which have x, y, z attributes to describe their position), 
* `model.xMin` and `model.xMax` (and their y and z analogues) are the lowest and highest x-coordinates of the 3D model in space.
* `double deltaMs` always gets passed into the run loop: it represents the millisecond delay since the last update.
* hue (`h`) is set to 250, which corresponds to blue. The hue is a float between 0 and 360, inclusive.
* Saturation and brightness are floats between 0 and 100, inclusive.
* saturation (`s`) is set to 100 to get the full effect of the color
* brightness (`b`) is set to 70 because full brightness can be harsh on the eyes.  
* Looping through the colors array is how you update the colors displayed by the LEDs. 
  `colors[p.index]` refers to the color of the LED represented by LXPoint p, and LX.hsb is a utility function used to 
  create a color from the 3 separate values.

```java
class BluePattern extends LEDomePattern { 
  public BluePattern(LX lx) {
    super(lx);
  }

	public void run(double deltaMs){
    for (LXPoint p : model.points) {
      float h = 250;
      float s = 100;
      float b = 70;
      colors[p.index] = LX.hsb(h, s, b);
    }
  }
}
```

The last step to get this pattern to work is to add it to the dome's patterns list in dome.pde.
By convention, add your name as a comment above your list of patterns:
```java
LXPattern[] patterns(P2LX lx) {
  return new LXPattern[] {
    // Create New Pattern Instances Below HERE

    // Your Name Here
    new BluePattern(lx),	

    // L8on
    new Explosions(lx),  
    new SpotLights(lx),

    // Test Patterns
    new LayerDemoPattern(lx),
    new FaceIteratorTest(lx),
    new EdgeIteratorTest(lx),
    ...
```

And try running in Processing (the play button on the top left of the window), 
select your pattern in the menu in the bottom of the window that pops up...
and voila! You should have a blue dome.

_Now let’s make it do things._

A great way to make patterns move is by using modulators such as LFO’s (Low Frequency Oscillators). LX has these built into the engine.

Parameters work in tandem with modulators. Parameters allow you to control and change aspects of the animation while it's running.

The example below uses a `SinLFO` (a sine wave low frequency oscillator). There are plenty others though: saw waves, linear envelopes, etc. 
The full list can be found in the LX docs. 

The period of time the LFO takes to oscillate between its minimum and maximum values is controlled by a parameter. 

Let’s write some code. In the snippet below:
* `colorChangeSpeed` is a bounded parameter with which the user can control the speed. 
  It’s labeled “SPD”, starts at 10000, and goes from 5000 to 20000. 
  The value represents an amount of time in milliseconds.
  The order is reversed (20000 is the start of the range, 5000 is the end) so that increasing
  the parameter with a physical knob increases the rate of color change.
* `whatColor` is a sine wave oscillator that oscillates between 0 and 360 (the range of the hue parameter) with a 
  frequency determined by the colorChangeSpeed parameter.
* Both parameters and modulators have to be added to the engine. 
  A convenient place to do that is in the constructor. 
  Modulators need to be triggered so that the value changes over time.
* The hue variable is now determined by the whatColor parameter. 
  The `getValuef()` method returns the value of that oscillator as a float.

```java
class ColorPattern extends LEDomePattern {
  private final BoundedParameter colorChangeSpeed = new BoundedParameter("SPD",  10000, 20000, 5000);
  private final SinLFO whatColor = new SinLFO(0, 360, colorChangeSpeed);
  
  public ColorPattern(LX lx) {
    super(lx);
    addParameter(colorChangeSpeed);
    addModulator(whatColor).trigger();
  }

  public void run(double deltaMs){
    for (LXPoint p : model.points) {
      float h = whatColor.getValuef();
      int s = 100;
      int b = 70;
      colors[p.index] = LX.hsb(h, s, b);
    }
  }
}
```

Run the simulation, and you should see LEDome, changing colors! 
You should see something like the picture to the right -- that knob  that controls the value of `colorChangeSpeed`.

We've only covered the very basics of building animations in LX. Here are some final tips to get you started:
* To keep things simple, always set a color for each and every point in the `run` method. 
  Not doing so leads to surprising behavior.
* Watch your brightness: actual LEDs will be much brighter in real life than in the simulator!
* Try using oscillators and the coordinate system to decide how bright each lights should be.
* Poke around the LX documentation to get a feel for the utility methods and different types of modulators.

## How to hook up patterns to music

The newest trick that LEDome can do involves music. The class `LEDomeAudioParameter` and its subclasses make it
easy to hook your audio up to the average magnitude of a specific frequency ranges:
* `LEDomeAudioParameterLow` - for the bass (da beat)
* `LEDomeAudioParameterMid` - for the mids (voice, acoustic instruments)
* `LEDomeAudioParameterHigh` - for the treble (electric instruments, symbols, claps)
* `LEDomeAudioParameterFull` - for the full audible range

If you are so inclined, you can totally dive into `LXAudioEngine` to use specific aspects of the audio input to alter
your animations, but using these parameters is easy.
In the next example, we've altered our old `ColorPattern` to change color more quickly when there is more overall sound.

```java
class ColorPattern extends LEDomePattern {
  private final LEDomeAudioParameterFull colorChangeSpeed = new LEDomeAudioParameterFull("SPD",  5000, 10000, 0);
  ...
}
```

Yup, that's all that needs to be updated for the color change to be altered by the audio input.

### Musical sensitivity

By default the modulation is subtle (will only alter the parameter by 30% of it's range in a positive direction). 
If that's too restrictive, `LEDomeAudioParameter` can be configured in the following ways: 
* Use `LEDomeAudioParameter#setModulationRange(float modulationRange)` to update how much of the parameter's range 
  can be altered by the audio input. The input is a normalized value between 0 and 1, (.3 for 30%, 1 for 100%), 
  so to remove all subtlety, use `colorChangeSpeed.setModulationRange(1)`
* Use `LEDomeAudioParameter#setModulationPolarity(LXParameter.Polarity polarity)` to change the direction of the 
  modulation such that it can also subtract from the current value instead of always being additive. To change it
  from its `UNIPOLAR` default use `setModulationPolarity(LXParameter.Polarity.BIPOLAR)`
  
So, to remove all subtlety
```java
class UnsubtleColorPattern extends LEDomePattern {
  private final BoundedParameter LEDomeAudioParameterFull = new LEDomeAudioParameterFull("SPD",  10000, 20000, 5000);
  private final SinLFO whatColor = new SinLFO(0, 360, colorChangeSpeed);
  
  public UnsubtleColorPattern(LX lx) {
    super(lx);
    colorChangeSpeed.setModulationRange(1);
    colorChangeSpeed.setModulationPolarity(LXParameter.Polarity.BIPOLAR);
    addParameter(colorChangeSpeed);
    addModulator(whatColor).trigger();
  }

  public void run(double deltaMs){
    for (LXPoint p : model.points) {
      float h = whatColor.getValuef();
      int s = 100;
      int b = 70;
      colors[p.index] = LX.hsb(h, s, b);
    }
  }
}
```

