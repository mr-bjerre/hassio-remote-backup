#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

# parse inputs from options
SSH_ENABLED=$(jq --raw-output ".ssh_enabled" $CONFIG_PATH)
SSH_HOST=$(jq --raw-output ".ssh_host" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
SSH_USER=$(jq --raw-output ".ssh_user" $CONFIG_PATH)
SSH_KEY=$(jq --raw-output ".ssh_key[]" $CONFIG_PATH)
REMOTE_DIRECTORY=$(jq --raw-output ".remote_directory" $CONFIG_PATH)
ZIP_PASSWORD=$(jq --raw-output '.zip_password' $CONFIG_PATH)
KEEP_LOCAL_BACKUP=$(jq --raw-output '.keep_local_backup' $CONFIG_PATH)

RSYNC_ENABLED=$(jq --raw-output ".rsync_enabled" $CONFIG_PATH)
RSYNC_HOST=$(jq --raw-output ".rsync_host" $CONFIG_PATH)
RSYNC_ROOTFOLDER=$(jq --raw-output ".rsync_rootfolder" $CONFIG_PATH)
RSYNC_USER=$(jq --raw-output ".rsync_user" $CONFIG_PATH)
RSYNC_PASSWORD=$(jq --raw-output ".rsync_password" $CONFIG_PATH)

# create variables
SSH_ID="${HOME}/.ssh/id"

function add-ssh-key {

    if [ "$SSH_ENABLED" = true ] ; then
        echo "Adding SSH key"
        mkdir -p ~/.ssh
        (
            echo "Host remote"
            echo "    IdentityFile ${HOME}/.ssh/id"
            echo "    HostName ${SSH_HOST}"
            echo "    User ${SSH_USER}"
            echo "    Port ${SSH_PORT}"
            echo "    StrictHostKeyChecking no"
        ) > "${HOME}/.ssh/config"

        while read -r line; do
            echo "$line" >> ${HOME}/.ssh/id
        done <<< "$SSH_KEY"

        chmod 600 "${HOME}/.ssh/config"
        chmod 600 "${HOME}/.ssh/id"
    fi    
}

function copy-backup-to-remote {

    if [ "$SSH_ENABLED" = true ] ; then
        cd /backup/
        if [[ -z $ZIP_PASSWORD  ]]; then
            echo "Copying ${slug}.tar to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
            scp -F "${HOME}/.ssh/config" "${slug}.tar" remote:"${REMOTE_DIRECTORY}"
        else
            echo "Copying password-protected ${slug}.zip to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
            zip -P "$ZIP_PASSWORD" "${slug}.zip" "${slug}".tar
            scp -F "${HOME}/.ssh/config" "${slug}.zip" remote:"${REMOTE_DIRECTORY}" && rm "${slug}.zip"
        fi
    fi
}

function delete-local-backup {

    hassio snapshots reload

    if [[ ${KEEP_LOCAL_BACKUP} == "all" ]]; then
        :
    elif [[ -z ${KEEP_LOCAL_BACKUP} ]]; then
        echo "Deleting local backup: ${slug}"
        hassio snapshots remove "${slug}"
    else

        last_date_to_keep=$(hassio snapshots list --raw-json | jq .data.snapshots[].date | sort -r | \
            head -n "${KEEP_LOCAL_BACKUP}" | tail -n 1 | xargs date -D "%Y-%m-%dT%T" +%s --date )

        hassio snapshots list --raw-json | jq -c .data.snapshots[] | while read backup; do
            if [[ $(echo ${backup} | jq .date | xargs date -D "%Y-%m-%dT%T" +%s --date ) -lt ${last_date_to_keep} ]]; then
                echo "Deleting local backup: $(echo ${backup} | jq -r .slug)"
                hassio snapshots remove "$(echo ${backup} | jq -r .slug)"
            fi
        done

    fi
}

function create-local-backup {
    name="Automated backup $(date +'%Y-%m-%d %H:%M')"
    echo "Creating local backup: \"${name}\""
    slug=$(hassio snapshots new --raw-json --name="${name}" | jq --raw-output '.data.slug')
    echo "Backup created: ${slug}"
}

function rsync_folders {

    if [ "$RSYNC_ENABLED" = true ] ; then
        rsyncurl="$RSYNC_USER@$RSYNC_HOST::$RSYNC_ROOTFOLDER"
        echo "[Info] trying to rsync hassio folders to $rsyncurl"
        echo ""
        echo "[Info] /config"
         sshpass -p $RSYNC_PASSWORD rsync -av --exclude '*.db-shm' --exclude '*.db-wal' /config/ $rsyncurl/config/ --delete
        echo ""
        echo "[Info] /addons"
         sshpass -p $RSYNC_PASSWORD rsync -av /addons/ $rsyncurl/addons/ --delete
        echo ""
        echo "[Info] /backup"
         sshpass -p $RSYNC_PASSWORD rsync -av /backup/ $rsyncurl/backup/ --delete
        echo ""
        echo "[Info] /share"
         sshpass -p $RSYNC_PASSWORD rsync -av /share/ $rsyncurl/share/ --delete
        echo ""
        echo "[Info] /ssl"
         sshpass -p $RSYNC_PASSWORD rsync -av /ssl/ $rsyncurl/ssl/ --delete
        echo "[Info] Finished rsync"
    fi
}


add-ssh-key
create-local-backup
copy-backup-to-remote
rsync_folders
delete-local-backup

echo "Backup process done!"
exit 0
