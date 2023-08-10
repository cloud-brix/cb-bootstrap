
// Ref: https://www.percona.com/blog/setting-up-an-innodb-cluster-with-a-few-lines-of-code/
print('InnoDB cluster set up\n');
print('==================================\n');
print('Setting up a Percona Server for MySQL - InnoDB cluster.\n\n');

// var dbPass = shell.prompt('Please enter the password for the MySQL root account: ', {
//     type: "password"
// });
// var numNodes = shell.prompt('Please enter the number of data nodes: ');




const dbUser = 'devops';
const dbPass = 'yU0B14NC1PdE';
const clusterName = 'cdCluster';
const port = 3306;
const key = { password: dbPass };


// const dbHosts = [
//     "192.168.1.171",
//     "192.168.1.172",
//     "192.168.1.173",
//     "192.168.1.174",
//     "192.168.1.175"
// ];

const dbHosts = [
    "240.93.0.172",
    "240.94.0.155",
    "240.95.0.221"
];

// for (let i = 1; i <= numNodes; i++) {
//     var hostName = shell.prompt('Please enter the hostname for node' + i + ': ');
//     dbHosts.push(hostName);
// }

function sleep(milliseconds) {
    const date = Date.now();
    let currentDate = null;
    do {
        currentDate = Date.now();
    } while (currentDate - date < milliseconds);
}

print('\nNumber of Hosts: ' + dbHosts.length + '\n');
print('\nList of hosts:\n');
for (let s = 0; s < dbHosts.length; s++) {
    print('Host: ' + dbHosts[s] + '\n');
}

function setupCluster() {
    print('\nConfiguring the instances.');
    for (let n = 0; n < dbHosts.length; n++) {
        print('\n=> ');
        dba.configureInstance(`${dbUser}:${dbPass}@${dbHosts[n]}:${port}`
        // , {
        //     clusterAdmin: `devops@${dbHosts[n]}`,
        //     clusterAdminPassword: dbPass,
        //     password: dbPass,
        //     interactive: false,
        //     restart: true
        // }
        );
    }
    print('\nConfiguring Instances completed.\n\n');

    sleep(10000); // source: https://www.sitepoint.com/delay-sleep-pause-wait/

    print('Setting up InnoDB Cluster.\n\n');
    shell.connect({
        user: dbUser,
        password: dbPass,
        host: dbHosts[1],
        port: 3306
    });

    shell.connect({
        user: dbUser,
        password: dbPass,
        host: dbHosts[2],
        port: 3306
    });

    shell.connect({
        user: dbUser,
        password: dbPass,
        host: dbHosts[0],
        port: 3306
    });

    sleep(2000);

    var cluster = dba.createCluster(clusterName);

    sleep(2000);

    print('Adding instances to the cluster.\n');

    for (let i = 1; i < dbHosts.length; i++) {
        print('\n=> ');
        cluster.addInstance(`${dbUser}@${dbHosts[i]}:${port}`, {
            password: dbPass,
            recoveryMethod: 'clone'
        });
        sleep(15000);
    }
    print('\nInstances successfully added to the cluster.\n');

}

try {
    setupCluster();

    print('\nInnoDB cluster deployed successfully.\n');
} catch (e) {
    print('\nThe InnoDB cluster could not be created.\n');
    print(JSON.stringify(e) + '\n');
}