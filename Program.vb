Imports System
Imports System.IO
Imports System.Data
Imports System.Windows.Forms
Imports Oracle.ManagedDataAccess.Client

' TO-DO:
' 1. Proposal Form --> Fix styling of table's 3rd column
' 2. Proposal Form --> Add buttons (combined save / update & Close?Cancel?Confirm?)
' 3. Proposal Form --> Setup INSERT statements
' 4. Database --> Add new INSERT statements and auto-increments / triggers as needed
' 5. Create Homepage / Menu
' 6. Finish Work Order Form
' 7. Create Work Assignment Form
' 8. Create Invoice Form
' 9. Update Styling and Test (Themes?)

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
    Private Shared connectionString As String = "User Id=ADMIN;Password=StRoNg_password123;Data Source=ovyv9ufieozhf2yr_medium;TNS_ADMIN=C:\\Users\\caleb\\OneDrive\\Documents\\Coding Projects\\Database\\Wallet_OVYV9UFIEOZHF2YR;Pooling=true;"

    Public Shared Function ExecuteQuery(query As String) As DataTable
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
End Class

Module Program
    Sub Main(args As String())
        Application.EnableVisualStyles()
        Application.SetCompatibleTextRenderingDefault(False)
        Application.Run(New MainForm())
    End Sub
End Module