import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

import "."

ShellRoot {
    id: root

    RightPanelShell {
        top: 400
        bottom: 200

        folderPath: "/favorites" // is $HOME/favorites or ~/favorites
        nameFilter: ".txt" // any format for select
    }
}