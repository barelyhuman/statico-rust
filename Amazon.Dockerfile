FROM amazonlinux:latest AS builder

RUN  amazon-linux-extras install -y rust1; yum groupinstall -y 'Development Tools'