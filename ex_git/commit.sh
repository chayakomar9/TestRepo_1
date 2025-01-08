#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: ./commit.sh <TaskID> <dev_comment> [<Push to GitHub (yes/no)>] [<Repo Path>]"
    exit 1
fi

TaskID=$1
DEV_COMMENT=$2
Push=${3:-no} #default is no push
RERO_PATH=${4:-"."} #default is current directory

CSV_FILE="ex_git/tasks.csv"

while IFS=',' read -r CSV_TASK_ID CSV_DESC CSV_BRANCH CSV_DEV CSV_GITHUB_URL
do

    if [ "$CSV_TASK_ID" == "TaskID" ]; then #skip the header row
        continue
    fi

    #If we find a match for TASK_ID, create the commit message
    if [ "$CSV_TASK_ID" == "$TASK_ID" ]; then
        TASK_DESC=$CSV_DESC
        BRANCH=$CSV_BRANCH
        DEV_NAME=$CSV_DEV
        GITHUB_URL=$CSV_GITHUB_URL

        CURRENT_DATE_TIME=$(date +"%Y%m%d_%H%M%S")

        #Change to the repository directory if path is provided
        cd "$REPO_PATH" || { echo "Repository path not found!"; exit 1; }

        #Ensure we're on the correct branch
        git checkout "$BRANCH" || { echo "Branch $BRANCH not found!"; exit 1; }

        #Commit message format
        COMMIT_MESSAGE="$TASK_ID - $CURRENT_DATE_TIME - $BRANCH - $DEV_NAME - $TASK_DESC - $DEV_COMMENT"

        #Stage all changes
        git add .

        #Commit with the generated message
        git commit -m "$COMMIT_MESSAGE" || { echo "Commit failed!"; exit 1; }

        #Push changes if 'push' is specified
        if [ "$PUSH" == "push" ]; then
            git push origin "$BRANCH" || { echo "Push failed!"; exit 1; }
            echo "Changes pushed to GitHub."
        else
            echo "Commit completed, but not pushed to GitHub."
        fi

        #Exit the loop since we found the task
        exit 0
    fi

done < "$CSV_FILE"
