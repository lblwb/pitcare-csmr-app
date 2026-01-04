#include "my_application.h"

#include <flutter_linux/flutter_linux.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Function to update the time label
static gboolean update_time(GtkWidget* label) {
  GDateTime* now = g_date_time_new_now_local();
  gchar* time_str = g_date_time_format(now, "%H:%M");
  gtk_label_set_text(GTK_LABEL(label), time_str);
  g_free(time_str);
  g_date_time_unref(now);
  return TRUE; // Continue calling
}

// Function to create the status bar widget
static GtkWidget* create_status_bar() {
  GtkWidget* box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);

  // Time label on the left
  GtkWidget* time_label = gtk_label_new("");
  gtk_box_pack_start(GTK_BOX(box), time_label, FALSE, FALSE, 10);

  // Spacer to push elements to the right
  GtkWidget* spacer = gtk_label_new("");
  gtk_box_pack_start(GTK_BOX(box), spacer, TRUE, TRUE, 0);

  // Battery label on the right
  GtkWidget* battery_label = gtk_label_new("100%");
  gtk_box_pack_end(GTK_BOX(box), battery_label, FALSE, FALSE, 10);

  // Signal label on the right
  GtkWidget* signal_label = gtk_label_new("WiFi");
  gtk_box_pack_end(GTK_BOX(box), signal_label, FALSE, FALSE, 10);

  // Apply CSS for styling
  GtkCssProvider* provider = gtk_css_provider_new();
  const char* css = "box { "
    "background-color: #1a1a1a; "
    "color: #FFFFFF; "
    "padding: 8px 12px; "
    "font-size: 13px; "
    "border-top: 1px solid #333333; "
  "} "
  "label { "
    "margin: 0px 5px; "
  "}";
  gtk_css_provider_load_from_data(provider, css, -1, NULL);
  GtkStyleContext* context = gtk_widget_get_style_context(box);
  gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_USER);
  g_object_unref(provider);

  // Set fixed height for status bar
  gtk_widget_set_size_request(box, -1, 50);

  // Start updating time every second
  g_timeout_add_seconds(1, (GSourceFunc)update_time, time_label);
  update_time(time_label); // Initial update

  gtk_widget_show_all(box);
  return box;
}

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;

  // Title bar varibale = text "Анализы Просто"
  const char* title_bar = "Анализы Просто";

  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, title_bar);
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, title_bar);
  }

  gtk_window_set_default_size(window, 420, 720);
  gtk_window_set_position(window, GTK_WIN_POS_CENTER);
  // max size for default size
  gtk_window_set_resizable(window, FALSE);

  // gtk_window_set_default_size(window, 1080, 2424);
  // gtk_window_set_default_size(window, 400, 800);
  //gtk_window_set_geometry_hints(window, NULL, GDK_HINT_MIN_SIZE | GDK_HINT_MAX_SIZE);


  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));

  // Create status bar
  GtkWidget* status_bar = create_status_bar();

  // Create main vertical box
  GtkWidget* main_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
  gtk_box_pack_start(GTK_BOX(main_box), status_bar, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(main_box), GTK_WIDGET(view), TRUE, TRUE, 0);
  gtk_widget_show(GTK_WIDGET(main_box));

  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(main_box));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
