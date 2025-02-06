# Build stage
FROM alpine:latest AS builder  # Use a standard Alpine image for building

RUN apk --no-cache add build-base git  # Install build tools and git

RUN git clone https://git.torproject.org/obfs4proxy.git  # Clone obfs4proxy
WORKDIR /obfs4proxy
RUN ./autogen.sh && ./configure && make && make install  # Compile and install

# Final image
FROM dockage/alpine:3.19-openrc

COPY assets/root/ /

COPY --from=builder /usr/local/bin/obfs4proxy /usr/bin/obfs4proxy # Copy the compiled binary

RUN apk --no-cache --update --upgrade add tor privoxy socat \
    && mv /etc/tor/torrc.sample /etc/tor/torrc \
    && mv /etc/privoxy/config.new /etc/privoxy/config \
    && mv /etc/privoxy/default.action.new /etc/privoxy/default.action \
    && mv /etc/privoxy/user.action.new /etc/privoxy/user.action \
    && mv /etc/privoxy/default.filter.new /etc/privoxy/default.filter \
    && mv /etc/privoxy/user.filter.new /etc/privoxy/user.filter \
    && mv /etc/privoxy/regression-tests.action.new /etc/privoxy/regression-tests.action \
    && mv /etc/privoxy/trust.new /etc/privoxy/trust \
    && mv /etc/privoxy/match-all.action.new /etc/privoxy/match-all.action \
    && mkdir /etc/torrc.d \
    && echo "forward-socks5t / 0.0.0.0:9050 ." >> /etc/privoxy/config \
    && sed -i 's/listen-address 127.0.0.0:8118/listen-address 0.0.0.0:8118/g' /etc/privoxy/config \
    && sed -i \
        -e 's/#SOCKSPort 192.168.0.1:9100/SOCKSPort 0.0.0.0:9050/g' \
        -e 's/#ControlPort 9051/ControlPort 9052/g' \
        -e 's/#%include \/etc\/torrc\.d\/\*\.conf/%include /etc/torrc.d/*.conf/g' \
        /etc/tor/torrc

EXPOSE 9050/tcp 9051/tcp 8118/tcp
