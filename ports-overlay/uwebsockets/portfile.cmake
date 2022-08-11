include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/immersaview
    OUT_SOURCE_PATH SOURCE_PATH
    REPO public/remotes/uwebsockets
    REF 0.14.8.2imv
    SHA512 9edb0894267a72ed47e300b2e1e9343cdbcfbab3b021377b27f93b8f930f5cfed5670bbfb458f6bef3e376f9a506b4fc27e5ca2bf8cf00a70dbdc6bbc1fa7bc6
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uwebsockets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/uwebsockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/uwebsockets/copyright)

vcpkg_copy_pdbs()
