cmake_minimum_required(VERSION 3.20)
project(AlpacaPi VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(BUILD_TESTS "Build tests" OFF)
option(BUILD_EXAMPLES "Build examples" ON)

file(GLOB_RECURSE ALPACAPI_PUBLIC_HEADERS
  CONFIGURE_DEPENDS
  "${CMAKE_SOURCE_DIR}/include/alpacapi/*.h"
  "${CMAKE_SOURCE_DIR}/include/alpacapi/*.hpp"
)

file(GLOB_RECURSE ALPACAPI_SOURCES
  CONFIGURE_DEPENDS
  "${CMAKE_SOURCE_DIR}/src/**/*.c"
  "${CMAKE_SOURCE_DIR}/src/**/*.cpp"
)

# Exclude OpenCV-dependent and problematic files for Phase 1
list(REMOVE_ITEM ALPACAPI_SOURCES
  "${CMAKE_SOURCE_DIR}/src/core/controllerImageArray.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_covercalib.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/cameradriver_opencv.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/opencv_utils.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_alpacaUnit.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_fw_common.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_main.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_multicam.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_preview.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_skyimage.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_slit.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_tscope_common.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/controller_startup.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/discoverythread.c"
  "${CMAKE_SOURCE_DIR}/src/core/discovery_lib.c"
  "${CMAKE_SOURCE_DIR}/src/core/dumpfits.c"
  "${CMAKE_SOURCE_DIR}/src/core/fits_opencv.c"
  "${CMAKE_SOURCE_DIR}/src/core/fitsview.c"
  "${CMAKE_SOURCE_DIR}/src/core/.!21133!obsconditionsdriver_rpi.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/mandelbrot.c"
  "${CMAKE_SOURCE_DIR}/src/core/nitecrawler_image.c"
  "${CMAKE_SOURCE_DIR}/src/core/readimagefile.c"
  "${CMAKE_SOURCE_DIR}/src/core/rgbmerge.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/slittracker_AlpacaCmds.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/slittracker_direct.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/slittracker.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_DeviceState.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_MoonPhase.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_alpacaUnit.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_about.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_alpacalist.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_auxmotor.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_camcooler.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_camsettings.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_camera.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_camvideo.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_config.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_capabilities.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_covercalib.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_deviceselect.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_dome.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_filelist.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_drvrInfo.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_filterwheel.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_graphs.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_fitsheader.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_focus.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_focus_ml_hr.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_focus_ml_nc.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_focus_generic.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_image.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_ml_single.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_ml_nc.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_obsconditions.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_remoteview.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_rotator.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_switch.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_telescope.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_tscope_common.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_startup.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_alpacaUnit.h"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_iplist.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_imageinfo.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_imageList.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_libraries.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_moon.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_mount.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_nitecrawler.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_multicam.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_obscond.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_preview.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_sw_versions.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_slitdome.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_slit.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_slitgraph.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_teleSettings.cpp"
  "${CMAKE_SOURCE_DIR}/src/core/windowtab_usb.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/RemoteImage.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/controller_constList.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/controller_skytravel.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/controller_GaiaRemote.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/controller_starlist.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/examples/main.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/iso9660.c"
  "${CMAKE_SOURCE_DIR}/src/util/web_graphics_opencv.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/windowtab_RemoteData.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/skytravel_main.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/skytravel_radec.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/windowtab_fov.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/windowtab_cpustats.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/windowtab_STsettings.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/windowtab_constList.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/windowtab_skytravel.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/windowtab_solarsystem.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/windowtab_starlist.cpp"
  "${CMAKE_SOURCE_DIR}/src/util/windowtab_time.cpp"
)

add_library(alpacapi ${ALPACAPI_SOURCES} ${ALPACAPI_PUBLIC_HEADERS})
target_include_directories(alpacapi
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<INSTALL_INTERFACE:include>
)
target_compile_features(alpacapi PUBLIC cxx_std_17)

if (BUILD_EXAMPLES)
  add_executable(example_discover examples/example_discover.cpp)
  target_link_libraries(example_discover PRIVATE alpacapi)
endif()
