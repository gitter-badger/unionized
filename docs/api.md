[&laquo; back to README](https://github.com/goodeggs/unionized)

# Unionized API

The `unionized` module exports an instance of the [`Factory`](#factory) class:

```javascript
var factory = require('unionized');
```

---------------------------

## `Factory`

`Factory` contains the following public methods:

Method                                         | Description
-----------------------------------------------|-------
[`factory.factory()`](#factoryfactory)         | Build a new factory as a child of the current factory
[`factory.create()`](#factorycreate)           | Create an object using this factory
[`factory.createAsync()`](#factorycreateasync) | Create an object using this factory, asynchronously

Additionally, every instance of `Factory` contains the following utility methods:

Method                                                 | Description
-------------------------------------------------------|-------
[`factory.array()`](#factoryarray)                     | Describe the contents of an array that a factory can create
[`factory.async()`](#factoryasync)                     | Define an asynchronous and dynamically-generated factory attribute
[`factory.enum()`](#factoryenum)                       | Define a list of options for a factory attribute
[`factory.mongooseFactory()`](#factorymongoosefactory) | Build a new factory out of a mongoose model

`Factory` is a subtype of [`Definition`](#definition) &mdash;
which means you can embed factories inside other factories. More on this later.

-----------------------

### `factory.factory()`

Build a new factory out of a [`Definition`](#definition). Returns another instance of [`Factory`](#factory).

#### Usage:

```javascript
var factory = parentFactory.factory(definition)
```

#### Example:

The most common type of [`Definition`](#definition) to use here is a [`DotNotationObjectDefinition`](#dotnotationobjectdefinition), which can be coerced from an `Object` like in the following example:

```javascript
var factory = require('unionized');
var blogFactory = factory.factory({
  title: 'How to make falafel'
  body: loremIpsumGenerator
  'metadata.tags': ['cooking', 'middle-eastern']
})
```

Once you have defined your `Factory`, you can call [`create()`](#factorycreate) or
[`createAsync()`](#factorycreateasync) on it to make it create an object, or
you can call `factory()` on it again to create a (generally more specific) variation on the [`Factory`](#factory) you
already have. For example:

```javascript
var blogByNatsumiFactory = blogFactory.factory({
  'metadata.author': 'Natsumi'
})
```

Now, creating an instance out of `blogByNatsumiFactory` will give you a blog entry
that looks like the following:

```javascript
blogByNatsumiFactory.create() // =>
{
  title: 'How to make falafel',
  body: 'Lorem ipsum dolor sit amet',
  metadata: {
    tags: ['cooking', 'middle-eastern'],
    author: 'Natsumi'
  },
}
```

-------

### `factory.create()`

Create an instance using this [`Factory`](#factory). In most cases, this
creates an instance of `Object`, but that depends on the
[`Definitions`](#definition) that were used to build up the
`Factory`. Optionally, also accepts a [`Definition`](#definition) that can be used to override existing values or add new values to the created instance.

#### Usage:

```javascript
var instance = factory.create()
var instance = factory.create(definition)
```

#### Example:

If we're starting with a `Factory` that's alredy been created:

```javascript
var factory = require('unionized');
var creditCardFactory = factory.factory({
  type: 'Visa',
  last4: '1111',
  'exp.month': '04'
  'exp.year': '15'
})
```

...then you can create an instance and override things with `create()`:

```javascript
var card = creditCardFactory.create({
  name: 'Chloris Elisaveta'
  'exp.year': '17'
}) // =>
{
  type: 'Visa',
  last4: '1111',
  exp: {
    month: '04'
    year: '17'
  },
  name: 'Chloris Elisaveta'
}
```

If any of the [`Definitions`](#definition) that make up the Factory are
asynchronous, you should use [`factory.createAsync()`](#factorycreateasync);
using `factory.create()` will throw an exception.

-------

### `factory.createAsync()`

Create an object asynchronously, using this [`Factory`](#factory). This method returns a `Promise` for an instance. In most cases, the instance will be an `Object`, but that depends on the
[`Definitions`](#definition) that were used to build up the `Factory`.
Optionally, accepts a [`Definition`](#definition) that can be used to override
existing values or add new values to the created instance. Optionally, also
accepts a traditional Node-style callback function which returns the instance.

This method can be used with a factory whose `Definitions` are entirely
synchronous, or with an object whose `Definitions` are asynchronous &mdash; in
either case, `createAsync()` will do its work asynchronously.

#### Usage:

```javascript
// Promises
factory.createAsync().then(function(instance) { /* ... */ })
factory.createAsync(definition).then(function(instance) { /* ... */ })

// Callbacks
factory.createAsync(function(err, instance) { /* ... */ })
factory.createAsync(definition, function(err, instance) { /* ... */ })
```

#### Example:

If we're starting with a `Factory` that's already been created:

```javascript
var factory = require('unionized');
var request = require('request');
var quoteSource = 'http://www.iheartquotes.com/api/v1/random';
var quoteFactory = factory.factory({
  content: factory.async(function (done) {
    request(quoteSource, function(err, response, body) { done(err, body) });
  }),
  source: quoteSource
});
```

...then you can create an instance and override things with `createAsync()`
(using the **promise** syntax):

```javascript
var promise = quoteFactory.createAsync({createdAt: new Date()})
promise.then(function (quote) {
  quote // =>
  {
    content: "A man who turns green has eschewed protein.",
    source: "http://www.iheartquotes.com/api/v1/random",
    createdAt: '2015-05-18T06:17:16.989Z'
  }
})
```

Alternatively, here's the same example using node-style callbacks:

```javascript
quoteFactory.createAsync({createdAt: new Date()}, function (err, quote) {
  quote // =>
  {
    content: "The best laid plans of mice and men are usually about equal."
    source: "http://www.iheartquotes.com/api/v1/random",
    createdAt: '2015-05-18T06:17:16.989Z'
  }
})
```

-------

### `factory.array()`

Terse syntax to create an `ArrayDefinition`. Allows you to specify an array by
describing an object to repeat, and a default length.

#### Usage:

```
var arrayDefinition = factory.array(definition, length)
```

#### Example:

Here is a factory for a carton of green eggs:

```javascript
var factory = require('unionized');
var eggCartonFactory = factory.factory({
  eggs: factory.array({shellColor: 'ecru', yolkColor: 'yellow'}, 12)
})
eggCartonFactory.create() // =>
{
  eggs: [
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
  ]
}
```

Here we create a half-carton with one green egg:

```javascript
eggCartonFactory.create({'eggs[]': 6, 'eggs[1].shellColor': 'green'}) // =>
{
  eggs: [
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'green', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
    { shellColor: 'ecru', yolkColor: 'yellow' }
  ]
}
```

-------

### `factory.async()`

Create an asynchronous factory definition using node-style callbacks.

#### Usage:

```javascript
var asyncDefinition = factory.async(function(done) { done(error, definition) })
```

#### Example:

Let's say we want to grab the contents of a file in a factory:

```javascript
var factory = require('unionized');
var fs = require('fs');
var fileFactory = factory.factory({
  name: 'paul-clifford.txt'
  contents: factory.async(function(done) {
    fs.readFile('paul-clifford.txt', {encoding: 'utf-8'}, done)
  })
});
fileFactory.createAsync(function(err, file) {
  file // =>
  {
    name: 'paul-clifford.txt',
    contents: 'It was a dark and stormy night; the rain fell in torrents...'
  }
})
```

-------

### `factory.enum()`

-------

### `factory.mongooseFactory()`

------

## `Definition`


