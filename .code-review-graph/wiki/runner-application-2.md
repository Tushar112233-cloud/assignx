# runner-application

## Overview

Directory-based community: superviser_app/linux

- **Size**: 12 nodes
- **Cohesion**: 0.0000
- **Dominant Language**: cpp

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| fl_register_plugins | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/flutter/generated_plugin_registrant.cc | 13-23 |
| main | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/main.cc | 3-6 |
| _MyApplication | Class | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 10-13 |
| first_frame_cb | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 18-20 |
| my_application_activate | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 23-79 |
| my_application_local_command_line | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 82-100 |
| my_application_startup | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 103-109 |
| my_application_shutdown | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 112-118 |
| my_application_dispose | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 121-125 |
| my_application_class_init | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 127-134 |
| my_application_init | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 136-136 |
| my_application_new | Function | /Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc | 138-148 |

## Execution Flows

No execution flows pass through this community.

## Dependencies

### Outgoing

- `GTK_WIDGET` (7 edge(s))
- `g_autoptr` (6 edge(s))
- `G_APPLICATION_CLASS` (6 edge(s))
- `MY_APPLICATION` (4 edge(s))
- `fl_plugin_registry_get_registrar_for_plugin` (3 edge(s))
- `gtk_widget_show` (3 edge(s))
- `G_OBJECT_CLASS` (2 edge(s))
- `file_selector_plugin_register_with_registrar` (1 edge(s))
- `flutter_secure_storage_linux_plugin_register_with_registrar` (1 edge(s))
- `url_launcher_plugin_register_with_registrar` (1 edge(s))
- `my_application_new` (1 edge(s))
- `g_application_run` (1 edge(s))
- `G_APPLICATION` (1 edge(s))
- `gtk_widget_get_toplevel` (1 edge(s))
- `GTK_WINDOW` (1 edge(s))

### Incoming

- `/Volumes/Crucial X9/AssignX/superviser_app/linux/runner/my_application.cc` (10 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser_app/linux/flutter/generated_plugin_registrant.cc` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser_app/linux/runner/main.cc` (1 edge(s))
