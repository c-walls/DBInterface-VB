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
    Private workLocationName As New TextBox()
    Private workLocationNameLabel As New Label() With {.Text = "Name:"}
    Private workLocationAddress As New TextBox() With {.Multiline = True, .Height = workLocationAddress.Height * 2.5}
    Private workLocationAddressLabel As New Label() With {.Text = "Address:"}
    Private workOrderDate As New DateTimePicker() With {.Format = DateTimePickerFormat.Short}
    Private workOrderDateLabel As New Label() With {.Text = "Date:"}
    Private workOrderNotes As New TextBox() With {.Multiline = True, .Height = workLocationAddress.Height * 2.5}
    Private workOrderNotesLabel As New Label() With {.Text = "Notes:"}
    Private manager As New ComboBox() With {.DropDownStyle = ComboBoxStyle.DropDownList}
    Private managerLabel As New Label() With {.Text = "Manager:"}
    Private dateRequired As New DateTimePicker() With {.Format = DateTimePickerFormat.Short}
    Private dateRequiredLabel As New Label() With {.Text = "Date Required:"}

    Private WithEvents taskOrderDG As New DataGridView() With {.Anchor = AnchorStyles.Left}
    Private taskOrder_DGColumn As New DataGridViewComboBoxColumn() With {.HeaderText = "Task", .Name = "Task"}

    Public Shared selectedProposal As String
    Private mainFields As Control() = {workOrderNo, proposalNo, workLocationName, workLocationAddress, workOrderDate, workOrderNotes, manager, dateRequired}
    Private mainLabels As Label() = {workOrderNoLabel, proposalNoLabel, workLocationLabel, workLocationNameLabel, workLocationAddressLabel, workOrderDateLabel, workOrderNotesLabel, managerLabel, dateRequiredLabel}


    Public Sub New()
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
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 25))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 18))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 14))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 18))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 25))
        tableLayoutPanel.RowCount = 10
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 30))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 30))
        Me.Controls.Add(tableLayoutPanel)

        ' Configure DataGridView
        taskOrderDG.Margin = New Padding(200, 40, 200, 10)
        tableLayoutPanel.SetColumnSpan(taskOrderDG, 5)
        taskOrderDG.Columns.Insert(0, taskOrder_DGColumn)
        taskOrderDG.Columns.Add("SquareFeet", "Square Feet")
        taskOrderDG.Columns.Add("EstHours", "Estimated Hours")
        taskOrderDG.Columns.Add("Status", "Status")
        taskOrderDG.Columns.Add("DateComplete", "Date Complete")
        taskOrderDG.Columns(3).ReadOnly = True
        taskOrderDG.Columns(4).ReadOnly = True
        taskOrderDG.Rows.Add(3)

        For Each control As Control In mainFields
            control.Width = 200
            control.Anchor = AnchorStyles.Left
        Next

        For Each label As Label In mainLabels
            label.Width = 200
            label.Anchor = AnchorStyles.Right
            label.TextAlign = ContentAlignment.MiddleRight
        Next

        taskOrderDG.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
        taskOrderDG.Dock = DockStyle.Fill

        ' Add controls to TableLayoutPanel
        tableLayoutPanel.Controls.Add(workOrderNoLabel, 0, 2)
        tableLayoutPanel.Controls.Add(workOrderNo, 1, 2)
        tableLayoutPanel.Controls.Add(proposalNoLabel, 0, 3)
        tableLayoutPanel.Controls.Add(proposalNo, 1, 3)
        tableLayoutPanel.Controls.Add(workLocationLabel, 0, 4)
        tableLayoutPanel.Controls.Add(workLocationNameLabel, 0, 5)
        tableLayoutPanel.Controls.Add(workLocationName, 1, 5)
        tableLayoutPanel.Controls.Add(workLocationAddressLabel, 0, 6)
        tableLayoutPanel.Controls.Add(workLocationAddress, 1, 6)
        tableLayoutPanel.Controls.Add(workOrderDateLabel, 3, 2)
        tableLayoutPanel.Controls.Add(workOrderDate, 4, 2)
        tableLayoutPanel.Controls.Add(workOrderNotesLabel, 3, 4)
        tableLayoutPanel.Controls.Add(workOrderNotes, 4, 4)
        tableLayoutPanel.Controls.Add(taskOrderDG, 0, 7)
        tableLayoutPanel.Controls.Add(managerLabel, 0, 8)
        tableLayoutPanel.Controls.Add(manager, 1, 8)
        tableLayoutPanel.Controls.Add(dateRequiredLabel, 3, 8)
        tableLayoutPanel.Controls.Add(dateRequired, 4, 8)


        AddHandler Me.Load, AddressOf WorkOrderPage_Load
    End Sub

    Private Sub WorkOrderPage_Load(sender As Object, e As EventArgs) Handles Me.Load
        PopulateManagersList()
        'PopulateTasksList()
        proposalNo.Text = selectedProposal
        workOrderNo.Text = "W" & proposalNo.Text.Substring(2, 4) & "-01"
    End Sub

    Private Sub PopulateTasksList()
        Dim dataTable As DataTable = DBHandler.ExecuteTableQuery("SELECT Task_Names FROM Tasks WHERE Task_ID IN (SELECT Task_ID FROM TaskRequests WHERE Proposal_No = '" & selectedProposal & "')")

        ' Set the data source of the DataGridViewComboBoxColumn.
        TaskOrder_DGColumn.DataSource = dataTable
        TaskOrder_DGColumn.DisplayMember = "Task_Names"
        TaskOrder_DGColumn.ValueMember = "Task_Names"
    End Sub

    Private Sub PopulateManagersList()
        Dim dataTable As DataTable = DBHandler.ExecuteTableQuery("SELECT Emp_Name FROM Employees WHERE Emp_Role = 'Project Manager' OR Emp_Role = 'Crew Supervisor'")

        ' Add an empty row to the top of the DataTable.
        Dim row As DataRow = dataTable.NewRow()
        row("Emp_Name") = ""
        dataTable.Rows.InsertAt(row, 0)

        ' Set the data source of the ComboBox.
        manager.DataSource = dataTable
        manager.DisplayMember = "Emp_Name"
        manager.ValueMember = "Emp_Name"
    End Sub
End Class