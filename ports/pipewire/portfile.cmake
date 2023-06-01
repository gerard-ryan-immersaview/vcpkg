vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pipewire/pipewire
    REF ${VERSION}
    SHA512 a8d67bb6135432705d6de026074325f0cae7f01e3fe0b65fa7dafb128e5984ce126f8b4635bfbd9746777514df6f0880a78149fd007c7c1432ac29f95655ddcc
    HEAD_REF master # branch name
)

if("gstreamer-plugin" IN_LIST FEATURES)
    set(GSTREAMER_PLUGIN true)
else()
    set(GSTREAMER_PLUGIN false)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dalsa=false
        -Daudioconvert=true
        -Daudiomixer=false
        -Daudiotestsrc=false
        -Dbluez5=false
        -Dcontrol=false
        -Ddocs=false
        -Devl=false
        -Dexamples=false
        -Dffmpeg=false
        # -Dgstreamer-device-provider=${GSTREAMER_PLUGIN}
        -Dgstreamer=${GSTREAMER_PLUGIN}
        -Djack=false
        -Dlibcamera=false
        -Dman=false
        -Dpipewire-alsa=false
        -Dpipewire-jack=false
        -Dpw-cat=false
        -Dspa-plugins=true # This one must be true or the resulting build won't be able to connect to pipewire daemon
        -Dsupport=true # This one must be true or the resulting build won't be able to connect to pipewire daemon
        -Dsystemd=false
        -Dtest=false
        -Dtests=false
        -Dv4l2=false
        -Dvideoconvert=false
        -Dvideotestsrc=false
        -Dvolume=false
        -Dvulkan=false
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
file(GLOB config_files "${CURRENT_PACKAGES_DIR}/etc/${PORT}/*.conf")
foreach(file ${config_files})
    vcpkg_replace_string("${file}" "in ${CURRENT_PACKAGES_DIR}/etc/pipewire for system-wide changes\n# or" "")
    cmake_path(GET file FILENAME filename)
    vcpkg_replace_string("${file}" "# ${CURRENT_PACKAGES_DIR}/etc/pipewire/${filename}.d/ for system-wide changes or in" "")
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/pipewire/pipewire.conf" "${CURRENT_PACKAGES_DIR}/bin" "")
# vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/pipewire/minimal.conf" "${CURRENT_PACKAGES_DIR}/bin" "")


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
