# [Connect to SQL Server Using Application Intent Read-Only](https://blogs.msdn.microsoft.com/alwaysonpro/2013/08/02/connect-to-sql-server-using-application-intent-read-only/)
```
Public Class Form1
    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        'Use SQLClient and ApplicationIntent
        Dim SQLClientConn As New SqlClient.SqlConnection("data source=TestAG2Listener;integrated security=sspi;initial catalog=TSQL2012;applicationintent=readonly")
        SQLClientConn.Open()
        Dim objCmd As SqlClient.SqlCommand = New SqlClient.SqlCommand("select @@servername", SQLClientConn)
        MsgBox(objCmd.ExecuteScalar())
        SQLClientConn.Close()
    End Sub

    Private Sub Button2_Click(sender As Object, e As EventArgs) Handles Button2.Click
        'Use SNAC ODBC And ApplicationIntent
        Dim SNACODBCConn As New Odbc.OdbcConnection("Driver={SQL Server Native Client 11.0};server=TestAG2Listener;database=TSQL2012;trusted_connection=yes;applicationintent=readonly")
        SNACODBCConn.Open()
        Dim objCmd As Odbc.OdbcCommand = New Odbc.OdbcCommand("select @@servername", SNACODBCConn)
        MsgBox(objCmd.ExecuteScalar())
        SNACODBCConn.Close()
    End Sub

    Private Sub Button3_Click(sender As Object, e As EventArgs) Handles Button3.Click
        'Use SNAC SQL OLE DB And ApplicationIntent
        Dim SNACOLEDBConn As New OleDb.OleDbConnection
        SNACOLEDBConn.ConnectionString = "Provider=sqlncli11;data source=TestAG2Listener;integrated security=sspi;initial catalog=TSQL2012;application intent=readonly"
        SNACOLEDBConn.Open()
        Dim objCmd As OleDb.OleDbCommand = New OleDb.OleDbCommand("select @@servername", SNACOLEDBConn)
        MsgBox(objCmd.ExecuteScalar())
        SNACOLEDBConn.Close()
    End Sub
End Class

```