FROM ubuntu:24.04
WORKDIR /usr/local/app

# Install Python
RUN apt-get update
RUN apt-get install -y python3

# Install pip
RUN apt install -y python3-pip

# Create virtual environment
RUN apt install -y python3.12-venv
RUN python3 -m venv ./venv

# Install dependencies
COPY requirements.txt ./
RUN ./venv/bin/pip install --no-cache-dir -r requirements.txt

# Install GLPK
RUN mkdir glpk
WORKDIR ./glpk
ADD https://ftp.gnu.org/gnu/glpk/glpk-5.0.tar.gz ./
ADD https://ftp.gnu.org/gnu/glpk/glpk-5.0.tar.gz.sig ./

# Verify GLPK download
RUN gpg --keyserver keys.gnupg.net --recv-keys 5981E818
RUN gpg --verify glpk-5.0.tar.gz.sig
WORKDIR ..

# Copy source code
COPY src ./src

# Setup app user to avoid running as root
RUN useradd app
USER app
