# Pinball
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
 - `Up/Down arrow` - change magnitude of initial impulse
 - `Space` - apply initial impulse to ball
 
## Saving new configuration

1. Add new `RandomForce` and `Attractor` objects, position and edit them as needed in Godot editor.
2. Run game in debug mode, open settings (`Ctrl+S`) and enter new config path, click "OK" button.

## Python environment
To use the environment in Python programms you can install Python module `python_env/pinball.py` using `python_env/setup.py`.

Control of the environment is through `Pinball` class:
- `obs()` - returns image observation array
- `act([phi float, m float])` - apply impulse with direction `phi` in radians and magnitude `m`
- `step()` - do one simulation step if run with `--sync=true` flag
- `reset()` - return ball to initial position and zero velocity

For more detailed API see the source code.

To run the environment through Python you need to compile an executable file of the environment through Godot editor. The executable has several useful flags:

- `--config=config_path` specify wich configuration you would like to run with
- `--host=ip_addr` and `--port=port` specify ip address and port of the environment that will be used for TCP connection between Python and Godot parts.  
- `--disable-render-loop` and `--no-window` are useful for a headless run.
- `--fixed-fps` breaks real-time synchronization of physics and render, useful for headless rendering.
- `--sync=true/false` if `true`, simulation is paused until the next frame is requested by Python environment.
- `--seed=seed` setup seed to reproduce simulations.

# Related work
Code realisation of interaction between Godot and Python parts of the environment is mostly inspired by [this](https://github.com/edbeeching/godot_rl_agents) repository. 
