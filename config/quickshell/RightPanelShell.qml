import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Qt.labs.folderlistmodel
import Qt.labs.platform as Platform
import "."

Scope {
    id: shell

    property var title: "Favorites"

    property var top: 200
    property var bottom: 200
    
    property string folderPath: "/favorites"
    property var model: Platform.StandardPaths.standardLocations(Platform.StandardPaths.HomeLocation)[0] + shell.folderPath
    property string nameFilter: ".txt"

    PanelWindow {
        id: triggerWin
        anchors { top: true; bottom: true; right: true }
        
        margins {
            top: shell.top
            bottom: shell.bottom
        }

        implicitWidth: 4
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        property var offsetMarginIdle: 3
        property var offsetMargin: triggerWin.offsetMarginIdle

        MouseArea {
            id: triggerArea
            anchors.fill: parent

            anchors.leftMargin: triggerWin.offsetMargin

            hoverEnabled: true
            propagateComposedEvents: false

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -triggerWin.offsetMargin
                topLeftRadius: Theme.radius
                bottomLeftRadius: Theme.radius
                color: Theme.widgetBg
            }

            onEntered: popup.openMenu()
            onExited: popup.closeMenu()
        }
    }

    PopupWindow {
        id: popup
        
        anchor { window: triggerWin }
        
        implicitWidth: 220
        implicitHeight: triggerWin.height
        
        visible: false 
        color: "transparent"

        property int slideOffset: 250

        function openMenu() {
            popup.visible = true
            closeTimer.stop()
            slideOffset = 0
            triggerWin.offsetMargin = 0
        }

        function closeMenu() {
            slideOffset = 250
            closeTimer.start() 
        }

        Timer {
            id: closeTimer
            interval: 300 
            onTriggered: {
                popup.visible = false
                triggerWin.offsetMargin = triggerWin.offsetMarginIdle
            }
        }

        Rectangle {
            id: background
            color: Theme.widgetBg
            topLeftRadius: Theme.radius
            bottomLeftRadius: Theme.radius
            anchors.fill: parent

            clip: true

            transform: Translate {
                x: popup.slideOffset
                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                id: backgroundMouse
                anchors.fill: parent
                hoverEnabled: true
                
                onEntered: popup.openMenu()
                onExited: popup.closeMenu()
            
                Text {
                    id: headerText
                    text: shell.title
                    color: Theme.textSecondary
                    font.bold: true
                    font.pixelSize: 14
                    anchors.top: parent.top
                    anchors.topMargin: 15
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    anchors.margins: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    y: 45
                    color: Theme.separator
                }

                ListView {
                    id: appList
                    anchors.top: headerText.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    anchors.topMargin: 15
                    
                    spacing: 5
                    clip: true

                    model: FolderListModel {
                        folder: shell.model
                        nameFilters: shell.nameFilters
                        showDirs: false
                    }

                    delegate: Rectangle {
                        width: appList.width
                        height: 36
                        color: itemMouse.containsMouse ? Theme.buttonSelected : "transparent"
                        radius: Theme.radius

                        Text {
                            text: fileName.replace(shell.nameFilter, "")
                            color: Theme.textPrimary
                            anchors.centerIn: parent
                            font.family: Theme.fontMain
                            font.pixelSize: Theme.fontSizeItem
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onEntered: popup.openMenu()

                            onClicked: {
                                var path = fileUrl.toString().replace("file://", "")
                                Quickshell.execDetached(["zsh", path])
                                popup.closeMenu()
                            }
                        }
                    }
                }
            }
        }
    }
}