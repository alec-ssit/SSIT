#region Functions
function Sync-SharepointLocation {
    param (
        [guid]$siteId,
        [guid]$webId,
        [guid]$listId,
        [mailaddress]$userEmail,
        [string]$webUrl,
        [string]$webTitle,
        [string]$listTitle,
        [string]$syncPath,
        [string]$regPath,
        [string]$tenantTitle
    )
    try {
         Add-Type -AssemblyName System.Web
        #Encode site, web, list, url & email
        [string]$siteId = [System.Web.HttpUtility]::UrlEncode($siteId)
        [string]$webId = [System.Web.HttpUtility]::UrlEncode($webId)
        [string]$listId = [System.Web.HttpUtility]::UrlEncode($listId)
        [string]$userEmail = [System.Web.HttpUtility]::UrlEncode($userEmail)
        [string]$webUrl = [System.Web.HttpUtility]::UrlEncode($webUrl)
        #build the URI
        $uri = New-Object System.UriBuilder
        $uri.Scheme = "odopen"
        $uri.Host = "sync"
        $uri.Query = "siteId=$siteId&webId=$webId&listId=$listId&userEmail=$userEmail&webUrl=$webUrl&listTitle=$listTitle&webTitle=$webTitle"
        #launch the process from URI
        Write-Host $uri.ToString()
        start-process -filepath $($uri.ToString())
    }
    catch {
        $errorMsg = $_.Exception.Message
    }
    if ($errorMsg) {
        Write-Warning "Sync failed."
        Write-Warning $errorMsg
        exit
    }
    else {
        Write-Host "Sync completed."
        return $true
        exit 0
    }    
    }
#endregion
#region Main Process
try {
    #region Sharepoint Sync
    #Modify the siteID, webID, and listID via a F12 Network Capture of the Sync button on Chrome or Edge
    #Modify the webURL with a link to the root of the Sharepoint site
    #Modify the Tenant Title to the title of the Office 365 tenant (can review synch path for top level Sharepoint sync folder name)
    #Modify the webTitle for the title of the Sharepoint site and the list Title for the title of the folder set being synched (likely Documents)
    [mailaddress]$userUpn = cmd /c "whoami/upn"
    [string]$userName= cmd /c "whoami"
    $params = @{
        #replace with data captured from your sharepoint site.
        siteId    = "{00000000-0000-0000-0000-000000000000}"
        webId     = "{00000000-0000-0000-0000-000000000000}"
        listId    = "{00000000-0000-0000-0000-000000000000}"
        webUrl    = "https://example.sharepoint.com/sites/SiteNameHere"
        tenantTitle = "Manually enter the Tenant Name Here"
        webTitle  = "Site Name from F12 grab"        
        listTitle = "Liste Title from F12 grab"
        userEmail = $userUpn
        UserName = $UserName.TrimStart("azuread\")
    }
    $params.syncPath  = "C:\Users\$($params.userName)\$($params.tenantTitle)\$($params.webTitle) - $($Params.listTitle)"
    $params.regPath = "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1\Tenants\$($params.tenantTitle)"
    Write-Host "SharePoint params:"
    $params | Format-Table
    if (!(Get-ItemProperty $($params.regPath) -Name $($params.syncPath))) {
        Write-Host "Sharepoint folder not found locally, will now sync.." -ForegroundColor Yellow
        $sp = Sync-SharepointLocation @params
        if (!($sp)) {
            Throw "Sharepoint sync failed."
        }
    }
    else {
        Write-Host "Location already syncronized: $($params.syncPath)" -ForegroundColor Yellow
        exit 0
    }
    #endregion
}
catch {
    $errorMsg = $_.Exception.Message
    }
finally {
    if ($errorMsg) {
        Write-Warning $errorMsg
        Throw $errorMsg
        exit
    }
    else {
        Write-Host "Completed successfully.."
        exit 0
    }
}
#endregion