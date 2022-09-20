vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cisco/libsrtp
    REF v2.4.2
    SHA512 6E4805E6D34B2050A6F68F629B0B42356B1D27F2CBAA6CC6166E56957609C3D9AA6B723DCC674E5C74180D122D27BADD2F9496639CCB1E0C210B9E1F7949D0E2
    PATCHES
    cmake_pr_patch_and_lib_dir.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} /wd4703")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /wd4703")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/libSRTP
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libsrtp" RENAME copyright)
