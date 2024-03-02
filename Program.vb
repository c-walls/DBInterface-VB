Imports System
Imports Oracle.ManagedDataAccess.Client

Module Program
    Sub Main(args As String())
        Dim connectionString As String = "User Id=ADMIN;Password=StRoNg_password123;Data Source=ovyv9ufieozhf2yr_medium;TNS_ADMIN=C:\\Users\\caleb\\OneDrive\\Documents\\Coding Projects\\Database\\Wallet_OVYV9UFIEOZHF2YR;Pooling=false;"
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
End Module