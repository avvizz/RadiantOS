// radiant-run: запуск Windows-программ (.exe, .bat, .cmd, .msi) через Wine.
// Без аргументов открывает окно выбора файла.
#include <QApplication>
#include <QDir>
#include <QFileDialog>
#include <QFileInfo>
#include <QMessageBox>
#include <QProcess>
#include <QProcessEnvironment>
#include <QStandardPaths>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QApplication::setApplicationName(QStringLiteral("radiant-run"));
    const QString title = QStringLiteral("RadiantOS: запуск программы Windows");

    QString path;
    if (argc > 1) {
        path = QString::fromLocal8Bit(argv[1]);
    } else {
        path = QFileDialog::getOpenFileName(
            nullptr, QStringLiteral("Выберите программу Windows"), QDir::homePath(),
            QStringLiteral("Программы Windows (*.exe *.bat *.cmd *.msi);;Все файлы (*)"));
    }
    if (path.isEmpty())
        return 0;

    const QFileInfo fi(path);
    if (!fi.exists()) {
        QMessageBox::critical(nullptr, title,
                              QStringLiteral("Файл не найден:\n%1").arg(path));
        return 1;
    }
    if (QStandardPaths::findExecutable(QStringLiteral("wine")).isEmpty()) {
        QMessageBox::critical(nullptr, title,
                              QStringLiteral("Wine не установлен.\nУстановите пакет wine и повторите."));
        return 1;
    }

    // .exe запускаем напрямую, остальное (bat, cmd, msi) через "wine start /unix"
    QStringList args;
    if (fi.suffix().compare(QStringLiteral("exe"), Qt::CaseInsensitive) == 0)
        args << fi.absoluteFilePath();
    else
        args << QStringLiteral("start") << QStringLiteral("/unix") << fi.absoluteFilePath();

    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert(QStringLiteral("WINEDEBUG"), QStringLiteral("fixme-all"));

    QProcess proc;
    proc.setProcessEnvironment(env);
    proc.setProcessChannelMode(QProcess::MergedChannels);
    proc.setWorkingDirectory(fi.absolutePath());
    proc.start(QStringLiteral("wine"), args);

    if (!proc.waitForStarted(5000)) {
        QMessageBox::critical(nullptr, title, QStringLiteral("Не удалось запустить Wine."));
        return 1;
    }

    // Если программа упала сразу, покажем последние строки вывода Wine
    if (proc.waitForFinished(8000)) {
        if (proc.exitStatus() != QProcess::NormalExit || proc.exitCode() != 0) {
            QString out = QString::fromLocal8Bit(proc.readAll()).trimmed();
            const QStringList lines = out.split(QLatin1Char('\n'));
            out = lines.mid(qMax(0, int(lines.size()) - 15)).join(QLatin1Char('\n'));
            QMessageBox::warning(
                nullptr, title,
                QStringLiteral("Программа завершилась с ошибкой (код %1).\n\n%2")
                    .arg(proc.exitCode()).arg(out));
            return proc.exitCode();
        }
        return 0;
    }

    // Программа работает: ждём её завершения, чтобы Wine не оборвался
    proc.waitForFinished(-1);
    return 0;
}
