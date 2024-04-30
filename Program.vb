Imports System
Imports System.IO
Imports System.Data
Imports System.Windows.Forms
Imports Oracle.ManagedDataAccess.Client

' TO-DO:
' 1. Proposal Form --> Add Column before customer name with gap and label (Also "New Customer Toggle")
' 2. Proposal Form --> Fix other INSERT statements
' 3. Database --> Add new INSERT statements and auto-increments / triggers as needed
' 4. Create Homepage / Menu
' 5. Finish Work Order Form
' 6. Create Work Assignment Form
' 7. Create Invoice Form
' 8. Update Styling and Test (Themes?)

Public Class MainForm
    Inherits Form
    Dim screenWidth As Integer = Me.Size.Width
    Dim screenHeight As Integer = Me.Size.Height
    Private ProposalPage As New ProposalPage() With {.Dock = DockStyle.Fill}
    Private Panel As New Panel() With {.Dock = DockStyle.Fill}

    Public Sub New()
        Me.Text = "Insulation Unlimited Database Interface"
        Me.Size = Screen.PrimaryScreen.Bounds.Size
        Controls.Add(Panel)
        Panel.Controls.Add(ProposalPage)
    End Sub
End Class

Public Class DBHandler
    Private Shared connectionString As String = System.IO.File.ReadAllText("config.txt")
    
    Public Shared Function ExecuteTableQuery(query As String) As DataTable
        Dim dataTable As New DataTable()
        Try
            Using connection As New OracleConnection(connectionString)
                connection.Open()
                Using command As New OracleCommand(query, connection)
                    Using reader As OracleDataReader = command.ExecuteReader()
                        dataTable.Load(reader)
                    End Using
                End Using
            End Using
        Catch ex As OracleException
            MessageBox.Show($"Database error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        Catch ex As Exception
            MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End Try
        Return dataTable
    End Function

    Public Shared Function ExecuteValueQuery(query As String) As Object
        Dim result As Object = Nothing
        Try
            Using connection As New OracleConnection(connectionString)
                connection.Open()
                Using command As New OracleCommand(query, connection)
                    result = command.ExecuteScalar()
                End Using
            End Using
        Catch ex As OracleException
            MessageBox.Show($"Database error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        Catch ex As Exception
            MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End Try
        Return result
    End Function

    Public Shared Function ExecuteStatement (statement As String) As Integer
        Dim rowsAffected As Integer = 0
        Try
            Using connection As New OracleConnection(connectionString)
                connection.Open()
                Using command As New OracleCommand(statement, connection)
                    rowsAffected = command.ExecuteNonQuery()
                End Using
            End Using
        Catch ex As OracleException
            MessageBox.Show($"Database error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        Catch ex As Exception
            MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End Try
        Return rowsAffected
    End Function
End Class

Module Program
    Sub Main(args As String())
        Application.EnableVisualStyles()
        Application.SetCompatibleTextRenderingDefault(False)
        Application.Run(New MainForm())
    End Sub
End Module