//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <background_blur_linux/background_blur_linux_plugin.h>
#include <linux_app_menu/linux_app_menu_plugin.h>
#include <screen_retriever_linux/screen_retriever_linux_plugin.h>
#include <window_manager/window_manager_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) background_blur_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "BackgroundBlurLinuxPlugin");
  background_blur_linux_plugin_register_with_registrar(background_blur_linux_registrar);
  g_autoptr(FlPluginRegistrar) linux_app_menu_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "LinuxAppMenuPlugin");
  linux_app_menu_plugin_register_with_registrar(linux_app_menu_registrar);
  g_autoptr(FlPluginRegistrar) screen_retriever_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ScreenRetrieverLinuxPlugin");
  screen_retriever_linux_plugin_register_with_registrar(screen_retriever_linux_registrar);
  g_autoptr(FlPluginRegistrar) window_manager_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WindowManagerPlugin");
  window_manager_plugin_register_with_registrar(window_manager_registrar);
}
