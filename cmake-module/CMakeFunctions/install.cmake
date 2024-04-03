# 定义一个函数来自动安装目标到标准的安装路径
# 这个函数确保可执行文件、动态库、静态库被安装到合适的目录中
#
# 参数:
#   target_name - 需要安装的目标名称。这应该是之前使用 add_executable 或 add_library 创建的目标。
#
function(install_target_to_standard_paths target_name)
    install(
        TARGETS ${target_name}
        RUNTIME DESTINATION bin # 可执行文件和DLL到 bin
        LIBRARY DESTINATION lib # 共享库 (.so) 到 lib
        ARCHIVE DESTINATION lib
    )
endfunction()



# 定义安装规则。将一个文件夹的内容安装到安装目录。
# 参数：
#   src_dir - 此文件夹内的内容将被安装
#   dst_dir - 安装到的目标路径（相对于CMAKE_INSTALL_PREFIX）
#   pattern - 通配符
function(install_from_dir src_dir dst_dir pattern)
    if(NOT PATTERN)
        # 如果没有提供 PATTERN，设置为匹配所有文件
        set(PATTERN "*")
    endif()

    install(
        DIRECTORY ${src_dir}/
        DESTINATION ${dst_dir}
        # 安装时保留原始的权限
        USE_SOURCE_PERMISSIONS
        FILES_MATCHING
        # 使用提供的模式，或默认匹配所有文件
        PATTERN ${pattern}
    )
endfunction()


# 将 dll_dir 下的所有 dll 安装到 ${CMAKE_INSTALL_PREFIX}/bin
# 因为是按文件夹安装，只不过是加了 *.dll 的筛选器，所以会保持原来的目录结构
#
# 参数：
#   dll_dir - 要被安装的 dll 所在的目录
function(install_dll_from_dir dll_dir)
    install_from_dir(${dll_dir}/ bin "*.dll")
endfunction()


# 安装一个文件到指定的路径。
#
# 参数：
#   file_path - 要被安装的文件的路径
#   dest_dir - 要将此文件安装到的文件夹。此文件夹相对于 CMAKE_INSTALL_PREFIX。
function(install_one_file file_path dest_dir)
    install(FILES "${file_path}" DESTINATION "${dest_dir}")
endfunction()
