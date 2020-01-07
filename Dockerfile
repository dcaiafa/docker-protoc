FROM debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends \
  bzip2 \
  ca-certificates \
  curl \
  g++ \
  gcc \
  git \
  make \
  python3-dev \
  python3-pip \
  ssh \
  unzip \
  graphviz \
  && rm -rf /var/lib/apt/lists/*

# Install protobuf compiler.
# https://github.com/protocolbuffers/protobuf/blob/master/src/README.md
RUN mkdir ~/protobuf_tmp && \
  cd ~/protobuf_tmp && \
  curl -L -o protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-x86_64.zip && \
  unzip protobuf.zip && \
  mv bin/* /usr/local/bin/ && \
  mv include/* /usr/local/include/ && \
  cd ~ && \
  rm -rf ~/protobuf_tmp

# Install Go.
RUN mkdir ~/go_tmp && \
  cd ~/go_tmp && \
  curl -L -o go.tar.gz https://dl.google.com/go/go1.13.linux-amd64.tar.gz && \
  tar -xzf go.tar.gz && \
  mv go /usr/local && \
  cd ~ && \
  rm -rf go_tmp && \
  mkdir -p /go/bin

ENV PATH /usr/local/go/bin:/go/bin:$PATH
RUN go env -w GO111MODULE=on && \
  go env -w GOBIN=/go/bin

# Install protoc plugins.
RUN go get github.com/golang/protobuf/protoc-gen-go@v1.3.2 && \
  go get github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v1.3.0  && \
  go get github.com/envoyproxy/protoc-gen-validate@v0.1.0

# Install Python dependencies.
RUN pip3 install setuptools wheel && \
  pip3 install grpclib==0.3.0 mypy-protobuf==1.15 betterproto[compiler]==1.2.1

RUN mkdir -p /protobuf/include && \
  mkdir ~/git_tmp && \
  cd ~/git_tmp && \
  git clone https://github.com/envoyproxy/protoc-gen-validate && \
  cd protoc-gen-validate && \
  git checkout v0.1.0 && \
  mv validate /protobuf/include && \
  cd ~ && \
  rm -rf git_tmp

RUN go get github.com/seamia/protodot

VOLUME /host
WORKDIR /host
