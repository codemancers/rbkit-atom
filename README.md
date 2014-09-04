# rbkit-atom

A GUI client for rbkit built using atom-shell

## Development

### Setup

- Download [atom-shell](https://github.com/atom/atom-shell/releases) and extract it somewhere
- Create an alias `atom-shell` that points to the atom-shell [executable](https://github.com/atom/atom-shell/blob/master/docs/tutorial/quick-start.md#run-your-app) *(optional)*
- Install [atom-package-manager](https://www.npmjs.org/package/atom-package-manager) `npm install -g atom-package-manager`

### Run

- `cd` into the `rbkit-atom` directory
- Run `apm install .`
- Run `atom-shell .`

### Build

- `cd` into the `build` directory
- Run `npm install`
- Run `gulp` to compile CoffeeScript files on the fly

### Rbkit client command messaging

For now, the command messaging system is not yet available, so, use
either Ruby (`rbkit/experiments/rbkit_command_test.rb`) or follow the
following instructions:

1. Install the `zmq` node library using `npm install -g zmq`
2. open a `node` repl and type the following commands one by one:

```javascript
var zmq = require('zmq');
var sock = zmq.socket('req');

sock.connect('tcp://127.0.0.1:5556');
sock.send('start_memory_profile');

console.log('sent message to start profiling'); /* optional */

/* That should start the profiling engine. The data would be available
   at 127.0.0.1:5555

   The following lines are optional
 */
sock.on('message', function(response) {
  console.log('got response');
});
```
