# smartfollow

## Resources

- [node-twitter-api](https://github.com/reneraab/node-twitter-api)
- [twit](https://github.com/ttezel/twit)

## Application Stack

This environment is intended to be used in a modular way. Everything is a
Component and should work and be testable independently.

Generated with the
[Grail Generator](https://github.com/mustardamus/generator-grail) for
[Yeoman](http://yeoman.io/).

### Tasking

Task management is done with [Gulp](http://gulpjs.com/), so your project is
easily extendible. This stack already uses some
[Gulp Plugins](http://gulpjs.com/plugins/):

  - [gulp-util](https://github.com/gulpjs/gulp-util) - `noop()` and logging
  - [gulp-concat](https://github.com/wearefractal/gulp-concat) - To concat files
    together
  - [gulp-imagemin](https://github.com/sindresorhus/gulp-imagemin) - Wrapper for
    imagemin, to optimize images
  - [gulp-stylus](https://github.com/stevelacy/gulp-stylus) - Wrapper for
    Stylus, to compile to CSS
  - [gulp-autoprefixer](https://github.com/sindresorhus/gulp-autoprefixer) -
    Wrapper for Autoprefixer, to vendor prefix CSS3
  - [gulp-csso](https://github.com/ben-eb/gulp-csso) - Wrapper for CSSO, to
    minify CSS
  - [gulp-uglify](https://github.com/terinjokes/gulp-uglify) - Wrapper for
    Uglify, to minify JavaScript
  - [gulp-spawn-mocha](https://github.com/KenPowers/gulp-spawn-mocha) - To run
    tests with Mocha
  - [gulp-bump](https://github.com/stevelacy/gulp-bump) - To bump up the version
    number in `package.json`

### Scripting

Codes are written mainly in [CoffeeScript](http://coffeescript.org/) and bundled
together with [Browserify](http://browserify.org/). Out of the box it comes with
some [transforms](https://www.npmjs.org/browse/keyword/browserify-transform) for
Browserify:

  - [coffeeify](https://github.com/jnordberg/coffeeify) - To compile
    CoffeeScript to JavaScript
  - [html2js-browserify](https://github.com/featurist/html2js-browserify) - To
    compile HTML templates to JavaScript strings
  - [debowerify](https://github.com/eugeneware/debowerify) - To use Bower
    components in Browserify
  - [deamdify](https://github.com/jaredhanson/deamdify) - To use AMD modules in
    Browserify

### Styling

Styles are written mainly in [Stylus](https://learnboost.github.io/stylus/).

### Watching

Watching for file changes is crucial if you pre-compile the Scripts and Styles.
For the Script re-bundle [Watchify](https://github.com/substack/watchify) is in
charge.

Since the Styles are not in the JS bundle,
[Chokidar](https://github.com/paulmillr/chokidar) is used to watch and rebuild
them. `gulp.watch` isn't used here, since it does not pick up newly created
files.

For the rest of the files (HTML, Images) it uses
[gulp.watch](https://github.com/gulpjs/gulp/blob/master/docs/API.md#gulpwatchglob-opts-tasks).

### Serving

The generated and bundled files will be served with
[BrowserSync](http://www.browsersync.io/). That means the Application is
automatically reloaded if Scripts or Styles are changing.

### Testing

Component tests written in CoffeeScript, bundled by Browserify and run by
[Mocha](https://visionmedia.github.io/mocha/).


## Gulp Tasks

Source of all tasks is `./client` and destination is `./public`.

### `gulp html`

Copies the HTML Entry Point.

### `gulp fonts`

Copies fonts. This tasks copies the fonts of Font Awesome included by
Semantic-UI by default, but note that you need to run
[`yo grail:extend`](../../extend/templates/README.md), so the files are
available.

### `gulp stylus`

Bundles the Style Entry Point with Stylus. Also prefix CSS3 properties with
Autoprefixer.

### `gulp images`

Copies all images.

### `gulp browserify`

Bundles the Script Entry Point with Browserify. It executes several transforms:

  - coffeeify - transforms the CoffeeScript to JavaScript
  - html2js - transforms the HTML templates to JavaScript strings
  - debowerify - `require()` modules installed by Bower
  - deamdify - `require()` modules that are wrapped by AMD

### `gulp browserify-watch`

Watches files in the source directory and re-bundles the Script Entry Point.

### `gulp watch`

  - Run `browserify-watch`
  - Run `stylus` whenever a `./client/**/*.styl` changes
  - Run `images` whenever a file in `./client/images/*` changes
  - Run `html` whenever a `./client/*.html` changes

### `gulp server`

Starts a BrowserSync web server. Also starts the `watch` task. Whenever a file
in the source directory changes, the Script or Style Entry Point is re-bundled
and the browser reloaded. Styles are directly injected in the page without a
reload.

### `gulp test`

Bundles the Application Components and Tests together and run them in Mocha.

### `gulp test-watch`

Whenever a Application or Test file changes re-run the `test` Task.

### `gulp build`

Run `browserify`, `stylus`, `images` and `html`. `gulp` without a task name will
also run this task.

### `gulp production`

Run this task if you want to release the Application for the audience. Note that
you need to run `gulp build` before!

  - Run `browserify` and minify JS with Uglify
  - Run `stylus` and minify CSS with CSSO
  - Run `images` and minify them with Imagemin

### `gulp bump`

Bumps up the version number in `package.json`.


## Application Structure

This is a one page application. It has three different entry points.

### HTML entry point - `./client/index.html`

This is your typical `index.html` page which is loaded first. It has references
to the Script and Stylesheet entry points.

Markup that is initially loaded (the Layout), is stored here.

### Script entry point - `./client/index.coffee`

Here you initialize components. Since the Script Bundle is packed
with Browserify you can simply `require()` the components you want to use:

    Post = require('./components/post')
    post = new Post

It is recommended to `require()` third party dependencies in the components
rather than having globals. But if you install the libraries with Bower, the
respective global will be defined without declaring it:

    require('jQuery') # $ is globally defined

However, if you declare it this way your tests may brake because they are run in
Node.js by default (todo: run them in [PhantomJS](http://phantomjs.org/)).

### Stylesheet entry point - `./client/index.styl`

Here you initialize stylesheets, third party stylesheets and variables. Stylus
will take care of the bundling, so all you need is `@import`.

For third party styles, include a `.css` file in a relative path:

    @import '../bower_components/normalize-css/normalize.css'

To import a module style:

    @import './components/post/style'

Note that you don't need to include every single Component style since by
default every `style.styl` from the `./client/components` is imported.

If you define variables, you can use them in your imported components:

    backgroundColor = #eee

And in `./client/components/post/style.styl`:

    @import './colors'
    body
      background: backgroundColor


## Component Structure

A component can have three different things: A Script, a Template, and a Style.
All three are optional, since it's in your hands how you initialize each part of
a component.

### Naming Convention

Again, you can name them like you want, really. I recommend this structure:

    ./client/components/[component-name]
      /index.coffee
      /template.html
      /style.styl

Why this naming? You can leave out the file extension when `require()`ing them
(which would not possible if every component-part has the same name):

    post     = require('../post')    # respectively index.coffee
    template = require('./template') # respectively template.html

With the `component-name` as identifier, and `index.coffee` as Script entry
point, you describe with the filename which part of the component you want to
`require()`: `post` (respectively `index.coffee`), `post/template` and
`post/style`.

A disadvantage of this method is that it might not be clear if you are editing
multiple components in your editor. But you should work on one component at a
time anyway.

### Testing a Component

You can and should test your Components. Just like the Application Script Entry
Point, the Tests have a Entry Point too in `./test/client/index.coffee`. There
you `require()` the components and tests:

    postTest = require('./components/post')

Then just create the component test a file named like the component:
`./test/client/components/post.coffee`:

    should = require('should')
    Post   = require('../../../client/components/post')
    post   = new Post

    describe 'Post Component', ->
      it 'should have the correct template', ->
        post.template.should.equal 'testing'

To bundle the Application and Tests, and run it in Mocha:

    gulp test

To automatically re-run the `test` task whenever Application or Test files
change, run:

    gulp test-watch


## Workflow

### Using third party Scripts

Third party libraries can be either installed with NPM or Bower. In the end, you
just need to `require()` the library.

#### NPM

    npm install moment --save

#### Bower

    bower install zepto --save

Then you can require the libraries wherever you want (usually in the Component):

    $      = require('zepto')
    moment = require('moment')

#### Manually

In the rare case you can't install a library from NPM or Bower, you also can
`require()` the `.js` from everywhere:

    lib = require('../path/to/lib.js')

### Using third party Styles

Install it via Bower:

    bower install foundation --save

And `@import` it in `./client/index.styl`:

    @import '../bower_components/foundation/css/foundation.css'


## Client Extensions

### [Vue.js](http://vuejs.org/guide/)

#### `$root` Component

The entry point for the [Vue.js](http://vuejs.org/guide/) application is
`./client/components/$root/index.coffee`. This component is initialized in a
`<div id="app"/>` container on the `<body>` of the `./client/index.html` page,
by the Script entry point `./client/index.coffee`.

Normally you should only touch `./client/index.coffee` to add new bootstrapping
functionality or glogbally defined libraries.

Use `./client/components/$root/data.coffee` to define data that are accessible
by every component via `@$root.$data`.

If you need to trigger events in components that are not related you should use
`@$root.$dispatch()` and `@$root.$on()`.

#### `$layout` Component

Components should be
[defined and initialized](http://vuejs.org/guide/composition.html) in
`./client/components/$layout/index.coffee` and
`./client/components/$layout/template.html`.
Global styles should go in `./client/components/$layout/style.styl`.

#### `$router` Component

The `$router` Component uses [Director](https://github.com/flatiron/director)
and sets `@$root.$data.currentPage` whenever the page changes. The `/#/` route
will become `home`. `/#/about`, for example, will become `about`.

Define your custom routes in `./client/components/$router/index.coffee`.

#### `page-home` Component

This acts as a example component. It is defined and initialized in the
`$layout` component, and is loaded whenever
`@$root.$data.currentPage === 'home'`.

It's recommended to keep the `page-*` convention when you create other
top-level pages.

### [jQuery](https://jquery.com/)

Ideally, you would not need [jQuery](https://jquery.com/) in combination with
Vue.js. But face it, you learned it for years and it is the fastest way to
interact with the DOM. You can use thousands of jQuery Plugins out of the box.
Also does the Semantic-UI Plugins rely on jQuery.

Get your app running as fast as possible, adjust, refactor and speed up later.

### [Semantic-UI](http://semantic-ui.com/)

[Semantic-UI](http://semantic-ui.com/) stylesheets are included in
`./client/index.styl` separately. Turn them on and off by commenting them in or
out.

Semantic-UI also offers a bunch of jQuery Plugins. They are included separately
in `./client/index.coffee`. Just like the stylesheets, turn them on and off as
needed.

Note that Semantic-UI includes
[Font Awesome](http://semantic-ui.com/elements/icon.html) icons.

### [Socket.io](http://socket.io/docs/)

If you are running a Socket.io Server (`yo grail:server`, for starters) you can
use [Socket.io](http://socket.io/docs/). If the web application is serving from
`gulp server` (port `7891`), the global `window.io` object is stubbed and don't
do anything other than printing a warning to `console.log`.

### [FastClick](https://github.com/ftlabs/fastclick)

[FastClick](https://github.com/ftlabs/fastclick) library for eliminating the
300ms delay between a physical tap and the firing of a `click` event on mobile
browsers.

### [Cheerio](https://github.com/cheeriojs/cheerio)

[Cheerio](https://github.com/cheeriojs/cheerio) is a jQuery like helper for
Node.js. This makes running tests on HTML code pretty easy.

### [Should.js](https://github.com/visionmedia/should.js/)

[Should.js](https://github.com/visionmedia/should.js/) is a assertion library
that reads better than the `assert` functions that come with Node.js.


## Create a Vue.js Component

Use the command `yo grail:create` to create a component in
`./client/components`. You can choose which parts you want to create: Script,
Template, Style and/or Test.

Then you just `require()` the Script or Template, `@import()` the Style wherever
it is needed. Component names should be all lowercase and divided by a dash `-`
if multiple words.


## Server Extensions

### [Express.js](http://expressjs.com/)

#### Entry Point

Bootstrapping is happening in `./server/index.coffee`. You usually don't need to
touch this file. If you want to extend the functionality of the Server you
should use the `./server/initialize` directory (see below).

#### Configuration

All configuration goes in `./server/config.coffee` and is passed along to
initilization and routes (see examples below).

The default port of the Server is `7799`. The default static directory is
`./public` - generated by `gulp build` (you want to run `gulp watch` to pick up
file changes while developing).

#### Initilization

The Entry Point will load and initialize all files that are in
`./server/initialize`. For example `./server/initialize/app.coffee` will
initialize the JSON Body Parser and the static directory:

    module.exports = (config, helpers, io, models) ->
      @use express.static(config.server.publicDir)
      @use bodyParser.json()

The context (`@`/`this`) is the `express()` app that is initialized in the
Entry Point.

#### Routes

Pretty much the same as the Initilization files, the Entry Point will load all
files in `./server/routes`. Split the files depending on your resources and
define all related routes in them. For example `./server/routes/app.coffee`:

    module.exports = (config, helpers, io, models) ->
      @get '/hello/:name', (req, res) ->
        res.json { str: helpers.app.sayHello(req.params.name) }

      @post '/whatever, (req, res) ->

#### Helpers

Helpers are commonly used functions that can be shared between initilization,
routes and models. They are passed to the exported function as seen in the
examples above.

All helpers will be loaded from the directory `./server/helpers`.

The name of the file is important, as it's used to populate the `helpers`
object. For example `./server/helpers/app.coffee`:

    module.exports =
      sayHello: (toName) ->
        "Hello #{toName}!"

Will be available as `helpers.app.sayHello()`. A file
`./server/helpers/string.coffee` would be available as `helpers.string.*`.

Helpers should only work with raw data and should not interact with the Express
app or models in any way.

#### Start Server for Development

When in development environment, use `npm start`. This will start a
[Forever](https://github.com/foreverjs/forever) process that still logs to
`STDOUT`. It will watch the `./server` directory for any file changes and
restarts the server.

You'd still need to reload the browser manually. Unfortunately I haven't found
a reliable solution for this yet.

### [Lodash](https://lodash.com/docs)

[Lodash](https://lodash.com/docs) is already installed for convinience. Just do
`_ = require('lodash')` anywhere and hack away.

### [Socket.io](http://socket.io/docs/)

A [Socket.io](http://socket.io/docs/) Server is automatically initialized on
the Entry Point and is served at the same port as the HTTP Server. The `io`
object is passed to the initilization and the routes, see the examples above.

### [MongoDB](https://www.mongodb.org/) with [Mongoose](http://mongoosejs.com/docs/guide.html) (Optional)

You can define [Mongoose](http://mongoosejs.com/docs/guide.html) models in
`./server/models`. For example `./server/models/count.coffee`:

    module.exports = (helpers) ->
      @model 'Count',
        visits: Number

The context (`@`/`this`) is the `mongoose` object defined in the Entry Point.
Just make sure that the `mongoose.model` definition is returned.

Models are initialized in the `models` object and passed to initilization as
well as routes. Just as the `helpers` it is important how you name the files, as
it is the key the model is initialized with. The example above would be located
at `models.count`. A usage example would be:

    module.exports = (config, helpers, models) ->
      @get '/count', (req, res) ->
        models.count.findOne {}, (err, count) ->
          unless count
            count = new models.count({ visits: 0 })

          count.visits += 1
          count.save()

          res.json count.toJSON()

The Server Entry Point only tries to connect to the database defined in the
config file if there are any model files. So you might use the Server without
any database connection by leaving the `./server/models` directory empty or
remove it altogether.


## Registration and Authentication

A boilerplate for basic user registration and authentication. This is based on
`yo grail:extend` and `yo grail:server`.

Please note that this is a boilerplate to get started. In the future you likely
want to implement more security measures like brute-force protection,
password-strength and e-mail confirmation.

### Backend

This is a custom implementation with
[jsonwebtoken](https://github.com/auth0/node-jsonwebtoken) and
[bcrypt](https://github.com/ncb000gt/node.bcrypt.js).

#### `POST /register`

On this route a user can register with a username and a password. It is checked
if the user already exist.

#### `POST /login`

On this route a user can login and generate a token that is delivered to the
frontend and acts as a session. Logging out just happens on the frontend by
destroying the token.

#### `GET /users/me`

This route will return the information of the current logged in user.

#### `POST /users/me`

On this route a user can update her information: username, e-mail and password.
It is checked if the username and e-mail already exists. To change the password
the user must provide the current password.

#### `auth` Middleware

You can protect routes by the authentication middleware like this:

    module.exports = (config, helpers, io, models) ->
      auth = require('../middleware/auth')(config, helpers)

      @get '/inside', auth, (req, res) ->
        res.json req.user

If the authentication fails, a 403 code is delivered to the client and the
defined callback is never happening. If the authentication succeeds, `req.user`
is populated with the information for the current user. Note that this is not
the User Model. If you'd like to get the model you can find it by
`req.user._id`.

### Frontend

Requests are happening exclusively via AJAX.

#### `/#/register`

On this page is the register form. Username, password and password check. With
form validation on the client-side. Once a user is registered he is already
logged in because the server returns the token.

#### `/#/login`

On this page a user can login with username and password. If successfully logged
in, the server will return the token.

#### `/#/user`

On this page a user can see and edit her information. If the e-mail is missing,
a extra message is displayed saying to provide a e-mail. Form validation is
happening on the client-side. To change the password the current password must
be provided.

#### Determine if a user is logged in

Once a user is successfully logged in (either by registering, logging in or
already set token), there are multiple data available on the `@$root.$data`
object:

    loggedIn    : true/false   # a simple boolean stating if the user is logged in
    currentUser : null/object  # if logged in, the user information (except password) is stored here
    currentToken: null/string  # the token of the current logged in user
