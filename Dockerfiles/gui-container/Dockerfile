FROM ubuntu:18.04

RUN apt update && apt upgrade -y
RUN apt install -y x11-apps

RUN useradd --create-home foo
RUN usermod -a -G audio foo

USER foo
CMD xeyes
