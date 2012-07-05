## git-check-ci

Display your continuous integration status in your prompt!

This tool will show a `✗` for failed builds, a `✔` for successful builds,
a `-` when the latest build is pending, and a `?` on errors.

### Installing

    gem install --no-wrappers git-check-ci

The `no-wrappers` option is very important. Without it, checks will jump from 50ms to 400ms---unacceptable for something that lives in your prompt.
This is because `require 'rubygems'` is awfully slow, even if you're usgin [Slimgems](http://slimgems.github.com/) instead of the stock [Rubygems](http://rubygems.org/).

    
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

Add it to your prompt:
    
    $ vi ~/.profile
    
    export PS1="\$(git-check-ci fast-check) \u\$"

Reload your shell:

    $ exec $SHELL -l

You're done! You should see:

    ✗ mezis$

