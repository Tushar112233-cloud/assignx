# runner-class

## Overview

Directory-based community: superviser_app/windows

- **Size**: 17 nodes
- **Cohesion**: 0.0541
- **Dominant Language**: cpp

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| RegisterPlugins | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/flutter/generated_plugin_registrant.cc | 15-26 |
| LRESULT | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/flutter_window.cpp | 50-71 |
| class | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/flutter_window.h | 12-31 |
| wWinMain | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/main.cpp | 8-43 |
| CreateAndAttachConsole | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/utils.cpp | 10-22 |
| GetCommandLineArguments | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/utils.cpp | 24-42 |
| Utf8FromUtf16 | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/utils.cpp | 44-65 |
| Scale | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp | 36-38 |
| EnableFullDpiSupportIfAvailable | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp | 42-54 |
| WindowClassRegistrar | Class | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp | 59-85 |
| WindowClassRegistrar | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp | 80-80 |
| wchar_t | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp | 89-107 |
| LRESULT | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp | 176-222 |
| Win32Window | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp | 236-239 |
| RECT | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp | 252-256 |
| HWND | Function | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp | 258-260 |
| Size | Class | /Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.h | 21-100 |

## Execution Flows

No execution flows pass through this community.

## Dependencies

### Outgoing

- `GetRegistrarForPlugin` (5 edge(s))
- `freopen_s` (2 edge(s))
- `_dup2` (2 edge(s))
- `_fileno` (2 edge(s))
- `DefWindowProc` (2 edge(s))
- `ConnectivityPlusWindowsPluginRegisterWithRegistrar` (1 edge(s))
- `FileSelectorWindowsRegisterWithRegistrar` (1 edge(s))
- `FlutterSecureStorageWindowsPluginRegisterWithRegistrar` (1 edge(s))
- `SharePlusWindowsPluginCApiRegisterWithRegistrar` (1 edge(s))
- `UrlLauncherWindowsRegisterWithRegistrar` (1 edge(s))
- `HandleTopLevelWindowProc` (1 edge(s))
- `ReloadSystemFonts` (1 edge(s))
- `engine` (1 edge(s))
- `CreateAndAttachConsole` (1 edge(s))
- `GetCommandLineArguments` (1 edge(s))

### Incoming

- `/Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.cpp` (9 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser_app/windows/runner/utils.cpp` (3 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser_app/windows/flutter/generated_plugin_registrant.cc` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser_app/windows/runner/flutter_window.cpp` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser_app/windows/runner/flutter_window.h` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser_app/windows/runner/main.cpp` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser_app/windows/runner/win32_window.h` (1 edge(s))
