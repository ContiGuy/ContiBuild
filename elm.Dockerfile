FROM ubuntu

# ARG UserID
# ARG GroupID

#
# setup Elm environment
#

# install npm
RUN apt-get update
# RUN apt-get install -y curl nodejs
# RUN apt-get install -y npm
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
# RUN curl -sL https://deb.nodesource.com/setup | bash -

## curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get install -y nodejs
# RUN apt-get install -y npm

# RUN wget https://deb.nodesource.com/setup_6.x | bash -
# RUN apt-get install -y npm

##RUN npm install -g npm || cat /npm-debug.log

# RUN apt-get update
# RUN apt-get install -y nodejs

# install elm
RUN npm install -g elm
RUN npm install -g elm-ui

EXPOSE 8001
EXPOSE 8002
EXPOSE 8003

ARG UserID
ARG GroupID
ARG OdenVersion

#
# play around
#


# RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
# RUN apt-get update
# RUN apt-get install -y nodejs

# ensure that the developer can actually create libraries and binaries
# RUN chown -R developer:developer /go   # && chmod -R a+rwx /go


# RUN npm install -g elm-server

# RUN apt-get update
# RUN apt-get install -y libpcre3-dev

# RUN mkdir -p /source
# WORKDIR /source

# # RUN git clone https://github.com/oden-lang/oden.git

# RUN wget https://github.com/oden-lang/oden/releases/download/0.3.5/oden-0.3.5-linux.tar.gz && tar xvzf oden-0.3.5-linux.tar.gz

# WORKDIR /source/oden

# RUN mkdir -p /usr/local/go/bin  /usr/local/go/lib  /usr/local/go/doc
# RUN cp bin/* /usr/local/go/bin
# RUN cp -R doc/* /usr/local/go/doc
# RUN cp -R lib/* /usr/local/go/lib

# RUN ls -laR /usr/local/go/bin  /usr/local/go/lib

# RUN stack setup
# RUN stack build
# RUN make test

# RUN ls -la  /usr/local/go/bin
