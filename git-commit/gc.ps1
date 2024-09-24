function gc {
    # Check for staged files
    $staged_files = git diff --cached --name-only
    if (-not $staged_files) {
        Write-Host "No files are staged for commit."
        return
    }

    # Prepare the prompt
    $staged_files_str = $staged_files -join "`n"
    $prompt = "Generate a concise and clear git commit message based on the following staged files:`n$staged_files_str"

    # TODO: Replace this section with your local intelligence server API call
    # Set the API URL
    $apiUrl = "http://SOME-API-URL"

    try {
        $body = @{
            model = "llama3.1"
            prompt = $prompt
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"
    } catch {
        Write-Host "Error: No response from API."
        return
    }

    # Parse the response to get the commit message
    $commit_message = $response.commit_message  # Adjust the parsing based on your API's response format

    if (-not $commit_message) {
        Write-Host "Error: Could not generate a commit message."
        return
    }

    # Display staged files and proposed commit message
    Write-Host "Staged files:"
    Write-Host $staged_files_str
    Write-Host ""
    Write-Host "Proposed commit message:"
    Write-Host $commit_message
    Write-Host ""

    # Prompt for user confirmation or editing
    $choice = Read-Host "Press Enter to confirm, 'e' to edit the commit message, or 'q' to cancel"
    if ($choice -eq "q") {
        Write-Host "Commit cancelled."
        return
    } elseif ($choice -eq "e") {
        # Open the commit message in an editor
        $temp_file = [System.IO.Path]::GetTempFileName()
        Set-Content -Path $temp_file -Value $commit_message

        # Open the temp file in Notepad
        Start-Process notepad $temp_file

        # Wait for the user to finish editing
        Write-Host "After editing the commit message, save and close Notepad."
        Write-Host "Press Enter when you have finished editing the commit message."
        Read-Host

        # Read the edited commit message
        $commit_message = Get-Content -Path $temp_file -Raw

        # Remove the temp file
        Remove-Item $temp_file
    }

    # Write the commit message to a temp file for git commit
    $commit_file = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $commit_file -Value $commit_message

    # Commit using the commit message file
    git commit -F $commit_file

    # Remove the temp file
    Remove-Item $commit_file
}
