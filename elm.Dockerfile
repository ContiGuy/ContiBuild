FROM ubuntu

ARG UserID
ARG GroupID
ARG OdenVersion

#
# setup Elm environment
#

# install npm
RUN apt-get update
RUN apt-get install -y curl python
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

# install elm
RUN npm install -g elm

# install elm-ui and expose the ports for it
RUN npm install -g elm-ui
EXPOSE 8001
EXPOSE 8002
EXPOSE 8003


#
# play around
#

