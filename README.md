# pinball
Pinball is an environment written on Godot for testing artificial agents.

![pinball user interface](assets/pinball.gif)

## Entities

```
RandomForce:
      angles: [phi1, phi2, ...]
      strength: m
```
When ball enters ring area, `RandomFroce` uniformly choses a direction from `angles` and applies impluse of magnitude `m`.

```
Attractor:
      strength: m
      frequency: f
```
When ball enters ring area, `Attractor` slowes down the ball and attracts to its center with frequency `f`.


## Control

 - `Ctrl+S` - open or save confgiuration
 - `Ctrl+R` - reset ball to initial position
 - `Left/Right arrow` - change direction of initial impulse
 - `Space` - apply initial impulse to ball
 
## Saving new configuration

1. Add new `RandomForce` and `Attractor` objects, position and edit them as needed.
2. Run game in debug mode, open settings (`Ctrl+S`) and enter config path, click "OK" button.
