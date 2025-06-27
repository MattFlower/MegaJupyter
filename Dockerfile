FROM ubuntu:latest

WORKDIR /app

# Add a user to run the container as
RUN useradd -ms /bin/bash jupyter
RUN mkdir -p /home/jupyter
ENV HOME="/home/jupyter"

RUN apt update &&\
  apt upgrade -y &&\
  rm -rf ~/.cache &&\
  apt clean all &&\
  apt install -y cmake &&\
  apt install -y clang
RUN apt install -y build-essential libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev libreadline-dev libsqlite3-dev libopencv-dev tk-dev git

# Install Rust
RUN apt install -y curl
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/jupyter/.cargo/bin:${PATH}"
RUN rustup default stable

# install python
RUN apt install -y python3-full python3-pip
RUN /usr/bin/python3 -m venv /home/jupyter/env
ENV VIRTUAL_ENV="/home/jupyter/env"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# jupyterlab, evcxr
RUN pip install jupyterlab
RUN cargo install evcxr_jupyter --no-default-features
RUN evcxr_jupyter --install

# Plain old jupyter notebooks
RUN pip install jupyter

# LLM training tools
RUN pip install torch torchvision torchaudio fastai 'duckduckgo_search>=6.2'

# C-Kernel
RUN pip install jupyter-c-kernel
RUN install_c_kernel

# GONB (Golang)
RUN apt install -y golang
RUN /usr/bin/go install github.com/janpfeifer/gonb@latest
RUN /usr/bin/go install golang.org/x/tools/cmd/goimports@latest
RUN /usr/bin/go install golang.org/x/tools/gopls@latest
ENV PATH="/home/jupyter/go/bin:${PATH}"
RUN gonb --install

# Java (Ganymede)
RUN apt install -y wget
RUN mkdir /tmp/ganymede
RUN apt install -y openjdk-21-jdk
RUN /usr/bin/wget https://github.com/allen-ball/ganymede/releases/download/v2.1.2.20230910/ganymede-2.1.2.20230910.jar -O /tmp/ganymede/ganymede.jar
RUN java -jar /tmp/ganymede/ganymede.jar --install

# Javascript, Typescript, WebAssembly (Deno)
RUN apt install -y protobuf-compiler unzip
RUN curl -fsSL https://deno.land/install.sh | sh -s -- -y
ENV PATH="/home/jupyter/.deno/bin:${PATH}"
RUN deno jupyter --install

# Bash Kernel
RUN pip install bash_kernel
RUN python -m bash_kernel.install

# OCaml Kernel
RUN apt-get install -y zlib1g-dev libffi-dev libgmp-dev libzmq5-dev ocaml opam
RUN opam init --disable-sandboxing
RUN opam install -y jupyter
RUN grep topfind ~/.ocamlinit || echo '#use "topfind";;' >> ~/.ocamlinit
RUN grep Topfind.log ~/.ocamlinit || echo 'Topfind.log:=ignore;;' >> ~/.ocamlinit
RUN /home/jupyter/.opam/default/bin/ocaml-jupyter-opam-genspec
RUN jupyter kernelspec install --user --name "ocaml-jupyter-$(opam var switch)" "$(opam var share)/jupyter"

# Kotlin Support
RUN pip install kotlin-jupyter-kernel

# Haskell Support
# Not working
#RUN apt install -y libncurses-dev libzmq3-dev libcairo2-dev libpango1.0-dev libmagic-dev libblas-dev liblapack-dev haskell-stack
#RUN mkdir -p /tmp/
#RUN cd /tmp/ && git clone https://github.com/gibiansky/IHaskell && cd IHaskell && pip install -r requirements.txt
#RUN cd /tmp/IHaskell && stack install --fast
#RUN cd /tmp/IHaskell && ihaskell install

# Dockerfile support
RUN apt install -y nodejs npm
RUN python -m pip install dockerfile-kernel
RUN python -m dockerfile_kernel.install
RUN apt install -y docker.io
RUN usermod -aG docker jupyter

# Language Servers
RUN apt install -y nodejs npm
RUN pip install jupyterlab-lsp
RUN touch package.json
RUN npm install -g \
    bash-language-server \
    dockerfile-language-server-nodejs \
    pyright \
    sql-language-server \
    typescript-language-server \
    unified-language-server \
    vscode-css-languageserver-bin \
    vscode-html-languageserver-bin \
    vscode-json-languageserver-bin \
    yaml-language-server

RUN curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > /usr/bin/rust-analyzer

# Vim bindings
RUN pip install jupyterlab-vim

# Put sudoers file in place as a workaround to make sure we can reset the user perms for the docker socket
RUN apt install -y sudo
COPY config/jupyter-sudo /etc/sudoers.d/jupyter-sudo
RUN chmod 440 /etc/sudoers.d/jupyter-sudo

# Config file with the default password of "password"
COPY config/jupyter_server_config.json /srv/config/jupyter_server_config.json

# Create some default notebooks to demonstrate different kernels working
RUN mkdir -p /srv/default_notebooks
ARG src="notebooks/Hello Worlds"
ARG dst="/srv/default_notebooks/Hello Worlds"
COPY ${src} ${dst}

# Make sure the user has enough permissions
RUN chown -R jupyter /app
RUN chown -R jupyter /home/jupyter

# Entrypoint
COPY entrypoint.sh /srv/entrypoint.sh

# Clean up
RUN rm /app/package.json

# Now switch to the jupyter user and install all of the kernels
USER jupyter

EXPOSE 8888
ENTRYPOINT ["/srv/entrypoint.sh"]


