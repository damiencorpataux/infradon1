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
        # Read the script directory from the environment variable
        script_dir='${script_dir}'  # We need to pass $script_dir as string concatenation from the calling shell

        # Read HTTP Request and extract info
        read -r request;
        http_request_method=$(echo "$request" | awk '\''{print $1}'\'');
        http_request_path=$(echo "$request" | awk '\''{print $2}'\'');
        http_response_code=200;

        # Route HTTP Request
        if [ "$http_request_path" = "/" ]; then
            echo "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n$(cat $script_dir/03-goodgrade-view.html)"  # Return a static HTML file
        else
            case "$http_request_path" in
                "/api/grades")
                    sql="SELECT json_agg(to_json(view_grades)) FROM view_grades";
                    ;;
                "/api/grades/average")
                    sql="SELECT json_agg(to_json(view_grades_avg_per_module)) FROM view_grades_avg_per_module";
                    ;;
                *)
                    sql="SELECT 404";
                    http_response_code=404;
                    ;;
            esac

            # Excute SQL query
            http_response_body=$(psql -U postgres goodgrade -tAc "${sql}");

            # Send HTTP Response
            echo "HTTP/1.1 ${http_response_code}\r\nContent-Type: application/json\r\n\r\n${http_response_body}"  # Return JSON from SQL Query
        fi
    '
    # content_length=$(( ${#http_response_body} + 4 ))
    # echo "HTTP/1.1 200 OK\r\nContent-Length: ${content_length}\r\nContent-Type: plain/text\r\n\r\n${http_response_body} - "
    echo "$(date) - Sent HTTP Response."
done

