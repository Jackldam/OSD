#region recover Wifi networks

(Get-ChildItem C:\test).FullName | ForEach-Object {
    $i = @(
        , "wlan"
        , "add"
        , "profile"
        , "filename=`"$_`""
        , "user=all"
    )
    
    netsh.exe @i
}

netsh.exe

#endregion