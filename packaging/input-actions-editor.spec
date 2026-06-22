%global debug_package %{nil}

Name:           input-actions-editor
Version:        0.5.0
Release:        2%{?dist}
Summary:        Input Actions configurator for managing shortcuts and input bindings
License:        MIT
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64

BuildRequires:  chrpath

Requires:       gtk3
Requires:       glib2
Requires:       libstdc++
# Runtime libraries for the optional KDE helpers (kde_icon_lookup / kde_key_lookup)
Requires:       qt6-qtbase
Requires:       qt6-qtbase-gui
Requires:       kf6-kiconthemes
Requires:       kf6-kservice

%description
Input Actions Editor is a graphical configurator for managing input action
shortcuts and bindings (e.g. KWin gestures and input rules).

%prep
%setup -q

%install
mkdir -p %{buildroot}/opt/%{name}
cp -r opt/%{name}/. %{buildroot}/opt/%{name}/

install -Dm755 usr/bin/input_actions_editor \
    %{buildroot}/usr/bin/input_actions_editor
install -Dm644 usr/share/applications/dev.luwx.input_actions_editor.desktop \
    %{buildroot}/usr/share/applications/dev.luwx.input_actions_editor.desktop

for size in 16 32 48 64 128 256 512; do
    install -Dm644 usr/share/icons/hicolor/${size}x${size}/apps/dev.luwx.input_actions_editor.png \
        %{buildroot}/usr/share/icons/hicolor/${size}x${size}/apps/dev.luwx.input_actions_editor.png
done

# Strip RPATHs that Flutter embeds pointing to the build machine's source tree
find %{buildroot}/opt/%{name}/lib/ -name '*.so' -exec chrpath -d {} \;

%files
%dir /opt/%{name}
/opt/%{name}/*
/usr/bin/input_actions_editor
/usr/share/applications/dev.luwx.input_actions_editor.desktop
/usr/share/icons/hicolor/*/apps/dev.luwx.input_actions_editor.png

%changelog
# Generated from CHANGELOG.md at build time by scripts/gen-spec-changelog.py.
# The entries below are a fallback for building the spec by hand.
* Wed Jun 10 2026 Luwx <mail@luwx.dev> - 0.5.0-1
- New action types: replace text, activate window
- Import/Export YAML from and to the clipboard
- Gesture selection is now persisted across app restarts
- Better UX for group gesture handling
- Various bugfixes
