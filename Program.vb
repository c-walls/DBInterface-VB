Imports System
Imports System.Drawing' May not need if switching to TableLayoutPanel
Imports System.Windows.Forms
Imports Oracle.ManagedDataAccess.Client

' TO-DO:
' 1. Seperate forms into different files
' 2. Make the dummy call using the button and display it
' 3. Use a config file to store the connection string values
' 4. Organize Interface with the TableLayoutPanel manager (Also check for VS code designer extension)

Public Class MainForm
    Inherits Form

    Private Shared connectionString As String = "User Id=ADMIN;Password=StRoNg_password123;Data Source=ovyv9ufieozhf2yr_medium;TNS_ADMIN=C:\\Users\\caleb\\OneDrive\\Documents\\Coding Projects\\Database\\Wallet_OVYV9UFIEOZHF2YR;Pooling=true;"
    Private connection As OracleConnection

    Public Sub New()
        ' Initialize the form
        Me.Text = "Database Interface"
        Me.Size = Screen.PrimaryScreen.Bounds.Size
        Dim screenWidth As Integer = Me.Size.Width
        Dim screenHeight As Integer = Me.Size.Height

        ' Initialize the connection
        connection = New OracleConnection(connectionString)
        connection.Open()

        ' Create a button
        Dim button As New Button()
        button.Text = "Run Query"
        button.Size = New Size(100, 50)
        button.Location = New Point(screenWidth / 2 - button.Size.Width / 2, screenHeight / 2 - button.Size.Height / 2)

        ' Add button with event handler
        AddHandler button.Click, AddressOf Button_Click
        Me.Controls.Add(button)
    End Sub

    Private Sub Button_Click(sender As Object, e As EventArgs)
        Using connection As New OracleConnection(connectionString)
            connection.Open()
            Dim command As New OracleCommand("SELECT * FROM DUAL", connection)
            Using reader As OracleDataReader = command.ExecuteReader()
                While reader.Read()
                    Console.WriteLine(String.Format("{0}", reader(0)))
                End While
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