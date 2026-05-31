#!/bin/bash
set -Eeuo pipefail

build_alpacapi() {
    : "${work_dir:?work_dir is required}"
    : "${src_repo:?src_repo is required}"
    : "${used_commit:?used_commit is required}"
    : "${arch:?arch is required}"

    rm -rf "${work_dir}" *-alpacapi-"${arch}".zip

    git clone --depth 1 --branch "${used_commit}" "${src_repo}" "${work_dir}"

    # pi-gen's dependency check exits on GitHub-hosted runners when binfmt_misc is
    # already mounted or cannot be mounted in the usual way. Mounting it here is
    # safe and idempotent for the ARM64 runner workflow.
    sed -i 's@exit 1@mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc || true@g' "${work_dir}/scripts/dependencies_check"

    cp -Rf config stage2 stage-alpacapi "${work_dir}"

    docker rm -v pigen_work 2>/dev/null || true

    cd "${work_dir}"

    export IMG_NAME="alpacapi"
    export RELEASE="trixie"
    export ARCH="${arch}"

    local cores make_jobs parallel_jobs pip_jobs
    cores="$(nproc)"
    echo "Starting pi-gen build process using ${cores} CPU cores..."

    if [ "${cores}" -ge 16 ]; then
        make_jobs="${cores}"
        parallel_jobs="$((cores * 2))"
        pip_jobs="$((cores * 2))"
    else
        make_jobs="${cores}"
        parallel_jobs="${cores}"
        pip_jobs="${cores}"
    fi

    export MAKEFLAGS="-j${make_jobs}"
    export MAKEOPTS="-j${make_jobs}"
    export PARALLEL_JOBS="${parallel_jobs}"
    export PIP_JOBS="${pip_jobs}"

    if ! ./build-docker.sh; then
        echo "Error: pi-gen build failed. Checking for errors..." >&2
        if [ -f "work/build.log" ]; then
            echo "Build log contents:" >&2
            tail -50 work/build.log >&2
        fi
        exit 1
    fi

    if [ ! -d "deploy" ]; then
        echo "Error: deploy directory not found. Build may have failed." >&2
        ls -la work/ 2>/dev/null || echo "No work directory found" >&2
        if [ -f "work/build.log" ]; then
            echo "Build log contents:" >&2
            tail -50 work/build.log >&2
        fi
        exit 1
    fi

    cd deploy

    local zip_file src_file buf tgt_file final_zip
    zip_file="$(find . -maxdepth 1 -type f -name '*-lite.zip' -printf '%f\n' | sort | tail -1)"
    if [ -z "${zip_file}" ]; then
        echo "Error: no Raspberry Pi OS Lite zip file found in deploy directory" >&2
        ls -la >&2
        exit 1
    fi

    unzip -o "${zip_file}"
    rm "${zip_file}"

    src_file="$(find . -maxdepth 1 -type f -name '*.img' -printf '%f\n' | sort | tail -1)"
    if [ -z "${src_file}" ]; then
        echo "Error: no img file found after unzipping ${zip_file}" >&2
        ls -la >&2
        exit 1
    fi

    buf="$(basename "${src_file}" -lite.img)"
    tgt_file="${buf}-${arch}.img"
    echo "Renaming: ${src_file} -> ${tgt_file}"
    mv "${src_file}" "${tgt_file}"

    final_zip="$(basename "${tgt_file}" .img).zip"
    echo "Creating archive: ${final_zip}"
    zip "${final_zip}" "${tgt_file}"
    rm "${tgt_file}"

    cd ../..
    mv "${work_dir}/deploy/${final_zip}" .
}
