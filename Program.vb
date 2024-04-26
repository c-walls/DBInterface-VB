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
    
    Private proposalNo As New TextBox()
    Private proposalNoLabel As New Label() With {.Text = "Proposal Number:"}
    Private customerNo As New TextBox()
    Private customerNoLabel As New Label() With {.Text = "Customer Number:"}
    Private estimationMethod As New ComboBox()
    Private estimationMethodLabel As New Label() With {.Text = "Estimation Method:"}
    Private billingName As New TextBox() With {.ReadOnly = True}
    Private billingNameLabel As New Label() With {.Text = "Customer Name:"}
    Private billingAddress As New TextBox() With {.ReadOnly = True, .Multiline = True}
    Private billingAddressLabel As New Label() With {.Text = "Billing Address:"}
    Private locations As New TextBox()
    Private locationsLabel As New Label() With {.Text = "Locations:"}
    Private dateWritten As New TextBox()
    Private dateWrittenLabel As New Label() With {.Text = "Date Written:"}
    Private status As New ComboBox()
    Private statusLabel As New Label() With {.Text = "Proposal Status:"}
    Private decisionDate As New TextBox()
    Private decisionDateLabel As New Label() With {.Text = "Decision Date:"}
    Private button As New Button()
    Private tasksDG As New DataGridView()
    Private customerType1 As New RadioButton() With {.Text = "General Contractor"}
    Private customerType2 As New RadioButton() With {.Text = "Commercial"}
    Private customerType3 As New RadioButton() With {.Text = "Government"}
    Private customerType4 As New RadioButton() With {.Text = "Residential"}
    Private customerTypeLabel As New Label() With {.Text = "Customer Type:"}
    Private salesperson As New ComboBox()
    Private salespersonLabel As New Label() With {.Text = "Salesperson:"}


    Public Sub New()
        ' Initialize the form
        Me.Text = "Insulation Unlimited Database Interface"
        Me.Size = Screen.PrimaryScreen.Bounds.Size
        Dim screenWidth As Integer = Me.Size.Width
        Dim screenHeight As Integer = Me.Size.Height

        ' Initialize the connection
        connection = New OracleConnection(connectionString)
        connection.Open()

        ' Configure Data Controls
        proposalNoLabel.Location = New Point(50, 20)
        proposalNo.Location = New Point(proposalNoLabel.Right + 10, 20)
        Me.Controls.Add(proposalNoLabel)
        Me.Controls.Add(proposalNo)

        customerNoLabel.Location = New Point(50, 60)
        customerNo.Location = New Point(customerNoLabel.Right + 10, 60)
        Me.Controls.Add(customerNoLabel)
        Me.Controls.Add(customerNo)

        estimationMethodLabel.Location = New Point(50, 100)
        estimationMethod.Location = New Point(estimationMethodLabel.Right + 10, 100)
        estimationMethod.Items.AddRange(New String() {"Walk Through", "Floor Plan"})
        Me.Controls.Add(estimationMethodLabel)
        Me.Controls.Add(estimationMethod)

        billingNameLabel.Location = New Point(50, 140)
        billingName.Location = New Point(billingNameLabel.Right + 10, 140)
        Me.Controls.Add(billingNameLabel)
        Me.Controls.Add(billingName)

        billingAddressLabel.Location = New Point(50, 180)
        billingAddress.Location = New Point(billingAddressLabel.Right + 10, 180)
        Me.Controls.Add(billingAddressLabel)
        Me.Controls.Add(billingAddress)

        locationsLabel.Location = New Point(50, 220)
        locations.Location = New Point(locationsLabel.Right + 10, 220)
        Me.Controls.Add(locationsLabel)
        Me.Controls.Add(locations)

        customerTypeLabel.Location = New Point(50, screenHeight - 200)
        customerType1.Location = New Point(customerTypeLabel.Right + 50, screenHeight - 200)
        customerType2.Location = New Point(customerTypeLabel.Right + 50, screenHeight - 180)
        customerType3.Location = New Point(customerType1.Right + 50, screenHeight - 200)
        customerType4.Location = New Point(customerType1.Right + 50, screenHeight - 180)
        Me.Controls.Add(customerTypeLabel)
        Me.Controls.Add(customerType1)
        Me.Controls.Add(customerType2)
        Me.Controls.Add(customerType3)
        Me.Controls.Add(customerType4)

        salespersonLabel.Location = New Point(50, screenHeight - 140)
        salesperson.Location = New Point(salespersonLabel.Right + 10, screenHeight - 140)
        salesperson.Items.AddRange(New String() {"Caleb", "John", "Jane"})
        Me.Controls.Add(salespersonLabel)
        Me.Controls.Add(salesperson)

        dateWrittenLabel.Location = New Point(screenWidth - 350, 20)
        dateWritten.Location = New Point(dateWrittenLabel.Right + 10, 20)
        Me.Controls.Add(dateWrittenLabel)
        Me.Controls.Add(dateWritten)

        statusLabel.Location = New Point(screenWidth - 350, 60)
        status.Location = New Point(statusLabel.Right + 10, 60)
        status.Items.AddRange(New String() {"Pending", "Accepted", "Denied"})
        Me.Controls.Add(statusLabel)
        Me.Controls.Add(status)

        decisionDateLabel.Location = New Point(screenWidth - 350, 100)
        decisionDate.Location = New Point(decisionDateLabel.Right + 10, 100)
        Me.Controls.Add(decisionDateLabel)
        Me.Controls.Add(decisionDate)


        ' Configure button
        button.Text = "Run Query"
        button.Size = New Size(100, 50)
        button.Location = New Point(screenWidth / 2 - button.Size.Width / 2, 250)
        AddHandler button.Click, AddressOf Button_Click
        Me.Controls.Add(button)

        ' Configure DataGridView
        tasksDG.Size = New Size(screenWidth * (5/6), screenHeight / 2)
        tasksDG.Location = New Point(screenWidth / 2 - tasksDG.Size.Width / 2, 300)
        Me.Controls.Add(tasksDG)

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