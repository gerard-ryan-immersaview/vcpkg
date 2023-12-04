vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gst-plugins-rs
    REF "${VERSION}"
    SHA512 34fd11c021807972c26f9d805d1fedf55bb9b4e39aff10dcff4361d45db8ea3599424175248b21b392c7e3f78cdf1ffd9c33b5e2731d26347f9043f813231af3
    HEAD_REF main
)

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(GIT)
vcpkg_execute_required_process(
    COMMAND cargo install --verbose --verbose cargo-c
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME "install-cargo-c"
)

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    list(APPEND CONFIGURATIONS "release")
endif ()
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    list(APPEND CONFIGURATIONS "debug")
endif ()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND LIB_TYPES --library-type cdylib)
endif ()
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND LIB_TYPES --library-type staticlib)
endif ()

set(PLUGINS_WITH_DEPS
    webp
    videofx
    threadshare
    sodium
    onvif
    gtk4
    dav1d
    csound
    closedcaption
)
foreach(PLUGIN ${PLUGINS_WITH_DEPS})
    if (NOT PLUGIN IN_LIST FEATURES)
        list(APPEND EXCLUDE_PLUGINS --exclude gst-plugin-${PLUGIN})
    endif ()
endforeach()

foreach(CONFIG ${CONFIGURATIONS})
    if (CONFIG STREQUAL "debug")
        set(PREFIX "${CURRENT_PACKAGES_DIR}/debug")
        set(PROFILE "dev")
        set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig")
    elseif (CONFIG STREQUAL "release")
        set(PREFIX "${CURRENT_PACKAGES_DIR}")
        set(PROFILE "release")
        set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
    endif ()

    vcpkg_execute_required_process(
        COMMAND cargo cinstall --verbose --verbose --target-dir=${CURRENT_BUILDTREES_DIR} --prefix=${PREFIX} --profile ${PROFILE} ${LIB_TYPES} --workspace ${EXCLUDE_PLUGINS}
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME "install-${CONFIG}"
    )
endforeach()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE-MPL-2.0"
        "${SOURCE_PATH}/LICENSE-APACHE"
        "${SOURCE_PATH}/LICENSE-MIT"
        "${SOURCE_PATH}/LICENSE-LGPLv2"
    COMMENT
        "gst-plugins-rs and all crates contained in here are licensed under one of the following licenses

        Mozilla Public License Version 2.0 (LICENSE-MPL-2.0 or http://opensource.org/licenses/MPL-2.0)
        Apache License, Version 2.0, (LICENSE-APACHE or http://www.apache.org/licenses/LICENSE-2.0)
        MIT license (LICENSE-MIT or http://opensource.org/licenses/MIT)
        Lesser General Public License (LICENSE-LGPLv2) version 2.1 or (at your option) any later version

        GStreamer itself is licensed under the Lesser General Public License version
        2.1 or (at your option) any later version: https://www.gnu.org/licenses/lgpl-2.1.html"
)

set(USAGE_FILE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
file(WRITE "${USAGE_FILE}" "${PORT} usage:\n\n")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(APPEND "${USAGE_FILE}" "\tMake sure one of the following paths is added to the 'GST_PLUGIN_PATH' environment variable\n")
    file(APPEND "${USAGE_FILE}" "\tFor more information on GStreamer environment variables see https://gstreamer.freedesktop.org/documentation/gstreamer/running.html?gi-language=c#environment-variables\n")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB DYNAMIC_PLUGINS
            "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}gst*${CMAKE_SHARED_LIBRARY_SUFFIX}"
            "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/gst*.pdb"
        )
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/plugins/gstreamer")
        file(COPY ${DYNAMIC_PLUGINS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/gstreamer")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/")

        file(APPEND "${USAGE_FILE}" "\t\t* '<path-to-vcpkg_installed>/${TARGET_TRIPLET}/debug/plugins/gstreamer/'\n")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(GLOB DYNAMIC_PLUGINS
            "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}gst*${CMAKE_SHARED_LIBRARY_SUFFIX}"
            "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/gst*.pdb"
        )
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/plugins/gstreamer")
        file(COPY ${DYNAMIC_PLUGINS} DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/gstreamer")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/")

        file(APPEND "${USAGE_FILE}" "\t\t* '<path-to-vcpkg_installed>/${TARGET_TRIPLET}/plugins/gstreamer/'\n")
    endif()
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(APPEND "${USAGE_FILE}" "\tRegister static plugin with gst_plugin_register_static()\n")
    file(APPEND "${USAGE_FILE}" "\thttps://gstreamer.freedesktop.org/documentation/application-development/appendix/compiling.html#embedding-static-elements-in-your-application\n")
endif()
