import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

import org.qfield 1.0
import org.qgis 1.0
import Theme 1.0

Item {
  id: relationCombobox

  anchors {
    left: parent.left
    right: parent.right
    rightMargin: 10
  }

  Popup {
    id: popup

    signal cancel
    signal apply
    signal finished

    parent: ApplicationWindow.overlay
    x: 24
    y: 24
    width: parent.width - 48
    height: parent.height - 48
    padding: 0
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    focus: visible
    visible: true

    onCancel: {
      close()
      finished()
    }

    onApply: {
      finished()
    }

    Page {
      anchors.fill: parent

      header: PageHeader {
        title: qsTr('Related Features')
        showApplyButton: true
        showCancelButton: true
        onApply: popup.apply()
        onCancel: popup.cancel()
      }

      TextField {
        z: 1
        id: searchField
        anchors.left: parent.left
        anchors.right: parent.right

        placeholderText: qsTr("Search…")
        placeholderTextColor: Theme.mainColor

        leftPadding: 24
        rightPadding: 24
        font: Theme.defaultFont
        selectByMouse: true
        verticalAlignment: TextInput.AlignVCenter

        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

        onDisplayTextChanged: {
          featureListModel.searchTerm = searchField.displayText
        }
      }

      ScrollView {
        padding: 20

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: searchField.bottom

        leftPadding: 0
        rightPadding: 0

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        contentItem: resultsList
        contentWidth: resultsList.width
        contentHeight: resultsList.height
        clip: true

        ListView {
          id: resultsList
          anchors.top: parent.top
          model: featureListModel
          width: parent.width
          height: popup.height - searchField.height - 50
          clip: true

          delegate: Rectangle {
            id: delegateRect

            anchors.margins: 10
            height: radioButton.visible ? radioButton.height : checkBoxButton.height
            width: parent ? parent.width : undefined

            RadioButton {
              id: radioButton

              visible: !featureListModel.allowMulti
              checked: model.checked
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              text: displayString
              topPadding: 12
              bottomPadding: 12
              leftPadding: 24
              rightPadding: 24
              ButtonGroup.group: buttonGroup
            }

            CheckBox {
              id: checkBoxButton

              visible: featureListModel.allowMulti
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              text: displayString
              topPadding: 12
              bottomPadding: 12
              leftPadding: 24
              rightPadding: 24
            }

            /* bottom border */
            Rectangle {
              anchors.bottom: parent.bottom
              height: 1
              color: "lightGray"
              width: parent.width
            }

            MouseArea {
              anchors.fill: parent
              propagateComposedEvents: true

              onClicked: {
                var allowMulti = resultsList.model.allowMulti;
                var popupRef = popup;

                // after this line, all the references get wrong, that's why we have `popupRef` defined above
                model.checked = !model.checked

                if (!allowMulti) {
                  popupRef.close()
                  popupRef.apply()
                  popupRef.finished()
                }
              }
            }
          }
        }
      }
    }
  }

  ButtonGroup { id: buttonGroup }

//  Rectangle {
//    id: resultsBox
//    z: 1000000
//    width: searchField.width - 24
//    height: searchField.visible && resultsList.count > 0 ? resultsList.height : 0
//    anchors.top: searchField.top
//    anchors.left: searchField.left
//    anchors.topMargin: 24
//    color: "blue"
//    visible: searchField.visible && resultsList.count > 0
//    clip: true

//    Behavior on height {
//      NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
//    }

//    ListView {
//      id: resultsList
//      z: 20000000
//      anchors.top: resultsBox.top
//      model: featureListModel
//      width: parent.width
//      height: resultsList.count > 0 ? Math.min( childrenRect.height, mainWindow.height / 2 - searchField.height - 10 ) : 0
//      clip: true

//      delegate: Rectangle {
//        id: delegateRect

//        property bool isGroup: model.ResultFilterGroupSorting === 0
//        property int resultIndex: index

//        anchors.margins: 10
//        height: isGroup ? 25 : 40
//        width: parent.width
//        visible: model.ResultType !== 0 // remove filter name

//        Text {
//          id: textCell
//          text: displayString
//          anchors.verticalCenter: parent.verticalCenter
//          anchors.left: parent.left
//          leftPadding: 5
//          font.bold: delegateRect.isGroup ? true : false
//          font.pointSize: Theme.resultFont.pointSize
//          elide: Text.ElideRight
//          horizontalAlignment: isGroup ? Text.AlignHCenter : Text.AlignLeft
//        }

//        /* bottom border */
//        Rectangle {
//          anchors.bottom: parent.bottom
//          height: isGroup ? 0 : 1
//          color: "lightGray"
//          width: parent.width
//        }

//        MouseArea {
//          anchors.left: parent.left
//          anchors.top: parent.top
//          anchors.bottom: parent.bottom
//          onClicked: {
//            locator.triggerResultAtRow(index)
//            locatorItem.state = "off"
//          }
//        }
//      }
//    }
//  }

//  Component.onCompleted: {
//    comboBox.currentIndex = featureListModel.findKey(value)
//    comboBox.visible = _relation !== undefined ? _relation.isValid : true
//    addButton.visible = _relation !== undefined ? _relation.isValid : false
//    invalidWarning.visible = _relation !== undefined ? !(_relation.isValid) : false
//  }

//  anchors {
//    left: parent.left
//    right: parent.right
//    rightMargin: 10
//  }

//  property var currentKeyValue: value
//  onCurrentKeyValueChanged: {
//    comboBox._cachedCurrentValue = currentKeyValue
//    comboBox.currentIndex = featureListModel.findKey(currentKeyValue)
//  }

//  height: childrenRect.height + 10

  RowLayout {
    anchors { left: parent.left; right: parent.right }

    ComboBox {
      id: comboBox

      property var _cachedCurrentValue

      textRole: 'display'

      Layout.fillWidth: true

      model: featureListModel

      onCurrentIndexChanged: {
        var newValue = featureListModel.dataFromRowIndex(currentIndex, FeatureListModel.KeyFieldRole)
        valueChanged(newValue, false)
      }

      Connections {
        target: featureListModel

        onModelReset: {
          comboBox.currentIndex = featureListModel.findKey(comboBox._cachedCurrentValue)
        }
      }

      MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true

        onClicked: mouse.accepted = false
        onPressed: { forceActiveFocus(); mouse.accepted = false; }
        onReleased: mouse.accepted = false;
        onDoubleClicked: mouse.accepted = false;
        onPositionChanged: mouse.accepted = false;
        onPressAndHold: mouse.accepted = false;
      }

      // [hidpi fixes]
      delegate: ItemDelegate {
        width: comboBox.width
        height: 36
        text: comboBox.textRole ? (Array.isArray(comboBox.model) ? modelData[comboBox.textRole] : model[comboBox.textRole]) : modelData
        font.weight: comboBox.currentIndex === index ? Font.DemiBold : Font.Normal
        font.pointSize: Theme.defaultFont.pointSize
        highlighted: comboBox.highlightedIndex == index
      }

      contentItem: Text {
        id: textLabel
        height: fontMetrics.height + 20
        text: comboBox.displayText
        font: Theme.defaultFont
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        color: value === undefined || !enabled ? 'gray' : 'black'
      }

      background: Item {
        implicitWidth: 120
        implicitHeight: 36

        Rectangle {
          y: textLabel.height - 8
          width: comboBox.width
          height: comboBox.activeFocus ? 2 : 1
          color: comboBox.activeFocus ? "#4CAF50" : "#C8E6C9"
        }

        Rectangle {
          visible: enabled
          anchors.fill: parent
          id: backgroundRect
          border.color: comboBox.pressed ? "#4CAF50" : "#C8E6C9"
          border.width: comboBox.visualFocus ? 2 : 1
          color: Theme.lightGray
          radius: 2
        }
      }
      // [/hidpi fixes]
    }
  }

//    Image {
//      Layout.margins: 4
//      Layout.preferredWidth: 18
//      Layout.preferredHeight: 18
//      id: addButton
//      source: Theme.getThemeIcon("ic_add_black_48dp")
//      width: 18
//      height: 18

//      MouseArea {
//        anchors.fill: parent
//        onClicked: {
//            addFeaturePopup.state = 'Add'
//            addFeaturePopup.currentLayer = relationCombobox._relation ? relationCombobox._relation.referencedLayer : null
//            addFeaturePopup.open()
//        }
//      }
//    }

//    Text {
//      id: invalidWarning
//      visible: false
//      text: qsTr( "Invalid relation")
//      color: Theme.errorColor
//    }
//  }

//  EmbeddedFeatureForm{
//      id: addFeaturePopup

//      onFeatureSaved: {
//          var referencedValue = addFeaturePopup.attributeFormModel.attribute(relationCombobox._relation.resolveReferencedField(field.name))
//          var index = featureListModel.findKey(referencedValue)
//          if ( index < 0 ) {
//            // model not yet reloaded - keep the value and set it onModelReset
//            comboBox._cachedCurrentValue = referencedValue
//          } else {
//            comboBox.currentIndex = index
//          }
//      }
//  }
}
