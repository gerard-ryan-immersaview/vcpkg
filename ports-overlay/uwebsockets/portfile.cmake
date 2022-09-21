include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/immersaview
    OUT_SOURCE_PATH SOURCE_PATH
    REPO public/remotes/uwebsockets
    REF 0.14.8.3imv
    SHA512 b3143922946f267e3b1cce23115485cb5d162abadae4291439cd4382da83ef6dd03baeee1d1ba01a0614f4bacd63d60346f32863cf045f873ca9f7cd3b28482b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uwebsockets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/uwebsockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/uwebsockets/copyright)

vcpkg_copy_pdbs()
