#!/usr/bin/env bash

setMailAccount ()
{
    local -- _mailAccount=$1

    plesk bin mail --update "$_mailAccount" -mailbox true -mbox_quota 6000M -antivirus inout

    plesk bin spamassassin --update "$_mailAccount" -status true -personal-conf true  -modify-subj true -modify-subj-text "SPAM Score: SCORE :"
}

setMailAccount "${NEW_MAILNAME}"
