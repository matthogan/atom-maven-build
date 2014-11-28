# decls
path = require('path')
{View, BufferedProcess, $$} = require 'atom'
COMMANDS = {VERSION:'--version',PACKAGE:'package'}
MavenBuildView = require './maven-build-view'

module.exports =
  mavenBuildView: null

  # configuration items for maven
  config:
    mvnPath:
      type: 'string'
      default: 'mvn.bat'
    settings:
      type: 'string'
      default: 'C:\\projects\\pl\\maven\\settings.xml'
    javaHome:
      type: 'string'
      default: 'C:\\Java\\jdk1.7.0_45'
    m2Home:
      type: 'string'
      default: 'C:\\Java\\apache-maven-3.1.1'
    debug:
      type: 'boolean'
      default: true

  activate: (state) ->
    @mavenBuildView = new MavenBuildView(state.mavenBuildViewState)
    atom.commands.add 'atom-workspace', 'maven-build:mavenVersion', => @mavenVersion()
    atom.commands.add 'atom-workspace', 'maven-build:mavenPackage', => @mavenPackage()

  deactivate: ->
    @mavenBuildView.destroy()

  serialize: ->
    mavenBuildViewState: @mavenBuildView.serialize()

  debug: (text) ->
    if atom.config.get('maven-build.debug')
      console.log("debug::[#{text}]")
    yes

  mavenConfig: ->
    {command:atom.config.get('maven-build.mvnPath'),
    settings:atom.config.get('maven-build.settings'),
    javaHome:atom.config.get('maven-build.javaHome'),
    m2Home:atom.config.get('maven-build.m2Home')}

  # all mandatory even though they can be set at the os-level
  mavenValidateSettings: (target) ->
    valid = yes if target
    @debug("mavenValidateSettings::Valid.target=#{valid}")

    config = @mavenConfig()

    valid = no if valid and not config.command or config.command.trim() is ''
    @debug("mavenValidateSettings::Valid.command=#{valid}")
    valid = no if valid and not config.settings or config.settings.trim() is ''
    @debug("mavenValidateSettings::Valid.settings=#{valid}")
    valid = no if valid and not config.javaHome or config.javaHome.trim() is ''
    @debug("mavenValidateSettings::Valid.javaHome=#{valid}")
    valid = no if valid and not config.m2Home or config.m2Home.trim() is ''
    @debug("mavenValidateSettings::Valid.m2Home=#{valid}")
    # why do I need this?
    valid

  # run that maven thingy
  mavenExec: (target) ->
    valid = @mavenValidateSettings(target)
    # meaningful indentation...
    if not valid
      no
    else
      # exec params
      config = @mavenConfig()
      # get the full path, windows stylee
      command = "#{config.m2Home}#{path.sep}bin#{path.sep}#{config.command}"
      # only if settings are being customised
      args = [target]
      # need the settings.xml be customised
      if config.settings
        args.push '--settings'
        args.push config.settings
      # usual streams, wouldn't let me pass @debug
      stdout = (output) -> console.log(output)
      stderr = (output) -> console.log(output)
      exit = (returnCode) -> console.log("Exited with #{returnCode}")
      # see http://nodejs.org/api/child_process.html#child_process_child_process_spawn_command_args_options
      env = {JAVA_HOME:config.javaHome,M2_HOME:config.m2Home}
      # must of course have a pom in the directory...
      options =
        cwd: atom.project.getPath()
        env: env
      # nodejs' own spawn/exec wrapper
      process = new BufferedProcess({command, args, options, stdout, stderr, exit})
      # haven't quite got my head around this implicit
      # mathematical function concept as it applies to
      # coffeescript...
      yes

  mavenPackage: ->
    @mavenExec(COMMANDS.PACKAGE)

  mavenVersion: ->
    @mavenExec(COMMANDS.VERSION)
