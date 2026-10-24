FROM dnlnash/jenuxos:jenux-base-rootfs
COPY . /build
WORKDIR /build/
CMD ["./build.sh"]
