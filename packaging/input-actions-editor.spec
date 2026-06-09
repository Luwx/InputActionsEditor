Name:           input-actions-editor
Version:        0.3.0
Release:        1%{?dist}
Summary:        Input Actions configurator for managing shortcuts and input bindings
License:        MIT
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64

Requires:       gtk3
Requires:       glib2
Requires:       libstdc++

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

%files
%dir /opt/%{name}
/opt/%{name}/*
/usr/bin/input_actions_editor
/usr/share/applications/dev.luwx.input_actions_editor.desktop
/usr/share/icons/hicolor/*/apps/dev.luwx.input_actions_editor.png

%changelog
* Sun Jun 08 2026 Luwx <gconta@outlook.com.br> - 0.3.0-1
- Initial COPR release
