FROM osixia/ubuntu-light-baseimage:0.2.1
ENV PYTHONDONTWRITEBYTECODE=true
ENV PYTHONUNBUFFERED=1

# ============================================================================
# Install developing tools
RUN echo -e "\n\n ============ install dev-tools ============ \n\n"
RUN add-apt-repository ppa:neovim-ppa/stable \
    && apt update -qq                        \
    && apt install --yes -qq                 \
           build-essential                   \
           curl                              \
           git                               \
           git-extras                        \
           neovim                            \
           software-properties-common        \
           tmux                              \
           wget                              \
           zsh

# ============================================================================
# Install python
RUN echo -e "\n\n ============ install python ============ \n\n"
ENV CONDA_DIR=/root/miniconda3
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -O miniconda.sh                                                               \
    && chmod +x miniconda.sh                                                      \
    && ./miniconda.sh -b -p $CONDA_DIR                                         \
    && rm ./miniconda.sh                                                          \
    && $CONDA_DIR/bin/conda init bash                                          \
    && $CONDA_DIR/bin/conda init zsh                                           \
    && $CONDA_DIR/bin/conda clean --all

# ============================================================================
# Custom configuration
SHELL ["/bin/bash", "-c"]
RUN echo -e "\n\n ============ install dotfiles ============ \n\n"
ENV DOTFILES=/root/github/mmngreco/dotfiles
RUN git clone https://github.com/mmngreco/dotfiles           \
    -b ubuntu $DOTFILES --recurse-submodules                 \
    && $DOTFILES/install                                     \
    && $CONDA_DIR/bin/conda init bash                        \
    && $CONDA_DIR/bin/conda init zsh                         \
    && $CONDA_DIR/bin/conda create -n neovim python=3.7 -y   \
    && $CONDA_DIR/envs/neovim/bin/python -s -m pip install   \
        "python-language-server[all]"                        \
        notedown                                             \
        pynvim                                               \
    && $DOTFILES/software/setup_tmux_plugins.sh              \
    && $DOTFILES/software/install_ag.sh

RUN echo -e "\n\n ============ install vim plugins ============ \n\n"
# Install vim plugings
RUN vim +PlugInstall +qall > /dev/null
RUN chsh -s $(which zsh)
# force to run once
RUN /bin/zsh -c "echo hello, world!"
CMD ["/bin/zsh"]
