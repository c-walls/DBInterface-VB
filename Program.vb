Imports System
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

    Private Shared connectionString As String = "User Id=ADMIN;Password=StRoNg_password123;Data Source=ovyv9ufieozhf2yr_medium;TNS_ADMIN=C:\\Users\\caleb\\OneDrive\\Documents\\Coding Projects\\Database\\Wallet_OVYV9UFIEOZHF2YR;Pooling=true;"
    Private connection As OracleConnection
    Private button As New Button()
    Private dataViewer As New DataGridView()
    Private proposalNo As New TextBox()
    Private customerNo As New TextBox()

    Public Sub New()
        ' Initialize the form
        Me.Text = "Database Interface"
        Me.Size = Screen.PrimaryScreen.Bounds.Size
        Dim screenWidth As Integer = Me.Size.Width
        Dim screenHeight As Integer = Me.Size.Height

        ' Initialize the connection
        connection = New OracleConnection(connectionString)
        connection.Open()

        ' Configure textboxes
        proposalNo.Location = New Point(10,10)
        Me.Controls.Add(proposalNo)

        customerNo.Location = New Point(10, 50)
        Me.Controls.Add(customerNo)

        ' Configure button
        button.Text = "Run Query"
        button.Size = New Size(100, 50)
        button.Location = New Point(screenWidth / 2 - button.Size.Width / 2, 100)
        AddHandler button.Click, AddressOf Button_Click
        Me.Controls.Add(button)

        ' Configure DataGridView
        dataViewer.Size = New Size(screenWidth * (5/6), screenHeight / 2)
        dataViewer.Location = New Point(screenWidth / 2 - dataViewer.Size.Width / 2, 250)
        Me.Controls.Add(dataViewer)

    End Sub

    Private Sub Button_Click(sender As Object, e As EventArgs)
        Using connection As New OracleConnection(connectionString)
            connection.Open()
            Dim command As New OracleCommand("SELECT * FROM DUAL", connection)
            Using reader As OracleDataReader = command.ExecuteReader()
                Dim dataTable As New DataTable()
                dataTable.Load(reader)
                dataViewer.DataSource = dataTable
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