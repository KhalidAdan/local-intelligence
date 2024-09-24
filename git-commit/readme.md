# Git Commit

(This document written by O1 preview, reviewed by me)

This script is a Git commit helper that uses a local intelligence server to generate a concise and clear commit message based on the staged files in your Git repository. It streamlines the commit process by automating message creation, while still giving you the option to review and edit the message before finalizing the commit.

## Why this script exists

Writing informative and meaningful commit messages is crucial for maintaining a project's history and facilitating collaboration. However, crafting these messages can be time-consuming or overlooked. This script leverages a local language model to analyze your staged changes and generate a suitable commit message automatically. This ensures consistency, saves time, and enhances the quality of your commit history.

## Usage

To use the script, follow these steps:

1. Stage Your Changes

Add the files you want to commit using:

```bash
git add <file1> <file2> ...
```

Or to add all changes in the current directory:

```bash
git add .
```

2. Run the Script

Run the script using:

```bash
gc
```

3. Review the Proposed Commit Message

The script will display:

- A list of staged files.
- A generated commit message based on these files.

4. Choose an Action

- Press Enter to confirm and use the proposed commit message.
- Type `e` and press Enter to edit the commit message in your default text editor.
- Type `q` and press Enter to cancel the commit process.

5. Finalize the Commit

If confirmed, the script will commit your changes with the chosen commit message.

## Installation

Copy the `gc` function from `gc.sh` or `gc.ps1` to your `.bashrc` or `.zshrc` file, whichever you need. If on windows add to your $PROFILE

## Configuration

- **Local Intelligence Server**
  Ensure your local server is running at and is accessible from your machine, update the `$apiUrl` variable (PowerShell) or the URL in the `curl` command (Bash) accordingly.
- **API Endpoint**
  If your server uses a different IP address or port, update the `$apiUrl` variable (PowerShell) or the URL in the `curl` command (Bash) accordingly.
- **Model Selection**
  The script specifies `"model": "llama3.1"`. Change this if you're using a different model.

This script enhances your Git workflow by automating the generation of commit messages using a local language model. It ensures that your commits are well-documented while saving you time and effort. By integrating it into your development environment, you can maintain a clean and informative commit history with ease.
