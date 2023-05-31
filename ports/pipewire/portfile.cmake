vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pipewire/pipewire
    REF ${VERSION}
    SHA512 aa19fc89f6f27046067b764ceb2052f5dace74fd7099afaf6e5b25c00b7e846bf4bd6332ac733ad4a48f4601cadaab6db679de9b4fc5ab3b01d078aee0ff7413
    HEAD_REF master # branch name
)

if("gstreamer-plugin" IN_LIST FEATURES)
    set(GSTREAMER_PLUGIN enabled)
else()
    set(GSTREAMER_PLUGIN disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dalsa=disabled
        -Daudioconvert=enabled
        -Daudiomixer=disabled
        -Daudiotestsrc=disabled
        -Davahi=disabled
        -Dbluez5-backend-hfp-native=disabled
        -Dbluez5-backend-hsp-native=disabled
        -Dbluez5-backend-hsphfpd=disabled
        -Dbluez5-backend-ofono=disabled
        -Dbluez5-codec-aac=disabled
        -Dbluez5-codec-aptx=disabled
        -Dbluez5-codec-lc3plus=disabled
        -Dbluez5-codec-ldac=disabled
        -Dbluez5=disabled
        -Dcontrol=disabled
        -Ddbus=enabled
        -Ddocs=disabled
        -Decho-cancel-webrtc=disabled
        -Devl=disabled
        -Dexamples=disabled
        -Dffmpeg=disabled
        -Dgstreamer-device-provider=${GSTREAMER_PLUGIN}
        -Dgstreamer=${GSTREAMER_PLUGIN}
        -Dinstalled_tests=disabled
        -Djack-devel=false
        -Djack=disabled
        -Dlegacy-rtkit=false
        -Dlibcamera=disabled
        -Dlibcanberra=disabled
        -Dlibpulse=disabled
        -Dlibusb=disabled
        -Dlv2=disabled
        -Dman=disabled
        -Dpipewire-alsa=disabled
        -Dpipewire-jack=disabled
        -Dpipewire-v4l2=disabled
        -Dpw-cat=disabled
        -Draop=disabled
        -Droc=disabled
        -Dsdl2=disabled
        -Dsndfile=disabled
        -Dspa-plugins=enabled # This one must be enabled or the resulting build won't be able to connect to pipewire daemon
        -Dsupport=enabled # This one must be enabled or the resulting build won't be able to connect to pipewire daemon
        -Dsystemd-system-service=disabled
        -Dsystemd-system-unit-dir=disabled
        -Dsystemd-user-service=disabled
        -Dsystemd-user-unit-dir=disabled
        -Dsystemd=disabled
        -Dtest=disabled
        -Dtests=disabled
        -Dudev=disabled
        -Dudevrulesdir=disabled
        -Dv4l2=disabled
        -Dvideoconvert=disabled
        -Dvideotestsrc=disabled
        -Dvolume=disabled
        -Dvulkan=disabled
        -Dx11-xfixes=disabled
        -Dx11=disabled
        -Dsession-managers=[]
)
vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# remove absolute paths
file(GLOB config_files "${CURRENT_PACKAGES_DIR}/share/${PORT}/*.conf")
foreach(file ${config_files})
    vcpkg_replace_string("${file}" "in ${CURRENT_PACKAGES_DIR}/etc/pipewire for system-wide changes\n# or" "")
    cmake_path(GET file FILENAME filename)
    vcpkg_replace_string("${file}" "# ${CURRENT_PACKAGES_DIR}/etc/pipewire/${filename}.d/ for system-wide changes or in" "")
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pipewire/pipewire.conf" "${CURRENT_PACKAGES_DIR}/bin" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pipewire/minimal.conf" "${CURRENT_PACKAGES_DIR}/bin" "")


set(USAGE_FILE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
file(WRITE "${USAGE_FILE}" "The package ${PORT} can be imported via CMake FindPkgConfig module:

    find_package(PkgConfig REQUIRED)
    pkg_check_modules(${PORT} REQUIRED)
    target_link_libraries(main PkgConfig::${PORT})

")

if("gstreamer-plugin" IN_LIST FEATURES)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)
        file(APPEND "${USAGE_FILE}" "\tMake sure one of the following paths is added to the 'GST_PLUGIN_PATH' environment variable\n")
        file(APPEND "${USAGE_FILE}" "\tFor more information on GStreamer environment variables see https://gstreamer.freedesktop.org/documentation/gstreamer/running.html?gi-language=c#environment-variables\n")

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/plugins/gstreamer")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}gstpipewire${CMAKE_SHARED_LIBRARY_SUFFIX}"
                        "${CURRENT_PACKAGES_DIR}/debug/plugins/gstreamer/${CMAKE_SHARED_LIBRARY_PREFIX}gstpipewire${CMAKE_SHARED_LIBRARY_SUFFIX}")
            if(VCPKG_TARGET_IS_WINDOWS)
                file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/gstpipewire.pdb"
                            "${CURRENT_PACKAGES_DIR}/debug/plugins/gstreamer/gstpipewire.pdb")
            else()
                file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0")
            endif()

            file(APPEND "${USAGE_FILE}" "\t\t* '${CURRENT_INSTALLED_DIR}/debug/plugins/gstreamer/'\n")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/plugins/gstreamer")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}gstpipewire${CMAKE_SHARED_LIBRARY_SUFFIX}"
                        "${CURRENT_PACKAGES_DIR}/plugins/gstreamer/${CMAKE_SHARED_LIBRARY_PREFIX}gstpipewire${CMAKE_SHARED_LIBRARY_SUFFIX}")
            if(VCPKG_TARGET_IS_WINDOWS)
                file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/gstpipewire.pdb"
                            "${CURRENT_PACKAGES_DIR}/plugins/gstreamer/gstpipewire.pdb")
            else()
                file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0")
            endif()

            file(APPEND "${USAGE_FILE}" "\t\t* '${CURRENT_INSTALLED_DIR}/plugins/gstreamer/'\n")
        endif()
    else()
        file(APPEND "${USAGE_FILE}" "\tRegister static GStreamer plugins with gst_plugin_register_static()\n")
        file(APPEND "${USAGE_FILE}" "\thttps://gstreamer.freedesktop.org/documentation/application-development/appendix/compiling.html#embedding-static-elements-in-your-application\n")
    endif()
endif()
