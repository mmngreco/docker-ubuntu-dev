FROM osixia/ubuntu-light-baseimage:0.2.1

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

RUN echo -e "**** install Python ****"
RUN apt update -qq                              \
    && apt install --yes -qq python3            \
                             python3-dev        \
                             python3-virtualenv \
                             python3-venv       \
                             python3-pip        \
    && ln -sf python3 /usr/bin/python           \
    && pip3 install --no-cache -U pip           \
                                  setuptools    \
                                  wheel         \
    && ln -sf pip3 /usr/bin/pip

RUN echo -e "\n\n============ install dev-tools ============"
RUN add-apt-repository ppa:neovim-ppa/stable                          \
    && apt update -qq                                                 \
    && apt install --yes -qq                                          \
           curl                                                       \
           git                                                        \
           neovim                                                     \
           tmux                                                       \
           wget                                                       \
           zsh                                                        \
           git-extras

RUN echo -e "\n\n============ install pyenv ============"       \
    && git clone https://github.com/pyenv/pyenv.git ~/.pyenv    \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc      \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc   \
    && echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zshrc
# Why of below code: https://github.com/pyenv/pyenv/wiki
RUN apt update -qq                                   \
    && apt install --no-install-recommends --yes -qq \
        build-essential                              \
        curl                                         \
        libbz2-dev                                   \
        libffi-dev                                   \
        liblzma-dev                                  \
        libncurses5-dev                              \
        libreadline-dev                              \
        libsqlite3-dev                               \
        libssl-dev                                   \
        libxml2-dev                                  \
        libxmlsec1-dev                               \
        llvm                                         \
        make                                         \
        tk-dev                                       \
        wget                                         \
        xz-utils                                     \
        zlib1g-dev

RUN git clone https://github.com/mmngreco/dotfiles -b ubuntu /root/dotfiles --recurse-submodules
WORKDIR /root/dotfiles
RUN ./install

# Install vim plugings
RUN vim +PlugInstall +qall > /dev/null

RUN echo -e "\n\n============ create git directory ============"
RUN mkdir -p /root/git
WORKDIR /root/git

RUN chsh -s $(which zsh)
RUN /bin/zsh -c "echo Hola"
CMD ["/bin/zsh"]
