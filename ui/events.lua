minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mail:inbox" and formname ~= "mail:sent" and formname ~= "mail:drafts" then
        return
    end

    local name = player:get_player_name()

    -- split inbox and sent msgs for different tests
    local entry = mail.get_storage_entry(name)

    local messagesInboxUnAnalyzed = entry.inbox
    local messagesOutBoxUnAnalyzed = entry.outbox
    local messagesDrafts = entry.drafts

    -- filter inbox/outbox messages

    local filter = fields.filter
    if not filter then
        filter = ""
    end

    local messagesInboxFiltered = mail.filter_messages(messagesInboxUnAnalyzed, filter)
    local messagesOutboxFiltered = mail.filter_messages(messagesOutBoxUnAnalyzed, filter)

    -- then sort them

    local sortfield = tostring(fields.sortfield)
    local sortdirection = tostring(fields.sortdirection)
    if not sortfield or sortfield == "" or sortfield == "0" then
        sortfield = "3"
    end
    if not sortdirection or sortdirection == "" or sortdirection == "0" then
        sortdirection = "1"
    end

    local messagesInbox = mail.sort_messages(messagesInboxFiltered, sortfield, sortdirection, filter)
    local messagesSent = mail.sort_messages(messagesOutboxFiltered, sortfield, sortdirection, filter)

    if fields.inbox then -- inbox table
        local evt = minetest.explode_table_event(fields.inbox)
        mail.selected_idxs.inbox[name] = evt.row - 1
        if evt.type == "DCL" and messagesInbox[mail.selected_idxs.inbox[name]] then
            mail.show_message(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        end
        return true
    end

    if fields.sent then -- sent table
        local evt = minetest.explode_table_event(fields.sent)
        mail.selected_idxs.sent[name] = evt.row - 1
        if evt.type == "DCL" and messagesSent[mail.selected_idxs.sent[name]] then
            mail.show_message(name, messagesSent[mail.selected_idxs.sent[name]].id)
        end
        return true
    end

    if fields.drafts then -- drafts table
        local evt = minetest.explode_table_event(fields.drafts)
        mail.selected_idxs.drafts[name] = evt.row - 1
        if evt.type == "DCL" and messagesDrafts[mail.selected_idxs.drafts[name]] then
            mail.show_compose(name,
            messagesDrafts[mail.selected_idxs.drafts[name]].to,
            messagesDrafts[mail.selected_idxs.drafts[name]].subject,
            messagesDrafts[mail.selected_idxs.drafts[name]].body,
            messagesDrafts[mail.selected_idxs.drafts[name]].cc,
            messagesDrafts[mail.selected_idxs.drafts[name]].bcc,
            messagesDrafts[mail.selected_idxs.drafts[name]].id
            )
        end
        return true
    end

    if fields.boxtab == "1" then
        mail.selected_idxs.boxtab[name] = 1
        mail.show_inbox(name, sortfield, sortdirection, filter)

    elseif fields.boxtab == "2" then
        mail.selected_idxs.boxtab[name] = 2
        mail.show_sent(name, sortfield, sortdirection, filter)

    elseif fields.boxtab == "3" then
        mail.selected_idxs.boxtab[name] = 3
        mail.show_drafts(name)

    elseif fields.read then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then -- inbox table
            mail.show_message(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then -- sent table
            mail.show_message(name, messagesSent[mail.selected_idxs.sent[name]].id)
        end

    elseif fields.edit then
        if formname == "mail:drafts" and messagesDrafts[mail.selected_idxs.drafts[name]] then
            mail.show_compose(name,
            messagesDrafts[mail.selected_idxs.drafts[name]].to,
            messagesDrafts[mail.selected_idxs.drafts[name]].subject,
            messagesDrafts[mail.selected_idxs.drafts[name]].body,
            messagesDrafts[mail.selected_idxs.drafts[name]].cc,
            messagesDrafts[mail.selected_idxs.drafts[name]].bcc,
            messagesDrafts[mail.selected_idxs.drafts[name]].id
            )
        end

    elseif fields.delete then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then -- inbox table
            mail.delete_mail(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then -- sent table
            mail.delete_mail(name, messagesSent[mail.selected_idxs.sent[name]].id)
        elseif formname == "mail:drafts" and messagesDrafts[mail.selected_idxs.drafts[name]] then -- drafts table
            mail.delete_mail(name, messagesDrafts[mail.selected_idxs.drafts[name]].id)
        end

        mail.show_mail_menu(name, sortfield, sortdirection, filter)

    elseif fields.reply then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            local message = messagesInbox[mail.selected_idxs.inbox[name]]
            mail.reply(name, message)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            local message = messagesSent[mail.selected_idxs.sent[name]]
            mail.reply(name, message)
        end

    elseif fields.replyall then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            local message = messagesInbox[mail.selected_idxs.inbox[name]]
            mail.replyall(name, message)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            local message = messagesSent[mail.selected_idxs.sent[name]]
            mail.replyall(name, message)
        end

    elseif fields.forward then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            local message = messagesInbox[mail.selected_idxs.inbox[name]]
            mail.forward(name, message)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            local message = messagesSent[mail.selected_idxs.sent[name]]
            mail.forward(name, message)
        end

    elseif fields.markread then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            mail.mark_read(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            mail.mark_read(name, messagesSent[mail.selected_idxs.sent[name]].id)
        end

        mail.show_mail_menu(name, sortfield, sortdirection, filter)

    elseif fields.markunread then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            mail.mark_unread(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            mail.mark_unread(name, messagesSent[mail.selected_idxs.sent[name]].id)
        end

        mail.show_mail_menu(name, sortfield, sortdirection, filter)

    elseif fields.new then
        mail.show_compose(name)

    elseif fields.contacts then
        mail.show_contacts(name)

    elseif fields.maillists then
        mail.show_maillists(name)

    elseif fields.about then
        mail.show_about(name)

    elseif fields.sortfield or fields.sortdirection or fields.filter then
        mail.show_mail_menu(name, sortfield, sortdirection, filter)
    end

    return true
end)
