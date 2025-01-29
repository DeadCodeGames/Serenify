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

        TextInput {
            anchors.centerIn: parent
            text: model.text
            color: mode ? "black" : "white"
            font.pointSize: 16
            selectByMouse: true
            onFocusChanged:{
                if (focus) selectAll()
            }

            Keys.onEnterPressed: focus = false
            Keys.onReturnPressed: focus = false
        }
    }
}
