Imports System
Imports System.Data
Imports System.Drawing
Imports System.Windows.Forms

Public Class InvoicePage
    Inherits UserControl
    
    Private invoiceNo As New TextBox() With {.ReadOnly = True}
    Private invoiceNoLabel As New Label() With {.Text = "Invoice Number:"}
    Private invoiceDate As New DateTimePicker() With {.Format = DateTimePickerFormat.Custom,  .CustomFormat = "MM/dd/yyyy"}
    Private invoiceDateLabel As New Label() With {.Text = "Date:"}
    Private ProposalNo As New TextBox() With {.ReadOnly = True}
    Private ProposalNoLabel As New Label() With {.Text = "Proposal Number:"}
    Private startDate As New DateTimePicker() With {.Format = DateTimePickerFormat.Custom, .CustomFormat = "MM/dd/yyyy"}
    Private startDateLabel As New Label() With {.Text = "Start Date:"}
    Private endDate As New DateTimePicker() With {.Format = DateTimePickerFormat.Custom, .CustomFormat = "MM/dd/yyyy"}
    Private endDateLabel As New Label() With {.Text = "End Date:"}
    
    Private WithEvents invoiceDG As New DataGridView() With {.Anchor = AnchorStyles.Left}
    Private subTotalLabel As New Label() With {.Text = "Total Before Tax:", .Font = New Font(Control.DefaultFont, FontStyle.Bold)}
    Private calc_subTotal As New Label() With {.Text = "$0.00", .Font = New Font(Control.DefaultFont, FontStyle.Bold)}
    Private taxLabel As New Label() With {.Text = "Tax (8.2%):", .Font = New Font(Control.DefaultFont, FontStyle.Bold)}
    Private calc_tax As New Label() With {.Text = "$0.00", .Font = New Font(Control.DefaultFont, FontStyle.Bold)}
    Private totalLabel As New Label() With {.Text = "Total:", .Font = New Font(Control.DefaultFont, FontStyle.Bold)}
    Private calc_total As New Label() With {.Text = "$0.00", .Font = New Font(Control.DefaultFont, FontStyle.Bold)}

    Private WithEvents saveButton As New Button() With {.Text = "Save", .Dock = DockStyle.Top, .Margin = New Padding(0, 80, 0, 0), .Height = 40}
    Private WithEvents cancelButton As New Button() With {.Text = "Cancel", .Dock = DockStyle.Top, .Margin = New Padding(0, 80, 0, 0), .Height = 40}

    Private mainFields As New List(Of Control) From {invoiceNo, invoiceDate, proposalNo, startDate, endDate}
    Private mainLabels As New List(Of Control) From {invoiceNoLabel, invoiceDateLabel, proposalNoLabel, startDateLabel, endDateLabel}
    Private calculatedFields As New List(Of Control) From {calc_subTotal, calc_tax, calc_total}
    Private calculatedLabels As New List(Of Control) From {subTotalLabel, taxLabel, totalLabel}
    
    'Private cust_DataTable As New DataTable()
    Private originalValues As New Dictionary(Of String, Object)
    Public Property existingInvoice As String

    Public Sub New(ByVal existingInvoice As String)
        Me.existingInvoice = existingInvoice

        ' Create a header label
        Dim headerLabel As New Label() With {
            .Text = "Invoice",
            .Dock = DockStyle.Top,
            .Font = New Font("Arial", 24, FontStyle.Bold),
            .TextAlign = ContentAlignment.MiddleCenter,
            .Height = 70}
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
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 3))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 4))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 42))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 4))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 4))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 4))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 4))
        tableLayoutPanel.RowStyles.Add(New RowStyle(SizeType.Percent, 20))
        Me.Controls.Add(tableLayoutPanel)

        ' Configure Data Controls
        tableLayoutPanel.Controls.Add(invoiceNoLabel, 0, 2)
        tableLayoutPanel.Controls.Add(invoiceNo, 1, 2)
        tableLayoutPanel.Controls.Add(invoiceDateLabel, 3, 2)
        tableLayoutPanel.Controls.Add(invoiceDate, 4, 2)
        tableLayoutPanel.Controls.Add(proposalNoLabel, 0, 3)
        tableLayoutPanel.Controls.Add(proposalNo, 1, 3)
        tableLayoutPanel.Controls.Add(startDateLabel, 0, 4)
        tableLayoutPanel.Controls.Add(startDate, 1, 4)
        tableLayoutPanel.Controls.Add(endDateLabel, 3, 4)
        tableLayoutPanel.Controls.Add(endDate, 4, 4)

        tableLayoutPanel.Controls.Add(subTotalLabel, 1, 8)
        tableLayoutPanel.Controls.Add(calc_subTotal, 3, 8)
        tableLayoutPanel.Controls.Add(taxLabel, 1, 9)
        tableLayoutPanel.Controls.Add(calc_tax, 3, 9)
        tableLayoutPanel.Controls.Add(totalLabel, 1, 10)
        tableLayoutPanel.Controls.Add(calc_total, 3, 10)

        tableLayoutPanel.Controls.Add(saveButton, 1, 11)
        tableLayoutPanel.Controls.Add(cancelButton, 3, 11)

        ' Configure DataGridView
        invoiceDG.Margin = New Padding(200, 40, 200, 10)
        tableLayoutPanel.SetColumnSpan(invoiceDG, 5)
        tableLayoutPanel.Controls.Add(invoiceDG, 0, 6)
        invoiceDG.Columns.Add("Task", "Task")
        invoiceDG.Columns.Add("Location", "Location")
        invoiceDG.Columns.Add("Amount", "Amount")
        invoiceDG.Columns.Add("DateCompleted", "Date Completed")
        invoiceDG.Columns(2).DefaultCellStyle.Format = "C2"
        invoiceDG.Columns(0).ReadOnly = True
        invoiceDG.Columns(1).ReadOnly = True
        invoiceDG.Columns(3).ReadOnly = True
        invoiceDG.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
        InvoiceDG.Dock = DockStyle.Fill


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

        For Each control As Control In calculatedFields
            control.Width = 200
            control.Anchor = AnchorStyles.None
            control.AutoSize = True
        Next

        For Each label As Label In calculatedLabels
            label.Width = 200
            label.Anchor = AnchorStyles.None
            label.AutoSize = True
        Next

        If Not String.IsNullOrEmpty(existingInvoice) Then
            invoiceNo.Text = existingInvoice
            proposalNo.Text = DBHandler.ExecuteValueQuery($"SELECT Proposal_No FROM Invoices WHERE Invoice_No = '{existingInvoice}'")
        
            Dim taskData As DataTable = DBHandler.ExecuteTableQuery($"SELECT Tasks.Task_Name, WorkOrders.Location_Name, TaskOrders.Date_Complete " &
                                                                    "FROM TaskOrders " &
                                                                    "INNER JOIN Tasks ON TaskOrders.Task_ID = Tasks.Task_ID " &
                                                                    "INNER JOIN WorkOrders ON TaskOrders.Order_No = WorkOrders.Order_No " &
                                                                    "WHERE TaskOrders.Invoice_No = '{existingInvoice}'")
        
            ' Bind the DataTable to the DataGridView
            invoiceDG.DataSource = taskData
        
            ' Bind the columns to the appropriate fields
            invoiceDG.Columns(0).DataPropertyName = "Task_Name"
            invoiceDG.Columns(1).DataPropertyName = "Location_Name"
            invoiceDG.Columns(3).DataPropertyName = "Date_Complete"
        End If
    End Sub

    ' Private Sub UserControl_Load(sender As Object, e As EventArgs) Handles Me.Load
    '     If Not String.IsNullOrEmpty(existingInvoice) Then
    '         ' invoiceNo.Text = originalValues("InvoiceNo")
    '         ' invoiceDate.Value = originalValues("InvoiceDate")
    '         ' proposalNo.Text = originalValues("ProposalNo")
    '     End If
    'End Sub

    Private Sub SaveButton_Click(sender As Object, e As EventArgs) Handles saveButton.Click
        MessageBox.Show("Invoice has been updated successfully!")
    End Sub

    Private Sub CancelButton_Click(sender As Object, e As EventArgs) Handles cancelButton.Click
        Me.Parent.Controls.Add(New dashboard() With {.Dock = DockStyle.Fill})
        Me.Parent.Controls.Remove(Me)
    End Sub
End Class