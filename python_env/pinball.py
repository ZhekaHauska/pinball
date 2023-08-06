import socket
import atexit
import time
import json
import numpy as np
import subprocess

HOST = "127.0.0.1"
PORT = 5555
TIMEOUT = 600


class Pinball:
    def __init__(
            self,
            exe_path: str = None,
            config_path: str = None,
            headless: bool = True,
            size_x: int = None,
            size_y: int = None,
            host: str = HOST,
            port: int = PORT,
            framerate: int = None,
            sync: bool = False,
            timeout: float = TIMEOUT,
            seed: int = None
    ):
        self.exe_path = exe_path
        self.config_path = config_path
        self.headless = headless
        self.size_x = size_x
        self.size_y = size_y
        self.host = host
        self.port = port
        self.timeout = timeout
        self.seed = seed

        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            while True:
                try:
                    s.bind((self.host, self.port))
                    break

                except OSError:
                    self.port += 1
                    if self.port > 49151:
                        self.port = 1024

            if exe_path is not None:
                self._launch_env(
                    exe_path,
                    config_path,
                    host,
                    self.port,
                    headless,
                    size_x,
                    size_y,
                    framerate,
                    sync,
                    seed
                )

            s.listen(1)
            s.settimeout(self.timeout)

            self.connection, addr = s.accept()
            print(
                f'connected {addr}'
            )

        if self.config_path is not None:
            self.set_config(self.config_path)

        atexit.register(self.close)

    def obs(self):
        message = {
            'type': 'get_obs'
        }
        self._send_as_json(message)
        response = self._get_json_dict()
        assert response['type'] == 'obs'
        obs = self.decode_2d_obs_from_string(
            response['obs'],
            response['shape']
        )
        reward = response['reward']
        is_terminal = response['is_terminal']

        return obs, reward, is_terminal

    def act(self, action):
        message = {
            'type': 'act',
            'action': action
        }
        self._send_as_json(message)

    def step(self):
        message = {
            'type': 'step'
        }
        self._send_as_json(message)

    def reset(self, position=None):
        message = {
            'type': 'reset',
            'position': position
        }
        self._send_as_json(message)

    def set_config(self, config_path):
        message = {
            'type': 'set_config',
            'config_path': config_path
        }
        self._send_as_json(message)

    def set_sensor_size(self, size):
        message = {
            'type': 'set_sensor_size',
            'sizex': size[0],
            'sizey': size[1]
        }
        self._send_as_json(message)

    def close(self):
        message = {
            'type': 'close'
        }
        self._send_as_json(message)
        print("close message sent")
        time.sleep(1.0)
        self.connection.close()
        try:
            atexit.unregister(self.close)
        except Exception as e:
            print("exception unregistering close method", e)

    @staticmethod
    def decode_2d_obs_from_string(
            hex_string,
            shape,
    ):
        return (
            np.frombuffer(bytes.fromhex(hex_string), dtype=np.float16)
            .reshape(shape)
            .astype(np.float32)[:, :, :]  # TODO remove the alpha channel
        )

    def _send_as_json(self, dictionary):
        message_json = json.dumps(dictionary)
        self._send_string(message_json)

    def _get_json_dict(self):
        data = self._get_data()
        return json.loads(data)

    def _send_string(self, string):
        message = len(string).to_bytes(4, "little") + bytes(string.encode())
        self.connection.sendall(message)

    def _get_data(self):
        try:
            data = self.connection.recv(4)
            if not data:
                time.sleep(0.000001)
                return self._get_data()
            length = int.from_bytes(data, "little")
            string = ""
            while (
                    len(string) != length
            ):  # TODO: refactor as string concatenation could be slow
                string += self.connection.recv(length).decode()

            return string
        except socket.timeout as e:
            print("env timed out", e)

        return None

    def _launch_env(
            self,
            env_path,
            config_path,
            host,
            port,
            headless,
            size_x,
            size_y,
            framerate,
            sync,
            seed
    ):
        launch_cmd = f"{env_path}"

        if config_path is not None:
            launch_cmd += f" --config={config_path}"
        if host is not None:
            launch_cmd += f" --host={host}"
        if port is not None:
            launch_cmd += f" --port={port}"
        if headless:
            launch_cmd += " --disable-render-loop --no-window"
        if framerate is not None:
            launch_cmd += f" --fixed-fps {framerate}"
        if sync:
            launch_cmd += f" --sync=true"
        if size_x:
            launch_cmd += f" --sizex={size_x}"
        if size_y:
            launch_cmd += f" --sizey={size_y}"
        if seed is not None:
            launch_cmd += f" --seed={seed}"

        print(launch_cmd)

        launch_cmd = launch_cmd.split(" ")
        self.proc = subprocess.Popen(
            launch_cmd,
            start_new_session=True,
        )
