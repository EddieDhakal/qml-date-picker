import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import Qt.labs.qmlmodels 1.0


Item {
    property date selected_date: new Date()
    property string format: 'dddd, d MMMM yyyy'
    property date _temp_date: selected_date

    function days_in_a_month(y, m) {
        return new Date(y, m + 1, 0).getDate()
    }

    function week_start(y, m) {
        return new Date(y, m, 1).getDay()
    }

    function sync_calendar(day) {
        const month = day.getMonth()
        const year = day.getFullYear()
        const total_days = days_in_a_month(year, month)
        const first_day = week_start(year, month)

        model.clear()
        for (let filler = 0; filler < first_day; filler++) {
            model.append({ day: 0 })
        }

        for (let i = 1; i <= total_days; i++) {
            model.append({ day: i })
        }
    }

    function next_month() {
        const _date = _temp_date
        _date.setMonth(_temp_date.getMonth() + 1)
        sync_calendar(_date)
        return _date
    }

    function previous_month() {
        const _date = _temp_date
        _date.setMonth(_temp_date.getMonth() - 1)
        sync_calendar(_date)
        return _date
    }

    Column {
        focus: true
        Keys.onPressed: {
            if (event.key === Qt.Key_Escape) {
                date_picker_trigger.checked = false
            }
        }

        Row {
            TextField {
                id: date_field
                text: selected_date.toLocaleDateString(Qt.locale(), format)
                width: 300
                readOnly: true

                TapHandler {
                    onTapped: {
                        date_picker_trigger.checked = !date_picker_trigger.checked
                    }
                }
            }

            Button {
                id: date_picker_trigger
                text: checked ? '▲' : '▼'
                checkable: true
                onCheckedChanged: {
                    if (checked) {
                        sync_calendar(selected_date)
                    }
                }
            }
        }

        ColumnLayout {
            visible: date_picker_trigger.checked
            width: 245
            height: 245
            anchors.right: parent.right
            anchors.rightMargin: date_picker_trigger.width

            RowLayout {
                Layout.fillWidth: true

                RoundButton {
                    text: '<'
                    onClicked: _temp_date = previous_month()
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: _temp_date.toLocaleDateString(Qt.locale(), 'MMM yyyy')
                    font.pixelSize: 18
                }

                RoundButton {
                    Layout.alignment: Qt.AlignRight
                    text: '>'
                    onClicked: _temp_date = next_month()
                }
            }

            Grid {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rows: 7

                Repeater {
                    model: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    delegate: Label {
                        width: 35
                        height: 35
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                    }
                }

                Repeater {
                    model: ListModel { id: model }

                    delegate: DelegateChooser {
                        DelegateChoice {
                            roleValue: 0

                            delegate: Item {
                                width: 35
                                height: 35
                            }
                        }

                        DelegateChoice {
                            delegate: Button {
                                width: 35
                                height: 35
                                text: day
                                highlighted: day === _temp_date.getDate() && selected_date.getMonth() === _temp_date.getMonth() && selected_date.getFullYear() === _temp_date.getFullYear()
                                onClicked: {
                                    const _date = _temp_date
                                    _date.setDate(day)
                                    _temp_date = _date
                                    selected_date = _temp_date
                                    date_picker_trigger.checked = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
