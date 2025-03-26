module versioning::counter {

    // 1. Track the current version of the module
    const VERSION: u64 = 1;

    public struct Counter has key {
        id: UID,
        // 2. Track the current version of the shared object
        version: u64,
        // 3. Associate the `Counter` with its `AdminCap`
        admin: ID,
        value: u64,
    }

    public struct AdminCap has key {
        id: UID,
    }

    /// Calling functions from the wrong package version
    const EWrongVersion: u64 = 1;

    fun init(ctx: &mut TxContext) {
        let admin = AdminCap {
            id: object::new(ctx),
        };

        transfer::share_object(Counter {
            id: object::new(ctx),
            version: VERSION,
            admin: object::id(&admin),
            value: 0,
        });

        transfer::transfer(admin, tx_context::sender(ctx));
    }

    public fun increment(c: &mut Counter) {
        // 4. Guard the entry of all functions that access the shared object
        //    with a version check.
        assert!(c.version == VERSION, EWrongVersion);
        c.value = c.value + 1;
    }
}