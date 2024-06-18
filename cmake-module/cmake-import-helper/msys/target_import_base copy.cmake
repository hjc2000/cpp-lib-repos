include(target_import_libusb)
include(target_import_jccpp)
include(target_import_base)

function(target_import_libusb_wrapper target_name visibility)
    target_include_directories(${target_name} ${visibility} ${libs_path}/libusb-wrapper/include/)
    target_auto_link_lib(${target_name} libusb-wrapper ${libs_path}/libusb-wrapper/lib/)
    install_dll_dir(${libs_path}/libusb-wrapper/bin/)

	target_import_libusb(${ProjectName} PUBLIC)
	target_import_jccpp(${ProjectName} PUBLIC)
	target_import_base(${ProjectName} PUBLIC)
endfunction()
