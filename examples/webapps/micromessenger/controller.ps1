# Script: webserver.ps1
# Description: Minimalistic web server in PowerShell that listens for HTTP requests, executes a PostgreSQL command, and returns the result as an HTTP response.
# Usage: Run the script using PowerShell. Ensure that the 'psql' command is accessible from the environment.
# Note: Replace 'http://localhost:8080/' with the desired listening address and port.
# Authors: Damien Corpataux & ChatGPT: https://chat.openai.com/share/c49d73a4-8598-4f35-8294-ab5dbb5db0c5

# Set the desired listening address and port
$address = "http://localhost:8080/"

# Create the HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($address)
$listener.Start()

Write-Host "$(Get-Date) ➤ Starting HTTP Server on port $($address), please visit $address"

while ($listener.IsListening) {
    try {
        # Wait for an incoming HTTP request
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        # Extract information from the HTTP request
        $http_request_method = $request.HttpMethod
        $http_request_path = $request.Url.AbsolutePath
        Write-Host "$(Get-Date) ➤ └─ Received HTTP Request: $http_request_method $http_request_path"

        # Route HTTP Request
        switch -Regex ($http_request_method + " " + $http_request_path) {
            "GET /" {
                $http_response_body = Get-Content "$script_dir/view.html" -Raw
                $http_response_content_type = "text/html"
            }
            "GET /api/contacts" {
                $sql = "SELECT json_agg(to_json(view_contacts)) FROM view_contacts"
            }
            "GET /api/messages" {
                $sql = "SELECT json_agg(to_json(view_messages)) FROM view_messages"
            }
            "POST /api/messages/(?<source>\d+)/(?<destination>\d+)/(?<content>.*)" {
                $source = $matches["source"]
                $destination = $matches["destination"]
                $message_encoded = $matches["content"]
                $message = [System.Uri]::UnescapeDataString($message_encoded)
                Write-Host "$(Get-Date) ➤ └─ Decoded message: $message_encoded"
                Write-Host "$(Get-Date)                   to: $message"
                $sql = @"
                    INSERT INTO rel_message (contact_id_source, contact_id_destination, content)
                    VALUES ($source, $destination, '$message')
"@
            }
            "POST /api/contacts/(?<contact_name>.*)" {
                $contact_name_encoded = $matches["contact_name"]
                $contact_name = [System.Uri]::UnescapeDataString($contact_name_encoded)
                Write-Host "$(Get-Date) ➤ └─ Decoded contact name: $contact_name_encoded -> $contact_name"
                $sql = @"
                    INSERT INTO contact (status_id, name)
                    VALUES (1, '$contact_name')
"@
            }
            # "GET /static/"* {  # TODO: A static file provider accepting arbitrary filename to be served.
            #     $file = $request.Url.AbsolutePath -replace "^/static/", ""
            #     $http_response_body = Get-Content "$script_dir/$file" -Raw
            #     $http_response_content_type = "text/plain"
            # }
            Default {
                $http_response_body = "404: Not Found."
                $http_response_content_type = "text/plain"
            }
        }

        # Execute SQL query, if any $sql
        if (-not [string]::IsNullOrEmpty($sql)) {
            Write-Host "$(Get-Date) ➤    └─ Executing SQL: $sql"
            $http_response_body = (psql -U postgres micromessenger -tAc $sql 2>&1)
            $http_response_content_type = "application/json"
            # Handle case of SQL error
            if ($http_response_body -match "error") {
                $http_response_code = 500
                $http_response_content_type = "text/plain"
            }
        }

        # Send HTTP Response
        Write-Host "$(Get-Date) ➤    └─ Sending HTTP Response ($($http_response_body.Length) bytes)..."
        Write-Host "$(Get-Date) ➤       └─ Reponse Detail: $http_response_code, $http_response_content_type, $($http_response_body.Substring(0, [Math]::Min(64, $http_response_body.Length)))..."
        $response.ContentType = $http_response_content_type
        $response.StatusCode = $http_response_code
        $response.OutputStream.Write([System.Text.Encoding]::UTF8.GetBytes($http_response_body), 0, $http_response_body.Length)
        $response.Close()
    }
    catch {
        Write-Host "Error occurred: $_"
    }
}

# Stop the listener when the loop is exited
$listener.Stop()
