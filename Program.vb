Imports System
Imports System.IO
Imports System.Data
Imports System.Drawing' May not need if switching to TableLayoutPanel
Imports System.Windows.Forms
Imports Oracle.ManagedDataAccess.Client

' TO-DO:
' 1. Seperate forms into different files
' 2. Use a config file to store the connection string values
' 3. Organize Interface with the TableLayoutPanel manager (Also check for VS code designer extension)

Public Class MainForm
    Inherits Form

    Private Shared connectionString As String = File.ReadAllText("config.txt").Trim()
    Private connection As OracleConnection
    
    Private proposalNo As New TextBox() With {.Anchor = AnchorStyles.Left, .ReadOnly = True}
    Private proposalNoLabel As New Label() With {.Text = "Proposal Number:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private customerNo As New TextBox() With {.Anchor = AnchorStyles.Left}
    Private customerNoLabel As New Label() With {.Text = "Customer Number:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private estimationMethod As New ComboBox() With {.Anchor = AnchorStyles.Left}
    Private estimationMethodLabel As New Label() With {.Text = "Estimation Method:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private billingName As New TextBox() With {.ReadOnly = True, .Anchor = AnchorStyles.Left}
    Private billingNameLabel As New Label() With {.Text = "Customer Name:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private billingAddress As New TextBox() With {.ReadOnly = True, .Multiline = True, .Anchor = AnchorStyles.Left}
    Private billingAddressLabel As New Label() With {.Text = "Billing Address:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private locations As New NumericUpDown() With {.Anchor = AnchorStyles.Left, .Value = 1, .Minimum = 1, .Maximum = 20}
    Private locationsLabel As New Label() With {.Text = "Locations:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private dateWritten As New DateTimePicker() With {.Anchor = AnchorStyles.Left, .Value = DateTime.Now, .Format = DateTimePickerFormat.Short}
    Private dateWrittenLabel As New Label() With {.Text = "Date Written:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private status As New ComboBox() With {.Anchor = AnchorStyles.Left}
    Private statusLabel As New Label() With {.Text = "Proposal Status:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private decisionDate As New DateTimePicker() With {.Anchor = AnchorStyles.Left, .ShowCheckBox = True, .Checked = False, .Format = DateTimePickerFormat.Short}
    Private decisionDateLabel As New Label() With {.Text = "Decision Date:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private tasksDG As New DataGridView() With {.Anchor = AnchorStyles.Left}
    Private customerType1 As New RadioButton() With {.Text = "General Contractor", .Anchor = AnchorStyles.Left}
    Private customerType2 As New RadioButton() With {.Text = "Commercial", .Anchor = AnchorStyles.Left}
    Private customerType3 As New RadioButton() With {.Text = "Government", .Anchor = AnchorStyles.Left}
    Private customerType4 As New RadioButton() With {.Text = "Residential", .Anchor = AnchorStyles.Left}
    Private customerTypeLabel As New Label() With {.Text = "Customer Type:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}
    Private salesperson As New ComboBox() With {.Anchor = AnchorStyles.Left}
    Private salespersonLabel As New Label() With {.Text = "Salesperson:", .Anchor = AnchorStyles.Right, .TextAlign = ContentAlignment.MiddleRight}


    Public Sub New()
        ' Initialize the form
        Me.Text = "Insulation Unlimited Database Interface"
        Me.Size = Screen.PrimaryScreen.Bounds.Size
        Dim screenWidth As Integer = Me.Size.Width
        Dim screenHeight As Integer = Me.Size.Height

        ' Initialize the connection
        connection = New OracleConnection(connectionString)
        connection.Open()

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

        status.Items.AddRange(New String() {"Pending", "Accepted", "Rejected"})
        estimationMethod.Items.AddRange(New String() {"Walk Through", "Floor Plan"})
        salesperson.Items.AddRange(New String() {"John Doe", "Jane Doe"})
        tasksDG.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
        tasksDG.Dock = DockStyle.Fill

    End Sub

    Private Sub Button_Click(sender As Object, e As EventArgs)
        Using connection As New OracleConnection(connectionString)
            connection.Open()
            Dim command As New OracleCommand("SELECT * FROM Customers", connection)
            Using reader As OracleDataReader = command.ExecuteReader()
                Dim dataTable As New DataTable()
                dataTable.Load(reader)
                tasksDG.DataSource = dataTable
            End Using
        End Using
    End Sub
End Class

Module Program
    Sub Main(args As String())
        Application.EnableVisualStyles()
        Application.SetCompatibleTextRenderingDefault(False)
        Application.Run(New MainForm())
    End Sub
End Module