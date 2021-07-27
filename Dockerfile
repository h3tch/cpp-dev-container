FROM ubuntu:20.04 AS dev-base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install \
        python3 python3-pip build-essential gdb cmake cppcheck libgtest-dev gcc-10 g++-10 git
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 60 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 40
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog

ARG USERNAME=coder
RUN useradd -ms /bin/bash ${USERNAME}
USER ${USERNAME}
