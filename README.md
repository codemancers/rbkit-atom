### Installation of Atom Shell
Download and install the atom shell app from the [Github
page](https://github.com/atom/atom-shell/releases)

The package manager would install the app to `/Applications/Atom.app`.
For easier development cycle, alias (or symlink appropriately) the
following path to `atom-shell`:

    /Applications/Atom.app/Contents/MacOS/Atom'


Then, inside of an atom-shell project, to run the app, the command would
be:

    atom-shell .


### Rbkit Client Installation instructions:

1. Clone this repo
2. Ensure you're having node 0.11.13 and it's `npm`
3. Run `npm install -g atom-package-manager`
4. Run `apm install .` inside the `rbkit-atom` directory

Then run the command `atom-shell .`. This should start up the window.

### Rbkit client command messaging

For now, the command messaging system is not yet available, so, use
either Ruby (`rbkit/experiments/rbkit_command_test.rb`) of follow the
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

### Avoid

(For now, sqlite3 need not be installed)
To install sqlite3:

### Using gulp

For compiling Coffeescript files, there's a gulp task that's available.
To use it, follow these steps:

1. `cd` into `build` directory
2. Run `npm install`
3. Once the modules are installed, run `gulp`. The coffeescript
   compilation process keeps running in the background.

```bash
export npm_config_disturl=https://gh-contractor-zcbenz.s3.amazonaws.com/atom-shell/dist
export npm_config_target=0.11.13
export npm_config_arch=x64
HOME=~/.atom-shell-gyp npm install sqlite3
```
