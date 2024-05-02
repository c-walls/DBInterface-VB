Imports System
Imports System.Data
Imports System.Drawing
Imports System.Windows.Forms

Public Class WorkAssignmentPage
    Inherits UserControl

    Private assignmentNo As New TextBox() With {.ReadOnly = True}
    Private assignmentNoLabel As New Label() With {.Text = "Assignment Number:"}
    Private workOrderNo As New TextBox() With {.ReadOnly = True}
    Private workOrderNoLabel As New Label() With {.Text = "Work Order Number:"}
    Private workLocationLabel As New Label() With {.Text = "Work Location:"}
    Private workLocationName As New TextBox()
    Private workLocationNameLabel As New Label() With {.Text = "Name:"}
    Private workLocationAddress As New TextBox() With {.Multiline = True}
    Private workLocationAddressLabel As New Label() With {.Text = "Address:"}
    Private startDate As New DateTimePicker() With {.Format = DateTimePickerFormat.Custom, .CustomFormat = "MM/dd/yyyy"}
    Private startDateLabel As New Label() With {.Text = "Start Date:"}
    Private endDate As New DateTimePicker() With {.Format = DateTimePickerFormat.Custom, .CustomFormat = "MM/dd/yyyy"}
    Private endDateLabel As New Label() With {.Text = "End Date:"}
    Private vehicleNo As New ComboBox() With {.DropDownStyle = ComboBoxStyle.DropDownList}
    Private vehicleNoLabel As New Label() With {.Text = "Vehicle Number:"}
    Private supervisor As New ComboBox() With {.DropDownStyle = ComboBoxStyle.DropDownList}
    Private supervisorLabel As New Label() With {.Text = "Supervisor:"}
    Private authorizer As New ComboBox() With {.DropDownStyle = ComboBoxStyle.DropDownList}
    Private authorizerLabel As New Label() With {.Text = "Authorized By:"}
    Private withEvents authDate As New DateTimePicker() With {.Format = DateTimePickerFormat.Custom, .CustomFormat = "MM/dd/yyyy"}
    Private authDateLabel As New Label() With {.Text = "Authorization Date:"}
    Private WithEvents SaveButton As New Button() With {.Text = "Create", .Dock = DockStyle.Top, .Margin = New Padding(0, 120, 0, 0), .Height = 40}
    Private WithEvents CancelButton As New Button() With {.Text = "Cancel", .Dock = DockStyle.Top, .Margin = New Padding(0, 120, 0, 0), .Height = 40}

    Private WithEvents materialAssignDG As New DataGridView() With {.Anchor = AnchorStyles.Left}
    Private materialTask_DGColumn As New DataGridViewComboBoxColumn() With {.HeaderText = "Task", .Name = "Task"}
    Private materialTask_Label As New Label() With {.Text = "Material Assignments:"}
    Private WithEvents laborAssignDG As New DataGridView() With {.Anchor = AnchorStyles.Left}
    Private laborTask_DGColumn As New DataGridViewComboBoxColumn() With {.HeaderText = "Task", .Name = "Task"}
    Private laborTask_Label As New Label() With {.Text = "Labor Assignments:"}

    Public Shared selectedOrder As String
    Private mainFields As Control() = {assignmentNo, workOrderNo, workLocationName, workLocationAddress, startDate, endDate, vehicleNo, supervisor, authorizer, authDate}
    Private mainLabels As Label() = {assignmentNoLabel, workOrderNoLabel, workLocationLabel, workLocationNameLabel, workLocationAddressLabel, startDateLabel, endDateLabel, vehicleNoLabel, supervisorLabel, authorizerLabel, authDateLabel}


    Public Sub New()
        Dim headerLabel As New Label() With {
            .Text = "Work Assignment Form",
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
        tableLayoutPanel.RowCount = 14
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 2))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 8))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 2))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 2))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 20))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 20))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 6))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 17))
        Me.Controls.Add(tableLayoutPanel)

        ' Configure material DataGridView
        materialAssignDG.Margin = New Padding(200, 40, 200, 10)
        tableLayoutPanel.SetColumnSpan(materialTask_Label, 5)
        tableLayoutPanel.SetColumnSpan(materialAssignDG, 5)
        materialAssignDG.Columns.Insert(0, materialTask_DGColumn)
        materialAssignDG.Columns.Add("Material", "Material")
        materialAssignDG.Columns.Add("UnitCost", "Unit Cost")
        materialAssignDG.Columns.Add("qtySent", "Quantity Sent")
        materialAssignDG.Columns.Add("qtyUsed", "Quantity Used")
        materialAssignDG.Columns(2).ReadOnly = True
        materialAssignDG.Rows.Add(3)

        ' Configure labor DataGridView
        laborAssignDG.Margin = New Padding(200, 40, 200, 10)
        tableLayoutPanel.SetColumnSpan(laborTask_Label, 5)
        tableLayoutPanel.SetColumnSpan(laborAssignDG, 5)
        laborAssignDG.Columns.Insert(0, laborTask_DGColumn)
        laborAssignDG.Columns.Add("Employee", "Employee")
        laborAssignDG.Columns.Add("Rate", "Rate")
        laborAssignDG.Columns.Add("HoursEst", "Hours Estimated")
        laborAssignDG.Columns.Add("HrsUsed", "Hours Used")
        laborAssignDG.Columns(3).ReadOnly = True
        laborAssignDG.Columns(4).ReadOnly = True
        laborAssignDG.Rows.Add(3)

        For Each control As Control In mainFields
            control.Width = 200
            control.Anchor = AnchorStyles.Left
        Next

        For Each label As Label In mainLabels
            label.Width = 200
            label.Anchor = AnchorStyles.Right
            label.TextAlign = ContentAlignment.MiddleRight
        Next

        materialAssignDG.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
        materialAssignDG.Dock = DockStyle.Fill
        laborAssignDG.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
        laborAssignDG.Dock = DockStyle.Fill

        ' Add controls to TableLayoutPanel
        tableLayoutPanel.Controls.Add(assignmentNoLabel, 0, 2)
        tableLayoutPanel.Controls.Add(assignmentNo, 1, 2)
        tableLayoutPanel.Controls.Add(workOrderNoLabel, 0, 3)
        tableLayoutPanel.Controls.Add(workOrderNo, 1, 3)
        tableLayoutPanel.Controls.Add(workLocationLabel, 0, 4)
        tableLayoutPanel.Controls.Add(workLocationNameLabel, 0, 5)
        tableLayoutPanel.Controls.Add(workLocationName, 1, 5)
        tableLayoutPanel.Controls.Add(workLocationAddressLabel, 0, 6)
        tableLayoutPanel.Controls.Add(workLocationAddress, 1, 6)
        tableLayoutPanel.Controls.Add(supervisorLabel, 0, 7)
        tableLayoutPanel.Controls.Add(supervisor, 1, 7)
        tableLayoutPanel.Controls.Add(startDateLabel, 3, 2)
        tableLayoutPanel.Controls.Add(startDate, 4, 2)
        tableLayoutPanel.Controls.Add(endDateLabel, 3, 3)
        tableLayoutPanel.Controls.Add(endDate, 4, 3)
        tableLayoutPanel.Controls.Add(vehicleNoLabel, 3, 7)
        tableLayoutPanel.Controls.Add(vehicleNo, 4, 7)
        tableLayoutPanel.Controls.Add(materialTask_Label, 0, 8)
        tableLayoutPanel.Controls.Add(materialAssignDG, 0, 9)
        tableLayoutPanel.Controls.Add(laborTask_Label, 0, 10)
        tableLayoutPanel.Controls.Add(laborAssignDG, 0, 11)
        tableLayoutPanel.Controls.Add(authorizerLabel, 0, 12)
        tableLayoutPanel.Controls.Add(authorizer, 1, 12)
        tableLayoutPanel.Controls.Add(authDateLabel, 3, 12)
        tableLayoutPanel.Controls.Add(authDate, 4, 12)
        tableLayoutPanel.Controls.Add(SaveButton, 1, 13)
        tableLayoutPanel.Controls.Add(CancelButton, 3, 13)


        AddHandler Me.Load, AddressOf WorkOrderPage_Load
        AddHandler SaveButton.Click, AddressOf SaveButton_Click
        AddHandler CancelButton.Click, AddressOf CancelButton_Click
        'AddHandler taskOrderDG.CellEndEdit, AddressOf taskOrderDG_CellEndEdit
    End Sub

    Private Sub WorkOrderPage_Load(sender As Object, e As EventArgs) Handles Me.Load
        'PopulateManagersList()
        'PopulateTasksList()

        workOrderNo.Text = selectedOrder
        Dim Assign_No As String = "A" + (DBHandler.ExecuteValueQuery("SELECT NVL(MAX(TO_NUMBER(SUBSTR(Assignment_No, 2))), 0) FROM WorkAssignments") + 1).ToString().PadLeft(5, "0"c)
        assignmentNo.Text = Assign_No
        workLocationAddress.Size = New Size(200, 35)
    End Sub

    Private Sub PopulateTasksList()
        ' Dim dataTable As DataTable = DBHandler.ExecuteTableQuery("SELECT Task_Names FROM Tasks WHERE Task_ID IN (SELECT Task_ID FROM TaskRequests WHERE Proposal_No = '" & selectedProposal & "')")

        ' ' Set the data source of the DataGridViewComboBoxColumn.
        ' TaskOrder_DGColumn.DataSource = dataTable
        ' TaskOrder_DGColumn.DisplayMember = "Task_Names"
        ' TaskOrder_DGColumn.ValueMember = "Task_Names"
    End Sub

    Private Sub PopulateManagersList()
        ' Dim dataTable As DataTable = DBHandler.ExecuteTableQuery("SELECT Emp_Name FROM Employees WHERE Emp_Role = 'Project Manager' OR Emp_Role = 'Crew Supervisor'")

        ' ' Add an empty row to the top of the DataTable.
        ' Dim row As DataRow = dataTable.NewRow()
        ' row("Emp_Name") = ""
        ' dataTable.Rows.InsertAt(row, 0)

        ' ' Set the data source of the ComboBox.
        ' manager.DataSource = dataTable
        ' manager.DisplayMember = "Emp_Name"
        ' manager.ValueMember = "Emp_Name"
    End Sub

    Private Sub materialAssignDG_CellEndEdit(sender As Object, e As DataGridViewCellEventArgs) Handles materialAssignDG.CellEndEdit
        ' Dim value As String = If(taskOrderDG.Rows(e.RowIndex).Cells(e.ColumnIndex).Value IsNot Nothing, taskOrderDG.Rows(e.RowIndex).Cells(e.ColumnIndex).Value.ToString(), 0)
        ' Dim selectedTask As String = If(taskOrderDG.Rows(e.RowIndex).Cells(0).Value IsNot Nothing, taskOrderDG.Rows(e.RowIndex).Cells(0).Value.ToString(), String.Empty)
        ' Dim maxSQFT As Integer = DBHandler.ExecuteValueQuery("SELECT Total_SQFT FROM TaskRequests WHERE Proposal_No = '" & selectedProposal & "' AND Task_ID IN (SELECT Task_ID FROM Tasks WHERE Task_Names = '" & selectedTask & "')")
    
        ' If (e.ColumnIndex = 1 Or e.ColumnIndex = 2) And Not IsNumeric(value) Then
        '     taskOrderDG.Rows(e.RowIndex).Cells(e.ColumnIndex).Value = Nothing
        ' End If
        
        ' If e.ColumnIndex = 1 Then
        '     If CInt(value) > maxSQFT Then
        '         MessageBox.Show($"Square footage exceeds maximum for this task: {maxSQFT}.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        '         taskOrderDG.Rows(e.RowIndex).Cells(1).Value = Nothing
        '     End If
        ' End If
        
        ' If e.ColumnIndex = 0 Then
        '     taskOrderDG.Rows(e.RowIndex).Cells(3).Value = "--"
        '     taskOrderDG.Rows(e.RowIndex).Cells(4).Value = "--"
        ' End If
    End Sub

    Private Sub SaveWorkAssignment()
        ' Dim orderNo As String = workOrderNo.Text
        ' Dim locationName As String = workLocationName.Text
        ' Dim locationAddress As String = workLocationAddress.Text
        ' Dim requiredDate As String = dateRequired.Value.ToString("yyyy-MM-dd")
        ' Dim orderNotes As String = If(String.IsNullOrEmpty(workOrderNotes.Text), String.Empty, workOrderNotes.Text)
        ' Dim managerID As String = DBHandler.ExecuteValueQuery($"SELECT Emp_ID FROM Employees WHERE Emp_Name = '{manager.Text}'")

        ' ' INSERT INTO WorkOrders
        ' Dim insertWorkOrderStatement As String = $"INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID) VALUES ('{orderNo}', '{selectedProposal}', '{locationName}', '{locationAddress}', TO_DATE('{requiredDate}', 'YYYY-MM-DD'), '{orderNotes}', '{managerID}')"
        ' DBHandler.ExecuteStatement(insertWorkOrderStatement)

        ' ' INSERT INTO TaskOrders
        ' For Each row As DataGridViewRow In taskOrderDG.Rows
        '     If row.Cells(0).Value IsNot Nothing AndAlso row.Cells(1).Value IsNot Nothing AndAlso row.Cells(2).Value IsNot Nothing Then
        '         Dim taskName As String = row.Cells(0).Value.ToString()
        '         Dim taskID As String = DBHandler.ExecuteValueQuery($"SELECT Task_ID FROM Tasks WHERE Task_Names = '{taskName}'")
        '         Dim sqft As Integer = row.Cells(1).Value
        '         Dim estHours As Integer = row.Cells(2).Value
        '         Dim status As String = "Pending"
        '         row.Cells(3).Value = status
        '         Dim statement As String = $"INSERT INTO TaskOrders (Order_No, Task_ID, Task_SQFT, Est_Duration, Task_Status) 
        '                                     VALUES ('{workOrderNo.Text}', '{taskID}', {sqft}, {estHours}, '{status}')"
        '         DBHandler.ExecuteStatement(statement)
        '     End If
        ' Next

        ' MessageBox.Show("Work Order created successfully.", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information)
        ' CancelButton_Click(nothing, nothing)
    End Sub

    Private Sub SaveButton_Click(sender As Object, e As EventArgs)
        'SaveWorkAssignment()
    End Sub

    Private Sub CancelButton_Click(sender As Object, e As EventArgs)
        Me.Parent.Controls.Add(New dashboard() With {.Dock = DockStyle.Fill})
        Me.Parent.Controls.Remove(Me)
    End Sub
End Class