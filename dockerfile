FROM dnlnash/jenuxos:jenux-base-rootfs
RUN pacman --noconfirm --overwrite \* -Syu btrfs-progs
COPY . /build
WORKDIR /build/
CMD ["./build.sh"]
