#==========^==========#
    O365 Exchange Org Mailbox Health Report
#==========v==========#
User mailbox sizes (in % and GB); & User mailbox X% until full.
    1. Collects all mailbox email addresses. 
    2. Divides the mailboxes used size by the total mailbox size to get a 'percentage used',
        -Converts the strings into ONLY the numerical bytes to allow calculations.
    3. Targets mailboxes with resulting values of '0.95' (95%) usage and outputs their used, deleted, total, and archive enabled/disabled information into a variable.
    4. Pushes a custom email alert with their email address contianing the contents of that mailbox information variable:
        Ex email: 
            ===================
            ajones@assurancemortgage.com 
            Used: 92.67 GB (99,505,953,735 bytes)
            Deleted: 48.28 MB (50,624,861 bytes)
            Total: 100 GB (107,374,182,400 bytes)
            Archive Mailbox not enabled.
            ===================