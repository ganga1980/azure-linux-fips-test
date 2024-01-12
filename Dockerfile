
ARG MARINER_BASE_IMAGE=mcr.microsoft.com/cbl-mariner/base/core:2.0
ARG MARINER_DISTROLESS_IMAGE=mcr.microsoft.com/cbl-mariner/distroless/base:2.0

FROM ${MARINER_BASE_IMAGE} AS builder

LABEL maintainer="OMSContainers@microsoft.com"
LABEL vendor=Microsoft\ Corp \
    com.microsoft.product="Azure Monitor for containers"
ENV tmpdir /opt

RUN tdnf clean all
RUN tdnf repolist --refresh
# RUN tdnf install -y curl busybox && rm -rf /var/lib/apt/lists/*
# for repro uncomment this line and comment the above line
RUN tdnf install -y openssl curl busybox && rm -rf /var/lib/apt/lists/*
RUN mkdir /busybin && busybox --install /busybin

COPY main.sh  $tmpdir/
COPY mariner-official-extras.repo /etc/yum.repos.d/
RUN  chmod +x $tmpdir/main.sh

FROM ${MARINER_DISTROLESS_IMAGE} AS distroless_image
LABEL maintainer="OMSContainers@microsoft.com"
LABEL vendor=Microsoft\ Corp \
    com.microsoft.product="Azure Monitor for containers"
ENV tmpdir /opt
ENV PATH="/busybin:${PATH}"


WORKDIR ${tmpdir}

# files
COPY --from=builder /opt /opt
COPY --from=builder /etc /etc
COPY --from=builder /busybin /busybin
COPY --from=builder /usr/bin/curl /usr/bin/curl


# curl dependencies
# COPY --from=builder /lib/lib*.so.* /lib/
# COPY --from=builder /usr/lib/lib*.so.*  /usr/lib/

COPY --from=builder /lib/libcurl.so.4 /lib/libz.so.1 /lib/libc.so.6 /lib/libnghttp2.so.14 /lib/libssl.so.1.1 /lib/libssh2.so.1 /lib/libcrypto.so.1.1 /lib/libgssapi_krb5.so.2 /lib/libzstd.so.1 /lib/
COPY --from=builder /usr/lib/libkrb5.so.3 /usr/lib/libk5crypto.so.3 /usr/lib/libcom_err.so.2 /usr/lib/libkrb5support.so.0 /usr/lib/libresolv.so.2 /usr/lib/

CMD [ "/opt/main.sh" ]
