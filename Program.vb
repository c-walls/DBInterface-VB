Imports System
Imports System.IO
Imports System.Data
Imports System.Windows.Forms
Imports Oracle.ManagedDataAccess.Client

' TO-DO:
' 1. Create Homepage / Menu --> DGV with tab control and two changing buttons
' 2. Finish Work Order Form
' 3. Create Work Assignment Form
' 4. Create Invoice Form
' 5. Update Styling and Test (Themes?)
' 6. Proposal Form --> Add Column before customer name with gap and label (Also "New Customer Toggle")
' 7. Proposal Form --> Add Confirmation message and/or clear form after submission (Also add commit SQL statement)

Public Class MainForm
    Inherits Form
    Dim screenWidth As Integer = Me.Size.Width
    Dim screenHeight As Integer = Me.Size.Height
    Private Dashboard As New Dashboard() With {.Dock = DockStyle.Fill}
    Private ProposalPage As New ProposalPage() With {.Dock = DockStyle.Fill}
    Private WorkOrderPage As New WorkOrderPage() With {.Dock = DockStyle.Fill}
    ' Private WorkAssignmentPage As New WorkAssignmentPage() With {.Dock = DockStyle.Fill}
    ' Private InvoicePage As New InvoicePage() With {.Dock = DockStyle.Fill}
    Private Panel As New Panel() With {.Dock = DockStyle.Fill}

    Public Sub New()
        Me.Text = "Insulation Unlimited Database Interface"
        Me.Size = Screen.PrimaryScreen.Bounds.Size
        Controls.Add(Panel)
        Panel.Controls.Add(Dashboard)
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