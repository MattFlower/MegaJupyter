FROM ubuntu:25.04

WORKDIR /app

# Add a user to run the container as
RUN useradd -ms /bin/bash jupyter && \
    mkdir -p /home/jupyter
ENV HOME="/home/jupyter"

RUN apt update &&\
  apt upgrade -y &&\
  apt install -y \
    build-essential \
    clang \
    cmake \
    curl \
    docker.io \
    git \
    golang \
    libbz2-dev \
    libffi-dev \
    libgmp-dev \
    liblzma-dev \
    libopencv-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libzmq5-dev \
    nodejs \
    npm \
    opam \
    openjdk-21-jdk \
    protobuf-compiler \
    python3 \
    python3-pip \
    python3-venv \
    sudo \
    tk-dev \
    unzip \
    wget \
    zlib1g-dev && \
  rm -rf ~/.cache &&\
  apt clean all
#    ocaml \

# Setup a python virtual environment
RUN /usr/bin/python3 -m venv /home/jupyter/env
ENV VIRTUAL_ENV="/home/jupyter/env"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Pip packages
# Rust and GONB (Golang)
# Install rust, because they can't play nicely and create normally sized ubuntu packages
# Javascript, Typescript, WebAssembly (Deno)
# Install gonb, c kernel, evcxr, ganymede (java) kernel
# Language Servers
# Dockerfile support
RUN pip install --no-cache-dir \
    bash_kernel \
    dockerfile-kernel \
    'duckduckgo_search>=6.2' \
    fastai \
    kotlin-jupyter-kernel \
    jupyter \
    jupyter-c-kernel \
    jupyterlab \
    jupyterlab-lsp \
    jupyterlab-vim && \
    pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal && \
    /home/jupyter/.cargo/bin/cargo install evcxr_jupyter --no-default-features && \
    /home/jupyter/.cargo/bin/cargo install cargo-cache && \
    /home/jupyter/.cargo/bin/cargo-cache -a && \
    /usr/bin/go install github.com/janpfeifer/gonb@latest && \
    /usr/bin/go install golang.org/x/tools/cmd/goimports@latest && \
    /usr/bin/go install golang.org/x/tools/gopls@latest && \
    /usr/bin/go clean -cache && \
    curl -fsSL https://deno.land/install.sh | sh -s -- -y && \
    mkdir /tmp/ganymede && \
    /usr/bin/wget https://github.com/allen-ball/ganymede/releases/download/v2.1.2.20230910/ganymede-2.1.2.20230910.jar -O /tmp/ganymede/ganymede.jar && \
    PATH=/home/jupyter/go/bin:${PATH} gonb --install && \
    install_c_kernel && \
    /home/jupyter/.cargo/bin/evcxr_jupyter --install && \
    java -jar /tmp/ganymede/ganymede.jar --install && \
    /home/jupyter/.deno/bin/deno jupyter --install && \
    python -m bash_kernel.install && \
    python -m dockerfile_kernel.install && \
    rm /tmp/ganymede/ganymede.jar && \
    touch package.json && \
    npm install -g \
        bash-language-server \
        dockerfile-language-server-nodejs \
        pyright \
        sql-language-server \
        typescript-language-server \
        unified-language-server \
        vscode-css-languageserver-bin \
        vscode-html-languageserver-bin \
        vscode-json-languageserver-bin \
        yaml-language-server && \
    npm cache clean --force && \
    rm package.json && \
    usermod -aG docker jupyter && \
    curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > /usr/bin/rust-analyzer
ENV PATH="/home/jupyter/.deno/bin:/home/jupyter/.cargo/bin:/home/jupyter/go/bin:${PATH}"

# OCaml Kernel
#RUN opam init --disable-sandboxing && \
#    echo "test -r '/home/jupyter/.opam/opam-init/init.sh' && . '/home/jupyter/.opam/opam-init/init.sh' > /dev/null 2> /dev/null || true" >> /home/jupyter/.profile && \
#    opam install -y jupyter && \
#    grep topfind ~/.ocamlinit || echo '#use "topfind";;' >> /home/jupyter/.ocamlinit && \
#    grep Topfind.log ~/.ocamlinit || echo 'Topfind.log:=ignore;;' >> /home/jupyter/.ocamlinit && \
#    /home/jupyter/.opam/default/bin/ocaml-jupyter-opam-genspec
#RUN jupyter kernelspec install --user --name "ocaml-jupyter-$(opam var switch)" "$(opam var share)/jupyter" && \


# Put sudoers file in place as a workaround to make sure we can reset the user perms for the docker socket
COPY config/jupyter-sudo /etc/sudoers.d/jupyter-sudo
RUN chmod 440 /etc/sudoers.d/jupyter-sudo

# Config file with the default password of "password"
COPY config/jupyter_server_config.json /srv/config/jupyter_server_config.json

# Create some default notebooks to demonstrate different kernels working
RUN mkdir -p /srv/default_notebooks
ARG src="notebooks/Hello Worlds"
ARG dst="/srv/default_notebooks/Hello Worlds"
COPY ${src} ${dst}

# Entrypoint
COPY entrypoint.sh /srv/entrypoint.sh

# Make sure the user has enough permissions, also, cleanup
RUN chown -R jupyter /app && \
    chown -R jupyter /home/jupyter && \
    rm -rf /home/jupyter/.cache && \
    rm -rf /tmp/*

# Now switch to the jupyter user and install all of the kernels
USER jupyter

EXPOSE 8888
ENTRYPOINT ["/srv/entrypoint.sh"]


