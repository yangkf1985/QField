import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import org.qgis 1.0
import org.qfield 1.0

import Theme 1.0

Popup {
  id: popup

  property var layerTree
  property var index

  property bool zoomToLayerButtonVisible: false

  property bool trackingButtonVisible: false
  property var trackingButtonText

  property bool expandCheckBoxVisible: false


  width: Math.min( childrenRect.width, mainWindow.width - 20 )
  x: (parent.width - width) / 2
  y: (parent.height - height) / 2
  padding: 0

  onIndexChanged: {
    title = layerTree.data(index, Qt.DisplayName)

    itemVisibleCheckBox.checked = layerTree.data(index, FlatLayerTreeModel.Visible);

    expandCheckBoxVisible = layerTree.data(index, FlatLayerTreeModel.HasChildren)
    expandCheckBox.text = layerTree.data( index, FlatLayerTreeModel.Type ) === 'group' ? qsTr('Expand group') : qsTr('Expand legend item')
    expandCheckBox.checked = !layerTree.data(index, FlatLayerTreeModel.IsCollapsed)

    zoomToLayerButtonVisible = isZoomToLayerButtonVisible()

    trackingButtonVisible = isTrackingButtonVisible()
    trackingButtonText = trackingModel.layerInTracking( layerTree.data(index, FlatLayerTreeModel.VectorLayerPointer) ) ? qsTr('Stop tracking') : qsTr('Start tracking')
  }

  Page {
    width: parent.width
    padding: 10
    header: Label {
      padding: 10
      topPadding: 15
      bottomPadding: 0
      width: parent.width - 20
      text: title
      font: Theme.strongFont
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.WordWrap
    }

    ColumnLayout {
      spacing: 4
      width: parent.width

      FontMetrics {
        id: fontMetrics
        font: lockText.font
      }

      Text {
        id: lockText
        property var padlockIcon: Theme.getThemeIcon('ic_lock_black_24dp')
        property var padlockSize: fontMetrics.height - 5

        visible: index !== undefined && (layerTree.data(index, FlatLayerTreeModel.ReadOnly) ||
                                        layerTree.data(index, FlatLayerTreeModel.GeometryLocked))
        Layout.fillWidth: true

        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        text: '<img src="' + padlockIcon + '" width="' + padlockSize + '" height="' + padlockSize + '"> '
              + (index !== undefined && layerTree.data(index, FlatLayerTreeModel.ReadOnly)
                  ? qsTr('This layer is configured as "Read-Only" which disables adding, deleting and editing features.')
                  : qsTr('This layer is configured as "Lock Geometries" which disables adding and deleting features, as well as modifying the geometries of existing features.'))
        font: Theme.tipFont
      }

      Text {
        id: invalidText
        property var invalidIcon: Theme.getThemeVectorIcon('ic_error_outline_24dp')
        property var invalidSize: fontMetrics.height - 5

        visible: index !== undefined && !layerTree.data(index, FlatLayerTreeModel.IsValid)
        Layout.fillWidth: true

        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        text: '<img src="' + invalidIcon + '" width="' + invalidSize + '" height="' + invalidSize + '"> '
              + qsTr('This layer is invalid. This might be due to a network issue, a missing file or a misconfiguration of the project.')
        font: Theme.tipFont
      }

      CheckBox {
        id: itemVisibleCheckBox
        Layout.fillWidth: true
        topPadding: 5
        bottomPadding: 5
        text: qsTr('Show on map canvas')
        font: Theme.defaultFont

        indicator.height: 16
        indicator.width: 16
        indicator.implicitHeight: 24
        indicator.implicitWidth: 24

        onCheckStateChanged: {
          layerTree.setData(index, checkState === Qt.Checked, FlatLayerTreeModel.Visible);
          close()
        }
      }

      CheckBox {
        id: expandCheckBox
        Layout.fillWidth: true
        text: qsTr('Expand legend item')
        font: Theme.defaultFont
        visible: expandCheckBoxVisible

        onCheckStateChanged: {
          layerTree.setData(index, checkState === Qt.Unchecked, FlatLayerTreeModel.IsCollapsed);
          close()
        }
      }

      QfButton {
        id: zoomToLayerButton
        Layout.fillWidth: true
        Layout.topMargin: 5
        font: Theme.defaultFont
        text: qsTr('Zoom to layer')
        visible: zoomToLayerButtonVisible

        onClicked: {
          mapCanvas.mapSettings.setCenterToLayer( layerTree.data( index, FlatLayerTreeModel.MapLayerPointer ) )
          close()
          dashBoard.visible = false
        }
      }

      QfButton {
        id: trackingButton
        Layout.fillWidth: true
        Layout.topMargin: 5
        font: Theme.defaultFont
        text: trackingButtonText
        visible: trackingButtonVisible

        onClicked: {
            //start track
            if ( trackingModel.layerInTracking( layerTree.data(index, FlatLayerTreeModel.VectorLayerPointer) ) ) {
                 trackingModel.stopTracker(layerTree.data(index, FlatLayerTreeModel.VectorLayerPointer));
                 displayToast( qsTr( 'Track on layer %1 stopped' ).arg( layerTree.data(index, FlatLayerTreeModel.VectorLayerPointer).name  ) )
            } else {
                trackingModel.createTracker(layerTree.data(index, FlatLayerTreeModel.VectorLayerPointer), itemVisibleCheckBox.checked );
            }
            close()
        }
      }
    }
  }

  function isTrackingButtonVisible() {
    if ( !index )
      return false

    return layerTree.data( index, FlatLayerTreeModel.Type ) === 'layer'
        && layerTree.data( index, FlatLayerTreeModel.Trackable )
        && positionSource.active
  }

  function isZoomToLayerButtonVisible() {
      if ( !index )
        return false

      return ( layerTree.data( index, FlatLayerTreeModel.Type ) === 'layer' )
  }
}
