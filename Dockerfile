#Links :
#http://beta.unity3d.com/download/ee86734cf592/unity-editor-installer-2017.2.0f3.sh
#http://beta.unity3d.com/download/ee86734cf592/unity-editor_amd64-2017.2.0f3.deb

FROM ubuntu:16.10

MAINTAINER jcardoso 

ARG PACKAGE="/usr/src/unity-editor_amd64-2017.2.0f3.deb"
ARG VIDEO_GID

RUN apt-get update

WORKDIR unity3d
COPY unity-editor_amd64-2017.2.0f3.deb /usr/src/

#Resolve missing dependencies
RUN dpkg -i ${PACKAGE} || apt-get -f install -y

#Install unity3d
RUN dpkg -i ${PACKAGE}

RUN apt-get install sudo

# Add the gamedev user
RUN useradd -ms /bin/bash gamedev && \
    chmod 0660 /etc/sudoers && \
    echo "gamedev ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chmod 0440 /etc/sudoers && \
    usermod -aG video gamedev && \
    #groupadd -g ${VIDEO_GID} unity3ddockervideo && \
    groupadd unity3ddockervideo && \
    usermod -aG unity3ddockervideo gamedev

# this is a requirement by chrome-sandbox
RUN chown root /opt/Unity/Editor/chrome-sandbox
RUN chmod 4755 /opt/Unity/Editor/chrome-sandbox

RUN apt-get clean
RUN rm ${PACKAGE}

ADD  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /src/google-chrome-stable_current_amd64.deb

# Install Chromium
RUN mkdir -p /usr/share/icons/hicolor && \
	apt-get update && apt-get install -y \
	ca-certificates \
  	fonts-liberation \
	gconf-service \
	hicolor-icon-theme \
	libappindicator1 \
	libasound2 \
	libcanberra-gtk-module \
	libcurl3 \
  	libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 \
	libexif-dev \
	libgconf-2-4 \
	libgl1-mesa-dri \
	libgl1-mesa-glx \
	libnspr4 \
	libnss3 \
	libpango1.0-0 \
	libgtk-3-0:amd64 \
	libgtk-3-bin \
	libgtk-3-common \
	libv4l-0 \
  	libxcb1 \
  	libxcb-render0 \
  	libxcb-shm0 \
	libxss1 \
	libxtst6 \
  	mono-complete \
  	monodevelop \
	wget \
	xdg-utils \
	--no-install-recommends && \
	dpkg -i '/src/google-chrome-stable_current_amd64.deb' && \
	rm -rf /var/lib/apt/lists/*

USER gamedev
WORKDIR /home/gamedev
ENV DISPLAY=:0
ENTRYPOINT ["sudo", "/opt/Unity/Editor/Unity"]
