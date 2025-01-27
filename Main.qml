import QtQuick

Window {
    width: 400
    height: 600
    visible: true
    title: qsTr("Hello World")

    PlusButton {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        radius: 30
        col: "blue"
    }
    TrashButton {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        radius: 50
        col: "red"
    }
}
