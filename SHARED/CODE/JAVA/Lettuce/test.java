package connection_test;
import io.lettuce.core.*;
import io.lettuce.core.api.StatefulRedisConnection;
import io.lettuce.core.api.sync.RedisCommands;

public class ConnectBasicTest {
    public void connectBasic() {
        RedisURI uri = RedisURI.Builder
                .redis("redis-12000.lscheffer-zd134514.primary.cs.redislabs.com", 12000)
                .build();
        RedisClient client = RedisClient.create(uri);
        client.setOptions(ClientOptions.builder()
                       .pingBeforeActivateConnection(true)
                       .build());
        StatefulRedisConnection<String, String> connection = client.connect();
        RedisCommands<String, String> commands = connection.sync();
        commands.set("foo", "bar");
        commands.set("bar", "foo");
        String result;

        for (int i = 0; i < 100; i++){
            try {
                result = commands.get("foo");
                System.out.println(result); // >>> bar
                result = commands.get("bar");
                System.out.println(result); 
            } catch (RedisConnectionException e) {
                System.out.println(e.toString());
            }
            try {
                Thread.sleep(10000);
            } catch (InterruptedException e) {
                System.out.println(e.toString());
            }
        }
        connection.close();
        client.shutdown();
    }
}


// bar
// foo
// Apr 11, 2025 3:12:22 P.M. io.lettuce.core.protocol.ConnectionWatchdog run
// INFO: Reconnecting, last destination was redis-12000.lscheffer-zd134514.primary.cs.redislabs.com/100.106.236.86:12000
// Apr 11, 2025 3:12:22 P.M. io.lettuce.core.protocol.ReconnectionHandler lambda$null$3
// INFO: Reconnected to redis-12000.lscheffer-zd134514.primary.cs.redislabs.com/<unresolved>:12000
// bar
// foo