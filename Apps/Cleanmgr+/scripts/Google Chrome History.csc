[Info]
Title=Google Chrome History
Description=Clean-up Google Chrome History (Cookies, Site-specific preferences, Saved form and Session data, Autocomplete history)
Author=Builtbybel
AuthorURL=http://www.builtbybel.com

[Files]
Task=TaskKill|chrome.exe|WARNING
File1=DeleteFile|%LocalAppData%\Google\Chrome\User Data\Default\History*
File2=DeleteFile|%LocalAppData%\Google\Chrome\User Data\Default\Archived History 
File3=DeleteFile|%LocalAppData%\Google\Chrome\User Data\Default\Visited Links 
File4=DeleteFile|%LocalAppData%\Google\Chrome\User Data\Default\Cookies 
File5=DeleteFile|%LocalAppData%\Google\Chrome\User Data\Default\Web Data 
File6=DeleteFile|%LocalAppData%\Google\Chrome\User Data\Default\Current Session 
File7=DeleteFile|%LocalAppData%\Google\Chrome\User Data\Default\Last Session 







