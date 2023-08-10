print('InnoDB Cluster set up\n');
print('==================================\n');

// var dbPass = shell.prompt('Please enter a password for the MySQL root account: ', {
//     type: "password"
// });

const user = 'devops';
const server = "devops@localhost:3306";
const dbPass = "yU0B14NC1PdE";
const key = { password: dbPass };

function sleep(milliseconds) {
    const date = Date.now();
    let currentDate = null;
    do {
        currentDate = Date.now();
    } while (currentDate - date < milliseconds);
}


try {
    print("try-01")
    var chk2 = dba.configureInstance(server, {password:dbPass, interactive: false,restart: true})
    sleep(15000); // source: https://www.sitepoint.com/delay-sleep-pause-wait/
    print(`chk2:${chk2}`)
    print('\nChecking instance...');
    print("try-02")
    var chk = dba.checkInstanceConfiguration(server, key);
    if (serverIsReady(chk)) {
        print('server is ready')
    } else {
        // print(chk);
        print("try-03")
        // chk.config_errors.length
        if ('config_errors' in chk) {
            print("try-04")
            print("Number of Errors:")
            print(chk.config_errors.length);
            print("try-05")
            const sess = mysql.getClassicSession(server, dbPass);
            // var chk2 = dba.configureInstance(server, {password:dbPass, interactive: false,restart: true})
            // sleep(5000); // source: https://www.sitepoint.com/delay-sleep-pause-wait/
            // print(`chk2:${chk2}`)
            print("try-06")
            shell.setSession(sess);
            print("try-07")
            // chk.config_errors.forEach((item, i) => {
            //     print(`forEachloop-${i}`)
            //     const action = item.action;
            //     const current = item.current;
            //     const option = item.option;
            //     const required = item.required;
            //     print(`Trying to correct the config: ${option}`)
            //     var resultSet = sess.runSql(`SET PERSIST ${option} = '${required}';`);
            //     var row = resultSet.fetchOneObject();
            //     print("resultSet:")
            //     print(row);
            // });

            for (i = 0; i < chk.config_errors.length; i++) {
                // console.log(numbers[i]);
                print(`for-loop-${i}`)
                let item = chk.config_errors[i];
                const action = item.action;
                const current = item.current;
                const option = item.option;
                let required = item.required;
                print(`required:${required}`)
                if (option === 'gtid_mode') {
                    enableGtid(sess);
                } else {
                    if (required === '<unique ID>') {
                        print(`for-if-01`)
                        required = Math.floor(Math.random() * 9999) + 1111;
                        print(`for-if-02`)
                    }
                    print(`Trying to correct the config: ${option} with value=${required}`)
                    sess.runSql(`SET PERSIST ${option} = ${required};`);
                }

            }

            print("Reruning the checkInstance again:");
            chk = dba.checkInstanceConfiguration(server, key);
            print(chk)
            if ('status' in chk) {
                if (chk.status === 'ok') {
                    print('******************WE ARE GOOD TO INNODB CLUSTER*****************')
                }
            }
        }
    }



} catch (e) {
    print('\nThe InnoDB Instance is not ready.\n\nError Message: ' +
        +e.message + '\n');
}

function configureItem(item) {
    print("configureItem_01")
    const action = item.action;
    const current = item.current;
    const option = item.option;
    const required = item.required;
    print(`Trying to correct the config: ${option}`)
    var resultSet = sess.runSql(`SET PERSIST ${option} = '${required}';`);
    var row = resultSet.fetchOneObject();
    print("resultSet:")
    print(row);
}

// Ref: https://dev.mysql.com/doc/refman/5.7/en/replication-mode-change-online-enable-gtids.html
function enableGtid(sess) {
    // To enable GTID transactions:
    // 1. On each server, execute:
    print(`enableGtid-01`)
    sess.runSql(`SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = WARN;`);
    // Let the server run for a while with your normal workload and monitor the logs. If this step causes any warnings in the log, adjust your application so that it only uses GTID-compatible features and does not generate any warnings.
    // Important:
    // This is the first important step. You must ensure that no warnings are being generated in the error logs before going to the next step.

    // 2. On each server, execute:
    print(`enableGtid-02`)
    sess.runSql(`SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = ON;`);

    // 3. On each server, execute:
    print(`enableGtid-03`)
    sess.runSql(`SET @@GLOBAL.GTID_MODE = OFF_PERMISSIVE;`);
    // It does not matter which server executes this statement first, but it is important that all servers complete this step before any server begins the next step.

    // 4. On each server, execute:
    print(`enableGtid-04`)
    sess.runSql(`SET @@GLOBAL.GTID_MODE = ON_PERMISSIVE;`);
    // It does not matter which server executes this statement first.

    // 5. On each server, wait until the status variable ONGOING_ANONYMOUS_TRANSACTION_COUNT is zero. This can be checked using:
    print(`enableGtid-05`)
    // sess.runSql(`SHOW STATUS LIKE 'ONGOING_ANONYMOUS_TRANSACTION_COUNT';`);
    var resultSet = sess.runSql(`SHOW STATUS LIKE 'ONGOING_ANONYMOUS_TRANSACTION_COUNT';`);
    var row = resultSet.fetchOneObject();
    print("resultSet:")
    print(row);

    // Note:
    // On a replica, it is theoretically possible that this shows zero and then nonzero again. This is not a problem, it suffices that it shows zero once.
    // Wait for all transactions generated up to step 5 to replicate to all servers. You can do this without stopping updates: the only important thing is that all anonymous transactions get replicated.
    // See Section 16.1.4.4, “Verifying Replication of Anonymous Transactions” for one method of checking that all anonymous transactions have replicated to all servers.
    // If you use binary logs for anything other than replication, for example point in time backup and restore, wait until you do not need the old binary logs having transactions without GTIDs.
    // For instance, after step 6 has completed, you can execute FLUSH LOGS on the server where you are taking backups. Then either explicitly take a backup or wait for the next iteration of any periodic backup routine you may have set up.
    // Ideally, wait for the server to purge all binary logs that existed when step 6 was completed. Also wait for any backup taken before step 6 to expire.
    // Important:
    // This is the second important point. It is vital to understand that binary logs containing anonymous transactions, without GTIDs cannot be used after the next step. After this step, you must be sure that transactions without GTIDs do not exist anywhere in the topology.

    // 6. On each server, execute:
    print(`enableGtid-06`)
    if ('Value' in row) {
        print(`enableGtid-07`)
        if (row.Variable_name === 'Ongoing_anonymous_transaction_count' && row.Value === "0") {
            print(`enableGtid-08`)
            sess.runSql(`SET @@GLOBAL.GTID_MODE = ON;`);
            print(`enableGtid-09`)
        }
    }
    // 7. On each server, add gtid_mode=ON and enforce_gtid_consistency=ON to my.cnf. 
    // to implement with ansible
}

function serverIsReady(chk){
    let ret = false;
    if ('status' in chk) {
        if (chk.status === 'ok') {
            ret = true;
            print('******************WE ARE GOOD TO INNODB CLUSTER*****************')
        }
    } else {
        ret = false;
    }
    return ret;
}