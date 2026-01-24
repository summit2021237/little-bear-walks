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

# Download GLPK
RUN mkdir glpk
WORKDIR ./glpk

ADD https://ftp.gnu.org/gnu/glpk/glpk-5.0.tar.gz ./
ADD https://ftp.gnu.org/gnu/glpk/glpk-5.0.tar.gz.sig ./

# Verify GLPK download
RUN gpg --keyserver keys.gnupg.net --recv-keys 5981E818
RUN gpg --verify glpk-5.0.tar.gz.sig

# Install GLPK
RUN gzip -d glpk-5.0.tar.gz
RUN tar -x < glpk-5.0.tar
WORKDIR glpk-5.0
RUN ./configure
RUN make
RUN make check
RUN make install
RUN ldconfig /usr/local/lib
RUN make clean

WORKDIR /usr/local/app

# Install Perl
RUN apt install -y curl
RUN curl -L http://xrl.us/installperlnix | bash

# Install Perl Modules
RUN cpan DateTime
RUN cpan JSON

# Create output directory
RUN mkdir output

# Copy scripts and source code
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
COPY config.json .
COPY src ./src

# Solve model
ENTRYPOINT ["./entrypoint.sh"]
