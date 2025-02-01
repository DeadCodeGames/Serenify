import QtQuick
import QtQuick.Layouts

Item {
    width: lView.width
    height: 70
    Rectangle {
        id: rec
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        color: root.taskBgColor
        border.color: root.taskBorderColor
        border.width: 2
        radius: 10
        height: 60
        // name, priority, deadline, description
        Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: rec.width - leftCol.width - 30
            Column {
                id: leftCol
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    Layout.bottomMargin: 5
                    id: nameLbl
                    text: model.name
                    font.pointSize: 15
                    font.bold: true
                    color: root.textColor
                }
                Text {
                    id: deeadlineLbl
                    text: model.deadline
                    color: root.textColor
                }
            }
            Column {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                Rectangle {
                    id: priorityRec
                    function assignColor(){
                        if(model.priority == "Low"){
                            return "green"
                        }
                        else if(model.priority == "Medium"){
                            return "yellow"
                        }
                        else if(model.priority == "High"){
                            return "red"
                        }
                    }
                    color: assignColor()
                    width: 12
                    height: 12
                    radius: 10
                }
            }
        }
    }
}
