module.exports =
class MavenBuildView
  constructor: (serializeState) ->
    # Register command that toggles this view
    atom.commands.add 'atom-workspace', 'maven-build:toggle': => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->

  # Toggle the visibility of this view
  toggle: ->
    console.log 'Maven Build toggled!'
