#!/bin/bash

build_alpacapi () {
	# start clean
	rm -rf ${work_dir} *-alpacapi-${arch}.zip

	# get the code and build the image
	git clone ${src_repo} ${work_dir}
	cd ${work_dir}
	git checkout ${used_commit}
	sed -i 's@exit 1@mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc@g' scripts/dependencies_check
	cd ..
	cp -Rf config stage2 stage3 ${work_dir}

	# Remove existing container if it exists
	docker rm -v pigen_work 2>/dev/null || true

	cd ${work_dir}

	# Set environment variables that pi-gen might need
	export IMG_NAME="alpacapi"
	export RELEASE="trixie"
	export ARCH="${arch}"

	# Configure for parallel processing
	CORES=$(nproc)
	echo "Starting pi-gen build process using $CORES CPU cores..."

	# Detect high-core systems and optimize accordingly
	if [ $CORES -ge 16 ]; then
		echo "🔥 High-core system detected! Using aggressive parallel processing..."
		MAKE_JOBS=$CORES
		PARALLEL_JOBS=$((CORES * 2))
		PIP_JOBS=$((CORES * 2))
	else
		MAKE_JOBS=$CORES
		PARALLEL_JOBS=$CORES
		PIP_JOBS=$CORES
	fi

	# Set environment variables for parallel processing
	export MAKEFLAGS="-j$MAKE_JOBS"
	export MAKEOPTS="-j$MAKE_JOBS"
	export PARALLEL_JOBS="$PARALLEL_JOBS"
	export PIP_JOBS="$PIP_JOBS"

	# Run the build and capture output
	if ! ./build-docker.sh; then
		echo "Error: pi-gen build failed. Checking for errors..."
		if [ -f "work/build.log" ]; then
			echo "Build log contents:"
			tail -50 work/build.log
		fi
		exit 1
	fi

	# Check if deploy directory exists
	if [ ! -d "deploy" ]; then
		echo "Error: deploy directory not found. Build may have failed."
		echo "Checking work directory contents:"
		ls -la work/ 2>/dev/null || echo "No work directory found"
		if [ -f "work/build.log" ]; then
			echo "Build log contents:"
			tail -50 work/build.log
		fi
		exit 1
	fi

	cd deploy

	# Find and unzip the result
	zip_file=$(ls *-lite.zip 2>/dev/null | head -1)
	if [ -z "${zip_file}" ]; then
		echo "Error: No lite zip file found in deploy directory"
		ls -la
		exit 1
	fi

	unzip "${zip_file}"
	rm "${zip_file}"

	# rename the image
	src_file=$(ls *.img 2>/dev/null | head -1)
	if [ -z "${src_file}" ]; then
		echo "Error: No img file found after unzipping"
		ls -la
		exit 1
	fi

	buf=$(basename "${src_file}" -lite.img)
	tgt_file="${buf}-${arch}.img"
	echo "Renaming: ${src_file} -> ${tgt_file}"
	mv "${src_file}" "${tgt_file}"

	# create the final zip for distribution
	final_zip=$(basename "${tgt_file}" .img).zip
	echo "Creating archive: ${final_zip}"
	zip "${final_zip}" "${tgt_file}"
	rm "${tgt_file}"
	cd ../..
	mv "${work_dir}/deploy/${final_zip}" .
}
