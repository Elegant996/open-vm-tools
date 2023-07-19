FROM alpine:latest AS build
RUN apk add --no-cache \
    abuild-rootbld \
    alpine-sdk
RUN adduser -D buildozer -G abuild && addgroup vmware
RUN mkdir -p /var/cache/distfiles
RUN chmod a+w /var/cache/distfiles
USER buildozer
WORKDIR /home/buildozer
RUN git clone https://gitlab.alpinelinux.org/alpine/aports
RUN abuild-keygen -a -n
WORKDIR /home/buildozer/aports/community/open-vm-tools
COPY APKBUILD .
ENV GOPATH="/home/buildozer"
# RUN abuild rootbld
RUN abuild deps
RUN abuild clean
RUN abuild fetch verify
RUN abuild unpack
RUN abuild prepare
RUN abuild build
RUN abuild rootpkg
# RUN abuild undeps

# FROM alpine:latest AS mirror
# RUN mkdir -p /out/etc/apk && cp -r /etc/apk/* /out/etc/apk/
# RUN apk add --no-cache --initdb -p /out \
#     alpine-baselayout \
#     busybox \
#     open-vm-tools \
#     open-vm-tools-guestinfo

# Remove apk residuals
# RUN rm -rf /out/etc/apk /out/lib/apk /out/var/cache

# FROM scratch
# ENTRYPOINT []
# CMD []
# WORKDIR /
# COPY --from=mirror /out/ /
# COPY scripts /etc/vmware-tools/scripts
# CMD ["/usr/bin/vmtoolsd"]