Imports System
Imports System.Data
Imports System.Drawing
Imports System.Windows.Forms

Public Class WorkOrderPage
    Inherits UserControl

    Private workOrderNo As New TextBox() With {.ReadOnly = True}
    Private workOrderNoLabel As New Label() With {.Text = "Work Order Number:"}
    Private proposalNo As New TextBox() With {.ReadOnly = True}
    Private proposalNoLabel As New Label() With {.Text = "Proposal Number:"}
    Private workLocationLabel As New Label() With {.Text = "Work Location:"}
    Private workLocationName As New TextBox() With {.ReadOnly = True}
    Private workLocationNameLabel As New Label() With {.Text = "Name:"}
    Private workLocationAddress As New TextBox() With {.ReadOnly = True, .Multiline = True}
    Private workLocationAddressLabel As New Label() With {.Text = "Address:"}
    Private workOrderDate As New DateTimePicker() With {.Format = DateTimePickerFormat.Short}
    Private workOrderDateLabel As New Label() With {.Text = "Date:"}
    Private workOrderNotes As New TextBox() With {.Multiline = True}
    Private workOrderNotesLabel As New Label() With {.Text = "Notes:"}
    Private manager As New ComboBox() With {.DropDownStyle = ComboBoxStyle.DropDownList}
    Private managerLabel As New Label() With {.Text = "Manager:"}
    Private dateRequired As New DateTimePicker() With {.Format = DateTimePickerFormat.Short}
    Private dateRequiredLabel As New Label() With {.Text = "Date Required:"}


    Public Sub New()
        ' Create a header label
        Dim headerLabel As New Label() With {
            .Text = "Work Order Form",
            .Dock = DockStyle.Top,
            .Font = New Font("Arial", 24, FontStyle.Bold),
            .TextAlign = ContentAlignment.MiddleCenter,
            .Height = 50}
        Me.Controls.Add(headerLabel)

        ' Configure TableLayoutPanel
        Dim tableLayoutPanel As New TableLayoutPanel()
        tableLayoutPanel.Dock = DockStyle.Fill
        tableLayoutPanel.ColumnCount = 5
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 20))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 20))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 20))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 20))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 20))
        tableLayoutPanel.RowCount = 12
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 25))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 2.5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 2.5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        Me.Controls.Add(tableLayoutPanel)

    End Sub
End Class