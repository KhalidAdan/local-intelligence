function gc() {
    # Check for staged files
    staged_files=$(git diff --cached --name-only)
    if [ -z "$staged_files" ]; then
        echo "No files are staged for commit."
        return
    fi

    # Prepare the prompt or data for your LLM
    prompt="Generate a concise and clear git commit message based on the following staged files:\n$staged_files"

    # TODO: Replace this section with your local intelligence server API call
    # For example, you might use curl to send the prompt to your server and get the response
    # Example:
    # response=$(curl -X POST http://your-local-server/api -d '{"prompt": "'"${prompt}"'"}')
    response=$(curl http://SOME-API-URL -d '{
      "model": "llama3.1",
      "prompt": prompt,
    }')

    # Check for API errors
    if [ -z "$response" ]; then
        echo "Error: No response from Ollama API."
        return
    fi

    # Parse the response to get the commit message
    commit_message=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
    if [ -z "$commit_message" ] || [ "$commit_message" = "null" ]; then
        echo "Error: Could not generate a commit message."
        return
    fi

    # Display staged files and proposed commit message
    echo "Staged files:"
    echo "$staged_files"
    echo
    echo "Proposed commit message:"
    echo "$commit_message"
    echo

    # Prompt for user confirmation or editing
    read "choice?Press Enter to confirm, 'e' to edit the commit message, or 'q' to cancel: "
    if [ "$choice" = "q" ]; then
        echo "Commit cancelled."
        return
    elif [ "$choice" = "e" ]; then
        # Open the commit message in an editor
        tmpfile=$(mktemp)
        echo "$commit_message" > "$tmpfile"
        ${EDITOR:-nano} "$tmpfile"
        commit_message=$(cat "$tmpfile")
        rm "$tmpfile"
    fi

    # Commit
    git commit -m "$commit_message"
}
