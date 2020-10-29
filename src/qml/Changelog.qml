import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import Theme 1.0
import org.qfield 1.0

Item {
  signal close()

  height: childrenRect.height
  width: parent.width

  GridLayout {
    id: mainGrid

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 20

    columns: 1

    Item {
        // top margin
        height: 20
    }

    Text {
      id: title
      text: qsTr( "What's new in the latest QField" )
      color: Theme.mainColor
      font: Theme.titleFont
      minimumPixelSize: 12


      fontSizeMode: Text.VerticalFit
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.minimumHeight: contentHeight
      Layout.maximumHeight: contentHeight
    }

    Text {
      id: changelogBody
      property bool isSuccess: false
      color: '#95000000'
      font: Theme.tipFont

      fontSizeMode: Text.VerticalFit
      textFormat: Text.MarkdownText
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.minimumHeight: contentHeight
      Layout.maximumHeight: contentHeight

      onLinkActivated: Qt.openUrlExternally(link)
    }

    QfButton {
      id: closeButton
      Layout.fillWidth: true

      text: qsTr( 'OK' )
      onClicked: close()
    }

    Item {
        // bottom
        height: 20
    }
  }

  function parseVersion(str) {
    str = str.replace(/^[a-z]*/, '')

    var parts = str.split('.')

    if (parts[0] >= 0 && parts[1] >= 0 && parts[2] >= 0)
      return [parts[0], parts[1], parts[2]]

    return []
  }

  function refreshChangelog() {

      console.log("Stupidlog: refresh 01")
    if ( changelogBody.isSuccess )
      return

    console.log("Stupidlog: refreshed 02")
    try {
        console.log("Stupidlog: 1")
      var RELEASES_URL = 'https://api.github.com/repos/opengisch/qfield/releases'
      var xhr = new XMLHttpRequest()

        console.log("Stupidlog: 2")
      xhr.open('GET', RELEASES_URL)
      xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            console.log("Stupidlog: 3")
          var resp = xhr.responseText
          var qfieldVersion = parseVersion(version)
          var versionNumbersOnly = ''
          var changelog = ''
            console.log("Stupidlog: 4")

          try {
              console.log("Stupidlog: 5")
            var releases = JSON.parse(resp)

            for (var i = 0, l = releases.length; i < l; i++) {
              var release = releases[i]
              var releaseVersion = parseVersion(release['tag_name'])

                console.log("Stupidlog: 6")
              if (releaseVersion.length === 0)
                continue

              // most probably developer version with no proper version set
              if (qfieldVersion.length === 0)
                qfieldVersion = releaseVersion

              if (qfieldVersion[0] !== releaseVersion[0] || qfieldVersion[1] !== releaseVersion[1])
                continue

              if ( !versionNumbersOnly )
                versionNumbersOnly = releaseVersion.join('.')

              var releaseChangelog = '\n#\n# ' + release['name'] + '\n\n' + release['body'] + '\n'
              // prepend the current release
              changelog = releaseChangelog + changelog
            }

            console.log("Stupidlog: 7")
            if ( changelog.length === 0 )
              throw new Error('Empty changelog!')

            console.log("Stupidlog: 8")
            changelog += '\n' + '[' + qsTr('Previous releases on GitHub') + '](https://github.com/opengisch/qfield/releases)'
            changelog = changelog.replace(/^##(.+)$/gm, function(full) {
              return '\n###\n' + full + '\n\n\n'
            })

            var changelogPeffix = '';
            changelogPeffix += 'Up to release **' + versionNumbersOnly + '**'

            console.log("Stupidlog: 9")
            changelogBody.text = changelogPeffix + changelog
            changelogBody.isSuccess = true
          } catch (err) {
              console.log("Stupidlog: 10")
            changelogBody.text = qsTr('Cannot retrieve the changelog. Please check your internet connection.')
          }
          console.log("Stupidlog: 11")
        }
        console.log("Stupidlog: 12")
      }
        console.log("Stupidlog: 13")
      xhr.send()

      changelogBody.text = qsTr('Loading…')
        console.log("Stupidlog: 14")
    } catch (err) {
        console.log("Stupidlog: incatch 1")
      console.error(err)
      close()
        console.log("Stupidlog: incatch 2")
    }
  }
}
