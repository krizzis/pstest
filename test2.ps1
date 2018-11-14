#Start-Process powershell -WindowStyle Hidden -Verb runAs

Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

$iisRoot = "C:\inetpub\wwwroot"
$wfwName = "2020Vision.SL"
$wfwRoot = Join-Path $iisRoot $wfwName

$appConfig = [xml](cat "C:\Users\vbel\Documents\work\settings.xml")

#Create tmp folder
$tmp = Join-Path $PSScriptRoot "\tmp"
if (!(Test-Path -Path $tmp )){
	New-Item -ItemType directory -Path $tmp
}

#Copy custom.web.config to temp folder
Copy-Item -Path $wfwRoot\custom.web.config -Destination $tmp

#Create a form
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='GUI for my PoSh script'
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true

$tTest = New-Object System.Windows.Forms.TextBox
$tTest.Location = New-Object System.Drawing.Point(380,30)
$main_form.Controls.Add($tTest)
$tTest.Text = $appConfig.Settings.test

$ButtonTest = New-Object System.Windows.Forms.Button
$ButtonTest.Location = New-Object System.Drawing.Point(380,200)
$ButtonTest.Text = "Test"
$main_form.Controls.Add($ButtonTest)

$ButtonTest.Add_Click(
{
	$appConfig.Settings.test = $tTest.Text
	$appConfig.Save("C:\Users\vbel\Documents\work\settings.xml")
}
)

$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = "From"
$Label1.Location  = New-Object System.Drawing.Point(30,30)
$Label1.AutoSize = $true
$main_form.Controls.Add($Label1)

$TextFrom = New-Object System.Windows.Forms.TextBox
$TextFrom.Location = New-Object System.Drawing.Point(80,30)
$main_form.Controls.Add($TextFrom)

$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "To"
$Label2.Location  = New-Object System.Drawing.Point(30,100)
$Label2.AutoSize = $true
$main_form.Controls.Add($Label2)

$TextTo = New-Object System.Windows.Forms.TextBox
$TextTo.Location = New-Object System.Drawing.Point(80,100)
$main_form.Controls.Add($TextTo)

$bFrom = New-Object System.Windows.Forms.Button
$bFrom.Location = New-Object System.Drawing.Point(200,30)
$bFrom.Text = "Open"
$main_form.Controls.Add($bFrom)

$bTo = New-Object System.Windows.Forms.Button
$bTo.Location = New-Object System.Drawing.Point(200,100)
$bTo.Text = "Choose folder"
$main_form.Controls.Add($bTo)

$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Point(200,200)
$Button.Text = "Unzip"
$main_form.Controls.Add($Button)

#Perform unzip of selected file to temp folder. Then try to unzip 2020Vision.SL archive
$Button.Add_Click(
{
$from = $TextFrom.Text
$to = $TextTo.Text


Try
{
	Unzip $from $tmp
	
	
	if (Test-Path $tmp\$wfwName.zip)
	{
		Unzip $tmp\$wfwName.zip $tmp
		[System.Windows.Forms.MessageBox]::Show('Done')
	}
	else 
	{
		[System.Windows.Forms.MessageBox]::Show('No app')
	}
}
Catch 
{
	[System.Windows.Forms.MessageBox]::Show('Error')	
}

}
)

$bFrom.Add_Click(
{
$openFileDialog = New-Object windows.forms.openfiledialog   
    $openFileDialog.initialDirectory = [System.IO.Directory]::GetCurrentDirectory()   
    $openFileDialog.title = "Select Deploy Package"   
    $openFileDialog.filter = "Zip Files|*.zip;*.rar"   
    $openFileDialog.ShowHelp = $True   
    $result = $openFileDialog.ShowDialog()   
    $result 
    if($result -eq "OK")    {    
            $TextFrom.Text = $OpenFileDialog.filename   
        } 
}
)

$bTo.Add_Click(
{
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
	$TextTo.Text = $folder
}
)

$main_form.Add_FormClosing(
{
	if(Test-Path -Path $tmp ){
	Remove-Item $tmp -Force -Recurse
	}
}
)

$main_form.ShowDialog()

