FROM alpine:latest AS mirror

ARG TAG
ENV TAG ${TAG}

RUN mkdir -p /out/etc/apk && cp -r /etc/apk/* /out/etc/apk/
RUN apk add --no-cache --initdb -p /out \
    alpine-baselayout \
    busybox \
    open-vm-tools${TAG} \
    open-vm-tools-guestinfo${TAG}

# Remove apk residuals
RUN rm -rf /out/etc/apk /out/lib/apk /out/var/cache

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /
COPY --from=mirror /out/ /
COPY scripts /etc/vmware-tools/scripts
CMD ["/usr/bin/vmtoolsd"]

LABEL org.opencontainers.image.source="https://github.com/vmware/open-vm-tools"
LABEL org.opencontainers.image.description="Official repository of VMware open-vm-tools project"
LABEL org.opencontainers.image.licenses="GPL-2.0-only"