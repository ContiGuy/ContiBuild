# small but not based on debian/ubuntu, so no apt packages available
# FROM golang:alpine
# FROM golang:wheezy
FROM golang

ARG UserID
ARG GroupID
ARG OdenVersion

#
# setup Elm environment
#

# install npm
#RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
#RUN apt-get update
#RUN apt-get install -y nodejs

# install elm
#RUN npm install -g elm

# # install purescript and it's tools
# RUN npm install -g purescript pulp bower


# open port for elm reactor
##EXPOSE 8000

# ENTRYPOINT [ "elm" ]

#
# setup Go environment
#

WORKDIR /go/src

# # add a helper tool written in Go
# ADD gopath gopath
# RUN go install gopath
# RUN GOOS=windows GOARCH=amd64 go install gopath

# create a non root developer user with the same user id as the developer who builds the docker image so that later the built files can be owned by him
RUN addgroup --gid "${GroupID}" developer
#~alpine: RUN addgroup -g "${GroupID}" developer

# FIXME: need to prevent interactive output
RUN adduser --uid "${UserID}" --gid "${GroupID}" --no-create-home --disabled-password --gecos "the local Go developer" developer
#~alpine: RUN adduser -u "${UserID}" -G developer -D developer

# add a helper tool written in Go
ADD cobui cobui
RUN go install --race cobui
#~alpine: RUN go install cobui
##RUN GOOS=windows GOARCH=amd64 go install cobui

# ensure that the developer can actually create libraries and binaries
RUN chown -R developer:developer /go   # && chmod -R a+rwx /go

# open port for go doc
##EXPOSE 6060

