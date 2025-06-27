#!/bin/sh

# If this is the first time a user is starting the container, add some niceties.
if [ ! -f /home/jupyter/.jupyter/.first_time_setup ]; then
    echo "Copying default notebooks to /app"
    mkdir -p /home/jupyter/env/share/jupyter/lab/notebooks
    cp -rf /srv/default_notebooks/* /app

    if [ ! -f /root/.jupyter/jupyter_server_config.json ]; then
        echo "Setting default password to 'password'"
        mkdir -p /home/jupyter/.jupyter
        cp /srv/config/jupyter_server_config.json /home/jupyter/.jupyter/jupyter_server_config.json
    fi

    touch /home/jupyter/.jupyter/.first_time_setup
fi

echo "Setting ownership of /run/docker.sock to jupyter user"
sudo /bin/chown jupyter:jupyter /run/docker.sock

/home/jupyter/env/bin/jupyter-lab --allow-root --ip=0.0.0.0 --port=8888