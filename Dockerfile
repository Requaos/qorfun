### From Builder
FROM golang:1.11.0 AS builder

RUN apt-get -yq update &&\
    apt-get -yq install ca-certificates

# create secure user
RUN adduser --disabled-password --gecos '' fun

WORKDIR /go/src/github.com/requaos/qorfun

COPY . ./

RUN make build


### Final Image
FROM scratch

# copy ssl certs
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# copy secure user
COPY --from=builder /etc/passwd /etc/passwd

# copy binary
COPY --from=builder /go/src/github.com/requaos/qorfun/bin/linux_amd64/qorfun /qorfun

# set the executing user
USER fun

# set the GOPATH
ENV GOPATH /go

# run binary
CMD ["/qorfun"]

HEALTHCHECK --interval=15s --timeout=10s --retries=2 \
  CMD curl -f http://localhost:5000/health || exit 1
