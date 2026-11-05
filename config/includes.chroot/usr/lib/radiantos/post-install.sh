#!/bin/sh
# Выполняется Calamares внутри только что установленной системы.

# 1. Брандмауэр ufw включён
[ -f /etc/ufw/ufw.conf ] && sed -i 's/^ENABLED=.*/ENABLED=yes/' /etc/ufw/ufw.conf

# 2. Автоматические обновления безопасности
cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOT
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOT

# 3. Раскладка: Alt+Shift, как в Windows; вторая раскладка us, если выбрана одна
KB=/etc/default/keyboard
if [ -f "$KB" ]; then
    if grep -q '^XKBOPTIONS=' "$KB"; then
        sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="grp:alt_shift_toggle"/' "$KB"
    else
        echo 'XKBOPTIONS="grp:alt_shift_toggle"' >> "$KB"
    fi
    CUR="$(sed -n 's/^XKBLAYOUT="\(.*\)"/\1/p' "$KB")"
    case "$CUR" in
        ""|*,*|us) ;;
        *) sed -i "s/^XKBLAYOUT=.*/XKBLAYOUT=\"$CUR,us\"/" "$KB" ;;
    esac
fi

# 4. Убрать ярлык установщика с рабочего стола нового пользователя
rm -f /etc/skel/Desktop/radiantos-installer.desktop
exit 0
