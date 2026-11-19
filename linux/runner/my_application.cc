#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_WAYLAND
#include <gdk/gdkwayland.h>
#endif
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication
{
  GtkApplication parent_instance;
  char **dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

struct KeyboardGrab
{
  GWeakRef window;
  GdkSeat *seat = nullptr;
  unsigned int recorders = 0;
};

static void release_keyboard_grab(KeyboardGrab *grab)
{
  if (grab->seat == nullptr)
    return;
  gdk_seat_ungrab(grab->seat);
  g_clear_object(&grab->seat);
}

static void acquire_keyboard_grab(KeyboardGrab *grab)
{
#ifdef GDK_WINDOWING_WAYLAND
  if (grab->seat != nullptr)
    return;

  g_autoptr(GObject) widget = G_OBJECT(g_weak_ref_get(&grab->window));
  if (widget == nullptr)
    return;

  GdkWindow *window = gtk_widget_get_window(GTK_WIDGET(widget));
  if (window == nullptr)
    return;

  GdkDisplay *display = gdk_window_get_display(window);
  if (!GDK_IS_WAYLAND_DISPLAY(display))
    return;

  GdkSeat *seat = gdk_display_get_default_seat(display);
  if (seat != nullptr &&
      gdk_seat_grab(seat, window, GDK_SEAT_CAPABILITY_KEYBOARD, TRUE, nullptr,
                    nullptr, nullptr, nullptr) == GDK_GRAB_SUCCESS)
    grab->seat = GDK_SEAT(g_object_ref(seat));
#endif
}

static void keyboard_recording_call(FlMethodChannel *, FlMethodCall *call,
                                    gpointer data)
{
  auto *grab = static_cast<KeyboardGrab *>(data);
  const gchar *method = fl_method_call_get_name(call);
  if (g_str_equal(method, "grab"))
  {
    ++grab->recorders;
    acquire_keyboard_grab(grab);
  }
  else if (g_str_equal(method, "ungrab"))
  {
    if (grab->recorders > 0 && --grab->recorders == 0)
      release_keyboard_grab(grab);
  }
  else
  {
    fl_method_call_respond_not_implemented(call, nullptr);
    return;
  }
  fl_method_call_respond_success(call, nullptr, nullptr);
}

static void register_keyboard_recording_channel(FlView *view, GtkWindow *window)
{
  auto *grab = new KeyboardGrab();
  g_weak_ref_init(&grab->window, G_OBJECT(window));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)),
      "input_actions_editor/keyboard_recording", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, keyboard_recording_call, grab, [](gpointer data) {
        auto *grab = static_cast<KeyboardGrab *>(data);
        release_keyboard_grab(grab);
        g_weak_ref_clear(&grab->window);
        delete grab;
      });
}

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication *self, FlView *view)
{
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication *application)
{
  MyApplication *self = MY_APPLICATION(application);
  GtkWindow *window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  gtk_window_set_title(window, "Input Actions Editor");
  gtk_window_set_icon_name(GTK_WINDOW(window), APPLICATION_ID);

  gtk_window_set_default_size(window, 1080, 640);

  // ── kde_blur: make the window transparent ──────────────────────────────────
  GdkScreen *gtk_screen = gtk_widget_get_screen(GTK_WIDGET(window));
  GdkVisual *visual = gdk_screen_get_rgba_visual(gtk_screen);
  if (visual != nullptr && gdk_screen_is_composited(gtk_screen))
  {
    gtk_widget_set_visual(GTK_WIDGET(window), visual);
  }
  gtk_widget_set_app_paintable(GTK_WIDGET(window), TRUE);
  // ──────────────────────────────────────────────────────────────────────────

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView *view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#00000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
  register_keyboard_recording_channel(view, window);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication *application,
                                                  gchar ***arguments,
                                                  int *exit_status)
{
  MyApplication *self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error))
  {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication *application)
{
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication *application)
{
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject *object)
{
  MyApplication *self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass *klass)
{
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication *self) {}

MyApplication *my_application_new()
{
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
