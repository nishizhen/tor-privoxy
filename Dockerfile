FROM alpine:3.21

COPY assets/root/ /

RUN apk --no-cache --update --upgrade add tor
RUN apk --no-cache --update --upgrade add privoxy
RUN apk --no-cache --update --upgrade add socat
RUN apk --no-cache --update --upgrade add go
RUN apk --no-cache --update --upgrade add git

RUN mv /etc/tor/torrc.sample /etc/tor/torrc
RUN mv /etc/privoxy/config.new /etc/privoxy/config
RUN mv /etc/privoxy/default.action.new /etc/privoxy/default.action
RUN mv /etc/privoxy/user.action.new /etc/privoxy/user.action
RUN mv /etc/privoxy/default.filter.new /etc/privoxy/default.filter
RUN mv /etc/privoxy/user.filter.new /etc/privoxy/user.filter
RUN mv /etc/privoxy/regression-tests.action.new /etc/privoxy/regression-tests.action
RUN mv /etc/privoxy/trust.new /etc/privoxy/trust
RUN mv /etc/privoxy/match-all.action.new /etc/privoxy/match-all.action

RUN mkdir /etc/torrc.d
RUN echo "forward-socks5t / 0.0.0.0:9050 ." >> /etc/privoxy/config
RUN sed -i 's/listen-address\s*127.0.0.1:8118/listen-address 0.0.0.0:8118/g' /etc/privoxy/config
RUN sed -i -e 's/#SOCKSPort 192.168.0.1:9100/SOCKSPort 0.0.0.0:9050/g' -e 's/#ControlPort 9051/ControlPort 9052/g' -e 's/#%include \/etc\/torrc\.d\/\*\.conf/%include \/etc\/torrc\.d\/\*\.conf/g' /etc/tor/torrc

RUN rc-update add tor
RUN rc-update add privoxy
RUN rc-update add socat

RUN git clone https://gitlab.com/yawning/obfs4.git
WORKDIR obfs4
RUN go build -o /usr/local/bin/obfs4proxy ./obfs4proxy

EXPOSE 9050/tcp 9051/tcp 8118/tcp
