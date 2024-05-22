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
                http_response_body=$(cat "$script_dir/view.html")  # Return a static HTML file
                http_response_content_type="text/html"
                ;;
            "GET /api/contacts")
                sql="SELECT * FROM view_person_json";
                ;;
            "POST /api/contacts/"*)
                label=$(echo "$http_request_path" | awk -F"/" '\''{print $NF}'\'')
                printf -v label "%b" "${label//\%/\\x}"  # Decode URL-encoded string, see https://stackoverflow.com/a/24003150
                sql="
                    INSERT INTO person (label) VALUES ('\''$label'\'')";
                ;;
            "POST /api/contacts/attributes"*)
                person_id=$(echo "$http_request_path" | awk -F"/" '\''{print $(NF-2)}'\'')
                attribute_name=$(echo "$http_request_path" | awk -F"/" '\''{print $(NF-1)}'\'')
                attribute_value=$(echo "$http_request_path" | awk -F"/" '\''{print $NF}'\'')
                printf -v attribute_name "%b" "${attribute_name//\%/\\x}"  # Decode URL-encoded string, see https://stackoverflow.com/a/24003150
                printf -v attribute_value "%b" "${attribute_value//\%/\\x}"  # Decode URL-encoded string, see https://stackoverflow.com/a/24003150
                sql="
                    INSERT INTO rel_attribute_person (person_id, name, value)
                    VALUES ($person_id, '\''$attribute_name'\'', '\''$attribute_value'\'')";
                ;;
                # TODO: CRUD Opertations for /contacts/attributes
            *)
                sql="SELECT 404";
                http_response_code=404;
                ;;
        esac

        # Excute SQL query, if any $sql
        if [ ! -z "$sql" ]; then
            echo "$(date) - Executing SQL: $sql" >&2
            http_response_body=$(psql -U postgres contacts -tAc "${sql}");
            http_response_content_type="application/json"
        fi;

        # Send HTTP Response
        echo "HTTP/1.1 ${http_response_code}\r\nContent-Type: ${http_response_content_type}\r\n\r\n${http_response_body}"  # Return JSON from SQL Query
    '
    # content_length=$(( ${#http_response_body} + 4 ))
    # echo "HTTP/1.1 200 OK\r\nContent-Length: ${content_length}\r\nContent-Type: plain/text\r\n\r\n${http_response_body} - "
    echo "$(date) - Sent HTTP Response."
done

