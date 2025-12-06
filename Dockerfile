FROM debian:unstable-slim AS build-sysroot

# Fetch runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    mmdebstrap

# Prepare sysroot
RUN mmdebstrap \
    --variant=minbase \
    --include=open-vm-tools \
    --include=open-vm-tools-containerinfo \
    --include=tzdata \
    unstable \
    /sysroot
RUN rm -rf /sysroot/var/lib/apt/lists/*

# Install entrypoint
# COPY --chmod=755 ./scripts/poweroff.sh /sysroot/etc/vmware-tools/scripts/poweroff-vm-default.d/
# COPY --chmod=755 ./entrypoint.sh /sysroot/

# Build image
FROM scratch
COPY --from=build-sysroot /sysroot/ /

# ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/vmtoolsd"]