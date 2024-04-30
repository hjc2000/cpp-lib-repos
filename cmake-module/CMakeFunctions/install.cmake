# 安装一个文件到指定的路径。
#
# 参数：
#   file_path - 要被安装的文件的路径
#   dest_dir - 要将此文件安装到的文件夹。此文件夹相对于 CMAKE_INSTALL_PREFIX。
function(install_one_file file_path dest_dir)
    install(FILES "${file_path}" DESTINATION "${dest_dir}")
endfunction()





# 将 ${src_dir} 目录的内容安装到 ${dst_dir} 目录下。会保持目录结构。
# ${pattern} 是通配符，例如 "*" 匹配所有，"*.h" 匹配所有头文件。
function(install_dir src_dir dst_dir pattern)
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





# 将 ${dll_dir} 内的 dll 文件安装到安装目录下的 bin 目录。
# 会保持目录结构。
function(install_dll_dir dll_dir)
    install_dir(${dll_dir}/ bin "*.dll")
endfunction()







# 将一个文件夹中的头文件安装到安装目录下的 include 目录。
# 会保持目录结构，同时会过滤，仅安装 *.h
function(install_include_dir include_dir)
    if(${option_install_headers})
        install_dir(${include_dir} include "*.h")
    endif()
endfunction()




# 递归收集 ${header_dir} 下的所有头文件，安装到安装目录下的 include 目录。
function(install_header_files_recurse header_dir)
    # 收集指定目录及其子目录下所有的头文件
    file(GLOB_RECURSE header_files "${header_dir}/*.h")

    # 安装所有收集到的头文件到安装前缀的include目录下
    if(${option_install_headers})
        install(FILES ${header_files} DESTINATION include)
    endif()
endfunction()
