# Credits: 
#
#   - http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/
#   - https://github.com/jfrazelle/dockerfiles/blob/master/spotify/Dockerfile
#
# Prepare (example):
# 
#   $ mkdir AnkiDocker
#   $ cd AnkiDocker
#   $ # Save this file to Dockerfile and adapt it to your needs.
#   $ mkdir config
#   $ docker build -t debian-anki .
#
# First run:
#
#   $ docker run -ti --rm -e DISPLAY="unix$DISPLAY" \
#         -v $HOME/.Xauthority:/home/anki-user/.Xauthority \
#         --net=host debian-anki bash
#   (docker)$ fcitx-configtool
#
#   [set up fcitx]
#
# Run (example):
#
#   $ docker run -ti --rm -e DISPLAY=unix$DISPLAY \
#         -v $HOME/Anki:/home/anki-user/Anki \
#         -v $(pwd)/config:/home/anki-user/.config \
#         -v $HOME/.Xauthority:/home/anki-user/.Xauthority \
#         --net=host debian-anki

FROM debian:stable

ARG ANKI_VERSION=2.1.49
ARG LANG=en_US.utf-8
ARG TZ=Pacific/Auckland

ENV ANKI_VERSION ${ANKI_VERSION}
ENV ANKI_DIST anki-${ANKI_VERSION}-linux

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG ${LANG}
ENV TZ ${TZ}
ENV XMODIFIERS @im=fcitx

RUN apt-get update
RUN apt-get install -y aptitude
# Credits: https://wiki.debian.org/Locale
RUN aptitude install -y locales
RUN echo "$LANG UTF-8" >> /etc/locale.gen && locale-gen
RUN aptitude install -y python3 python3-pyqt5 python3-pyqt5.qtwebengine python3-pyqt5.qtwebchannel libqt5core5a python3-distutils python3-bs4 python3-pyaudio python3-requests python3-send2trash python3-decorator python3-markdown python3-jsonschema python3-distro libjs-jquery libjs-jquery-ui libjs-jquery-flot libjs-mathjax
RUN aptitude install -y mpv wget

# fonts-vlgothic is for Japanese fonts. Depending on what you study with
# Anki, you might want to install other packages.
#RUN aptitude install -y fonts-vlgothic 
RUN aptitude install -y fonts-arphic-uming fonts-wqy-zenhei
RUN aptitude install -y fcitx fcitx-chewing fcitx-googlepinyin
RUN aptitude install -y dbus-x11 x11-xkb-utils
#RUN aptitude install -y anki

RUN mkdir -p /build/src/
WORKDIR /build/src
RUN wget https://github.com/ankitects/anki/releases/download/$ANKI_VERSION/$ANKI_DIST.tar.bz2
RUN tar xjf $ANKI_DIST.tar.bz2

WORKDIR /build/src/$ANKI_DIST
RUN bash ./install.sh

# remove apt cache
RUN set -ex \
    && rm -rf /var/lib/apt/lists/*

# Might only work if your host user and group IDs are both 1000.
ENV HOME /home/anki-user
RUN useradd --create-home --home-dir $HOME anki-user \
        && chown -R anki-user:anki-user $HOME

WORKDIR $HOME
USER anki-user

CMD /bin/bash -c "/usr/bin/fcitx-autostart ; anki"

# The MIT License (MIT)
# 
# Copyright (c) 2016 Richard Möhn
# 
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
