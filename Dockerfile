FROM alpinelinux/build-base:edge AS build-sysroot

# Copy build directory
COPY ./build /build
WORKDIR /build

# Build open-vm-tools
RUN abuild-keygen -ai
RUN abuild checksum
RUN abuild -r

# Prepare sysroot
RUN mkdir -p /sysroot/etc/apk && cp -r /etc/apk/* /sysroot/etc/apk/

# Fetch runtime dependencies
RUN apk add --no-cache --initdb -p /sysroot \
    alpine-baselayout \
    busybox \
    tzdata
RUN rm -rf /sysroot/etc/apk /sysroot/lib/apk /sysroot/var/cache

# Install open-vm-tools to new system root
# RUN

# Install entrypoint
COPY --chmod=755 ./scripts/poweroff.sh /sysroot/etc/vmware-tools/scripts/poweroff-vm-default.d/
COPY --chmod=755 ./entrypoint.sh /sysroot/

# Build image
FROM scratch
COPY --from=build-sysroot /sysroot/ /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/vmtoolsd"]