FROM ubuntu:20.04 AS conan-base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install python3 python3-venv python3-pip \
    && python3 -m venv /venv/conan \
    && /venv/conan/bin/python3 -m pip install wheel \
    && /venv/conan/bin/python3 -m pip install conan

ENV PATH=/venv/conan/bin:${PATH}

ENV DEBIAN_FRONTEND=dialog

FROM conan-base AS cpp-dev-container
ARG USERNAME=coder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install build-essential gdb cmake cppcheck libgtest-dev

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog

RUN useradd -ms /bin/bash ${USERNAME}
USER ${USERNAME}

# Enable new GCC ABI
RUN conan profile new default --detect \
    && conan profile update settings.compiler.libcxx=libstdc++11 default