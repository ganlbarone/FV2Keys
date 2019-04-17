# FV2Keys
Gets file vault 2 keys via powershell.
All you need to do is call the function with the machines ID from JAMF.
So for example:

$key = CasperFVault "9794"

Will return the file vault key back into the $key varriable. 
