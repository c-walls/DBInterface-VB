Imports System
Imports System.Data
Imports System.Drawing
Imports System.Windows.Forms

Public Class Dashboard
    Inherits UserControl

    Private tableLayoutPanel As New TableLayoutPanel()
    Private dataGridView As New DataGridView()
    Private tabControl As New TabControl()
    Private button1 As New Button()
    Private button2 As New Button()

    Public Sub New()
        ' Set up the TableLayoutPanel
        tableLayoutPanel.Dock = DockStyle.Fill
        tableLayoutPanel.RowCount = 3
        tableLayoutPanel.ColumnCount = 1
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 75))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 25))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Absolute, 50))
        Controls.Add(tableLayoutPanel)

        ' Set up the DataGridView
        dataGridView.Dock = DockStyle.Fill
        tableLayoutPanel.Controls.Add(dataGridView, 0, 0)

        ' Set up the TabControl
        tabControl.Dock = DockStyle.Fill
        For i As Integer = 1 To 4
            tabControl.TabPages.Add($"Tab {i}")
        Next
        tableLayoutPanel.Controls.Add(tabControl, 0, 1)

        ' Set up the buttons
        button1.Text = "Button 1"
        button2.Text = "Button 2"
        Dim buttonPanel As New FlowLayoutPanel() With {.Dock = DockStyle.Fill}
        buttonPanel.Controls.Add(button1)
        buttonPanel.Controls.Add(button2)
        tableLayoutPanel.Controls.Add(buttonPanel, 0, 2)
    End Sub
End Class