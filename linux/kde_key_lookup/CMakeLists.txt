# Optional helper – silently skipped if Qt6Gui is not available (non-Qt systems).
find_package(Qt6 QUIET COMPONENTS Gui)

if(Qt6Gui_FOUND)
  add_executable(kde_key_lookup kde_key_lookup.cpp)
  target_link_libraries(kde_key_lookup PRIVATE Qt6::Gui)
  set_target_properties(kde_key_lookup PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED ON)
  # Install into the bundle root (relative to CMAKE_INSTALL_PREFIX, which Flutter
  # only points at the bundle dir after this subdirectory is added).
  install(TARGETS kde_key_lookup RUNTIME DESTINATION "." COMPONENT Runtime)
endif()
