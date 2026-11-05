import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation

    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle { anchors.fill: parent; color: "#1b1e2b" }
        Text {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            color: "#ffcc33"
            font.pixelSize: 28
            text: "RadiantOS\nWindows-программы запускаются двойным кликом"
        }
    }
    Slide {
        Rectangle { anchors.fill: parent; color: "#1b1e2b" }
        Text {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            color: "#ffffff"
            font.pixelSize: 24
            text: "Полный доступ к системе:\nтерминал, root, открытые конфиги"
        }
    }
}
