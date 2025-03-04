import QtQuick
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts

Window {
    width: 400
    height: 600
    minimumWidth: 400
    minimumHeight: 600
    maximumHeight: 600
    maximumWidth: 400
    visible: true
    title: qsTr("Serenify")
    id: root

    // Variables
    property int taskCounter: 0

    // Colors here
    property bool mode: true // False = dark mode, True = light mode
    property color trashColor: mode ? "red" : "#850900"
    property color plusColor: mode ? "blue" : "#03076b"
    property color borderColor: mode ? "#ff9991" : "red"
    property color bgColor: mode ? "white" : "#171716"
    property color textColor: mode ? "black" : "white"
    property color phTextColor: mode ? "#797979" : "#a6a6a6"
    property color greenBtn: mode ? "#54ff22" : "#3ebf19"
    property color greenBtnHover: mode ? "#3aff00" : "#31d600"
    property color greenBtnDisabled: mode ? "#98ff7a" : "#7ac165"
    property color inputBorderNormal: mode ? "#b3b3b3" : "#4d4d4d"
    property color inputBorderError: mode ? "#ff5555" : "#ff3333"
    property color inputBorderValid: mode ? "#55aa55" : "#33aa33"

    color: bgColor

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

        addDisplaced: Transition {
            NumberAnimation {
                properties: "x,y";
                duration: 400;
                easing.type: Easing.OutQuad
            }
        }

        removeDisplaced: Transition {
            NumberAnimation {
                properties: "x,y";
                duration: 400;
                easing.type: Easing.OutQuad
            }
        }

        add: Transition {
            NumberAnimation {
                property: "opacity";
                from: 0;
                to: 1.0;
                duration: 400
            }
            NumberAnimation {
                property: "scale";
                from: 0.5;
                to: 1.0;
                duration: 400
            }
        }

        remove: Transition {
            NumberAnimation {
                property: "opacity";
                to: 0;
                duration: 400
            }
        }
        delegate: Task {

        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 10

        RoundButton {
            width: 50
            height: 50
            text: mode ? "🌙" : "☀️"
            font.pixelSize: 25
            radius: 25
            background: Rectangle {
                radius: 25
                color: mode ? "#e0e0e0" : "#303030"
                border.width: 1
                border.color: mode ? "#c0c0c0" : "#505050"
            }
            onClicked: {
                root.mode = !root.mode
            }
        }

        PlusButton {
            radius: 30
            col: root.plusColor
            onClicked: {
                taskPopup.open()
            }
        }

        TrashButton {
            radius: 25
            col: root.trashColor
            onClicked: {
                if(lModel.count > 0) lModel.remove(lModel.count-1)
            }
        }
    }

    TaskCreator {
        id: taskPopup
        modal: true
        focus: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    }

    TimeDateSelector {
        id: dateTimeSelector
        modal: true
        focus: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    }

    function validateInput() {
        let isValidName = taskPopup.taskName.text.length > 0 && taskPopup.taskName.text.length <= 30
        let isValidDesc = taskPopup.taskDescription.text.length <= 100
        let isValidDate = dateTimeSelector.selectedDate !== ""

        taskPopup.addButton.enabled = isValidName && isValidDesc && isValidDate

        taskPopup.taskNameError.text = !isValidName ?
            (taskPopup.taskName.text.length === 0 ? "Task name is required" : "Maximum 30 characters allowed") : ""
        taskPopup.dateError.text = !isValidDate ? "Deadline is required" : ""
    }
}
