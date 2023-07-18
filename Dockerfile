FROM alpine:latest AS build
ENV REPODEST="/packages"
RUN apk add --no-cache alpine-sdk
RUN git clone https://gitlab.alpinelinux.org/alpine/aports
RUN mkdir -p /packages
RUN abuild-keygen -a -i
RUN cd community/open-vm-tools

FROM alpine:latest AS mirror
RUN mkdir -p /out/etc/apk && cp -r /etc/apk/* /out/etc/apk/
RUN apk add --no-cache --initdb -p /out \
    alpine-baselayout \
    busybox \
    open-vm-tools \
    open-vm-tools-guestinfo

# Remove apk residuals
RUN rm -rf /out/etc/apk /out/lib/apk /out/var/cache

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /
COPY --from=mirror /out/ /
COPY scripts /etc/vmware-tools/scripts
CMD ["/usr/bin/vmtoolsd"]