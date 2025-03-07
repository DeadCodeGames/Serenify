import QtQuick 2.15

Item {
    id: root
    property alias col: button1._btnColor
    property alias radius: button1.radius
    signal clicked

    width: 50
    height: 50
    Rectangle {
        property color _btnColor: "red"
        id: button1
        anchors.fill: parent
        color: _btnColor
        state: "normal"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                button1.state = "hovering"
            }
            onExited: {
                button1.state = "normal"
            }
        }

        Text {
            anchors.centerIn: parent
            text: "+"
            font.family: "Times New Roman"
            font.pixelSize: button1.width*0.65
            font.bold: true
            color: "white"
        }

        states: [
            State {
                name: "normal"
                PropertyChanges { target: button1; color: _btnColor}
            },
            State {
                name: "hovering"
                PropertyChanges { target: button1; color: Qt.lighter(_btnColor)}
            }
        ]

        transitions: [
            Transition {
                reversible: true
                from: "normal"
                to: "hovering"
                ColorAnimation{
                    duration: 150
                }
            }
        ]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
