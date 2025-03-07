import QtQuick 2.15

Item {
    id: root
    property alias col: buttonTrash._btnColor
    property alias radius: buttonTrash.radius
    signal clicked
    width: 50
    height: 50


    Rectangle {
        property color _btnColor: "red"
        id: buttonTrash
        anchors.fill: parent
        state: "normal"

        Image {
                source: "qrc:/qt/qml/Serenify/Images/Trash.png"
                width: root.width * 0.8
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                smooth: true
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        buttonTrash.state = "hovering"
                    }
                    onExited: {
                        buttonTrash.state = "normal"
                    }
                }
            }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                buttonTrash.state = "hovering"
            }
            onExited: {
                buttonTrash.state = "normal"
            }
        }

        states: [
            State {
                name: "normal"
                PropertyChanges { target: buttonTrash; color: _btnColor}
            },
            State {
                name: "hovering"
                PropertyChanges { target: buttonTrash; color: Qt.lighter(_btnColor)}
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
    MouseArea{
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

