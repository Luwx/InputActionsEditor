// Reads Qt key codes from stdin (one per line, decimal integers),
// writes QKeySequence::toString(PortableText) to stdout (one per line).
// Modifier bits in the combined code are decoded automatically, producing
// strings like "Touchpad Toggle" or "Meta+Ctrl+Touchpad Toggle".
//
// Runtime deps: libQt6Gui.
#include <QCoreApplication>
#include <QKeySequence>
#include <QKeyCombination>
#include <QTextStream>

int main(int argc, char* argv[])
{
    QCoreApplication app(argc, argv);
    QTextStream in(stdin);
    QTextStream out(stdout);
    in.setEncoding(QStringConverter::Utf8);
    out.setEncoding(QStringConverter::Utf8);

    QString line;
    while (in.readLineInto(&line)) {
        line = line.trimmed();
        if (line.isEmpty()) {
            out << '\n';
        } else {
            bool ok;
            const int code = line.toInt(&ok);
            if (ok) {
                const QKeySequence ks(QKeyCombination::fromCombined(code));
                out << ks.toString(QKeySequence::PortableText) << '\n';
            } else {
                out << '\n';
            }
        }
        out.flush();
    }
}
