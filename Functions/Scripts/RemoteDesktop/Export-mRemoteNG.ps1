Function Export-mRemoteNg {
    Param(
        [string]$NodeName ="",
        [string]$NodeType = "Connection",
        [string]$ProjectName = "General",
        [string]$Domain = "",
        [string]$Description ="",
        [string]$IpAddress = "",
        [string]$Password = "",
        [string]$ParentId = "e8982aa3-890f-48d1-a664-022097d27ec4",
        [string]$NodeId = "",
        [string]$Icon = "Windows"
    )

    $Properties = @{
        Name = $NodeName
        Id = $NodeId
        Parent = $ParentId
        NodeType = $NodeType # connection or Container
        Description = $Description
        Icon = $Icon
        Panel= $ProjectName
        Username = $UserName
        Password = $Password
        Domain = $Domain
        Hostname = $IpAddress
        Protocol = "RDP"
        PuttySession = "Default Settings"
        Port = "3389"
        ConnectToConsole = "FALSE"
        UseCredSsp = "TRUE"
        RenderingEngine = "IE"
        ICAEncryptionStrength = "EncrBasic"
        RDPAuthenticationLevel = "NoAuth"
        LoadBalanceInfo = ""
        Colors = "Colors32Bit"
        Resolution = "FitToWindows"
        AutomaticResize = "TRUE"
        DisplayWallpaper = "TRUE"
        DisplayThemes = "TRUE"
        EnableFontSmoothing = "TRUE"
        EnableDesktopComposition = "TRUE"
        CacheBitmaps = "TRUE"
        RedirectDiskDrives = "FALSE"
        RedirectPorts = "FALSE"
        RedirectPrinters ="FALSE"
        RedirectSmartCards = "FALSE"
        RedirectSound = "FALSE"
        RedirectKeys = "FALSE"
        PreExtApp = ""
        PostExtApp = ""
        MacAddress = ""
        UserField = ""
        ExtApp = ""
        VNCCompression = "CompNone"
        VNCEncoding = "EncHextile"
        VNCAuthMode = "AuthVNC"
        VNCProxyType = "ProxyNone"
        VNCProxyIP = ""
        VNCProxyPort = "0"
        VNCProxyUsername = ""
        VNCProxyPassword = ""
        VNCColors = "ColNormal"
        VNCSmartSizeMode = "SmartSAspect"
        VNCViewOnly = "False"
        RDGatewayUsageMethod = "Never"
        RDGatewayHostname = ""
        RDGatewayUseConnectionCredentials=  "Yes"
        RDGatewayUsername = ""
        RDGatewayPassword = ""
        RDGatewayDomain = ""
        InheritCacheBitmaps = "FALSE"
        InheritColors = "FALSE"
        InheritDescription = "FALSE"
        InheritDisplayThemes = "FALSE"
        InheritDisplayWallpaper = "FALSE"
        InheritEnableFontSmoothing = "FALSE"
        InheritEnableDesktopComposition ="FALSE"
        InheritDomain = "FALSE"
        InheritIcon = "FALSE"
        InheritPanel = "FALSE"
        InheritPassword = "TRUE"
        InheritPort = "FALSE"
        InheritProtocol = "FALSE"
        InheritPuttySession = "FALSE"
        InheritRedirectDiskDrives = "FALSE"
        InheritRedirectKeys = "FALSE"
        InheritRedirectPorts = "FALSE"
        InheritRedirectPrinters = "FALSE"
        InheritRedirectSmartCards = "FALSE"
        InheritRedirectSound = "FALSE"
        InheritResolution = "FALSE"
        InheritAutomaticResize = "FALSE"
        InheritUseConsoleSession = "FALSE"
        InheritUseCredSsp = "FALSE"
        InheritRenderingEngine = "FALSE"
        InheritUsername = "FALSE"
        InheritICAEncryptionStrength = "FALSE"
        InheritRDPAuthenticationLevel = "FALSE"
        InheritLoadBalanceInfo = "FALSE"
        InheritPreExtApp = "FALSE"
        InheritPostExtApp = "FALSE"
        InheritMacAddress = "FALSE"
        InheritUserField = "FALSE"
        InheritExtApp = "FALSE"
        InheritVNCCompression = "FALSE"
        InheritVNCEncoding = "FALSE"
        InheritVNCAuthMode = "FALSE"
        InheritVNCProxyType = "FALSE"
        InheritVNCProxyIP = "FALSE"
        InheritVNCProxyPort = "FALSE"
        InheritVNCProxyUsername = "FALSE"
        InheritVNCProxyPassword = "FALSE"
        InheritVNCColors = "FALSE"
        InheritVNCSmartSizeMode = "FALSE"
        InheritVNCViewOnly = "FALSE"
        InheritRDGatewayUsageMethod = "FALSE"
        InheritRDGatewayHostname = "FALSE"
        InheritRDGatewayUseConnectionCredentials = "FALSE"
        InheritRDGatewayUsername = "FALSE"
        InheritRDGatewayPassword = "FALSE"
        InheritRDGatewayDomain = "FALSE"
        InheritRDPAlertIdleTimeout = "FALSE"
        InheritRDPMinutesToIdleTimeout = "FALSE"
        InheritSoundQuality = "FALSE"
    }

    return (New-Object psobject -Property $Properties)
}