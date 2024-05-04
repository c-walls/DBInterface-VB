Imports System
Imports System.Data
Imports System.Drawing
Imports System.Windows.Forms
Imports System.Drawing.Printing

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
    
    Private originalValues As New Dictionary(Of String, Object)
    Public Property existingInvoice As String
    Public Property printInvoice As Boolean

    Public Sub New(ByVal existingInvoice As String, Optional ByVal printInvoice As Boolean = False)
        Me.existingInvoice = existingInvoice
        Me.printInvoice = printInvoice

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
        
            Dim taskData As DataTable = DBHandler.ExecuteTableQuery($"SELECT Tasks.Task_Names, WorkOrders.Location_Name, TaskOrders.Billed_Amount, TaskOrders.Date_Complete
                                                                        FROM TaskOrders
                                                                        INNER JOIN Tasks ON TaskOrders.Task_ID = Tasks.Task_ID
                                                                        INNER JOIN WorkOrders ON TaskOrders.Order_No = WorkOrders.Order_No
                                                                        WHERE TaskOrders.Invoice_No = '{existingInvoice}'")
        
            ' ' Bind the DataTable to the DataGridView
            invoiceDG.AutoGenerateColumns = False
            invoiceDG.DataSource = taskData
        
            ' Bind the columns to the appropriate fields
            invoiceDG.Columns("Task").DataPropertyName = "Task_Names"
            invoiceDG.Columns("Location").DataPropertyName = "Location_Name"
            invoiceDG.Columns("DateCompleted").DataPropertyName = "Date_Complete"

            If printInvoice Then
                InvoiceDG.Columns("Amount").DataPropertyName = "Billed_Amount"
            End If

            startDate.Value = CType(taskData.Compute("MIN(Date_Complete)", ""), DateTime)
            endDate.Value = CType(taskData.Compute("MAX(Date_Complete)", ""), DateTime)

            AddHandler Me.Load, AddressOf UserControl_Load
            AddHandler invoiceDG.CellEndEdit, AddressOf invoiceDG_CellEndEdit
        End If
    End Sub

    Private Sub invoiceDG_CellEndEdit(sender As Object, e As DataGridViewCellEventArgs)
        If e.ColumnIndex = 1 Or e.ColumnIndex = 2 Then
            Dim row = invoiceDG.Rows(e.RowIndex)
            Dim value1 As Integer

            ' if column 2 is not an integer, clear the cell
            If e.ColumnIndex = 2 AndAlso row.Cells(e.ColumnIndex).Value IsNot Nothing AndAlso Not Integer.TryParse(row.Cells(e.ColumnIndex).Value.ToString(), value1) Then
                row.Cells(e.ColumnIndex).Value = Nothing
            End If
    
            CalculateTotals()
        End If
    End Sub

    Private Sub CalculateTotals()
        Dim subtotal As Decimal = invoiceDG.Rows.Cast(Of DataGridViewRow)().
            Where(Function(r) Not r.IsNewRow AndAlso r.Cells(2).Value IsNot Nothing).
            Sum(Function(r) Convert.ToDecimal(r.Cells(2).Value))
        calc_subTotal.Text = subtotal.ToString("C2")
        calc_Tax.Text = (subtotal * 0.082).ToString("C2")
        calc_total.Text = (subtotal * 1.082).ToString("C2")
    End Sub

    Private Sub Save_Invoice_Amounts()
        ' Save the amounts for individual tasks
        For Each row As DataGridViewRow In invoiceDG.Rows
            Dim amount As Decimal = Convert.ToDecimal(row.Cells("Amount").Value)
        
            ' Get the Task_Name and Date_Complete from the row
            Dim taskName As String = Convert.ToString(row.Cells("Task").Value)
            Dim date1 As DateTime = Convert.ToDateTime(row.Cells("DateCompleted").Value)
            Dim taskID As String = DBHandler.ExecuteValueQuery($"SELECT Task_ID FROM Tasks WHERE Task_Names = '{taskName}'")
            
            ' Format the date correctly for the SQL query
            Dim dateComplete = date1.ToString("yyyy-MM-dd")
        
            ' UPDATE TaskOrders
            Dim updateQuery As String = $"UPDATE TaskOrders SET Billed_Amount = {amount} WHERE Invoice_No = '{existingInvoice}' AND Task_ID = '{taskID}' AND Date_Complete = TO_DATE('{dateComplete}', 'YYYY-MM-DD')"
            DBHandler.ExecuteStatement(updateQuery)
        Next
    
        ' Get the Invoice_Date from the form and format it correctly for the SQL query
        Dim invoice_Date = invoiceDate.Value.ToString("yyyy-MM-dd")
    
        ' UPDATE the TOTAL Invoice Amount and Invoice_Date in the Invoices table
        Dim totalAmount As Decimal = Convert.ToDecimal(calc_total.Text.Substring(1))
        DBHandler.ExecuteStatement($"UPDATE Invoices SET Invoice_Total = {totalAmount}, Invoice_Date = TO_DATE('{invoice_Date}', 'YYYY-MM-DD') WHERE Invoice_No = '{existingInvoice}'")
    End Sub

    Private Sub SaveButton_Click(sender As Object, e As EventArgs) Handles saveButton.Click
        Try
            Save_Invoice_Amounts()
            MessageBox.Show("Invoice saved successfully.", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information)
            CancelButton_Click(nothing, nothing)
        Catch ex As Exception
            MessageBox.Show($"An error occurred while saving the invoice amounts: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End Try
    End Sub

    Private Sub CancelButton_Click(sender As Object, e As EventArgs) Handles cancelButton.Click
        Me.Parent.Controls.Add(New dashboard() With {.Dock = DockStyle.Fill})
        Me.Parent.Controls.Remove(Me)
    End Sub
    
    Private Sub UserControl_Load(sender As Object, e As EventArgs) Handles Me.Load
        Static hasLoaded As Boolean = False
        CalculateTotals()
    
        If printInvoice AndAlso Not hasLoaded Then
            Dim printDoc As New PrintDocument()
            printDoc.DefaultPageSettings.Landscape = True ' Set to landscape mode
            AddHandler printDoc.PrintPage, AddressOf PrintDoc_PrintPage
    
            ' Create a new PrintPreviewDialog using the PrintDocument.
            Dim ppd As New PrintPreviewDialog With {
                .Document = printDoc,
                .WindowState = FormWindowState.Maximized
            }
    
            ' Delay the ShowDialog method until after the form has fully loaded.
            Me.BeginInvoke(New Action(Sub() ppd.ShowDialog()))
    
            hasLoaded = True
        End If
    End Sub
    
    Private Sub PrintDoc_PrintPage(sender As Object, e As PrintPageEventArgs)
        Dim bmp As New Bitmap(Me.Width, Me.Height)
        Me.DrawToBitmap(bmp, New Rectangle(0, 0, Me.Width, Me.Height))
    
        ' Scale down to 75%
        e.Graphics.ScaleTransform(0.60F, 0.60F)
    
        ' Calculate the center points of the page and the image
        Dim pageCenterX As Single = e.PageBounds.Width / 2
        Dim pageCenterY As Single = e.PageBounds.Height / 2
        Dim imageCenterX As Single = bmp.Width * 0.60F / 2
        Dim imageCenterY As Single = bmp.Height * 0.60F / 2
    
        ' Adjust the image's position to center it on the page
        Dim startX As Single = pageCenterX - imageCenterX
        Dim startY As Single = pageCenterY - imageCenterY
    
        e.Graphics.DrawImage(bmp, startX, startY)
    End Sub
End Class