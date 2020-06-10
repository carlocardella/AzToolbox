function Test-IsAdmin {
    <#
    .Synopsis
    Returns true if the current user is an administrator, false otherwise

    .Example
    Test-IsAdmin
    #>

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
