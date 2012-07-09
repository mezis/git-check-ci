## git-check-ci

Display your continuous integration status in your prompt!
This tool helps you decorate your command line with `✗` for failed builds and `✔` for successful builds.

It assumes you're running a CI server that responds to a `/:project/ping` endpoint with status 200 on build successes.

### Installing

As simple as it gets:

    gem install git-check-ci


### Configuring

Go to a Git clone of the project you've placed under CI:

    $ cd <my-repository>

Run the setup command:
    
    $ git check-ci setup
    
    What is the URL of your CI server? [currently unset]
    > http://my-integrity-server:port
    
    What is the name of the project you're checking? [currently unset] 
    > integrity-project-name
    
    If the server requires a login, what should I use? [currently unset]
    > john.mcfoo
    
    with which passphrase? [currently unset]
    
    Setup is now complete. Doing a test run.
    All good! Now the 'check' and 'fast-check' commands should work.

Add it to your prompt (simplistic example):
    
    --- add me to e.g. ~/.profile ---
    eval "$(git check-ci init)"
    export PS1="\[\$(_git_ci_color)\]\$(_git_ci_status) \u@\h\$"

Reload your shell:

    $ exec $SHELL -l

You're done! You should see the following while it's starting up:

    ? mezis$

And after hitting return a few times, assuming your build is broken:

    ✗ mezis$

It's red... Time to make it green and refactor!
Happy coding!


### Status icons

This tool will show:

- nothing when not in a Git repository.
- `✗` for failed builds.
- `✔` for successful builds.
- `●` when the latest build is pending or in progress.
- `?` if the configuration is incomplete, or the check service is starting up.
- `!` on failures (properly configured but checking failed).


### Behind the scenes

The `GitCheckCI` shell helper does two things:

- it spawns a checking service with `git check-ci server_start`
- it returns the contents of the `ci.status` Git configuration variable

The spawned server check the CI status over HTTP every minute and stores the response in the Git configuration (used as an IPC of sorts).

It's done that way because the `_git_ci_*` shell functions need to be really, really fast---anything slower than 30ms will make your prompt feel unresponsive.

