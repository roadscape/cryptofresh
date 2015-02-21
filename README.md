# cryptofresh
Webstore accepting BitAsset payments.

### Refactoring in Progress!

### Getting Started

- config/database.yml.example
- config/unicorn.yml.example
- config/store.yml.example

        cashier_acct: cashier
        rpc_port: 9999
        rpc_user: user
        rpc_pass: pass
        admin_user:        # login for store manager
        admin_pass:        # pass for store manager
        secret_phrase:     # random pass, secures downloads

### Todo

- Check wallet is responding and blockchain is current. Disable the store otherwise.
- Change floats to BigDecimal
- Categories (enable STI on products table)
- "Refund" button
- Accept partial payments?
