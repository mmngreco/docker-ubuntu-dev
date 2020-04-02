# FROM osixia/ubuntu-light-baseimage:0.2.1
FROM continuumio/miniconda3:4.8.2
ENV PYTHONDONTWRITEBYTECODE=true
ENV PYTHONUNBUFFERED=1

# ============================================================================
# Install python
RUN echo -e "\n\n============ install python ============"
RUN conda install --yes --freeze-installed \
    nomkl \
    numpy \
    pandas \
    && conda clean --all

# ============================================================================
# Install developing tools
RUN echo -e "\n\n============ install dev-tools ============"
RUN apt-get -y install software-properties-common  \
    && apt-get update -qq                          \
    && apt-get install --yes -qq                   \
           build-essential                         \
           curl                                    \
           git                                     \
           git-extras                              \
           neovim                                  \
           tmux                                    \
           wget                                    \
           zsh

# ============================================================================
# Custom configuration
RUN git clone https://github.com/mmngreco/dotfiles -b ubuntu /root/github/mmngreco/dotfiles --recurse-submodules
WORKDIR /root/github/mmngreco/dotfiles
RUN ./install
RUN ./software/create_neovim_env.sh \
    && ./software/install_ag.sh     \
    && ./software/install_fzf.sh

# Install vim plugings
RUN vim +PlugInstall +qall > /dev/null
RUN chsh -s $(which zsh)
# force to run once
RUN /bin/zsh -c "echo Hola"
CMD ["/bin/zsh"]
