<# 

.DESCRIPTION 
 Create a toast notification based on supplied parameters. 

#> 
Param(
    [Parameter(Mandatory=$true)]    
    [string]$ConfigJson
)

# Load Assemblies
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

# Set Location as Local Path
$MyPath = (Get-Location).Path

# Build Configuration File Path
[io.fileinfo]$ConfigurationFile = Join-Path $MyPath -ChildPath $ConfigJson

if($ConfigurationFile.Exists){
    if($ConfigurationFile.Extension -eq ".json"){
        $Configurations = try{
            # Get configurations
            Get-Content $ConfigurationFile | ConvertFrom-Json -ErrorAction Stop
        } catch {
            "Unable to get json."
        }
    } else {
        "File not json."
    }
} else {
    "File not found."
}
# Change Hero Image file to full path.
$Configurations.Visual.HeroImage = Join-Path $MyPath -ChildPath $Configurations.Visual.HeroImage


#Build XML Template
[xml]$ToastTemplate = @"
<toast scenario="$($Configurations.Scenario)">
    <visual>
        <binding template="$($Configurations.Visual.BindingTemplate)">
            <text id="1">$($Configurations.Visual.Title)</text>
            <text id="2">$($Configurations.Visual.Text[0])</text>
            <text id="2">$($Configurations.Visual.Text[1])</text>
            <text placement="$($Configurations.Visual.Placement)">$($Configurations.Visual.Attribution)</text>
            <image id="1" src="$($Configurations.Visual.HeroImage)" />
        </binding>
    </visual>
    <actions>
        <action arguments="$($Configurations.Actions[0].Arguments)" content="$($Configurations.Actions[0].Content)" activationType="$($Configurations.Actions[0].ActivationType)" />
        <action arguments="$($Configurations.Actions[1].Arguments)" content="$($Configurations.Actions[1].Content)" activationType="$($Configurations.Actions[1].ActivationType)"/>
    </actions>
</toast>
"@
 
#Prepare XML
$ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::New()
$ToastXml.LoadXml($ToastTemplate.OuterXml)
 
#Prepare and Create Toast
$ToastMessage = [Windows.UI.Notifications.ToastNotification]::New($ToastXML)

# Invoke Toast notification
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($Configurations.LauncherID).Show($ToastMessage)
