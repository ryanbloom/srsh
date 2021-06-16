# `srsh`: Spaced Repetition for SHell commands

`srsh` is a simple program designed to help you learn shell commands.

## Installation

You'll need to have [Crystal](https://crystal-lang.org) installed.
Then just clone the repo and `crystal build src/main.cr -o srsh`.
Put the output somewhere in your `$PATH`.

## Getting started

First, create a text file with some examples of the commands
you want to learn. 

```
# Navigation

123
List the files in the current directory, including hidden files.
ls -a
```

Here, `123` is a unique ID for the exercise. You can leave it out, but
then any modification will be imported as a new exercise instead of a 
replacement for the old one. Exercises will be presented with the most
recent heading (denoted with `#`) to provide context.

To import a file, use `srsh import exercises.txt`. This will read in all the
exercises and put them into a SQLite database at `~/srsh.db`. You can change
the location of the database with the environment variable `$SRSH_DB`.

## Review

`srsh` automatically schedules exercises for review at increasing intervals.
To start a review session, simply run `srsh`.

To delete an exercise, type `!del` when prompted for the answer.
