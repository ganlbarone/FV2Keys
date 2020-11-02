# FV2Keys
Gets file vault 2 keys via powershell.
All you need to do is call the function with the machines ID from JAMF.

Before attempting to use the function you must ensure your account you are using has the proper permissions. In JAMF you would need to go to management settings \ system settings \ jamf pro user accounts and groups \ select or create an account \ go to privileges tab \ jamf pro server actions then 'View Disk Encryption Recovery Key' put a check in the box here and you are all set to use the below.
So for example:

$key = CasperFVault "9794"

Will return the file vault key back into the $key varriable. 
