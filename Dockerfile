FROM rust:latest

WORKDIR /app
RUN apt update &&\
    rm -rf ~/.cache &&\
    apt clean all &&\
    apt install -y cmake &&\
    apt install -y clang
RUN apt install -y build-essential libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev libreadline-dev libsqlite3-dev libopencv-dev tk-dev git


# install python
ENV HOME="/root"
ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc
RUN eval "$(pyenv init -)"
RUN pyenv install 3.12
RUN pyenv global 3.12

# jupyterlab, evcxr
RUN pip install jupyterlab
RUN cargo install evcxr_jupyter --no-default-features
RUN evcxr_jupyter --install

# Plain old jupyter notebooks
RUN pip install jupyter

# C-Kernel
RUN pip install jupyter-c-kernel
RUN install_c_kernel

# GONB (Golang)
RUN apt install -y golang
RUN /usr/bin/go install github.com/janpfeifer/gonb@latest
RUN /usr/bin/go install golang.org/x/tools/cmd/goimports@latest
RUN /usr/bin/go install golang.org/x/tools/gopls@latest
ENV PATH="/root/go/bin:${PATH}"
RUN /root/go/bin/gonb --install

# Java (Ganymede)
# RUN mkdir /jars
# RUN apt install -y openjdk-17-jdk
# RUN /usr/bin/wget https://github.com/allen-ball/ganymede/releases/download/v2.1.2.20230910/ganymede-2.1.2.20230910.jar -O /jars/ganymede.jar
# RUN /usr/bin/java -jar /jars/ganymede.jar --install --copy-jar=true --user

# Java (IJava)
RUN apt install -y openjdk-17-jdk
RUN mkdir -p /tmp/ijava
RUN wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip -O /tmp/ijava/ijava-1.3.0.zip
RUN unzip /tmp/ijava/ijava-1.3.0.zip -d /tmp/ijava
RUN cd /tmp/ijava && python3 install.py --user

# Javascript, Typescript, WebAssembly (Deno)
RUN apt install -y protobuf-compiler
RUN cargo install deno
RUN deno jupyter --unstable --install

# Bash Kernel
RUN pip install bash_kernel
RUN python -m bash_kernel.install

# OCaml Kernel
RUN apt-get install -y zlib1g-dev libffi-dev libgmp-dev libzmq5-dev ocaml opam
RUN opam init --disable-sandboxing
RUN opam install -y jupyter
RUN grep topfind ~/.ocamlinit || echo '#use "topfind";;' >> ~/.ocamlinit 
RUN grep Topfind.log ~/.ocamlinit || echo 'Topfind.log:=ignore;;' >> ~/.ocamlinit
RUN /root/.opam/default/bin/ocaml-jupyter-opam-genspec
RUN jupyter kernelspec install --user --name "ocaml-jupyter-$(opam var switch)" "$(opam var share)/jupyter"

# Language Servers
RUN apt install -y nodejs npm
RUN pip install jupyterlab-lsp
RUN touch package.json
RUN npm install -g bash-language-server dockerfile-language-server-nodejs pyright sql-language-server typescript-language-server unified-language-server vscode-css-languageserver-bin vscode-html-languageserver-bin vscode-json-languageserver-bin yaml-language-server
RUN curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > /usr/bin/rust-analyzer

# Vim bindings
RUN pip install jupyterlab-vim

EXPOSE 8888

ENTRYPOINT [ "/root/.pyenv/shims/jupyter-lab", "--allow-root", "--ip=0.0.0.0", "--port=8888"]


