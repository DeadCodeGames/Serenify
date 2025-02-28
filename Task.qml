import QtQuick
import QtQuick.Layouts

Item {
    id: rootItem
    width: lView.width
    height: 70

    Behavior on height {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    Rectangle {
        id: rec
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        border.color: root.taskBorderColor
        border.width: 2
        radius: 10
        height: 60
        color: root.taskBgColor

        property bool isOpened: false

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                gradientBackground.fadeDirection = "in";
                fadeTimer.start();
            }

            onExited: {
                gradientBackground.fadeDirection = "out";
                fadeTimer.start();
            }

            onClicked: {
                rec.isOpened = !rec.isOpened;
                rec.height = rec.isOpened ? 120 : 60;
                rootItem.height = rec.isOpened ? 130 : 70;
            }
        }

        Rectangle {
            id: gradientBackground
            anchors.fill: parent
            anchors.margins: parent.border.width
            anchors.centerIn: parent
            radius: parent.radius - parent.border.width
            opacity: 0

            Timer {
                id: fadeTimer
                interval: 1
                repeat: true
                onTriggered: {
                    if (gradientBackground.opacity < 1 && gradientBackground.opacity >= 0 && gradientBackground.fadeDirection === "in") {
                        gradientBackground.opacity += 0.02;
                    } else if (gradientBackground.opacity > 0 && gradientBackground.fadeDirection === "out") {
                        gradientBackground.opacity -= 0.02;
                    } else {
                        fadeTimer.stop();
                    }
                }
            }

            property string fadeDirection: ""

            gradient: Gradient {
                GradientStop { position: 0.0; color: root.taskBgColor }
                GradientStop { position: 0.5; color: root.taskBgColor }
                GradientStop { position: 1.0; color: root.taskBorderColor }
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: rec.width - leftCol.width - 30
            Column {
                id: leftCol
                anchors.top: parent.top
                anchors.topMargin: 5
                Text {
                    Layout.bottomMargin: 5
                    id: nameLbl
                    text: model.name
                    font.pointSize: 15
                    font.bold: true
                    color: root.textColor
                }
                Text {
                    id: deadlineLbl
                    text: model.deadline
                    color: root.textColor
                    Layout.bottomMargin: 6
                }
                Text {
                    id: descriptionLbl
                    text: model.description
                    width: rootItem.width - 40
                    wrapMode: Text.Wrap
                    color: root.textColor
                    font.pointSize: 8
                    opacity: 0
                }
                Item {
                    y: 74
                    Row{
                        id: buttonRow
                        spacing: 10
                        Rectangle {
                            id: trashTask
                            width: 33
                            height: 33
                            color: "red"
                            radius: 20
                            opacity: 0

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    lModel.remove(model.id)
                                }
                            }
                            Image {
                                source: "qrc:/qt/qml/Serenify/Images/Trash.png"
                                width: trashTask.width * 0.8
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                smooth: true
                            }

                        }
                        Rectangle {
                            id: editTask
                            width: 33
                            height: 33
                            color: "yellow"
                            radius: 20
                            opacity: 0
                        }
                        Rectangle {
                            id: finishTask
                            width: 33
                            height: 33
                            color: "green"
                            radius: 20
                            opacity: 0
                        }
                    }
                }
            }
            Column {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                Rectangle {
                    id: priorityRec
                    function assignColor(){
                        if (model.priority == "Low") return "green";
                        if (model.priority == "Medium") return "yellow";
                        if (model.priority == "High") return "red";
                    }
                    color: assignColor()
                    width: 12
                    height: 12
                    radius: 10
                }
            }
        }

        states: [
            State {
                name: "collapsed"
                PropertyChanges { target: descriptionLbl; opacity: 0 }
                PropertyChanges { target: trashTask; opacity: 0 }
                PropertyChanges { target: editTask; opacity: 0 }
                PropertyChanges { target: finishTask; opacity: 0 }
            },
            State {
                name: "expanded"
                PropertyChanges { target: descriptionLbl; opacity: 1 }
                PropertyChanges { target: trashTask; opacity: 1 }
                PropertyChanges { target: editTask; opacity: 1 }
                PropertyChanges { target: finishTask; opacity: 1 }
            }
        ]

        transitions: [
            Transition {
                from: "collapsed"
                to: "expanded"
                reversible: true
                ParallelAnimation {
                    NumberAnimation { target: descriptionLbl; property: "opacity"; duration: 100 }
                    NumberAnimation { target: trashTask; property: "opacity"; duration: 100 }
                    NumberAnimation { target: editTask; property: "opacity"; duration: 100 }
                    NumberAnimation { target: finishTask; property: "opacity"; duration: 100 }

                }
            }
        ]

        onIsOpenedChanged: {
            rec.state = rec.isOpened ? "expanded" : "collapsed";
        }
    }
}
