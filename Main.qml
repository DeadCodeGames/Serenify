import QtQuick
import QtQuick.Controls 2.15

Window {
    width: 400
    height: 600
    minimumWidth: 400
    minimumHeight: 600
    visible: true
    title: qsTr("Serenify")
    id: root

    property bool mode: false
    property color trashColor: mode ? "red" : "#850900"
    property color plusColor: mode ? "blue" : "#03076b"
    property color taskBorderColor: mode ? "#ff9991" : "red"
    property color taskBgColor: mode ? "white" : "#2e2c2c"



    color: mode ? "white" : "#2e2c2c"

    ListModel {
        id: lModel
    }

    ListView {
        id: lView
        model: lModel
        width: parent.width
        height: parent.height - 70
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true
        delegate: Task {

        }
    }

    PlusButton {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        radius: 30
        col: root.plusColor
        onClicked: {
            lModel.append({ text: "Item " + (lModel.count + 1)});
        }
    }

    TrashButton {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        radius: 50
        col: root.trashColor
        onClicked: {
            if(lModel.count > 0) lModel.remove(lModel.count-1)
        }
    }

    RoundButton {
        width: 50
        height: 50
        text: "Mode"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        radius: 50
        onClicked: {
            root.mode = !root.mode
        }
    }
}
