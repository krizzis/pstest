$cn2 = new-object system.data.SqlClient.SQLConnection("Password=q;Persist Security Info=True;User ID=flow;Initial Catalog=LondonLocal;Data Source=(local)\sqlexpress");

$com = Get-Content "./test.sql"
$com2 = "delete from dbo.AppGenders where DescrDL = 'thing'"

$cmd = new-object system.data.sqlclient.sqlcommand($com2, $cn2);
$cn2.Open();
$cmd.ExecuteNonQuery()

$cn2.Close();