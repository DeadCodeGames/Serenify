import QtQuick

Item {
    width: lView.width
    height: 70
    Rectangle {
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        color: root.taskBgColor
        border.color: root.taskBorderColor
        border.width: 2
        radius: 10
        height: 60

        Text {
            anchors.centerIn: parent
            text: model.text
            font.pointSize: 16
        }
    }
}
