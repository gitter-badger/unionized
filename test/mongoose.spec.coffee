expect = require('chai').expect
moment = require 'moment'
mongoose = require 'mongoose'
unionized = require '..'

mongoose.connect('mongodb://localhost/test')

describe 'mongoose tests', ->

  beforeEach ->
    @instance = null

  describe 'an instance generated by the factory with no inputs', ->
    before ->
      @Model = mongoose.model 'Kitten1', mongoose.Schema
        name: { type: String, required: true }
        cutenessPercentile: { type: Number, required: true }
        personality: { type: String, required: true, enum: ['friendly', 'fierce', 'antisocial', 'changeable'] }
        eyeColor: { type: String, default: 'yellow', required: true }
        isHunter: { type: Boolean, required: true }
        bornAt: { type: Date, required: true }
        description: String

      @factory = unionized.mongooseFactory @Model

    beforeEach (done) ->
      @factory.createAsync (error, @instance) => done error

    it 'has an _id', ->
      expect(@instance._id).to.be.an.instanceOf mongoose.Types.ObjectId

    it 'can generate a string', ->
      expect(@instance.name).to.be.a 'string'

    it 'can generate a number', ->
      expect(@instance.cutenessPercentile).to.be.a 'number'

    it 'can generate within an enum', ->
      expect(@instance.personality in ['friendly', 'fierce', 'antisocial', 'changeable']).to.be.ok

    it 'can generate a boolean', ->
      expect(@instance.isHunter).to.be.a 'boolean'

    it 'can generate a date (default in 2013)', ->
      born = moment(@instance.bornAt)
      expect(born.isAfter  '2012-12-31').to.be.ok
      expect(born.isBefore '2014-01-01').to.be.ok

    it 'will use provided defaults', ->
      expect(@instance.eyeColor).to.equal 'yellow'

    it 'will ignore non-required attributes', ->
      expect(@instance.description).to.be.undefined

    it 'is a model', ->
      expect(@instance).to.be.an.instanceof @Model

  describe 'arrays', ->
    before ->
      Model = mongoose.model 'Kitten2', mongoose.Schema
        paws: [
          nickname: { type: String, required: true }
          clawCount: Number
        ]

      @factory = unionized.mongooseFactory Model

    beforeEach (done) ->
      @factory.createAsync (error, @instance) => done error

    it 'can generate an array', ->
      expect(@instance.paws).to.be.an.instanceOf Array

    it 'generates required properties on array elements', ->
      expect(@instance.paws[0]).to.be.a 'object'
      expect(@instance.paws[0]).to.have.property 'nickname'
      expect(@instance.paws[0].clawCount).not.to.be.ok

  describe 'deeply-nested attributes', ->
    before ->
      @Model = mongoose.model 'Kitten3', mongoose.Schema
        meta:
          owner:
            name: { type: String, required: true }
            age: Number

      @factory = unionized.mongooseFactory @Model

    beforeEach (done) ->
      @factory.createAsync (error, @instance) => done error

    it 'are generated', ->
      expect(@instance?.meta?.owner?.name).to.have.length.of.at.least 1
      expect(@instance?.meta?.owner?.age).not.to.be.ok

  describe 'an instance generated with inputs', ->
    before ->
      @Model = mongoose.model 'Kitten4', mongoose.Schema
        name: { type: String, required: true }
        meta:
          owner:
            name: { type: String, required: true }
            age: Number

      @factory = unionized.mongooseFactory @Model

    beforeEach (done) ->
      @factory.createAsync {
        name: 'John Doe'
        meta:
          owner:
            age: 30
        'meta.owner.name': 'Joe Shmoe'
      }, (error, @instance) => done error

    it 'respects top-level inputs', ->
      expect(@instance).to.have.property 'name', 'John Doe'

    it 'respects deeply-nested object inputs', ->
      expect(@instance?.meta?.owner?.age).to.equal 30

    it 'respects deeply-nested dot-pathed arguments', ->
      expect(@instance?.meta?.owner?.name).to.equal 'Joe Shmoe'

    it 'is a model', ->
      expect(@instance).to.be.an.instanceof @Model

  describe 'extending factories', ->
    before ->
      @Model = mongoose.model 'Kitten5', mongoose.Schema
        name: { type: String, required: true }
        age: { type: Number, required: true }
        description: String

      @factory = unionized.mongooseFactory(@Model).factory name: 'Fluffy'

    beforeEach (done) ->
      @factory.createAsync { description: 'Big ball of fluff' }
      , (error, @instance) => done error

    it 'combines default attributes', ->
      expect(@instance).to.have.property 'name', 'Fluffy'
      expect(@instance).to.have.property 'age'
      expect(@instance.age).to.be.a 'number'

    it 'takes inputs', ->
      expect(@instance).to.have.property 'description', 'Big ball of fluff'

    it 'is a model', ->
      expect(@instance).to.be.an.instanceof @Model

  describe 'saving', ->
    before ->
      @Model = mongoose.model 'Kitten6', mongoose.Schema
        name: { type: String, required: true }
        age: { type: Number, required: true }
        description: String

      @factory = unionized.mongooseFactory(@Model).factory name: 'Fluffy'

    beforeEach (done) ->
      @factory.createAndSave({description: 'Big ball of fluff'}, (error) => done error)

    it 'saves the kitten to the database', (done) ->
      @Model.find (err, kittens) ->
        expect(kittens[0]).to.have.property 'description', 'Big ball of fluff'
        done(err)

  describe 'lean creation', ->
    before ->
      @Model = mongoose.model 'Kitten7', mongoose.Schema
        name: { type: String, required: true }
        age: { type: Number, required: true }
        description: String

      @factory = unionized.mongooseFactory(@Model).factory name: 'Fluffy'

    beforeEach (done) ->
      @factory.createLeanAsync { description: 'Big ball of fluff' }
      , (error, @instance) => done error

    it 'sets attributes properly', ->
      expect(@instance).to.have.property 'description', 'Big ball of fluff'

    it 'is not a model', ->
      expect(@instance).to.not.be.an.instanceof @Model
