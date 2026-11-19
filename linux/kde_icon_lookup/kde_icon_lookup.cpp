// Reads icon/app names from stdin (one per line), writes the resolved absolute
// icon path to stdout (one per line, empty line if not found). A single Qt
// init means startup cost is paid once regardless of how many names are looked up.
//
// Runtime deps: libKF6IconThemes, libKF6Service, libQt6Core.
#include <QCoreApplication>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMap>
#include <QTextStream>
#include <KIconLoader>
#include <KService>
#include <kiconthemes_version.h>

static QJsonArray listIcons()
{
    auto* loader = KIconLoader::global();
#if KICONTHEMES_VERSION >= QT_VERSION_CHECK(6, 11, 0)
    const auto paths = loader->queryIcons();
#else
    loader->iconPath(QStringLiteral("unknown"), KIconLoader::Small, true);
    const auto paths = loader->queryIconsByContext(-32, KIconLoader::Any);
#endif
    QMap<QString, QString> icons;
    for (const auto& path : paths) {
        const auto name = QFileInfo(path).completeBaseName();
        if (name.isEmpty() || icons.contains(name)) continue;
        const auto preview = loader->iconPath(name, -32, true);
        if (!preview.isEmpty()) icons.insert(name, preview);
    }

    QJsonArray result;
    QMap<QString, QJsonArray> contexts;
    for (int value = KIconLoader::Action; value <= KIconLoader::StatusIcon; ++value) {
        const auto context = static_cast<KIconLoader::Context>(value);
        for (const auto& path : loader->queryIconsByContext(-32, context))
            contexts[QFileInfo(path).completeBaseName()].append(value);
    }
    for (auto it = icons.cbegin(); it != icons.cend(); ++it) {
        result.append(QJsonObject{
            {"name", it.key()}, {"path", it.value()}, {"contexts", contexts.value(it.key())}
        });
    }
    return result;
}

static QString resolve(const QString& name, int size)
{
    auto* loader = KIconLoader::global();

    // 1. Try the name directly as an icon name (works for kwin, com.brave.Browser, …).
    QString path = loader->iconPath(name, size, /*canReturnNull=*/true);
    if (!path.isEmpty()) return path;

    // 2. KService fallback: maps "org.kde.konsole.desktop" → Icon=utilities-terminal.
    const QString desktopName = name.endsWith(QLatin1String(".desktop"))
        ? name.chopped(8) : name;
    const auto service = KService::serviceByDesktopName(desktopName);
    if (service && !service->icon().isEmpty())
        path = loader->iconPath(service->icon(), size, true);

    return path;
}

int main(int argc, char* argv[])
{
    QCoreApplication app(argc, argv);
    QTextStream in(stdin), out(stdout);
    if (app.arguments().contains(QStringLiteral("--list"))) {
        out << QJsonDocument(listIcons()).toJson(QJsonDocument::Compact) << '\n';
        return 0;
    }
    int size = KIconLoader::Desktop;
    const int sizeOption = app.arguments().indexOf(QStringLiteral("--size"));
    if (sizeOption >= 0) {
        if (sizeOption + 1 >= argc) return 2;
        bool valid = false;
        const int requested = app.arguments().at(sizeOption + 1).toInt(&valid);
        if (!valid || requested <= 0) return 2;
        size = -requested;
    }
    QString line;
    while (in.readLineInto(&line)) {
        line = line.trimmed();
        out << (line.isEmpty() ? QString{} : resolve(line, size)) << '\n';
        out.flush();
    }
}
