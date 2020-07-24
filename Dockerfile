FROM ubuntu:20.04
ARG USERNAME=coder

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install build-essential gdb cmake cppcheck libgtest-dev

    # Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

RUN useradd -ms /bin/bash ${USERNAME}
USER ${USERNAME}