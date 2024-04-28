Imports System
Imports System.Data
Imports System.Drawing
Imports System.Windows.Forms

Public Class ProposalPage
    Inherits UserControl
    
    Private proposalNo As New TextBox() With {.ReadOnly = True}
    Private proposalNoLabel As New Label() With {.Text = "Proposal Number:"}
    Private customerNo As New TextBox() With {.ReadOnly = True}
    Private customerNoLabel As New Label() With {.Text = "Customer Number:"}
    Private estimationMethod As New ComboBox() With {.DropDownStyle = ComboBoxStyle.DropDownList}
    Private estimationMethodLabel As New Label() With {.Text = "Estimation Method:"}
    Private WithEvents billingName As New ComboBox()
    Private billingNameLabel As New Label() With {.Text = "Customer Name:"}
    Private billingAddress As New TextBox() With {.ReadOnly = True, .Multiline = True}
    Private billingAddressLabel As New Label() With {.Text = "Billing Address:"}
    Private locations As New NumericUpDown() With {.Minimum = 1, .Maximum = 20}
    Private locationsLabel As New Label() With {.Text = "Locations:"}
    Private dateWritten As New DateTimePicker() With {.Format = DateTimePickerFormat.Short}
    Private dateWrittenLabel As New Label() With {.Text = "Date Written:"}
    Private status As New ComboBox() With {.DropDownStyle = ComboBoxStyle.DropDownList}
    Private statusLabel As New Label() With {.Text = "Proposal Status:"}
    Private WithEvents decisionDate As New DateTimePicker() With {.ShowCheckBox = True, .Checked = False, .Format = DateTimePickerFormat.Short}
    Private decisionDateLabel As New Label() With {.Text = "Decision Date:"}
    Private tasksDG As New DataGridView() With {.Anchor = AnchorStyles.Left}
    Private customerType1 As New RadioButton() With {.Text = "General Contractor", .Anchor = AnchorStyles.Left, .Padding = New Padding(40, 0, 0, 0), .Width = 200}
    Private customerType2 As New RadioButton() With {.Text = "Commercial", .Anchor = AnchorStyles.Left}
    Private customerType3 As New RadioButton() With {.Text = "Government", .Anchor = AnchorStyles.Left, .Padding = New Padding(40, 0, 0, 0), .Width = 200}
    Private customerType4 As New RadioButton() With {.Text = "Residential", .Anchor = AnchorStyles.Left}
    Private customerTypeLabel As New Label() With {.Text = "Customer Type:"}
    Private salesperson As New ComboBox() With {.DropDownStyle = ComboBoxStyle.DropDownList}
    Private salespersonLabel As New Label() With {.Text = "Salesperson:"}

    Private mainFields As New List(Of Control) From {proposalNo, customerNo, estimationMethod, billingName, billingAddress, dateWritten, status, decisionDate, salesperson, locations}
    Private mainLabels As New List(Of Control) From {proposalNoLabel, customerNoLabel, estimationMethodLabel, billingNameLabel, billingAddressLabel, dateWrittenLabel, statusLabel, decisionDateLabel, customerTypeLabel, salespersonLabel, locationsLabel}
    Private cust_DataTable As New DataTable()

    Public Sub New()
        ' Create a header label
        Dim headerLabel As New Label() With {
            .Text = "Proposal Form",
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

        ' Configure Data Controls
        tableLayoutPanel.Controls.Add(proposalNoLabel, 0, 1)
        tableLayoutPanel.Controls.Add(proposalNo, 1, 1)
        tableLayoutPanel.Controls.Add(customerNoLabel, 0, 2)
        tableLayoutPanel.Controls.Add(customerNo, 1, 2)
        tableLayoutPanel.Controls.Add(estimationMethodLabel, 0, 3)
        tableLayoutPanel.Controls.Add(estimationMethod, 1, 3)
        tableLayoutPanel.Controls.Add(billingNameLabel, 0, 4)
        tableLayoutPanel.Controls.Add(billingName, 1, 4)
        tableLayoutPanel.Controls.Add(billingAddressLabel, 0, 5)
        tableLayoutPanel.Controls.Add(billingAddress, 1, 5)
        tableLayoutPanel.Controls.Add(locationsLabel, 0, 6)
        tableLayoutPanel.Controls.Add(locations, 1, 6)
        tableLayoutPanel.Controls.Add(customerTypeLabel, 0, 8)
        tableLayoutPanel.Controls.Add(customerType1, 1, 8)
        tableLayoutPanel.Controls.Add(customerType2, 2, 8)
        tableLayoutPanel.Controls.Add(customerType3, 1, 9)
        tableLayoutPanel.Controls.Add(customerType4, 2, 9)
        tableLayoutPanel.Controls.Add(salespersonLabel, 0, 10)
        tableLayoutPanel.Controls.Add(salesperson, 1, 10)
        tableLayoutPanel.Controls.Add(dateWrittenLabel, 3, 1)
        tableLayoutPanel.Controls.Add(dateWritten, 4, 1)
        tableLayoutPanel.Controls.Add(statusLabel, 3, 2)
        tableLayoutPanel.Controls.Add(status, 4, 2)
        tableLayoutPanel.Controls.Add(decisionDateLabel, 3, 3)
        tableLayoutPanel.Controls.Add(decisionDate, 4, 3)

        ' Configure DataGridView
        tasksDG.Margin = New Padding(100, 0, 75, 0)
        tableLayoutPanel.SetColumnSpan(tasksDG, 5)
        tableLayoutPanel.Controls.Add(tasksDG, 0, 7)

        ' Format main controls
        For Each control As Control In mainFields
            control.Width = 200
            control.Anchor = AnchorStyles.Left
        Next

        For Each label As Label In mainLabels
            label.Width = 200
            label.Anchor = AnchorStyles.Right
            label.TextAlign = ContentAlignment.MiddleRight
        Next

        status.Items.AddRange(New String() {" Pending", " Accepted", " Rejected"})
        status.Enabled = decisionDate.Checked
        estimationMethod.Items.AddRange(New String() {" Walk Through", " Floor Plan"})
        tasksDG.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
        tasksDG.Dock = DockStyle.Fill
        
        ' Event Handlers
        AddHandler Me.Load, AddressOf UserControl_Load
        AddHandler billingName.SelectionChangeCommitted, AddressOf billingName_SelectionChangeCommitted
        AddHandler decisionDate.ValueChanged, AddressOf decisionDate_ValueChanged
    End Sub

    Private Sub UserControl_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        PopulateCustomerList()
        PopulateSalespersonList()
        salesperson.SelectedItem = ""
        Status.SelectedIndex = 0
        locations.Value = 1
        DateWritten.Value = DateTime.Now
        BillingName.Select()
    End Sub

    Private Sub PopulateCustomerList()
        cust_DataTable = DBHandler.ExecuteQuery("SELECT Cust_BillName FROM Customers")
        
        ' Insert an empty row at the beginning of the cust_DataTable.
        Dim row As DataRow = cust_DataTable.NewRow()
        row("Cust_BillName") = ""
        cust_DataTable.Rows.InsertAt(row, 0)
        
        billingName.DataSource = cust_DataTable
        billingName.DisplayMember = "Cust_BillName"
        billingName.ValueMember = "Cust_BillName"
        billingName.AutoCompleteMode = AutoCompleteMode.SuggestAppend
        billingName.AutoCompleteSource = AutoCompleteSource.ListItems
    End Sub

    Private Sub PopulateSalespersonList()
        Dim dataTable As DataTable = DBHandler.ExecuteQuery("SELECT Emp_Name FROM Employees WHERE Emp_Role = 'Salesperson'")
        
        ' Insert an empty row at the beginning of the DataTable.
        Dim row As DataRow = dataTable.NewRow()
        row("Emp_Name") = ""
        dataTable.Rows.InsertAt(row, 0)
        
        salesperson.DataSource = dataTable
        salesperson.DisplayMember = "Emp_Name"
        salesperson.ValueMember = "Emp_Name"
    End Sub

    Private Sub billingName_SelectionChangeCommitted(sender As Object, e As EventArgs) Handles billingName.SelectionChangeCommitted
        ' Query the database to get the corresponding address and set it to the address field.
        Dim selectedBillingName As String = billingName.SelectedValue.ToString()
        Dim dataTable As DataTable = DBHandler.ExecuteQuery("SELECT Cust_BillAddress FROM Customers WHERE Cust_BillName = '" & selectedBillingName & "'")
        billingAddress.Text = If(dataTable.Rows.Count = 1, dataTable.Rows(0)("Cust_BillAddress").ToString(), "")
        
        ' Removes highlighting from text after field update
        Me.BeginInvoke(New Action(Sub() billingName.SelectionLength = 0))
    End Sub

    Private Sub decisionDate_ValueChanged(sender As Object, e As EventArgs) Handles decisionDate.ValueChanged
        ' Allow status change when decision date is set
        status.Enabled = decisionDate.Checked

        ' Validate decision date
        If decisionDate.Value.Date < DateWritten.Value.Date OrElse decisionDate.Value.Date > DateTime.Now.Date Then
            MessageBox.Show("Decision date invalid." & vbCrLf & vbCrLf & "Choose a date between the creation date and today.", "Invalid Date", MessageBoxButtons.OK, MessageBoxIcon.Error)
            decisionDate.Value = DateTime.Now.Date
        End If
    End Sub

End Class