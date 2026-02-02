pragma Singleton
import QtQuick

QtObject {
    readonly property int radius: 8

    // === Шрифты ===
    readonly property string fontMain: "JetBrainsMono Nerd Font Propo"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeNormal: 12
    readonly property int fontSizeItem: 16

    // === Colors ===
    readonly property color background: '#171011'
    readonly property color widgetBg: '#2e1e1e'
    readonly property color separator: "#45475a"
    
    // Text colors
    readonly property color textPrimary: '#e6accb'
    readonly property color textSecondary: '#b0d4f1'
    readonly property color textDark: "#db171723"

    // Button colors
    readonly property color buttonSelected: '#45ea7ca1'
}