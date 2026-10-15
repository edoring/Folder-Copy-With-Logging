
# 📁 Folder Copy with Logging

A simple PowerShell utility for copying folders between hard drives using Robocopy.

This script provides a guided workflow for copying files and subfolders from one location to another while creating a detailed transfer log and summary. It is designed for Windows users who need a straightforward way to transfer large amounts of data without moving or deleting the original files.

## 🚀 What the Script Does

This script helps you:

- Copy a folder and all its subfolders to another hard drive
- Preserve file and folder timestamps and attributes
- Create a detailed Robocopy log documenting the transfer
- Generate a summary with the source, destination, start time, finish time, duration, and Robocopy exit code
- Identify transfers that may need further review

The script uses simple prompts to guide you through the process. No programming experience is required.

## 📁 Included Tool

This repository contains:

- `Copy-Folders-With-Log.ps1` — Copies folders between drives and creates transfer documentation.

No additional software needs to be installed. Robocopy is included with Windows.

## 📥 How to Download the Script

1. Visit this repository on GitHub.
2. Click the green **Code** button.
3. Select **Download ZIP**.
4. Save the ZIP file to your computer.
5. Right-click the downloaded ZIP file and select **Extract All...**
6. Open the extracted folder.

The PowerShell script will be available inside the extracted folder.

## 🔧 How to Run the Script

1. Connect both the source and destination hard drives to your computer.
2. Open the folder containing `Copy-Folders-With-Log.ps1`.
3. Right-click the script.
4. Select **Run with PowerShell**.
5. Follow the prompts to enter the source folder and destination parent folder.
6. Review the displayed paths carefully.
7. Type `YES` when prompted to confirm the transfer.
8. Allow Robocopy to finish. Keep both drives connected during the transfer.

If Windows blocks the script because of its execution policy, follow your organization's approved procedure for running PowerShell scripts.

## 📂 Entering Folder Paths

The script asks for two paths.

**Source folder:** The folder you want to copy.

Example:

`E:\Archives\Governor Papers`

**Destination parent folder:** The drive or folder where you want the copied folder to be placed.

Example:

`F:\`

In this example, the script copies the `Governor Papers` folder to:

`F:\Governor Papers`

The destination folder retains the name of the original source folder.

## 📋 Transfer Documentation

The script creates a `_transfer_documentation` folder in the destination parent folder.

This folder contains:

- A detailed Robocopy log recording the transfer results
- A transfer summary documenting the source and destination paths, start and finish times, duration, Robocopy exit code, and reported status

Example folder structure:

```text
F:\
├── Governor Papers\
│   ├── Folder 1\
│   ├── Folder 2\
│   └── ...
└── _transfer_documentation\
    ├── Robocopy_Governor Papers_YYYYMMDD_HHMMSS.log
    └── Transfer_Summary_Governor Papers_YYYYMMDD_HHMMSS.txt
```

The actual log filenames include the date and time of the transfer.

## 🗄️ Notes for Archival Transfers

- **Original files remain untouched.** The script copies files rather than moving or deleting them.
- **No checksum verification is performed.** This script does not independently verify that copied files are identical to their sources.
- **Existing destination files:** If the destination folder already exists, matching files may be updated. Files that exist only in the destination are not intentionally deleted by this script.
- **Transfer status:** A `PASS` status means Robocopy reported no copy failure. It is not a substitute for checksum verification.
- **Review required:** A transfer that reports an error should be investigated using the detailed log.
- **Large transfers:** Transfers involving several terabytes of data may take many hours or longer. Keep the computer powered on and prevent it from sleeping during the transfer.

For important archival transfers, review the log and summary after each copy operation.

## 🛠 Troubleshooting

**The script will not run**

Windows may block PowerShell scripts because of its execution policy. Follow your organization's approved procedure for running scripts.

**The source or destination folder cannot be found**

Check that the drive is connected and that the folder path is correct. Enter the full path when prompted.

**The transfer reports that review is needed**

Open the detailed Robocopy log in `_transfer_documentation` and review the reported errors. Check that both drives remained connected and that the destination had enough available space.

**The transfer takes longer than expected**

Transfer speed depends on the drives, USB connection, number and size of files, and other computer activity. Large transfers may need to run overnight or longer.

## 📌 Transparency Statement: AI in Script Development

AI tools were incorporated during the development of this project to assist with:

- Generating and refining PowerShell script logic
- Drafting and organizing user documentation
- Improving the clarity of instructions for users with minimal technical experience

AI-assisted material should be reviewed and tested before use. Transfer results should be evaluated using the logs and the needs of the specific workflow.

---

I hope it helps!
