# RadiantOS

Дружелюбный к пользователям Windows дистрибутив на базе **Ubuntu 24.04 LTS**
с Wine «из коробки», установщиком Calamares и Windows-подобным интерфейсом.

> Статус: ранняя альфа. Сейчас реализован этап 1 из чеклиста (база и сборка ISO).

## Состав (этап 1)
| Компонент | Зачем |
|---|---|
| Ubuntu 24.04 LTS (noble) | стабильная база |
| Cinnamon | интерфейс, похожий на Windows |
| Wine + Winetricks | запуск `.exe` / `.bat` |
| Bottles (Flatpak) + Lutris | GUI для Wine и игр |
| Calamares | установщик (настройка на этапе 2) |
| live-build | воспроизводимая сборка ISO |

## Сборка
Нужна Ubuntu 22.04/24.04 (хост, VM или контейнер), ~25 ГБ места и интернет.

```bash
git clone https://github.com/<ТВОЙ_НИК>/RadiantOS.git
cd RadiantOS
sudo ./build.sh
```
Результат: `radiantos-<версия>-<дата>-amd64.iso` + `.sha256`.

Проверка: VirtualBox или QEMU (`qemu-system-x86_64 -m 4G -enable-kvm -cdrom radiantos-*.iso`).

## Структура
```
auto/      скрипты live-build (config/build/clean)
config/    пакеты, хуки, файлы, попадающие в образ
docs/      документация (на русском)
build.sh   сборка одной командой
```

## Дорожная карта
См. [docs/ROADMAP.md](docs/ROADMAP.md).
