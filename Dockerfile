# AlpineLinux with a glibc-2.23
FROM alpine:3.4

MAINTAINER Alex Huang <alex@hydra.work>

ARG RESPOSITORY=mirrors.aliyun.com

ENV GLIBC_VERSION=2.23-r3 \
    LANG=C.UTF-8

# Replace apk
RUN sed -i -e "s/dl-cdn.alpinelinux.org/$RESPOSITORY/g" /etc/apk/repositories && \
	# Add glibc-2.23
	apk add --update ca-certificates bash && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; \
    	do wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -O /tmp/${pkg}.apk; \
    done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    # Add Timezone
    apk add tzdata && \
    /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone && \
    # Clear cache and temp files
    apk del glibc-i18n && \
    rm -rf /tmp/* /var/cache/apk/*

# EOF
