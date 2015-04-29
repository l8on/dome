# dome
`dome` is a processing sketch that controls the lights on the LEDome.

It runs in [Processing 2](https://processing.org/). 
The model of the dome is generated using [HE_Mesh](https://github.com/wblut/HE_Mesh2014). 
The Lights are driven with Mark Slee's wonderful [LX](https://github.com/heronarts/LX) library.

# contributing
Contributions are hella encouraged.

To contribute your own light animations to this repo, you will need to:

* Install [Processing 2](https://processing.org/download) and make sure it runs.
* Fork this repo.
* Clone your version of the repo: 
  
  ```
  [dome]$~ git clone git@github.com:yourgithubname/dome.git .
  ```
* Open `dome.pde` in processing.
* Create a new tab and name the file after yourself. You can see `L8on.pde` in their already.
* Create your pattern classes in your personal file. See `TestPatterns` for a simple-ish example.
* Add your class to the list of patterns in `dome.pde`
* Select your pattern when the simulator runs.
* Rejoice!
