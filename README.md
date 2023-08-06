# Pinball
Pinball is an environment written on Godot for testing artificial agents.

![pinball user interface](assets/pinball.gif)

## Entities

```
RandomForce:
      angles: [phi1, phi2, ...]
      strength: m
      reward: r
      terminal: is_terminal
```
When ball enters ring area, `RandomFroce` uniformly choses a direction from `angles` and applies impluse of magnitude `m`.

```
Attractor:
      strength: m
      frequency: f
      reward: r
      terminal: is_terminal
```
When ball enters ring area, `Attractor` slowes down the ball and attracts to its center with frequency `f`.

Both entities have fields: 
- `reward` - `r` is amount of reward that agent gets by entering the area
- `terminal` - if `is_terminal==true`, ball resets the environment by entering the area  

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
- `obs()` - returns a tuple: (image observation array, reward, terminal state flag)
- `act([phi float, m float])` - apply impulse with direction `phi` in radians and magnitude `m`
- `step()` - do one simulation step if run with `--sync=true` flag
- `reset(position=None)` - return ball to initial position and zero velocity, if position is not specified, it uses initial position from config file

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
