import QtQuick

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    PlusButton {
        anchors.centerIn: parent
        radius: 30
        col: "blue"
    }
}
