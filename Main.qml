import QtQuick

Window {
    width: 400
    height: 600
    visible: true
    title: qsTr("Serenify")

    ListModel {
        id: lModel
    }

    ListView {
        id: lView
        model: lModel
        anchors.fill: parent
        delegate: Item {
            width: lView.width
            height: 50
            Rectangle {
                anchors.fill: parent
                color: "lightblue"
                height: 40

                Text {
                    anchors.centerIn: parent
                    text: model.text
                    font.pointSize: 16
                }
            }
        }
    }

    PlusButton {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        radius: 30
        col: "blue"
        onClicked: {
            lModel.append({ text: "Item " + (lModel.count + 1) });
        }
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
