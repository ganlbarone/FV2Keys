Function CasperFVault($id){
    try{
        $user = "ENTER USER NAME HERE"
        $pass= "ENTER PASSWORD HERE"
        $serverAddress = "https://somedomain.com:8443" #must be in format https://servername:port

        $data = @{"username"="$user";"password"="$pass";"resetUsername"=""}
        $auth = Invoke-WebRequest -SessionVariable Sessions -UseBasicParsing -Uri "$serverAddress/?failover'" -Body $data -Method "Post" -ErrorAction Stop

        #grab session key for future AJAX call 
        $data = @{"id"="$id";"o"="r";"v"="management"}
        $response = Invoke-WebRequest -WebSession $Sessions -Method "Get" -Uri "$serverAddress/legacy/computers.html" -Body $data -ErrorAction Stop
        $key = $response.ParsedHtml.getElementById("session-token") | select -ExpandProperty value
        if($key.Length -eq 0){
            throw "Could Not Get Session Key"
        }

        $macDetails = Invoke-WebRequest -WebSession $Sessions -Uri "$serverAddress/legacy/computers.html?id=$id&o=r" -Method "Post" -Headers $headers -DisableKeepAlive:$false -ErrorAction Stop
        $fileVaultid = $macDetails.ParsedHtml.getElementById("FIELD_FILEVAULT2_INDIVIDUAL_KEY_VALUE")
        if($fileVaultid -eq $null){
            return "Error No FileVault ID In JAMF."
        }else{
            $fileVaultid = $fileVaultid.innerHTML.split("(")[1].split(",")[0].trim()
        }
    
        $data= "fileVaultKeyId=$fileVaultid&fileVaultKeyType=individualKey&identifier=FIELD_FILEVAULT2_INDIVIDUAL_KEY&ajaxAction=AJAX_ACTION_READ_FILE_VAULT_2_KEY&session-token=$key"
        $datalen = $data.Length
        $headers=@{
                "X-Requested-With"="XMLHttpRequest";
                "Origin"="$serverAddress";
                "Content-Type"= "application/x-www-form-urlencoded; charset=UTF-8";
                "Accept"= "*/*";
                "Content-Length"="$datalen";
                "Accept-Encoding"= "gzip, deflate, br";
                "Accept-Language"= "en-US,en;q=0.9";
                #"Connection"= "keep-alive";
                "User-Agent"= "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.81 Safari/537.36";
                "Referer"= "$serverAddress/legacy/computers.html?id=$id&o=r"
                }
        $getKey = Invoke-RestMethod -WebSession $Sessions -Uri "$serverAddress/computers.ajax?id=$id&o=r" -Body $data -Method "Post" -Headers $headers -DisableKeepAlive:$false -ErrorAction Stop
        $EncKey = $getKey.jss.individualKey
        if($EncKey.Length -gt 0){
            #found a key
            return "$EncKey"
        }else{
            return "Error No FileVault Key In JAMF."
        }
    }catch{
        $errorFV = $_.Exception.Message
        return "Error Grabbing FileVault Key - $errorFV."
    }
}
