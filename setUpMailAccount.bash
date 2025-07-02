#!/usr/bin/env/ bash

SIGINTdefHandler ()
{
    printf "\nSIGINT sent to %s. Exiting...\n" \
           "${0##*/}" \
           2>&1

    trap - SIGINT

    kill -INT "$$"
}

getMailAccount ()
{
    local -n -- _mailAccounts=$1

    mapfile -t _mailAccounts < <(

            plesk db \
                  --skip-column-names \
                  --execute="select concat(m.mail_name,'@',d.name) as email from mail as m left join domains as d on m.dom_id=d.id"
    )
}

setMailAccount ()
{
    local -a -- _mAccounts=()
    local -- _mailAccount=''

    getMailAccount _mAccounts

    for _mailAccount in "${_mAccounts[@]}"
    do
        (
            plesk bin mail --update "$_mailAccount" -mailbox true -mbox_quota 6000M -antivirus inout

            plesk bin spamassassin --update "$_mailAccount" -status true -personal-conf true  -modify-subj true -modify-subj-text "SPAM Score: SCORE :"

        ) &

    done

    wait
}

trap SIGINTdefHandler SIGINT

setMailAccount
