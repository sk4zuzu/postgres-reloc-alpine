#!/usr/bin/env sh

set -x
set -e

PREFIX="${PREFIX:-/opt/postgres}"

echo "$PREFIX"

detect_elf_files() {
    xargs file|\
    grep 'ELF 64-bit'|\
    cut -d: -f1
}

detect_so_libs() {
    detect_elf_files|\
    xargs -n1 ldd 2>/dev/null|\
    grep -v ldd|\
    grep '=>'|\
    awk '{print $3}'|\
    sort|\
    uniq
}

collect_so_libs() {
    echo "$*"|\
    xargs -n1|\
    sort|\
    uniq|\
    grep -v "$PREFIX"|\
    xargs -n1 -i{} /bin/cp -f {} "$PREFIX/lib"
}

patch_elf_files() {
    cd $PREFIX
    for ELF_FILE in `find * -type f -a ! -path '*/patchelf' -a ! -path '*/ld-musl-x86_64.so.1'|detect_elf_files`; do
        $PREFIX/bin/patchelf --set-interpreter "$PREFIX/lib/ld-musl-x86_64.so.1" "$ELF_FILE" || true
        if MATCH=`ldd "$ELF_FILE"|grep '=>'|grep -v "$PREFIX"|grep -v ldd`; then
            BASENAME=`echo "$MATCH"|awk '{print $1}'`
            $PREFIX/bin/patchelf --replace-needed "$BASENAME" "$PREFIX/lib/$BASENAME" "$ELF_FILE"
        fi
    done
    cd -
}

create_so_symlinks() {
    cd $PREFIX/lib
    for SO_LIB in `find * -type f -name '*.so.*.*.*' -maxdepth 1`; do
        SYMLINK=`echo "$SO_LIB"|grep -o '^.*[.]so[.][^.]*'`
        ln -s "$SO_LIB" "$SYMLINK"
    done
    cd -
}

STAGE1=`find $PREFIX/* -type f|detect_so_libs`
STAGE2=`echo "$STAGE1"|detect_so_libs`
collect_so_libs "$STAGE1" "$STAGE2"

STAGE3=`find $PREFIX/* -type f|detect_so_libs`
STAGE4=`echo "$STAGE3"|detect_so_libs` 
collect_so_libs "$STAGE3" "$STAGE4"

patch_elf_files
create_so_symlinks

# vim:ts=4:sw=4:et:
