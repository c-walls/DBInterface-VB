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
    Private WithEvents button3 As New Button()

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
        tabControl.TabPages.Add("Invoices")
        tableLayoutPanel.Controls.Add(tabControl, 0, 0)

        ' Set up the DataGridView
        dashboardDGV.Dock = DockStyle.Fill
        dashboardDGV.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
        dashboardDGV.SelectionMode = DataGridViewSelectionMode.FullRowSelect
        tableLayoutPanel.Controls.Add(dashboardDGV, 0, 1)

        ' Set up the buttons
        Dim buttons As New List(Of Button) From {button1, button2, button3}

        For Each btn As Button In buttons
            ' Set the Text, Font, Size, and Margin properties
            btn.Text = btn.Name
            btn.Font = New Font("Sans Serif", 10, FontStyle.Bold)
            btn.Size = New Size(250, 40)
            btn.Margin = New Padding(25)
        Next

        Dim buttonPanel As New FlowLayoutPanel() With {
            .Dock = DockStyle.Fill,
            .FlowDirection = FlowDirection.LeftToRight,
            .AutoSizeMode = AutoSizeMode.GrowAndShrink,
            .AutoSize = True,
            .Anchor = AnchorStyles.None}
        buttonPanel.Controls.Add(button1)
        buttonPanel.Controls.Add(button2)
        buttonPanel.Controls.Add(button3)
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
            button1.Text = "Create Proposal"
            button2.Text = "Edit Proposal"
            button3.Text = "Create Work Order"
            dashboardDGV.DataSource = DBHandler.ExecuteTableQuery("SELECT Proposals.Proposal_No As Proposal, Cust_BillName As Customer, Location_QTY, 
                                                                  '$ ' || SUM(taskRequests.Total_SQFT * taskRequests.Quoted_SQFTPrice) AS Total, 
                                                                  Prop_Date As Created, Emp_Name As Salesperson, Prop_Status As Status,
                                                                  CASE WHEN Prop_Status = 'Accepted' THEN (CASE WHEN WorkOrders.Proposal_No IS NULL THEN 'No' ELSE 'Yes' END) ELSE '-' END AS Planned
                                                                  FROM Customers JOIN Proposals ON Customers.Cust_No = Proposals.Cust_No 
                                                                  INNER JOIN Employees ON Proposals.Salesperson_ID = Employees.Emp_ID 
                                                                  LEFT JOIN WorkOrders ON Proposals.Proposal_No = WorkOrders.Proposal_No 
                                                                  LEFT JOIN taskRequests ON Proposals.Proposal_No = taskRequests.Proposal_No
                                                                  WHERE Prop_Status = 'Accepted' OR Prop_Status = 'Pending'
                                                                  GROUP BY Proposals.Proposal_No, Cust_BillName, Location_QTY, Prop_Date, Emp_Name, Prop_Status, WorkOrders.Proposal_No 
                                                                  ORDER BY CASE WHEN Planned = 'No' THEN 1 WHEN Planned = 'Yes' THEN 2 ELSE 3 END, Prop_Date DESC")
        Case "Work Orders"
            button1.Text = "Update Work Order"
            button2.Text = "Schedule Work Assignment"
            button3.Text = "Update Work Assignment"
            dashboardDGV.DataSource = DBHandler.ExecuteTableQuery("SELECT WorkOrders.Order_No, Location_Name As Location, Location_Address As Address, Required_Date As Deadline,
                                                        LastAssignments.Assignment_No As Last_Assignment,
                                                        CASE WHEN LastAssignments.Assignment_No IS NOT NULL AND LastAssignments.Finish_Date IS NULL THEN 'In progress'
                                                            WHEN LastAssignments.Assignment_No IS NULL AND LastAssignments.Finish_Date IS NULL THEN ''
                                                            ELSE 'Closed - ' || TO_CHAR(LastAssignments.Finish_Date, 'MM/DD/YYYY') END As Assignment_Status
                                                        FROM WorkOrders 
                                                        LEFT JOIN (SELECT Order_No, Assignment_No, Finish_Date, ROW_NUMBER() OVER (PARTITION BY Order_No ORDER BY Assignment_No DESC) AS rn
                                                                 FROM WorkAssignments) LastAssignments ON WorkOrders.Order_No = LastAssignments.Order_No AND LastAssignments.rn = 1
                                                        WHERE WorkOrders.Order_No IN (SELECT Order_No FROM TaskOrders WHERE Date_Complete IS NULL)")

        Case "Invoices"
            button1.Text = "Prepare Invoice"
            button2.Text = "Edit Invoice"
            button3.Text = "Print Invoice"
            dashboardDGV.DataSource = DBHandler.ExecuteTableQuery("SELECT * FROM Invoices")
        End Select
    End Sub

    Private Sub button1_Click(sender As Object, e As EventArgs) Handles button1.Click
        Dim selectedTab = tabControl.SelectedTab
        If dashboardDGV.SelectedCells.Count > 0 Then
            Dim rowIndex = dashboardDGV.SelectedCells(0).RowIndex
            Select Case selectedTab.Text
                Case "Proposals" ' -- CREATE PROPOSAL --
                    Me.Parent.Controls.Add(New ProposalPage() With {.Dock = DockStyle.Fill})
                    Me.Parent.Controls.Remove(Me)
                Case "Work Orders" ' -- UPDATE WORK ORDER --

                Case "Invoices" ' -- PREPARE INVOICE --

                Case Else
                    MessageBox.Show($"Tab Select Error")
            End Select
        End If
    End Sub

    Private Sub button2_Click(sender As Object, e As EventArgs) Handles button2.Click
        Dim selectedTab = tabControl.SelectedTab
        If dashboardDGV.SelectedCells.Count > 0 and Me.Parent IsNot Nothing Then
            Dim rowIndex = dashboardDGV.SelectedCells(0).RowIndex
            Select Case selectedTab.Text
                Case "Proposals" ' -- EDIT PROPOSAL --
                    
                Case "Work Orders" ' -- SCHEDULE WORK ASSIGNMENT --
                    Dim workAssignmentForm As New WorkAssignmentPage() With {.Dock = DockStyle.Fill}
                    WorkAssignmentPage.selectedOrder = dashboardDGV.Rows(rowIndex).Cells(0).Value.ToString()
                    Me.Parent.Controls.Add(workAssignmentForm)
                    Me.Parent.Controls.Remove(Me)
                Case "Invoices" ' -- EDIT INVOICE --

                Case Else
                    messagebox.Show($"Tab Select Error")
            End Select
        End If
    End Sub

    Private Sub button3_Click(sender As Object, e As EventArgs) Handles button3.Click
        Dim selectedTab = tabControl.SelectedTab
        If dashboardDGV.SelectedCells.Count > 0 Then
            Dim rowIndex = dashboardDGV.SelectedCells(0).RowIndex
            Select Case selectedTab.Text
                Case "Proposals" ' -- CREATE WORK ORDER --
                    Dim selectedProposal = dashboardDGV.Rows(rowIndex).Cells(0).Value.ToString()
                    Dim locationQTY = dashboardDGV.Rows(rowIndex).Cells(2).Value.ToString()
                    WorkOrderPage.selectedProposal = selectedProposal

                    ' Create a new page instance for each location
                    For i As Integer = 1 To locationQTY
                        Dim generatedWorkOrder = "W" & selectedProposal.Substring(2, 4) & "-" & i.ToString("D2")
                        Dim workOrderControl As New WorkOrderPage(generatedWorkOrder) With {.Dock = DockStyle.Fill}
                        Me.Parent.Controls.Add(workOrderControl)
                    Next

                    Me.Parent.Controls.Remove(Me)

                Case "Work Orders" ' -- UPDATE WORK ASSIGNMENT --

                Case "Invoices" ' -- PRINT INVOICE --

                Case Else
                    MessageBox.Show($"Tab Select Error")
            End Select
        End If
    End Sub
End Class