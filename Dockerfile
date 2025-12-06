# FROM alpinelinux/build-base:edge AS build

# # Copy build directory
# COPY ./build /build
# WORKDIR /build

# # Build open-vm-tools
# RUN abuild-keygen -ain
# RUN abuild checksum
# RUN abuild -r

FROM alpine:edge AS build-sysroot

# Prepare sysroot
RUN mkdir -p /sysroot/etc/apk && cp -r /etc/apk/* /sysroot/etc/apk/

# Fetch runtime dependencies
RUN apk add --no-cache --initdb -p /sysroot \
    alpine-baselayout \
    busybox \
    dbus \
    open-vm-tools \
    open-vm-tools-guestinfo \
    tzdata
RUN rm -rf /sysroot/etc/apk /sysroot/lib/apk /sysroot/var/cache

# Install entrypoint
COPY --chmod=755 ./scripts/ /sysroot/etc/vmware-tools/
COPY --chmod=755 ./entrypoint.sh /sysroot/

# Build image
FROM scratch
COPY --from=build-sysroot /sysroot/ /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/vmtoolsd"]