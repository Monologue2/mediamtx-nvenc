# MIT License

# Copyright (c) 2024 Seung Un Yu

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

FROM nvcr.io/nvidia/cuda:12.2.0-devel-ubuntu20.04

# Linux: 550.54.14 or newer
ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul

RUN apt update && \
    apt -y --no-install-recommends install \
    build-essential \
    pkg-config \
    yasm \
    cmake \
    git \ 
    wget \
    checkinstall \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libvorbis-dev \
    libvpx-dev \
    libx264-dev \
    libx265-dev \
    libnuma-dev \
    libfdk-aac-dev \
    libmp3lame-dev \
    libopus-dev \
    libvulkan-dev \
    libdrm-dev

# FFmpeg version of headers required to interface with Nvidias codec APIs.
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd nv-codec-headers && \
    make install

## Get FFmpeg
RUN git clone https://git.ffmpeg.org/ffmpeg.git && \
    cd /ffmpeg && \
     ./configure --enable-nonfree --enable-cuda --enable-cuvid --enable-nvenc \
    --enable-libnpp --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 && \
    make -j$(nproc) && \
    checkinstall --pkgname=ffmpeg-nvenc --pkgversion="4.4" --backup=no --deldoc=yes --fstrans=no --default

# Media Server Dependency
# Get Golang
RUN wget https://go.dev/dl/go1.23.1.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz && \
    export PATH=$PATH:/usr/local/go/bin
ENV PATH=$PATH:/usr/local/go/bin

# Get Mediamtx
RUN git clone https://github.com/bluenviron/mediamtx && \
    cd mediamtx && \
    go generate ./... && \
    CGO_ENABLED=0 go build 

CMD ["/mediamtx/mediamtx"]

