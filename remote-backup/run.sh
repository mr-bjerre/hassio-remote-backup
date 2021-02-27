#!/bin/bash
# hassio remote-backup main script
# formatted with: shfmt -i 4 -l
set -e

CONFIG_PATH=/data/options.json
HA=/usr/bin/ha

# parse inputs from options
SSH_HOST=$(jq --raw-output ".ssh_host" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
SSH_USER=$(jq --raw-output ".ssh_user" $CONFIG_PATH)
SSH_KEY=$(jq --raw-output ".ssh_key[]" $CONFIG_PATH)
REMOTE_DIRECTORY=$(jq --raw-output ".remote_directory" $CONFIG_PATH)
ZIP_PASSWORD=$(jq --raw-output '.zip_password' $CONFIG_PATH)
KEEP_LOCAL_BACKUP=$(jq --raw-output '.keep_local_backup' $CONFIG_PATH)

# create variables
SSH_ID="${HOME}/.ssh/id"

function add-ssh-key {
    echo "Adding SSH key"
    mkdir -p ~/.ssh
    (
        echo "Host remote"
        echo "    IdentityFile ${HOME}/.ssh/id"
        echo "    HostName ${SSH_HOST}"
        echo "    User ${SSH_USER}"
        echo "    Port ${SSH_PORT}"
        echo "    StrictHostKeyChecking no"
    ) >"${HOME}/.ssh/config"

    while read -r line; do
        echo "$line" >>${HOME}/.ssh/id
    done <<<"$SSH_KEY"

    chmod 600 "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/id"
}

function copy-backup-to-remote {

    cd /backup/
    if [[ -z $ZIP_PASSWORD ]]; then
        echo "Copying ${slug}.tar to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
        scp -F "${HOME}/.ssh/config" "${slug}.tar" remote:"${REMOTE_DIRECTORY}"
    else
        echo "Copying password-protected ${slug}.zip to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
        zip -P "$ZIP_PASSWORD" "${slug}.zip" "${slug}".tar
        scp -F "${HOME}/.ssh/config" "${slug}.zip" remote:"${REMOTE_DIRECTORY}" && rm "${slug}.zip"
    fi

}

function delete-local-backup {

    ${HA} snapshots reload

    if [[ ${KEEP_LOCAL_BACKUP} == "all" ]]; then
        :
    elif [[ -z ${KEEP_LOCAL_BACKUP} ]]; then
        echo "Deleting local backup: ${slug}"
        ${HA} snapshots remove ${slug}
    else
        ## jq filter used to select required snapshots to delete.
        ## Expanded form given here with explanation...
        #   # Remove outer containers to leave an array of snapshot objects
        #   .data.snapshots
        #   # select out snapshots that are not protected
        #   | map(select(.protected==false))
        #   # sort the objects by date - oldest first
        #   | sort_by(.date)
        #   # reverse the sort - now oldest last
        #   | reverse
        #   # select all items after the fist ${KEEP_LOCAL_BACKUP} items
        #   | .[${KEEP_LOCAL_BACKUP}:]
        #   # output just the slug entry for each snapshot
        #   | .[].slug
        for slug in $(
            ${HA} snapshots list --raw-json |
                jq -r ".data.snapshots | map(select(.protected==false)) | sort_by(.date) | reverse | .[${KEEP_LOCAL_BACKUP}:] | .[].slug"
        ); do
            echo "Deleting local backup: ${slug}"
            ${HA} snapshots remove ${slug}
        done

    fi
    echo Exiting
}

function create-local-backup {
    name="Automated backup $(date +'%Y-%m-%d %H:%M')"
    echo "Creating local backup: \"${name}\""
    slug=$(${HA} snapshots new --raw-json --name="${name}" --no-progress | jq --raw-output '.data.slug')
    echo "Backup created: ${slug}"
}

add-ssh-key
create-local-backup
copy-backup-to-remote
delete-local-backup

echo "Backup process done!"
exit 0
