import QtQuick
import QtQuick.Layouts

Item {
    id: rootItem
    width: lView.width
    height: 70

    property bool isBeingDeleted: false

    Behavior on height {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    Behavior on x {
        NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
    }

    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }

    Rectangle {
        id: rec
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        border.color: root.isDeleting ? root.trashDeletingColor : model.finished === 0 ? root.borderColor : root.taskFinished
        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }
        border.width: 2
        radius: 10
        height: 60
        color: root.bgColor

        property bool isOpened: false
        property bool isContentVisible: false
        property int expandedHeight: Math.max(120, 60 + descriptionLbl.height + buttonRow.height + 20) // Dynamic height based on content

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !rootItem.isBeingDeleted
            cursorShape: root.isDeleting ? Qt.PointingHandCursor : Qt.ArrowCursor
            onEntered: {
                gradientBackground.fadeDirection = "in";
                fadeTimer.start();
            }

            onExited: {
                gradientBackground.fadeDirection = "out";
                fadeTimer.start();
            }

            onClicked: {
                if(root.isDeleting && !isBeingDeleted){
                    // Start delete animation
                    rootItem.isBeingDeleted = true;

                    // Store the current index for the deletion
                    var currentIndex = -1;
                    for(let i = 0; i < lModel.count; ++i){
                        if(lModel.get(i).id === model.id){
                            currentIndex = i;
                            break;
                        }
                    }

                    if(currentIndex !== -1) {
                        // Schedule the deletion after animations
                        deleteTimer.modelIndex = currentIndex;
                        deleteTimer.start();
                        taskManager.removeTaskDB(model.id);
                    }
                }
                else{
                    rec.isOpened = !rec.isOpened;

                    contentTimer.stop();
                    collapseTimer.stop();

                    if (rec.isOpened) {
                        rec.height = rec.expandedHeight;
                        rootItem.height = rec.expandedHeight + 10;
                        contentTimer.start();
                    } else {
                        rec.isContentVisible = false;
                        collapseTimer.start();
                    }
                }
            }

            Timer {
                id: safetyTimer
                interval: 250
                repeat: false
                running: rec.isOpened !== rec.isContentVisible
                onTriggered: {
                    rec.isContentVisible = rec.isOpened;
                }
            }
        }

        Timer {
            id: contentTimer
            interval: 200
            repeat: false
            onTriggered: {
                rec.isContentVisible = true;
            }
        }

        Timer {
            id: collapseTimer
            interval: 150
            repeat: false
            onTriggered: {
                rec.height = 60;
                rootItem.height = 70;
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
            property color hoverColor: root.isDeleting ? root.trashDeletingColor : model.finished === 0 ? root.borderColor : root.taskFinished

            Behavior on hoverColor {
                ColorAnimation {
                    duration: 200
                }
            }

            gradient: Gradient {
                GradientStop { position: 0.0; color: root.bgColor }
                GradientStop { position: 0.5; color: root.bgColor }
                GradientStop { position: 1.0; color: gradientBackground.hoverColor }

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
                    font.strikeout: model.finished
                    font.pointSize: 15
                    font.bold: true
                    color: model.finished===0 ? root.textColor : root.taskFinished
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                    Behavior on font.strikeout {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
                Text {
                    id: deadlineLbl
                    text: model.deadline
                    color: root.textColor
                    Layout.bottomMargin: 20
                }
                Text {
                    id: descriptionLbl
                    text: model.description
                    width: rootItem.width - 40
                    wrapMode: Text.Wrap
                    color: root.textColor
                    font.pointSize: 8
                    opacity: rec.isContentVisible ? 1 : 0
                    // Update the rectangle's expanded height whenever the text changes
                    onTextChanged: {
                        // Force layout update to get correct height
                        descriptionLbl.height = implicitHeight;
                        rec.expandedHeight = Math.max(120, 60 + descriptionLbl.height + buttonRow.height + 20);

                        // If already expanded, update heights immediately
                        if (rec.isOpened) {
                            rec.height = rec.expandedHeight;
                            rootItem.height = rec.expandedHeight + 10;
                        }
                    }

                    // Also update on component completion
                    Component.onCompleted: {
                        descriptionLbl.height = implicitHeight;
                        rec.expandedHeight = Math.max(120, 60 + descriptionLbl.height + buttonRow.height + 20);
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }
                Item {
                    y: rec.expandedHeight - 49
                    Row{
                        id: buttonRow
                        spacing: 10
                        Rectangle {
                            id: trashTask
                            width: 33
                            height: 33
                            color: "red"
                            radius: 20
                            opacity: rec.isContentVisible ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation { duration: 150 }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    // Start delete animation
                                    rootItem.isBeingDeleted = true;

                                    // Store the current index for the deletion
                                    var currentIndex = -1;
                                    for(let i = 0; i < lModel.count; ++i){
                                        if(lModel.get(i).id === model.id){
                                            currentIndex = i;
                                            break;
                                        }
                                    }

                                    if(currentIndex !== -1) {
                                        // Schedule the deletion after animations
                                        deleteTimer.modelIndex = currentIndex;
                                        deleteTimer.start();
                                        taskManager.removeTaskDB(model.id);
                                    }
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
                            opacity: rec.isContentVisible ? 1 : 0

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    taskPopup.startName = model.name
                                    taskPopup.startDesc = model.description
                                    taskPopup.startPriority = model.priority
                                    taskPopup.currentId = model.id
                                    taskPopup.isEditing = true
                                    dateTimeSelector.selectedDate = model.deadline
                                    taskPopup.open()
                                }
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: 150 }
                            }

                            Image {
                                source: "qrc:/qt/qml/Serenify/Images/pencil.png"
                                width: editTask.width * 0.6
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                smooth: true
                            }
                        }
                        Rectangle {
                            id: finishTask
                            width: 33
                            height: 33
                            color: "green"
                            radius: 20
                            opacity: rec.isContentVisible ? 1 : 0

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if(model.finished===0){
                                        model.finished = 1;
                                    }
                                    else model.finished = 0;
                                    root.sortTasks();
                                }
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: 150 }
                            }

                            Image {
                                source: "qrc:/qt/qml/Serenify/Images/checkmark.png"
                                width: finishTask.width * 0.6
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                smooth: true
                            }
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
                        if (model.priority === "Low") return "green";
                        if (model.priority === "Medium") return "yellow";
                        if (model.priority === "High") return "red";
                    }
                    color: assignColor()
                    width: 12
                    height: 12
                    radius: 10
                }
            }
        }
    }

    // Handle the deletion animation
    states: [
        State {
            name: "deleting"
            when: rootItem.isBeingDeleted
            PropertyChanges { target: rootItem; x: rootItem.width }
            PropertyChanges { target: rootItem; opacity: 0 }
        }
    ]

    // Timer to actually remove the item after animation
    Timer {
        id: deleteTimer
        interval: 300 // Match the duration of the delete animation
        repeat: false
        property int modelIndex: -1
        onTriggered: {
            if(modelIndex !== -1) {
                lModel.remove(modelIndex);
                rootItem.isBeingDeleted = false;
            }
        }
    }
}
