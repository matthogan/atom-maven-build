{WorkspaceView} = require 'atom'
MavenBuild = require '../lib/maven-build'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MavenBuild", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('maven-build')

  describe "when the maven-build:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.maven-build')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch atom.workspaceView.element, 'maven-build:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.maven-build')).toExist()
        atom.commands.dispatch atom.workspaceView.element, 'maven-build:toggle'
        expect(atom.workspaceView.find('.maven-build')).not.toExist()
