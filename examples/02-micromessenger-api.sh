# #!/bin/bash

# Script: webserver.sh
# Description: Minimalistic web server in Bash and Zsh that listens for HTTP requests, executes a PostgreSQL command, and returns the result as an HTTP response.
# Usage: Run the script using Bash or Zsh. Ensure that the 'psql' command is accessible from the environment.
# Note: Replace 'http://localhost:8080/' with the desired listening address and port.
# Authors: Damien Corpataux & ChatGPT: https://chat.openai.com/share/c49d73a4-8598-4f35-8294-ab5dbb5db0c5

port=8080
script_dir=$(dirname "$0")  # Script directory, to be used inside the sh spawned by --sh-exec

echo "$(date) - Starting HTTP Server on port ${port}, please visit http://localhost:${port}/"

while true; do

    # Listen for incoming HTTP requests and handle them
    echo "$(date) - Listening for HTTP Request..."
    ncat -l "${port}" --sh-exec '

        function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

        # Read the script directory from the environment variable
        script_dir='${script_dir}'  # We need to pass $script_dir as string concatenation from the calling shell

        # Read HTTP Request and extract info
        read -r request;
        http_request_method=$(echo "$request" | awk '\''{print $1}'\'');
        http_request_path=$(echo "$request" | awk '\''{print $2}'\'');
        http_response_code=200;
        echo "$(date) - Received HTTP Request: $http_request_method $http_request_path" >&2

        # Route HTTP Request
        case "$http_request_method $http_request_path" in
            "GET /")
                http_response_body=$(cat "$script_dir/02-micromessenger-ui.html")  # Return a static HTML file
                http_response_content_type="text/html"
                ;;
            "GET /api/contacts")
                sql="SELECT json_agg(to_json(view_contacts)) FROM view_contacts";
                ;;
            "GET /api/messages")
                sql="SELECT json_agg(to_json(view_messages)) FROM view_messages";
                ;;
            "POST /api/messages/"*)
                source=$(echo "$http_request_path" | awk -F"/" '\''{print $(NF-2)}'\'')
                destination=$(echo "$http_request_path" | awk -F"/" '\''{print $(NF-1)}'\'')
                content=$(echo "$http_request_path" | awk -F"/" '\''{print $NF}'\'')
                printf -v content "%b" "${content//\%/\\x}"  # Decode URL-encoded content, see https://stackoverflow.com/a/24003150
                sql="
                    INSERT INTO rel_message (contact_id_source, contact_id_destination, content)
                    VALUES ($source, $destination, '\''$content'\'')";
                ;;
            # "GET /static/"*)
            #     file=$(echo "$http_request_path" | awk -F"/" '\''{print $NF}'\'')
            #     printf -v file "%b" "${file//\%/\\x}"  # Decode URL-encoded content, see https://stackoverflow.com/a/24003150
            #     http_response_body=$(cat "$script_dir/$file")  # Return a static HTML file
            #     http_response_content_type="text/plain"
            #     ;;
            *)
                sql="SELECT 404";
                http_response_code=404;
                ;;
        esac

        # Excute SQL query, if any $sql
        if [ ! -z "$sql" ]; then
            echo "  Executing SQL: $sql" >&2
            http_response_body=$(psql -U postgres micromessenger -tAc "${sql}");
            http_response_content_type="application/json"
        fi;

        # Send HTTP Response
        echo "HTTP/1.1 ${http_response_code}\r\nContent-Type: \r\n\r\n${http_response_body}"  # Return JSON from SQL Query
    '
    # content_length=$(( ${#http_response_body} + 4 ))
    # echo "HTTP/1.1 200 OK\r\nContent-Length: ${content_length}\r\nContent-Type: plain/text\r\n\r\n${http_response_body} - "
    echo "$(date) - Sent HTTP Response."
done

