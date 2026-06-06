// Reads icon/app names from stdin (one per line), writes the resolved absolute
// icon path to stdout (one per line, empty line if not found). A single Qt
// init means startup cost is paid once regardless of how many names are looked up.
//
// Runtime deps: libKF6IconThemes, libKF6Service, libQt6Core.
#include <QCoreApplication>
#include <QTextStream>
#include <KIconLoader>
#include <KService>

static QString resolve(const QString& name)
{
    auto* loader = KIconLoader::global();

    // 1. Try the name directly as an icon name (works for kwin, com.brave.Browser, …).
    QString path = loader->iconPath(name, KIconLoader::Desktop, /*canReturnNull=*/true);
    if (!path.isEmpty()) return path;

    // 2. KService fallback: maps "org.kde.konsole.desktop" → Icon=utilities-terminal.
    const QString desktopName = name.endsWith(QLatin1String(".desktop"))
        ? name.chopped(8) : name;
    const auto service = KService::serviceByDesktopName(desktopName);
    if (service && !service->icon().isEmpty())
        path = loader->iconPath(service->icon(), KIconLoader::Desktop, true);

    return path;
}

int main(int argc, char* argv[])
{
    QCoreApplication app(argc, argv);
    QTextStream in(stdin), out(stdout);
    QString line;
    while (in.readLineInto(&line)) {
        line = line.trimmed();
        out << (line.isEmpty() ? QString{} : resolve(line)) << '\n';
        out.flush();
    }
}
