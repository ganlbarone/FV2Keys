function CasperFVault($id){
    try{
        #initial auth \ only purpose here is to get cookies, we dont pass auth header info anywhere else, we simply capture cookie.
        $user = "ENTER USER NAME HERE"
        $pass= "ENTER PASSWORD HERE"
        $serverAddress = "https://somedomain.com:8443" #must be in format https://servername:port
        $data = @{"username"="$user";"password"="$pass";"resetUsername"=""}
        $auth = Invoke-WebRequest -SessionVariable Sessions -UseBasicParsing -Uri "$serverAddress/?failover'" -Body $data -Method "Post" -TimeoutSec 2

        #grab session key for future AJAX call 
        $data = @{"id"="$id";"o"="r";"v"="management"}
        $response = Invoke-WebRequest -WebSession $Sessions -Method "Get" -UseBasicParsing -Uri "$serverAddress/legacy/computers.html" -Body $data -TimeoutSec 2
        $response = $response.rawcontent.split(">")
        foreach($line in $response){
            if($line.contains('session-token')){
                $key = $line.split()[-1].replace('"',"").replace("value=","")
            }
        }

        #build header info. ALL THIS IS NEEDED
        $data = "&ajaxAction=AJAX_ACTION_READ_FILE_VAULT_2_KEY&session-token=$key"
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
                "Referer"= "$serverAddress/legacy/computers.html?id=$id&o=r&v=management"
                }

        #AJAX call is specified in data body
        $auth = Invoke-WebRequest -WebSession $Sessions -UseBasicParsing -Uri "$serverAddress/computers.ajax?id=$id&o=r&v=management" -Body $data -Method "Post" -Headers $headers -DisableKeepAlive:$false -TimeoutSec 2
        $data = $auth.RawContent.split("`n")
        foreach($line in $data){
            if($line.Contains("individual")){
                $line = [xml]$line
                $EncKey = $line.individualKey
            }
        }
        if($EncKey.Length -gt 0){
            #found a key
            return "$EncKey"
        }else{
            return "No FileVault Key In JAMF."
        }
    }catch{
        $errorFV = $_.Exception.Message
        return "Error Grabbing FileVault Key - $errorFV."
    }
}