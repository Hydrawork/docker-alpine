ARG ALPINE_VERSION=3.9

FROM alpine:${ALPINE_VERSION}
LABEL maintainer="hydrawork <alex@hydra.work>"

ARG RESPOSITORY=mirrors.aliyun.com
ARG GLIBC_ENABLE=YES
ARG GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc/releases/download
ARG GLIBC_VERSION=2.29-r0
ARG LANG=C.UTF-8

RUN set -ex && \
    sed -i -e "s/dl-cdn.alpinelinux.org/$RESPOSITORY/g" /etc/apk/repositories && \
    apk -U upgrade && \
	# Add glibc
    if [ "${GLIBC_ENABLE}" = 'YES' ]; then \
	apk add libstdc++ ca-certificates curl bash && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; \
    	do curl -L -o /tmp/${pkg}.apk ${GLIBC_REPO}/${GLIBC_VERSION}/${pkg}.apk; \
    done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    apk del glibc-i18n; \
    fi && \
    # Add Timezone
    apk add tzdata && \
    /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone && \
    # Clear cache and temp files
    rm -rf /tmp/* /var/cache/apk/*
