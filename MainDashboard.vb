Imports System
Imports System.Data
Imports System.Drawing
Imports System.Windows.Forms

Public Class Dashboard
    Inherits UserControl

    Private tableLayoutPanel As New TableLayoutPanel()
    Private dashboardDGV As New DataGridView()
    Private tabControl As New TabControl()
    Private WithEvents button1 As New Button()
    Private WithEvents button2 As New Button()

    Public Sub New()
        tableLayoutPanel.Dock = DockStyle.Fill
        tableLayoutPanel.RowCount = 3
        tableLayoutPanel.ColumnCount = 1
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 4))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 70))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 26))
        Controls.Add(tableLayoutPanel)

        ' Set up the TabControl
        tabControl.Dock = DockStyle.Fill
        tabControl.SizeMode = TabSizeMode.FillToRight
        tabControl.Appearance = TabAppearance.FlatButtons
        tabControl.Font = New Font("Sans Serif", 12, FontStyle.Bold)
        tabControl.TabPages.Add("Proposals")
        tabControl.TabPages.Add("Work Orders")
        tabControl.TabPages.Add("Work Assignments")
        tabControl.TabPages.Add("Invoices")
        tableLayoutPanel.Controls.Add(tabControl, 0, 0)

        ' Set up the DataGridView
        dashboardDGV.Dock = DockStyle.Fill
        dashboardDGV.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
        dashboardDGV.SelectionMode = DataGridViewSelectionMode.FullRowSelect
        tableLayoutPanel.Controls.Add(dashboardDGV, 0, 1)

        ' Set up the buttons
        button1.Text = "Button 1"
        button2.Text = "Button 2"
        button1.Font = New Font("Sans Serif", 10, FontStyle.Bold)
        button2.Font = New Font("Sans Serif", 10, FontStyle.Bold)
        button1.Size = New Size(300, 45)
        button2.Size = New Size(300, 45)
        button1.Margin = New Padding(25)
        button2.Margin = New Padding(25)
        Dim buttonPanel As New FlowLayoutPanel() With {
            .Dock = DockStyle.Fill,
            .FlowDirection = FlowDirection.LeftToRight,
            .AutoSizeMode = AutoSizeMode.GrowAndShrink,
            .AutoSize = True,
            .Anchor = AnchorStyles.None}
        buttonPanel.Controls.Add(button1)
        buttonPanel.Controls.Add(button2)
        tableLayoutPanel.Controls.Add(buttonPanel, 0, 2)

        AddHandler tabControl.SelectedIndexChanged, AddressOf tabControl_SelectedIndexChanged
        AddHandler button2.Click, AddressOf button2_Click
    End Sub

    Private Sub UserControl_Load(sender As Object, e As EventArgs) Handles Me.Load
        tabControl.SelectedIndex = 0
        tabControl_SelectedIndexChanged(tabControl, e)
    End Sub

    Private Sub tabControl_SelectedIndexChanged(sender As Object, e As EventArgs)
    Dim selectedTab = CType(sender, TabControl).SelectedTab
    Select Case selectedTab.Text
        Case "Proposals"
            button1.Text = "Edit Proposal"
            button2.Text = "Create New Proposal"
            dashboardDGV.DataSource = DBHandler.ExecuteTableQuery("SELECT Proposals.Proposal_No As Proposal, Cust_BillName As Customer, Location_QTY As Locations, Prop_Status As Status,
                                                                  '$ ' || SUM(taskRequests.Total_SQFT * taskRequests.Quoted_SQFTPrice) AS Total,
                                                                  Emp_Name As Salesperson, Prop_Date FROM Proposals 
                                                                  INNER JOIN Customers ON Proposals.Cust_No = Customers.Cust_No 
                                                                  INNER JOIN Employees ON Proposals.Salesperson_ID = Employees.Emp_ID 
                                                                  LEFT JOIN taskRequests ON Proposals.Proposal_No = taskRequests.Proposal_No
                                                                  GROUP BY Proposals.Proposal_No, Cust_BillName, Location_QTY, Prop_Status, Emp_Name, Prop_Date
                                                                  ORDER BY Prop_Date DESC")
        Case "Work Orders"
            button1.Text = "Edit Work Order"
            button2.Text = "Create Work Order"
            dashboardDGV.DataSource = DBHandler.ExecuteTableQuery("SELECT Cust_BillName As Customer, Proposals.Proposal_No As Proposal, Prop_Status As Status,
                                                                  CASE WHEN WorkOrders.Proposal_No IS NULL THEN 'No' ELSE 'Yes' END AS Planned,
                                                                  '$ ' || SUM(taskRequests.Total_SQFT * taskRequests.Quoted_SQFTPrice) AS Total
                                                                  FROM Customers JOIN Proposals ON Customers.Cust_No = Proposals.Cust_No 
                                                                  LEFT JOIN WorkOrders ON Proposals.Proposal_No = WorkOrders.Proposal_No 
                                                                  LEFT JOIN taskRequests ON Proposals.Proposal_No = taskRequests.Proposal_No
                                                                  WHERE Prop_Status = 'Accepted' OR Prop_Status = 'Pending'
                                                                  GROUP BY Cust_BillName, Proposals.Proposal_No, Prop_Status, WorkOrders.Proposal_No ORDER BY Prop_Status ASC")
        Case "Work Assignments"
            button1.Text = "Schedule Work"
            button2.Text = "Update Assignment"
            dashboardDGV.DataSource = DBHandler.ExecuteTableQuery("SELECT WorkOrders.Order_No, Location_Name, Location_Address, Required_Date,
                                                                    CASE WHEN WorkAssignments.Order_No IS NULL THEN 'No' ELSE 'Yes' END AS Assigned 
                                                                    FROM WorkOrders LEFT JOIN WorkAssignments ON WorkOrders.Order_No = WorkAssignments.Order_No")
        Case "Invoices"
            button1.Text = "Button 1"
            button2.Text = "Button 2"
            dashboardDGV.DataSource = DBHandler.ExecuteTableQuery("SELECT * FROM Invoices")
        End Select
    End Sub

    Private Sub button2_Click(sender As Object, e As EventArgs) Handles button2.Click
        Dim selectedTab = tabControl.SelectedTab
        If dashboardDGV.SelectedCells.Count > 0 and Me.Parent IsNot Nothing Then
            Dim rowIndex = dashboardDGV.SelectedCells(0).RowIndex
            Select Case selectedTab.Text
                Case "Proposals"
                    Me.Parent.Controls.Add(New ProposalPage() With {.Dock = DockStyle.Fill})
                    Me.Parent.Controls.Remove(Me)
                Case "Work Orders"
                    Dim workOrderForm As New WorkOrderPage() With {.Dock = DockStyle.Fill}
                    WorkOrderPage.selectedProposal = dashboardDGV.Rows(rowIndex).Cells(1).Value.ToString()
                    Me.Parent.Controls.Add(workOrderForm)
                    Me.Parent.Controls.Remove(Me)
                Case "Work Assignments"
                    Dim workAssignmentForm As New WorkAssignmentPage() With {.Dock = DockStyle.Fill}
                    WorkAssignmentPage.selectedOrder = dashboardDGV.Rows(rowIndex).Cells(0).Value.ToString()
                    Me.Parent.Controls.Add(workAssignmentForm)
                    Me.Parent.Controls.Remove(Me)
                Case "Invoices"
                    ' Perform action for "Invoices" tab
                    messagebox.Show($"Selected row index in Invoices tab: {rowIndex}")
                Case Else
                    ' Perform default action
                    messagebox.Show($"Tab Select Error")
            End Select
        End If
    End Sub
End Class