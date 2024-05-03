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
    Private workLocationLabel As New Label() With {.Text = "Work Location:", .Font = New Font(Control.DefaultFont, FontStyle.Bold)}
    Private workLocationName As New TextBox()
    Private workLocationNameLabel As New Label() With {.Text = "Name:"}
    Private workLocationAddress As New TextBox() With {.Multiline = True}
    Private workLocationAddressLabel As New Label() With {.Text = "Address:"}
    Private workOrderDate As New DateTimePicker() With {.Format = DateTimePickerFormat.Custom, .CustomFormat = "MM/dd/yyyy"}
    Private workOrderDateLabel As New Label() With {.Text = "Date:"}
    Private workOrderNotes As New TextBox() With {.Multiline = True}
    Private workOrderNotesLabel As New Label() With {.Text = "Notes:"}
    Private manager As New ComboBox() With {.DropDownStyle = ComboBoxStyle.DropDownList}
    Private managerLabel As New Label() With {.Text = "Manager:"}
    Private withEvents dateRequired As New DateTimePicker() With {.Format = DateTimePickerFormat.Custom}
    Private dateRequiredLabel As New Label() With {.Text = "Date Required:"}
    Private WithEvents SaveButton As New Button() With {.Text = "Save", .Dock = DockStyle.Top, .Margin = New Padding(0, 120, 0, 0), .Height = 40}
    Private WithEvents CancelButton As New Button() With {.Text = "Cancel", .Dock = DockStyle.Top, .Margin = New Padding(0, 120, 0, 0), .Height = 40}

    Private WithEvents taskOrderDG As New DataGridView() With {.Anchor = AnchorStyles.Left}
    Private taskOrder_DGColumn As New DataGridViewComboBoxColumn() With {.HeaderText = "Task", .Name = "Task"}
    Private taskStatus_DGColumn As New DataGridViewComboBoxColumn() With {.HeaderText = "Status", .Name = "Status"}

    Public Property selectedProposal As String
    Public Property generatedWorkOrder As String
    Public Property selectedWorkOrder As String
    Private mainFields As Control() = {workOrderNo, proposalNo, workLocationName, workLocationAddress, workOrderDate, workOrderNotes, manager, dateRequired}
    Private mainLabels As Label() = {workOrderNoLabel, proposalNoLabel, workLocationLabel, workLocationNameLabel, workLocationAddressLabel, workOrderDateLabel, workOrderNotesLabel, managerLabel, dateRequiredLabel}
    Private originalValues As New Dictionary(Of String, String)

    Public Sub New(ByVal selectedProposal As String, ByVal generatedWorkOrder As String, ByVal selectedWorkOrder As String)
        Me.selectedProposal = selectedProposal
        Me.generatedWorkOrder = generatedWorkOrder
        Me.selectedWorkOrder = selectedWorkOrder

        Dim headerLabel As New Label() With {
            .Dock = DockStyle.Top,
            .Font = New Font("Arial", 24, FontStyle.Bold),
            .TextAlign = ContentAlignment.MiddleCenter,
            .Height = 50}
        Me.Controls.Add(headerLabel)

        If String.IsNullOrEmpty(selectedWorkOrder) Then
            Try
                If generatedWorkOrder.EndsWith("01") Then
                    headerLabel.Text = "Primary Work Order"
                Else
                    headerLabel.Text = "Secondary Work Order"
                End If
            Catch ex As Exception
                MessageBox.Show("Error: " & ex.Message & vbCrLf & "generatedWorkOrder: " & generatedWorkOrder, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
            End Try
        Else If selectedWorkOrder.EndsWith("01") Then
            headerLabel.Text = "Primary Work Order"
        Else
            headerLabel.Text = "Secondary Work Order"
        End If

        ' Configure TableLayoutPanel
        Dim tableLayoutPanel As New TableLayoutPanel()
        tableLayoutPanel.Dock = DockStyle.Fill
        tableLayoutPanel.ColumnCount = 5
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 25))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 18))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 14))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 18))
        tableLayoutPanel.ColumnStyles.Add(New ColumnStyle(SizeType.Percent, 25))
        tableLayoutPanel.RowCount = 11
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 2))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 8))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 2))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 2))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 8))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 30))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 5))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 27))
        Me.Controls.Add(tableLayoutPanel)

        ' Configure DataGridView
        taskStatus_DGColumn.DataSource = New List(Of String) From {"Pending", "In Process", "Completed"}
        taskOrderDG.Margin = New Padding(200, 40, 200, 10)
        tableLayoutPanel.SetColumnSpan(taskOrderDG, 5)
        tableLayoutPanel.Controls.Add(taskOrderDG, 0, 7)
        taskOrderDG.Columns.Insert(0, taskOrder_DGColumn)
        taskOrderDG.Columns.Add("SquareFeet", "Square Feet")
        taskOrderDG.Columns.Add("EstHours", "Estimated Hours")
        If String.IsNullOrEmpty(selectedWorkOrder) Then
            taskOrderDG.Columns.Add("Status", "Status")
        Else
            taskOrderDG.Columns.Insert(3, taskStatus_DGColumn)
        End If
        taskOrderDG.Columns.Add("DateComplete", "Date Complete")
        taskOrderDG.Columns(4).ReadOnly = True

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
        tableLayoutPanel.Controls.Add(workOrderNotesLabel, 3, 6)
        tableLayoutPanel.Controls.Add(workOrderNotes, 4, 6)
        tableLayoutPanel.Controls.Add(managerLabel, 0, 8)
        tableLayoutPanel.Controls.Add(manager, 1, 8)
        tableLayoutPanel.Controls.Add(dateRequiredLabel, 3, 8)
        tableLayoutPanel.Controls.Add(dateRequired, 4, 8)
        tableLayoutPanel.Controls.Add(SaveButton, 1, 10)
        tableLayoutPanel.Controls.Add(CancelButton, 3, 10)

        If String.IsNullOrEmpty(selectedWorkOrder) Then
            proposalNo.Text = selectedProposal
            workOrderNo.Text = generatedWorkOrder
            taskOrderDG.Columns(3).ReadOnly = True
            taskOrderDG.Rows.Add(3)
            dateRequired.CustomFormat = " "
        Else
            workOrderNo.Text = selectedWorkOrder
            Dim workOrderData As DataTable = DBHandler.ExecuteTableQuery("SELECT * FROM WorkOrders WHERE Order_No = '" & selectedWorkOrder & "'")
            Dim taskOrderData As DataTable = DBHandler.ExecuteTableQuery("SELECT TaskOrders.Task_ID, Task_Names, Task_SQFT, Est_Duration, Task_Status, Date_Complete FROM TaskOrders JOIN Tasks ON TaskOrders.Task_ID = Tasks.Task_ID WHERE Order_No = '" & selectedWorkOrder & "'")

            If workOrderData.Rows.Count > 0 and taskOrderData.Rows.Count > 0 Then
                originalValues.Add("Proposal_No", workOrderData.Rows(0)("Proposal_No").ToString())
                originalValues.Add("Location_Name", workOrderData.Rows(0)("Location_Name").ToString())
                originalValues.Add("Location_Address", workOrderData.Rows(0)("Location_Address").ToString())
                originalValues.Add("Required_Date", workOrderData.Rows(0)("Required_Date").ToString())
                originalValues.Add("Order_Notes", workOrderData.Rows(0)("Order_Notes").ToString())
                originalValues.Add("Manager_ID", workOrderData.Rows(0)("Manager_ID").ToString())

                proposalNo.Text = originalValues("Proposal_No")
                workLocationName.Text = originalValues("Location_Name")
                workLocationAddress.Text = originalValues("Location_Address")
                workOrderDate.Value = DateTime.Parse(originalValues("Required_Date"))
                workOrderNotes.Text = originalValues("Order_Notes")

                For Each row As DataRow In taskOrderData.Rows
                    Dim taskIndex As Integer = taskOrderDG.Rows.Add()
                    Dim dataTable As DataTable = DBHandler.ExecuteTableQuery("SELECT Task_Names FROM Tasks WHERE Task_ID IN (SELECT Task_ID FROM TaskRequests WHERE Proposal_No = '" & originalValues("Proposal_No") & "')")

                    ' Set the data source of the DataGridViewComboBoxColumn.
                    TaskOrder_DGColumn.DataSource = dataTable
                    TaskOrder_DGColumn.DisplayMember = "Task_Names"
                    TaskOrder_DGColumn.ValueMember = "Task_Names"
                          
                    taskOrderDG.Rows(taskIndex).Cells("Task").Value = row("Task_Names").ToString()
                    taskOrderDG.Rows(taskIndex).Cells("SquareFeet").Value = row("Task_SQFT").ToString()
                    taskOrderDG.Rows(taskIndex).Cells("EstHours").Value = row("Est_Duration").ToString()
                    taskOrderDG.Rows(taskIndex).Cells("Status").Value = row("Task_Status").ToString()
                    taskOrderDG.Rows(taskIndex).Cells("DateComplete").Value = row("Date_Complete").ToString()
                    taskOrderDG_CellEndEdit(taskOrderDG, New DataGridViewCellEventArgs(0, taskIndex))
                Next
            End If
        End If

        AddHandler Me.Load, AddressOf WorkOrderPage_Load
        AddHandler dateRequired.ValueChanged, AddressOf dateRequired_ValueChanged
        AddHandler SaveButton.Click, AddressOf SaveButton_Click
        AddHandler CancelButton.Click, AddressOf CancelButton_Click
        AddHandler taskOrderDG.CellEndEdit, AddressOf taskOrderDG_CellEndEdit
    End Sub

    Private Sub WorkOrderPage_Load(sender As Object, e As EventArgs) Handles Me.Load
        PopulateManagersList()

        If Not String.IsNullOrEmpty(selectedWorkOrder) Then
            manager.SelectedValue = DBHandler.ExecuteValueQuery("SELECT Emp_Name FROM Employees WHERE Emp_ID = '" & originalValues("Manager_ID") & "'")
            taskOrderDG.Columns(0).ReadOnly = True
            dateRequired.CustomFormat = "MM/dd/yyyy"
        Else
            PopulateTasksList()
        End If

        workLocationAddress.Size = New Size(200, 35)
        workOrderNotes.Size = New Size(200, 35)
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

    Private Sub dateRequired_ValueChanged(sender As Object, e As EventArgs) Handles dateRequired.ValueChanged
        dateRequired.CustomFormat = "MM/dd/yyyy"
    End Sub

    Private Sub taskOrderDG_CellEndEdit(sender As Object, e As DataGridViewCellEventArgs) Handles taskOrderDG.CellEndEdit
        Dim value As String = If(taskOrderDG.Rows(e.RowIndex).Cells(e.ColumnIndex).Value IsNot Nothing, taskOrderDG.Rows(e.RowIndex).Cells(e.ColumnIndex).Value.ToString(), 0)

        If (e.ColumnIndex = 1 Or e.ColumnIndex = 2) And Not IsNumeric(value) Then
            taskOrderDG.Rows(e.RowIndex).Cells(e.ColumnIndex).Value = Nothing
        End If
        
        If String.IsNullOrEmpty(selectedWorkOrder) Then
            Dim selectedTask As String = If(taskOrderDG.Rows(e.RowIndex).Cells(0).Value IsNot Nothing, taskOrderDG.Rows(e.RowIndex).Cells(0).Value.ToString(), String.Empty)
            Dim maxSQFT As Integer = DBHandler.ExecuteValueQuery("SELECT Total_SQFT FROM TaskRequests WHERE Proposal_No = '" & selectedProposal & "' AND Task_ID IN (SELECT Task_ID FROM Tasks WHERE Task_Names = '" & selectedTask & "')")
            
            If e.ColumnIndex = 1 Then
                If CInt(value) > maxSQFT Then
                    MessageBox.Show($"Square footage exceeds maximum for this task: {maxSQFT}.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
                    taskOrderDG.Rows(e.RowIndex).Cells(1).Value = Nothing
                End If
            End If
            
            If e.ColumnIndex = 0 Then
                taskOrderDG.Rows(e.RowIndex).Cells(3).Value = "--"
                taskOrderDG.Rows(e.RowIndex).Cells(4).Value = "--"
            End If
        End If

        If e.ColumnIndex = 3 And taskOrderDG.Rows(e.RowIndex).Cells(e.ColumnIndex).Value.ToString() = "Completed" Then
            taskOrderDG.Rows(e.RowIndex).Cells(4).Value = DateTime.Now.ToString("MM/dd/yyyy")
        End If
    End Sub

    Private Sub SaveWorkOrder()
        Dim orderNo As String = workOrderNo.Text
        Dim locationName As String = workLocationName.Text
        Dim locationAddress As String = workLocationAddress.Text
        Dim requiredDate As String = dateRequired.Value.ToString("yyyy-MM-dd")
        Dim orderNotes As String = If(String.IsNullOrEmpty(workOrderNotes.Text), String.Empty, workOrderNotes.Text)
        Dim managerID As String = DBHandler.ExecuteValueQuery($"SELECT Emp_ID FROM Employees WHERE Emp_Name = '{manager.Text}'")

        ' INSERT INTO WorkOrders
        Dim insertWorkOrderStatement As String = $"INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID) VALUES ('{orderNo}', '{selectedProposal}', '{locationName}', '{locationAddress}', TO_DATE('{requiredDate}', 'YYYY-MM-DD'), '{orderNotes}', '{managerID}')"
        DBHandler.ExecuteStatement(insertWorkOrderStatement)

        ' INSERT INTO TaskOrders
        For Each row As DataGridViewRow In taskOrderDG.Rows
            If row.Cells(0).Value IsNot Nothing AndAlso row.Cells(1).Value IsNot Nothing AndAlso row.Cells(2).Value IsNot Nothing Then
                Dim taskName As String = row.Cells(0).Value.ToString()
                Dim taskID As String = DBHandler.ExecuteValueQuery($"SELECT Task_ID FROM Tasks WHERE Task_Names = '{taskName}'")
                Dim sqft As Integer = row.Cells(1).Value
                Dim estHours As Integer = row.Cells(2).Value
                Dim status As String = "Pending"
                row.Cells(3).Value = status
                Dim statement As String = $"INSERT INTO TaskOrders (Order_No, Task_ID, Task_SQFT, Est_Duration, Task_Status) 
                                            VALUES ('{workOrderNo.Text}', '{taskID}', {sqft}, {estHours}, '{status}')"
                DBHandler.ExecuteStatement(statement)
            End If
        Next

        MessageBox.Show("Work Order created successfully.", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information)
        CancelButton_Click(nothing, nothing)
    End Sub



    Private Sub SaveButton_Click(sender As Object, e As EventArgs)
        If String.IsNullOrEmpty(selectedWorkOrder) Then
            SaveWorkOrder()
        Else
            messagebox.show("Update functionality not yet implemented.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End If
    End Sub

    Private Sub CancelButton_Click(sender As Object, e As EventArgs)
        Me.Parent.Controls.Add(New dashboard() With {.Dock = DockStyle.Fill})
        Me.Parent.Controls.Remove(Me)
    End Sub
End Class