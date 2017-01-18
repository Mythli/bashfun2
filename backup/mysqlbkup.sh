#!/bin/bash
# --------------------------------------------------------------------------------
# mysqlbkup
# (c) Nathan Nobbe 2014
# http://quickshiftin.com
# quickshiftin@gmail.com
#
# A simple MySQL backup script in BASH.
#
# All it does is loop over every database and create a backup
# file.  Every database has its own direcotry beneath the root
# backup directory, $BACKUP_DIR.
#
# We're using gzip compression on each backup file and
# labeling backup files by date.  The number of backup files
# per db is controlled by $MAX_BACKUPS.
#
# The script is intended to be run by a cron job.  It echos
# messages to STDOUT which can be redirected to a file for
# simple logging. 
# --------------------------------------------------------------------------------


SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

# mysql server info ------------------------------------------
if [ -e "$SCRIPTPATH/backup.config" ]; then
    . $SCRIPTPATH/backup.config
fi

if [ -z "$DEFAULTS_FILE" ]; then
    echo 'mysql configuration file (DEFAULTS_FILE) not set in configuration.' 1>&2
    exit 1
fi

if [ -z "$BACKUP_DIR" ]; then
    echo 'Backup directory not set in configuration.' 1>&2
    exit 3
fi

if [ -z "$MAX_BACKUPS" ]; then
    echo 'Max backups not configured.' 1>&2
    exit 4
fi

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p $BACKUP_DIR
    chown "$BACKUP_USER:$BACKUP_GROUP" $BACKUP_DIR
fi

if [ ! -e $DEFAULTS_FILE ]; then
    echo "DEFAULTS_FILE ($DEFAULTS_FILE) does not exist" 1>&2
    exit 6
fi

if ! grep -Fxq "[mysql]" $DEFAULTS_FILE; then
    echo "DEFAULTS_FILE ($DEFAULTS_FILE) missing [mysql] block" 1>&2
    exit 7
fi

if ! grep -Fxq "[mysqldump]" $DEFAULTS_FILE; then
    echo "DEFAULTS_FILE ($DEFAULTS_FILE) missing [mysqldump] block" 1>&2
    exit 8
fi

nuke() {
    nukeDir=$1
    nukeExtension=$2

    numBackups=$(ls -1lt "$nukeDir"/*."$nukeExtension" 2>/dev/null | wc -l) # count the number of existing backups for $db
    if [ -z "$numBackups" ]; then numBackups=0; fi

    if [ "$numBackups" -gt "$MAX_BACKUPS" ]; then
        # how many files to nuke
        ((numFilesToNuke = "$numBackups - $MAX_BACKUPS + 1"))
        # actual files to nuke
        filesToNuke=$(ls -1rt "$nukeDir"/*."$nukeExtension" | head -n "$numFilesToNuke" | tr '\n' ' ')

        echo "Nuking files $filesToNuke"
        rm $filesToNuke
    fi
}

#if ! (stat -c "%a" $DEFAULTS_FILE | grep -xq ".00"); then
#    echo "DEFAULTS_FILE ($DEFAULTS_FILE) needs secure file permissions" 1>&2
#    exit 9
#fi

# First command line arg indicates dry mode meaning don't actually run mysqldump
DRY_MODE=0
if [ -n "$1" -a "$1" == 'dry' ]; then
    DRY_MODE=1
fi

# Check for external dependencies, bail with an error message if any are missing
for program in date $BKUP_BIN head hostname ls mysql mysqldump rm tr wc
do
    which $program 1>/dev/null 2>/dev/null
    if [ $? -gt 0 ]; then
        echo "External dependency $program not found or not in $PATH" 1>&2
        exit 6
    fi
done

# the date is used for backup file names
date=$(date +%F)

# get the list of dbs to backup, may as well just hit them all..
dbs=$(echo 'show databases' | mysql --defaults-file=$DEFAULTS_FILE )

# Apply default filters
db_filter='Database information_schema performance_schema mysql'
if [ ${#DB_EXCLUDE_FILTER} -gt 0 ]; then
    db_filter="$db_filter ${DB_EXCLUDE_FILTER}"
fi

echo "== Running $0 on $(hostname) - $date =="; echo

 loop over the list of databases
for db in $dbs
do
    # Check to see if the current database should be skipped
    skip='';
    for filter in $db_filter; do
        real_filter="${filter:1}"

        # default to bash pattern matching
        # with support for regular expression matching instead
        match_type='='
        if [ "${filter:0:1}" == '~' ]; then
            match_type='=~'
        fi

        # Evalute the matching expression such that metacharacters like * are
        # treated appropriately instead of literally
        # @note If you know a way to do this without invoking the shell again please make this better!
        #       This was the only way I could figure out how to do it with my skill level in BASH.
        cmd='if [[ "'"$db"'" '"$match_type"' '"$filter"' ]]; then echo skip; fi;';
        skip=$(bash -c "$cmd");

        # Skip this database if
        if [ "$skip" == skip ]; then
            continue 2;
        fi
    done;

    backupDir="$BACKUP_DIR/$db"    # full path to the backup dir for $db
    mysqlBackupFile="$date-$db.sql.$BKUP_EXT"  # filename of backup for $db & $date
    wwwBackupFile="$date-$db.www.$BKUP_EXT"  # filename of backup for $db & $date

    echo "Backing up $db into $backupDir"

    # each db gets its own directory
    if [ ! -d "$backupDir" ]; then
        # create the backup dir for $db if it doesn't exist
        echo "Creating directory $backupDir"
        mkdir -p "$backupDir"
        chown "$BACKUP_USER:$BACKUP_GROUP" $backupDir
    else
        # nuke any backups beyond $MAX_BACKUPS
        nuke $backupDir "sql.$BKUP_EXT"
        nuke $backupDir "www.$BKUP_EXT"
    fi

    # create the backup for $db
    echo "yeah"
    echo "Running: mysqldump --defaults-file=$DEFAULTS_FILE $db | $BKUP_BIN > $backupDir/$mysqlBackupFile"
    echo "Running: $TAR_BIN $backupDir/$wwwBackupFile $WWW_DIR/$db"

    # Skip actual call to mysqldump in DRY mode
    if [ $DRY_MODE -eq 1 ]; then
        continue;
    fi

    mysqldump --defaults-file=$DEFAULTS_FILE "$db" | $BKUP_BIN > "$backupDir/$mysqlBackupFile"

    echo

    if [ -d "$WWW_DIR/$db" ]; then
        $TAR_BIN "$backupDir/$wwwBackupFile" "$WWW_DIR/$db"
        chown "$BACKUP_USER:$BACKUP_GROUP" "$backupDir/$wwwBackupFile"
    fi
done


echo "YEAH $FOLDERS"

for folder in $(echo $FOLDERS | sed "s/,/ /g")
do
    folderName=`basename $folder`
    backupDir="$BACKUP_DIR/$folderName"

    if [ ! -d "$backupDir" ]; then
        # create the backup dir for $db if it doesn't exist
        echo "Creating directory $backupDir"
        mkdir -p "$backupDir"
        chown "$BACKUP_USER:$BACKUP_GROUP" $backupDir
    else
        # nuke any backups beyond $MAX_BACKUPS

        nuke $backupDir "$BKUP_EXT"
    fi

    folderBackupFile="$date-$folderName.$BKUP_EXT"

    $TAR_BIN "$backupDir/$folderBackupFile" "$folder"
done

echo "Finished running - $date"; echo
