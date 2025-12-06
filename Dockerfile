FROM debian:unstable-slim AS build-sysroot

# Fetch runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    mmdebstrap
RUN rm -rf /sysroot/var/lib/apt/lists /sysroot/var/cache/apt

# Prepare sysroot
RUN mmdebstrap \
    --variant=minbase \
    --include=dbus \
    --include=open-vm-tools \
    --include=open-vm-tools-containerinfo \
    unstable \
    /sysroot

# Do not setup network
RUN rm -f /sysroot/etc/vmware-tools/scripts/vmware/network

# Install entrypoint
# COPY --chmod=755 ./scripts/poweroff.sh /sysroot/etc/vmware-tools/scripts/poweroff-vm-default.d/
# COPY --chmod=755 ./entrypoint.sh /sysroot/

# Build image
FROM scratch
COPY --from=build-sysroot /sysroot/ /

# ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/vmtoolsd"]