# Optional helper – silently skipped if KF6 is not available (non-KDE systems).
find_package(Qt6 QUIET COMPONENTS Core)
find_package(KF6IconThemes QUIET CONFIG)
find_package(KF6Service QUIET CONFIG)

if(Qt6Core_FOUND AND KF6IconThemes_FOUND AND KF6Service_FOUND)
  add_executable(kde_icon_lookup kde_icon_lookup.cpp)
  target_link_libraries(kde_icon_lookup PRIVATE Qt6::Core KF6::IconThemes KF6::Service)
  set_target_properties(kde_icon_lookup PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED ON)
  # Install alongside the main app binary.
  install(TARGETS kde_icon_lookup RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
endif()
