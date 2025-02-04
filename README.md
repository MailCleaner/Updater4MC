# Updater4MC

This is the update orchestration utility for [MailCleaner-Next](https://github.com/MailCleaner/MailCleaner-Next), the upcoming release of [MailCleaner](https://github.com/MailCleaner/MailCleaner). Your stable appliance may still be pointed at the repository, but it should be automatically configured to use the [Updater4MC8](https://github.com/MailCleaner/Updater4MC8) repository by [the first update](https://github.com/MailCleaner/Updater4MC/blob/master/updates/00_rebase_jessie.update) in this one.

## Usage

This script is run automatically on a nightly basis, and additionally as directed for Enterprise Edition out-of-schedule updates. To see when your updates are schedules, you can run `crontab -l` as the `root` user.

Normally, you should not need to use this utility at all. If you find that your machine is behind on updates, you can simply check the logs for the last attempt:

```
less /var/mailcleaner/log/mailcleaner/updater4mc.log
```

Depending on the time your script is set to run and when you check the log, it is likely that the log will have been rotated. In this case, add the suffix `.0` to the above path. Older days updates go on to be compressed with suffixes counting up from `.1.gz` and can be viewed like `zcat /var/mailcleaner/log/mailcleaner/updater4mc.log.1.gz | less`.

If you would like to run the update script manually, you can do so with:

```
/roo/Updater4MC/updater4mc.sh
```

## Summary

On a basic level, this tool does a few things:

* It pull changes from this repository when it starts up to see if there are any system updates pending.

* It pull the latest changes from [the MailCleaner repository](https://github.com/MailCleaner/MailCleaner) to see if there are any application updates pending.

* It will attempt to execute any pending system update script from the `/updates` directory of this repository. These are updates which cannot be accomplished via the Git repository of the application (eg. installing package updates).

* If there was either type of update, it will force the restart of system services.

* Version and patch numbers will be written to `etc/mailcleaner/version.def` within the MailCleaner application repository which will be used to display the current version number in the WebUI and SMTP banner.
